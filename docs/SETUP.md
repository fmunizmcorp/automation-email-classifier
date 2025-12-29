# 🚀 Guia de Setup - Email Classifier

## 📋 Pré-requisitos

- ✅ Acesso ao VPS Hostinger (72.62.12.216)
- ✅ EasyPanel instalado e configurado
- ✅ PostgreSQL 15+ rodando
- ✅ N8N instalado via EasyPanel
- ✅ Conta Google Workspace
- ✅ Conta OpenAI com API Key
- ✅ osTicket instalado e configurado
- ✅ Metabase instalado via EasyPanel

---

## 🗂️ Passo 1: Configuração do PostgreSQL

### 1.1 Verificar Schema

```bash
# Conectar ao PostgreSQL
PGPASSWORD='6DCAt6MBuK4yH8h2Q8pL' psql -h 72.62.12.216 -p 5432 -U postgres -d bdn8n

# Verificar schema
\dn automation_email_classifier

# Verificar tabelas
\dt automation_email_classifier.*

# Verificar views
\dv automation_email_classifier.*
```

Saída esperada:
- Schema: automation_email_classifier
- Tabelas: 8 (emails, classifications, tickets, spam_approvals, departments, slas, knowledge_base, chat_history)
- Views: 6 (dashboard_overview, view_classifications_analysis, etc)

### 1.2 Executar Migrations (se necessário)

```bash
cd /path/to/automation-email-classifier/database/migrations

# Executar todas as migrations em ordem
for file in $(ls -1 *.sql | sort); do
  echo "Executing migration: $file"
  PGPASSWORD='6DCAt6MBuK4yH8h2Q8pL' psql -h 72.62.12.216 -p 5432 -U postgres -d bdn8n -f "$file"
done
```

### 1.3 Executar Seeds

```bash
cd /path/to/automation-email-classifier/database/seeds

# Executar seeds
for file in $(ls -1 *.sql | sort); do
  echo "Executing seed: $file"
  PGPASSWORD='6DCAt6MBuK4yH8h2Q8pL' psql -h 72.62.12.216 -p 5432 -U postgres -d bdn8n -f "$file"
done
```

### 1.4 Verificar Dados Iniciais

```sql
-- Verificar departamentos
SELECT code, name FROM automation_email_classifier.departments ORDER BY code;

-- Verificar SLAs
SELECT code, name, response_time_minutes, resolution_time_minutes 
FROM automation_email_classifier.slas 
ORDER BY priority DESC;
```

---

## 🔧 Passo 2: Configuração do N8N

### 2.1 Acessar N8N

- **URL:** https://n8n-n8n.aymebz.easypanel.host
- **Login:** gensparkflavio
- **Senha:** gensparkflavio89742937592

### 2.2 Configurar Credenciais

#### 2.2.1 Gmail OAuth2

1. Ir em: Settings → Credentials → Add Credential
2. Selecionar: Google → Gmail OAuth2
3. Configurar:
   - Client ID: (obter do Google Cloud Console)
   - Client Secret: (obter do Google Cloud Console)
   - Scopes: 
     - https://www.googleapis.com/auth/gmail.readonly
     - https://www.googleapis.com/auth/gmail.modify
     - https://www.googleapis.com/auth/gmail.send
4. Clicar em "Connect my account"
5. Autorizar acesso
6. Salvar

**Como obter Client ID/Secret:**
1. Acessar: https://console.cloud.google.com
2. Criar novo projeto ou selecionar existente
3. Ativar Gmail API
4. Ir em: Credentials → Create Credentials → OAuth 2.0 Client ID
5. Application Type: Web Application
6. Authorized redirect URIs: https://n8n-n8n.aymebz.easypanel.host/rest/oauth2-credential/callback
7. Copiar Client ID e Client Secret

#### 2.2.2 PostgreSQL

