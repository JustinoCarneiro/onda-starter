# Prompt para o Codex — revisão independente do ambiente OndaDev 3.0 (PR-03 a PR-07)

O Claude implementou os PRs **PR-03 a PR-07** do roadmap OndaDev 3.0 no
`onda-starter` (contrato de agentes, seis skills compartilhadas, ambiente
VS Code/worktree, protocolo de failover de cota, CI de validações + secret
scanning, metodologia atualizada para a versão 3.0). Tudo já está em `master`.

Esta é uma **revisão pós-merge** — pendência registrada pelo usuário: o autor
foi o Claude; o revisor independente é o Codex. O objetivo é revisão de
**comportamento, segurança e testes**, não estilo.

Cole o bloco abaixo no Codex, com o repositório `onda-starter` aberto em
`master` (sem abrir worktree).

---

```text
Tarefa: OndaDev — revisão independente do ambiente 3.0 (PR-03 a PR-07)
Autor: Claude
Revisor: Codex
Risco: R1 (automação e configuração compartilhada; sem código de produto)

Escopo da revisão
  Diff completo: `git diff e2d4c90..HEAD` (base e2d4c90 = "backup do working
  tree", último commit antes do trabalho 3.0). São 102 arquivos, ~5,5k linhas
  adicionadas. Commits relevantes, em ordem:
    30388aa chore(ondadev): establish secure environment baseline
    5be485a docs(ondadev): establish shared agent contract        (PR-03)
    ba1f145 feat(ondadev): consolidate legacy commands into six shared skills (PR-03)
    226972c chore(ondadev): VS Code tasks, extensions, worktree setup (PR-04)
    2610db6 chore(ondadev): configure local Codex environment       (PR-04)
    0ed28b8 feat(ondadev): quota failover protocol and handoff checkpoint (PR-05)
    6957c90 fix(ondadev): failover handoff happens in-place, not a worktree (PR-05)
    c388b9c docs(ondadev): prompt for Codex to close Gate G5        (PR-05)
    f6c75a9 fix(ondadev): ai-checkpoint refreshes only section 0    (PR-05)
    e0cd396 ci(ondadev): enforce validations, installer smoke, secret scanning (PR-06)
    8c338c5 / a52a1e7  ci(ondadev): correções do CI do PR-06
    b7cb9f7 docs(ondadev): update methodology to OndaDev 3.0        (PR-07)
    11bbb1d / 41e607e / ef91447  ADR 0002 + Trello→Jira + §13 (follow-ups)

O que verificar (por área)
  1. Contrato de agentes (AGENTS.md, CLAUDE.md importando @AGENTS.md):
     - o contrato é interno-consistente? algum comando "verificado" que não
       existe ou não roda? (rode `bash scripts/ci-report.sh` e confira)
     - a tabela de risco R0/R1/R2 e a Definition of Done batem com o resto do
       repo (docs/security/, ROADMAP.md)?
  2. Seis skills compartilhadas (setup/shared/skills/ondadev-*):
     - `bash setup/shared/sync-skills.sh --check` passa? drift entre a fonte
       canônica e os destinos .claude/ e .agents/?
     - `bash setup/tests/skills-frontmatter.sh` e `skills-drift.sh` passam?
     - o frontmatter (name/description) e o corpo de cada SKILL.md descrevem
       a mesma fase da metodologia sem contradição?
     - `setup/shared/skills-manifest.sha256` está coerente com o conteúdo atual?
  3. Failover de cota (.ondadev/, scripts/ai-checkpoint.sh):
     - `bash scripts/ai-checkpoint.sh --stdout` roda sem erro e NÃO vaza
       segredo, valor de variável, diff ou conteúdo de arquivo?
     - o script regenera SÓ a seção 0 (entre os marcadores
       `ai-checkpoint:auto`) e preserva a prosa das seções 1–9? teste editando
       um current.md fake e rodando de novo.
     - o protocolo do README avisa sobre ANTHROPIC_API_KEY/OPENAI_API_KEY não
       serem usadas como fallback automático?
  4. CI (.github/workflows/*.yml, scripts/ci-*.sh):
     - o secret-scan varre o range certo (commits do PR, não só staged)?
       gitleaks fixado por versão? actions fixadas por SHA?
     - `permissions:` minimamente escopado em cada workflow?
     - o smoke do instalador (setup/tests/install-smoke.sh) cobre o caminho
       real de `setup/install.sh`?
     - algum passo do CI depende de segredo de repo que não está documentado?
  5. setup/install.sh (+673/-~460 — a maior mudança):
     - idempotência: rodar duas vezes seguidas deixa o mesmo estado?
     - `--dry-run` realmente não escreve nada fora do repo?
     - trata caminho com espaço, ausência de dependência, e falha no meio
       sem deixar o repo num estado quebrado?
  6. Metodologia (docs/Metodologia_de_Desenvolvimento_-_Onda.md, ADRs,
     docs/migracao-2.0-para-3.0.md):
     - a v3.0 do doc está coerente com o que o código realmente faz?
     - ADR 0001 (skills) e ADR 0002 (capacidade sob orçamento fixo) não
       contradizem a spec nem um ao outro?
     - a troca Trello→Jira foi aplicada em TODAS as fontes (AGENTS.md,
       metodologia, §13, scripts) ou sobrou referência órfã a Trello?

Como rodar as validações
  bash scripts/ci-report.sh              # roda tudo: shellcheck, links, metodologia, skills
  bash setup/shared/sync-skills.sh --check
  bash setup/tests/skills-drift.sh
  bash setup/tests/skills-frontmatter.sh
  bash setup/tests/install-smoke.sh
  bash setup/install.sh --dry-run
  bash scripts/ai-checkpoint.sh --stdout

Restrições (invioláveis)
  - Isto é REVISÃO. Não corrija nada, não faça commit, não abra PR.
  - Sem push, merge, deploy, login, autorização externa, instalação de plugin.
  - Não habilitar OPENAI_API_KEY / ANTHROPIC_API_KEY.
  - Não colar no relatório segredo, token, valor de variável, diff completo
    nem conteúdo integral de arquivo — cite por caminho e número de linha.
  - Se algo exigir decisão de produto ou credencial, registre como pendência
    e pare.

Entregável (cole de volta para o Claude)
  Um relatório com:
    A. Veredito por área (1–6 acima): OK | ressalvas | bloqueio.
    B. Achados, cada um com: caminho:linha, severidade (alta/média/baixa),
       o que está errado, e o cenário concreto de falha.
    C. Validações que você rodou e o resultado real (cole a última linha de
       cada, não o log inteiro).
    D. Síntese de handoff:
         Escopo: …
         Mudanças: (nenhuma — revisão)
         Validações executadas e resultado: …
         Decisões/ADRs: …
         Riscos, bloqueios e próximos passos: …
```

---

## Depois que o Codex devolver

O Claude tria os achados: cada um de severidade alta/média vira um PR de
correção com teste; os de severidade baixa entram como pendência priorizada.
Nenhuma correção é aplicada dentro desta revisão.
