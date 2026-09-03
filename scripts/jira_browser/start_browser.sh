#!/usr/bin/env bash
# Abre (ou reabre, após reboot) um Chrome dedicado à automação do Jira, com
# porta de debug remoto e perfil isolado em .browser-profile/ — login
# persiste em disco, não precisa logar de novo a cada vez, só se as cookies
# expirarem. Mesmo padrão do automacao_workana/start_browser.sh.
#
# Os scripts Python (jira_ui.py e afins) se conectam nesse Chrome via CDP
# em vez de abrir uma instância nova — isso é o que permite automatizar sem
# nenhuma credencial do Jira passar por código: você loga manualmente uma
# vez nessa janela, o Playwright só controla o que já está autenticado.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$DIR/.browser-profile"
PORT="${JIRA_CDP_PORT:-9333}"

if curl -s "http://localhost:${PORT}/json/version" > /dev/null 2>&1; then
    echo "Já tem um Chrome respondendo em http://localhost:${PORT} — nada a fazer."
    exit 0
fi

mkdir -p "$PROFILE_DIR"

if [[ "$(uname -s)" == "Darwin" ]]; then
    CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    if [[ ! -x "$CHROME_BIN" ]]; then
        echo "Não achei o Google Chrome em '$CHROME_BIN'. Instale em https://www.google.com/chrome/ ou ajuste o caminho neste script." >&2
        exit 1
    fi
else
    CHROME_BIN="$(command -v google-chrome-stable || command -v google-chrome || true)"
    if [[ -z "$CHROME_BIN" ]]; then
        echo "Não achei google-chrome-stable/google-chrome no PATH. Instale o Google Chrome." >&2
        exit 1
    fi
fi

setsid "$CHROME_BIN" \
    --remote-debugging-port="$PORT" \
    --user-data-dir="$PROFILE_DIR" \
    --no-first-run \
    --no-default-browser-check \
    "https://ondaenterprise.atlassian.net" \
    > "$DIR/chrome.log" 2>&1 < /dev/null &

disown

echo "Chrome dedicado abrindo em http://localhost:${PORT} (perfil: $PROFILE_DIR)."
echo "Se essa é a primeira vez: faça login no Jira nessa janela e deixe aberta."
