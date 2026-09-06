# Failover de cota entre agentes — OndaDev 3.0

Quando a janela de uso de um agente acaba, o trabalho continua no outro **sem
reanálise completa do repositório**. Um agente por checkout por vez; o primeiro
para de escrever antes de o segundo começar.

## Monitorar a janela

| Agente | Comando | O que olhar |
| --- | --- | --- |
| Claude Code | `/usage` | % da janela de 5h e do limite semanal |
| Codex | `/status` | janela e limites da assinatura |

Não use a estimativa monetária do Claude Code para decidir consumo — a unidade
é **janela de uso aceita**, não preço por token.

## Limiares operacionais

| Uso da janela | Ação |
| --- | --- |
| **75%** | Rodar `bash scripts/ai-checkpoint.sh`. Commit de checkpoint opcional. Seguir trabalhando. |
| **90%** | Terminar **apenas a unidade atômica** em andamento (teste verde + commit limpo). Não começar módulo novo. |
| **100%** | Handoff completo: `ai-checkpoint.sh`, preencher as seções de raciocínio de `current.md`, **parar**. |

## Artefatos

```text
.ondadev/handoff/TEMPLATE.md   # versionado; estrutura do handoff
.ondadev/handoff/current.md    # ignorado pelo Git; gerado por ai-checkpoint.sh
scripts/ai-checkpoint.sh       # coleta só metadados seguros
```

`ai-checkpoint.sh` preenche automaticamente branch, último commit, `git status`,
`git diff --stat` e o resultado das validações determinísticas. As seções de
objetivo, decisões, próximos passos e riscos são escritas pelo agente. **Nunca**
cole conteúdo de arquivo, diff completo, valor de `.env` ou segredo no handoff.

## Fluxo Claude → Codex

1. Claude: `bash scripts/ai-checkpoint.sh` e preenche `current.md`.
2. Claude: fecha a unidade atômica (`git add -A && git commit`), **para de
   escrever** e sinaliza o handoff.
3. Codex: abre o worktree próprio (`setup/WORKTREE.md`), roda
   `bash setup/worktree-setup.sh`, lê `current.md`.
4. Codex: continua a partir de "Próximo passo concreto" — sem reler o repo
   inteiro. Passa contrato + diff + logs de teste ao revisor, não pede
   reanálise completa.

## Fluxo Codex → Claude

1. Codex: `bash scripts/ai-checkpoint.sh` e preenche `current.md`.
2. Codex: fecha a unidade atômica, commita, **para de escrever**.
3. Claude: `git fetch .` / `git switch <branch>` no checkout Local (a branch não
   pode estar em uso em dois worktrees ao mesmo tempo — ver `setup/WORKTREE.md`).
4. Claude: lê `current.md`, valida com `bash scripts/ai-checkpoint.sh --no-tests`
   ou rodando as validações, e continua do "Próximo passo concreto".

## Regras invioláveis

- **Sem escrita concorrente.** O primeiro agente para antes de o segundo
  escrever. A checkbox "o primeiro agente parou?" em `current.md` é obrigatória.
- **`ANTHROPIC_API_KEY` nunca como fallback automático.** Se estiver definida, o
  Claude Code pode cobrar via API em vez de usar a assinatura. `ai-checkpoint.sh`
  avisa quando detecta a variável. Autenticação é sempre `claude auth login`.
- **Sem segredo no handoff.** `current.md` é ignorado pelo Git justamente para
  não virar canal de vazamento; ainda assim, não escreva segredo nele.
- **Checkpoint commit é opcional; squash antes do merge.** Commits de checkpoint
  (`chore: checkpoint <tarefa>`) podem ser espremidos num histórico limpo antes
  de qualquer merge. Nada de push/merge sem autorização humana.

## Simulação de continuidade (Gate G5)

1. Agente A começa uma tarefa pequena, roda `ai-checkpoint.sh`, para.
2. Agente B abre `current.md` e responde, sem abrir mais nada: qual foi o último
   teste e o resultado, qual a pendência, qual o próximo passo.
3. B executa o próximo passo e fecha. Repetir invertendo A e B.
