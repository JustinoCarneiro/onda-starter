"""
Aplica uma das 6 cores sólidas pré-definidas como fundo de um espaço, via
menu de contexto na barra lateral (hover no item de nav "..." > Set space
background > cor sólida).

Só existem 6 cores fixas (sem hex customizado): cinza, lavanda, azul, ciano,
verde, rosa — nenhuma bate exato com a paleta da marca, mapeado por família
de matiz mais próxima.

Uso: python3 set_background.py <PROJECT_KEY> <BOARD_ID> <SWATCH_INDEX 0-5>
0=cinza 1=lavanda 2=azul 3=ciano 4=verde 5=rosa
"""
import sys
from jira_ui import connect, get_page

SWATCH_X = [612, 646, 680, 714, 748, 782]
SWATCH_Y = 817


def main(project_key, board_id, swatch_index):
    pw, browser, context = connect()
    page = get_page(context)
    page.goto(f"https://ondaenterprise.atlassian.net/jira/software/projects/{project_key}/boards/{board_id}")
    page.wait_for_timeout(2000)

    item = page.get_by_test_id(f"NAV4_proj_{project_key}")
    box = item.bounding_box()
    if not box:
        print(f"  não achei o item de nav pra {project_key} — confira se o projeto aparece na sidebar (Recent/Starred)")
        pw.stop()
        return
    cx, cy = box["x"] + box["width"] / 2, box["y"] + box["height"] / 2
    page.mouse.move(cx, cy, steps=15)
    page.wait_for_timeout(500)

    dots_x = box["x"] + box["width"] - 12
    dots_y = box["y"] + box["height"] / 2
    page.mouse.click(dots_x, dots_y)
    page.wait_for_timeout(700)

    page.get_by_text("Set space background", exact=True).click()
    page.wait_for_timeout(800)

    page.mouse.click(SWATCH_X[swatch_index], SWATCH_Y)
    page.wait_for_timeout(1000)

    page.keyboard.press("Escape")
    page.keyboard.press("Escape")
    page.wait_for_timeout(300)
    page.screenshot(path=f"bg_{project_key}.png")
    print(f"  {project_key}: cor índice {swatch_index} aplicada")
    pw.stop()


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], int(sys.argv[3]))
