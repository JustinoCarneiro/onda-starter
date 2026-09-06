#!/usr/bin/env bash
# Roda todas as validações determinísticas do OndaDev e imprime um relatório
# legível ao final. Código de saída != 0 se qualquer verificação falhar.
# É o mesmo comando usado localmente e pelo CI.

set -uo pipefail

cd "$(git rev-parse --show-toplevel)"

onda_names=()
onda_results=()
onda_details=()
onda_failed=0

run() {
  local name="$1"; shift
  local out rc
  out="$("$@" 2>&1)" && rc=0 || rc=$?
  onda_names+=("$name")
  if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q '^\[SKIP\]'; then
    onda_results+=("skip")
    onda_details+=("$(printf '%s\n' "$out" | grep '^\[SKIP\]' | head -n 1)")
  elif [ "$rc" -eq 0 ]; then
    onda_results+=("ok")
    onda_details+=("")
  else
    onda_results+=("fail")
    onda_details+=("$(printf '%s\n' "$out" | grep -E '^\[(ERROR|BROKEN|COPY|FAIL)' | head -n 8)")
    onda_failed=$((onda_failed + 1))
  fi
}

run_shell_syntax() {
  local f
  while IFS= read -r f; do
    bash -n "$f" || return 1
  done < <(git ls-files '*.sh')
}

run_shellcheck() {
  command -v shellcheck >/dev/null 2>&1 || { echo "[SKIP] shellcheck não instalado"; return 0; }
  git ls-files '*.sh' | xargs -r shellcheck -S warning
}

run_compose_config() {
  docker compose version >/dev/null 2>&1 || { echo "[SKIP] docker compose não disponível"; return 0; }
  docker compose config -q
}

# --- verificações -----------------------------------------------------------
run "shell: bash -n"                 run_shell_syntax
run "shell: shellcheck"              run_shellcheck
run "docker compose config"         run_compose_config
run "contexto raiz (AGENTS/CLAUDE)"  bash scripts/validate-agent-context.sh
run "links markdown"                 bash scripts/check-markdown-links.sh
run "metodologia sem cópia"          bash scripts/check-methodology-copies.sh
run "skills: sincronização"          bash setup/shared/sync-skills.sh --check
run "skills: drift + IDs de modelo"  bash setup/tests/skills-drift.sh
run "skills: frontmatter/ativação"   bash setup/tests/skills-frontmatter.sh

# --- relatório ------------------------------------------------------------
printf '\n== OndaDev CI — relatório ==\n'
i=0
while [ "$i" -lt "${#onda_names[@]}" ]; do
  case "${onda_results[$i]}" in
    ok)
      printf '  PASS  %s\n' "${onda_names[$i]}"
      ;;
    skip)
      printf '  SKIP  %s  (%s)\n' "${onda_names[$i]}" "${onda_details[$i]}"
      ;;
    *)
      printf '  FAIL  %s\n' "${onda_names[$i]}"
      [ -n "${onda_details[$i]}" ] && printf '%s\n' "${onda_details[$i]}" | sed 's/^/          /'
      ;;
  esac
  i=$((i + 1))
done

printf '\n'
if [ "$onda_failed" -gt 0 ]; then
  printf '%s de %s verificações falharam. Corrija os itens FAIL acima.\n' \
    "$onda_failed" "${#onda_names[@]}" >&2
  exit 1
fi
printf 'Todas as %s verificações passaram.\n' "${#onda_names[@]}"
