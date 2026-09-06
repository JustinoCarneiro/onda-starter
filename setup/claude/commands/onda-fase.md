---
name: onda-fase
description: Invoca e muda para a fase especifica da metodologia.
argument-hint: [numero-fase]
---

> ⚠️ **Comando legado — em depreciação (OndaDev 3.0).** Migrou para a skill
> **`ondadev-discovery`** (`setup/shared/skills/ondadev-discovery/`, referência
> `references/mapa-de-fases.md`). Este wrapper continua funcionando durante o
> piloto e será removido após o PR-08. Prefira `/ondadev-discovery` (Claude) ou a
> skill `ondadev-discovery` (Codex).

Mova o contexto atual de trabalho para a Fase `$1` da Metodologia Onda.
Confirme os artefatos de entrada e chame a skill correspondente (ex: `onda-layout` para Fase 2).
