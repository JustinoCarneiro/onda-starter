---
tipo: decisao
data: 2026-09-09
status: Ativa
origem: projeto Heliene Araújo
---

# Seção some do menu enquanto a collection não tem nada publicado

## Contexto
Conteúdo entra aos poucos. Um item de menu levando a uma página vazia (Blog, Fotos,
Agenda ainda sem conteúdo) parece site quebrado.

## Decisão
Enquanto a collection tem **0 documentos publicados**: o item some do menu **e** a página
responde `notFound()`. Volta sozinho ao publicar o primeiro. Páginas fixas
(Home/Sobre/Contato/Currículo) sempre aparecem.

```ts
// src/lib/sections.ts
const isPublishedEmpty = cache(async (collection) => {
  try {
    const res = await (await getPayloadClient()).find({
      collection, where: { _status: { equals: 'published' } }, limit: 0, depth: 0, overrideAccess: false,
    })
    return res.totalDocs === 0
  } catch { return false }  // fail-open: banco frio não some com o menu inteiro
})
```

`cache()` do React dedupa layout + página + generateMetadata no mesmo request.

## Consequências
- A página de "não encontrada" do site responde **HTTP 200** (renderiza com o chrome do
  site), não 404. Então:
  - **testes e2e checam presença de conteúdo, não status HTTP**;
  - uma seção oculta ainda é uma página 200 pro Google (SEO — aceitável na v1, anotar).
- **Avisar o cliente no manual**: "enquanto você não publicar o primeiro item, o link não
  aparece no menu". Sem isso a reação é "as fotos sumiram".
- Rótulo dinâmico do item (ex.: "Orientações" vs "Coorientações" conforme o conteúdo
  publicado) segue o mesmo padrão de `cache()` + fail-safe.

## Ligado a
- [[postgres-order-by-nulls-primeiro]]
