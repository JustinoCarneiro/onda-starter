# Onda · Metodologia de Desenvolvimento

### Playbook de Engenharia — Onda-Dev

> **Belo no design. Fluido no uso. Sólido na segurança.**
> **v3.0 · Setembro/2026** — versão declarada em `ONDA_VERSION`.
> Migração desde a 2.0: `docs/migracao-2.0-para-3.0.md`.

---

> **Propósito.** Formalizar o ciclo de vida de desenvolvimento da Onda como um processo
> padronizado, repetível e previsível. Entra um pedido de cliente — que pode ser uma única
> frase; sai software em produção, com **prazo calculado** (não estimado no chute) e
> **qualidade verificada** em cada etapa (não apenas prometida), independentemente do tipo de
> projeto: e-commerce, app, landing page, sistema interno ou automação.

Este playbook foi desenhado para o cenário de um **desenvolvedor solo operando com dois
agentes de IA** — **VS Code** como editor canônico, **Codex Desktop** como mesa de
orquestração (worktrees, tarefas longas) e **Claude Code** como par de programação no terminal
e revisor crítico. Um autor por PR; o outro agente revisa o diff. Antigravity fica só como
laboratório visual opcional, fora do fluxo padrão. Ele se apoia nos princípios do *Agile Vibe
Code* e do *Extreme Programming (XP)* com IA: no lugar da burocracia voltada à gestão de
pessoas, uma **iteratividade de engenharia** que garante adaptação a mudanças, entregas
contínuas e altíssima qualidade técnica.

> **Governança de risco (2.0 → 3.0).** Toda tarefa declara uma classe de risco — **R0** (um
> agente + CI), **R1** (um autor + revisão de diff pelo outro), **R2** (plano, revisão cruzada e
> **aprovação humana**). Os exemplos e a fronteira exata de cada classe — inclusive que
> **migração de schema/dados e mudança de auth são R2**, não R1 — vivem em `AGENTS.md` ›
> "Segurança e classes de risco", fonte canônica desta matriz. O ambiente 3.0 (contrato
> `AGENTS.md`, skills, toolchain, CI) é montado pelos PRs de ambiente com seus próprios gates
> G0–G6; ver `AGENTS.md` e o roadmap de implementação.

---

## 1. A caixa-preta (visão executiva)

O cliente não precisa entender o interior do processo; precisa confiar que, dada qualquer
entrada válida, a saída é consistente. A promessa é simples:

| Entrada | Processo | Saída |
|---|---|---|
| Pedido do cliente (pode ser uma única frase) | 6 fases sequenciais com fluxo Kanban e TDD | Software rodando em produção |

---

## 2. Atores (as raias do processo)

Três papéis percorrem todas as fases. A IA sempre opera sob supervisão humana — ela gera, o
humano valida.

| Ator | Papel no processo |
|---|---|
| **Cliente** | Origem do pedido. Fornece requisitos, aprova o visual e valida a entrega. Participante externo. |
| **Dev / Humano (Onda)** | Conduz o processo, faz as perguntas certas, decide arquitetura, valida as saídas da IA, aprova R2 e fala com o cliente. |
| **IA — Claude Code** | Par de programação no terminal/VS Code. Contexto quente em projeto legado, direção visual, TDD e revisão crítica de mudanças do Codex. |
| **IA — Codex** | Mesa de orquestração (Codex Desktop). Descoberta e pesquisa, produção diária em projeto novo, worktrees, release e documentação estruturada. |

Regra de autoria: **um agente é o autor do diff**; o outro revisa apenas quando o risco exige
(R1/R2) e recebe o mínimo suficiente — contrato, diff, logs de teste — sem reanálise completa
do repositório. Nunca dois agentes escrevendo no mesmo checkout. Quando a cota de um acaba, o
outro assume por `handoff` (`.ondadev/README.md`).

---

## 3. Artefatos (os entregáveis palpáveis)

A previsibilidade nasce de entregáveis concretos a cada etapa, que comprovam o avanço para o
cliente e para o negócio.

| Artefato | Nasce na | Função |
|---|---|---|
| `CLAUDE.md` + `spec.md` | Fase 1 | Fonte única da verdade: épicos, histórias de usuário, stack e arquitetura. |
| `tokens.css` + `DESIGN.md` | Fase 2 | Identidade visual **do projeto** — do cliente, nunca a da Onda. |
| Protótipo estático | Fase 2 | Interface aprovável, com dados fictícios. |
| `ROADMAP.md` + contratos | Fase 3 | Planta técnica: módulos, pesos e contratos Request/Response. Também é o quadro Kanban do projeto — ver seção 12. |
| Commits / Small Releases | Fase 4 | Código testado e pronto para produção. |
| `memoria-tecnica/` | Fase 4 (nasce vazia na Fase 0) | Memória técnica viva: bugs cabeludos e decisões tomadas fora da spec — ver seção 11. |
| Deploy | Fase 5 | Software em produção. |
| `docs/METRICAS-PROJETO.md` | Fase 0 | Registro de coleta: kickoff (datas, valor, canal), timesheet por sessão, log de espera/impedimento — ver seção 14. |
| `docs/ANALISE-PROJETO-<nome>.md` | Fase 5 | Análise de fechamento pelos KPIs (prazo, DORA, fluxo, valor agregado, financeiro). Alimenta o histórico da empresa e calibra o prazo/preço do próximo — ver seção 14. |

