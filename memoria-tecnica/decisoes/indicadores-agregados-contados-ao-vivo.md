---
tipo: decisao
data: 2026-09-09
status: Ativa
origem: projeto Heliene Araújo
---

# Indicadores agregados da Home são contados ao vivo, não campo manual

## Contexto
A Home tem uma faixa de "números" (nº de projetos, publicações, capítulos, municípios
atendidos, orientações). Ao longo do projeto de referência a implementação foi e voltou
**quatro vezes**:
1. contados automaticamente das collections;
2. números fixos hardcoded no código (a cliente pediu, "conteúdo real entrando aos
   poucos");
3. campo `number` editável no global `Home` (`stat*`), ela digitava;
4. **de volta a automático** — os números digitados descolaram do site
   ("está 9, mas subi 3") e ela percebeu na hora.

## Decisão
Contar **ao vivo** do conteúdo publicado. Sem campo numérico no painel.

```ts
// src/lib/homeStats.ts — padrão
const publishedCount = (payload, collection, extra?) =>
  payload.count({
    collection,
    where: extra ? { and: [{ _status: { equals: 'published' } }, extra] } : { _status: { equals: 'published' } },
    overrideAccess: false,
  }).then(r => r.totalDocs).catch(() => 0)

// agregação que varre linhas (ex.: distintos): pagination:false, senão para na 1a página
payload.find({ collection: 'projects', where: {...}, pagination: false, depth: 0, select: { municipalities: true } })
```

## Consequências
- **Um "número manual" sempre descola da realidade** e o cliente nota. Não oferecer campo
  manual como default.
- Se o cliente quer um número **curado** (ex.: "municípios atendidos na carreira toda",
  não só os do site), adicionar um **override opcional** por indicador — se preenchido,
  ganha da contagem; se vazio, vale a contagem. Não substituir a contagem inteira.
- Agregação que varre linhas (contar distintos, somar) precisa de `pagination: false` —
  senão para na 1ª página (1000) e fica menor que o indicador de contagem simples ao
  lado.
- Cada consulta com `.catch(() => 0)` — indicador zerado é melhor que Home quebrada.
- Contagem de subconjunto (ex.: "capítulos" = publicações `type: capitulo`) é
  `and: [published, { type: { equals: ... } }]`.

## Ligado a
- [[campo-lista-hasmany-vs-texto-unico]]
