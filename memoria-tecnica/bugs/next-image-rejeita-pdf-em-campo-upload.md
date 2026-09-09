---
tipo: bug
data: 2026-09-09
severidade: Baixa
status: Resolvido
origem: projeto Heliene Araújo
---

# next/image quebra (400) quando escolhem um PDF num campo de imagem do Payload

## Sintoma
Thumbnail quebrada / erro 400 na página quando um editor seleciona um PDF (da biblioteca
compartilhada de Media) num campo `upload` que era para ser imagem — capa de post, ícone
de item, foto de destaque.

## Causa raiz
Um campo `upload` sem restrição aceita qualquer mídia da collection. A página renderiza
por `next/image`, que rejeita `application/pdf` como imagem inválida.

## Solução
`filterOptions` restringindo a mídia a imagens nos campos que são renderizados como
imagem. Campos de "documento / anexo" ficam sem restrição.

```ts
{
  name: 'coverImage',
  type: 'upload',
  relationTo: 'media',
  filterOptions: { mimeType: { contains: 'image' } },
},
```

## Ligado a
- [[payload-richtext-upload-recorta-imagem-inline]]
