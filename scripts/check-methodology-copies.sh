#!/usr/bin/env bash
# Detecta cópias não autorizadas da metodologia OndaDev dentro do repositório.
#
# A fonte canônica da metodologia é UM arquivo. Cópias integrais em outros
# lugares geram drift (melhorias não chegam a todos). Projetos derivados devem
# guardar apenas uma referência de versão + adaptações locais (PR-07), nunca o
# texto inteiro.
#
# Heurística determinística: uma frase-marca distinta do playbook não pode
# aparecer fora do arquivo canônico e da allowlist.

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

onda_canonical="docs/Metodologia_de_Desenvolvimento_-_Onda.md"
onda_marker="Playbook de Engenharia"

# Arquivos autorizados a conter a frase-marca.
onda_allow=(
  "$onda_canonical"
  "scripts/check-methodology-copies.sh"
)

[ -f "$onda_canonical" ] || {
  printf '[ERROR] metodologia canônica ausente: %s\n' "$onda_canonical" >&2
  exit 1
}

onda_is_allowed() {
  local f="$1" a
  for a in "${onda_allow[@]}"; do
    [ "$f" = "$a" ] && return 0
  done
  return 1
}

onda_hits=0
while IFS= read -r file; do
  onda_is_allowed "$file" && continue
  if grep -qF "$onda_marker" "$file"; then
    printf '[COPY] %s contém a frase-marca da metodologia ("%s").\n' "$file" "$onda_marker" >&2
    onda_hits=$((onda_hits + 1))
  fi
done < <(git grep -lF "$onda_marker" -- ':!*.pdf' ':!*.docx' 2>/dev/null || true)

if [ "$onda_hits" -gt 0 ]; then
  printf '[ERROR] %s cópia(s) não autorizada(s) da metodologia. Use uma referência de versão, não o texto integral.\n' "$onda_hits" >&2
  exit 1
fi

printf '[OK] metodologia só no arquivo canônico (%s).\n' "$onda_canonical"
