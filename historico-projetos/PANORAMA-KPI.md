# Panorama de KPIs — projetos Onda

> **Primeira carga: 2026-09-02.** Reconstruída **só do git** (+ arquivos-chave) de cada repositório
> em `~/Applications`. Sem timesheet real em nenhum projeto — toda hora aqui é **estimativa por
> proxy de commit** (ver *Método*). Valores de contrato, margem e CSAT quase sempre faltam: são
> lacunas marcadas, não zeros.
>
> Padrão/fórmulas: [`../docs/METRICAS-KPI.md`](../docs/METRICAS-KPI.md). Este documento **não é
> spec** — não dispara sincronização com Trello/Jira.

---

## Método — estimativa de horas por proxy de commit `(est.)`

Nenhum projeto da Onda registrou timesheet até 2026-09-02. Para ter noção de esforço, as horas
abaixo são derivadas dos **timestamps dos commits**:

1. Ordena os commits por data/hora.
2. **Sessão** = sequência de commits com ≤ 2,5 h entre um e o seguinte. Gap maior abre nova sessão.
3. Duração da sessão = (último − primeiro commit) **+ 0,75 h de ramp-up** (trabalho antes do 1º
   commit).
4. **Piso** = soma das durações de sessão. **Central** = piso × 1,25 a 1,45 (cobre trabalho depois
   do último commit e sessões de 1 commit que rendem span 0). **Teto** = span do 1º ao último
   commit de cada *dia* (infla dias que juntam madrugada + tarde).

**Viés:** só para baixo — não vê planejamento, design, reunião com cliente, leitura, trabalho
pós-commit além dos 45 min. Não citar como hora medida. Serve para faixa de sanidade de
*effective hourly rate* e para comparar projetos entre si (o viés é consistente).

`fix ÷ total` (rework) só é confiável onde os commits seguem Conventional Commits. Vários repos
antigos usam mensagens automáticas (`modified`, `deleted`, `(sem prefixo)`) — nesses, o rework
está marcado *n/c* (não confiável).

---

## Tabela mestre

| Projeto | Tipo (a confirmar) | Janela | Dias corr./ativos | Commits / sessões | Horas est. **central** | Churn (add/del) | Rework | Testes | Docs KPI no repo |
|---|---|---|---|---|---|---|---|---|---|
| confidencial-calcados | Cliente — e-commerce | 2026-08-20 → 09-02 | 14 / 12 (86%) | 73 / 18 | **~55–60 h** | +29,2k / −2,0k | 28,8% | 40 | ✅ análise + métricas |
| heliene-araujo | Cliente — site (piloto KPI) | 2026-08-17 → 09-02 | 17 / 8 (47%) | 31 / 9 | **~18–20 h** | +39,5k / −0,8k | n/c¹ | 23 | ✅ análise + métricas |
| marketplace-ceara | Cliente — marketplace (web+mobile) | 2026-06-19 → 09-01 | 75 / 20 (27%) | 111 / 28 | **~65–75 h** | +61,3k / −8,9k | ~38% | 15 | ⚠ só template |
| saw-hub | Cliente — plataforma (Java/Spring) | 2026-07-06 → 09-01 | 58 / 24 (41%) | 188 / 43 | **~120–139 h** | +97,8k / −9,9k | 31,4% | 32 | ⚠ só template |
| sistema_lucas | Cliente — sistema interno | 2026-02-19 → 09-01 | 195 / 35 (18%) | 121 / 44 | **~94–109 h** | +70,8k / −12,6k | ~21% | 34 | ⚠ só template |
| sistema_melvin | Cliente (ONG) — sistema, 2+ anos | 2024-07-03 → 2026-09-01 | 791 / 68 (9%) | 155 / 81 | **~116–135 h** | +72,0k / −25,8k | n/c¹ | 18 | ⚠ só template |
| vanessa-vaz-projeto | Cliente — site institucional + blog | 2026-06-13 → 09-01 | 81 / 6 (7%) | 51 / 9 | **~25–29 h** | +27,8k / −1,3k | n/c¹ | 12 | ⚠ só template |
| sistema_so_moqas | Cliente? — sistema de manutenção | 2026-03-09 → 07-31 | 145 / 11 (8%) | 26 / 14 | **~24–27 h** | +24,0k / −13,3k | n/c¹ | 9 | — |
| figurinos-tja | Cliente — sistema p/ teatro público | 2026-05-22 → 06-19 | 29 / 2 (7%) | 7 / 4 | **~9–10 h** | +21,8k / −13,4k | n/c¹ | 0 | proposta em onda-propostas |
| landing_page_Klinsmann | Cliente — landing page | 2026-05-30 → 08-02 | 65 / 3 (5%) | 14 / 4 | **~9–10 h** | +3,3k / −0,6k | n/c¹ | 0 | — |
| onda_enterprise | Interno — site da Onda | 2026-06-05 → 08-01 | 58 / 4 (7%) | 40 / 5 | **~22–25 h** | +5,6k / −2,0k | n/c¹ | 0 | — |
| onda-starter | Interno — scaffold/metodologia | 2026-06-11 → 09-01 | 83 / 8 (10%) | 12 / 8 | **~9–10 h** | +3,5k / −0,2k | n/c¹ | 28² | — |
| onda-propostas | Interno — propostas comerciais | 2026-06-17 → 06-24 | 8 / 2 | 2 / 2 | **~2 h** | +3,3k / −0,2k | n/c¹ | 0 | — |
| copiloto-ai-source | Spike — Copiloto AI | 2026-08-04 → 08-13 | 10 / 2 (20%) | 17 / 3 | **~8–9 h** | +37,8k / −1,1k | n/c¹ | 17 | — |
| tutor-socratico | Spike — protótipo | 2026-06-25 → 06-26 | 2 / 2 | 2 / 2 | **~2 h** | +8,8k / −0,1k | n/c¹ | 0 | — |
| portfolio | Pessoal | 2026-03-30 → 06-03 | 66 / 3 (5%) | 10 / 3 | **~5 h** | (poluído³) | n/c¹ | 0 | — |
| mini-ipfs-so | Acadêmico (4 autores) — fora do escopo empresa | 2026-07-06 → 07-09 | 4 / 4 | 6 / 4 | **~6–7 h** | +0,9k / −0,3k | n/c¹ | 0 | — |

