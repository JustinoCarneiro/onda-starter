#!/usr/bin/env bash
# OndaDev - instalador guiado e idempotente para Ubuntu/Debian.
# Uso: bash setup/install.sh [--check] [--dry-run] [--component NOME]

set -e -o pipefail

onda_dry_run=0
onda_check_only=0
onda_add_docker_group=0
onda_overwrite_legacy_assets=0
onda_components=all
onda_apt_updated=0
onda_script_dir="$(cd "$(dirname "$0")" && pwd)"
onda_nvm_version=v0.40.3
# SHA-256 do install.sh do nvm na tag acima (raw.githubusercontent.com).
# Verificado antes de executar — uma retag/comprometimento da origem que altere
# o conteúdo do script é barrada. Para bumpar a versão: baixar o novo install.sh,
# `sha256sum`, e trocar as duas linhas juntas.
onda_nvm_sha256=2d8359a64a3cb07c02389ad88ceecd43f2fa469c06104f92f98df5b6f315275f
onda_claude_key_fingerprint=31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE
onda_github_key_sha256=6084d5d7bd8e288441e0e94fc6275570895da18e6751f70f057485dc2d1a811b

onda_info() {
  printf '[INFO] %s\n' "$1"
}

onda_ok() {
  printf '[OK] %s\n' "$1"
}

onda_warn() {
  printf '[WARN] %s\n' "$1"
}

onda_die() {
  printf '[ERROR] %s\n' "$1" >&2
  exit 1
}

onda_usage() {
  printf '%s\n' \
    'Uso: bash setup/install.sh [opções]' \
    '' \
    'Opções:' \
    '  --check                         Executa apenas setup/check-environment.sh.' \
    '  --dry-run                       Mostra alterações sem executá-las.' \
    '  --component NOME                Instala apenas: git, node, docker, gh, claude, skills ou all.' \
    '  --add-user-to-docker-group      Autoriza adicionar o usuário atual ao grupo docker.' \
    '  --overwrite-legacy-assets       Sobrescreve commands/agents Claude legados já existentes.' \
    '  -h, --help                       Exibe esta ajuda.' \
    '' \
    'Por padrão, tenta instalar todos os componentes em Ubuntu/Debian.' \
    'O instalador nunca autentica Claude, GitHub ou Codex.'
}

onda_print_command() {
  printf '  +'
  printf ' %q' "$@"
  printf '\n'
}

onda_run() {
  if [ "$onda_dry_run" -eq 1 ]; then
    onda_print_command "$@"
  else
    "$@"
  fi
}

onda_run_root() {
  if [ "$(id -u)" -eq 0 ]; then
    onda_run "$@"
  else
    command -v sudo >/dev/null 2>&1 || onda_die 'sudo é necessário para instalar componentes de sistema.'
    onda_run sudo "$@"
  fi
}

onda_write_root_file() {
  local destination="$1"
  local content="$2"

  if [ "$onda_dry_run" -eq 1 ]; then
    onda_info "criaria $destination com conteúdo de repositório assinado"
    return
  fi

  if [ "$(id -u)" -eq 0 ]; then
    printf '%s\n' "$content" > "$destination"
  else
    printf '%s\n' "$content" | sudo tee "$destination" >/dev/null
  fi
}

onda_load_os_release() {
  [ -r /etc/os-release ] || onda_die 'não foi possível identificar a distribuição Linux.'
  # shellcheck disable=SC1091
  . /etc/os-release

  case "$ID" in
    debian|ubuntu)
      onda_os_id="$ID"
      if [ -n "$UBUNTU_CODENAME" ]; then
        onda_os_codename="$UBUNTU_CODENAME"
      else
        onda_os_codename="$VERSION_CODENAME"
      fi
      ;;
    *)
      onda_die "distribuição não suportada por este instalador: $ID. Use os guias oficiais da sua distribuição."
      ;;
  esac

  [ -n "$onda_os_codename" ] || onda_die 'não foi possível identificar o codinome da distribuição.'
}

onda_ensure_apt() {
  command -v apt-get >/dev/null 2>&1 || onda_die 'apt-get não encontrado; este instalador atende Ubuntu/Debian.'
  onda_load_os_release

  if [ "$onda_apt_updated" -eq 0 ]; then
    onda_run_root apt-get update
    onda_apt_updated=1
  fi
}

onda_install_apt_packages() {
  onda_ensure_apt
  onda_run_root apt-get install -y "$@"
}

