#!/usr/bin/env bash
# Valida a ativação (explícita e implícita) das skills OndaDev canônicas.
#
# Ativação explícita  -> frontmatter tem `name` válido, igual ao diretório.
# Ativação implícita  -> frontmatter tem `description` com gatilho de uso.
# Nenhum ID de modelo datado pode aparecer no SKILL.md.

set -euo pipefail

onda_repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
onda_skills_dir="$onda_repo_root/setup/shared/skills"
onda_expected=(ondadev-discovery ondadev-spec ondadev-experience ondadev-blueprint ondadev-build ondadev-release)
onda_desc_min=40
onda_desc_max=1024
onda_failures=0

onda_err() {
  printf '[ERROR] %s\n' "$1" >&2
  onda_failures=$((onda_failures + 1))
}

# Extrai o valor de um campo escalar (plano ou bloco dobrado >- / |) do
# frontmatter YAML de um arquivo markdown.
onda_frontmatter_field() {
  local file="$1" key="$2"
  awk -v key="$key" '
    function trim(s,  t){ t=s; gsub(/^[[:space:]]+/,"",t); gsub(/[[:space:]]+$/,"",t); return t }
    BEGIN { fm=0; c=0; grab=0; val="" }
    /^---[[:space:]]*$/ {
      c++
      if (c==1) { fm=1; next }
      if (c>=2) { if (grab) print trim(val); exit }
    }
    fm==1 && grab==1 {
      if ($0 ~ /^[[:space:]]+[^[:space:]]/) { l=$0; sub(/^[[:space:]]+/,"",l); val=(val==""?l:val" " l); next }
      print trim(val); exit
    }
    fm==1 {
      if ($0 ~ "^" key ":[[:space:]]*") {
        r=$0; sub("^" key ":[[:space:]]*","",r)
        if (r ~ /^[>|]-?[[:space:]]*$/ || r=="") { grab=1; val=""; next }
        print trim(r); exit
      }
    }
  ' "$file"
}

onda_body_nonempty() {
  # Há conteúdo não vazio depois do segundo delimitador `---`?
  awk '
    BEGIN { c=0 }
    /^---[[:space:]]*$/ { c++; next }
    c>=2 && $0 ~ /[^[:space:]]/ { print "yes"; exit }
  ' "$1"
}

[ -d "$onda_skills_dir" ] || { printf '[ERROR] ausente: setup/shared/skills\n' >&2; exit 1; }

# Conjunto de skills: exatamente as seis esperadas, sem sobras nem faltas.
mapfile -t onda_found < <(find "$onda_skills_dir" -mindepth 1 -maxdepth 1 -type d -name 'ondadev-*' -printf '%f\n' | LC_ALL=C sort)
onda_expected_sorted="$(printf '%s\n' "${onda_expected[@]}" | LC_ALL=C sort)"
onda_found_joined="$(printf '%s\n' "${onda_found[@]}")"
if [ "$onda_expected_sorted" != "$onda_found_joined" ]; then
  onda_err "conjunto de skills diferente do esperado"
  diff <(printf '%s\n' "$onda_expected_sorted") <(printf '%s\n' "$onda_found_joined") >&2 || true
fi

for name in "${onda_found[@]}"; do
  skill_md="$onda_skills_dir/$name/SKILL.md"

  [ -f "$skill_md" ] || { onda_err "$name: SKILL.md ausente"; continue; }

  if [ "$(sed -n '1p' "$skill_md")" != '---' ]; then
    onda_err "$name: SKILL.md não começa com frontmatter '---'"
    continue
  fi
  if [ "$(grep -c '^---[[:space:]]*$' "$skill_md")" -lt 2 ]; then
    onda_err "$name: frontmatter não fechado com '---'"
    continue
  fi

  fm_name="$(onda_frontmatter_field "$skill_md" name)"
  fm_desc="$(onda_frontmatter_field "$skill_md" description)"

  # Ativação explícita.
  if [ -z "$fm_name" ]; then
    onda_err "$name: campo 'name' ausente no frontmatter"
  elif [ "$fm_name" != "$name" ]; then
    onda_err "$name: 'name' ($fm_name) != nome do diretório"
  elif ! printf '%s' "$fm_name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    onda_err "$name: 'name' fora do padrão ^[a-z0-9-]+$"
  fi

  # Ativação implícita.
  if [ -z "$fm_desc" ]; then
    onda_err "$name: campo 'description' ausente no frontmatter"
  else
    desc_len=${#fm_desc}
    if [ "$desc_len" -lt "$onda_desc_min" ]; then
      onda_err "$name: 'description' curta demais ($desc_len < $onda_desc_min)"
    fi
    if [ "$desc_len" -gt "$onda_desc_max" ]; then
      onda_err "$name: 'description' longa demais ($desc_len > $onda_desc_max)"
    fi
    if ! printf '%s' "$fm_desc" | grep -qiE '(^|[^a-z])use |quando|fase [0-9]'; then
      onda_err "$name: 'description' sem gatilho de uso (\"Use ...\", \"quando ...\" ou \"Fase N\")"
    fi
  fi

  # Corpo com instruções.
  if [ "$(onda_body_nonempty "$skill_md")" != "yes" ]; then
    onda_err "$name: SKILL.md sem corpo depois do frontmatter"
  fi

  # Sem ID de modelo datado.
  if grep -nE 'claude-[0-9]|20240229|20240307|20241022|claude-3-|claude-2\.' "$skill_md" >&2; then
    onda_err "$name: ID de modelo datado no SKILL.md"
  fi

  [ "$onda_failures" -eq 0 ] && printf '[OK] %s\n' "$name"
done

if [ "$onda_failures" -gt 0 ]; then
  printf '[ERROR] %s verificação(ões) de frontmatter falharam.\n' "$onda_failures" >&2
  exit 1
fi

printf '[OK] %s skills com ativação explícita e implícita válidas.\n' "${#onda_found[@]}"
