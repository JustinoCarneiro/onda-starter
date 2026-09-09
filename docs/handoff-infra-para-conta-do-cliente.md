# Playbook — migrar a infra para a conta do cliente (Vercel + Neon + Blob + domínio)

Origem: projeto Heliene Araújo, 05–09/09/2026. No fim do projeto tudo sai das contas do
desenvolvedor e passa para as do cliente.

## O que o "Claim deployment" da Vercel leva

Projeto, deploys, domínio(s), **variáveis de ambiente** e a **integração Neon conectada
ao projeto** (o banco continua acessível, `integration ls --all` no time antigo passa a
dizer "No resources found").

## O que o Claim NÃO leva

- **Blob store que só estava ligado por uma variável `BLOB_READ_WRITE_TOKEN` manual**
  (não "Connected" como recurso de Storage). Ele fica **órfão** no time antigo do dev;
  produção segue lendo dele por token cross-conta até alguém apagar o store. Verificar:
  o token de produção começa com `vercel_blob_rw_<STOREID>_...` — se o `<STOREID>` é de
  um store que ainda está no time do dev, ele não migrou.
- **A ligação com o GitHub** — o projeto novo nasce sem Git conectado ("Connect Git
  Repository" aparece disponível).

## Migrar um Blob store que ficou para trás

1. Na conta do cliente: projeto → aba **Storage** → **Create Database** → **Blob** →
   região igual à do banco (`iad1`) → nome distinto do antigo.
2. **Connect Project** → o projeto → marcar **Production + Preview + Development** e a
   opção **"Add a read-write token env var"**, prefixo `BLOB` (o Payload lê exatamente
   `BLOB_READ_WRITE_TOKEN`).
3. Se avisar que `BLOB_READ_WRITE_TOKEN` já existe → **Override**. Se não deixar
   (variável "Sensitive"): apagar a variável em Settings → Environment Variables e refazer
   o Connect.
4. Copiar os arquivos **preservando o pathname exato** (Payload monta a URL como
   `/api/media/file/<filename>`; nome trocado = imagem quebrada). Os arquivos do store
   antigo são públicos — baixar por
   `https://<hash>.public.blob.vercel-storage.com/<file>` e subir com o SDK
   `@vercel/blob` (o CLI ignora `--add-random-suffix false` — ver
   `memoria-tecnica/bugs/vercel-cli-blob-put-random-suffix-ignorado.md`).
   Enumerar os pathnames pela API do Payload:
   `GET /api/media?limit=500&depth=0` → `filename` + cada `sizes.*.filename`.
5. **Redeploy de produção** (para o deploy novo pegar o token novo).
6. **Só então** apagar o store antigo.

### Cuidados na tela do Blob store

- **Não** clicar em **"Revoke Token"** — o aviso sugere OIDC, que o Payload não usa;
  revogar quebra as imagens.
- `vercel blob empty-store` exige o **RW token daquele** store (não temos mais — foi
  removido das variáveis). `vercel blob delete-store` **recusa** modo não-interativo
  (`dangerous_operation_requires_user`). **Apagar pela tela**: Settings → Delete Store
  (esvazia + apaga num passo).
- O "Transfer Store" nativo só lista **times dos quais você é membro** — não serve para
  passar para a conta pessoal do cliente.

## Deploy depois do handoff

`git push` e `vercel deploy` normais são **bloqueados** (autor de commit não é membro do
time) — ver `docs/deploy-vercel-sem-seat-no-time-do-cliente.md`.

## Rotacionar credenciais que apareceram em tela compartilhada

String de conexão do banco etc.: Neon → **Reset password**; a Vercel atualiza a variável
sozinha; um redeploy. (Decisão do humano — o cliente pode optar por não rotacionar.)

## Backup do código-fonte para o cliente

O Vercel **não é backup**: guarda saída de build, e no plano gratuito deployments antigos
são removidos. Se o repo GitHub e o clone local se perdem, o site roda congelado e
ninguém mais consegue alterá-lo.

```bash
git bundle create <projeto>-AAAAMMDD.bundle --all       # repo completo, git clone-able
git archive --format=zip -o <projeto>-AAAAMMDD-codigo.zip HEAD
# conferir que nenhum .env / .env.jira / PDF-com-credenciais entrou no zip
```

**Nunca excluir o repositório.** Se precisar sair da conta do dev, **transferir**, não
deletar. Entregar junto um leia-me em linguagem não técnica explicando o que são os
arquivos e como um dev futuro retomaria (`git clone <bundle>`, `npm ci`, env vars da
Vercel, `npm run dev`).

## Chamada com controle de tela (cliente não-técnico)

Nunca pedir a senha da conta. Guiar por controle remoto:
- **Google Meet NÃO tem** controle remoto.
- **Zoom / Teams** têm nativo.
- **Chrome Remote Desktop** (`remotedesktop.google.com/support`) — funciona no navegador,
  ~5 min de setup (instala uma extensão, gera código, o dev conecta).

Levar um checklist de uma página para a chamada render 20 min: verificar projeto → env
vars → domínio → Neon na Storage → criar/conectar Blob → (pós-chamada, sozinho) migrar
mídia → validar → apagar store antigo.

## Artefatos de referência

`scripts/deploy.sh`, `scripts/backup-fonte.sh`, `docs/INFRA-CLIENTE.md` no projeto
Heliene.