¹ commits sem Conventional Commits (mensagens automáticas) → rework não confiável.
² arquivos de teste do *template* (herdados do starter), não testes do próprio repo.
³ `portfolio` tem um commit com artefato gigante vendorizado (+1M linhas) — churn inútil.

**Totais Onda (clientes + interno, exclui acadêmico/pessoal):** ~15 projetos · ~1.170 commits ·
**~600–700 h estimadas** de esforço acumulado desde fev/2026 (a maior parte em saw-hub,
sistema_melvin, sistema_lucas e marketplace-ceara).

---

## Projetos com Fase 5 formal (análise completa no repo)

### confidencial-calcados
E-commerce de calçados. **Análise completa:** `confidencial-calcados/docs/ANALISE-PROJETO-CONFIDENCIAL-CALCADOS.md`
(refresh 2026-09-02). Único com valor de contrato conhecido (**R$ 1.500**, 100% adiantado) e
com análise financeira privada. 73 commits em 12 dias ativos; núcleo transacional validado com
dinheiro real em 10 dias; 15 itens fora da cláusula 3 do contrato, aditivo R$ 0. Effective hourly
rate bruto `(est.)` ~R$ 25–34/h. Margem/CPI no ledger privado — **abaixo do alvo, subprecificado**.

### heliene-araujo (`heliene-macedo-projeto`)
Site — **projeto-piloto da metodologia de KPI**. **Análise completa:**
`heliene-macedo-projeto/docs/ANALISE-PROJETO-HELIENE.md`. Refresh git 2026-09-02: 31 commits,
9 sessões, 8 dias ativos de 17 corridos (47%), ~18–20 h `(est.)`. 23 arquivos de teste. Um gap de
7 dias (2026-08-22 +7d). Rework não confiável pelos prefixos. Já tem `METRICAS-PROJETO.md`
preenchido — usar como referência de formato.

---

## Projetos Onda sem Fase 5 formal — reconstrução git (2026-09-02)

> Para cada um: o que dá pra afirmar do git, e a lista de lacunas para fechar o "conjunto mínimo"
> de `METRICAS-KPI.md` § 2. **Padrão de lacuna em todos:** valor do contrato, 4 datas do kickoff,
> timesheet, CSAT — nenhum registrado.

