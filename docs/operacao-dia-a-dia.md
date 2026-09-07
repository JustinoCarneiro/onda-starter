# Operação dia a dia — OndaDev 3.0

Guia prático de como trabalhar num projeto OndaDev 3.0. É um resumo operacional;
as fontes canônicas são [`Metodologia_de_Desenvolvimento_-_Onda.md`](Metodologia_de_Desenvolvimento_-_Onda.md),
o [`AGENTS.md`](../AGENTS.md) de cada repo e o [`.ondadev/README.md`](../.ondadev/README.md).

## 1. Ao abrir uma sessão

- Editor canônico: **VS Code**. **Claude Code** no terminal é par de programação
  e revisor crítico; **Codex Desktop** orquestra worktrees e tarefas longas.
- Leia, nesta ordem: `AGENTS.md` (contrato) → `CLAUDE.md` + `docs/product/spec.md`
  (o quê) → [`ROADMAP.md`](../ROADMAP.md) (ordem) → [`memoria-tecnica/`](../memoria-tecnica/)
  (o que já foi resolvido).
- **Uma tarefa por conversa.** `/clear` ao trocar de assunto; `/compact` com foco
  quando o contexto encher; CLI antes de MCP; subagente só para trilha realmente
  independente. (Disciplina de cota — [ADR 0002](architecture/adr/0002-capacidade-sob-orcamento-fixo.md).)

## 2. Escolha a fase e chame a skill

As seis fases não mudam; cada uma tem uma skill em
[`setup/shared/skills/`](../setup/shared/skills/), sincronizada para
`.claude/skills/` (Claude) e `.agents/skills/` (Codex).

| Fase | Skill | Quando |
| --- | --- | --- |
| 0 · Descoberta / Scaffolding | `ondadev-discovery` | projeto novo, novo módulo, perfil de cliente |
| 1 · Spec Viva | `ondadev-spec` | escrever ou ajustar histórias e critérios de aceite |
| 2 · Experiência verificável | `ondadev-experience` | layout e protótipo antes do código |
| 3 · Blueprint executável | `ondadev-blueprint` | decisão técnica durável → ADR |
| 4 · Construção em pequenos lotes | `ondadev-build` | implementar em ciclo TDD |
| 5 · Release e operação | `ondadev-release` | smoke, QA humano, deploy |

Ativação: no Claude, `/ondadev-build`; no Codex, selecione a skill `ondadev-build`.
As duas leem a mesma fonte canônica — nunca edite os destinos `.claude/skills/`
ou `.agents/skills/`.

## 3. Classifique o risco antes de mexer

A matriz canônica está no `AGENTS.md` de cada repo, seção "Segurança e classes
de risco".

| Classe | Exemplos | O que exige |
| --- | --- | --- |
| **R0** | docs, estilo, refac coberta por teste, testes locais | um agente + CI |
| **R1** | regra de negócio, endpoint, schema aditivo, dependência, automação, configuração compartilhada | um autor implementa; **o outro agente revisa o diff** |
| **R2** | auth, pagamento, PII, produção e infra, **migração de schema ou de dados**, credenciais, exclusão, escrita externa | plano + revisão cruzada + **autorização humana explícita** e alvo confirmado |

Na dúvida entre R1 e R2, trate como R2.

## 4. O ciclo de construção (Fase 4)

1. Lote pequeno e revisável. TDD: teste vermelho → verde → refatorar.
2. Não reescreva um arquivo nem descarte trabalho existente sem instrução
   explícita. Prefira mudanças pequenas e verificadas.
3. Antes de investigar um bug não trivial, consulte `memoria-tecnica/bugs/`. Ao
   descobrir uma causa-raiz reutilizável ou tomar uma decisão fora da spec,
   registre uma nota nova (templates em `memoria-tecnica/templates/`), linkando
   com a notação `[[nome-da-nota]]`.
4. **Um autor por PR.** Para R1/R2, entregue ao outro agente a síntese curta e
   peça revisão de **comportamento, segurança e testes** — não de estilo:

   ```text
   Escopo: …
   Mudanças: …
   Validações executadas e resultado: …
   Decisões/ADRs: …
   Riscos, bloqueios e próximos passos: …
   ```
