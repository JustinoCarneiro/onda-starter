# 0004 — Protocolo de revisão cruzada entre agentes sob orçamento fixo

## Contexto

[ADR 0002](0002-capacidade-sob-orcamento-fixo.md) já declara que as cotas dos
agentes são limitadas, sem orçamento para upgrade, e que a
disciplina operacional inclui "subagente só para trilha realmente
independente". Essa disciplina rege a sessão do próprio agente — não rege o
conteúdo do pedido que um agente manda para o **outro** quando `AGENTS.md`
("Revisão e handoff entre agentes") exige revisão cruzada em R1/R2. Esse pedido
roda na conta do agente que o recebe, sob as mesmas regras de cota, e hoje não
tem nenhum limite de escopo, tamanho ou comportamento esperado.

Esse buraco foi medido no histórico de sessão local do Codex
(`~/.codex/sessions/`), que registra prompt, uso de token por turno e status
de rate limit por sessão. Critério e corte: sessões cujo **último**
`task_complete` registrado carrega `"codex_error_info":"usage_limit_exceeded"`,
no retention local atual (2026-09-04 a 2026-10-11) — contagem simples de
qualquer ocorrência do erro em qualquer ponto da sessão superestima o problema,
porque algumas sessões hitaram o limite num turno e completaram com sucesso
num turno posterior. Por esse critério: **26 sessões em 11 projetos derivados
distintos** terminaram sem entregar o turno em curso. Os nomes dos projetos
não entram aqui — são identificadores de clientes reais e este repositório é
público; a contagem agregada preserva a evidência sem exigir essa exposição.
Três casos foram inspecionados: os dois primeiros detalham fan-out de revisão;
o terceiro ilustra consumo entre projetos sem subagentes.

- **Caso 1, 2026-10-10 ("rodada 3" de revisão de uma pilha de 6 PRs):** o
  prompt de revisão mandava ler `AGENTS.md` + `CLAUDE.md` + 6 ADRs (~25 mil
  tokens) antes de qualquer trabalho, e pedia rodar as suítes completas (624
  testes unitários, E2E Docker, Playwright) e reproduzir mutações. O Codex
  abriu 3 subagentes em paralelo (um por PR) além do próprio turno do agente
  principal — 4 threads simultâneas. Em ~3min10s, um único subagente foi de
  40 338 para 2 118 313 tokens totais (93% da janela primária de 5h); os outros
  dois chegaram a 1 016 998 e 1 800 373. As quatro threads terminaram em
  `usage_limit_exceeded` com mensagem final vazia — nenhum achado novo foi
  entregue para nenhuma das 6 PRs, incluindo as duas que o agente principal
  reteve para si.
- **Caso 2, 2026-10-02 (outro projeto, revisão de PR isolada):** o mesmo
  padrão — 5 subagentes nomeados mais o turno principal, todos estourando
  dentro da mesma janela de minutos.
- **Caso 3, onda-starter, 2026-09-22:** uma sessão **sem** subagentes também
  estourou, porque a janela secundária (7 dias) já estava em 37% de uso quando
  a sessão começou — consumida por trabalho em outros projetos na mesma
  semana.

Esse terceiro caso prova o fato estrutural que faltava no ADR 0002: a cota do
Codex (`plan_type: plus`; janela primária de 300 min/5h; janela secundária de
10080 min/7 dias) é **por conta, não por projeto nem por sessão**. Uma revisão
perdulária num projeto consome o orçamento da mesma conta que os outros
projetos do estúdio vão precisar nas horas (ou no resto da semana) seguintes.

## Decisão

1. **Todo pedido de revisão cruzada (R1/R2) a outro agente é escopado por
   diff, nunca por repositório.** Cite `arquivo:método` (código) ou
   `arquivo:seção`/`arquivo:chave` (doc, config) e a pergunta exata; nunca
   "liste todos", "procure em todo o código". Uma busca limitada e nomeada
   (ex.: quem chama `X`, quem consome a config `Y`) é permitida quando serve
   para verificar o impacto de uma mudança específica — o que fica fora é
   varredura aberta sem alvo. Uma PR (ou um tema coeso) por execução, na ordem
   de risco — nunca a pilha inteira numa tacada.
2. **O prompt enviado ao outro agente é enxuto (≈1–1,5 mil tokens), com 3 a 5
   perguntas verificáveis.** O contexto citado é só o necessário à pergunta —
   o ADR do tema, a seção da spec, o contrato de API ou o controle de
   segurança aplicável, conforme o caso — nunca `AGENTS.md` + `CLAUDE.md` +
   todos os ADRs de uma vez "para garantir". Dar ao outro agente o que você já
   levantou (sua própria varredura/medição) para ele *verificar*, não
   *explorar* do zero.
3. **Proibir explicitamente, por padrão, no próprio pedido:** abrir
   subagentes/paralelismo; rodar suítes completas (a evidência de teste vai no
   PR, não é pedido para reexecutar); reproduzir mutações além de uma, e só se
   você apontar qual.
4. **Todo pedido de revisão cruzada leva um teto e uma instrução de saída
   parcial:** "pare ao chegar a N arquivos lidos ou M passos e devolva o que
   tiver, P1 primeiro."
5. **Antes de enviar, declarar o tamanho e o custo estimado do pedido** (número
   de PRs, linhas de diff) e oferecer a versão menor primeiro quando a tarefa
   permitir.
6. **Checar a janela do outro agente antes de disparar uma revisão grande**
   (`/status` no Codex, `/usage` no Claude) — como a cota é da conta inteira,
   não só do projeto atual, uma revisão grande num projeto pode deixar outro
   sem orçamento nas próximas horas/dias. Evitar empilhar revisões pesadas em
   paralelo entre projetos diferentes na mesma janela de 5h.

Essas regras valem para o conteúdo do **pedido de revisão**
(`AGENTS.md`, seção "Revisão e handoff entre agentes"); a disciplina de sessão
do próprio agente (`/clear`, `/compact`, subagente só para trilha
independente) continua sendo a do ADR 0002.

## Consequências

- `AGENTS.md` ganha um apontamento curto para este ADR na seção "Revisão e
  handoff entre agentes", sem duplicar a lista de regras ali.
- `docs/operacao-dia-a-dia.md` (seção 5) ganha a nota de que a cota é por
  conta, não por projeto, ao lado do apontamento para `/usage`/`/status`.
- O gatilho de "bloqueio crônico" previsto no ADR 0002 ("reduzir lote/escopo…
  nunca contratar plano maior") está confirmado por dado medido, não por
  suspeita; este ADR é a resposta operacional a esse gatilho.
- Nenhuma skill nem script gera o prompt de revisão automaticamente hoje; a
  disciplina depende de quem escreve o pedido seguir as 6 regras acima
  manualmente. Se o padrão se confirmar valioso após uso real, um
  gerador de prompt é um PR futuro — não especificado aqui.

## Alternativas consideradas

- **Permitir subagentes com um teto numérico de tokens:** preterida — não há
  telemetria de token exposta a quem escreve o pedido antes de enviá-lo;
  proibir por padrão é mais simples de seguir e de auditar do que calibrar um
  número sem dado prévio por projeto.
- **Upgrade de assinatura (Codex Pro/Business) para absorver o fan-out:**
  rejeitada pelo próprio ADR 0002 — sem orçamento, e o fan-out descontrolado
  continuaria caro mesmo num plano maior.
- **Tratar cada estouro como incidente isolado do projeto onde ocorreu:**
  rejeitada — o mesmo padrão se repetiu em 11 projetos derivados distintos;
  é falha de metodologia, não de um projeto.

## Estado

Aceita — 2026-10-11.