### marketplace-ceara
- **Forma:** monorepo `web + mobile + admin` (Maestro/E2E no mobile, specs no admin). Marketplace
  de propostas/pagamento. Sem stack única detectável no root.
- **Cronograma:** 75 dias corridos, 20 ativos (27%). Dois blocos: **jun/2026 (42 commits)** e
  **ago/2026 (61)**, com um vale de ~1 commit em jul. Gaps de **26 d** (jul) e **19 d** (ago) —
  candidatos a espera/pausa, sem registro do motivo.
- **Esforço:** 111 commits, 28 sessões → piso ~52 h, **central ~65–75 h**, teto ~103 h.
- **Fluxo/qualidade:** feat 34 / fix 42 / ci 10 → **rework ~38%** (alto; mas há CI e testes — 15
  arquivos). Churn alto (+61k/−9k) coerente com 3 frentes.
- **Lacunas p/ conjunto mínimo:** valor do contrato · datas · timesheet · CSAT · pesos de módulo
  (tem `METRICAS-PROJETO.md` template, não preenchido) · deploy/DORA (histórico não coletado).

### saw-hub
- **Forma:** backend **Java/Spring** (`backend/target/...` com surefire) + front. Plataforma de
  mentoria (mentorado, contrato, documento).
- **Cronograma:** 58 dias corridos, 24 ativos (41% — o mais intenso da carteira). **Sprint pesado
  em jul/2026 (175 dos 188 commits)**, depois um gap de **22 d** e cauda em ago. 43 sessões.
- **Esforço:** piso ~96 h, **central ~120–139 h**, teto ~180 h — **maior projeto da Onda por
  esforço estimado**.
- **Fluxo/qualidade:** feat 69 / fix 59 / refactor 9 / debug 7 → **rework 31%**. 32 arquivos de
  teste. Churn +98k/−10k.
- **Valor:** proposta em `onda-propostas/clientes/saw/` — **R$ 20.000** (10k kickoff + 10k entrega)
  ou **R$ 7.700** (condição especial). Qual foi aceita decide se este projeto é o único lucrativo
  da carteira ou o segundo maior prejuízo — ver ledger privado. **É a informação financeira
  prioritária a levantar.**
- **Lacunas:** contrato aceito (20k vs 7,7k) · datas · timesheet · CSAT · DORA (deploy Coolify —
  histórico não puxado).

### sistema_lucas
- **Cronograma:** **195 dias corridos** (fev→set/2026), só 35 ativos (18%) — desenvolvimento
  intermitente/longo. Picos em mar (34) e ago (36). Gaps de **30 d**, **24 d**, **20 d**, **14 d**.
  2 autores (JustinoCarneiro, MarcosJustino).
- **Esforço:** 121 commits, 44 sessões → piso ~75 h, **central ~94–109 h**, teto ~119 h.
- **Fluxo/qualidade:** metade dos commits antigos são `modified` (não convencionais); depois
  vira feat/fix. Rework ~21% na parte confiável. 34 arquivos de teste.
- **Lacunas:** valor do contrato · datas · timesheet · CSAT · o que explica os 4 gaps longos
  (espera do cliente? outro projeto?) — nenhum registrado.

### sistema_melvin
- **Cronograma:** **791 dias corridos (jul/2024 → set/2026)**, 68 ativos (9%). Projeto de **ONG
  (Instituto Social Melvin)** em modo manutenção de longo prazo: gaps de **183 d**, **115 d**,
  **87 d**, **54 d**. Atividade real concentrada em blocos curtos (mar/2026: 21, jun: 22, ago: 27).
  2 autores.
- **Esforço:** 155 commits, 81 sessões → piso ~93 h, **central ~116–135 h** — mas **diluídos em
  2+ anos**; não comparável a um projeto de entrega única.
- **Qualidade:** commits majoritariamente não convencionais (`modified` 53, `(sem prefixo)` 55).
  18 arquivos de teste.
- **Lacunas:** natureza do acordo (pro bono? simbólico? — provável, sendo ONG) · datas · o custo
  real de manter isso vivo por 2 anos (relevante para decidir se continua).

### vanessa-vaz-projeto
- **Forma:** Next.js + React + Tailwind. **VVM Advocacia — site institucional + blog.** Tem
  `BRIEFING-FASE-2B.md`.
