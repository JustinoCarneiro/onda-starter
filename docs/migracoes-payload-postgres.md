# Playbook — gerar, revisar e testar migração Payload 3 + Postgres

Origem: projeto Heliene Araújo. Toda migração é R2 (produção / migração de dados).

## Testar contra um CLONE do schema de produção, nunca contra o dev sujo

```bash
# 1. banco limpo + aplica TODAS as migrações anteriores (N-1)
createdb <db>_migrate_gen
DATABASE_URI=postgres://.../<db>_migrate_gen  payload migrate

# 2. TIRAR a migração nova de cena (mover os .ts/.json e a linha do index.ts),
#    aplicar as N-1, e SÓ ENTÃO semear os casos difíceis:
#    - registro só com locale PT
#    - registro só com locale EN
#    - registro com os dois (e com espaço acidental, p/ testar trim)
#    - lista longa (ex.: 18 itens)
#    - campo opcional vazio

# 3. devolver a migração e gerar/aplicar
DATABASE_URI=...  payload migrate:create <nome>
#    revisar o .ts gerado (ver armadilhas abaixo)
DATABASE_URI=...  payload migrate           # up
DATABASE_URI=...  payload migrate:down      # down
DATABASE_URI=...  payload migrate           # up de novo — o ciclo tem que ser limpo
```

## Armadilhas do gerador (todas já mordidas)

### Re-adiciona coluna que já existe
Se uma migração anterior foi escrita **à mão sem o `.json` de snapshot**, o gerador diffa
contra um retrato velho e emite `ALTER TABLE ... ADD COLUMN` de algo que já está no banco
→ `column already exists` **derruba o deploy em produção**.
**Fix:** sempre deixar o `migrate:create` gerar o `.json`. Se pegar uma migração à mão
sem `.json`, **remover do diff novo** os `ADD COLUMN` que já existem (e conferir contra
`information_schema.columns` do clone).

### `down()` com `DROP TABLE ... CASCADE`
O CASCADE já remove as FKs e índices dependentes. Os `DROP CONSTRAINT` / `DROP INDEX`
explícitos que o gerador coloca **depois** falham com "does not exist".
**Fix:** `IF EXISTS` em **todo** drop do `down()`.

### Ordem no move de dados
- No `up()`: mover o dado para a estrutura nova **ANTES** do `DROP COLUMN` da antiga.
- No `down()`: recriar a coluna antiga e **restaurar** o dado **ANTES** do `DROP TABLE`
  da estrutura nova. O gerador coloca na ordem errada — reordenar à mão.

### Campo localizado (texto único) → `hasMany` não-localizado
`hasMany`-text fica em `<tabela>_texts` (`id serial`, `order int NOT NULL`, `parent_id`,
`path varchar`, `text varchar`) + `_<tabela>_v_texts` para versões. Mover com fallback de
locale — um registro editado só em EN teria o valor só na linha `en`:

```sql
INSERT INTO "projects_texts" ("order", "parent_id", "path", "text")
SELECT 0, p."id", 'municipalities', trim(v.val)
  FROM "projects" p
  CROSS JOIN LATERAL (
    SELECT COALESCE(
      NULLIF(trim((SELECT "municipality" FROM "projects_locales" WHERE "_parent_id"=p."id" AND "_locale"='pt')), ''),
      NULLIF(trim((SELECT "municipality" FROM "projects_locales" WHERE "_parent_id"=p."id" AND "_locale"='en')), '')
    ) AS val
  ) v
 WHERE v.val IS NOT NULL;
```

No `down()`, restauro best-effort (o campo era único, só dá para devolver o primeiro):

```sql
UPDATE "projects_locales" pl SET "municipality" = t.first_text
  FROM (SELECT DISTINCT ON ("parent_id") "parent_id", "text" AS first_text
          FROM "projects_texts" WHERE "path"='municipalities' ORDER BY "parent_id","order") t
 WHERE pl."_parent_id" = t."parent_id";
```

### `payload migrate` PENDURA local
Prompt `batch=-1` em non-TTY quando o schema foi dev-pushado sem registro de migração —
aplicar o SQL à mão via `psql` e inserir a linha em `payload_migrations`
(`INSERT ... ON CONFLICT DO NOTHING`).

## Backfill de `_order` (ordenação manual)

Ver `memoria-tecnica/decisoes/ordenacao-manual-orderable-com-backfill.md`.

## Revisão

Mandar o diff da migração pro Codex (`codex review --uncommitted`, roda em background,
buffer só no fim). No projeto de referência ele pegou: perda de dado só-EN, ordem do
`down()`, agregação sem `pagination:false`. Corrigir e re-testar o ciclo antes de fechar.

## Exemplo completo

`src/migrations/20260909_133259_add_blog_media_agenda_image_project_municipalities_auto_stats.ts`
no projeto Heliene.
