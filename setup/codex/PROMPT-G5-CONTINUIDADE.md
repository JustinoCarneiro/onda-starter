# Prompt para o Codex — fechar o Gate G5 (continuidade entre agentes)

O Claude já fez o **passo 1** da simulação: criou
`.ondadev/handoff/G5-SIMULACAO.md` (só a linha do passo 1) e escreveu o handoff
em `.ondadev/handoff/current.md`. Falta o **passo 2** (Codex) e depois o passo 3
(Claude confere e limpa).

Cole o bloco abaixo no Codex, com o repositório `onda-starter` aberto na branch
`feat/ondadev-3-environment`, **no mesmo checkout** (sem abrir worktree).

---

```text
Tarefa: OndaDev PR-05 — fechar o Gate G5 (passo 2 de 3)
Autor: Codex
Revisor: Claude
Risco: R0

Contexto
  Você é o SEGUNDO agente numa simulação de continuidade. Regra do teste:
  leia SOMENTE .ondadev/handoff/current.md. NÃO abra outros arquivos, NÃO
  releia o repositório, NÃO rode busca ampla.

Passo 1 — ler o handoff
  Abra .ondadev/handoff/current.md e responda em 3 linhas, no seu relato:
    - qual foi o último teste rodado e o resultado
    - qual a pendência
    - qual o próximo passo concreto

Passo 2 — executar
  a) Acrescente ao FIM de .ondadev/handoff/G5-SIMULACAO.md exatamente uma linha:
     - Passo 2 — Codex — <timestamp UTC ISO> — continuei a partir do current.md; último teste: 4/4 PASS; pendência: nenhuma.
  b) Rode: bash scripts/ai-checkpoint.sh
  c) Edite as seções de raciocínio de .ondadev/handoff/current.md:
     - Direção: Codex -> Claude
     - Seção 7 (próximo passo): "Passo 3: Claude confere a linha do passo 2 e
       remove .ondadev/handoff/G5-SIMULACAO.md; roda ai-checkpoint.sh; G5 fechado."
     - marque "[x] o primeiro agente parou?" (agora é você quem parou)
     - marque os itens da seção 9 (checklist de segurança)
  d) NÃO faça `git add` de G5-SIMULACAO.md nem de current.md (o primeiro é
     descartável, o segundo é ignorado pelo Git).

Restrições
  - Sem push, merge, deploy, login, autorização externa, instalação de plugin.
  - Não habilitar OPENAI_API_KEY / ANTHROPIC_API_KEY como fallback.
  - Não escrever em mais nenhum arquivo. Sem escrita concorrente: quando
    terminar, PARE e encerre a sessão antes de devolver ao Claude.
  - Não colar no handoff conteúdo de arquivo, diff completo ou valor de variável.

Pronto (Gate G5)
  1. G5-SIMULACAO.md tem as linhas do passo 1 (Claude) e do passo 2 (Codex).
  2. current.md aponta Codex -> Claude e o passo 3.
  3. Você conseguiu dizer o último teste, a pendência e o próximo passo lendo
     só o current.md — sem reler o repo.
  4. Entregue a síntese de handoff (Escopo / Mudanças / Validações e resultado /
     Decisões / Riscos e próximos passos). Sem push.
```

---

## Depois que o Codex devolver

Me avise. Eu faço o passo 3: confiro a linha do passo 2 lendo só o `current.md`,
removo `.ondadev/handoff/G5-SIMULACAO.md`, rodo `ai-checkpoint.sh` e declaro o
**Gate G5 fechado** — continuidade comprovada Claude→Codex e Codex→Claude.