- **Cronograma:** 81 dias corridos, **só 6 ativos (7%)**. **Quase tudo em jun/2026 (49 commits)**;
  1 em ago, 1 em set (ajustes). Gaps de **51 d** e **25 d** = projeto entregue em jun, toques
  esporádicos depois.
- **Esforço:** 51 commits, 9 sessões → piso ~20 h, **central ~25–29 h**.
- **Qualidade:** commits não convencionais (`(sem prefixo)` 42). 12 arquivos de teste.
- **Lacunas:** valor do contrato · datas · CSAT · confirmação de que está entregue/aceito.

### sistema_so_moqas
- **Forma:** "MoQa — Sistema de Manutenção de Monitores". Relação com `MoQa`/`MoQa_backup` (não
  são repos git) a esclarecer.
- **Cronograma:** 145 dias corridos, 11 ativos (8%). Concentrado em **mar/2026 (20)**, resto
  esparso. Gaps de **52 d** e **49 d**.
- **Esforço:** 26 commits, 14 sessões → **central ~24–27 h**.
- **Lacunas:** é projeto de cliente, interno ou acadêmico? · valor · datas · estado atual.

### figurinos-tja
- **Forma:** sistema de **gestão de figurino/acervo para teatro público** (não é LP) — controle de
  locação com caução, relatórios, rastreabilidade. Proposta em `onda-propostas/clientes/tja/`
  (v1.0 R$ 5.500 → v1.1 R$ 3.500). Tem `BRIEFING-FASE-2B.md`.
- **Cronograma:** 29 dias corridos, **só 2 ativos** (mai–jun/2026). 7 commits, 4 sessões →
  **central ~9–10 h**. Churn +22k/−13k = 1 grande import/refactor.
- **Contradição a resolver:** proposta de sistema (R$ 3.500) vs. repo com 7 commits / ~10 h. Ou o
  projeto está no começo, ou foi pausado/cancelado, ou o código está em outro lugar.
- **Lacunas:** aceite e estado do projeto · datas · valor confirmado.

### landing_page_Klinsmann
- **Forma:** landing page ("Zoo Agency"). Sem testes.
- **Cronograma:** 65 dias corridos, 3 ativos (5%). 14 commits, 4 sessões → **central ~9–10 h**.
  Churn baixo (+3,3k/−0,6k) — LP enxuta.
- **Lacunas:** valor do contrato · datas · aceite · métrica de conversão pós-lançamento (é o KPI
  que importa em LP).

---

## Projetos internos / infra

### onda_enterprise — site institucional da Onda
58 dias corridos, 4 ativos (7%); 40 commits, **~22–25 h `(est.)`**, quase tudo em jun/2026.
Sem receita — investimento próprio. KPI relevante aqui não é margem, é se o site gera lead.

### onda-starter — scaffold + metodologia
O template/tooling clonado a cada projeto. 12 commits em 83 dias (10% ativo), **~9–10 h `(est.)`**
de trabalho direto, mas o valor está em quanto ele **poupa por projeto** (Fase 0 automatizada),
não no esforço próprio. Os 28 "arquivos de teste" são do template, não deste repo.

### onda-propostas — geração de propostas comerciais
2 commits, ~2 h. Guarda propostas PDF/HTML por cliente. **Cruzado com a tabela mestre em
2026-09-02** — clientes com proposta: heliene (só checklist), saw (R$ 20k / R$ 7,7k), tja
(R$ 3,5k), instituto-melvin (só infra), + sanarys, eriksen-gm, marcel-imobiliaria, felipe,
samuel-vrapfilms (sem repo em `~/Applications` — pipeline comercial). Valores no ledger privado.

---

## Spikes / pessoal / acadêmico

| Projeto | O que é | Esforço est. | Nota |
|---|---|---|---|
| copiloto-ai-source | Spike "Copiloto AI" (React/Vite) | ~8–9 h | 17 commits em 2 dias; churn +38k = import de base pronta. Não é entrega de cliente. |
| tutor-socratico | Protótipo | ~2 h | 2 commits. Descartável/arquivar. |
| portfolio | Portfólio pessoal do Justino | ~5 h | Fora do escopo empresa. |
| mini-ipfs-so | Trabalho acadêmico de SO (4 autores) | ~6–7 h | Fora do escopo empresa — não incluir em métrica de agência. |

