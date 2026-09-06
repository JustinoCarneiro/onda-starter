# 0001 — Skills OndaDev compartilhadas com fonte canônica única

## Contexto

O ecossistema OndaDev tinha 12 comandos e 3 subagentes exclusivos do Claude
Code em `setup/claude/`, com perfis arquiteturais como comandos soltos e IDs de
modelo datados (2024) fixados nos subagentes. Codex e Claude precisam iniciar o
mesmo processo, mas cada um lê skills de um diretório próprio
(`.claude/skills/` e `.agents/skills/`). Cópias manuais divergem com o tempo
(drift), e procedimentos longos no contexto automático encarecem cada tarefa.

O roadmap OndaDev 3.0 (PR-03, gate G3) exige: seis skills de responsabilidade
única, perfis como referência sob demanda, compatibilidade temporária com os
comandos antigos, remoção de IDs de modelo datados, sincronização determinística
para os dois destinos, manifesto de hashes e teste de drift.

## Decisão

1. **Fonte canônica única:** `setup/shared/skills/` contém as seis skills
   (`ondadev-discovery`, `ondadev-spec`, `ondadev-experience`,
   `ondadev-blueprint`, `ondadev-build`, `ondadev-release`), cada uma com um
   `SKILL.md` (frontmatter `name` + `description`) e um diretório `references/`
   opcional. É o único lugar que se edita.
2. **Perfis viram referência:** `app`, `ecommerce`, `lp`, `sistema` e
   `automacao` passam a ser arquivos em
   `ondadev-discovery/references/perfil-*.md`, carregados um de cada vez.
3. **Sincronização determinística:** `setup/shared/sync-skills.sh` espelha a
   fonte canônica em `.claude/skills/ondadev-*` e `.agents/skills/ondadev-*`,
   normaliza permissões e regenera `setup/shared/skills-manifest.sha256`. O
   script não contém decisão de conteúdo — só cópia e hash.
4. **Testes:** `setup/tests/skills-drift.sh` (manifesto + destinos idênticos à
   fonte e entre si + ausência de ID de modelo datado no repo) e
   `setup/tests/skills-frontmatter.sh` (ativação explícita por `name` e
   implícita por `description`).
5. **Subagentes:** os três em `setup/claude/agents/` passam a usar
   `model: inherit` — respeita o modelo e a cota da sessão, sem fixar versão.
6. **Compatibilidade:** os 12 comandos legados em `setup/claude/commands/`
   continuam funcionando com um aviso de depreciação no topo, apontando para a
   skill equivalente. Serão removidos após a retro leve de rollout definida no
   [ADR 0002](0002-capacidade-sob-orcamento-fixo.md) (ponto 2) — quando ~5–10
   tarefas reais em repositórios migrados confirmarem que as skills `ondadev-*`
   cobrem os fluxos que os comandos `onda-*` cobriam. Não há mais gatilho "PR-08".

## Consequências

- Uma alteração canônica gera conteúdo idêntico para Claude e Codex; o CI
  (PR-06) passa a bloquear drift, ID de modelo datado e frontmatter inválido
  chamando os scripts já existentes.
- Os destinos `.claude/skills/` e `.agents/skills/` são **gerados**: editá-los
  diretamente é sobrescrito pelo sync e acusado pelo teste de drift.
- Ao adicionar/renomear uma skill, rode `bash setup/shared/sync-skills.sh` e
  commite fonte, destinos e manifesto juntos.
- O `install.sh --component skills` passa a espelhar as skills canônicas em
  `~/.claude/skills/` (e `~/.agents/skills/` se houver Codex), além dos assets
  legados.
- A tabela "Mapa de fases e skills" do `ROADMAP.md` template ainda cita os nomes
  antigos (`onda-*`); o realinhamento de nomenclatura nos documentos de
  metodologia pertence ao PR-07.

## Alternativas consideradas

- **Manter comandos só do Claude e duplicar para o Codex à mão:** rejeitada —
  é exatamente o drift que o PR-03 elimina.
- **Symlink entre destinos em vez de cópia:** rejeitada — nem todo checkout,
  empacotamento ou runner preserva symlink; a cópia + manifesto é verificável
  em qualquer ambiente.
- **Aliases de modelo (`sonnet`/`opus`) nos subagentes em vez de `inherit`:**
  preterida — fixaria capacidade e custo; `inherit` segue a política de cota do
  OndaDev 3.0. Um projeto derivado pode trocar por um alias se justificar.
- **Gerar os destinos em tempo de CI e não versioná-los:** rejeitada — o teste
  de drift num checkout limpo precisa dos destinos presentes, e Claude/Codex os
  leem direto do repositório.

## Estado

Aceita — PR-03 (OndaDev 3.0), 2026-09-05.
