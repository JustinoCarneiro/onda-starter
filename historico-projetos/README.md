# historico-projetos — ledger de KPIs da Onda

Coletânea **entre projetos** dos resultados da Fase 5 (Análise de KPIs de Fechamento). O padrão e
as fórmulas moram em [`../docs/METRICAS-KPI.md`](../docs/METRICAS-KPI.md); o template por projeto em
[`../docs/METRICAS-PROJETO.md`](../docs/METRICAS-PROJETO.md); o prompt reutilizável em
[`../docs/PROMPT-ANALISE-KPI.md`](../docs/PROMPT-ANALISE-KPI.md). **Aqui ficam os números**, para
calibrar proposta nova, ver tendência de margem/retrabalho e comparar estimativa com realizado.

## Arquivos

- **[`PANORAMA-KPI.md`](./PANORAMA-KPI.md)** — tabela mestre + uma seção por projeto + os blocos
  "Snapshot para o histórico da empresa". Primeira carga (2026-09-02) reconstruída do git de todos
  os repositórios em `~/Applications` — ver a seção *Método* lá.
- Dados sensíveis (custo/hora interno, margem, CPI) **não entram aqui** — vão em
  `onda-starter-docs-privados/FINANCEIRO-POR-PROJETO.md` (fora do GitHub).

## Como alimentar (a cada fechamento de projeto)

1. Rodar `PROMPT-ANALISE-KPI.md` no repo do projeto → gera `docs/ANALISE-PROJETO-<nome>.md` lá.
2. Copiar o bloco **"Snapshot para o histórico da empresa"** para o fim de `PANORAMA-KPI.md`.
3. Atualizar a linha do projeto na tabela mestre.
4. Colar a linha financeira (com custo/hora real) no ledger privado.

## Aviso de clone

`onda-starter` é clonado a cada projeto novo. Esta pasta **não deve** ir junto no clone — ela é
histórico da empresa, não scaffold. Ajustar `setup/install.sh` para excluir `historico-projetos/`
(e o `.gitignore` do projeto-filho, se o clone for por cópia).
