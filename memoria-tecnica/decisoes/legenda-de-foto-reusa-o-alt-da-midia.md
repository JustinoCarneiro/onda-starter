---
tipo: decisao
data: 2026-09-09
status: Ativa
origem: projeto Heliene Araújo
---

# Legenda visível da foto reusa o "Texto alternativo" da mídia

## Contexto
Cliente quer legenda embaixo de cada foto na galeria. O modelo de álbum era
`photos: upload hasMany` (sem sub-campos por foto).

## Decisão
A legenda exibida **é** o campo `alt` da mídia (o "Texto alternativo" que ela já preenche
ao subir a foto, para leitor de tela e SEO). Sem campo de legenda dedicado por foto.

```tsx
const photos = (album.photos ?? [])
  .filter((p): p is Media => typeof p === 'object' && Boolean(p?.url))
  .map((p) => ({ url: p.url, alt: p.alt, caption: p.alt }))
// <figcaption>{photo.caption}</figcaption>
```

## Consequências
- **Zero migração**, e o texto que ela já preenchia passa a aparecer imediatamente.
- Trade-off: a mesma foto usada em dois contextos tem a **mesma** legenda. Aceitável para
  o caso de uso (fotos de campo).
- Se um dia precisar legendas diferentes por contexto: aí sim `photos` vira `array
  { imagem: upload, legenda: text }` — migração de `_rels` para tabela de array, mais
  cara.
- Documentar no manual que o "Texto alternativo" tem duas funções (acessibilidade +
  legenda).

## Ligado a
- [[modal-lightbox-acessivel]]
