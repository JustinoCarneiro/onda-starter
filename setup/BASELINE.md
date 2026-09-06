# OndaDev 3.0 - Baseline do ambiente

Data da coleta: 5 de setembro de 2026

Este documento registra o ponto inicial da migração para o OndaDev 3.0. Ele
não contém caminho de máquina, nome de usuário, e-mail, token, chave ou valor
de variável de ambiente.

## Snapshot observado

| Componente | Versão ou estado |
|---|---|
| Git | 2.43.0 |
| Node.js | 20.20.2 |
| npm | 10.8.2 |
| Docker | 29.7.2 |
| GitHub CLI | 2.96.0 |
| Claude Code | 2.1.197 |
| Codex CLI | 0.153.3 |
| VS Code | 1.136.0 |
| Extensão Claude Code | `anthropic.claude-code` detectada |
| Extensão VS Code OpenAI/Codex | não detectada pela varredura de nomes |
| `ANTHROPIC_API_KEY` | não definida no ambiente da coleta |

## Interpretação do baseline

- Node 20 atende ao ambiente existente, mas o PR-01 elevará o baseline para
  Node 22 ou superior antes de atualizar o método de instalação do Claude Code.
- A ausência de `ANTHROPIC_API_KEY` é intencional: Claude Code deve continuar
  usando a assinatura, sem alternar silenciosamente para cobrança de API.
- A extensão do Codex será escolhida e confirmada no Marketplace oficial no
  PR-04; esta coleta não assume um identificador de extensão.
- `AGENTS.md`, `.codex` e skills compartilhadas são entregas dos PRs seguintes;
  não são criados pelo PR-00.

## Contrato do verificador

Execute, a partir da raiz do repositório:

```bash
bash setup/check-environment.sh
```

O comando apenas consulta ferramentas e configurações. Ele não instala
dependências, autentica contas, cria arquivos, modifica variáveis de ambiente
nem revela valores sensíveis.

O código de saída é `0` quando todas as ferramentas mínimas estão disponíveis e
`1` quando alguma estiver ausente. Avisos não alteram o código de saída nesta
fase, pois a migração para Node 22 e a extensão Codex pertencem aos PRs 01 e 04.

## Insumos relativos para o futuro `AGENTS.md`

O PR-02 deverá referenciar somente caminhos relativos e comandos verificáveis:

```text
setup/check-environment.sh   # diagnóstico somente leitura
setup/install.sh             # instalador a ser modernizado no PR-01
setup/CHECKLIST.md           # ações manuais e autenticação
docs/                        # metodologia, design e métricas
scripts/                     # automações versionadas
```

Esses caminhos descrevem o repositório, não uma máquina específica.
