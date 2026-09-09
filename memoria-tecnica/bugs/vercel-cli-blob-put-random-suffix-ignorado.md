---
tipo: bug
data: 2026-09-09
severidade: Baixa
status: Resolvido (usar o SDK)
origem: projeto Heliene Araújo
---

# `vercel blob put --add-random-suffix false` é ignorado pelo CLI

## Sintoma
Ao migrar arquivos entre Blob stores, `vercel blob put arquivo.jpg --add-random-suffix
false --pathname arquivo.jpg` sobe como `arquivo-<hash-aleatorio>.jpg` mesmo assim. O
Payload monta a URL da mídia como `/api/media/file/<filename>` exato, então o nome com
sufixo = imagem quebrada.

## Causa raiz
Bug/quirk de parsing de flag booleana no `vercel` CLI (versão ~59.x): `--add-random-suffix
false` não desativa o sufixo.

## Solução
Usar o SDK `@vercel/blob` direto, que respeita `addRandomSuffix: false`:

```js
import { createRequire } from 'node:module'
const require = createRequire('/caminho/do/projeto/')
const { put, list } = require('@vercel/blob')

await put(pathname, buffer, {
  access: 'public',
  addRandomSuffix: false,
  allowOverwrite: true,
  contentType: 'image/jpeg',
  token, // BLOB_READ_WRITE_TOKEN do store de destino
})
```

Detalhe: passar `BLOB_STORE_ID` junto com o token confunde o CLI/SDK (acha que é OIDC).
Exportar **só** `BLOB_READ_WRITE_TOKEN`.

## Ligado a
- [[handoff-infra-para-conta-do-cliente]]
