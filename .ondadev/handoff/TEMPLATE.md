<!--
  Template de handoff entre agentes (Claude <-> Codex) do OndaDev 3.0.
  Versionado. NÃO edite este arquivo para uma tarefa concreta: gere uma cópia
  em .ondadev/handoff/current.md (ignorado pelo Git) com:

      bash scripts/ai-checkpoint.sh

  O script preenche os campos automáticos (branch, commit, status, testes).
  Os campos de raciocínio (decisões, próximos passos, riscos) são seus.
  Nunca cole conteúdo de arquivo, diff completo, valor de variável ou segredo.
-->

# Handoff — <título curto da tarefa>

- **Direção:** Claude -> Codex  |  Codex -> Claude
- **Motivo:** cota a 100%  |  checkpoint a 75%  |  troca planejada  |  outro
- **Data (UTC):** <preenchido pelo script>
- **Risco da tarefa:** R0 | R1 | R2

## 1. Objetivo

Uma frase: qual é o resultado observável esperado.

## 2. Estado atual

- **Branch:** <preenchido pelo script>
- **Último commit:** <preenchido pelo script>
- **Worktree / checkout:** Local  |  worktree `../onda-starter--<tarefa>`
- **O primeiro agente parou de escrever?** [ ] sim — obrigatório antes do outro começar

## 3. Arquivos em jogo

<preenchido pelo script: git status --short + diff --stat, só nomes e números>

Comentário curto do humano/agente sobre o que cada mudança pendente representa:

- `caminho/arquivo` — o que está sendo feito ali

## 4. Último teste rodado e resultado

<preenchido pelo script: tabela de validações determinísticas + PASS/FAIL>

Testes específicos da tarefa (se houver) e resultado — descreva, não cole log:

- `<comando>` — PASS | FAIL (<resumo de 1 linha>)

## 5. Decisões tomadas

- Decisão — motivo — o que ela impede/exige daqui pra frente.
- ADRs afetados: `docs/architecture/adr/NNNN-*.md`

## 6. Erros / bloqueios abertos

- Sintoma observável — hipótese de causa — onde parou de investigar.

## 7. Próximo passo concreto

1. A primeira ação que o próximo agente deve executar.
2. A segunda.

## 8. Riscos e pendências

- Risco — probabilidade/impacto — mitigação.
- Pendências que dependem de decisão de produto, credencial ou autorização externa.

## 9. Checklist de segurança do handoff

- [ ] Nenhum segredo, token, valor de `.env` ou dado de cliente neste arquivo.
- [ ] `ANTHROPIC_API_KEY` NÃO foi habilitada como fallback automático.
- [ ] Sem escrita concorrente: um agente por checkout por vez.
- [ ] `current.md` está fora do Git (é ignorado).
