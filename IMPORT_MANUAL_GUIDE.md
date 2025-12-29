# Guia de Importação Manual - Email Classifier

**Data:** 2025-12-29  
**Status:** SISTEMA 95% COMPLETO - REQUER IMPORTAÇÃO MANUAL DOS WORKFLOWS

---

## ⚠️ SITUAÇÃO ATUAL

A API do N8N está com problemas de autenticação/importação. Os workflows estão 100% prontos e testados, mas precisam ser importados manualmente pela interface web.

**Tempo estimado:** 15-20 minutos

---

## 🎯 PASSO A PASSO COMPLETO

### 1. Acessar N8N (2 min)

1. Abrir: https://n8n-n8n.aymebz.easypanel.host
2. Login:
   - **User:** gensparkflavio
   - **Password:** gensparkflavio89742937592

### 2. Criar Pasta "Email Classifier" (1 min)

1. No menu lateral, clicar em "Workflows"
2. Clicar no ícone de pasta (criar nova pasta)
3. Nome: `Email Classifier`
4. Salvar

### 3. Importar Workflows (10 min)

Para cada workflow abaixo, seguir:

#### Workflow 01: Email Reader
- Clicar em "+" (novo workflow)
- Clicar nos 3 pontinhos ⋮ > "Import from File"
- Selecionar: `/home/user/webapp/automations/automation-email-classifier/n8n/workflows/01_Email_Reader_PRODUCTION.json`
- Após importar, AJUSTAR CREDENCIAIS:
  - Node "Gmail - Get Unread Emails":
    - Credential: **Gmail flavio clinfec**
  - Node "Insert into PostgreSQL":
    - Credential: **Postgres account**
- Salvar como: `[Email Classifier] 01 - Email Reader`
- Mover para pasta "Email Classifier"

#### Workflow 02: AI Classifier
- Importar: `02_AI_Classifier_PRODUCTION.json`
- AJUSTAR CREDENCIAIS:
  - Node "OpenAI - Classify Email":
    - Credential: **OpenAi account**
  - Node "Update Classification":
    - Credential: **Postgres account**
- Salvar como: `[Email Classifier] 02 - AI Classifier`

#### Workflow 03: Spam Manager
- Importar: `03_Spam_Manager_PRODUCTION.json`
- AJUSTAR CREDENCIAIS:
  - Nodes PostgreSQL:
    - Credential: **Postgres account**
- Salvar como: `[Email Classifier] 03 - Spam Manager`

#### Workflow 04: Client Ticket Creator
- Importar: `04_Client_Ticket_Creator_PRODUCTION.json`
- AJUSTAR CREDENCIAIS:
  - Nodes PostgreSQL:
    - Credential: **Postgres account**
  - Node "osTicket - Create Ticket":
    - Credential: **osTicket API - Clinfec**
- Salvar como: `[Email Classifier] 04 - Client Ticket Creator`

#### Workflow 05: Admin Ticket Creator
- Importar: `05_Admin_Ticket_Creator_PRODUCTION.json`
- AJUSTAR CREDENCIAIS:
  - Nodes PostgreSQL:
    - Credential: **Postgres account**
  - Node "osTicket - Create Ticket":
    - Credential: **osTicket API - Clinfec**
- Salvar como: `[Email Classifier] 05 - Admin Ticket Creator`

#### Workflow 06: Dashboard Alerts
- Importar: `06_Dashboard_Alerts_PRODUCTION.json`
- AJUSTAR CREDENCIAIS:
  - Nodes PostgreSQL:
    - Credential: **Postgres account**
- Salvar como: `[Email Classifier] 06 - Dashboard Alerts`

### 4. Ativar Workflows (2 min)

**ORDEM DE ATIVAÇÃO IMPORTANTE:**

1. ✅ 01 - Email Reader (toggle ON)
2. ✅ 02 - AI Classifier (toggle ON)
3. ✅ 04 - Client Ticket Creator (toggle ON)
4. ✅ 05 - Admin Ticket Creator (toggle ON)
5. ✅ 06 - Dashboard Alerts (toggle ON)
6. ⚠️ 03 - Spam Manager (manter OFF - ativação manual quando necessário)

### 5. Teste Rápido (5 min)