onda_ensure_apt_packages() {
  local package
  local missing_packages=()

  for package in "$@"; do
    if [ "$(dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null || true)" != 'installed' ]; then
      missing_packages+=("$package")
    fi
  done

  if [ "${#missing_packages[@]}" -eq 0 ]; then
    onda_info "pacotes do sistema já disponíveis: $*"
    return
  fi

  onda_install_apt_packages "${missing_packages[@]}"
}

onda_download_root() {
  local url="$1"
  local destination="$2"
  onda_run_root curl --fail --show-error --location --proto '=https' --tlsv1.2 "$url" --output "$destination"
}

onda_download_user() {
  local url="$1"
  local destination="$2"

  command -v curl >/dev/null 2>&1 || onda_die 'curl é necessário para baixar este componente.'
  onda_run curl --fail --show-error --location --proto '=https' --tlsv1.2 "$url" --output "$destination"
}

onda_add_component() {
  local component="$1"

  case "$component" in
    git|node|docker|gh|claude|skills)
      ;;
    all)
      onda_components=all
      return
      ;;
    *)
      onda_die "componente inválido: $component"
      ;;
  esac

  if [ "$onda_components" = all ]; then
    onda_components=
  fi

  if [ -z "$onda_components" ]; then
    onda_components="$component"
  else
    onda_components="$onda_components,$component"
  fi
}

onda_has_component() {
  local component="$1"

  if [ "$onda_components" = all ]; then
    return 0
  fi

  case ",$onda_components," in
    *,"$component",*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

onda_node_major() {
  if ! command -v node >/dev/null 2>&1; then
    return
  fi
  node --version 2>/dev/null | sed -n '1s/^v\([0-9][0-9]*\).*/\1/p'
}

onda_install_git() {
  if command -v git >/dev/null 2>&1; then
    onda_ok "git já está instalado"
    return
  fi

  onda_install_apt_packages git
  onda_ok 'git instalado'
}

onda_install_node() {
  local current_major
  current_major="$(onda_node_major)"

  case "$current_major" in
    2[2-9]|[3-9][0-9])
      onda_ok "Node $current_major já atende ao alvo 22+"
      return
      ;;
  esac

  onda_ensure_apt_packages ca-certificates curl

  local onda_nvm_dir
  onda_nvm_dir="$HOME/.nvm"

  if [ ! -s "$onda_nvm_dir/nvm.sh" ]; then
    if [ "$onda_dry_run" -eq 1 ]; then
      onda_info "baixaria nvm $onda_nvm_version para arquivo temporário; nenhuma execução por pipe seria usada"
      onda_print_command curl --fail --show-error --location --proto '=https' --tlsv1.2 "https://raw.githubusercontent.com/nvm-sh/nvm/$onda_nvm_version/install.sh" --output '<arquivo-temporario>'
      onda_info "verificaria o SHA-256 do script baixado ($onda_nvm_sha256) antes de qualquer execução"
      onda_print_command bash '<arquivo-temporario>' --no-use
    else
      local installer_tmp
      installer_tmp="$(mktemp)"
      onda_info "baixando nvm $onda_nvm_version para arquivo temporário; nenhuma execução por pipe será usada"
      onda_download_user "https://raw.githubusercontent.com/nvm-sh/nvm/$onda_nvm_version/install.sh" "$installer_tmp"
      onda_verify_sha256 "$installer_tmp" "$onda_nvm_sha256" "o instalador do nvm $onda_nvm_version"
      onda_run bash "$installer_tmp" --no-use
      rm -f "$installer_tmp"
    fi
  fi

  if [ "$onda_dry_run" -eq 1 ]; then
    onda_print_command source "$onda_nvm_dir/nvm.sh"
    onda_print_command nvm install 22
    onda_print_command nvm alias default 22
    onda_print_command nvm use 22
    return
  fi

  [ -s "$onda_nvm_dir/nvm.sh" ] || onda_die 'nvm não foi instalado corretamente.'
  # shellcheck disable=SC1090
  . "$onda_nvm_dir/nvm.sh"
  nvm install 22
  nvm alias default 22
  nvm use 22
  onda_ok "Node $(node --version) configurado como padrão pelo nvm"
}

