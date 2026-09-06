# Prompt para o Codex — gerar o ambiente local `.codex/` (PR-04)

Este passo do PR-04 só pode ser feito pelo Codex, porque envolve o **painel do
Codex Desktop**. Cole o bloco abaixo no Codex (app desktop) com o repositório
`onda-starter` aberto na branch `feat/ondadev-3-environment`.

O restante do PR-04 (extensão do VS Code confirmada, `.vscode/extensions.json`,
`.vscode/tasks.json`, `.env.example`, `setup/worktree-setup.sh`,
`setup/WORKTREE.md`) já foi entregue pelo Claude. Falta só a `.codex/` e as
ações do Codex.

---

```text
Tarefa: OndaDev PR-04 — ambiente local do Codex
Autor: Codex
Revisor: Claude (revisa o diff)
Risco: R1

Objetivo
  Configurar o ambiente local pelo painel do Codex Desktop e versionar a
  pasta .codex/ gerada, com as cinco ações padrão apontando para os comandos
  que já existem neste repositório.

Contexto
  - Repositório: onda-starter, branch feat/ondadev-3-environment.
  - Este é o starter da metodologia OndaDev: NÃO tem build, lint nem suíte de
    testes de aplicação. As ações devem rodar só validações reais.
  - Contrato local: AGENTS.md (seção "Comandos verificados"), regras R0/R1/R2
    e Definition of Done.
  - VS Code é o editor canônico; as tarefas equivalentes estão em
    .vscode/tasks.json — mantenha as ações do Codex alinhadas a elas.
  - .gitignore já ignora .codex/auth.json, .codex/*.log, .codex/sessions/ e
    .codex/cache/. Confirme que nada de credencial ou estado de sessão entra
    no commit.

Ações a definir (mesmos comandos das tarefas do VS Code)
  Setup : bash setup/check-environment.sh
  Lint  : bash scripts/validate-agent-context.sh && git ls-files '*.sh' | xargs -r -n1 bash -n && bash setup/shared/sync-skills.sh --check && echo '[OK] lint'
  Test  : bash setup/tests/skills-drift.sh && bash setup/tests/skills-frontmatter.sh && bash scripts/validate-agent-context.sh
  Build : docker compose config -q && echo '[OK] docker-compose válido — starter sem build de aplicação'
  Run   : docker compose up -d

Setup de worktree
  Use setup/worktree-setup.sh como script de preparação de novas árvores de
  trabalho. Ele já é não interativo e idempotente. Se o painel do Codex pedir
  um comando de setup de ambiente, use exatamente:
    bash setup/worktree-setup.sh

Restrições
  - Não fazer push, merge, deploy, login, autorização externa nem instalar
    plugin. Não habilitar OPENAI_API_KEY nem ANTHROPIC_API_KEY como fallback.
  - Não copiar segredo para worktrees. Não alterar arquivos fora de .codex/ e
    da documentação estritamente necessária (um parágrafo em setup/CHECKLIST.md
    confirmando o ID da extensão e a existência de .codex/, se ainda faltar).
  - Não ampliar o escopo além do ambiente local do Codex e das cinco ações.
  - Mudanças pequenas e revisáveis; um único diff.

Pronto (Definition of Done + Gate G4)
  1. .codex/ versionada, sem credencial nem estado de sessão no diff.
  2. As cinco ações rodam do painel do Codex Desktop e reproduzem o resultado
     das tarefas de .vscode/tasks.json (mesmos comandos, mesma saída).
  3. bash setup/worktree-setup.sh prepara um worktree novo sem passo oculto e
     sem copiar segredo; roda a verificação básica verde.
  4. Entregar a síntese de handoff (Escopo / Mudanças / Validações e resultado /
     Decisões / Riscos e próximos passos) para o Claude revisar o diff.
  5. Parar no Gate G4: "uma tarefa pode começar em worktree limpo e ser
     transferida com segurança para Local". Sem push.
```

---

## Depois que o Codex entregar

1. Claude revisa o diff da `.codex/` focado em: nenhum segredo, ações batendo
   com `.vscode/tasks.json`, worktree setup idempotente.
2. Rodar `bash setup/worktree-setup.sh --check` para confirmar o Gate G4.
3. Seguir para o PR-05 (failover de cota).
