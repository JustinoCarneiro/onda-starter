# 0006 — Política de modelo, esforço e tier sob cota fixa

## Contexto

O [ADR 0002](0002-capacidade-sob-orcamento-fixo.md) fixa a cota como restrição
permanente, e os ADRs [0004](0004-protocolo-de-revisao-cruzada-entre-agentes.md)
e [0005](0005-teto-de-passos-em-turnos-autonomos.md) trataram desperdício
(fan-out de revisão e turnos longos sem checkpoint). Faltava a camada de
configuração: qual modelo, esforço e tier usar em cada tipo de tarefa.

A pesquisa de 2026-10-11 ([`docs/cota-e-praticas-claude-codex.md`](../../cota-e-praticas-claude-codex.md))
concluiu que o "5x" percebido entre Codex e Claude Code não tinha base pública e
propôs medir. A medição passiva rodou de 11 a 16/10/2026, cruzando o log da
status line do Claude Code (`rate_limits`), os transcritos do Claude Code e os
logs de sessão do Codex. Resultados:

- **Claude Pro:** a janela de 5h equivale a ~US$29 de custo de lista de API e a
  semanal a ~US$215. A calibração é estável: 0,28–0,30 US$/ponto em 6 janelas
  de 5h e 1,9–2,5 US$/ponto em 4 dias, o que sustenta a hipótese de que o
  medidor segue o preço de lista com cache a 0,05x.
- **Codex Plus:** a janela de 5h equivale a ~US$5 no tier `priority` e ~US$9 no
  tier padrão (1,33 e 2,34 créditos por ponto; n=30 e n=10; crédito a US$0,04,
  estimativa não oficial). No mesmo modelo, `priority` consumiu ~2,0x a janela
  (a documentação do Codex diz 2,5x).
- Em outubro, 17 de 19 janelas de 5h do Codex foram de 0% a 92% ou mais, todas
  em `priority`, enquanto o limite semanal ficou em 16%. A razão entre as
  janelas de 5h na configuração daquele mês foi ~5,5x; sem `priority`, ~3x.
- Uma conversa do Codex iniciada seis dias antes (esforço `xhigh`, `priority`)
  foi reaberta e releu ~200 mil tokens a cada chamada até esgotar a janela. A
  configuração nova só vale para conversas novas.
- No Claude Code o limite semanal subiu de 26% para 97% em 5 dias, com sessões
  longas em `xhigh`, até três em paralelo, e a janela de 5h chegou a 100% uma
  vez.

## Decisão

1. **Tier padrão sempre.** No Codex, `service_tier` fica sem definir e
   `[features] fast_mode` e `ultrafast_mode` ficam `false`. Fast só por decisão
   humana explícita, para uma tarefa delimitada.
2. **Modelo e esforço por tipo de tarefa.** `xhigh`, `max` e `ultra` não são
   padrão de rotina; `ultra` no Codex delega a subagentes e segue proibido por
   padrão (ADR 0004). O modelo mais caro de cada ferramenta (Astra, Opus) só com
   aprovação humana, exceto planejamento em conversa nova.

   | Tarefa | Claude Code | Codex |
   | --- | --- | --- |
   | Implementação TDD de módulo | Sonnet `high` | `gpt-6.1-sol` `medium` |
   | Edição mecânica, exploração | Haiku, ou Sonnet `low`/`medium` | `gpt-6-luna` `high` |
   | Depuração difícil | Sonnet `high`, subindo a `xhigh` na mesma conversa | `gpt-6.1-sol` `high` |
   | Planejamento, revisão R2 | Opus `high`, conversa nova, escopo por diff | `gpt-6.1-sol` `high`/`xhigh`, escopo por diff |

   O Claude Code usa Sonnet como modelo padrão da conta, porque o padrão do
   plano é Opus.
3. **Conversas curtas.** Uma conversa por tarefa ou módulo. Não continuar nem
   reabrir conversa com mais de um dia ou com contexto por chamada acima de
   ~150 mil tokens: rodar `ai-checkpoint.sh` e abrir conversa nova com um
   resumo curto. Compactar não substitui isso: a conversa mais longa da
   leitura 1 foi compactada quatro vezes e manteve contexto mediano de 166 mil.
   A regra vale para as duas ferramentas; no Claude Code, retomar uma conversa
   grande depois de a hora do cache expirar reescreve o contexto inteiro.
4. **Uma sessão de escrita longa por ferramenta.** A janela é da conta;
   sessões longas em paralelo somam. Exploração e revisão escopada por diff
   (ADR 0004) não entram na conta.
5. **Failover sem compensar com esforço.** Quando a janela de uma ferramenta
   acaba, a outra assume com as configurações desta política
   (`.ondadev/README.md`); não se sobe esforço nem tier para compensar.
6. **Medição contínua.** Manter a status line do Claude Code gravando
   `rate_limits` e os logs do Codex; a retro leve do ADR 0002 lê os dois.
   Gatilhos de revisão desta política: (a) mais de duas janelas de 5h por semana
   acima de 90% em qualquer ferramenta apesar dela; (b) retrabalho ou testes
   vermelhos atribuídos ao esforço menor; (c) mudança de plano ou limite
   anunciada por um fornecedor.

