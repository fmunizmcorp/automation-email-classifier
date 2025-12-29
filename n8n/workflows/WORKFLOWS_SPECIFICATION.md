# 📋 Especificação Completa dos Workflows N8N

## 🔄 Workflow 1: Email Reader (Gmail → PostgreSQL)

**Objetivo:** Ler emails do Gmail e inserir no PostgreSQL

**Nodes:**
1. **Gmail Trigger** (n8n-nodes-base.gmailTrigger)
   - Poll: Every 1 minute
   - Filter: `is:unread` in INBOX
   - Credentials: Gmail OAuth2

2. **PostgreSQL Insert Email** (n8n-nodes-base.postgres)
   - Operation: Execute Query
   - Query: INSERT INTO automation_email_classifier.emails
   - Returns: email_id, gmail_message_id

3. **Gmail Mark as Processed** (n8n-nodes-base.gmail)
   - Operation: Update message
   - Add label: PROCESSED
   - Remove label: UNREAD

4. **HTTP Request - Trigger AI Classifier** (n8n-nodes-base.httpRequest)
   - Method: POST
   - URL: https://n8n-n8n.aymebz.easypanel.host/webhook/ai-classifier
   - Body: { email_id, gmail_message_id }

5. **IF - Check Success** (n8n-nodes-base.if)
   - Condition: status === 'success'

6. **PostgreSQL Update Success/Failed** (n8n-nodes-base.postgres)
   - Update processing_status accordingly

**Conexões:**
Gmail Trigger → PostgreSQL Insert → Gmail Mark → HTTP Request → IF → Update Success/Failed

**Variáveis de Ambiente Necessárias:**
- Gmail OAuth2 credentials
- PostgreSQL connection (bdn8n)
- N8N_WEBHOOK_URL

---

## 🤖 Workflow 2: AI Classifier (OpenAI → Classification)

**Objetivo:** Classificar emails usando OpenAI GPT-4

**Nodes:**
1. **Webhook Trigger** (n8n-nodes-base.webhook)
   - Path: /ai-classifier
   - Method: POST
   - Receives: { email_id, gmail_message_id }

2. **PostgreSQL Get Email** (n8n-nodes-base.postgres)
   - Query: SELECT * FROM automation_email_classifier.emails WHERE id = {{ $json.email_id }}

3. **OpenAI GPT-4** (n8n-nodes-base.openAi)
   - Model: gpt-4
   - Prompt: 
   ```
   Você é um assistente especializado em classificar emails para uma clínica médica.
   
   Classifique o seguinte email em uma das 3 categorias:
   1. SPAM: Emails promocionais, newsletters não solicitados, marketing
   2. CLIENT: Emails de pacientes ou potenciais clientes (agendamento, consulta, orçamento)
   3. ADMIN: Emails administrativos (notas fiscais, boletos, fornecedores)
   
   Email:
   De: {{ $node["PostgreSQL Get Email"].json.from_email }}
   Assunto: {{ $node["PostgreSQL Get Email"].json.subject }}
   Corpo: {{ $node["PostgreSQL Get Email"].json.body_text }}
   
   Responda APENAS em formato JSON:
   {
     "classification_type": "SPAM|CLIENT|ADMIN",
     "confidence_score": 0-100,
     "sub_category": "descrição da subcategoria",
     "ticket_type": "INFORMACAO|ORCAMENTO|SERVICO|URGENCIA",
     "priority_suggested": 1-4,
     "department_code": "código do departamento",
     "sentiment": "POSITIVE|NEUTRAL|NEGATIVE|URGENT",
     "reasoning": "explicação da classificação",
     "extracted_keywords": ["palavra1", "palavra2"]
   }
   ```
   - Temperature: 0.3
   - Max Tokens: 500

4. **Function - Parse JSON Response** (n8n-nodes-base.function)
   - Parse OpenAI response
   - Extract classification data

