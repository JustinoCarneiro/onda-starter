# OndaDev - Checklist de nova máquina

Este checklist acompanha o instalador guiado para Ubuntu/Debian. Ele separa
instalação, autenticação e permissões para evitar mudanças silenciosas na
máquina.

## 1. Revisar antes de instalar

Execute sempre o modo sem escrita primeiro:

~~~bash
bash setup/install.sh --dry-run
~~~

Para instalar tudo em uma máquina nova:

~~~bash
bash setup/install.sh
~~~

Para instalar apenas um componente:

~~~bash
bash setup/install.sh --component node
bash setup/install.sh --component claude
~~~

Componentes aceitos: git, node, docker, gh, claude, skills e all.

O componente `skills` espelha as seis skills canônicas OndaDev
(`setup/shared/skills/`) em `~/.claude/skills/` e, se o Codex CLI estiver
presente, em `~/.agents/skills/`. A fonte canônica é sincronizada para os
destinos do repositório por `bash setup/shared/sync-skills.sh`.

O instalador não autentica contas, não instala extensões do VS Code e não
configura qualquer chave de API.

## 2. Componentes instalados

- [ ] Git
- [ ] Node.js 22 ou superior, pelo nvm
- [ ] Docker Engine pelo repositório apt assinado
- [ ] GitHub CLI pelo repositório oficial
- [ ] Claude Code pelo repositório apt assinado, canal stable
- [ ] Skills OndaDev canônicas espelhadas em `~/.claude/skills/` (e `~/.agents/skills/` com Codex)
- [ ] Comandos e agentes Claude legados, preservando alterações locais por padrão

O instalador não sobrescreve assets legados diferentes em ~/.claude sem a
opção explícita:

~~~bash
bash setup/install.sh --component skills --overwrite-legacy-assets
~~~

Essa compatibilidade é temporária: os comandos legados já foram consolidados nas
seis skills canônicas de `setup/shared/skills/` (PR-03) e carregam aviso de
depreciação. Serão removidos após o piloto (PR-08).

## 3. Docker sem sudo é opt-in

Pertencer ao grupo docker equivale, na prática, a uma permissão privilegiada
na máquina. Por isso, o instalador não altera o grupo por padrão.

Caso você entenda esse impacto e queira usar Docker sem sudo:

~~~bash
bash setup/install.sh --component docker --add-user-to-docker-group
~~~

Depois, encerre e reabra a sessão do sistema.

Se usar Docker Desktop no Linux com o contexto `desktop-linux`, execute Docker
como o seu usuário, sem `sudo`: esse contexto fica em `~/.docker` e o root não
o enxerga. O smoke test reconhece esse cenário automaticamente, mesmo se a
opção `--sudo` for informada.

## 4. Autenticar manualmente

### Claude Code

~~~bash
claude auth login
~~~

Use a conta com assinatura Claude Pro. Não defina ANTHROPIC_API_KEY como
atalho: isso pode fazer o Claude Code usar cobrança de API separada.

### GitHub CLI

~~~bash
gh auth login
~~~

Escolha GitHub.com e login no navegador. Prefira os fluxos de autorização do
gh a criar um Personal Access Token classic amplo. Quando um token for
realmente indispensável, conceda apenas os escopos estritamente necessários e
guarde-o em um gerenciador de senhas.

### Codex

Abra o Codex CLI ou o aplicativo desktop e entre com a conta ChatGPT Plus. O
Codex não precisa de OPENAI_API_KEY para o fluxo normal de assinatura.

## 5. VS Code

- [ ] Instalar ou abrir o VS Code.
- [ ] Confirmar a extensão `anthropic.claude-code`.
- [ ] Confirmar a extensão oficial do Codex `openai.chatgpt`
  ("Codex – OpenAI's coding agent", publisher OpenAI).
- [ ] Abrir um projeto e validar terminal, Git, Claude e Codex.

Ambos os IDs estão versionados em `.vscode/extensions.json` (confirmados no
Marketplace em 2026-09-05, PR-04). O VS Code oferece instalá-los ao abrir o
repositório; pela linha de comando: `code --install-extension openai.chatgpt`.
As tarefas Setup/Lint/Test/Build/Run estão em `.vscode/tasks.json`. O ambiente
local do Codex (`.codex/`) é gerado pelo painel do Codex Desktop — veja
`setup/codex/PROMPT-AMBIENTE-LOCAL.md`.

## 6. Conexão SSH com GitHub

Opcional, mas recomendada para evitar credenciais repetidas:

~~~bash
ssh-keygen -t ed25519 -C "seu-email"
ssh -T git@github.com
~~~

Adicione a chave pública à sua conta GitHub pelo painel de chaves SSH.

## 7. Verificação final

~~~bash
bash setup/check-environment.sh
~~~

O verificador é somente leitura. Ele consulta as versões das ferramentas,
confirma se há autenticação do GitHub CLI sem exibir a conta e reporta apenas a
presença ou ausência de ANTHROPIC_API_KEY, nunca o valor.

Para validar o modo dry-run em um Ubuntu 24.04 limpo, com o repositório montado
somente para leitura:

~~~bash
bash setup/tests/install-smoke.sh
~~~

Se o seu usuário ainda não puder acessar o daemon Docker, a variante explícita
é:

~~~bash
bash setup/tests/install-smoke.sh --sudo
~~~

Resultado esperado neste estágio:

- Git, Node, npm, Docker, gh, Claude Code, Codex CLI e VS Code detectados.
- Node 22 ou superior após o PR-01 ser aplicado numa máquina nova.
- Extensão Claude Code detectada.
- Extensão Codex confirmada posteriormente no PR-04.
- ANTHROPIC_API_KEY ausente, salvo decisão explícita de usar API.

## 8. CI e hooks locais

O CI (`.github/workflows/ci.yml`) roda sem segredos: validações determinísticas
(`scripts/ci-report.sh`), smoke do instalador e secret scanning via pre-commit.
Permissão mínima (`contents: read`); actions de terceiros fixadas por SHA.

Rodar o mesmo conjunto localmente:

~~~bash
bash scripts/ci-report.sh
~~~

Hooks de commit (opcional, recomendado):

~~~bash
pipx install pre-commit   # ou: pip install --user pre-commit
pre-commit install
pre-commit run --all-files
~~~

### Ajustes no GitHub que exigem você (fora do repositório)

- [ ] Habilitar **secret scanning** e **push protection** em Settings → Code security.
- [ ] Proteger `master`: exigir os checks `Validações determinísticas`,
  `Smoke do instalador` e `Secret scanning` antes do merge.
- [ ] Conferir em Settings → Actions que o `GITHUB_TOKEN` tem permissão de
  leitura por padrão (o workflow já declara `contents: read`).

## 9. Referências oficiais

- [Claude Code: instalação e repositório apt assinado](https://code.claude.com/docs/en/setup)
- [Docker Engine: repositório apt](https://docs.docker.com/engine/install/ubuntu/)
- [GitHub CLI: instalação Linux](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)
- [Codex CLI](https://learn.chatgpt.com/pt-BR/docs/codex/cli)
