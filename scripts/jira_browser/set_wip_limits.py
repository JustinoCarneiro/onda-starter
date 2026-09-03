"""
Define WIP limit (Max) nas colunas Em Execução (2) e Code Review/Testes (3)
de um board, na tela de Columns.

A ordem das colunas (confirmada via API pros 5 projetos de entrega) é:
Backlog, A Fazer, Em Execução, Base de Conhecimento, Icebox,
Requisitos Não-Funcionais, Code Review/Testes, UAT, Done — 9 colunas reais,
cada uma com 2 inputs (Min, Max) na ordem em que aparecem na página.

Uso: python3 set_wip_limits.py <PROJECT_KEY> <BOARD_ID>
"""
import sys
from jira_ui import connect, get_page

# índice da coluna (0-based, só entre as 9 mapeadas) -> valor de Max
COLUMN_ORDER = [
    "Backlog", "A Fazer", "Em Execução", "Base de Conhecimento", "Icebox",
    "Requisitos Não-Funcionais", "Code Review", "UAT", "Done",
]
LIMITS = {"Em Execução": "2", "Code Review": "3"}


def main(project_key, board_id):
    pw, browser, context = connect()
    page = get_page(context)
    url = f"https://ondaenterprise.atlassian.net/jira/software/c/projects/{project_key}/boards/{board_id}/settings/columns"
    page.goto(url)
    page.wait_for_selector("text=Columns and statuses", timeout=20000)

    none_inputs = page.get_by_placeholder("None")
    count = none_inputs.count()
    print(f"  {count} inputs Min/Max encontrados ({count // 2} colunas)")
    if count != len(COLUMN_ORDER) * 2:
        print(f"  AVISO: esperava {len(COLUMN_ORDER)*2} inputs, achei {count} — ordem pode ter mudado, confira manualmente.")

    for col_name, max_value in LIMITS.items():
        if col_name not in COLUMN_ORDER:
            continue
        idx = COLUMN_ORDER.index(col_name)
        max_input_index = idx * 2 + 1  # Min, Max por coluna
        if max_input_index >= count:
            print(f"  pulei '{col_name}': índice fora do range")
            continue
        none_inputs.nth(max_input_index).fill(max_value)
        page.keyboard.press("Tab")
        page.wait_for_timeout(500)
        print(f"  {col_name}: Max = {max_value}")

    page.screenshot(path=f"wip_{project_key}.png", full_page=True)
    pw.stop()


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
