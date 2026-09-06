#!/usr/bin/env bash
# Verifica links relativos quebrados em todos os arquivos Markdown versionados.
# Ignora http(s)/mailto/tel e âncoras puras (#secao). Determinístico.

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

onda_broken=0
onda_files=0

while IFS= read -r file; do
  onda_files=$((onda_files + 1))
  dir="$(dirname "$file")"

  while IFS= read -r match; do
    target="${match#](}"
    target="${target%%#*}"          # tira âncora
    target="${target%% *}"          # tira ' "title"'
    target="${target%\"}"

    case "$target" in
      ''|'#'*|http://*|https://*|mailto:*|tel:*)
        continue
        ;;
    esac

    if [ ! -e "$dir/$target" ]; then
      printf '[BROKEN] %s -> %s\n' "$file" "$target" >&2
      onda_broken=$((onda_broken + 1))
    fi
  done < <(grep -oE '\]\([^ )]+' "$file" || true)
done < <(git ls-files '*.md')

if [ "$onda_broken" -gt 0 ]; then
  printf '[ERROR] %s link(s) relativo(s) quebrado(s) em %s arquivo(s) Markdown.\n' "$onda_broken" "$onda_files" >&2
  exit 1
fi

printf '[OK] %s arquivos Markdown, nenhum link relativo quebrado.\n' "$onda_files"
