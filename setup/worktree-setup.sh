#!/usr/bin/env bash
# Prepara uma árvore de trabalho (git worktree) recém-criada do onda-starter.
#
# Não interativo e idempotente: pode rodar quantas vezes quiser.
# Não instala ferramentas de sistema (use setup/install.sh para isso).
# Não copia segredo nenhum: o .env é recriado a partir do .env.example.
#
# Uso:
#   bash setup/worktree-setup.sh            # prepara + roda a verificação básica
#   bash setup/worktree-setup.sh --check    # só a verificação básica, sem escrever

set -euo pipefail

onda_check_only=0
case "${1-}" in
  '') ;;
  --check) onda_check_only=1 ;;
  -h|--help)
    sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    printf '[ERROR] opção desconhecida: %s\n' "$1" >&2
    exit 2
    ;;
esac

cd "$(git rev-parse --show-toplevel)"
onda_repo_root="$(pwd)"
printf '[INFO] worktree: %s\n' "$onda_repo_root"

# 1. .env local a partir do exemplo (placeholders, sem segredo).
if [ "$onda_check_only" -eq 0 ]; then
  if [ -f .env ]; then
    printf '[OK] .env já existe; preservado.\n'
  elif [ -f .env.example ]; then
    cp .env.example .env
    printf '[OK] .env criado a partir de .env.example (só placeholders).\n'
  fi
fi

# 2. Verificação básica — as mesmas validações de "Comandos verificados".
onda_step() {
  printf '\n$ %s\n' "$*"
  "$@"
}

# O diagnóstico de ferramentas é consultivo: não bloqueia o preparo do worktree.
printf '\n$ bash setup/check-environment.sh\n'
bash setup/check-environment.sh || printf '[WARN] ambiente incompleto; rode setup/install.sh antes de codificar.\n'

# As validações determinísticas do repositório são obrigatórias.
onda_step bash setup/shared/sync-skills.sh --check
onda_step bash setup/tests/skills-drift.sh
onda_step bash setup/tests/skills-frontmatter.sh
onda_step bash scripts/validate-agent-context.sh

printf '\n[OK] worktree pronto. Uma branch por worktree; nunca a mesma branch em dois.\n'
printf '     Transferência segura Local <-> Worktree: setup/WORKTREE.md\n'
