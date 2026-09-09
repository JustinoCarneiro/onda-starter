# Playbook — modal / lightbox acessível (AA) sem biblioteca

Origem: projeto Heliene Araújo (`src/components/PhotoGallery.tsx`). Cliente pediu fotos
"clicáveis e grandes" — no celular ficavam pequenas.

## Checklist

- **Renderizar via `createPortal(node, document.body)`.** Um ancestral com `transform`
  (comum em transições de página) encurta `position: fixed` para dentro dele e o overlay
  não cobre a tela toda. O portal no `<body>` resolve. Confirmar depois com
  `document.elementFromPoint(x, y)` no topo da tela = o overlay; e amostrar o pixel real
  (`(26,30,25)` ≈ backdrop 0.94 — o header por trás fica em ghosting de 6%, o que ilude
  no screenshot mas está certo).
- `z-index` **acima do header sticky** (no projeto: 1000 vs header 40).
- `role="dialog"` + `aria-modal="true"` + `aria-label`.
- **Foco**: ao abrir, mover o foco para dentro do dialog (primeiro botão); **prender o
  Tab** (circular entre os controles, incluindo o wrap Shift+Tab); ao fechar, **devolver
  o foco** para o elemento que abriu (guardar o índice no clique).
- `Escape` fecha; clique no backdrop fecha (com `stopPropagation` na figura/imagem);
  travar `document.body.style.overflow = 'hidden'` e restaurar no cleanup.
- `@media (prefers-reduced-motion: reduce)` mata a animação de entrada.
- Cada miniatura-gatilho tem `aria-label` que **nomeia a foto específica**
  (`${abrir}: ${legenda || alt}`); um `aria-label` genérico **sobrescreve** o `alt` da
  `<img>` aninhada e o leitor de tela não sabe qual foto vai abrir. A `<img>` da
  miniatura fica com `alt=""` (a informação está no botão).
- `next/image` no overlay: parent `.lightbox-image` com `position: relative` e
  **largura/altura explícitas** (`width: min(1100px, 86vw); height: min(78vh, 780px)`) —
  `flex:1; min-height:0` num column-flex sem altura definida colapsa para 0 e a imagem
  fica "hidden" pro Playwright.
- Não usar `setState` síncrono dentro de `useEffect` só pra "montou" — se o portal só
  renderiza depois de um clique (já client-side), o guard `mounted` é redundante e
  dispara lint (`react-hooks`). Capturar refs em variáveis dentro do effect para o
  cleanup não reclamar.

## CSS que importa

```css
.lightbox { position: fixed; inset: 0; z-index: 1000; display: flex;
  align-items: center; justify-content: center; background: rgba(12,16,11,.94); }
.lightbox-btn { position: absolute; z-index: 2; /* acima da figura */ }
.gallery-open { position: absolute; inset: 0; border: 0; background: none; cursor: zoom-in; }
.gallery-item figcaption { pointer-events: none; -webkit-line-clamp: 2; /* não bloqueia o clique */ }
```

Cores hardcoded (`#F3F1EC` sobre backdrop escuro) são OK **só** porque o backdrop é
sempre escuro; todo o resto do CSS novo usa tokens de tema.

## Componente de referência

`src/components/PhotoGallery.tsx` no projeto Heliene — grade + lightbox num arquivo,
recebe `photos: {url, alt, caption}[]` e `labels` localizados.