---

## Leitura consolidada — o que o panorama diz para a empresa

1. **Nenhum projeto tem timesheet.** Toda análise de custo/margem/CPI da Onda hoje é estimativa por
   proxy de commit com viés para baixo. **Ação:** timesheet leve (`METRICAS-PROJETO.md` § 3) a
   partir da próxima sessão de *qualquer* projeto ativo — não só nos novos.

2. **Esforço estimado acumulado ~600–700 h** desde fev/2026, concentrado em 4 projetos
   (saw-hub ~130 h, sistema_melvin ~125 h diluídos em 2 anos, sistema_lucas ~100 h,
   marketplace-ceara ~70 h). Sem os valores de contrato, é impossível dizer quais desses pagaram.

3. **Valor de contrato confirmado só para 1 de 15 projetos** (confidencial, R$ 1.500 — margem
   negativa no cenário-meta). `onda-propostas/clientes/` foi cruzado (2026-09-02) e deu **pistas,
   não confirmações**: saw-hub tem proposta de R$ 20.000 **ou** R$ 7.700 (condição especial) —
   qual foi aceita muda o projeto de "único lucrativo" para "segundo maior prejuízo"; figurinos-tja
   ~R$ 3.500; instituto-melvin só tem cotação de infra (provável quase pro bono). Detalhe e
   números no ledger privado. **Ação:** confirmar o contrato aceito de cada um (começar por
   saw-hub) e fechar a leitura financeira.

4. **Rework alto onde dá pra medir** (confidencial 28,8%, marketplace ~38%, saw-hub 31%). Parte é
   auditoria proposital (segurança/perf/SEO), parte é bug real. **Ação:** separar `fix:` de
   auditoria de `fix:` de defeito nos próximos, para o número significar algo.

5. **Padrão de escopo que cresce sem aditivo** documentado em confidencial (15 itens, R$ 0).
   Provável que se repita nos outros. **Ação:** usar a seção 5 do `METRICAS-PROJETO.md` (mudanças
   de escopo) desde o começo, mesmo quando a decisão comercial for dar cortesia.

6. **CI placeholder** passou semanas despercebido em confidencial. Vale auditar o `.github/` dos
   outros projetos ativos (marketplace-ceara tem `ci` nos prefixos; os demais, verificar).

7. **Convenção de commit inconsistente** (metade dos repos sem Conventional Commits) custa
   rastreabilidade de flow distribution e rework. **Ação:** padronizar via `onda-starter`
   (commit-msg hook / lint).

---

## Snapshots para o histórico da empresa

> Bloco plano por projeto, para colar em planilha/BI. Os dois primeiros vêm das análises formais;
> os demais são reconstrução git de 2026-09-02.

```
CONFIDENCIAL CALÇADOS — snapshot 2026-09-01, refresh 2026-09-02 (em curso)
Tipo: e-commerce (calçados) | Stack: Next.js + Prisma/Postgres | 1 dev | Deploy: VPS Coolify (cliente)
Contrato: R$ 1.500,00, 100% adiantado, prazo 4-5 semanas
Janela: 2026-08-20 a 2026-09-02 (14 dias corridos, 12 ativos, 86%) | 73 commits, 18 sessões
Horas (est. proxy de commit): ~44 piso / ~55-60 central / ~76 teto
Effective hourly rate bruto (est.): ~R$ 25-34/h | Margem/CPI: ledger privado (abaixo do alvo)
Escopo: 36 histórias; 15 itens fora da cláusula 3 do contrato, aditivo R$ 0
Testes: ~299 casos / 40 arquivos | CI real desde 02/09 | Bugs c/ causa raiz: 5-6
1º deploy produção: 2026-08-31/09-01 | incidentes: 2, recuperados <1h
```

```
HELIENE ARAÚJO — snapshot 2026-09-02 (piloto da metodologia de KPI)
Tipo: site | Stack: Next.js + React | 1 dev
Janela: 2026-08-17 a 2026-09-02 (17 dias corridos, 8 ativos, 47%) | 31 commits, 9 sessões
Horas (est. proxy de commit): ~14 piso / ~18-20 central
Testes: 23 arquivos | Rework: n/c (prefixos não convencionais) | Gap: 1 de 7 dias
Contrato/CSAT/datas: ver docs/ANALISE-PROJETO-HELIENE.md no repo
```

