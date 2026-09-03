"""
Conexão compartilhada com o Chrome dedicado do Jira (start_browser.sh) via CDP.

Não abre navegador novo nem guarda credencial nenhuma — só controla a aba já
autenticada manualmente pelo usuário. Ver README.md pra contexto completo.
"""
import os
from playwright.sync_api import sync_playwright

JIRA_BASE = "https://ondaenterprise.atlassian.net"
CDP_PORT = os.environ.get("JIRA_CDP_PORT", "9333")
CDP_URL = f"http://localhost:{CDP_PORT}"


def connect():
    """Conecta no Chrome já aberto via start_browser.sh. Levanta erro claro se não achar."""
    pw = sync_playwright().start()
    try:
        browser = pw.chromium.connect_over_cdp(CDP_URL)
    except Exception as e:
        pw.stop()
        raise RuntimeError(
            f"Não consegui conectar no Chrome em {CDP_URL}. "
            f"Rode ./start_browser.sh primeiro e confirme que fez login no Jira. ({e})"
        )
    context = browser.contexts[0] if browser.contexts else browser.new_context()
    return pw, browser, context


def get_page(context):
    """Reusa uma aba já aberta apontando pro Jira, ou abre uma nova."""
    for page in context.pages:
        if JIRA_BASE in page.url:
            return page
    page = context.new_page()
    page.goto(JIRA_BASE)
    return page


def ensure_logged_in(page):
    page.wait_for_load_state("domcontentloaded")
    if "login" in page.url or "id.atlassian.com" in page.url:
        raise RuntimeError(
            "Parece que a sessão não está logada (URL de login detectada). "
            "Faça login manualmente na janela do Chrome dedicado e rode de novo."
        )
