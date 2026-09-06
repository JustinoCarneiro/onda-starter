#!/usr/bin/env bash
# Smoke test do instalador em Ubuntu limpo, sem escrita no repositório montado.

set -e -o pipefail

onda_repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
onda_use_sudo=0
onda_docker_context=''

case "$1" in
  '')
    ;;
  --sudo)
    onda_use_sudo=1
    ;;
  -h|--help)
    printf 'Uso: bash setup/tests/install-smoke.sh [--sudo]\n'
    exit 0
    ;;
  *)
    printf '[ERROR] Opção desconhecida: %s\n' "$1" >&2
    exit 2
    ;;
esac

if ! command -v docker >/dev/null 2>&1; then
  printf '[ERROR] Docker é necessário para o smoke test.\n' >&2
  exit 2
fi

onda_docker_context="$(docker context show 2>/dev/null || true)"

# O contexto Docker Desktop pertence ao usuário logado. Usar sudo nesse caso
# troca para a configuração do root, que normalmente não conhece desktop-linux.
if [ "$onda_use_sudo" -eq 1 ] && [ "$onda_docker_context" = 'desktop-linux' ]; then
  printf '[INFO] Contexto Docker Desktop detectado; o smoke test usará Docker sem sudo.\n'
  onda_use_sudo=0
fi

onda_docker() {
  if [ "$onda_use_sudo" -eq 1 ]; then
    sudo docker "$@"
  else
    docker "$@"
  fi
}

if ! onda_docker info >/dev/null 2>&1; then
  if [ "$onda_docker_context" = 'desktop-linux' ]; then
    printf "%s\\n" "[ERROR] Docker Desktop não está acessível neste usuário. Abra-o ou execute 'docker desktop start'; não use sudo neste contexto." >&2
  else
    printf '[ERROR] Docker não está disponível. Inicie o daemon, entre no grupo docker ou execute novamente com --sudo.\n' >&2
  fi
  exit 2
fi

# O corpo do bash -lc roda DENTRO do container: as variáveis ($HOME, $before…)
# devem expandir lá, não no host — aspas simples são de propósito.
# shellcheck disable=SC2016
onda_docker run --rm \
  --mount "type=bind,src=$onda_repo_root,dst=/workspace,readonly" \
  --workdir /workspace \
  ubuntu:24.04 \
  bash -lc '
    set -e

    # 1. Contrato do --dry-run: não escreve nada, e o roteiro previsto está lá.
    bash setup/install.sh --help >/dev/null
    bash setup/install.sh --dry-run >/tmp/ondadev-install.out
    grep -F "[WARN] modo dry-run: nenhum comando ou arquivo será modificado." /tmp/ondadev-install.out
    grep -F "nvm install 22" /tmp/ondadev-install.out
    grep -F "verificaria o SHA-256 do script baixado" /tmp/ondadev-install.out
    grep -F "O instalador não autentica contas" /tmp/ondadev-install.out

    # 2. Caminho real de instalação de skills num HOME limpo. Não toca o
    #    repositório (montado readonly): as skills vão para ~/.claude/skills.
    #    ~/.agents/skills só é espelhado quando há Codex CLI — ausente neste
    #    container, então o instalador anuncia que pulou.
    export HOME=/tmp/ondadev-home
    mkdir -p "$HOME"
    bash setup/install.sh --component skills >/tmp/ondadev-skills.out
    test -f "$HOME/.claude/skills/ondadev-build/SKILL.md"
    test -f "$HOME/.claude/skills/ondadev-discovery/SKILL.md"
    grep -F "Codex CLI não detectado" /tmp/ondadev-skills.out
    grep -F "asset(s) legado(s) do Claude copiado(s)" /tmp/ondadev-skills.out

    # 3. Idempotência: rodar de novo deixa a árvore de skills byte a byte igual.
    before="$(find "$HOME/.claude/skills" -type f -exec sha256sum {} + | sort)"
    bash setup/install.sh --component skills >/dev/null
    after="$(find "$HOME/.claude/skills" -type f -exec sha256sum {} + | sort)"
    test "$before" = "$after"
  '

printf '[OK] smoke test do instalador concluído em Ubuntu 24.04 (dry-run + install real de skills + idempotência).\n'
