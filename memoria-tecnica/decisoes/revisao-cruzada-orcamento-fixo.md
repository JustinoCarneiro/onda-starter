---
tipo: decisao
data: 2026-10-11
status: Ativa
---

# Revisão cruzada sob orçamento fixo

## Contexto

Uma revisão ampla num projeto consome a mesma cota da conta usada pelos outros
projetos. O corte local de 2026-10-11 encontrou **26 sessões em 11 projetos**
cujo último evento `task_complete` registrou `usage_limit_exceeded`.

## Decisão

Aplicar o protocolo do [ADR 0004](../../docs/architecture/adr/0004-protocolo-de-revisao-cruzada-entre-agentes.md).
O critério de contagem é uma fotografia da retenção local nessa data; a
metodologia e as regras operacionais do protocolo permanecem no ADR.

## Consequências

- Tratar 26/11 como dado histórico do corte, não como contador atual.
- Não reproduzir identificadores de projetos nem conteúdo dos prompts no starter.
- Atualizar o ADR se uma nova medição mudar a decisão.
