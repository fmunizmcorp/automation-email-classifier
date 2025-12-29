# 🏗️ Arquitetura do Sistema - Email Classifier

## 📋 Visão Geral

Sistema inteligente de classificação automática de emails do Google Workspace utilizando IA (OpenAI GPT-4), com criação automática de chamados no osTicket, roteamento por departamento, cache Redis e dashboards em tempo real.

---

## 🎯 Componentes Principais

### 1. **Gmail API** (Fonte de Dados)
- **Função:** Leitura de emails não lidos do INBOX
- **Polling:** A cada 1 minuto
- **Autenticação:** OAuth2
- **Operações:**
  - Ler emails novos (is:unread)
  - Marcar como processado (label PROCESSED)
  - Enviar confirmações e notificações
  - Download de anexos

### 2. **N8N Workflows** (Orquestração)
- **Workflow 1:** Email Reader - Leitura e inserção inicial
- **Workflow 2:** AI Classifier - Classificação com OpenAI
- **Workflow 3:** Spam Manager - Gestão de spam
- **Workflow 4:** Client Ticket Creator - Chamados de clientes
- **Workflow 5:** Admin Ticket Creator - Chamados administrativos
- **Workflow 6:** Dashboard Alerts - Monitoramento e alertas

**URL N8N:** https://n8n-n8n.aymebz.easypanel.host

### 3. **OpenAI GPT-4** (Inteligência Artificial)
- **Função:** Classificação inteligente de emails
- **Modelo:** gpt-4 (temperature: 0.3)
- **Prompt Engineering:** Otimizado para contexto de clínica
- **Output:** JSON estruturado com classificação
- **Métricas:**
  - Confidence Score (0-100%)
  - Sentiment Analysis
  - Entity Extraction
  - Keywords Extraction

### 4. **PostgreSQL Database** (Persistência)
- **Host:** 72.62.12.216:5432
- **Database:** bdn8n
- **Schema:** automation_email_classifier
- **Tabelas:** 8 tabelas principais
- **Views:** 6 views para Metabase
- **Índices:** Otimizados para performance

**Estrutura de Dados:**
```
automation_email_classifier/
├── emails (emails processados)
├── classifications (classificações IA)
├── tickets (chamados osTicket)
├── spam_approvals (aprovações spam)
├── departments (departamentos)
├── slas (configurações SLA)
├── knowledge_base (base conhecimento)
└── chat_history (histórico chat)
```

### 5. **osTicket** (Sistema de Tickets)
- **URL:** https://www.clinfec.com.br/osticket/
- **API:** REST API para criação de tickets
- **Integração:** Automática via N8N
- **Funcionalidades:**
  - Criação automática de chamados
  - Roteamento por departamento
  - SLA tracking
  - Anexos de emails
  - Histórico completo

### 6. **Redis Cache** (Performance)
- **Função:** Cache da base de conhecimento
- **TTL:** 24 horas (configurável)
- **Uso:**
  - Armazenar conhecimento frequente
  - Acelerar consultas de chat
  - Reduzir carga no PostgreSQL
  - Cache de embeddings (futuro)

### 7. **Metabase** (Analytics)
- **URL:** https://metabase-metabase.aymebz.easypanel.host
- **Dashboards:** 6 dashboards principais
- **Conexão:** PostgreSQL views otimizadas
- **Atualização:** Tempo real
- **Métricas:**
  - Volume de emails
  - Classificações por tipo
  - Performance de SLA
  - Tickets por departamento
  - Gestão de spam
  - Estatísticas de conhecimento

---

## 🔄 Fluxo de Processamento

### Fluxo Principal de Email