---

## 4. O macrofluxo — as 6 fases

A execução obedece a uma linha de montagem. Cada fase tem entrada, atividades, um ponto de
decisão e uma saída clara.

```
Fase 0 → Fase 1 → Fase 2 → Fase 3 → Fase 4 → Fase 5
Scaffolding · Spec Viva · Layout & Congelamento · Blueprint · Esteira XP · Homologação
```

### Fase 0 — Scaffolding
*Prepara o terreno antes de qualquer conversa de escopo.*

- **Entrada:** pedido aceito, projeto iniciado.
- **Atividades:** clonar o template `onda-starter`; ativar a skill de perfil conforme o tipo (e-commerce, app, LP, sistema, automação); criar o **registro de métricas** `docs/METRICAS-PROJETO.md` (template vem no `onda-starter`) e preencher o bloco de kickoff — as 4 datas, o valor do contrato + moeda, o canal (Workana/direto) com comissão/saque/tributo, o valor/hora alvo. O custo/hora interno da empresa fica no sibling privado do projeto, nunca no repo (ver seção 14).
- **Saída:** repositório preparado, contexto enxuto.
- **Skill:** `ondadev-discovery` (perfis viram referência sob demanda).
- **Responsável:** Codex (descoberta) · Humano aprova.
- **Evidência:** repo clonado com `ONDA_VERSION`, perfil carregado, `docs/METRICAS-PROJETO.md` iniciado.

### Fase 1 — Spec Viva (gera o `CLAUDE.md`)
*Transforma o pedido (muitas vezes vago) na especificação viva do projeto.*

- **Entrada:** pedido do cliente.
- **Atividades:**
  1. Briefing que destrava o escopo (público, dores, regras, volume).
  2. Mapeamento de épicos.
  3. Quebra em histórias de usuário (“Como [X], quero [Y] para [Z]”).
  4. Critérios de aceite no formato dado-quando-então.
  5. Geração do `CLAUDE.md` + `spec.md`.
- **Decisão — G1:** *Requisitos claros o suficiente?* Não → volta ao briefing. Sim → avança.
- **Saída:** `CLAUDE.md` (fonte única da verdade) + `spec.md`.
- **Skill:** `ondadev-spec`.
- **Responsável:** Humano conduz · Cliente fornece · IA redige.
- **Evidência:** épicos e histórias com critérios Dado/Quando/Então; módulos de risco com 2+ critérios; dados classificados por `docs/security/data-classification.md`.

### Fase 2 — Layout & Congelamento Visual
*Mitiga o risco de o cliente mudar o fluxo depois e destruir o banco. É condicional.*

- **Entrada:** `CLAUDE.md`.
- **Decisão — G2:** *O cliente tem identidade visual?*
  - **Não → Fase 2a (Direção Visual):** briefing de marca curto → 2–3 direções divergentes em *style tiles* → cliente escolhe → refino → `tokens.css` + `DESIGN.md`. Parte-se de um starter neutro e acessível, **nunca da marca da Onda**.
  - **Sim → vai direto para a Fase 2b.**
- **Fase 2b (Layout):** a IA lê o `CLAUDE.md` + a identidade do projeto e gera o front 100% estático com dados fictícios (hierarquia, responsividade, acessibilidade AA, estados de erro/carregamento).
- **Decisão — G3:** *Layout aprovado?* Não → revisa. Sim → **Congelamento Visual**: a partir daqui, mudar o visual é mudança de escopo.
- **Saída:** protótipo aprovado e congelado; `tokens.css` definido.
- **Skill:** `ondadev-experience` (cobre 2a Direção Visual e 2b Layout).
- **Responsável:** Claude (direção visual e layout) · Cliente aprova · Humano media.
- **Evidência:** protótipo navegável com acessibilidade AA (contraste ≥ 4.5:1, alvo ≥ 44px), estados loading/erro/vazio/sucesso, e `design/tokens.css` + `design/DESIGN.md`.

> **Nota de prazo.** Se houve criação de identidade (Fase 2a), o termo da Fase 2 cresce de ~2 para ~4 dias — e isso é precificado como item próprio.

### Fase 3 — Blueprint (gera o `ROADMAP.md`)
*A planta técnica, desenhada antes de codificar.*

- **Entrada:** visual congelado.
- **Atividades:**
  1. Modelagem do banco (tabelas e relacionamentos exatos).
  2. Divisão do sistema em **módulos independentes**.
  3. Pesagem de cada módulo (Complexidade + Risco).
  4. Definição dos **contratos de API** (Request/Response) — antes de qualquer código.
  5. Rastreabilidade história ↔ módulo (relação N:1).
  6. Cada módulo nasce com `**Status:** ⬜ Pendente` — é o quadro Kanban do projeto (ver seção 12).
- **Saída:** `ROADMAP.md` + contratos + **prazo técnico calculado**.
- **Skill:** `ondadev-blueprint`.
- **Responsável:** Humano decide arquitetura · Codex gera o roteiro. ADR para decisão durável; threat model se houver módulo R2.
- **Evidência:** ERD, módulos independentes com peso, contratos Request/Response, rastreabilidade história ↔ módulo, tabela de parcelas do prazo.