onda_install_docker() {
  if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
      onda_ok 'Docker já está instalado e o daemon está acessível'
    elif [ "$(docker context show 2>/dev/null || true)" = 'desktop-linux' ]; then
      onda_warn "Docker Desktop foi detectado, mas não está acessível neste usuário; abra-o ou execute 'docker desktop start' sem sudo"
    else
      onda_warn 'Docker CLI já está instalado, mas o daemon não está acessível; o instalador não substitui uma instalação existente.'
    fi
    return
  fi

  onda_ensure_apt_packages ca-certificates curl
  onda_run_root install -m 0755 -d /etc/apt/keyrings
  onda_run_root install -m 0755 -d /etc/apt/sources.list.d
  onda_download_root "https://download.docker.com/linux/$onda_os_id/gpg" /etc/apt/keyrings/docker.asc
  onda_run_root chmod a+r /etc/apt/keyrings/docker.asc

  onda_write_root_file /etc/apt/sources.list.d/docker.sources "Types: deb
URIs: https://download.docker.com/linux/$onda_os_id
Suites: $onda_os_codename
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc"

  onda_apt_updated=0
  onda_install_apt_packages docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  if [ "$onda_add_docker_group" -eq 1 ]; then
    local target_user
    target_user="$SUDO_USER"
    if [ -z "$target_user" ]; then
      target_user="$USER"
    fi

    if [ -z "$target_user" ] || [ "$target_user" = root ]; then
      onda_warn 'Docker foi instalado, mas nenhum usuário não-root foi identificado para o grupo docker.'
    else
      onda_run_root usermod -aG docker "$target_user"
      onda_warn "faça logout e login antes de usar Docker sem sudo como $target_user"
    fi
  else
    onda_warn 'Docker exige sudo até você executar novamente com --add-user-to-docker-group.'
  fi
}

onda_install_gh() {
  if command -v gh >/dev/null 2>&1; then
    onda_ok 'GitHub CLI já está instalado'
    return
  fi

  onda_ensure_apt_packages ca-certificates curl
  onda_run_root install -m 0755 -d /etc/apt/keyrings
  onda_run_root install -m 0755 -d /etc/apt/sources.list.d
  onda_download_root https://cli.github.com/packages/githubcli-archive-keyring.gpg /etc/apt/keyrings/githubcli-archive-keyring.gpg
  if [ "$onda_dry_run" -eq 1 ]; then
    onda_print_command sha256sum /etc/apt/keyrings/githubcli-archive-keyring.gpg
  else
    onda_verify_sha256 /etc/apt/keyrings/githubcli-archive-keyring.gpg "$onda_github_key_sha256" 'a chave do GitHub CLI'
  fi
  onda_run_root chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

  onda_write_root_file /etc/apt/sources.list.d/github-cli.list "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main"

  onda_apt_updated=0
  onda_install_apt_packages gh
  onda_ok 'GitHub CLI instalado; autenticação continua sendo uma etapa manual'
}

onda_verify_claude_key() {
  local key_file="$1"
  local fingerprint

  fingerprint="$(gpg --show-keys --with-colons "$key_file" 2>/dev/null | awk -F: '$1 == "fpr" {print toupper($10); exit}')"
  if [ "$fingerprint" != "$onda_claude_key_fingerprint" ]; then
    onda_die 'a chave de assinatura do Claude Code não corresponde ao fingerprint oficial esperado.'
  fi
}

onda_verify_sha256() {
  local file_path="$1"
  local expected="$2"
  local label="$3"
  local actual

  actual="$(sha256sum "$file_path" | awk '{print $1}')"
  if [ "$actual" != "$expected" ]; then
    onda_die "o checksum SHA256 de $label não corresponde ao valor oficial esperado."
  fi
}

onda_install_claude() {
  if command -v claude >/dev/null 2>&1; then
    onda_ok 'Claude Code já está instalado'
    return
  fi

  onda_ensure_apt_packages ca-certificates curl gnupg
  onda_run_root install -m 0755 -d /etc/apt/keyrings
  onda_run_root install -m 0755 -d /etc/apt/sources.list.d
  onda_download_root https://downloads.claude.ai/keys/claude-code.asc /etc/apt/keyrings/claude-code.asc

  if [ "$onda_dry_run" -eq 1 ]; then
    onda_print_command gpg --show-keys /etc/apt/keyrings/claude-code.asc
  else
    onda_verify_claude_key /etc/apt/keyrings/claude-code.asc
  fi

  onda_write_root_file /etc/apt/sources.list.d/claude-code.list "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/stable stable main"

  onda_apt_updated=0
  onda_install_apt_packages claude-code
  onda_ok 'Claude Code instalado pelo repositório apt assinado, canal stable'
}

