# Worktrees e transferência segura Local ↔ Worktree

Regra operacional do OndaDev 3.0: **um autor por PR, uma conversa, uma
branch/worktree**. Claude e Codex nunca escrevem no mesmo checkout ao mesmo
tempo.

## Papéis

| Ambiente | Quem | Para quê |
| --- | --- | --- |
| **Local** (este checkout) | Claude Code | Projetos com contexto quente; revisão crítica de mudanças do Codex |
| **Worktree** | Codex Desktop | Produção em projeto novo, tarefas longas, trabalho paralelo isolado |

## Criar um worktree

```bash
# a partir do checkout Local, na raiz do repositório
git worktree add ../onda-starter--<tarefa> -b <tipo>/<tarefa>
cd ../onda-starter--<tarefa>
bash setup/worktree-setup.sh
```

- `setup/worktree-setup.sh` é não interativo e idempotente: cria o `.env` a
  partir de `.env.example` (só placeholders) e roda a verificação básica.
- **Uma branch por worktree.** A mesma branch não pode estar em checkout em dois
  worktrees ao mesmo tempo — o Git recusa, e é proposital.
- Nenhum segredo real é copiado para o worktree. Arquivos ignorados
  (`.env`, `.env.jira`, `.codex/auth.json`) não acompanham o worktree.
- Não há `.worktreeinclude` neste starter: nenhum arquivo ignorado não secreto é
  indispensável para trabalhar num worktree novo. Crie um só se isso mudar.

## Transferir trabalho do Worktree para o Local

O worktree compartilha o mesmo repositório Git do Local, então o histórico já
está visível dos dois lados. Para continuar no Local uma tarefa começada no
worktree:

1. **No worktree**, feche a unidade atômica: testes verdes, commit limpo.
   ```bash
   bash setup/worktree-setup.sh --check
   git add -A && git commit -m "<mensagem>"
   ```
2. **Pare o agente do worktree.** Só então libere a escrita ao segundo agente
   (protocolo de failover — detalhado no PR-05).
3. **No Local**, traga a branch:
   ```bash
   git fetch .                     # o worktree já está no mesmo repo
   git switch <tipo>/<tarefa>      # ou: git switch - / git merge
   ```
   Se preferir aplicar só um recorte: `git cherry-pick <sha>`.
4. **Remova o worktree** quando a tarefa sair dele:
   ```bash
   git worktree remove ../onda-starter--<tarefa>
   git worktree prune
   ```

## Transferir do Local para o Worktree

Mesma lógica ao contrário: commite no Local, pare o Claude, e no worktree faça
`git switch <branch>` (a branch não pode estar em uso no Local nesse momento).

## Checklist de segurança

- [ ] Nenhum `.env`, token, `auth.json` ou dump foi copiado para o worktree.
- [ ] A branch está em um único worktree por vez.
- [ ] O primeiro agente parou antes de o segundo começar a escrever.
- [ ] `bash setup/worktree-setup.sh --check` passou dos dois lados.
