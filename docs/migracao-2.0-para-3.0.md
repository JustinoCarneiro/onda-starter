# Migração OndaDev 2.0 → 3.0

## O que a 3.0 muda

A 2.0 assumia **um agente** (Claude Code no terminal) e **Antigravity** como
IDE/orquestrador. A 3.0 assume **dois agentes** (Claude Code e Codex) com um
contrato compartilhado, **VS Code** como editor canônico e um protocolo de
failover para quando a cota de um acabar. O método das 6 fases não muda; muda a
infraestrutura e a governança.

| Tema | 2.0 | 3.0 |
| --- | --- | --- |
| Editor | Antigravity (IDE/orquestrador) | **VS Code** canônico; Antigravity só laboratório opcional |
| Orquestração | Antigravity | **Codex Desktop** (worktrees, tarefas longas) |
| Par no terminal | Claude Code | **Claude Code** (contexto quente, revisão crítica) |
| Contrato | `CLAUDE.md` por projeto | `AGENTS.md` canônico + `CLAUDE.md` importa `@AGENTS.md` |
| Skills | 12 comandos só do Claude em `setup/claude/` | 6 skills `ondadev-*` em `setup/shared/skills/`, sincronizadas para Claude e Codex |
| Node | baseline 20 | baseline **22+** |
| IDs de modelo | fixos de 2024 nos subagentes | `inherit` ou alias atual |
| Continuidade | oral / memória do agente | `.ondadev/handoff/` + `scripts/ai-checkpoint.sh`, limiares 75/90/100% |
| Qualidade | CI placeholder | CI com validações determinísticas, smoke do instalador e secret scanning |
| Versão | implícita | arquivo `ONDA_VERSION` |

## `ONDA_VERSION`

A raiz do repositório tem um arquivo `ONDA_VERSION` com a versão da metodologia
que o projeto segue (hoje `3.0.0`, semver). Um projeto derivado **declara**
explicitamente sua versão copiando esse arquivo e ajustando quando migrar. Ler
`ONDA_VERSION` responde "qual OndaDev este repo usa?" sem adivinhação.

## Passos para migrar um projeto 2.0

1. **Contrato.** Adicione `AGENTS.md` na raiz (mapa, comandos, fronteiras,
   segurança, DoD). Faça `CLAUDE.md` importar `@AGENTS.md` na primeira linha e
   manter só o que é específico do Claude.
2. **Versão.** Copie `ONDA_VERSION` (`3.0.0`).
3. **Skills.** Instale as skills `ondadev-*` de `setup/shared/skills/` nos dois
   destinos: `bash setup/shared/sync-skills.sh`. Os comandos antigos `onda-*`
   seguem funcionando com aviso de depreciação até o fim do piloto.
4. **Toolchain.** Suba o baseline para Node 22+. Rode `bash setup/install.sh
   --dry-run` antes de instalar.
5. **Modelos.** Troque qualquer `model:` datado de subagente por `model:
   inherit`.
6. **Continuidade.** Traga `.ondadev/` e `scripts/ai-checkpoint.sh`. Adote os
   limiares 75/90/100%.
7. **Ambiente Codex.** Se o projeto justifica worktrees, gere `.codex/` pelo
   painel do Codex Desktop e versione (ver `setup/codex/`).
8. **CI.** Adote `.github/workflows/ci.yml` e `.pre-commit-config.yaml`. Habilite
   secret scanning e required checks nas configurações do GitHub.
9. **Metodologia.** Não copie o texto integral do playbook. Referencie a versão
   em `ONDA_VERSION` e mantenha só as adaptações locais.

## Compatibilidade

- Os comandos `onda-*` legados continuam resolvendo durante o piloto (PR-08) e
  emitem aviso de migração. Serão removidos depois.
- Nenhuma mudança quebra a estrutura de artefatos (`CLAUDE.md`, `spec.md`,
  `ROADMAP.md`, `memoria-tecnica/`, `docs/METRICAS-PROJETO.md`).
- O cálculo de prazo (peso dos módulos) é idêntico.

## Fontes canônicas na 3.0

| Assunto | Onde |
| --- | --- |
| Contrato de trabalho | `AGENTS.md` |
| Fases, papéis, evidência | `docs/Metodologia_de_Desenvolvimento_-_Onda.md` |
| Skills | `setup/shared/skills/` |
| Failover de cota | `.ondadev/README.md` |
| Worktrees | `setup/WORKTREE.md` |
| Versão da metodologia | `ONDA_VERSION` |
