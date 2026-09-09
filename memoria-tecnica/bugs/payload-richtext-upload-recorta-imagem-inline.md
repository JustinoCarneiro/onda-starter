---
tipo: bug
data: 2026-09-09
severidade: Média
status: Resolvido
origem: projeto Heliene Araújo
---

# RichText do Payload recorta imagem inline em retrato no mobile

## Sintoma
Imagem inserida no meio de um texto rico (post de blog, descrição de projeto) aparece
cortada em retrato 3:4 quando a tela é estreita (celular). No desktop aparece inteira.

## Causa raiz
O `<RichText>` do `@payloadcms/richtext-lexical/react` **já renderiza nós de upload sem
config** — o `UploadJSXConverter` está nos `defaultJSXConverters` (confirmado no fonte:
`dist/features/converters/lexicalToJSX/converter/defaultConverters.js`). O
`UploadFeature` também já vem no editor por padrão, então a autora consegue inserir
imagens.

O problema é o converter padrão: para uma imagem que tem `sizes`, ele emite um
`<picture>` com um `<source media="(max-width: Npx)">` para **cada** `imageSize`
declarado na collection Media. Se a collection tem um size `portrait` (720×960, criado
para a foto de /sobre), abaixo de 720px o browser escolhe esse recorte 3:4 para
**qualquer** imagem inline.

## Solução
Sobrescrever só o converter `upload` para renderizar um `<img loading="lazy">` simples
apontando para a imagem original. Aplicar em toda tela que renderiza texto escrito pela
cliente (blog, descrição de projeto, agenda).

```tsx
// src/lib/richtextConverters.tsx
import type { DefaultNodeTypes, SerializedUploadNode } from '@payloadcms/richtext-lexical'
import type { JSXConvertersFunction } from '@payloadcms/richtext-lexical/react'

export const proseConverters: JSXConvertersFunction<DefaultNodeTypes> = ({ defaultConverters }) => ({
  ...defaultConverters,
  upload: ({ node }: { node: SerializedUploadNode }) => {
    const media = node.value
    if (!media || typeof media !== 'object' || !media.url) return null
    if (media.mimeType && !media.mimeType.startsWith('image')) {
      return <a href={media.url} target="_blank" rel="noopener noreferrer">{media.filename}</a>
    }
    // eslint-disable-next-line @next/next/no-img-element
    return <img src={media.url} alt={media.alt || ''} loading="lazy" width={media.width} height={media.height} />
  },
})
```
```tsx
<RichText data={post.body} converters={proseConverters} />
```

## Ligado a
- [[next-image-rejeita-pdf-em-campo-upload]]
