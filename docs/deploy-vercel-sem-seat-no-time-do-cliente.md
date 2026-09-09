# Playbook — publicar sem seat pago no time Vercel do cliente

Origem: projeto Heliene Araújo. Depois do handoff, o projeto vive no time do cliente e o
dev não é membro.

## Por que não dá do jeito normal

- `vercel deploy` / `git push`: o build é **bloqueado** porque o **autor do commit** não
  é membro do time (`readyState: BLOCKED`, `TEAM_ACCESS_REQUIRED`). Sintoma enganoso:
  deployment preso em `UNKNOWN` **sem log**; o motivo real só está em
  `GET /v13/deployments/<id>` → `readyStateReason`. Detalhe completo em
  `memoria-tecnica/bugs/vercel-deploy-bloqueado-autor-de-commit.md`.
- `vercel redeploy` e o "Redeploy" do painel: falham com *"The provided GitHub repository
  can't be found"* (o Claim não trouxe a ligação com o GitHub).
- **Plano gratuito de time** não deixa adicionar membro (paywall). Conta pessoal Hobby
  não tem "membro".

## Contorno em uso: deploy de cópia sem `.git`

Sem histórico Git → sem autor de commit → o deploy é atribuído à dona do token.

```bash
#!/usr/bin/env bash
set -euo pipefail
SCOPE="<slug-do-time>"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; cd "$REPO"

# .env do PROJETO ganha do ambiente (o dev tem VERCEL_TOKEN no shell dele)
TOKEN=""
[ -f "$REPO/.env" ] && TOKEN="$(grep -E '^VERCEL_TOKEN=' "$REPO/.env" | head -1 | cut -d= -f2- | tr -d '"'\'' ')"
[ -z "$TOKEN" ] && TOKEN="${VERCEL_TOKEN:-}"
[ -z "$TOKEN" ] && { echo "sem VERCEL_TOKEN"; exit 1; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
git archive --format=tar HEAD | tar -x -C "$TMP"       # ou rsync --exclude=.git p/ incluir não-commitado
mkdir -p "$TMP/.vercel"; cp "$REPO/.vercel/project.json" "$TMP/.vercel/project.json"
cd "$TMP"
vercel deploy --prod --yes --archive=tgz --token="$TOKEN" --scope="$SCOPE"
```

- **`--archive=tgz` é obrigatório** — sem ele o upload arquivo-a-arquivo pendura e o
  deployment nasce `UNKNOWN`.
- `VERCEL_TOKEN` no `.env` (gitignored) = Access Token que o cliente gera em **Account
  Settings → Tokens**, escopo do time, validade longa.
- Linkar uma vez: `vercel link --yes --project <nome> --scope <slug> --token=$TOKEN` (o
  `.vercel/project.json` fica com o `orgId` do time novo).

## Alternativas

| Opção | Quando |
| --- | --- |
| **Mover o projeto para a conta pessoal Hobby do cliente** | Melhor. Conta pessoal não tem "membro", a regra de autor de commit não se aplica, e `git push` com GitHub conectado volta a funcionar. Combina com "Vercel Hobby pessoal" do escopo. |
| **GitHub Action no repo do dev** rodando `vercel deploy` com o token como secret | `git push` publica de verdade, sem seat pago. O commit author ainda é o dev, mas a Action deploya "prebuilt" sem carregar o git author. |
| **Seat pago (~US$20/mês)** | Acesso total. Caro para projeto finalizado de baixo orçamento. |

## Migração no build

Se o build roda `payload migrate` (via `vercel-build`), a migração aplica em produção
nesse deploy. Ver `docs/migracoes-payload-postgres.md`.