5. **PostgreSQL Get Department** (n8n-nodes-base.postgres)
   - Query: SELECT id FROM automation_email_classifier.departments WHERE code = '{{ $json.department_code }}'

6. **PostgreSQL Get SLA** (n8n-nodes-base.postgres)
   - Query: SELECT id FROM automation_email_classifier.slas 
     WHERE ticket_type = '{{ $json.ticket_type }}' 
     AND priority = {{ $json.priority_suggested }}
     ORDER BY relevance_score DESC LIMIT 1

7. **PostgreSQL Insert Classification** (n8n-nodes-base.postgres)
   - Query: INSERT INTO automation_email_classifier.classifications
   - Returns: classification_id

8. **IF - Classification Type Router** (n8n-nodes-base.if)
   - Route based on classification_type: SPAM, CLIENT, ADMIN

9. **HTTP Request - Trigger Appropriate Workflow**
   - SPAM → Trigger Spam Manager
   - CLIENT → Trigger Client Ticket Creator
   - ADMIN → Trigger Admin Ticket Creator

**Conexões:**
Webhook → Get Email → OpenAI → Parse JSON → Get Department/SLA → Insert Classification → IF Router → Trigger Workflows

**Variáveis de Ambiente Necessárias:**
- OPENAI_API_KEY
- PostgreSQL connection

---

## 🗑️ Workflow 3: Spam Manager

**Objetivo:** Gerenciar aprovação de spam e descadastramento

**Nodes:**
1. **Webhook Trigger** (n8n-nodes-base.webhook)
   - Path: /spam-manager
   - Receives: { email_id, classification_id }

2. **PostgreSQL Get Email & Classification** (n8n-nodes-base.postgres)
   - JOIN emails and classifications

3. **Function - Detect Spam Type & Score** (n8n-nodes-base.function)
   - Analyze spam indicators
   - Calculate spam_score
   - Determine spam_type

4. **PostgreSQL Insert Spam Approval** (n8n-nodes-base.postgres)
   - INSERT INTO spam_approvals
   - Set approval_status = 'pending'
   - Set approval_deadline = NOW() + 24 hours

5. **IF - Auto-approve Rules** (n8n-nodes-base.if)
   - Check if sender is whitelisted
   - Check if domain is blacklisted
   - Check if spam_score > 90

6. **Gmail Send Approval Request** (n8n-nodes-base.gmail)
   - Send email to manager
   - Include approval link
   - Include spam details

7. **Set - Schedule Reminder** (n8n-nodes-base.schedule)
   - Schedule reminder for 12 hours before deadline

**Approval Webhook:**
8. **Webhook - Approval Response** (n8n-nodes-base.webhook)
   - Path: /spam-approval-response
   - Receives: { spam_approval_id, action: 'approve|reject' }

9. **PostgreSQL Update Approval** (n8n-nodes-base.postgres)
   - Update approval_status
   - Set approved_at, approver

10. **IF - Action Approved** (n8n-nodes-base.if)
    - If approved → Proceed with unsubscribe
    - If rejected → Whitelist sender

11. **HTTP Request - Unsubscribe** (n8n-nodes-base.httpRequest)
    - Find unsubscribe link in email
    - Send unsubscribe request

12. **Gmail Update Labels** (n8n-nodes-base.gmail)
    - Add SPAM label
    - Archive message

**Conexões:**
Webhook → Get Data → Insert Spam Approval → IF Auto-approve → Send Request → Approval Webhook → Update → IF Action → Unsubscribe/Whitelist

---

## 👤 Workflow 4: Client Ticket Creator (osTicket)

**Objetivo:** Criar chamados automáticos no osTicket para clientes/pacientes

**Nodes:**
1. **Webhook Trigger** (n8n-nodes-base.webhook)
   - Path: /client-ticket-creator
   - Receives: { email_id, classification_id }

2. **PostgreSQL Get Complete Data** (n8n-nodes-base.postgres)
   - JOIN emails, classifications, departments, slas

