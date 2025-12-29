# 📧 Automação: Email Classifier com IA

## 🎯 Objetivo

Sistema inteligente de classificação automática de emails do Google Workspace com IA (OpenAI GPT-4), criação automática de chamados no osTicket, roteamento inteligente por departamento e prioridade, cache Redis para base de conhecimento e dashboards em tempo real no Metabase.

## 📋 Descrição

Esta automação processa emails recebidos nas contas/grupos do Google Workspace da empresa, utilizando Inteligência Artificial para:

1. **Classificar automaticamente** em 3 categorias:
   - 🗑️ **Spam/Promoções**: Listados para aprovação do gestor → Descadastramento automático
   - 👤 **Cliente/Paciente**: Criação automática de chamado no osTicket com SLA apropriado
   - 📋 **Administrativo**: Criação de chamado para área administrativa (NF, boletos, etc.)

2. **Processar inteligentemente**:
   - Extração de anexos e salvamento na pasta do paciente/cliente
   - Identificação de tipo de solicitação (informação, orçamento, serviço, urgência)
   - Cálculo automático de prioridade e tempo de SLA
   - Roteamento para departamento responsável

3. **Base de Conhecimento**:
   - Armazenamento de todos os emails processados
   - Cache Redis para acesso rápido pela IA
   - Interface de chat para consulta organizada
   - Histórico completo de interações

## 🏗️ Arquitetura

```
┌─────────────────┐
│ Google Workspace│
│   (Gmail API)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  N8N Workflow   │
│  Email Reader   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   OpenAI GPT-4  │
│  (Classificação)│
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼         ▼
┌───────┐ ┌──────┐ ┌────────┐
│ Spam  │ │Client│ │  Admin │
│Manager│ │Ticket│ │ Ticket │
└───────┘ └──────┘ └────────┘
    │         │         │
    ▼         ▼         ▼
┌─────────────────────────┐
│      osTicket API       │
└─────────────────────────┘
         │
         ▼
┌─────────────────────────┐
│  PostgreSQL Database    │
│  + Redis Cache          │
└─────────────────────────┘
         │
         ▼
┌─────────────────────────┐
│   Metabase Dashboard    │
└─────────────────────────┘
```

## 🗂️ Estrutura do Projeto

```
automation-email-classifier/
├── README.md                 # Este arquivo
├── .gitignore               # Arquivos ignorados pelo Git
├── database/                # Banco de dados
│   ├── migrations/          # Migrations SQL (8 tabelas)
│   ├── seeds/               # Dados iniciais
│   └── views/               # Views para Metabase
├── n8n/                     # Workflows N8N
│   └── workflows/           # 6 workflows JSON
├── docs/                    # Documentação completa
│   ├── ARCHITECTURE.md      # Arquitetura detalhada
│   ├── SETUP.md            # Guia de instalação
│   ├── API.md              # Documentação de APIs
│   └── TROUBLESHOOTING.md  # Resolução de problemas
├── scripts/                 # Scripts utilitários
│   ├── deploy.sh           # Script de deployment
│   ├── backup.sh           # Script de backup
│   └── test.sh             # Script de testes
└── tests/                   # Testes automatizados
    ├── unit/               # Testes unitários
    └── integration/        # Testes de integração
```

## 🚀 Status da Implementação

### ✅ Concluído (15%)
- [x] Repositório GitHub criado
- [x] Schema PostgreSQL `automation_email_classifier` criado
- [x] Estrutura de diretórios completa
- [x] .gitignore e README inicial

### 🔄 Em Progresso (0%)
- [ ] 8 Tabelas do banco de dados
- [ ] Views para dashboard
- [ ] Seed inicial
- [ ] 6 Workflows N8N
- [ ] Integração OpenAI
- [ ] Integração osTicket
- [ ] Cache Redis
- [ ] Dashboard Metabase

### ⏳ Pendente (85%)
- [ ] Testes end-to-end
- [ ] Deploy em produção
- [ ] Documentação completa
- [ ] Monitoramento e alertas

## 🔗 Links Importantes

- **Repositório GitHub**: https://github.com/fmunizmcorp/automation-email-classifier
- **N8N**: https://n8n-n8n.aymebz.easypanel.host
- **Metabase**: https://metabase-metabase.aymebz.easypanel.host
- **osTicket**: https://www.clinfec.com.br/osticket/
- **PostgreSQL**: 72.62.12.216:5432 (database: bdn8n, schema: automation_email_classifier)

## 📊 Métricas Esperadas

- **Redução de trabalho manual**: 90%
- **Tempo de resposta**: < 5 minutos
- **Precisão de classificação**: > 95%
- **SLA de atendimento**: Melhorado em 50%
- **Satisfação do cliente**: Aumentada

## 🔒 Credenciais

Todas as credenciais estão armazenadas em:
- `/home/user/webapp/CREDENCIAIS_CONSOLIDADAS.md` (desenvolvimento)
- Vault seguro (pós-implantação)

## 📅 Histórico

- **2025-12-29 05:40 UTC**: Início da implementação
- **2025-12-29 05:45 UTC**: Setup inicial concluído (15%)

## 👥 Equipe

- **Cliente**: Flávio Muniz (fmunizm@gmail.com)
- **Projeto**: Sistema de Monitoramento - Clínica Clinfec
- **Consultor N8N**: GenSpark AI Developer

## 📝 Próximos Passos

1. Criar 8 tabelas do banco de dados com migrations
2. Implementar 6 workflows N8N
3. Configurar integrações (Gmail, OpenAI, osTicket, Redis)
4. Criar dashboard Metabase
5. Testes e validação
6. Deploy em produção

---

**Última atualização**: 2025-12-29 05:45 UTC  
**Status**: 🔄 Em desenvolvimento (15% concluído)  
**Tempo estimado para conclusão**: 10-12 horas