### Fase 4 — Esteira XP (codificação por módulo)
*Fluxo contínuo (Kanban), consumindo o `ROADMAP.md`. Pesado no terminal (Claude Code).*

- **Skill:** `ondadev-build`. **Responsável:** Claude (legado com contexto quente) ou Codex (projeto novo, em worktree); o outro revisa R1/R2.
- **Abertura — Diretiva Primária:** “Leia o `CLAUDE.md` e o `ROADMAP.md`; a partir de agora, não altere a sintaxe do código existente sem um teste que justifique a quebra.”
- **Ciclo TDD:**
  - **Red:** IA escreve testes com mocks; eles falham.
  - **Green:** só o código necessário para passar.
  - **Refactor:** aplica DRY e otimiza sem quebrar os testes.
  - **Segurança:** agente `revisor-seguranca` nos módulos de risco.
  - **Commit limpo** (Small Release).
  - **Atualiza o status do módulo no `ROADMAP.md`** de `⬜ Pendente` para `✅ Concluído (data)` assim que os testes fecham verdes e o commit é feito — é isso que faz do `ROADMAP.md` o quadro Kanban vivo do projeto (seção 12), não um board externo.
- **Memória técnica:** antes de investigar um bug ou decidir algo fora da spec, consultar `memoria-tecnica/`; ao resolver algo não-trivial, registrar lá (ver seção 11 — critério de quando vale a pena).
- **Coleta de métricas (leve):** ao fim de cada sessão, uma linha de timesheet em `docs/METRICAS-PROJETO.md`; ao parar por causa externa (cliente, terceiro, infra), abrir e fechar um episódio no log de espera/impedimento do mesmo arquivo. É o que torna a análise de fechamento da Fase 5 possível — ver seção 14.
- **Decisões:**
  - **G4 — Testes verdes?** Não → volta ao TDD.
  - **G5 — Pedido de mudança?** Sim → **retorno à Fase 1**.
  - **G6 — Mais módulos na fila?** Sim → puxa o próximo · Não → avança.
- **Saída:** todos os módulos testados e commitados.
- **Responsável:** IA codifica · Humano supervisiona e valida.
- **Evidência por tipo:** negócio → testes de contrato/integração verdes; UI → testes de componente + acessibilidade + revisão visual; API → contrato Request/Response validado; banco → migração para a frente e rollback ensaiado; infraestrutura → policy/plan revisado; documentação → lint e links.
- **Continuidade:** se a cota acabar no meio de um módulo, `handoff` pelo `.ondadev/` (checkpoint a 75%, só unidade atômica a 90%, handoff a 100%).

> **O coração entra cedo.** O módulo de maior risco (gateway de pagamento, máquina de estados,
> motor de permissões) é puxado no **início** da Fase 4 — nunca no fim. Falhar cedo é barato;
> falhar tarde compromete a entrega.

### Fase 5 — Homologação, Deploy e Encerramento
*A entrega oficial.*

- **Entrada:** módulos completos.
- **Atividades:**
  1. Smoke test local: subir o ambiente via Docker e rodar toda a esteira de testes.
  2. Validação humana de ponta a ponta.
  3. Revisão final de segurança.
  4. Revisão manual da `memoria-tecnica/`: checar se ficou desatualizada e podar notas triviais (a IA popula por conta própria em melhor esforço, não é garantido — não assumir que está completa sem olhar).
  5. **Análise de KPIs de fechamento:** rodar a análise pelo padrão da empresa (`docs/METRICAS-KPI.md`), gerando `docs/ANALISE-PROJETO-<nome>.md` — prazo, DORA, fluxo, valor agregado, financeiro de serviços, SPACE, cliente. Feita **perto do fim**, assim que o escopo está estável; não precisa esperar o deploy. Prompt operacional: `docs/PROMPT-ANALISE-KPI.md`. Ver seção 14.
- **Decisão — G7:** *Smoke test + validação OK?* Não → **retorno à Fase 4**. Sim → avança.
- **Saída:** **Deploy via CI/CD** → software em produção; `docs/ANALISE-PROJETO-<nome>.md` no histórico da empresa.
- **Skill:** `ondadev-release`.
- **Responsável:** Codex executa · Humano valida e autoriza o deploy · Cliente recebe. (Deploy, push e merge sempre com autorização humana explícita.)
- **Evidência:** smoke test verde, validação humana ponta a ponta, revisão de segurança, `memoria-tecnica/` revisada, `docs/ANALISE-PROJETO-<nome>.md` gerado.

---

## 5. Gateways e retornos (o mapa de decisões)

Os sete gateways exclusivos (XOR) e os loops que o processo precisa representar — o núcleo da
governança do fluxo.

| # | Onde | Pergunta | Sim | Não |
|---|---|---|---|---|
| G1 | Fim da Fase 1 | Requisitos claros? | Vai para Fase 2 | Volta ao briefing |
| G2 | Início da Fase 2 | Cliente tem identidade? | Vai para Fase 2b | Entra na Fase 2a |
| G3 | Fim da Fase 2 | Layout aprovado? | Congelamento → Fase 3 | Revisa o layout |
| G4 | Dentro da Fase 4 | Testes verdes? | Commit | Volta ao ciclo TDD |
| G5 | Dentro da Fase 4 | Pedido de mudança? | Retorna à Fase 1 | Continua |
| G6 | Dentro da Fase 4 | Mais módulos na fila? | Puxa o próximo | Vai para Fase 5 |
| G7 | Dentro da Fase 5 | Smoke test + validação OK? | Deploy | Retorna à Fase 4 |