3. **Function - Extract Customer Info** (n8n-nodes-base.function)
   - Extract customer name, email, phone
   - Identify customer_id if exists
   - Format ticket subject/description

4. **HTTP Request - osTicket API Create Ticket** (n8n-nodes-base.httpRequest)
   - Method: POST
   - URL: https://www.clinfec.com.br/osticket/api/tickets.json
   - Headers: X-API-Key
   - Body:
   ```json
   {
     "name": "{{ $json.customer_name }}",
     "email": "{{ $json.customer_email }}",
     "subject": "{{ $json.subject }}",
     "message": "{{ $json.description }}",
     "topicId": "{{ $json.osticket_topic_id }}",
     "priority": "{{ $json.priority }}",
     "source": "Email"
   }
   ```

5. **PostgreSQL Insert Ticket** (n8n-nodes-base.postgres)
   - INSERT INTO tickets
   - Store osticket_ticket_id, osticket_ticket_number

6. **Function - Calculate SLA Deadlines** (n8n-nodes-base.function)
   - response_deadline = NOW() + sla_response_minutes
   - resolution_deadline = NOW() + sla_resolution_minutes

7. **PostgreSQL Update Ticket SLA** (n8n-nodes-base.postgres)
   - UPDATE tickets SET sla_response_deadline, sla_resolution_deadline

8. **IF - Has Attachments** (n8n-nodes-base.if)
   - Check if email has attachments

9. **Gmail Get Attachments** (n8n-nodes-base.gmail)
   - Download attachments

10. **HTTP Request - Upload to osTicket** (n8n-nodes-base.httpRequest)
    - Upload attachments to ticket

11. **Gmail Send Confirmation** (n8n-nodes-base.gmail)
    - Send auto-reply to customer
    - Include ticket number
    - Include SLA information

12. **HTTP Request - Create Knowledge Base Entry** (n8n-nodes-base.httpRequest)
    - Trigger knowledge base workflow
    - Store email content for future reference

**Conexões:**
Webhook → Get Data → Extract Info → Create osTicket → Insert DB → Calculate SLA → IF Attachments → Download/Upload → Send Confirmation → Create KB Entry

**Credenciais Necessárias:**
- osTicket API Key
- Gmail OAuth2
- PostgreSQL

---

## 📋 Workflow 5: Admin Ticket Creator (osTicket)

**Objetivo:** Criar chamados administrativos (NF, boletos, etc)

**Nodes:**
Similar ao Workflow 4, mas com:

1. **Different Classification Logic**
   - Sub-categories: financeiro, RH, TI, fornecedores

2. **Function - Detect Document Types** (n8n-nodes-base.function)
   - Identify: Nota Fiscal, Boleto, Contrato, etc
   - Extract: valores, vencimentos, CNPJs

3. **PostgreSQL Check Duplicate** (n8n-nodes-base.postgres)
   - Check if document already processed
   - Avoid duplicate tickets

4. **IF - Document Type Router**
   - Nota Fiscal → Financial dept
   - Boleto → Financial dept
   - RH → HR dept
   - TI → IT dept

5. **Additional Node: Store Document Metadata**
   - Store in custom_fields JSONB

**Diferenças do Workflow 4:**
- Não envia confirmação ao remetente (emails automáticos)
- Prioridade geralmente mais baixa
- SLAs mais longos
- Routing mais complexo

---

## 📊 Workflow 6: Dashboard Alerts

**Objetivo:** Monitorar métricas e enviar alertas

**Nodes:**
1. **Cron Trigger** (n8n-nodes-base.cron)
   - Schedule: Every 15 minutes

2. **PostgreSQL - Check SLA Breaches** (n8n-nodes-base.postgres)
   - Query: SELECT * FROM view_sla_performance 
     WHERE response_sla_status = 'AT_RISK' OR resolution_sla_status = 'AT_RISK'

