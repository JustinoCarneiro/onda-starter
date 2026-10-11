# 0005 — Teto de passos em turnos autônomos longos

## Contexto

[ADR 0002](0002-capacidade-sob-orcamento-fixo.md) já exige disciplina de cota
na própria sessão ("/compact com foco", subagente só para trilha
independente) e [ADR 0004](0004-protocolo-de-revisao-cruzada-entre-agentes.md)
escopou isso para o **pedido** de revisão cruzada entre agentes. Nenhum dos
dois cobre o caso em que o **próprio agente**, trabalhando sozinho num turno
autônomo longo (por exemplo, construção de um módulo via `ondadev-build`),
encadeia muitas chamadas de ferramenta sem pausar — e por isso nunca dá chance
aos limiares de 75/90/100% de `.ondadev/README.md` de disparar, porque esses
limiares só são medidos quando o agente para para checar `/usage`/`/status`
entre turnos.

Isso foi medido: das 26 sessões/11 projetos que terminaram em
`usage_limit_exceeded` (ver ADR 0004), **16 (62%) não têm nenhum subagente**
— a maioria com poucos turnos (1 a 6) e totais finais enormes (2 a 56 milhões
de tokens), consistente com um turno único crescendo sem pausa, não com
fan-out. Um caso foi inspecionado em detalhe:

- **Caso observado em setembro de 2026, durante a Fase 4:** um único turno
  autônomo encadeou **44 chamadas de `exec`** em ~20 minutos, sem nenhuma
  pausa. O total de tokens cresceu quase linearmente a cada chamada —
  20 mil, 279 mil, 943 mil, 2,04 milhões, 4,35 milhões — porque cada chamada
  reenviava o histórico acumulado de todas as anteriores (a skill
  `ondadev-build` inteira + `CLAUDE.md` + `ROADMAP.md` + a saída de cada
  `exec` anterior). O turno terminou em `usage_limit_exceeded` no meio do
  módulo, sem checkpoint e sem commit.

O mecanismo é diferente do ADR 0004 (ali o custo multiplicava por fan-out de
subagentes; aqui o custo cresce dentro de um único turno porque nada o
interrompe) mas a causa raiz é a mesma categoria: nenhum lugar da metodologia
diz **quando parar** um turno autônomo antes que ele acabe sozinho.

## Decisão

1. **Nenhum turno autônomo (build, release, discovery, investigação) encadeia
   mais de 15 chamadas de ferramenta sem pausar.** O ponto-alvo provisório é 12:
   ao chegar nele, o agente não começa outra unidade, conclui a chamada em
   andamento, roda `ai-checkpoint.sh` e devolve controle — mesmo que a fase não
   tenha convergido. O teto deve ser recalibrado após uso real, conforme ADR
   0002.
2. **No ciclo TDD do `ondadev-build`, Red, Green e Refactor são pontos de
   checkpoint**, não uma cadeia ininterrupta. Ao bater o teto do item 1 dentro
   de uma dessas fases, o agente para ali, relata o estado (o que passou, o
   que falta) e aguarda confirmação para continuar — não tenta "terminar o
   módulo" de uma vez.
3. **O teto por passos é o que dá chance real aos limiares de
   `.ondadev/README.md` (75/90/100%) de funcionar.** Eles pressupõem uma pausa
   entre turnos para checar `/usage`/`/status`; um turno sem pausa nunca é
   medido a tempo. O teto deste ADR não substitui aqueles limiares — garante
   que eles sejam consultados com frequência suficiente.
4. Isso vale para qualquer skill que produza turnos autônomos longos, não só
   `ondadev-build` — a referência central fica neste ADR para não duplicar a
   regra em cada skill.

## Consequências

- `setup/shared/skills/ondadev-build/SKILL.md` ganha o teto de passos e os
  pontos de checkpoint explícitos no ciclo Red-Green-Refactor, com
  apontamento para este ADR.
- Um módulo que antes seria "uma sessão só até terminar" pode agora precisar
  de várias trocas de turno (usuário confirma "continua") — é o custo
  aceito pela troca de previsibilidade de orçamento.
- Não há telemetria de passos exposta ao agente durante o turno; o teto é
  seguido por contagem própria (lembrar quantas chamadas de ferramenta já
  fez desde o último checkpoint), não por um mecanismo automático externo.
  Se isso se mostrar não confiável na prática, um contador explícito (ex.:
  anotar a contagem no início de cada resposta) é um ajuste futuro deste ADR.

## Alternativas consideradas

- **Confiar só nos limiares de 75/90/100% de `.ondadev/README.md`:** rejeitada
  — é exatamente o que já existia e não preveniu o caso observado; eles só
  funcionam com pausa entre turnos, que é o que falta.
- **Proibir turnos autônomos longos por completo (sempre pedir confirmação a
  cada chamada de ferramenta):** rejeitada — destrói a produtividade do ciclo
  TDD para a maioria dos módulos, que termina bem antes de qualquer teto.
- **Teto fixo mais baixo (ex.: 5 chamadas):** preterida por ora — sem dado
  sobre quantas chamadas um módulo típico de risco baixo/médio realmente
  precisa; 12 chamadas como alvo e 15 como máximo são estimativas iniciais,
  ajustáveis por retro (ADR 0002, ponto 2).

## Estado

Aceita — 2026-10-11.