5. **Cartão de próximo passo.** Ao fechar cada módulo/PR, o agente termina com um
   cartão dizendo o risco (R0/R1/R2 + porquê), a ação exata (mergear · abrir o
   outro agente para revisão · revisão cruzada + sua aprovação) e a síntese
   pronta para colar — assim você não precisa lembrar a regra. Contrato:
   `AGENTS.md` › "Revisão e handoff entre agentes" › "Cartão de próximo passo".

## 5. Cota e failover entre agentes

Monitore a janela de uso: Claude `/usage`, Codex `/status`. A unidade é **janela
de uso aceita**, não o preço em dólar.

| Uso da janela | Ação |
| --- | --- |
| **75%** | `bash scripts/ai-checkpoint.sh`. Commit de checkpoint opcional. Segue trabalhando. |
| **90%** | Termina **apenas a unidade atômica** em andamento (teste verde + commit limpo). Não começa módulo novo. |
| **100%** | Handoff completo: `ai-checkpoint.sh`, preenche as seções de raciocínio de `.ondadev/handoff/current.md`, **para**. |

Regras invioláveis:

- **Um agente por checkout por vez.** O primeiro para de escrever antes de o
  segundo começar; a checkbox "o primeiro agente parou?" em `current.md` é
  obrigatória.
- O segundo agente continua **no mesmo checkout**, lê **só** o `current.md` e
  retoma do "próximo passo concreto" — sem reler o repositório.
- **`ANTHROPIC_API_KEY` / `OPENAI_API_KEY` nunca como fallback automático.**
  Autenticação é sempre pela sessão (`claude auth login` / login do Codex).
  `ai-checkpoint.sh` avisa se detectar qualquer uma delas.
- Sem segredo no handoff. `current.md` é ignorado pelo Git; ainda assim não
  escreva segredo, valor de `.env`, diff completo ou conteúdo de arquivo nele.

Detalhes e a simulação de continuidade (Gate G5) estão no
[`.ondadev/README.md`](../.ondadev/README.md).

## 6. Fechar: Definition of Done

Uma entrega só está pronta quando:

1. atende a uma spec ou escopo escrito com critérios de aceite verificáveis;
2. executa os testes e validações que **realmente existem** e reporta o
   resultado (no starter, `bash scripts/ci-report.sh`; num projeto derivado, os
   comandos registrados no `AGENTS.md`);
3. atualiza spec, roadmap, ADR ou segurança quando o contrato mudou;
4. não introduz segredo, credencial ou dado restrito no repositório;
5. passa por revisão proporcional ao risco e deixa um diff compreensível;
6. registra handoff com mudanças, validações, decisões, riscos e pendências.

Nunca afirme que teste, CI, deploy ou sincronização passou sem evidência.

## 7. Jira e board

O quadro (`ondaenterprise.atlassian.net`) é uma **projeção de status**, nunca a
fonte da verdade — essa continua sendo `docs/product/spec.md` (ou
`CLAUDE.md` + `docs/spec.md`) + `ROADMAP.md`.

- A spec muda **primeiro nos arquivos**; o board é acertado depois, à mão na UI
  ou, onde existe, com `scripts/jira_sync.py` para lotes pontuais.
- **Nunca** dispare sincronização automática a partir de edição de doc — isso já
  recriou issues em duplicata.
- A configuração do quadro (colunas, limites de WIP, campos) é feita uma vez por
  projeto com `scripts/jira_browser/`.
- Exclusão de issue exige confirmação explícita.

## 8. Segurança — o que nunca sai do repo local

Siga [`docs/security/data-classification.md`](security/data-classification.md).
Nunca versione, exiba em log ou cole em prompt: tokens, chaves de API, senhas,
cookies, dados pessoais reais, exports de clientes. Use `.env` local e
`.env.example` só com placeholders. Rotas temporárias de fix nunca com segredo
hardcoded — use variável de ambiente e remova a rota no mesmo PR.

## 9. Quando um repo ainda não tem tudo

Um projeto derivado deve ter: `AGENTS.md` canônico, `CLAUDE.md` importando
`@AGENTS.md` na primeira linha, `ONDA_VERSION`, as seis skills nos dois
destinos, `.ondadev/` + `scripts/ai-checkpoint.sh`, `.gitleaks.toml` e o
workflow de secret scanning. O guia de adoção está em
[`migracao-2.0-para-3.0.md`](migracao-2.0-para-3.0.md).