1. Add Credential → PostgreSQL
2. Configurar:
   - **Name:** PostgreSQL - bdn8n
   - **Host:** 72.62.12.216
   - **Port:** 5432
   - **Database:** bdn8n
   - **User:** postgres
   - **Password:** 6DCAt6MBuK4yH8h2Q8pL
   - **SSL:** Disable (ou configurar certificado)
3. Test connection
4. Save

#### 2.2.3 OpenAI

1. Add Credential → OpenAI
2. Configurar:
   - **API Key:** (obter em https://platform.openai.com/api-keys)
   - **Organization ID:** (opcional)
3. Test connection
4. Save

**Como obter OpenAI API Key:**
1. Acessar: https://platform.openai.com
2. Login ou criar conta
3. Ir em: API Keys
4. Criar nova API Key
5. Copiar e salvar (não pode ver novamente)
6. Adicionar créditos na conta (mínimo $5)

#### 2.2.4 osTicket API

1. Add Credential → HTTP Header Auth
2. Configurar:
   - **Name:** osTicket API
   - **Header Name:** X-API-Key
   - **Header Value:** (gerar no osTicket - ver abaixo)
3. Save

**Como gerar osTicket API Key:**
1. Acessar: https://www.clinfec.com.br/osticket/scp
2. Login: clinfecbsb@gmail.com / n8nautomacao
3. Ir em: Admin Panel → Manage → API Keys
4. Add New API Key
5. Configurar:
   - Status: Active
   - IP Address: 72.62.12.216 (VPS IP) ou vazio
   - Notes: "N8N Automation"
6. Copiar API Key gerada

### 2.3 Criar Pasta de Workflows

1. No N8N, clicar em "Workflows"
2. Criar nova pasta: "EmailClassifier"
3. Mover todos workflows para esta pasta

### 2.4 Importar Workflows

Para cada workflow em `/n8n/workflows/`:

1. Clicar em "Add workflow"
2. Nome do workflow (ex: "Email Classifier - 01 Email Reader")
3. Adicionar nodes conforme especificação em WORKFLOWS_SPECIFICATION.md
4. Configurar credenciais em cada node
5. Testar cada node individualmente
6. Save workflow
7. **NÃO ATIVAR AINDA** (ativar na ordem correta depois)

**Ordem de criação:**
1. ✅ Workflow 6: Dashboard Alerts
2. ✅ Workflow 3: Spam Manager
3. ✅ Workflow 4: Client Ticket Creator
4. ✅ Workflow 5: Admin Ticket Creator
5. ✅ Workflow 2: AI Classifier
6. ✅ Workflow 1: Email Reader

---

## 📊 Passo 3: Configuração do Metabase

### 3.1 Acessar Metabase

- **URL:** https://metabase-metabase.aymebz.easypanel.host
- **Login:** gensparkflavio
- **Senha:** gensparkflavio89742937592

### 3.2 Adicionar Database Connection

1. Ir em: Settings → Admin → Databases
2. Add Database
3. Configurar:
   - **Database type:** PostgreSQL
   - **Name:** Email Classifier
   - **Host:** 72.62.12.216
   - **Port:** 5432
   - **Database name:** bdn8n
   - **Username:** postgres
   - **Password:** 6DCAt6MBuK4yH8h2Q8pL
   - **Schema:** automation_email_classifier
4. Save
5. Sync database schema

### 3.3 Criar Dashboards

#### Dashboard 1: Overview Geral

1. New → Dashboard → "Email Classifier - Overview"
2. Adicionar perguntas:
   - **Total Emails:** `SELECT total_emails FROM automation_email_classifier.dashboard_overview`
   - **Emails Hoje:** `SELECT emails_today FROM automation_email_classifier.dashboard_overview`
   - **Taxa de Processamento:** `SELECT ROUND((emails_processed::DECIMAL / NULLIF(total_emails, 0) * 100), 2) as processing_rate FROM automation_email_classifier.dashboard_overview`
3. Add visualizations: Number, Line Chart, Pie Chart

#### Dashboard 2: Classificações

1. New → Dashboard → "Email Classifier - Classifications"
2. Question: `SELECT * FROM automation_email_classifier.view_classifications_analysis ORDER BY created_at DESC LIMIT 100`
3. Visualizations:
   - Pie Chart: Distribuição por tipo
   - Bar Chart: Classificações por hora
   - Table: Últimas classificações

#### Dashboard 3: SLA Performance

1. New → Dashboard → "Email Classifier - SLA"
2. Question: `SELECT * FROM automation_email_classifier.view_sla_performance WHERE status IN ('open', 'assigned', 'in_progress')`
3. Visualizations:
   - Gauge: SLA Compliance %
   - Table: Tickets at-risk
   - Line Chart: SLA trend

#### Dashboard 4: Tickets por Departamento

1. New → Dashboard → "Email Classifier - Departments"
2. Question: `SELECT * FROM automation_email_classifier.view_tickets_by_department`
3. Visualizations:
   - Bar Chart: Tickets por departamento
   - Table: Métricas por departamento
   - Heatmap: Volume por hora/dia

#### Dashboard 5: Gestão de Spam

1. New → Dashboard → "Email Classifier - Spam"
2. Question: `SELECT * FROM automation_email_classifier.view_spam_management WHERE approval_status = 'pending'`
3. Visualizations:
   - Number: Pendentes de aprovação
   - Table: Lista de spam
   - Pie Chart: Ações tomadas

#### Dashboard 6: Knowledge Base

1. New → Dashboard → "Email Classifier - Knowledge"
2. Question: `SELECT * FROM automation_email_classifier.view_knowledge_base_stats WHERE status = 'active' ORDER BY usage_count DESC LIMIT 50`
3. Visualizations:
   - Bar Chart: Top conteúdos mais usados
   - Table: Lista de conhecimento
   - Number: Total de itens

---

## 🔄 Passo 4: Testes Iniciais

### 4.1 Teste de Conexões

```bash
# Testar PostgreSQL
PGPASSWORD='6DCAt6MBuK4yH8h2Q8pL' psql -h 72.62.12.216 -p 5432 -U postgres -d bdn8n -c "SELECT COUNT(*) FROM automation_email_classifier.departments;"

# Testar Gmail API (via N8N)
# - Ir no workflow Email Reader
# - Clicar em "Execute Node" no Gmail Trigger
# - Verificar se retorna emails

# Testar OpenAI API (via N8N)
# - Criar workflow de teste
# - Adicionar node OpenAI
# - Enviar prompt simples
# - Verificar resposta

# Testar osTicket API
curl -X POST https://www.clinfec.com.br/osticket/api/tickets.json \
  -H "X-API-Key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Teste Sistema",
    "email": "teste@teste.com",
    "subject": "Teste de Integração",
    "message": "Este é um teste de integração da API.",
    "topicId": "1"
  }'
```

### 4.2 Teste End-to-End

1. **Enviar Email de Teste:**
   - De: seu_email@gmail.com
   - Para: conta_monitorada@clinfec.com.br
   - Assunto: "Teste - Solicitação de Orçamento"
   - Corpo: "Gostaria de solicitar um orçamento para consulta..."

2. **Verificar Processamento:**
   ```sql
   -- Verificar email inserido
   SELECT * FROM automation_email_classifier.emails 
   WHERE subject LIKE '%Teste%' 
   ORDER BY created_at DESC LIMIT 1;
   
   -- Verificar classificação
   SELECT * FROM automation_email_classifier.classifications 
   WHERE email_id = (SELECT id FROM automation_email_classifier.emails WHERE subject LIKE '%Teste%' ORDER BY created_at DESC LIMIT 1);
   
   -- Verificar ticket
   SELECT * FROM automation_email_classifier.tickets 
   WHERE email_id = (SELECT id FROM automation_email_classifier.emails WHERE subject LIKE '%Teste%' ORDER BY created_at DESC LIMIT 1);
   ```

3. **Verificar no osTicket:**
   - Acessar https://www.clinfec.com.br/osticket/scp
   - Verificar se ticket foi criado
   - Verificar departamento correto
   - Verificar SLA aplicado

4. **Verificar Dashboard Metabase:**
   - Acessar dashboard Overview
   - Verificar se métricas foram atualizadas
   - Verificar visualizações

---

## ✅ Passo 5: Ativação dos Workflows

**IMPORTANTE:** Ativar na ordem correta!

### 5.1 Ordem de Ativação

1. ✅ **Workflow 6: Dashboard Alerts**
   - Ativar primeiro para monitoramento
   - Verificar execução do cron

2. ✅ **Workflow 3: Spam Manager**
   - Ativar webhook de aprovação
   - Testar com email spam

3. ✅ **Workflow 4: Client Ticket Creator**
   - Ativar webhook
   - Testar com email cliente

4. ✅ **Workflow 5: Admin Ticket Creator**
   - Ativar webhook
   - Testar com email admin

5. ✅ **Workflow 2: AI Classifier**
   - Ativar webhook
   - Testar classificação

6. ✅ **Workflow 1: Email Reader** ⚠️ ATIVAR POR ÚLTIMO!
   - Ativar trigger do Gmail
   - Monitorar execuções

### 5.2 Checklist de Ativação

Para cada workflow:
- [ ] Credenciais configuradas
- [ ] Todos nodes testados
- [ ] Error handling configurado
- [ ] Logs ativados
- [ ] Workflow salvo
- [ ] Workflow ativado (toggle ON)
- [ ] Primeira execução bem-sucedida
- [ ] Monitoramento ativo

---

## 🔍 Passo 6: Monitoramento Inicial

### 6.1 Primeira Hora

- Verificar execuções N8N a cada 5 minutos
- Monitorar logs de erro
- Verificar inserções no banco
- Verificar criação de tickets

### 6.2 Primeiro Dia

- Revisar todas classificações
- Validar tickets criados
- Verificar SLA compliance
- Ajustar parâmetros se necessário

### 6.3 Primeira Semana

- Análise de performance
- Otimização de queries
- Ajuste de SLAs
- Feedback dos usuários

---

## 🆘 Troubleshooting

### Problema: Email não está sendo processado

**Solução:**
1. Verificar se Gmail Trigger está ativo
2. Verificar credenciais Gmail OAuth2
3. Verificar filtros (is:unread)
4. Verificar logs do workflow
5. Verificar rate limits do Gmail

### Problema: Classificação IA falhando

**Solução:**
1. Verificar API Key OpenAI
2. Verificar créditos na conta OpenAI
3. Verificar rate limits OpenAI
4. Verificar formato do prompt
5. Testar com email mais simples

### Problema: Ticket não criado no osTicket

**Solução:**
1. Verificar API Key osTicket
2. Verificar URL da API
3. Verificar formato do payload
4. Verificar topicId válido
5. Verificar logs osTicket

### Problema: Dashboard não atualiza

**Solução:**
1. Verificar conexão Metabase-PostgreSQL
2. Sync database schema
3. Refresh queries manualmente
4. Verificar views no PostgreSQL
5. Verificar cache do Metabase

---

## 📚 Próximos Passos

Após setup completo:

1. ✅ Documentar ajustes realizados
2. ✅ Criar runbook de operação
3. ✅ Treinar usuários
4. ✅ Estabelecer rotinas de manutenção
5. ✅ Configurar backups automáticos
6. ✅ Implementar alertas avançados
7. ✅ Otimizar performance
8. ✅ Expandir funcionalidades

---

## 📞 Suporte

- **Repositório GitHub:** https://github.com/fmunizmcorp/automation-email-classifier
- **Documentação:** Ver pasta `/docs`
- **Credenciais:** Ver `CREDENCIAIS_CONSOLIDADAS.md` no repositório principal

---

**Última atualização:** 2025-12-29  
**Versão:** 1.0  
**Tempo estimado de setup:** 2-3 horas
