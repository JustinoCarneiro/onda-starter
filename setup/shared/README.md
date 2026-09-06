# Skills OndaDev compartilhadas

Fonte única das skills da metodologia OndaDev, agnóstica de fornecedor. Um único
conteúdo canônico é sincronizado, sem edição manual, para os destinos de Claude
e de Codex dentro do repositório.

## Estrutura

```
setup/shared/
  skills/                     # FONTE CANÔNICA — edite aqui
    ondadev-discovery/
      SKILL.md
      references/             # perfis e material sob demanda
    ondadev-spec/SKILL.md
    ondadev-experience/SKILL.md
    ondadev-blueprint/SKILL.md
    ondadev-build/SKILL.md
    ondadev-release/SKILL.md
  sync-skills.sh              # sincronizador determinístico
  skills-manifest.sha256      # manifesto de hashes da fonte canônica

.claude/skills/ondadev-*/     # DESTINO Claude   — gerado, não edite
.agents/skills/ondadev-*/     # DESTINO Codex    — gerado, não edite
```

## Regras

- **Edite apenas `setup/shared/skills/`.** Os diretórios `ondadev-*` em
  `.claude/skills/` e `.agents/skills/` são cópias geradas; qualquer edição
  neles é sobrescrita pelo sincronizador e acusada pelo teste de drift.
- Uma alteração canônica gera **conteúdo idêntico** nos dois destinos.
- Scripts são determinísticos: nenhuma decisão de conteúdo mora neles. O
  raciocínio e as instruções vivem nos `SKILL.md`.

## Uso

```bash
# Sincronizar a fonte canônica para os dois destinos e regenerar o manifesto
bash setup/shared/sync-skills.sh

# Só verificar (não escreve); falha se houver drift ou manifesto desatualizado
bash setup/shared/sync-skills.sh --check

# Regenerar apenas o manifesto de hashes
bash setup/shared/sync-skills.sh --manifest

# Testes
bash setup/tests/skills-drift.sh          # manifesto + destinos + IDs de modelo
bash setup/tests/skills-frontmatter.sh    # ativação explícita e implícita
```

## As seis skills canônicas

| Skill | Fase | Substitui (comandos legados) |
| --- | --- | --- |
| `ondadev-discovery` | 0 · Descoberta / Scaffolding | `onda-novo`, `onda-fase`, `perfil-*`, `onda-proposta` |
| `ondadev-spec` | 1 · Spec Viva | `onda-spec-viva` |
| `ondadev-experience` | 2 · Experiência verificável | `onda-layout` |
| `ondadev-blueprint` | 3 · Blueprint executável | `onda-blueprint` |
| `ondadev-build` | 4 · Construção em pequenos lotes | `diretiva-primaria` |
| `ondadev-release` | 5 · Release e operação | — (nova) |

Os comandos legados em `setup/claude/commands/` continuam funcionando com aviso
de depreciação durante o piloto (PR-08) e serão removidos depois.

## Ativação

- **Explícita:** `/ondadev-spec` (Claude) ou selecionar a skill `ondadev-spec`
  (Codex). O campo `name` do frontmatter é o identificador.
- **Implícita:** o campo `description` descreve o gatilho — o agente ativa a
  skill quando a tarefa corresponde. Descrições sem contexto de uso quebram a
  ativação implícita e são reprovadas por `skills-frontmatter.sh`.