## Consequências

- Troca qualidade por cota. Num benchmark independente (preço de API, não de
  assinatura), o Claude `high` custa ~2,6x menos tokens que o `xhigh` por ~8
  pontos de índice, e o Codex `medium` custa ~33% menos que o `xhigh` por ~2
  pontos. São números de terceiros, não medidos aqui; se o retrabalho subir,
  sobe-se o esforço pontualmente, não como padrão.
- A leitura 1 (abaixo) mediu que o esforço mexe diretamente em ~11% do custo
  do Claude (a saída); o grosso é leitura e escrita de cache de contexto grande.
  O efeito indireto do esforço (menos passos) não foi medido. Por isso a
  conversa curta pesa mais que a escolha de esforço.
- É convenção documentada. As configurações ficam por usuário
  (`~/.codex/config.toml`, `~/.claude/settings.json`); exemplos estão no
  relatório de pesquisa.
- A evidência é de uma semana e de um estúdio; o preço por crédito não é
  oficial; os créditos do Codex contados aqui ignoram sessões de auto-review e
  de nuvem e portanto subestimam a capacidade da janela. Preços e limites mudam
  (ADR 0002). Os valores numéricos desta decisão são provisórios e se
  recalibram na retro.
- Não decide upgrade de plano; o ADR 0002 continua valendo.
- `docs/operacao-dia-a-dia.md` (seção 5) ganha o apontamento para este ADR.

## Alternativas consideradas

- **Manter as configurações como estavam:** rejeitada — a razão de ~5,5x
  medida na janela de 5h vem em boa parte de tier, esforço e conversas antigas,
  que são corrigíveis sem custo.
- **Baixar o esforço em tudo, de forma simétrica:** rejeitada — as curvas de
  qualidade por esforço diferem entre as ferramentas, e o Claude perde mais ao
  baixar.
- **Concentrar o trabalho numa só ferramenta:** rejeitada — as janelas são
  independentes e o failover entre elas é o plano (ADR 0002).
- **Esperar um A/B controlado antes de decidir:** preterida — a medição passiva
  já sustenta o que é barato e reversível; o A/B serve para calibrar os números.

## Leituras da medição

### Leitura 1 — 2026-10-17

Fontes: log da status line e transcritos do Claude Code (deduplicados por id de
mensagem, com subagentes) e logs de sessão do Codex (deduplicados entre forks).
Cobre ~30 h de política no Codex; o Claude ainda não tem dado sob a política,
porque o esforço dele só foi ajustado em 2026-10-17 e a cota semanal estava
quase esgotada desde 16/10.

- **Codex, preço por token:** tier padrão com `gpt-6.1-sol` `medium` consumiu
  2,0 pontos da janela de 5h por milhão de tokens (3,0 em `gpt-6-sol` `medium`;
  5 a 11 nas medições com `xhigh`, `priority` e `ultra`).
- **Codex, volume:** cada janela de 5h passou a consumir ~50 milhões de tokens
  (antes 16 a 33), e três janelas chegaram a 100% em ~30 h. **O gatilho (a)
  disparou.** O limite semanal foi de 16% a 59% no mesmo período; cada janela
  de 5h cheia custa ~20 pontos semanais.
- **Codex, causa:** uma única conversa (34 turnos, 817 chamadas, 4 compactações)
  concentrou 75% dos tokens, com contexto mediano de 166 mil e máximo de 342
  mil; uma segunda, aberta no mesmo minuto, outros 15%. Na semana, 65% dos
  tokens estavam em chamadas com mais de 150 mil de contexto. A regra do item 3
  existia e não foi seguida; por isso foi reforçada.
- **Codex, subagentes:** 10 threads, 4% dos tokens, com `features.multi_agent =
  false` no config. O app desktop não respeita a flag; a contenção do ADR 0004
  (escopo por diff, sem fan-out no pedido) continua necessária.
- **Claude, calibração:** a semana de 10 a 17/10 chegou a 98%, equivalente a
  ~US$ 218 de custo de lista (~US$ 2,2 por ponto semanal; 0,25 a 0,32 por ponto
  na janela de 5h), o que confirma a calibração do Contexto. A estimativa vem
  dos transcritos, calibrada contra o custo registrado pelo Claude Code
  (razão 0,47; 5 sessões).
- **Claude, composição:** 89% do custo é cache (62% leitura, 27% escrita) e 11%
  é saída. 64% do custo está em chamadas com mais de 400 mil de contexto. Houve
  25 reescritas de cache de 150 mil tokens ou mais (~14% do custo); das 19 na
  conversa principal, 16 vieram depois de uma pausa de mais de uma hora, com o
  cache expirado. Um teto hipotético de 150 mil por chamada
  reduziria o custo em até 49% (limite superior: ignora o custo de abrir
  conversas novas). Subagentes foram 7% do custo.
- **Claude, janelas de 5h:** duas acima de 90%, ambas na mesma noite com três
  sessões em paralelo (item 4), antes da política.
- **Não avaliados:** gatilhos (b) e (c).

Próxima leitura: após uma semana completa do Claude sob a política.

## Estado

Aceita — 2026-10-16. Item 3 reforçado e leitura 1 registrada em 2026-10-17.
