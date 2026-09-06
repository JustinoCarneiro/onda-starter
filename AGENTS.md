# OndaDev - Contrato canônico de trabalho

## Objetivo

Este repositório é o starter da metodologia OndaDev. Ele guarda templates,
processos e automações reutilizáveis; não representa um produto de cliente em
produção. Ao iniciar um projeto, preencha a spec, o roadmap e os ADRs antes de
criar implementação de negócio.

## Mapa do repositório

| Caminho | Finalidade |
| --- | --- |
| `docs/product/spec.md` | Fonte de verdade funcional e critérios de aceite. |
| `ROADMAP.md` | Ordem técnica, módulos e estado de entrega. |
| `docs/architecture/adr/` | Decisões arquiteturais ativas. |
| `docs/security/` | Classificação de dados, ameaças e controles. |
| `docs/` | Metodologia, design system, QA e métricas reutilizáveis. |
| `memoria-tecnica/` | Histórico de bugs e decisões; consulte antes de investigar. |
| `setup/` | Diagnóstico e instalação do ambiente OndaDev. |
| `setup/shared/skills/` | Fonte canônica das seis skills OndaDev; sincronizada para `.claude/skills/` e `.agents/skills/` (nunca edite os destinos). |
| `setup/WORKTREE.md` | Papéis Local/Worktree e transferência segura entre eles. |
| `.ondadev/` | Protocolo de failover de cota e template de handoff entre agentes. |
| `.vscode/` | Extensões recomendadas e tarefas Setup/Lint/Test/Build/Run. |
| `.github/workflows/` | CI: validações determinísticas, smoke do instalador e secret scanning. |
| `.pre-commit-config.yaml` | Hooks locais (gitleaks + verificações OndaDev). |
| `.gitleaks.toml` | Regras padrão do gitleaks + allowlist de material público de verificação. |
| `.env.example` | Modelo de ambiente local sanitizado; copie para `.env` (não versionado). |
| `scripts/` | Automações locais; `jira_browser/` configura o quadro Jira via navegador. |
| `docker-compose.yml` | PostgreSQL e pgAdmin de desenvolvimento local. |

## Autoridade da informação

| Assunto | Fonte canônica | Papel das demais fontes |
| --- | --- | --- |
| Escopo, histórias e aceite | `docs/product/spec.md` | Jira e GitHub apenas refletem o trabalho. |
| Ordem técnica e progresso | `ROADMAP.md` | O board é uma projeção visual de status. |
| Decisão de arquitetura | `docs/architecture/adr/` | `memoria-tecnica/decisoes/` preserva contexto histórico. |
| Dados, ameaças e controles | `docs/security/` | Nenhuma tarefa pode contrariar esta classificação. |
| Código e histórico versionado | Git | GitHub registra PRs, revisão e CI quando utilizados. |
| Trabalho externo | Jira/GitHub | Nunca sobrescreve a verdade local sem decisão explícita. |

Jira é uma projeção do status, nunca o bloqueio da edição local. O quadro é
configurado uma vez por projeto com `scripts/jira_browser/` (colunas, limites de
WIP, campos); a gestão de issues no dia a dia é manual na UI do Jira. Falhas de
rede, login ou API devem ser registradas e não podem apagar nem impedir mudanças
locais. Exclusões de issue exigem confirmação explícita.

## Comandos verificados

```bash
# Ambiente e instruções
bash setup/check-environment.sh
bash setup/install.sh --dry-run
bash setup/tests/install-smoke.sh
bash scripts/validate-agent-context.sh

# Relatório único de CI (roda tudo abaixo + shellcheck + links + metodologia)
bash scripts/ci-report.sh

# Skills OndaDev compartilhadas (fonte canônica -> destinos Claude e Codex)
bash setup/shared/sync-skills.sh --check
bash setup/tests/skills-drift.sh
bash setup/tests/skills-frontmatter.sh

# Preparação/verificação de uma árvore de trabalho (git worktree)
bash setup/worktree-setup.sh --check

# Checkpoint de handoff entre agentes (só metadados seguros)
bash scripts/ai-checkpoint.sh --stdout

# Serviços locais (cria/atualiza containers e volumes)
docker compose config
docker compose up -d

# Automação do quadro Jira (setup one-time via navegador); ver o README
cat scripts/jira_browser/README.md
```

Não há ainda build, lint ou suíte de testes de uma aplicação neste starter.
Não invente comandos como `npm test`: o projeto derivado deve registrá-los aqui
quando o runtime for criado.

## Fronteiras e convenções

- Não introduza código de produto, dependências de produção ou stack de cliente
  neste starter sem uma decisão documentada.
- Preserve a separação: spec define o **porquê/o quê**, roadmap define a ordem,
  ADR define o **como** duradouro e código implementa a decisão.
- Escreva documentação em português claro; use nomes técnicos, comandos e APIs
  no idioma exigido pela tecnologia.
- Prefira mudanças pequenas, revisáveis e verificadas. Não reescreva arquivos
  ou descarte trabalho existente sem uma instrução explícita.
- Antes de corrigir bug não trivial, consulte `memoria-tecnica/bugs/`; ao
  descobrir causa-raiz reutilizável, registre uma nota com o template existente.

## Segurança e classes de risco

Siga `docs/security/data-classification.md`. Nunca versione, exiba em logs ou
cole em prompts: tokens, chaves API, senhas, cookies, dados pessoais reais ou
exports de clientes. Use `.env` local e exemplos sem segredos.

| Nível | Exemplos | Regra |
| --- | --- | --- |
| R0 | Leitura, docs, templates, testes locais | Executar e validar normalmente. |
| R1 | Código, dependência, schema, automação e configuração compartilhada | Declarar impacto, testar e pedir revisão. |
| R2 | Produção, cobrança, credenciais, dados de cliente, exclusão e escrita externa | Exigir autorização explícita e alvo confirmado. |

## Definition of Done

Uma entrega só está pronta quando:

1. atende a uma spec ou escopo escrito e tem critérios de aceite verificáveis;
2. executa os testes e validações que realmente existem, reportando o resultado;
3. atualiza spec, roadmap, ADR ou segurança quando o contrato mudou;
4. não introduz segredo, credencial ou dado restrito no repositório;
5. passa por revisão proporcional ao risco e deixa um diff compreensível;
6. registra handoff com mudanças, validações, decisões, riscos e pendências.

Não afirme que testes, CI, deploy ou sincronização passaram sem evidência.

## Revisão e handoff entre agentes

Claude e Codex seguem este arquivo como núcleo comum. Quem implementa deve
entregar ao revisor independente uma síntese curta:

```text
Escopo: …
Mudanças: …
Validações executadas e resultado: …
Decisões/ADRs: …
Riscos, bloqueios e próximos passos: …
```

Para R1/R2, peça revisão focada em comportamento, segurança e testes; não use
o revisor apenas para estilo. Procedimentos longos pertencem a skills ou à
documentação apontada acima, não a este contexto automático.
