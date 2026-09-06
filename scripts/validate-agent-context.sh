#!/usr/bin/env bash
# Valida o contrato compartilhado carregado por Codex e Claude Code.

set -e -o pipefail

limit_bytes=32768
root_files=(AGENTS.md CLAUDE.md)
link_files=(
  AGENTS.md
  CLAUDE.md
  docs/product/spec.md
  docs/architecture/adr/README.md
  docs/security/README.md
  docs/security/data-classification.md
)
combined_bytes=0

fail() {
  printf '[ERROR] %s\n' "$1" >&2
  exit 1
}

for file in "${root_files[@]}"; do
  [ -f "$file" ] || fail "arquivo de instrução ausente: $file"
  file_bytes="$(wc -c < "$file")"
  combined_bytes=$((combined_bytes + file_bytes))
done

if [ "$combined_bytes" -gt "$limit_bytes" ]; then
  fail "AGENTS.md + CLAUDE.md usam $combined_bytes bytes; limite é $limit_bytes"
fi

if [ "$(sed -n '1p' CLAUDE.md)" != '@AGENTS.md' ]; then
  fail 'CLAUDE.md deve importar @AGENTS.md na primeira linha'
fi

for file in "${link_files[@]}"; do
  [ -f "$file" ] || fail "arquivo de contexto ausente: $file"

  while IFS= read -r match; do
    target="${match#](}"
    target="${target%%#*}"

    case "$target" in
      ''|'#'*|http://*|https://*|mailto:*|tel:*)
        continue
        ;;
    esac

    [ -e "$(dirname "$file")/$target" ] \
      || fail "link local quebrado em $file: $target"
  done < <(grep -oE '\]\([^ )]+' "$file" || true)
done

# Governança de risco: a matriz R0/R1/R2 canônica vive em AGENTS.md; a
# metodologia aponta para ela e não mantém uma lista paralela que diverge
# (achado da revisão Codex, 2026-09-06).
grep -q 'fonte canônica.*classes de risco\|matriz R0/R1/R2 abaixo é a \*\*fonte canônica\*\*' AGENTS.md \
  || fail 'AGENTS.md: marque a matriz R0/R1/R2 como fonte canônica das classes de risco'

methodology='docs/Metodologia_de_Desenvolvimento_-_Onda.md'
if [ -f "$methodology" ]; then
  risk_block="$(sed -n '/Governança de risco/,/^$/p' "$methodology")"
  printf '%s' "$risk_block" | grep -q 'AGENTS.md' \
    || fail "$methodology: o bloco 'Governança de risco' deve referenciar AGENTS.md (matriz canônica)"
  if printf '%s' "$risk_block" | grep -qE '\*\*R2\*\* \((auth|prod|infra|migraç)'; then
    fail "$methodology: o bloco 'Governança de risco' reenumera exemplos de R2; defira a fronteira a AGENTS.md"
  fi
fi

printf '[OK] contexto raiz: %s bytes (limite: %s)\n' "$combined_bytes" "$limit_bytes"
printf '[OK] CLAUDE.md importa AGENTS.md e os links locais são válidos.\n'
printf '[OK] matriz de risco R0/R1/R2 canônica em AGENTS.md; metodologia defere a fronteira.\n'