> A **análise de KPIs de fechamento** (seção 14) é atividade obrigatória da Fase 5, não um gateway —
> não bloqueia o deploy, mas a Fase 5 não se encerra sem ela.

> **Não confundir com os gates de ambiente.** G1–G7 acima são pontos de decisão **do fluxo de um
> projeto**. Os gates **G0–G6** citados no roadmap de implementação são outra coisa: marcos de
> PR para montar o ambiente OndaDev 3.0 (baseline, toolchain, contrato, skills, worktrees,
> failover, CI). Mesma letra, escopos diferentes.

---

## 6. Gestão de mudanças no fluxo

Mudança não é exceção — é parte do processo, com pontos de retorno bem definidos para que nada
destrua trabalho já feito.

**Retorno à Fase 1 — funcionalidade nova.** Se o cliente pede uma feature nova no meio da Fase 4
(ex.: “adicionar PIX”), **não se codifica na hora**. O fluxo volta à Fase 1: atualiza-se o
`CLAUDE.md` com a nova história, a IA lê a regra, atualiza os testes e **só então** codifica.

**Retorno à Fase 2 — mudança no visual congelado.** Alterar o visual já aprovado enquanto o
backend está em andamento impacta as tabelas do sistema. Caracteriza **mudança de escopo** e
exige aditivo de prazo, medido com o mesmo peso de módulo.

---

## 7. Previsibilidade — o prazo calculado

Para um desenvolvedor solo com IA, estimar por “horas” é ineficaz. A métrica é o **peso dos
módulos** do `ROADMAP.md` (Complexidade + Risco), não horas.

| Peso | Dias | Características |
|---|---|---|
| Pequeno | 1–2d | Código mecânico, baixo risco. CRUDs simples, telas estáticas, perfis. |
| Médio | 3–4d | Lógica intermediária, mais atenção no TDD. Relatórios, APIs externas. |
| Grande | 5–7d | Coração do sistema, alto risco. Gateway de pagamento, máquina de estados, segurança e permissões. |

```
Prazo = Fase 2 (≈2d com identidade / ≈4d sem) + Σ(dias dos módulos das Fases 3 e 4) + 2d (Fase 5)
```

O mesmo método precifica **aditivos**: uma funcionalidade nova pedida no meio é medida com o
mesmo peso e soma ao prazo de forma consistente.

O histórico de `docs/ANALISE-PROJETO-*.md` (seção 14) recalibra esta tabela projeto a projeto: se
o `effective hourly rate` real vem sistematicamente abaixo do alvo, ou o `lead time` real diverge
do peso estimado, os pesos e o preço-base sobem na próxima proposta — a previsibilidade deixa de
ser só teórica e passa a se corrigir com dado.

### Exemplo prático

Cliente traz a própria identidade (Fase 2 = 2d). O `ROADMAP.md` tem 2 módulos pequenos (≈4d) e
1 módulo grande (≈7d) — 11 dias de engenharia. Somando a homologação:

| Parcela | Dias |
|---|---|
| Fase 2 — identidade já trazida pelo cliente | 2 |
| 2 módulos pequenos | 4 |
| 1 módulo grande | 7 |
| Fase 5 — homologação e deploy | 2 |
| **Prazo técnico blindado** | **15 dias úteis** |

---

## 8. Definição de pronto — o filtro de qualidade

Nenhuma entrega fecha sem responder “sim” às três camadas da marca. Faltou uma, não está pronto.

- **Belo — no design.** Bate com a identidade do projeto aprovada na Fase 2: hierarquia clara, estética cuidada.
- **Fluido — nas funcionalidades.** Funciona sem atrito; estados de erro e carregamento tratados. Se trava ou falha, não é fluido.
- **Sólido — na segurança.** TDD verde, dados protegidos, revisão de segurança aprovada. Qualidade verificada, não prometida.

---

## 9. Divisão de ferramentas por fase

**VS Code é o editor canônico** de todo o ciclo — Claude Code e Codex são suportados nele.
**Codex Desktop** entra como mesa de orquestração (worktrees, tarefas longas, pesquisa).
**Claude Code** é o par no terminal/VS Code, forte em contexto quente e revisão crítica. A Fase
2b usa o Claude Design para geração de interface. Antigravity só como laboratório visual
opcional, nunca como orquestrador padrão.

| Fase | Agente principal | Segundo agente | Por quê |
|---|---|---|---|
| 0 · Descoberta | Codex | Claude só se for decisão crítica | Pesquisa e artefatos sem gastar a cota do Claude. |
| 1 · Spec Viva | Humano + IA que redige | — | Destravar ambiguidade antes de arquitetura. |
| 2 · Experiência | Claude (Design) | Codex revisa responsivo/acessível | Separa intenção visual de engenharia. |
| 3 · Blueprint | Codex | Claude critica uma ADR curta | Duas perspectivas, uma implementação. |
| 4 · Esteira XP | Claude (legado) ou Codex (novo, worktree) | o outro revisa R1/R2 | Preserva contexto quente; isola o trabalho novo. |
| 5 · Release | Codex | Claude só se houver risco técnico | Trabalho estruturado e automatizável. |

