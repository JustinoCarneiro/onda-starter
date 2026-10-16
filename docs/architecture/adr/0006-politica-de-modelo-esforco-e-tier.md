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
3. **Conversas curtas.** Uma conversa por tarefa ou módulo. Não reabrir
   conversa com mais de um dia ou com contexto por chamada acima de ~150 mil
   tokens: rodar `ai-checkpoint.sh` e abrir conversa nova.
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

## Estado

Aceita — 2026-10-16.
