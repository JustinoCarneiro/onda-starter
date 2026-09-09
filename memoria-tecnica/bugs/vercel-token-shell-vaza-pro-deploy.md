---
tipo: bug
data: 2026-09-09
severidade: Média
status: Resolvido
origem: projeto Heliene Araújo
---

# `VERCEL_TOKEN` do perfil de shell do dev vaza para o deploy do cliente

## Sintoma
`vercel deploy ... --token=<token do cliente> --scope=<time do cliente>` falha com
*"The specified scope does not exist"* — mesmo com o token certo em mãos.

## Causa raiz
O desenvolvedor tem um `VERCEL_TOKEN` **exportado no `.zshrc`/`.bashrc`** apontando para a
conta pessoal dele. O CLI (e scripts ingênuos) leem a variável de ambiente **antes** do
`.env` do projeto, então o token do dev vence e o `--scope` do cliente não existe naquela
conta. A mensagem de erro aponta para o escopo e manda investigar o lado errado.

## Solução
No script de deploy, o `.env` do projeto tem **prioridade** sobre o ambiente:

```bash
TOKEN=""
[ -f "$REPO/.env" ] && TOKEN="$(grep -E '^VERCEL_TOKEN=' "$REPO/.env" | head -1 | cut -d= -f2- | tr -d '"'\'' ')"
[ -z "$TOKEN" ] && TOKEN="${VERCEL_TOKEN:-}"
```

Vale lembrar: essa variável no perfil do dev pode atrapalhar **qualquer** comando
`vercel` rodado dentro do projeto do cliente, não só o deploy.

## Ligado a
- [[vercel-deploy-bloqueado-autor-de-commit]]
