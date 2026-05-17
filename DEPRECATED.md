# ⚠️ DEPRECATED — Repositório arquivado

**Data:** 2026-05-17
**Status:** DEPRECATED
**Substituído por:** [`fmunizmcorp/Organizemailclinica`](https://github.com/fmunizmcorp/Organizemailclinica) (InteliMail)
**ADR:** [maestro/decisions/2026-05-17-ADR-002-deprecate-n8n-classifier.md](https://github.com/fmunizmcorp/maestro/blob/claude/email-integration-solutions-5sHqM/decisions/2026-05-17-ADR-002-deprecate-n8n-classifier.md)

## Por que foi deprecado

Este repositório implementava um classificador de email em **n8n + PostgreSQL + GPT-4 + osTicket**. Apesar de bem desenhado e documentado (>90 KB de documentação técnica), ele:

- Nunca foi importado no n8n (parado há ~5 meses)
- Tem inconsistências entre spec e código (`processing_status` vs `status`, webhook vs polling)
- Compete com o **InteliMail (Organizemailclinica)** que já está em produção em `intelimail.clinfec.com.br`

O Maestro consolidou a estratégia de email no ADR-001:

> InteliMail é o classificador canônico da empresa. Todas as capacidades de classificação, leitura e envio de email vivem nele.

## O que foi preservado

O Maestro absorveu como **heranças** em `projects/intelimail.md`:

- Schema PostgreSQL (`automation_email_classifier`, 8 tabelas + 6 views Metabase) — referência para futura camada BI
- Sistema de SLAs versionados em banco — adotar em tabela `slas` futura no InteliMail
- Workflow de aprovação humana de spam — feature backlog do InteliMail
- Prompt OpenAI estruturado JSON — padrão já em uso no InteliMail
- Integração osTicket REST — manter especificação caso a empresa volte a usar osTicket

## Como migrar se você usa este repo

Você provavelmente não usa — ele nunca foi importado no n8n de produção. Mas se planejava usar:

1. **Para classificar emails** — use a API v1 do InteliMail:
   ```
   POST https://intelimail.clinfec.com.br/api/v1/classify
   Header: X-API-Key: <chave>
   Body: {"subject": "...", "body": "...", "sender": "..."}
   ```
2. **Para enviar email transacional** — use `/api/v1/send` do InteliMail (ver ADR-003 no Maestro).
3. **Para abrir tickets osTicket** — não há substituto direto. Se necessário, o InteliMail pode receber endpoint `/api/v1/tickets` em rodada futura.

## Segurança

Este repo é **público** e contém credenciais em texto claro (Postgres, n8n, osTicket, Gmail). Issue de rotação a ser aberta pelo Diretor.

Até lá: **não use as credenciais aqui** — todas precisam ser consideradas comprometidas.

## Histórico Git

O histórico permanece disponível para consulta. Não há plano de deleção.
