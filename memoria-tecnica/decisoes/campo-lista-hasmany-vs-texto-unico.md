---
tipo: decisao
data: 2026-09-09
status: Ativa
origem: projeto Heliene Araújo
---

# Campo simples vira lista (`hasMany`) quando "um X pode ter vários Y"

## Contexto
"Município do projeto" era `type: 'text'` localizado. Um projeto real abrangeu **18
municípios** — o indicador "municípios atendidos" ficava impossível de bater.

## Decisão
`type: 'text', hasMany: true` (input estilo tags — digita, Enter, próximo). **Não**
localizado: nome de município/instituição/pessoa é nome próprio, igual nos dois idiomas —
localizar obrigaria digitar a mesma lista duas vezes.

O indicador conta os **distintos** somando as listas de todos os registros publicados
(trim, case-insensitive).

## Consequências
- Precisa de **migração de dado** (ver [[migracoes-payload-postgres]]): `hasMany`-text
  fica em `<tabela>_texts` (`path`, `order`, `text`, `parent_id`) + `_<tabela>_v_texts`
  para versões. Mover o valor antigo com `COALESCE(pt, en)` e `trim`.
- O campo **sai do `autoTranslateHook`**.
- `defaultColumns` do admin: tirar o campo (lista não renderiza bem como coluna).
- Contagem de distintos vira helper puro e testável:
  `countDistinct(rows.flatMap(r => r.municipalities ?? []))` com trim + lowercase.
- Aplica sempre que um campo simples precisa virar "vários" (categorias, tags, parceiros,
  áreas).

## Ligado a
- [[indicadores-agregados-contados-ao-vivo]]
- [[migracoes-payload-postgres]]
