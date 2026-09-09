---
tipo: bug
data: 2026-09-09
severidade: Alta
status: Resolvido (workaround) — ver playbook
origem: projeto Heliene Araújo
---

# Deploy Vercel preso em UNKNOWN sem log = autor do commit não é membro do time

## Sintoma
Depois de migrar o projeto para o time Vercel do cliente (via Claim), `vercel deploy` (ou
`git push` com Git conectado) cria um deployment que fica **`UNKNOWN` indefinidamente,
sem nenhuma linha de log de build**. O botão "Redeploy" do painel e `vercel redeploy`
falham com *"The provided GitHub repository can't be found"*.

## Causa raiz
1. A Vercel atribui o deploy ao **autor do commit** lido do `.git` local. Se esse autor
   (o desenvolvedor) **não é membro do time do cliente**, o build é **bloqueado**:
   `readyState: BLOCKED`, `seatBlock.blockCode: TEAM_ACCESS_REQUIRED`. O motivo só
   aparece em `GET /v13/deployments/<id>` no campo `readyStateReason`
   (*"...the commit author doesn't have permission to create deployments for this
   project"*) — **não** nos logs, **não** no `vercel inspect` (que só mostra
   `status UNKNOWN`).
2. `vercel redeploy` e o "Redeploy" do painel reusam a origem Git do deployment antigo;
   como o projeto perdeu a ligação com o GitHub no Claim, falham antes de tentar o build.
3. Plano **gratuito de time** do Vercel não deixa adicionar membro (paywall). Conta
   pessoal Hobby não tem "membro".

## Solução
Publicar de uma cópia **sem `.git`** (sem histórico → sem autor de commit → deploy
atribuído à dona do token):

```bash
TMP=$(mktemp -d)
git archive --format=tar HEAD | tar -x -C "$TMP"
mkdir -p "$TMP/.vercel" && cp .vercel/project.json "$TMP/.vercel/"
cd "$TMP"
vercel deploy --prod --yes --archive=tgz --token="$TOKEN" --scope="$TIME"
```

- **`--archive=tgz` é obrigatório**: sem ele o upload arquivo-a-arquivo pendura e o
  deployment nasce `UNKNOWN` (mesmo sintoma, causa diferente).
- `$TOKEN` = Access Token que o cliente gera em Account Settings → Tokens, escopo do time.
- Solução definitiva: mover o projeto para a **conta pessoal Hobby** do cliente (sem
  "membro", a regra não se aplica), ou seat pago, ou uma GitHub Action no repo do dev
  que roda `vercel deploy` com o token como secret (aí `git push` publica).

## Ligado a
- [[deploy-vercel-sem-seat-no-time-do-cliente]]
- [[vercel-token-shell-vaza-pro-deploy]]
