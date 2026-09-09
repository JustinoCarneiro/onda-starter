---
tipo: decisao
data: 2026-09-09
status: Ativa
origem: projeto Heliene Araújo
---

# Ordenação manual de collection: `orderable: true` + backfill de `_order`

## Contexto
O cliente quer decidir a ordem em que os projetos aparecem no site (destacar o mais
relevante), sem depender da data de cadastro nem do desenvolvedor.

## Decisão
`orderable: true` na `CollectionConfig` → arrastar na lista do painel (alça de pontinhos
à esquerda da linha). O frontend lê `sort: '_order'`. Os N primeiros da ordem viram os
destaques da Home.

## Consequências
- **A migração precisa fazer backfill de `_order`** nos registros que já existem — sem
  isso saem em ordem indefinida no primeiro acesso. Índice fracionário em texto:
  ```sql
  UPDATE "projects" p
     SET "_order" = 'a' || substr('0123456789abcdefghijklmnopqrstuvwxyz', s.rn::int, 1)
    FROM (SELECT id, row_number() OVER (ORDER BY created_at DESC) AS rn FROM "projects") s
   WHERE p.id = s.id AND s.rn <= 36 AND p."_order" IS NULL;
  ```
  (`'a'` + dígito base36 ordena certo por comparação lexicográfica; acima de 36 registros
  os restantes ficam NULL e o Payload atribui no primeiro arraste). Espelhar em
  `_<tabela>_v`.
- Semear com a **mesma ordem que o site já exibia** (ex.: mais recente primeiro) para o
  deploy não mudar nada visualmente.
- As alças de arrastar só aparecem com a lista **ordenada pela coluna de ordem** no
  painel — vale avisar o cliente no manual.
- Testar no painel de verdade (e2e logado), não só a config: `test.setTimeout(180_000)`,
  só no projeto desktop.

## Ligado a
- [[migracoes-payload-postgres]]
