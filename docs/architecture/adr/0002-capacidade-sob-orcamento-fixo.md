# 0002 — Estratégia de capacidade sob orçamento fixo; piloto A/B dispensado

## Contexto

O OndaDev 3.0 opera com dois agentes (Claude Code + Codex) em assinaturas de
nível básico — Claude Pro e ChatGPT Plus — com cota compartilhada em janelas
móveis de 5 h e teto semanal. A estratégia OndaDev 3.0 previa um piloto A/B de
duas semanas (PR-08) para medir a matriz de papéis e decidir sobre um upgrade
de assinatura (Claude Pro → Max; ChatGPT Plus → Pro/Business).

O estúdio **não tem orçamento para upgrade**, e essa é uma restrição
permanente, não uma questão em aberto a ser resolvida pelo piloto.

## Decisão

1. **Sem upgrade de assinatura.** A estratégia de capacidade é o failover entre
   agentes descrito em `.ondadev/README.md` (PR-05): quando a janela de um
   agente esgota, o outro assume por handoff. Não é paliativo — é o plano.
2. **Piloto A/B formal (PR-08) dispensado.** A metade financeira do seu critério
   de decisão ("medir para decidir upgrade") já está respondida. A calibração da
   matriz de papéis passa a ser feita por uma **retrospectiva leve** após ~5–10
   tarefas reais, usando a coleta que já existe: `docs/METRICAS-PROJETO.md`
   (timesheet + log de espera/impedimento), `scripts/ai-checkpoint.sh` e a taxa
   de CI aprovado na primeira tentativa.
3. **Disciplina de cota é política operacional:** uma tarefa por conversa;
   `/clear` ao trocar de assunto; `/compact` com foco; CLI antes de MCP;
   subagente só para trilha realmente independente.

## Consequências

- O rollout (PR-09) não depende do PR-08.
- Se o bloqueio de cota ficar crônico mesmo com o revezamento entre agentes, a
  resposta é **reduzir lote/escopo** e fechar apenas a unidade atômica em
  andamento — nunca contratar plano maior.
- A matriz de papéis da seção 9 da metodologia é ponto de partida ajustável por
  retro, não um resultado medido. Documentos que a citam devem deixar isso claro.
- Preços e limites de assinatura mudam. Se algum dia houver orçamento, este ADR
  é substituído por um novo, com os números revalidados nas páginas oficiais.

## Alternativas consideradas

- **Executar o PR-08 como especificado (2 semanas, 10 tarefas comparáveis):**
  rejeitada — a pergunta financeira central já está respondida e o custo de
  contexto e de tempo de um experimento formal não se paga.
- **Não medir nada:** rejeitada — a retro leve custa quase nada e evita que a
  matriz de papéis fique sem calibração com dado real.
- **Fixar aliases de modelo mais baratos nos subagentes para poupar cota:**
  preterida — `model: inherit` já segue o modelo da sessão; trocar por alias é
  decisão de projeto derivado (ver [ADR 0001](0001-skills-compartilhadas-onda.md)).

## Estado

Aceita — 2026-09-06.
