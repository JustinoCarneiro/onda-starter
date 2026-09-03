"""
Adiciona campos customizados à tela de um tipo de issue via
"Select Field ..." (Project settings > Work items > Types > <tipo>).

IDs de issuetype são globais (mesmos em todos os projetos):
Epic=10000, Story=10007, Task=10008, Sub-task=10009, Bug=10010.

Uso: python3 add_fields.py <PROJECT_KEY> <ISSUETYPE_ID> <campo1> [campo2 ...]
"""
import sys
from jira_ui import connect, get_page


def add_field(page, field_name):
    # widget AUI: input de texto visível + <select> real escondido por trás
    inp = page.locator("#field-picker-field")
    inp.click()
    inp.fill("")
    inp.type(field_name, delay=40)
    page.wait_for_timeout(800)
    page.locator("#field-picker-suggestions li").first.click()
    page.wait_for_timeout(1500)


def main(project_key, issuetype_id, fields):
    pw, browser, context = connect()
    page = get_page(context)
    url = f"https://ondaenterprise.atlassian.net/plugins/servlet/project-config/{project_key}/issuetypes/{issuetype_id}"
    page.goto(url)
    page.wait_for_selector("#field-picker-field", timeout=20000)
    for f in fields:
        print(f"  adicionando campo: {f}")
        try:
            add_field(page, f)
        except Exception as e:
            print(f"    ERRO: {e}")
    page.screenshot(path=f"fields_{project_key}_{issuetype_id}.png", full_page=True)
    pw.stop()


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3:])