```
┌─────────────────────────────────────────────────────────────────┐
│                      1. ENTRADA DE EMAIL                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Gmail Trigger   │
                    │  (Every 1 min)   │
                    └──────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                2. ARMAZENAMENTO INICIAL (PostgreSQL)             │
│  - Inserir email na tabela 'emails'                             │
│  - Status: 'pending'                                             │
│  - Retornar email_id                                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    3. MARCAR NO GMAIL                            │
│  - Adicionar label: PROCESSED                                    │
│  - Remover label: UNREAD                                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│               4. CLASSIFICAÇÃO IA (OpenAI GPT-4)                 │
│  - Analisar conteúdo do email                                   │
│  - Classificar: SPAM / CLIENT / ADMIN                           │
│  - Calcular confidence score                                     │
│  - Extrair keywords e entities                                   │
│  - Determinar departamento e SLA                                 │
│  - Inserir em 'classifications'                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  IF: Tipo de     │
                    │  Classificação   │
                    └──────────────────┘
                   /          |          \
                  /           |           \
                 /            |            \
                ▼             ▼             ▼
        ┌──────────┐  ┌────────────┐  ┌──────────┐
        │   SPAM   │  │   CLIENT   │  │  ADMIN   │
        └──────────┘  └────────────┘  └──────────┘
              │              │              │
              ▼              ▼              ▼
┌─────────────────────┐┌─────────────────────┐┌─────────────────────┐
│  5a. SPAM MANAGER   ││ 5b. CLIENT TICKET   ││ 5c. ADMIN TICKET    │
│                     ││     CREATOR         ││     CREATOR         │
│  - Detectar tipo    ││                     ││                     │
│  - Calcular score   ││  - Extrair dados    ││  - Detectar docs    │
│  - Criar approval   ││    cliente          ││  - Check duplicate  │
│  - Enviar p/gestor  ││  - Criar ticket     ││  - Criar ticket     │
│  - Aguardar resposta││    osTicket         ││    osTicket         │
│                     ││  - Calcular SLA     ││  - Routing complexo │
│  → Se aprovado:     ││  - Enviar           ││  - Store metadata   │
│    - Unsubscribe    ││    confirmação      ││                     │
│    - Archive        ││  - Upload anexos    ││                     │
└─────────────────────┘└─────────────────────┘└─────────────────────┘
              │              │              │
              └──────────────┴──────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              6. CRIAR BASE DE CONHECIMENTO                       │
│  - Armazenar conteúdo processado                                │
│  - Gerar embeddings (futuro)                                     │
│  - Cache Redis (TTL: 24h)                                        │
│  - Disponibilizar para chat                                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                7. ATUALIZAR STATUS FINAL                         │
│  - Status: 'completed'                                           │
│  - processing_completed_at                                       │
│  - Update metrics                                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Modelo de Dados

### Relacionamentos Entre Tabelas

```
┌──────────────┐
│   emails     │◄───┐
└──────────────┘    │
       │            │
       │ 1          │
       │            │
       ▼ N          │
┌──────────────────┐│
│classifications   ││
└──────────────────┘│
       │            │
       │ 1          │
       │            │
       ▼ N          │
┌──────────────────┐│
│    tickets       │┤
└──────────────────┘│
       │            │
       ├────────────┘
       │
       ├─────► ┌──────────────┐
       │        │ departments  │
       │        └──────────────┘
       │
       └─────► ┌──────────────┐
                │     slas     │
                └──────────────┘

┌──────────────────┐
│ spam_approvals   │
└──────────────────┘
       ▲
       │ N
       │
       │ 1
┌──────────────┐
│   emails     │
└──────────────┘

┌──────────────────┐
│ knowledge_base   │
└──────────────────┘
       ▲
       │ N
       ├──────────┐
       │          │
┌──────────────┐  │
│   emails     │  │
└──────────────┘  │
                  │
┌──────────────┐  │
│   tickets    │──┘
└──────────────┘

┌──────────────────┐
│  chat_history    │
└──────────────────┘
       │
       │ N:N (array)
       │
       ▼
