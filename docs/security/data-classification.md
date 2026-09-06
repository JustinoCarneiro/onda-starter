# Classificação de dados

| Classe | Exemplos | Tratamento mínimo |
| --- | --- | --- |
| Público | Marketing aprovado, documentação pública | Pode ser versionado após revisão. |
| Interno | Roadmap, estimativas e documentação operacional | Versionar apenas no repositório apropriado; compartilhar por necessidade. |
| Restrito | Segredos, tokens, senhas, PII, dados financeiros e exportações de clientes | Nunca versionar ou enviar a agentes; minimizar acesso, mascarar logs e usar cofre/variáveis locais. |

Dados restritos exigem autorização explícita para acesso, escrita externa,
movimentação, retenção ou descarte. Em dúvida, trate o dado como restrito.