```
MARKETPLACE CEARÁ — snapshot 2026-09-02 (reconstrução git, sem Fase 5 formal)
Tipo: marketplace web+mobile+admin | multi-stack | 1 dev
Janela: 2026-06-19 a 2026-09-01 (75 dias corridos, 20 ativos, 27%) | 111 commits, 28 sessões
Horas (est. proxy de commit): ~52 piso / ~65-75 central / ~103 teto
Blocos: jun (42) + ago (61) | gaps de 26d e 19d sem motivo registrado
feat 34 / fix 42 / ci 10 -> rework ~38% | testes: 15 arquivos
Contrato/datas/timesheet/CSAT/DORA: não coletados
```

```
SAW HUB — snapshot 2026-09-02 (reconstrução git, sem Fase 5 formal)
Tipo: plataforma de mentoria | backend Java/Spring | 1 dev | Deploy: VPS Coolify
Janela: 2026-07-06 a 2026-09-01 (58 dias corridos, 24 ativos, 41%) | 188 commits, 43 sessões
Horas (est. proxy de commit): ~96 piso / ~120-139 central / ~180 teto  [MAIOR ESFORÇO DA CARTEIRA]
Sprint jul (175 commits) -> gap 22d -> cauda ago | feat 69 / fix 59 -> rework 31% | testes: 32
Contrato/datas/timesheet/CSAT/DORA: não coletados
```

```
SISTEMA LUCAS — snapshot 2026-09-02 (reconstrução git, sem Fase 5 formal)
Tipo: sistema interno | 2 devs (JustinoCarneiro, MarcosJustino)
Janela: 2026-02-19 a 2026-09-01 (195 dias corridos, 35 ativos, 18%) | 121 commits, 44 sessões
Horas (est. proxy de commit): ~75 piso / ~94-109 central / ~119 teto
Intermitente: gaps de 30d, 24d, 20d, 14d sem motivo registrado | rework ~21% (parte confiável)
Testes: 34 arquivos | Contrato/datas/timesheet/CSAT: não coletados
```

```
SISTEMA MELVIN — snapshot 2026-09-02 (reconstrução git, sem Fase 5 formal)
Tipo: sistema para ONG (Instituto Social Melvin) | 2 devs | modo manutenção de longo prazo
Janela: 2024-07-03 a 2026-09-01 (791 dias corridos, 68 ativos, 9%) | 155 commits, 81 sessões
Horas (est. proxy de commit): ~93 piso / ~116-135 central  [DILUÍDO EM 2+ ANOS]
Gaps de 183d, 115d, 87d, 54d | commits não convencionais | testes: 18 arquivos
Natureza do acordo (pro bono?/datas/custo de manutenção): não documentado
```

```
VANESSA VAZ (VVM ADVOCACIA) — snapshot 2026-09-02 (reconstrução git, sem Fase 5 formal)
Tipo: site institucional + blog | Next.js + React + Tailwind | 1 dev
Janela: 2026-06-13 a 2026-09-01 (81 dias corridos, 6 ativos, 7%) | 51 commits, 9 sessões
Horas (est. proxy de commit): ~20 piso / ~25-29 central
Entregue em jun/2026 (49 commits), toques esporádicos depois | testes: 12 arquivos
Contrato/datas/aceite/CSAT: não coletados
```

```
MENORES — snapshot 2026-09-02 (reconstrução git)
sistema_so_moqas : 26 commits / ~24-27h est. | mar/2026 | tipo a confirmar
figurinos-tja    : 7 commits  / ~9-10h est.  | Fase 2b | LP/site pequeno
landing_Klinsmann: 14 commits / ~9-10h est.  | LP "Zoo Agency"
onda_enterprise  : 40 commits / ~22-25h est. | site da própria Onda (sem receita)
onda-starter     : 12 commits / ~9-10h est.  | tooling/metodologia
onda-propostas   : 2 commits  / ~2h est.     | propostas comerciais (fonte de valores de contrato)
copiloto-ai-source: 17 commits / ~8-9h est.  | spike, não é entrega
tutor-socratico  : 2 commits  / ~2h est.     | protótipo descartável
```
