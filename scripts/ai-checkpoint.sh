#!/usr/bin/env bash
# Checkpoint de handoff entre agentes (OndaDev 3.0).
#
# Coleta SOMENTE metadados seguros e preenche .ondadev/handoff/current.md a
# partir de .ondadev/handoff/TEMPLATE.md:
#   - branch, último commit, ahead/behind
#   - git status --short e git diff --stat (nomes e números, nunca o conteúdo)
#   - resultado das validações determinísticas do repositório
#
# NÃO lê conteúdo de arquivo, NÃO gera diff completo (patch), NÃO imprime valor
# de variável de ambiente. Determinístico: nenhuma decisão mora aqui.
#
# Uso:
#   bash scripts/ai-checkpoint.sh              # escreve .ondadev/handoff/current.md
#   bash scripts/ai-checkpoint.sh --stdout     # imprime, não escreve
#   bash scripts/ai-checkpoint.sh --no-tests   # não roda as validações
#   bash scripts/ai-checkpoint.sh -h

set -euo pipefail

onda_run_tests=1
onda_to_stdout=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --stdout) onda_to_stdout=1 ;;
    --no-tests) onda_run_tests=0 ;;
    -h|--help)
      sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      printf '[ERROR] opção desconhecida: %s\n' "$1" >&2
      exit 2
      ;;
  esac
  shift
done

cd "$(git rev-parse --show-toplevel)"
onda_template=".ondadev/handoff/TEMPLATE.md"
onda_current=".ondadev/handoff/current.md"
[ -f "$onda_template" ] || { printf '[ERROR] ausente: %s\n' "$onda_template" >&2; exit 1; }

onda_tmp="$(mktemp -d)"
trap 'rm -rf "$onda_tmp"' EXIT

# --- metadados de git (só porcelanas seguras) -------------------------------
onda_date="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
onda_branch="$(git branch --show-current 2>/dev/null || echo '(detached)')"
onda_commit="$(git log -1 --format='%h %s (%cI)' 2>/dev/null || echo '(sem commits)')"

onda_track='sem upstream configurado'
if git rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
  read -r behind ahead < <(git rev-list --left-right --count '@{u}...HEAD' 2>/dev/null || echo '0 0')
  onda_track="ahead ${ahead:-0} / behind ${behind:-0} vs $(git rev-parse --abbrev-ref '@{u}')"
fi

{
  echo '```text'
  echo "# git status --short"
  git status --short || true
  echo
  echo "# git diff --stat (working tree)"
  git diff --stat || true
  echo
  echo "# git diff --cached --stat (staged)"
  git diff --cached --stat || true
  echo
  echo "# git worktree list"
  git worktree list || true
  echo '```'
} > "$onda_tmp/status.md"

# --- validações determinísticas -------------------------------------------
onda_run_check() {
  local label="$1"; shift
  local out rc
  out="$("$@" 2>&1)" && rc=0 || rc=$?
  if [ "$rc" -eq 0 ]; then
    printf '| %s | ✅ PASS | |\n' "$label"
  else
    printf '| %s | ❌ FAIL | %s |\n' "$label" "$(printf '%s\n' "$out" | tail -n1 | tr '|' '/')"
  fi
}

{
  echo "| Validação | Resultado | Nota |"
  echo "| --- | --- | --- |"
  if [ "$onda_run_tests" -eq 1 ]; then
    onda_run_check 'sync-skills.sh --check'        bash setup/shared/sync-skills.sh --check
    onda_run_check 'skills-drift.sh'               bash setup/tests/skills-drift.sh
    onda_run_check 'skills-frontmatter.sh'         bash setup/tests/skills-frontmatter.sh
    onda_run_check 'validate-agent-context.sh'     bash scripts/validate-agent-context.sh
  else
    echo "| (validações puladas: --no-tests) | — | rode sem --no-tests |"
  fi
} > "$onda_tmp/tests.md"

# --- aviso de cobrança por API ------------------------------------------------
onda_apikey_note=''
if [ -n "${ANTHROPIC_API_KEY-}" ]; then
  onda_apikey_note='> ⚠️ ANTHROPIC_API_KEY está DEFINIDA no ambiente. Não use como fallback automático de cota — o Claude Code pode cobrar via API. Ver .ondadev/README.md.'
fi

# --- montar current.md a partir do template --------------------------------
awk -v date="$onda_date" -v branch="$onda_branch" -v commit="$onda_commit" \
    -v track="$onda_track" -v apikey="$onda_apikey_note" \
    -v statusfile="$onda_tmp/status.md" -v testsfile="$onda_tmp/tests.md" '
  function dump(f,  l){ while ((getline l < f) > 0) print l; close(f) }
  NR==1 && apikey!="" { print apikey; print "" }
  /\*\*Data \(UTC\):\*\* <preenchido pelo script>/ {
    print "- **Data (UTC):** " date; next }
  /\*\*Branch:\*\* <preenchido pelo script>/ {
    print "- **Branch:** " branch "  ·  " track; next }
  /\*\*Último commit:\*\* <preenchido pelo script>/ {
    print "- **Último commit:** " commit; next }
  /<preenchido pelo script: git status/ { dump(statusfile); next }
  /<preenchido pelo script: tabela de validações/ { dump(testsfile); next }
  { print }
' "$onda_template" > "$onda_tmp/current.md"

if [ "$onda_to_stdout" -eq 1 ]; then
  cat "$onda_tmp/current.md"
else
  mkdir -p "$(dirname "$onda_current")"
  cp "$onda_tmp/current.md" "$onda_current"
  printf '[OK] %s atualizado (%s).\n' "$onda_current" "$onda_date"
  printf '     Preencha as seções de raciocínio (objetivo, decisões, próximos passos, riscos).\n'
fi