3. **IF - Has SLA Risks** (n8n-nodes-base.if)
   - Count > 0

4. **Gmail Send Alert** (n8n-nodes-base.gmail)
   - To: managers
   - Subject: SLA Alert
   - Body: List of at-risk tickets

5. **PostgreSQL - Check Pending Spam Approvals** (n8n-nodes-base.postgres)
   - Query: SELECT * FROM spam_approvals 
     WHERE approval_status = 'pending' 
     AND approval_deadline < NOW() + INTERVAL '2 hours'

6. **IF - Has Pending Approvals** (n8n-nodes-base.if)
   - Count > 0

7. **Gmail Send Reminder** (n8n-nodes-base.gmail)
   - Reminder to approve spam

8. **PostgreSQL - Check System Health** (n8n-nodes-base.postgres)
   - Query: SELECT * FROM dashboard_overview

9. **Function - Calculate KPIs** (n8n-nodes-base.function)
   - Processing rate
   - Success rate
   - Average response time

10. **IF - KPI Thresholds** (n8n-nodes-base.if)
    - Check if below thresholds

11. **Gmail Send Daily Report** (n8n-nodes-base.gmail)
    - Daily summary at 18:00
    - Include metrics, charts

---

## 🔐 Credenciais Necessárias

### Gmail OAuth2
- Client ID
- Client Secret
- Refresh Token
- Scopes: gmail.readonly, gmail.modify, gmail.send

### PostgreSQL
- Host: 72.62.12.216
- Port: 5432
- Database: bdn8n
- Schema: automation_email_classifier
- User: postgres
- Password: (ver CREDENCIAIS_CONSOLIDADAS.md)

### OpenAI
- API Key: (configurar no N8N)
- Organization ID: (opcional)
- Model: gpt-4

### osTicket
- Base URL: https://www.clinfec.com.br/osticket
- API Key: (gerar no osTicket)
- User: clinfecbsb@gmail.com
- Password: n8nautomacao

### Redis (para cache)
- Host: localhost (ou redis service)
- Port: 6379
- Database: 0
- Password: (se configurado)

---

## 📝 Instruções de Importação no N8N

1. Acesse N8N: https://n8n-n8n.aymebz.easypanel.host
2. Login: gensparkflavio / gensparkflavio89742937592
3. Criar Pasta: "EmailClassifier"
4. Para cada workflow:
   - Clicar em "Add workflow"
   - Importar JSON ou criar manualmente seguindo especificação
   - Configurar credenciais
   - Testar nodes individualmente
   - Ativar workflow

5. Ordem de ativação:
   - Workflow 6 (Dashboard Alerts) - para monitoramento
   - Workflow 3 (Spam Manager)
   - Workflow 4 (Client Ticket Creator)
   - Workflow 5 (Admin Ticket Creator)
   - Workflow 2 (AI Classifier)
   - Workflow 1 (Email Reader) - por último

---

## 🧪 Testes Recomendados

1. **Teste Individual de Nodes:**
   - Testar conexão Gmail
   - Testar conexão PostgreSQL
   - Testar OpenAI API
   - Testar osTicket API

2. **Teste de Workflows:**
   - Enviar email de teste para cada tipo (spam, cliente, admin)
   - Verificar inserção no banco
   - Verificar classificação IA
   - Verificar criação de ticket
   - Verificar alertas

3. **Teste de Performance:**
   - Processar batch de 10 emails
   - Verificar tempo de processamento
   - Verificar uso de tokens OpenAI
   - Verificar rate limits

4. **Teste de Error Handling:**
   - Simular falha de API
   - Simular email mal formatado
   - Verificar retries
   - Verificar logs de erro

---

## 📊 Métricas de Sucesso

- ✅ 100% de emails processados
- ✅ >95% de precisão na classificação
- ✅ <5 minutos tempo médio de processamento
- ✅ >90% compliance de SLA
- ✅ 0% de perda de emails
