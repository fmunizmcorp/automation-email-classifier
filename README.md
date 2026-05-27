# Email Classifier - Clínica

> ⚠️ **DEPRECATED** — Este repositório foi arquivado em 2026-05-17.
> Veja [DEPRECATED.md](DEPRECATED.md) para detalhes.
> Substituído por **[InteliMail (Organizemailclinica)](https://github.com/fmunizmcorp/Organizemailclinica)**.

---

## Sistema de Classificação Automática de E-mails (histórico)

Sistema completo para classificação automática de e-mails da clínica usando IA, com criação automática de chamados no osTicket.

**Importante:** este projeto nunca foi colocado em produção. Os workflows n8n nunca foram importados.
O conteúdo aqui é referência histórica. Para qualquer nova capacidade de email, use o InteliMail.

## 🎯 Objetivo

Automatizar a classificação e o tratamento de e-mails recebidos na clínica, separando:

- **Spam/Promo** (com aprovação manual antes do descarte/descadastramento)
- **Cliente/Paciente** (criação de tickets no osTicket)
- **Administrativo** (criação de tickets em departamentos específicos)

## 📋 Arquitetura

```
Google Workspace (Gmail API)
         ↓
    N8N Workflow
   (Email Reader)
         ↓
    OpenAI GPT-4
   (Classificação)
         ↓
    ┌────┴────┐
    ↓         ↓
  Spam     Cliente/Admin
  (Aprov)   ↓
           osTicket API
              ↓
          PostgreSQL
          (bdn8n.automation_email_classifier)
              ↓
           Metabase
          (Dashboard)
```

## 🗂️ Estrutura

```
automation-email-classifier/
├── README.md             # Este arquivo (banner DEPRECATED no topo)
├── DEPRECATED.md         # Aviso oficial de depreciação
├── CLAUDE.md             # Protocolo Claude Code (histórico)
├── database/             # 8 migrations SQL + 6 views Metabase + seeds
├── n8n/                  # 6 workflows JSON (nunca importados)
├── docs/                 # >90 KB de documentação técnica
└── graphify-out/         # Knowledge graph gerado
```

## 📌 Por que arquivado

- Parado há ~5 meses, nunca importado no n8n
- Inconsistências entre spec e implementação
- Duplicava capacidades já cobertas pelo InteliMail (em produção)

## 📚 Referências

- Substituto: https://github.com/fmunizmcorp/Organizemailclinica
- ADR de depreciação: maestro/decisions/2026-05-17-ADR-002-deprecate-n8n-classifier.md
- Documentação técnica preservada: ver pasta `docs/`