┌──────────────────┐
│ knowledge_base   │
└──────────────────┘
```

---

## 🔐 Segurança

### Autenticação e Autorização

1. **Gmail OAuth2**
   - Scopes limitados
   - Refresh token seguro
   - Rotação automática

2. **PostgreSQL**
   - Conexões SSL/TLS
   - User com permissões limitadas
   - Schema isolation

3. **OpenAI API**
   - API Key em variáveis de ambiente
   - Rate limiting
   - Monitoring de uso

4. **osTicket API**
   - API Key dedicada
   - HTTPS only
   - IP whitelist (opcional)

5. **N8N Webhooks**
   - Authentication headers
   - HTTPS only
   - Webhook IDs únicos

### Dados Sensíveis

- **Emails:** Armazenados com criptografia no banco
- **Credenciais:** Vault do N8N
- **Logs:** Sanitizados (sem passwords/tokens)
- **Backups:** Encrypted at rest

---

## ⚡ Performance

### Otimizações Implementadas

1. **Índices PostgreSQL**
   - Índices em foreign keys
   - Índices em campos de busca frequente
   - Partial indexes para status específicos
   - GIN indexes para arrays e full-text

2. **Views Materializadas** (futuro)
   - Dashboard overview
   - Caching de agregações

3. **Redis Cache**
   - Knowledge base frequente
   - Resultados de queries pesadas
   - TTL configurável

4. **N8N Optimization**
   - Polling interval: 1 minuto (ajustável)
   - Batch processing (até 10 emails)
   - Retry logic com backoff
   - Error handling robusto

5. **OpenAI Usage**
   - Temperature baixa (0.3) para consistency
   - Max tokens limitado (500)
   - Caching de classificações similares (futuro)

### Capacidade Esperada

- **Emails/dia:** ~1000-2000
- **Emails/hora:** ~100-150 (pico)
- **Tempo médio processamento:** 5-10 segundos
- **Concurrent workflows:** 5-10
- **Database connections:** Pool de 20

---

## 📈 Escalabilidade

### Horizontal Scaling

1. **N8N Workers**
   - Múltiplas instâncias N8N
   - Load balancing de webhooks
   - Queue-based processing

2. **PostgreSQL**
   - Read replicas para queries
   - Write to primary
   - Connection pooling (PgBouncer)

3. **Redis**
   - Redis Cluster para high availability
   - Replication para read scaling

### Vertical Scaling

- Aumentar recursos VPS
- Otimizar queries
- Adicionar mais índices
- Tuning PostgreSQL

---

## 🔍 Monitoramento

### Métricas Coletadas

1. **Email Processing**
   - Emails recebidos/hora
   - Tempo médio de processamento
   - Taxa de sucesso/falha
   - Emails pendentes

2. **Classification Accuracy**
   - Confidence score médio
   - Taxa de validação correta
   - Distribuição por tipo

3. **SLA Compliance**
   - % SLA resposta atendido
   - % SLA resolução atendido
   - Tickets at-risk
   - Tempo médio de resposta

4. **System Health**
   - CPU/Memory usage
   - Database connections
   - API response times
   - Error rates

### Alertas Configurados

- SLA at-risk (< 1 hora)
- Processing failures (> 5%)
- Queue backlog (> 50 emails)
- API rate limits approaching
- Database disk space (> 80%)

---

## 🛠️ Manutenção

### Rotinas Diárias

- ✅ Verificar dashboard de métricas
- ✅ Revisar emails falhos
- ✅ Verificar spam approvals pendentes
- ✅ Monitoring de SLA

### Rotinas Semanais

- ✅ Revisar classificações validadas
- ✅ Otimizar queries lentas
- ✅ Backup do banco
- ✅ Atualizar conhecimento base

### Rotinas Mensais

- ✅ Análise de custos OpenAI
- ✅ Review de SLAs
- ✅ Performance tuning
- ✅ Security audit

---

## 🚀 Deploy e CI/CD

### Pipeline de Deploy

1. **Development**
   - Testes locais
   - Validação de schemas
   - Lint de workflows

2. **Staging**
   - Deploy em ambiente de testes
   - Testes end-to-end
   - Validação de integrações

3. **Production**
   - Deploy via EasyPanel
   - Smoke tests
   - Monitoring ativo

### Rollback Plan

1. Desativar workflows N8N
2. Restore database backup
3. Revert workflows para versão anterior
4. Reativar workflows
5. Monitoring intensivo

---

## 📚 Referências Técnicas

- **N8N Documentation:** https://docs.n8n.io
- **OpenAI API:** https://platform.openai.com/docs
- **PostgreSQL 15:** https://www.postgresql.org/docs/15
- **osTicket API:** https://docs.osticket.com/en/latest/Developer%20Documentation/API
- **Gmail API:** https://developers.google.com/gmail/api
- **Metabase:** https://www.metabase.com/docs

---

**Última atualização:** 2025-12-29  
**Versão:** 1.0  
**Status:** Produção Ready
