#!/usr/bin/env bash
# Sincronizador determinístico das skills OndaDev.
#
# Fonte canônica : setup/shared/skills/ondadev-*
# Destinos       : .claude/skills/ondadev-*  e  .agents/skills/ondadev-*
# Manifesto      : setup/shared/skills-manifest.sha256
#
# O script não toma nenhuma decisão de conteúdo: apenas copia, normaliza
# permissões e calcula hashes. Toda instrução mora nos arquivos SKILL.md.

set -euo pipefail

onda_repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
onda_canonical_dir="$onda_repo_root/setup/shared/skills"
onda_manifest="$onda_repo_root/setup/shared/skills-manifest.sha256"
onda_destinations=(".claude/skills" ".agents/skills")
onda_mode="write"

onda_usage() {
  cat <<'EOF'
Uso: bash setup/shared/sync-skills.sh [opção]

  (sem opção)   Espelha a fonte canônica nos destinos Claude e Codex e
                regenera o manifesto de hashes. Idempotente.
  --check       Não escreve. Falha (código 1) se algum destino divergir da
                fonte canônica ou se o manifesto estiver desatualizado.
  --manifest    Regenera apenas setup/shared/skills-manifest.sha256.
  -h, --help    Esta ajuda.
EOF
}

onda_fail() {
  printf '[ERROR] %s\n' "$1" >&2
  exit 1
}

# Lista, em ordem estável, os nomes dos diretórios de skill canônicos.
onda_skill_names() {
  find "$onda_canonical_dir" -mindepth 1 -maxdepth 1 -type d -name 'ondadev-*' \
    -printf '%f\n' | LC_ALL=C sort
}

# Calcula o manifesto (hash + caminho relativo a setup/shared) na saída padrão.
onda_compute_manifest() {
  (
    cd "$onda_repo_root/setup/shared"
    find skills -type f | LC_ALL=C sort | while IFS= read -r file; do
      sha256sum "$file"
    done
  )
}

onda_write_manifest() {
  onda_compute_manifest > "$onda_manifest"
  printf '[OK] manifesto regenerado: %s\n' "setup/shared/skills-manifest.sha256"
}

onda_normalize_permissions() {
  local target="$1"
  find "$target" -type d -exec chmod 755 {} +
  find "$target" -type f -exec chmod 644 {} +
}

onda_sync_write() {
  local names dest name src dst
  names="$(onda_skill_names)"
  [ -n "$names" ] || onda_fail "nenhuma skill canônica encontrada em setup/shared/skills"

  for dest in "${onda_destinations[@]}"; do
    mkdir -p "$onda_repo_root/$dest"
    [ -f "$onda_repo_root/$dest/.gitkeep" ] || : > "$onda_repo_root/$dest/.gitkeep"

    # Remove destinos ondadev-* que não existem mais na fonte canônica.
    while IFS= read -r existing; do
      [ -n "$existing" ] || continue
      if ! printf '%s\n' "$names" | grep -qxF "$existing"; then
        rm -rf "${onda_repo_root:?}/$dest/$existing"
        printf '[OK] removido destino órfão: %s/%s\n' "$dest" "$existing"
      fi
    done < <(find "$onda_repo_root/$dest" -mindepth 1 -maxdepth 1 -type d -name 'ondadev-*' -printf '%f\n' | LC_ALL=C sort)

    # Copia cada skill canônica, substituindo o destino por inteiro.
    while IFS= read -r name; do
      [ -n "$name" ] || continue
      src="$onda_canonical_dir/$name"
      dst="$onda_repo_root/$dest/$name"
      rm -rf "$dst"
      cp -R "$src" "$dst"
      onda_normalize_permissions "$dst"
    done <<< "$names"

    printf '[OK] %s sincronizado (%s skills)\n' "$dest" "$(printf '%s\n' "$names" | grep -c .)"
  done

  onda_write_manifest
}

onda_sync_check() {
  local status=0 names dest name expected actual

  names="$(onda_skill_names)"
  [ -n "$names" ] || onda_fail "nenhuma skill canônica encontrada em setup/shared/skills"

  # 1. Manifesto atualizado?
  if [ ! -f "$onda_manifest" ]; then
    printf '[ERROR] manifesto ausente: setup/shared/skills-manifest.sha256\n' >&2
    status=1
  else
    expected="$(cat "$onda_manifest")"
    actual="$(onda_compute_manifest)"
    if [ "$expected" != "$actual" ]; then
      printf '[ERROR] manifesto desatualizado. Rode: bash setup/shared/sync-skills.sh --manifest\n' >&2
      diff <(printf '%s\n' "$expected") <(printf '%s\n' "$actual") >&2 || true
      status=1
    fi
  fi

  # 2. Cada destino é idêntico à fonte canônica?
  for dest in "${onda_destinations[@]}"; do
    while IFS= read -r name; do
      [ -n "$name" ] || continue
      if [ ! -d "$onda_repo_root/$dest/$name" ]; then
        printf '[ERROR] destino ausente: %s/%s\n' "$dest" "$name" >&2
        status=1
        continue
      fi
      if ! diff -r "$onda_canonical_dir/$name" "$onda_repo_root/$dest/$name" >&2; then
        printf '[ERROR] %s/%s difere da fonte canônica\n' "$dest" "$name" >&2
        status=1
      fi
    done <<< "$names"

    # Destinos órfãos?
    while IFS= read -r existing; do
      [ -n "$existing" ] || continue
      if ! printf '%s\n' "$names" | grep -qxF "$existing"; then
        printf '[ERROR] destino órfão em %s: %s\n' "$dest" "$existing" >&2
        status=1
      fi
    done < <(find "$onda_repo_root/$dest" -mindepth 1 -maxdepth 1 -type d -name 'ondadev-*' -printf '%f\n' 2>/dev/null | LC_ALL=C sort)
  done

  # 3. Os dois destinos são idênticos entre si?
  if ! diff -r \
      --exclude='.gitkeep' \
      "$onda_repo_root/${onda_destinations[0]}" \
      "$onda_repo_root/${onda_destinations[1]}" >&2; then
    printf '[ERROR] %s e %s não são idênticos\n' "${onda_destinations[0]}" "${onda_destinations[1]}" >&2
    status=1
  fi

  if [ "$status" -eq 0 ]; then
    printf '[OK] destinos sincronizados e manifesto atualizado.\n'
  fi
  return "$status"
}

case "${1-}" in
  ''|--write) onda_mode="write" ;;
  --check)    onda_mode="check" ;;
  --manifest) onda_mode="manifest" ;;
  -h|--help)  onda_usage; exit 0 ;;
  *)          printf '[ERROR] opção desconhecida: %s\n\n' "$1" >&2; onda_usage >&2; exit 2 ;;
esac

[ -d "$onda_canonical_dir" ] || onda_fail "fonte canônica ausente: setup/shared/skills"

case "$onda_mode" in
  write)    onda_sync_write ;;
  check)    onda_sync_check ;;
  manifest) onda_write_manifest ;;
esac