### Ponto de entrada por fase

| Fase | Onde | Ação | Skill |
|---|---|---|---|
| 0 · Descoberta | Terminal / VS Code | `git clone onda-starter nome && code .` | `ondadev-discovery` |
| 1 · Spec Viva | VS Code (Claude/Codex) | ativar a skill | `ondadev-spec` |
| 2 · Experiência | VS Code + Claude Design | ativar a skill | `ondadev-experience` |
| 3 · Blueprint | VS Code (Claude/Codex) | ativar a skill | `ondadev-blueprint` |
| 4 · Esteira XP | VS Code (Claude/Codex) | Diretiva Primária + ciclo TDD por módulo | `ondadev-build` |
| 5 · Release | VS Code (Claude/Codex) | smoke test + validação + deploy + KPIs | `ondadev-release` |

> As skills `ondadev-*` valem para os dois agentes. Os comandos legados `onda-*` (`/onda-novo`,
> `/onda-spec-viva`, `/onda-layout`, `/onda-blueprint`, perfis…) continuam funcionando com aviso
> de depreciação até o fim do piloto e depois são removidos.

---

## 10. Configuração e migração de ambiente

O ecossistema de desenvolvimento da Onda — skills, agentes e ferramentas — está versionado no próprio `onda-starter`, dentro da pasta `setup/`. Isso garante que qualquer máquina nova seja configurada de forma idêntica em minutos, sem dependência de memória ou configuração manual.

### Estrutura de setup (3.0)

```
onda-starter/
├── AGENTS.md                  ← contrato canônico (Claude e Codex); CLAUDE.md importa @AGENTS.md
├── ONDA_VERSION               ← versão da metodologia que o projeto segue
├── setup/
│   ├── install.sh             ← instalador idempotente (--check / --dry-run / --component)
│   ├── CHECKLIST.md           ← autenticação e ajustes manuais
│   ├── worktree-setup.sh      ← preparo não interativo de um git worktree
│   ├── shared/skills/         ← FONTE CANÔNICA das 6 skills ondadev-*
│   ├── shared/sync-skills.sh  ← sincroniza para .claude/skills e .agents/skills
│   └── claude/                ← comandos/agents legados (compat até o piloto)
├── .claude/skills/  .agents/skills/   ← destinos gerados (não editar)
├── .ondadev/                  ← protocolo de failover + template de handoff
└── .github/workflows/ci.yml   ← validações, smoke do instalador, secret scanning
```

### Troca ou formatação de máquina

```bash
git clone https://github.com/JustinoCarneiro/onda-starter.git && cd onda-starter
bash setup/install.sh --dry-run          # revisar
bash setup/install.sh                     # instalar (Node 22+, Docker, gh, Claude Code, skills)
cat setup/CHECKLIST.md                    # auth, VS Code, extensão Codex, CI
```

O `install.sh` cuida de Git, Node.js 22+ (nvm), Docker, GitHub CLI, Claude Code e do espelho
das skills canônicas em `~/.claude/skills/` e `~/.agents/skills/`. Não autentica contas nem
instala extensão de IDE.

### Evoluir uma skill

Edite **só** `setup/shared/skills/` e rode:

```bash
bash setup/shared/sync-skills.sh          # atualiza os dois destinos + o manifesto de hashes
```

Os diretórios `ondadev-*` em `.claude/skills/` e `.agents/skills/` são cópias geradas; editá-los
direto é sobrescrito pelo sync e acusado por `bash setup/tests/skills-drift.sh`.

> **Regra:** `setup/shared/skills/` é a fonte única da verdade das skills; `AGENTS.md` é a do
> contrato de trabalho. Um projeto derivado declara sua versão em `ONDA_VERSION` e não copia o
> texto integral desta metodologia — só referencia a versão e mantém adaptações locais. Guia de
> migração 2.0 → 3.0: `docs/migracao-2.0-para-3.0.md`.

---

## 11. Memória Técnica Viva — padrão Obsidian

*Piloto validado no projeto Sistema Melvin (jul/2026) antes de virar padrão.*

### O que é e por quê

`CLAUDE.md` e `ROADMAP.md` cobrem o que foi planejado. Mas todo projeto acumula, ao vivo, conhecimento
que não estava na spec: um bug que exigiu investigação de causa raiz, uma decisão técnica tomada no
meio da Fase 4 por um motivo que não é óbvio olhando só o código. Hoje esse conhecimento cai na memória
do próprio agente — que é isolada por projeto, não versionada, e não sobrevive a uma troca de máquina
ou ferramenta.

`memoria-tecnica/` resolve isso como uma pasta comum dentro do repositório (não uma ferramenta externa):
markdown puro, sem lock-in, que o Obsidian sabe abrir como *vault* pra navegação em grafo — mas que o
Claude Code lê e escreve normalmente com ou sem o Obsidian aberto.

### Estrutura

```
memoria-tecnica/
├── _index.md         ← painel de entrada, lista bugs e decisões
├── bugs/              ← causa raiz de bugs não-triviais já resolvidos
├── decisoes/          ← decisões técnicas tomadas fora da spec original
└── templates/         ← modelo de nota (bug.md, decisao.md)
```

