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

printf '[OK] contexto raiz: %s bytes (limite: %s)\n' "$combined_bytes" "$limit_bytes"
printf '[OK] CLAUDE.md importa AGENTS.md e os links locais são válidos.\n'
