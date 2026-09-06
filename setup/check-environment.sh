#!/usr/bin/env bash
# OndaDev - verificação somente leitura do ambiente local.
# Uso: bash setup/check-environment.sh

set -u -o pipefail

missing=0
warnings=0

ok() {
  printf '[OK] %s\n' "$1"
}

warn() {
  printf '[WARN] %s\n' "$1"
  warnings=$((warnings + 1))
}

absent() {
  printf '[MISSING] %s\n' "$1"
  missing=$((missing + 1))
}

usage() {
  cat <<'EOF'
Uso: bash setup/check-environment.sh

Consulta ferramentas e estados de configuração sem modificar a máquina.
Retorna 0 quando todas as ferramentas mínimas estão disponíveis e 1 quando
alguma estiver ausente.
EOF
}

check_tool() {
  local binary="$1"
  shift

  if ! command -v "$binary" >/dev/null 2>&1; then
    absent "$binary não encontrado"
    return
  fi

  local version
  version="$("$@" 2>&1 | sed -n '1p')"
  if [ -n "$version" ]; then
    ok "$binary: $version"
  else
    warn "$binary foi encontrado, mas não retornou versão"
  fi
}

check_node() {
  if ! command -v node >/dev/null 2>&1; then
    absent "node não encontrado"
    return
  fi

  local version major
  version="$(node --version 2>&1 | sed -n '1p')"
  major="${version#v}"
  major="${major%%.*}"

  if [ -z "$version" ]; then
    warn "node foi encontrado, mas não retornou versão"
    return
  fi

  ok "node: $version"

  case "$major" in
    ''|*[!0-9]*)
      warn "não foi possível identificar a versão principal do Node"
      ;;
    0|1[0-9])
      warn "Node abaixo de 20; o PR-01 exigirá Node 22 ou superior"
      ;;
    20|21)
      warn "Node abaixo do alvo do OndaDev 3.0; o PR-01 elevará o baseline para 22+"
      ;;
    *)
      ok "Node atende ao alvo futuro de 22+"
      ;;
  esac
}

check_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    absent "docker não encontrado"
    return
  fi

  check_tool docker docker --version

  if docker info >/dev/null 2>&1; then
    ok "daemon Docker acessível no contexto atual"
  elif [ "$(docker context show 2>/dev/null || true)" = 'desktop-linux' ]; then
    warn "Docker Desktop foi detectado, mas o daemon não está acessível neste usuário; abra-o ou execute 'docker desktop start' sem sudo"
  else
    warn "Docker CLI encontrado, mas o daemon não está acessível; inicie-o ou use sudo quando apropriado"
  fi
}

check_git_identity() {
  if ! command -v git >/dev/null 2>&1; then
    return
  fi

  if git config --global --get user.name >/dev/null 2>&1 \
    && git config --global --get user.email >/dev/null 2>&1; then
    ok "identidade global do Git configurada"
  else
    warn "identidade global do Git incompleta; configure antes de criar commits"
  fi
}

check_github_auth() {
  if ! command -v gh >/dev/null 2>&1; then
    return
  fi

  if gh auth status >/dev/null 2>&1; then
    ok "GitHub CLI autenticado"
  else
    warn "GitHub CLI sem autenticação confirmada; execute 'gh auth login' quando precisar de acesso remoto"
  fi
}

check_vscode_extensions() {
  if ! command -v code >/dev/null 2>&1; then
    return
  fi

  local extensions codex_matches
  extensions="$(code --list-extensions 2>/dev/null || true)"

  if printf '%s\n' "$extensions" | grep -Fxq 'anthropic.claude-code'; then
    ok "extensão VS Code Claude Code detectada"
  else
    warn "extensão VS Code Claude Code não detectada"
  fi

  codex_matches="$(printf '%s\n' "$extensions" | grep -Ei '(^openai\.|codex)' || true)"
  if [ -n "$codex_matches" ]; then
    ok "extensão VS Code relacionada a OpenAI/Codex detectada"
  else
    warn "nenhuma extensão VS Code relacionada a OpenAI/Codex foi detectada; confirmar no PR-04"
  fi
}

check_anthropic_billing_mode() {
  if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
    warn "ANTHROPIC_API_KEY está definida; Claude Code pode usar cobrança de API separada"
  else
    ok "ANTHROPIC_API_KEY não está definida"
  fi
}

main() {
  case "${1:-}" in
    '' ) ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac

  printf 'OndaDev - verificação somente leitura do ambiente\n\n'

  check_tool git git --version
  check_node
  check_tool npm npm --version
  check_docker
  check_tool gh gh --version
  check_tool claude claude --version
  check_tool codex codex --version
  check_tool code code --version

  printf '\n'
  check_git_identity
  check_github_auth
  check_vscode_extensions
  check_anthropic_billing_mode

  printf '\nResumo: %s ferramenta(s) ausente(s), %s aviso(s).\n' "$missing" "$warnings"

  if [ "$missing" -gt 0 ]; then
    exit 1
  fi
}

main "$@"
