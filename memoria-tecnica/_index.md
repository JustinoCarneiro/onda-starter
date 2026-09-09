---
tipo: indice
---

# Memória Técnica — [Nome do Projeto]

Base de conhecimento viva do projeto: bugs cabeludos resolvidos (com causa raiz) e decisões técnicas
tomadas fora da spec original do [`CLAUDE.md`](../CLAUDE.md). Não documenta conceitos genéricos — só o
que é específico deste projeto e não seria óbvio olhando só o código.

Padrão da metodologia Onda-Dev — ver seção 11 de
[`Metodologia_de_Desenvolvimento_-_Onda.md`](../docs/Metodologia_de_Desenvolvimento_-_Onda.md) pro
critério completo de quando vale (e quando não vale) criar uma nota aqui.

## Como usar
- **Antes de investigar um bug**, procurar em `bugs/` se algo parecido já foi resolvido.
- **Antes de tomar uma decisão de arquitetura**, procurar em `decisoes/` se já existe uma decisão
  relacionada (evita reabrir debate já resolvido ou contradizer uma decisão ativa).
- **Ao resolver um bug não-trivial** (que exigiu investigação real, causa raiz não óbvia a partir do
  código) ou **tomar uma decisão técnica fora da spec**, criar uma nota nova usando `templates/bug.md`
  ou `templates/decisao.md`, e linkar às notas relacionadas com a notação `[[nome-da-nota]]`.
- Não criar nota se o fato já tem um lar melhor (já é critério de aceite no `CLAUDE.md`, ou já tem um
  aviso dedicado em outro doc) — isso duplicaria a fonte de verdade em vez de complementá-la.

## Bugs
*(o específico de cada projeto nasce vazio na Fase 0 e é populado na Fase 4)*

## Decisões
*(idem)*

---

## Notas promovidas de projetos (reaproveitáveis entre clientes)

Bugs e decisões que apareceram num projeto mas valem para os próximos. Ao scaffoldar um
projeto novo, dá para manter (viajam como conhecimento pronto) ou podar para começar
limpo. Playbooks maiores em [`../docs/`](../docs/).

### Bugs
- [[jira-team-managed-endpoints-bloqueados]] — campo→layout é gap de API; delete de issue é permissão
- [[payload-richtext-upload-recorta-imagem-inline]] — `<RichText>` emite `<picture>` com o size `portrait`, recorta 3:4 no mobile
- [[next-image-rejeita-pdf-em-campo-upload]] — campo `upload` sem `filterOptions` aceita PDF, quebra o `next/image`
- [[vercel-cli-blob-put-random-suffix-ignorado]] — CLI ignora `--add-random-suffix false`; usar o SDK
- [[postgres-order-by-nulls-primeiro]] — `ORDER BY x DESC` põe NULL no topo; ordenar em memória com fallback
- [[vercel-deploy-bloqueado-autor-de-commit]] — deploy `UNKNOWN` sem log = `TEAM_ACCESS_REQUIRED`
- [[vercel-token-shell-vaza-pro-deploy]] — `VERCEL_TOKEN` do perfil do dev vence o `.env` do projeto

### Decisões
- [[indicadores-agregados-contados-ao-vivo]] — faixa de números da Home conta ao vivo, sem campo manual
- [[campo-lista-hasmany-vs-texto-unico]] — "um X pode ter vários Y" → `hasMany`, com migração
- [[ordenacao-manual-orderable-com-backfill]] — `orderable: true` + backfill de `_order` na migração
- [[secao-oculta-quando-collection-vazia]] — item do menu some quando 0 publicados; a 404 responde 200
- [[legenda-de-foto-reusa-o-alt-da-midia]] — legenda visível = "Texto alternativo" da mídia, sem campo novo

### Playbooks (`../docs/`)
- [`handoff-infra-para-conta-do-cliente.md`](../docs/handoff-infra-para-conta-do-cliente.md)
- [`deploy-vercel-sem-seat-no-time-do-cliente.md`](../docs/deploy-vercel-sem-seat-no-time-do-cliente.md)
- [`migracoes-payload-postgres.md`](../docs/migracoes-payload-postgres.md)
- [`modal-lightbox-acessivel.md`](../docs/modal-lightbox-acessivel.md)