Nasce vazia na Fase 0 (scaffolding) — não é um problema ela não ter nada útil ainda nos primeiros
módulos; o valor se acumula com o tempo de vida do projeto, igual acontece com o Changelog de Escopo
do `CLAUDE.md`.

### Critério de quando criar uma nota

Documentar só quando pelo menos um destes for verdade — evitar isso vira ruído e destrói o valor do
padrão:
- Exigiu investigação real (a causa não era óbvia a partir do stack trace ou do código).
- A causa está fora do código-fonte visível (config de infra, comportamento de dependência externa, nginx, etc.).
- É uma decisão que contradiz ou refina algo que já foi decidido antes — e alguém (humano ou IA) vai
  precisar saber disso antes de mexer ali de novo.

Não criar nota se o fato já tem um lar melhor e visível (ex.: já é critério de aceite no `CLAUDE.md`,
ou já tem um aviso dedicado num checklist) — isso duplicaria a fonte de verdade em vez de complementá-la.

### Ressalvas

- **Não é automático.** A IA populando a `memoria-tecnica/` sozinha é melhor esforço, seguindo a
  instrução do `CLAUDE.md` — não uma garantia de sistema. Por isso a Fase 5 tem um passo de revisão
  manual (ver seção anterior).
- **Escreva para humano ler primeiro.** O ganho de ser indexável por IA é consequência do formato
  (markdown + links), não o objetivo — uma nota que só um agente entende não serve pro humano que
  vai reler meses depois.
- **Um vault por projeto, nunca um vault único pra todos os projetos da Onda.** Cada projeto é de um
  cliente diferente — misturar bugs/decisões de clientes distintos num grafo só vaza contexto entre
  eles. Padrões técnicos genuinamente reaproveitáveis entre projetos (se/quando surgirem) vivem em
  outro lugar, nunca dentro da `memoria-tecnica/` de um cliente específico.

---

## 12. Rastreio de Progresso — Status por Módulo no ROADMAP.md

*Formalizado em 30/07/2026 — o padrão estrutural (status por módulo dentro do `ROADMAP.md`) já
existia organicamente em mais de um projeto da Onda antes de virar regra escrita — só que cada um
com um vocabulário próprio (ver "Padronização de vocabulário" abaixo).*

### O que é e por quê

A seção 4 sempre falou em "fluxo Kanban" na Fase 4, mas nunca disse **onde** esse Kanban mora.
Este é o padrão oficial: **o quadro Kanban de progresso não é uma ferramenta externa — é o
próprio `ROADMAP.md`.** O Jira (seção 13) é um espelho visual do status para o cliente e para
gestão, não a fonte da verdade do progresso.

### Convenção — vocabulário único, sem variações

Cada módulo, ao nascer na Fase 3 (Blueprint), recebe:
```
**Status:** ⬜ Pendente
```
Ao ser concluído na Fase 4 (testes verdes, commitado), atualiza pra:
```
**Status:** ✅ Concluído (2026-07-09) — backend (137/137 testes...)
```
Um resumo curto do que foi coberto (contagem de testes, achado relevante) é bem-vindo, mas
opcional. Um estado intermediário `🔄 Em andamento` pode ser usado se o módulo estiver em
progresso há mais de uma sessão.

**São exatamente estes 3 marcadores, sempre com esse texto exato — `⬜ Pendente`, `🔄 Em
andamento`, `✅ Concluído` — em todos os projetos da Onda.** Não usar variações como `COMPLETO`,
`DONE`, `Feito`, `Finalizado` etc., mesmo que pareçam sinônimos óbvios — o valor do padrão é
poder olhar o `ROADMAP.md` de qualquer projeto da Onda e reconhecer o status sem reaprender o
vocabulário daquele projeto específico. (Achado nesta mesma formalização: Sistema Melvin e SAW
Hub já tinham convergido pra essa estrutura de forma independente, mas com palavras diferentes
entre si — `COMPLETO` vs `concluído` — corrigido pra um só termo em todos.)

### Distinção do Changelog de Escopo

Isso **não substitui** o Changelog de Escopo (tabela usada no `CLAUDE.md` de outros projetos,
como o Sistema Melvin) — são artefatos com propósitos diferentes:
- **Status por módulo (`ROADMAP.md`)** — progresso: o que já foi construído, módulo a módulo.
- **Changelog de Escopo (`CLAUDE.md`)** — histórico: mudanças de escopo e decisões que alteraram
  o que estava planejado, com data e impacto.

Um projeto pode (e frequentemente deve) ter os dois — não são concorrentes.

---

## 13. Padrão de Gestão Visual (Kanban 9 Colunas)

A ferramenta de gestão visual da Onda é o **Jira** (`ondaenterprise.atlassian.net`), um projeto
**team-managed** com template Kanban por cliente. Ele é o espelho visual do status; a fonte da
verdade continua sendo `docs/product/spec.md` + `ROADMAP.md`. Uma spec criada, alterada ou
removida atualiza primeiro os arquivos locais; o Jira é acertado depois, na UI.

**Não há regra de ouro de sincronização automática.** A tentativa anterior (rodar um
`jira_sync.py` a cada edição de `CLAUDE.md`/`ROADMAP.md`/`spec.md`) recriava issues em
duplicata a cada commit — abandonada. CRUD de issue via API funciona e um projeto derivado pode
manter um script próprio para lotes pontuais, mas nunca disparado por edição de doc. A
configuração de board (colunas, WIP, associar campo ao layout) **não** tem API em projeto
team-managed — só a automação de navegador abaixo. Ver
`memoria-tecnica/bugs/jira-team-managed-endpoints-bloqueados.md`.

