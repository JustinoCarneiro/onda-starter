"""
Adiciona colunas (com status novo) num board Jira via UI, usando o Chrome
conectado por jira_ui.py. Cada coluna = 1 status novo criado + categoria.

Uso: python3 add_columns.py <PROJECT_KEY> <BOARD_ID>
Edita a lista COLUMNS abaixo pra mudar o que é criado.
"""
import sys
from jira_ui import connect, get_page

COLUMNS = [
    ("📚 Base de Conhecimento (Docs / Memória Técnica)", "To Do"),
    ("❄️ Icebox (Banco de Ideias)", "To Do"),
    ("🏗️ Requisitos Não-Funcionais & Arquitetura", "To Do"),
    ("🔍 Code Review / Testes", "In Progress"),
    ("🧪 UAT (Homologação / Validação do Cliente)", "In Progress"),
]


def add_column(page, name, category):
    page.get_by_test_id(
        "platform-board-kit.ui.column.column-create.button.styled-button"
    ).click()
    page.wait_for_timeout(500)
    name_field = page.get_by_placeholder("Enter a column name")
    name_field.fill(name)
    page.wait_for_timeout(200)

    # o combobox de Category às vezes vem travado (disabled) já com o valor
    # certo pré-selecionado, dependendo de onde o "+" foi clicado — nesse
    # caso não dá pra interagir (nem precisa). Usa timeout curto pra não
    # travar 30s tentando clicar num elemento que nunca vai ficar clicável.
    try:
        cat = page.get_by_role("combobox", name="Category")
        current = cat.inner_text(timeout=2000).strip()
    except Exception:
        current = ""
    if category not in current:
        try:
            page.get_by_role("combobox", name="Category").click(timeout=2000)
            page.wait_for_timeout(300)
            page.get_by_role("option", name=category, exact=True).click(timeout=2000)
            page.wait_for_timeout(300)
        except Exception:
            print(f"  AVISO: não consegui mudar a categoria pra '{category}' (atual: '{current}') — confira manualmente depois")

    page.get_by_role("button", name="Add column", exact=True).click()
    page.wait_for_timeout(1500)


def main(project_key, board_id):
    pw, browser, context = connect()
    page = get_page(context)
    url = f"https://ondaenterprise.atlassian.net/jira/software/c/projects/{project_key}/boards/{board_id}/settings/columns"
    page.goto(url)
    page.wait_for_selector("text=Columns and statuses", timeout=20000)
    for name, category in COLUMNS:
        print(f"criando coluna: {name} [{category}]")
        add_column(page, name, category)
    page.screenshot(path=f"result_{project_key}.png", full_page=True)
    print("feito, screenshot salvo em result_" + project_key + ".png")
    pw.stop()


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
