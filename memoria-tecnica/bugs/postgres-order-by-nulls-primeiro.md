---
tipo: bug
data: 2026-09-09
severidade: Média
status: Resolvido
origem: projeto Heliene Araújo
---

# `ORDER BY campo DESC` no Postgres joga registros sem valor para o topo

## Sintoma
Numa listagem "mais recente primeiro" ordenada por uma data **opcional**, os itens **sem
data preenchida** aparecem antes de todos os datados — o contrário do esperado.

## Causa raiz
No Postgres, `ORDER BY x DESC` coloca `NULL` **primeiro** por padrão (`NULLS FIRST` é o
default em ordem descendente). Um `sort: '-date'` do Payload vira exatamente isso.

Armadilha secundária: uma primeira correção com `sort: ['-date', '-createdAt']` só
resolve a instabilidade (ordem entre os NULLs), não o lado — os NULLs continuam no topo.

## Solução
Ordenar em memória usando `data ?? data_de_cadastro` como chave, extraído para um helper
puro e testável:

```ts
export function sortByRecency<T extends { date?: string | null; createdAt: string }>(rows: T[]): T[] {
  const key = (r: T) => new Date(r.date ?? r.createdAt).getTime()
  return [...rows].sort((a, b) => key(b) - key(a))
}
```

Se preferir no banco: `ORDER BY date DESC NULLS LAST, created_at DESC`.

Regra: **só se vê ao olhar a tela com dado realista** — um e2e por seletor não pega. Faz
parte do valor da "revisão por screenshot" com conteúdo do cliente.

## Ligado a
- [[secao-oculta-quando-collection-vazia]]