### Setup do quadro (uma vez por projeto)

`scripts/jira_browser/` automatiza a **configuração** do board (colunas, WIP, campos) via
navegador, porque a API não deixa. Nenhuma credencial passa por código:

```bash
cd scripts/jira_browser && python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
./start_browser.sh                      # Chrome dedicado; logue no Jira uma vez, à mão
python3 add_columns.py   <PROJECT_KEY> <BOARD_ID>   # cria as 5 colunas Onda
python3 set_wip_limits.py <PROJECT_KEY> <BOARD_ID>  # Max: Em Execução=2, Code Review=3
python3 add_fields.py    <PROJECT_KEY> <ISSUETYPE_ID> "Peso" "Dias Estimados"
```

IDs de board (conferir se entrar projeto novo — `GET /rest/agile/1.0/board?projectKeyOrId=<KEY>`):
SAW=6, MEL=3, MKT=4, LUC=5, HEL=2, VND=9. IDs de issuetype são globais: Epic=10000, Story=10007,
Task=10008, Sub-task=10009, Bug=10010.

### As 9 colunas

Ordem no board (confirmada via API nos 5 projetos de entrega). As posições 1–3 e 7–9 são o fluxo
de trabalho; as 4 a 6 são colunas auxiliares.

| # | Coluna | Categoria | Papel |
|---|---|---|---|
| 1 | **Backlog** | To Do | Épicos e histórias aprovados e detalhados. **Spec-driven**: a issue carrega a spec da feature ou o link para `spec.md` antes de ir para desenvolvimento. |
| 2 | **A Fazer** | To Do | Itens priorizados, refinados e prontos para serem puxados no ciclo atual. |
| 3 | **Em Execução** | In Progress | O que está sendo ativamente codificado agora. **WIP Max = 2.** |
| 4 | **📚 Base de Conhecimento** | To Do | Links para documentação oficial e notas rápidas de memória técnica. |
| 5 | **❄️ Icebox** | To Do | Ideias e pedidos ainda não priorizados. Separa "talvez" do backlog real. |
| 6 | **🏗️ Requisitos Não-Funcionais & Arquitetura** | To Do | Débito técnico, segurança, performance, LGPD, decisões de infra/arquitetura — fora das entregas funcionais. |
| 7 | **🔍 Code Review / Testes** | In Progress | Revisão de código, testes e validação técnica interna. **WIP Max = 3.** |
| 8 | **🧪 UAT (Homologação / Validação do Cliente)** | In Progress | Aceitação do usuário junto ao cliente. Alinha-se à **Fase 5**. |
| 9 | **Done** | Done | Testado, aprovado pelo cliente, homologado e em produção. |

### 13.1 Padrão de Escrita das Issues (Spec-Driven & Checklists)

Para que o board funcione como uma ferramenta ágil real (inspirada no Scrum) e não apenas um amontoado de lembretes, a escrita interna das issues deve seguir regras rígidas:

- **Clareza de Épicos e Histórias de Usuário:** O resumo e a descrição devem comunicar claramente o valor de negócio (ex: "Como usuário, quero X para poder Y"). O contexto do requisito ou o link para o `spec.md` deve estar explícito.
- **Checklists Contextuais ("Critérios de Aceite"):** É terminantemente proibido o uso de listas genéricas (boilerplates). Toda issue refinada (movida para **A Fazer**) deve conter um checklist nomeado exclusivamente como `"Critérios de Aceite"` (checklist nativo ou sub-tasks).
- **Granularidade Técnica:** Os itens desse checklist devem traduzir a regra de negócio em entregas técnicas tangíveis (ex: *Criar índice PostGIS, Construir endpoint GET /search, Validar regra de no-show*). A issue só atinge 100% de conclusão quando todos esses critérios técnicos específicos são validados.

### 13.2 Padrão de Labels

Para garantir rastreabilidade de responsabilidades e filtragem visual rápida, os quadros usam **apenas 6 labels oficiais** no Jira, abolindo tags ad-hoc (ex: "Database", "Integração"). Toda issue de requisito deve ter pelo menos uma destas associada:

- 🔵 **Frontend (UI/UX):** Telas, layouts, SPA, mobile, responsividade.
- 🟢 **Backend (Regras & APIs):** Serviços, banco de dados, regras de negócio, endpoints.
- 🟡 **Arquitetura / Segurança:** Decisões de modelagem estrutural, autenticação, permissões e LGPD.
- 🟠 **Infraestrutura / Cloud:** DevOps, pipelines CI/CD, buckets (S3), Docker, deploys.
- 🟣 **Design / Documentação:** Pesquisa visual, criação de tokens, prototipagem (Figma) e documentação técnica.
- 🔴 **Bug / Débito Técnico:** Correções de defeitos ou refatorações emergenciais de performance.

---

## 14. Análise de KPIs de Fechamento — passo da Fase 5

*Formalizado em set/2026, a partir do projeto Heliene Araújo (piloto). O padrão de métricas
(`docs/METRICAS-KPI.md`) e o prompt operacional (`docs/PROMPT-ANALISE-KPI.md`) nasceram nesse
projeto e valem para todos.*

