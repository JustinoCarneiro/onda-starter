# Automação Jira via navegador (jira_browser)

Scripts Playwright pra fazer no Jira o que a API REST não deixa (team-managed
bloqueia várias ações administrativas via API — ver
`memoria-tecnica/bugs/jira-team-managed-endpoints-bloqueados.md`).

## Como funciona (sem nenhuma credencial no código)

1. `./start_browser.sh` abre um Chrome dedicado (perfil isolado em
   `.browser-profile/`, porta de debug remoto `9333`).
2. Você loga no Jira manualmente nessa janela, uma vez. A sessão persiste em
   disco — só precisa logar de novo se as cookies expirarem.
3. Os scripts (`jira_ui.py` e os que o usam) se conectam nesse Chrome via
   CDP e controlam a aba já autenticada. Nunca veem senha nem token.

Mesmo padrão do `automacao_workana/start_browser.sh` (bypass de detecção de
bot: navegador real com perfil persistente, não instância nova do zero).

## Setup

```bash
cd scripts/jira_browser
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
./start_browser.sh   # abre o Chrome, loga manualmente uma vez
```

## Scripts disponíveis

| Script | O que faz | Uso |
|---|---|---|
| `add_columns.py` | Cria as colunas/status listados em `COLUMNS` num board | `python3 add_columns.py <PROJECT_KEY> <BOARD_ID>` |
| `set_wip_limits.py` | Define Max nas colunas Em Execução (2) e Code Review (3) | `python3 set_wip_limits.py <PROJECT_KEY> <BOARD_ID>` |
| `add_fields.py` | Adiciona campo(s) custom à tela de um tipo de issue | `python3 add_fields.py <PROJECT_KEY> <ISSUETYPE_ID> "<Campo 1>" ["<Campo 2>" ...]` |

IDs de board conhecidos (22/08/2026): SAW=6, MEL=3, MKT=4, LUC=5, HEL=2, VND=9.
IDs de issuetype são **globais**, iguais em todo projeto: Epic=10000, Story=10007, Task=10008,
Sub-task=10009, Bug=10010.
Confira de novo se algum projeto novo entrar — `GET /rest/agile/1.0/board?projectKeyOrId=<KEY>`.

## Ações que pareciam impossíveis mas foram resolvidas (22/08/2026, 2ª rodada)

A primeira tentativa (acima, texto original) concluiu essas duas como manuais. Numa 2ª rodada,
com mais insistência e técnicas diferentes, as duas caíram:

1. **Cor de fundo do projeto**: o menu "..." que aparece no hover do item da sidebar
   (`[data-testid="NAV4_proj_{KEY}"]`) é real e funciona com `page.mouse.move()` (real, não
   `locator.hover()`) seguido de `page.mouse.click()` **nas mesmas coordenadas de pixel**, sem
   re-resolver o elemento por seletor entre o move e o click (re-resolver quebra o estado de
   hover). O item de menu certo é **"Set space background"**. **Limite real do produto, não de
   automação**: só existem 6 cores sólidas pré-definidas (sem hex customizado) — nenhuma bate com
   a paleta da marca; mapeei por família de matiz mais próxima. Ver `set_background.py`.
2. **Gadget em dashboard**: a causa da falha original era um **bug de seletor meu**, não do
   produto — `get_by_role("button", name="Add")` colidia com o botão "**Add gadget**" da barra
   superior (que também "contém" a palavra Add) e sempre clicava nele por engano, silenciosamente.
   A correção: achar a posição exata do botão certo com
   `document.elementFromPoint(x,y)` antes de clicar, depois `page.mouse.click()` direto nessas
   coordenadas — nunca `locator.click()`, que resolve pro elemento errado nesse tipo de colisão de
   nome. Depois de adicionado, configurar o gadget (filtro salvo, eixos) é outro problema à parte:
   ver a seção seguinte.

## Configuração de gadget (Saved Filter): fica manual, e é honesto dizer isso

O campo "Saved Filter" é um widget AUI legado (`aui-ss`, mesmo padrão do field-picker de campos
customizados). `locator.type()` com o **nome completo e exato** do filtro (não busca parcial),
delay=40, feito **por último** no formulário (depois de XAxis/YAxis, porque mexer em outros campos
reseta o filtro) **às vezes** faz o `<select>` escondido assumir o valor certo (confirmado uma vez
lendo `document.querySelector('[id="..."]').value` = o id do filtro certo) — mas não é
reprodutível de forma confiável; a mesma sequência exata falhou em tentativas seguintes. Não vale
a pena insistir mais nisso via UI — é instável o bastante pra não virar um script confiável.

**Beco sem saída real, testado a fundo**: tentei configurar o gadget inteiramente via API REST
(`PUT /rest/dashboards/1.0/{dashboardId}/gadget/{gadgetId}/prefs.json`, existe e é a chamada que a
própria UI usa) — sempre devolve `204` mas **não persiste nada**, nem o campo mais simples possível
(`numberToShow`). Testado com Basic Auth via API token, com sessão de navegador real via
`fetch()` dentro da própria página, com JSON, form-encoded, com/sem header `X-Atlassian-Token:
no-check` — todos "sucesso" (204) sem gravar de verdade. Não é problema de autenticação nem de
formato, é o endpoint mesmo que não grava por essa via nem de dentro do navegador autenticado.

**Conclusão prática**: o gadget "Two Dimensional Filter Statistics" já fica adicionado e
posicionado certo no dashboard (isso automatiza 100%). Selecionar o filtro salvo e clicar Save é
1 ação manual de ~15s que sobra mesmo depois de esforço real em ~10 técnicas diferentes de UI e
~6 de API — não é preguiça, é limite genuíno do que dá pra automatizar nesse widget específico.

## Lições de quem for estender isso

- **Emoji no texto**: `page.fill()` funciona, `page.keyboard.type()` não —
  digitação simulada corrompe caracteres multi-byte.
- **Dropdown "Add status"** não busca por status já existentes no site
  inteiro — só sugere "Create novo". Usar sempre "Add column" (cria status +
  coluna junto), nunca tentar reaproveitar um status criado via API crua
  antes — vira órfão. Isso já aconteceu (`10015`, `10017`, `10019` foram
  limpos via `DELETE /rest/api/3/statuses?id=...`).
- **Categoria do "Add column" às vezes vem travada** (disabled), já
  pré-preenchida com o valor certo — não force clicar, só confira depois via
  `GET /rest/api/3/statuses/search`. Os scripts já lidam com isso (timeout
  curto, não trava 30s).
- **Botões duplicados**: vários elementos podem compartilhar o mesmo
  `role`+`name` (ex: botão que abre o modal vs. botão de submit dentro dele)
  — usar `data-testid` quando `get_by_role` colidir.
- **Ordem das colunas** em `set_wip_limits.py` é posicional (índice do
  input na página) — se a ordem das colunas mudar num board specific,
  atualizar `COLUMN_ORDER`.
- **Drag-and-drop não é confiável** nesse board (testado, várias tentativas
  erraram o alvo) — preferir sempre um fluxo de diálogo com campo de texto.