onda_copy_legacy_asset_group() {
  local source_dir="$1"
  local destination_dir="$2"
  local source_file destination_file copied=0

  [ -d "$source_dir" ] || return

  for source_file in "$source_dir"/*.md; do
    [ -f "$source_file" ] || continue
    destination_file="$destination_dir/$(basename "$source_file")"

    if [ -f "$destination_file" ] && cmp -s "$source_file" "$destination_file"; then
      onda_info "$(basename "$source_file") já está sincronizado"
      continue
    fi

    if [ -f "$destination_file" ] && [ "$onda_overwrite_legacy_assets" -ne 1 ]; then
      onda_warn "$(basename "$source_file") difere do destino; preservado. Use --overwrite-legacy-assets para substituir."
      continue
    fi

    onda_run install -D -m 0644 "$source_file" "$destination_file"
    copied=$((copied + 1))
  done

  onda_ok "$copied asset(s) legado(s) do Claude copiado(s) para $destination_dir"
}

onda_install_legacy_claude_assets() {
  local claude_home
  claude_home="$HOME/.claude"

  onda_copy_legacy_asset_group "$onda_script_dir/claude/commands" "$claude_home/commands"
  onda_copy_legacy_asset_group "$onda_script_dir/claude/agents" "$claude_home/agents"
  onda_warn 'Comandos/agents legados: compatibilidade temporária; serão removidos após o piloto (PR-08).'
}

onda_copy_shared_skill_tree() {
  local destination_root="$1"
  local skills_source="$onda_script_dir/shared/skills"
  local skill_dir skill_name copied=0

  [ -d "$skills_source" ] || return

  onda_run mkdir -p "$destination_root"

  for skill_dir in "$skills_source"/ondadev-*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    onda_run rm -rf "$destination_root/$skill_name"
    onda_run cp -R "$skills_source/$skill_name" "$destination_root/$skill_name"
    copied=$((copied + 1))
  done

  onda_ok "$copied skill(s) OndaDev espelhada(s) em $destination_root"
}

onda_install_shared_skills() {
  onda_copy_shared_skill_tree "$HOME/.claude/skills"

  if command -v codex >/dev/null 2>&1; then
    onda_copy_shared_skill_tree "$HOME/.agents/skills"
  else
    onda_info 'Codex CLI não detectado; skills OndaDev não espelhadas em ~/.agents/skills.'
  fi

  onda_info 'Fonte canônica: setup/shared/skills. Verifique com: bash setup/shared/sync-skills.sh --check'
}

onda_check_git_identity() {
  if ! command -v git >/dev/null 2>&1; then
    onda_warn 'Git não está disponível; a identidade será verificada depois da instalação.'
    return
  fi

  if git config --global --get user.name >/dev/null 2>&1 \
    && git config --global --get user.email >/dev/null 2>&1; then
    onda_ok 'identidade global do Git já está configurada'
  else
    onda_warn 'identidade global do Git ausente; configure manualmente antes de criar commits.'
  fi
}

onda_parse_arguments() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --check)
        onda_check_only=1
        ;;
      --dry-run)
        onda_dry_run=1
        ;;
      --component)
        [ "$#" -ge 2 ] || onda_die '--component exige um nome.'
        shift
        onda_add_component "$1"
        ;;
      --add-user-to-docker-group)
        onda_add_docker_group=1
        ;;
      --overwrite-legacy-assets)
        onda_overwrite_legacy_assets=1
        ;;
      -h|--help)
        onda_usage
        exit 0
        ;;
      *)
        onda_die "opção desconhecida: $1"
        ;;
    esac
    shift
  done

  if [ "$onda_check_only" -eq 1 ] && [ "$onda_dry_run" -eq 1 ]; then
    onda_die '--check e --dry-run não podem ser usados juntos.'
  fi
}

onda_main() {
  onda_parse_arguments "$@"

  if [ "$onda_check_only" -eq 1 ]; then
    exec bash "$onda_script_dir/check-environment.sh"
  fi

  printf '%s\n' \
    'OndaDev - instalador guiado do ambiente' \
    'Apenas Ubuntu/Debian. Use --dry-run para revisar as mudanças antes de instalar.' \
    ''

  if [ "$onda_dry_run" -eq 1 ]; then
    onda_warn 'modo dry-run: nenhum comando ou arquivo será modificado.'
  fi

  if onda_has_component git; then
    onda_install_git
  fi
  if onda_has_component node; then
    onda_install_node
  fi
  if onda_has_component docker; then
    onda_install_docker
  fi
  if onda_has_component gh; then
    onda_install_gh
  fi
  if onda_has_component claude; then
    onda_install_claude
  fi
  if onda_has_component skills; then
    onda_install_shared_skills
    onda_install_legacy_claude_assets
  fi

  onda_check_git_identity

  printf '%s\n' \
    '' \
    'Próximos passos manuais:' \
    '  1. bash setup/check-environment.sh' \
    '  2. claude auth login' \
    '  3. gh auth login' \
    '  4. Abra o VS Code e instale/confirme a extensão oficial do Codex no PR-04.' \
    '' \
    'O instalador não autentica contas, não instala a extensão do VS Code e não configura API paga.'
}

onda_main "$@"