### O que é e por quê

Todo projeto que fecha deixa aprendizado sobre **prazo, custo e fluxo** que, se não for capturado
num formato comparável, se perde. Este é o passo que transforma cada entrega em dado para o
planejamento da empresa: ao fim (ou perto do fim) de **todo** projeto, roda-se uma análise
padronizada e grava-se `docs/ANALISE-PROJETO-<nome>.md`.

Não é opcional e não é um gateway: a Fase 5 não se encerra sem essa análise, mas ela **não
bloqueia o deploy** — pode (e deve) ser feita assim que o escopo está estável, em paralelo com a
homologação.

### Quando

- **Fase 0** — criar `docs/METRICAS-PROJETO.md` (template no `onda-starter`) e preencher o bloco
  de kickoff: as 4 datas, o valor do contrato + moeda, o canal (Workana/direto) com comissão %,
  taxa de saque % e regime tributário, o valor/hora alvo. O **custo/hora interno da empresa** é o
  único número sensível — fica no sibling privado (`<projeto>-docs-privados/`) ou é informado na
  hora da análise, nunca no repo. O peso dos módulos entra aqui quando o `ROADMAP.md` nascer (Fase 3).
- **Fase 4** — coleta leve contínua nos blocos de `docs/METRICAS-PROJETO.md`: uma linha de
  timesheet por sessão (`data | fase | horas | nota`) e um episódio no log de espera/impedimento
  sempre que o trabalho parar por causa externa (`início | fim | motivo | o que destrava`). Sem
  esses dois, metade dos KPIs vira estimativa grosseira (não dá pra fechar margem real, CPI, flow
  efficiency, realization rate).
- **Fase 5** — a análise em si: rodar `docs/PROMPT-ANALISE-KPI.md` numa sessão na raiz do repo.

### O que a análise cobre

Prazo · **DORA** (deployment frequency, lead time p/ mudança, change failure rate, recovery time,
rework rate) · **Fluxo** (lead time vs. cycle time vs. flow efficiency, aging WIP, flow
distribution, wait/blocked time) · **Valor Agregado** (SPI, CPI, EAC, VAC; burn vs. % concluído) ·
**Financeiro de serviços** (effective hourly rate, realization rate, gross margin com e sem mão de
obra, receita por unidade de escopo, aditivos faturados) · **SPACE** · **Cliente** (on-time
delivery, CSAT, rework, time-to-launch). Definições, fórmulas e alvos: `docs/METRICAS-KPI.md`,
seção 3.

### Regras

- Todo valor derivado de horas não registradas é **faixa estimada**, marcada como tal. Nunca
  fabricar timesheet.
- Cada achado vem com a **implicação de planejamento**, não só o número.
- Anti-padrões proibidos: linhas de código como KPI de valor, velocity como meta ou comparação,
  métrica individual para avaliar pessoa, post-mortem financeiro em vez de acompanhamento contínuo.

### Saída e uso

- `docs/ANALISE-PROJETO-<nome>.md` no repo do projeto + um bloco-resumo (“Snapshot para o
  histórico”) copiado para o registro central da empresa.
- Esse histórico **recalibra a seção 7**: pesos de módulo e preço-base se corrigem com dado real,
  projeto a projeto.

### Ressalvas

- Escrever para humano ler — o valor está no aprendizado destilado, não na tabela.
- Um `ANALISE-PROJETO` por projeto; o padrão (`METRICAS-KPI.md`) é único e fixo para todos.
- É melhor esforço da IA seguir a instrução; o humano confere o preenchimento no fechamento, junto
  com a revisão da `memoria-tecnica/` (Fase 5, atividade 4).

---

## 15. OndaDev 3.0 — o que mudou e onde está

A 3.0 não muda as 6 fases nem o cálculo de prazo. Muda a infraestrutura e a governança:
dois agentes (Claude Code + Codex) sob um contrato comum, VS Code canônico, skills
compartilhadas, failover de cota e CI que valida a própria metodologia.

| Assunto | Fonte canônica |
| --- | --- |
| Contrato de trabalho, risco R0/R1/R2, Definition of Done | `AGENTS.md` (raiz) |
| Versão da metodologia deste projeto | `ONDA_VERSION` |
| Guia de migração 2.0 → 3.0 | `docs/migracao-2.0-para-3.0.md` |
| Skills das fases (`ondadev-*`) | `setup/shared/skills/` |
| Failover de cota / handoff entre agentes | `.ondadev/README.md` |
| Papéis Local (Claude) × Worktree (Codex) | `setup/WORKTREE.md` |
| Ambiente do Codex e ações | `setup/codex/` + `.codex/` |
| Validação automática (CI + hooks) | `.github/workflows/ci.yml` + `.pre-commit-config.yaml` |

Regra de não-duplicação: cada artefato tem **uma** fonte. Esta metodologia descreve o **fluxo**;
comandos exatos, contrato e procedimentos longos vivem nos arquivos acima, não aqui.

---

*Onda · Documento de processo — base para modelagem BPMN. Documento vivo: versionar a cada
evolução do método (versão atual em `ONDA_VERSION`). Toda decisão volta à pergunta-âncora:*
**é belo no design, fluido no uso e seguro por dentro?**
