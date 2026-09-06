#!/usr/bin/env bash
# Teste de drift das skills OndaDev.
#
#   1. Fonte canônica == destinos Claude/Codex, e manifesto de hashes atualizado
#      (delegado a `sync-skills.sh --check`).
#   2. Os dois destinos são idênticos entre si.
#   3. Nenhum ID de modelo datado sobrou no repositório.

set -euo pipefail

onda_repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
onda_status=0

printf '== 1/2 · sincronização e manifesto ==\n'
if bash "$onda_repo_root/setup/shared/sync-skills.sh" --check; then
  printf '[OK] destinos e manifesto conferem.\n'
else
  printf '[ERROR] drift detectado. Rode: bash setup/shared/sync-skills.sh\n' >&2
  onda_status=1
fi

printf '\n== 2/2 · IDs de modelo datados ==\n'
# Padrões: claude-3-*, claude-2.*, sufixos de data AAAAMMDD conhecidos.
if git -C "$onda_repo_root" grep -nE 'claude-[0-9]|claude-3-|claude-2\.|20240229|20240307|20241022|20240620|20250219' \
    -- ':!setup/tests/skills-drift.sh' ':!setup/tests/skills-frontmatter.sh' ':!setup/shared/sync-skills.sh' >&2; then
  printf '[ERROR] ID de modelo datado encontrado. Use `inherit` ou um alias atual (sonnet, opus, haiku).\n' >&2
  onda_status=1
else
  printf '[OK] nenhum ID de modelo datado no repositório.\n'
fi

printf '\n'
if [ "$onda_status" -eq 0 ]; then
  printf '[OK] skills-drift: tudo verde.\n'
else
  printf '[ERROR] skills-drift: falhou.\n' >&2
fi
exit "$onda_status"