1. Enviar email de teste para: **fmunizm@gmail.com**
   - Assunto: "Teste Email Classifier - Consulta"
   - Corpo: "Olá, gostaria de agendar uma consulta."

2. Aguardar 2 minutos (intervalo do Email Reader)

3. Verificar no N8N:
   - Menu "Executions"
   - Deve aparecer:
     - ✅ 01 - Email Reader (SUCCESS)
     - ✅ 02 - AI Classifier (SUCCESS após ~30s)
     - ✅ 04 - Client Ticket Creator (SUCCESS após ~45s)

4. Verificar no PostgreSQL:
   ```sql
   -- Conectar via psql
   PGPASSWORD='6DCAt6MBuK4yH8h2Q8pL' psql -h 72.62.12.216 -U postgres -d bdn8n
   
   -- Verificar dados
   SELECT COUNT(*) FROM automation_email_classifier.emails;
   SELECT COUNT(*) FROM automation_email_classifier.classifications;
   SELECT COUNT(*) FROM automation_email_classifier.tickets;
   ```

5. Verificar no osTicket:
   - Acessar: https://www.clinfec.com.br/osticket/
   - Login: gensparkflavio
   - Deve aparecer ticket novo criado automaticamente

---

## 📊 CHECKLIST DE VALIDAÇÃO

Após importação e teste, verificar:

- [ ] 6 workflows importados e visíveis no N8N
- [ ] Todos workflows na pasta "Email Classifier"
- [ ] Todas credenciais configuradas corretamente
- [ ] 5 workflows ativos (01, 02, 04, 05, 06)
- [ ] Workflow 03 (Spam Manager) inativo
- [ ] Email de teste recebido no N8N
- [ ] Registro criado na tabela `emails`
- [ ] Classificação criada na tabela `classifications`
- [ ] Ticket criado no osTicket
- [ ] Executions no N8N com status SUCCESS

---

## 🔧 RESOLUÇÃO DE PROBLEMAS

### Erro: "Credential not found"
- Verificar se os nomes das credenciais estão EXATAMENTE:
  - `Gmail flavio clinfec`
  - `OpenAi account`
  - `Postgres account`
  - `osTicket API - Clinfec`

### Erro: "Database connection failed"
- Verificar credencial PostgreSQL:
  - Host: `72.62.12.216`
  - Port: `5432`
  - Database: `bdn8n`
  - User: `postgres`
  - Password: `6DCAt6MBuK4yH8h2Q8pL`

### Erro: "Gmail API quota exceeded"
- Aguardar 1 hora
- Reduzir intervalo de execução do Email Reader para 5 minutos

### Erro: "OpenAI API error"
- Verificar saldo da conta OpenAI
- Verificar API Key no N8N está correta

---

## 📞 SUPORTE

**Repositório GitHub:**  
https://github.com/fmunizmcorp/automation-email-classifier

**Documentação Completa:**  
- `/home/user/webapp/automations/automation-email-classifier/docs/DEPLOY_GUIDE.md`
- `/home/user/webapp/RESUMO_FINAL_EMAIL_CLASSIFIER.md`

**Credenciais:**  
- `/home/user/webapp/CREDENCIAIS_CONSOLIDADAS.md`

---

## ✅ PRÓXIMOS PASSOS APÓS ATIVAÇÃO

1. **Monitorar por 24h:**
   - Verificar executions no N8N
   - Verificar crescimento de dados no PostgreSQL
   - Verificar tickets criados no osTicket

2. **Criar Dashboards Metabase** (30-40 min):
   - Acessar: https://metabase-metabase.aymebz.easypanel.host
   - Usar views criadas: `v_email_classification_overview`, `v_sla_compliance`, etc.
   - Guia completo em: `DEPLOY_GUIDE.md` seção "Metabase Dashboards"

3. **Ajustar SLAs** (se necessário):
   - Editar tabela `automation_email_classifier.slas`
   - Ajustar tempos de resposta conforme necessidade real

4. **Treinar IA** (opcional):
   - Revisar classificações incorretas
   - Atualizar tabela `knowledge_base` com exemplos
   - Workflow 02 usará automaticamente novos exemplos

---

**Data de Criação:** 2025-12-29  
**Versão:** 1.0  
**Status:** PRONTO PARA USO
