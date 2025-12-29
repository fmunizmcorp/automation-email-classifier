# 🚀 GUIA DE DEPLOY E ATIVAÇÃO - EMAIL CLASSIFIER

## 📋 PRÉ-REQUISITOS

Antes de iniciar, certifique-se que você tem:

- ✅ Acesso ao N8N: https://n8n-n8n.aymebz.easypanel.host
- ✅ Credenciais Gmail OAuth2 configuradas no N8N
- ✅ Credenciais OpenAI API configuradas no N8N
- ✅ API Key do osTicket: `47A5F014F699019805B984E89018040B`
- ✅ Acesso ao PostgreSQL (já configurado)
- ✅ Acesso ao Metabase: https://metabase-metabase.aymebz.easypanel.host

---

## 🗂️ FASE 1: IMPORTAÇÃO DOS WORKFLOWS NO N8N

### 1.1. Criar Pasta no N8N

1. Acesse https://n8n-n8n.aymebz.easypanel.host
2. Login: `gensparkflavio` / `gensparkflavio89742937592`
3. Vá em "Workflows" no menu lateral
4. Clique em "New Folder" ou organize workflows
5. Crie uma pasta chamada: **"Email Classifier"**

### 1.2. Importar Workflows (em ordem)

Importar os arquivos JSON localizados em:
```
/home/user/webapp/automations/automation-email-classifier/n8n/workflows/
```

**ORDEM DE IMPORTAÇÃO:**

1. **01_Email_Reader_PRODUCTION.json**
   - Trigger: A cada 2 minutos
   - Função: Lê emails não lidos do Gmail → PostgreSQL

2. **02_AI_Classifier_PRODUCTION.json**
   - Trigger: A cada 30 segundos
   - Função: Classifica emails com OpenAI GPT-4

3. **03_Spam_Manager_PRODUCTION.json**
   - Trigger: A cada 5 minutos
   - Função: Aprova spam automaticamente ou marca para revisão

4. **04_Client_Ticket_Creator_PRODUCTION.json**
   - Trigger: A cada 45 segundos
   - Função: Cria tickets no osTicket para emails de clientes

5. **05_Admin_Ticket_Creator_PRODUCTION.json**
   - Trigger: A cada 1 minuto
   - Função: Cria tickets no osTicket para emails administrativos

6. **06_Dashboard_Alerts_PRODUCTION.json**
   - Trigger: A cada 10 minutos
   - Função: Monitora SLA, spam pendente e erros

### 1.3. Configurar Credenciais em Cada Workflow

Para cada workflow importado, você precisa configurar as credenciais:

#### A. Gmail OAuth2 (Workflows 01 e 03)

1. Abra o workflow
2. Clique no node "Gmail"
3. Em "Credentials", selecione a credencial Gmail OAuth2 existente
4. Se não existir:
   - Clique em "+ Create New Credential"
   - Selecione "Gmail OAuth2 API"
   - Siga o fluxo de autenticação do Google
   - Autorize o acesso

#### B. OpenAI API (Workflow 02)

1. Abra o workflow "02 - AI Classifier"
2. Clique no node "OpenAI - Classify Email"
3. Em "Credentials", selecione a credencial OpenAI API existente
4. Se não existir:
   - Clique em "+ Create New Credential"
   - Tipo: "OpenAI API"
   - Insira sua API Key da OpenAI

#### C. PostgreSQL (Todos os workflows)

1. Em cada workflow, clique em nodes PostgreSQL
2. Em "Credentials", selecione ou crie:
   - **Name**: "PostgreSQL - bdn8n"
   - **Host**: `72.62.12.216`
   - **Port**: `5432`
   - **Database**: `bdn8n`
   - **User**: `postgres`
   - **Password**: `6DCAt6MBuK4yH8h2Q8pL`
   - **SSL**: Disabled

#### D. osTicket API (Workflows 04 e 05)

Os workflows 04 e 05 usam HTTP Request nodes com API Key no header:

1. Abra workflow 04 ou 05
2. Clique no node "Create osTicket Ticket"
3. Verifique que o header contém:
   - **Name**: `X-API-Key`
   - **Value**: `47A5F014F699019805B984E89018040B`
4. A URL deve ser: `https://www.clinfec.com.br/osticket/api/tickets.json`

---

## ⚙️ FASE 2: ATIVAÇÃO DOS WORKFLOWS

### 2.1. Ordem de Ativação (IMPORTANTE!)

**ATIVE NA ORDEM ABAIXO** para evitar erros:

1. ✅ **06 - Dashboard Alerts** (primeiro - para começar a monitorar)
2. ✅ **03 - Spam Manager** (segundo - para processar spam)
3. ✅ **05 - Admin Ticket Creator** (terceiro - tickets admin)
4. ✅ **04 - Client Ticket Creator** (quarto - tickets clientes)
5. ✅ **02 - AI Classifier** (quinto - classificação IA)
6. ✅ **01 - Email Reader** (último - começa a ler emails)

### 2.2. Como Ativar um Workflow

1. Abra o workflow no N8N
2. No canto superior direito, localize o toggle "Inactive" / "Active"
3. Clique para mudar para **"Active"**
4. Aguarde confirmação de ativação (círculo verde)
5. Verifique que o workflow está rodando:
   - Menu lateral: "Executions"
   - Filtre pelo nome do workflow
   - Deve começar a executar automaticamente

### 2.3. Validação Pós-Ativação

Após ativar todos os workflows, aguarde 5-10 minutos e verifique:

#### PostgreSQL - Verificar Dados

```sql
-- Conectar ao banco
psql -h 72.62.12.216 -U postgres -d bdn8n

-- Verificar emails lidos
SELECT COUNT(*) as total_emails, status, COUNT(*) 
FROM automation_email_classifier.emails 
GROUP BY status;

-- Verificar classificações
SELECT category, COUNT(*) 
FROM automation_email_classifier.classifications 
GROUP BY category;

-- Verificar tickets criados
SELECT COUNT(*) as total_tickets, ticket_status 
FROM automation_email_classifier.tickets 
GROUP BY ticket_status;

-- Verificar logs de execução
SELECT workflow_name, execution_status, COUNT(*) 
FROM automation_email_classifier.execution_logs 
WHERE created_at > NOW() - INTERVAL '1 hour'
GROUP BY workflow_name, execution_status
ORDER BY workflow_name;
```

#### N8N - Verificar Execuções

1. No N8N, vá em "Executions" no menu lateral
2. Verifique que os workflows estão executando:
   - ✅ 01 - Email Reader (a cada 2 min)
   - ✅ 02 - AI Classifier (a cada 30s)
   - ✅ 03 - Spam Manager (a cada 5 min)
   - ✅ 04 - Client Ticket Creator (a cada 45s)
   - ✅ 05 - Admin Ticket Creator (a cada 1 min)
   - ✅ 06 - Dashboard Alerts (a cada 10 min)

3. Clique em cada execução e verifique:
   - ✅ Status: Success (verde)
   - ❌ Se houver erro (vermelho): Clique para ver detalhes

---

## 📊 FASE 3: CONFIGURAÇÃO METABASE DASHBOARDS

### 3.1. Conectar Database ao Metabase (se ainda não conectado)

1. Acesse https://metabase-metabase.aymebz.easypanel.host
2. Login: `gensparkflavio` / `gensparkflavio89742937592`
3. Vá em "Admin Settings" (ícone de engrenagem)
4. Clique em "Databases"
5. Clique em "+ Add Database"
6. Configure:
   - **Name**: `Email Classifier - PostgreSQL`
   - **Database type**: PostgreSQL
   - **Host**: `72.62.12.216`
   - **Port**: `5432`
   - **Database name**: `bdn8n`
   - **Username**: `postgres`
   - **Password**: `6DCAt6MBuK4yH8h2Q8pL`
   - **Schemas**: `automation_email_classifier`
7. Clique em "Save"
8. Aguarde o Metabase escanear o schema
9. Clique em "Sync database schema now"

### 3.2. Criar Dashboard Principal

#### Dashboard: "Email Classifier - Overview"

**Cards a criar:**

1. **Total Emails Recebidos (hoje)**
   - Tipo: Number
   - Query: `SELECT COUNT(*) FROM automation_email_classifier.emails WHERE DATE(created_at) = CURRENT_DATE`

2. **Emails por Status**
   - Tipo: Pie Chart
   - Query: `SELECT status, COUNT(*) FROM automation_email_classifier.emails GROUP BY status`

3. **Emails por Categoria**
   - Tipo: Bar Chart
   - Query: `SELECT category, COUNT(*) FROM automation_email_classifier.classifications GROUP BY category ORDER BY COUNT(*) DESC`

4. **Taxa de Sucesso da Classificação**
   - Tipo: Number (%)
   - Query: 
   ```sql
   SELECT 
     ROUND(100.0 * COUNT(CASE WHEN status = 'classified' THEN 1 END) / NULLIF(COUNT(*), 0), 2) as taxa
   FROM automation_email_classifier.emails
   WHERE created_at > NOW() - INTERVAL '24 hours'
   ```

5. **Tickets Criados (últimas 24h)**
   - Tipo: Number
   - Query: 
   ```sql
   SELECT COUNT(*) 
   FROM automation_email_classifier.tickets 
   WHERE created_at > NOW() - INTERVAL '24 hours'
   ```

6. **Emails por Departamento**
   - Tipo: Bar Chart
   - Query:
   ```sql
   SELECT d.name, COUNT(c.id) 
   FROM automation_email_classifier.departments d
   LEFT JOIN automation_email_classifier.classifications c ON c.department_id = d.id
   WHERE c.created_at > NOW() - INTERVAL '7 days'
   GROUP BY d.name
   ORDER BY COUNT(c.id) DESC
   ```

7. **Spam Pendente de Aprovação**
   - Tipo: Number
   - Query:
   ```sql
   SELECT COUNT(*) 
   FROM automation_email_classifier.spam_approvals 
   WHERE approval_status = 'pending' AND requires_action = true
   ```

8. **SLA - Tickets em Risco**
   - Tipo: Table
   - Query:
   ```sql
   SELECT 
     t.ticket_number,
     e.subject,
     t.priority,
     d.name as department,
     t.sla_deadline,
     EXTRACT(EPOCH FROM (t.sla_deadline - NOW())) / 3600 as horas_restantes
   FROM automation_email_classifier.tickets t
   JOIN automation_email_classifier.emails e ON e.id = t.email_id
   JOIN automation_email_classifier.departments d ON d.id = t.department_id
   WHERE t.sla_deadline < NOW() + INTERVAL '4 hours'
     AND t.ticket_status IN ('open', 'pending')
   ORDER BY t.sla_deadline ASC
   LIMIT 10
   ```

9. **Tempo Médio de Processamento**
   - Tipo: Number (minutos)
   - Query:
   ```sql
   SELECT 
     ROUND(AVG(EXTRACT(EPOCH FROM (classification_completed_at - created_at)) / 60), 2) as media_minutos
   FROM automation_email_classifier.emails
   WHERE classification_completed_at IS NOT NULL
     AND created_at > NOW() - INTERVAL '24 hours'
   ```

10. **Últimas Execuções dos Workflows**
    - Tipo: Table
    - Query:
    ```sql
    SELECT 
      workflow_name,
      execution_status,
      processed_count,
      created_at
    FROM automation_email_classifier.execution_logs
    ORDER BY created_at DESC
    LIMIT 20
    ```

### 3.3. Criar Dashboard de Alertas

#### Dashboard: "Email Classifier - Alertas e Monitoramento"

1. **Classificações com Baixa Confiança**
   ```sql
   SELECT 
     e.subject,
     e.from_email,
     c.category,
     c.confidence_score,
     c.created_at
   FROM automation_email_classifier.emails e
   JOIN automation_email_classifier.classifications c ON c.email_id = e.id
   WHERE c.confidence_score < 0.7
     AND c.created_at > NOW() - INTERVAL '24 hours'
   ORDER BY c.confidence_score ASC
   LIMIT 10
   ```

2. **Erros de Classificação**
   ```sql
   SELECT 
     id,
     email_id,
     subject,
     status,
     created_at
   FROM automation_email_classifier.emails
   WHERE status = 'error'
     AND created_at > NOW() - INTERVAL '24 hours'
   ORDER BY created_at DESC
   ```

3. **Performance por Departamento**
   ```sql
   SELECT 
     d.name as departamento,
     COUNT(t.id) as total_tickets,
     COUNT(CASE WHEN t.sla_deadline < NOW() THEN 1 END) as tickets_atrasados,
     ROUND(100.0 * COUNT(CASE WHEN t.sla_deadline >= NOW() THEN 1 END) / NULLIF(COUNT(t.id), 0), 2) as taxa_sla
   FROM automation_email_classifier.departments d
   LEFT JOIN automation_email_classifier.tickets t ON t.department_id = d.id
   WHERE t.created_at > NOW() - INTERVAL '7 days'
   GROUP BY d.name
   ORDER BY total_tickets DESC
   ```

### 3.4. Configurar Auto-Refresh

1. Em cada dashboard, clique em "..." (três pontos)
2. Selecione "Auto-refresh"
3. Configure para: **5 minutes** (dashboards se atualizam a cada 5 minutos)
4. Salve

### 3.5. Compartilhar Dashboards

1. Clique em "Share" no dashboard
2. Copie o link público ou configure permissões
3. Envie para stakeholders relevantes

---

## 🧪 FASE 4: TESTES END-TO-END

### 4.1. Teste Manual - Enviar Email de Teste

1. **Envie 3 emails de teste para a conta Gmail monitorada:**

   **Email 1 - Cliente/Paciente:**
   ```
   Para: <email-monitorado>@clinfec.com.br
   Assunto: Solicitação de Orçamento
   Corpo: Olá, gostaria de solicitar um orçamento para consulta dermatológica. 
   Meu nome é João Silva.
   ```

   **Email 2 - Spam:**
   ```
   Para: <email-monitorado>@clinfec.com.br
   Assunto: Promoção Imperdível! 50% OFF
   Corpo: Aproveite nossa promoção especial...
   ```

   **Email 3 - Administrativo:**
   ```
   Para: <email-monitorado>@clinfec.com.br
   Assunto: Fatura - Fornecedor XYZ
   Corpo: Segue em anexo a fatura do mês de dezembro...
   ```

### 4.2. Aguardar Processamento (5-10 minutos)

1. **2 minutos**: Email Reader deve ler os emails
2. **+30 segundos**: AI Classifier deve classificar
3. **+45 segundos**: Ticket Creator deve criar tickets
4. **Total**: ~3-5 minutos até tickets criados

### 4.3. Validar Resultados

#### No PostgreSQL:
```sql
-- Ver emails recebidos
SELECT id, subject, status, created_at 
FROM automation_email_classifier.emails 
ORDER BY created_at DESC 
LIMIT 3;

-- Ver classificações
SELECT 
  e.subject,
  c.category,
  c.subcategory,
  c.priority,
  c.confidence_score
FROM automation_email_classifier.emails e
JOIN automation_email_classifier.classifications c ON c.email_id = e.id
ORDER BY e.created_at DESC
LIMIT 3;

-- Ver tickets criados
SELECT 
  t.ticket_number,
  e.subject,
  t.priority,
  d.name as department,
  t.ticket_status
FROM automation_email_classifier.tickets t
JOIN automation_email_classifier.emails e ON e.id = t.email_id
JOIN automation_email_classifier.departments d ON d.id = t.department_id
ORDER BY t.created_at DESC
LIMIT 3;
```

#### No osTicket:
1. Acesse https://www.clinfec.com.br/osticket/
2. Login: `clinfecbsb@gmail.com` / `n8nautomacao`
3. Vá em "Tickets"
4. Verifique que os 2 tickets foram criados (Cliente e Admin)
5. Confira prioridades e departamentos corretos

#### No N8N:
1. Vá em "Executions"
2. Filtre por workflows individuais
3. Verifique execuções bem-sucedidas (verde)
4. Clique para ver detalhes de cada node

#### No Metabase:
1. Acesse o dashboard "Email Classifier - Overview"
2. Verifique que os números aumentaram:
   - Total de emails
   - Classificações por categoria
   - Tickets criados

---

## 📈 FASE 5: MONITORAMENTO CONTÍNUO

### 5.1. Checklist Diário

- [ ] Acessar Metabase dashboard "Email Classifier - Overview"
- [ ] Verificar:
  - ✅ Emails sendo processados
  - ✅ Taxa de sucesso > 95%
  - ✅ Tickets sendo criados
  - ✅ SLA em dia (sem tickets críticos)
  - ✅ Spam pendente < 5 emails
  - ✅ Erros de classificação = 0

### 5.2. Alertas Automáticos

O workflow **06 - Dashboard Alerts** monitora automaticamente:

- 🚨 **SLA em risco** (< 2 horas para deadline)
- ⚠️ **Spam pendente** (> 4 horas sem aprovação)
- ❌ **Erros de classificação** (> 5 erros na última hora)

Logs são gravados em: `automation_email_classifier.execution_logs`

### 5.3. Queries Úteis de Monitoramento

```sql
-- Dashboard de saúde do sistema
SELECT 
  'Emails Recebidos (24h)' as metric,
  COUNT(*) as value
FROM automation_email_classifier.emails
WHERE created_at > NOW() - INTERVAL '24 hours'

UNION ALL

SELECT 
  'Taxa de Classificação (%)',
  ROUND(100.0 * COUNT(CASE WHEN status = 'classified' THEN 1 END) / NULLIF(COUNT(*), 0), 2)
FROM automation_email_classifier.emails
WHERE created_at > NOW() - INTERVAL '24 hours'

UNION ALL

SELECT 
  'Tickets Criados (24h)',
  COUNT(*)
FROM automation_email_classifier.tickets
WHERE created_at > NOW() - INTERVAL '24 hours'

UNION ALL

SELECT 
  'Tickets em Risco SLA',
  COUNT(*)
FROM automation_email_classifier.tickets
WHERE sla_deadline < NOW() + INTERVAL '2 hours'
  AND ticket_status IN ('open', 'pending')

UNION ALL

SELECT 
  'Spam Pendente Aprovação',
  COUNT(*)
FROM automation_email_classifier.spam_approvals
WHERE approval_status = 'pending' AND requires_action = true;
```

---

## 🆘 TROUBLESHOOTING

### Problema 1: Workflow não está executando

**Sintomas:**
- Workflow ativo mas sem execuções
- Ou execuções muito antigas

**Solução:**
1. Verificar que o workflow está **Active** (toggle verde)
2. Clicar em "Execute Workflow" manualmente para testar
3. Verificar logs de erro no N8N
4. Reativar o workflow (desativar → ativar)

### Problema 2: Erro de Credenciais

**Sintomas:**
- Execução falha em node específico
- Erro: "401 Unauthorized" ou "403 Forbidden"

**Solução:**
1. Abrir o workflow
2. Clicar no node com erro
3. Ir em "Credentials"
4. Reautenticar ou recriar credencial
5. Salvar e reativar workflow

### Problema 3: Emails não sendo lidos

**Sintomas:**
- Tabela `emails` vazia ou sem novos registros

**Verificações:**
1. **Gmail OAuth2 válido?**
   - Testar executando workflow 01 manualmente
   - Verificar se precisa reautorizar

2. **Filtro correto?**
   - O workflow busca emails com label "INBOX" e "is:unread"
   - Verificar se emails estão chegando na inbox

3. **PostgreSQL acessível?**
   - Testar conexão: `psql -h 72.62.12.216 -U postgres -d bdn8n`

### Problema 4: Classificação IA não funcionando

**Sintomas:**
- Emails ficam em `status = 'pending_classification'`
- Não há registros em `classifications`

**Soluções:**
1. **Verificar credencial OpenAI:**
   - Abrir workflow 02
   - Node "OpenAI - Classify Email"
   - Reautenticar API Key

2. **Verificar cota OpenAI:**
   - Acessar https://platform.openai.com/usage
   - Verificar se há créditos disponíveis

3. **Testar manualmente:**
   - Executar workflow 02 manualmente
   - Ver output de cada node

### Problema 5: Tickets não sendo criados no osTicket

**Sintomas:**
- Classificações OK mas sem tickets
- Ou erro no node "Create osTicket Ticket"

**Soluções:**
1. **Verificar API Key:**
   - Workflow 04 ou 05
   - Node HTTP Request
   - Header `X-API-Key` = `47A5F014F699019805B984E89018040B`

2. **Testar API osTicket manualmente:**
   ```bash
   curl -X POST https://www.clinfec.com.br/osticket/api/tickets.json \
     -H "X-API-Key: 47A5F014F699019805B984E89018040B" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Teste API",
       "email": "teste@example.com",
       "subject": "Teste Ticket",
       "message": "Mensagem de teste"
     }'
   ```

3. **Verificar topicId e priority:**
   - osTicket pode rejeitar se topicId ou priority inválidos
   - Ver logs de erro no N8N

### Problema 6: Dashboard Metabase sem dados

**Sintomas:**
- Dashboards mostram 0 ou valores vazios

**Soluções:**
1. **Verificar conexão database:**
   - Admin Settings → Databases
   - Clicar em "Email Classifier - PostgreSQL"
   - Testar conexão
   - "Sync database schema now"

2. **Verificar queries:**
   - Abrir cada "Question"
   - Executar query manualmente
   - Ver se retorna dados

3. **Verificar permissões schema:**
   ```sql
   GRANT USAGE ON SCHEMA automation_email_classifier TO postgres;
   GRANT SELECT ON ALL TABLES IN SCHEMA automation_email_classifier TO postgres;
   ```

---

## ✅ CHECKLIST FINAL DE DEPLOY

Use este checklist para garantir que tudo está funcionando:

### Infraestrutura
- [ ] PostgreSQL acessível (72.62.12.216:5432)
- [ ] Schema `automation_email_classifier` existe
- [ ] 8 tabelas criadas
- [ ] 6 views criadas
- [ ] Dados seed inseridos (8 departamentos, 11 SLAs)

### N8N Workflows
- [ ] Pasta "Email Classifier" criada
- [ ] 6 workflows importados
- [ ] Todas credenciais configuradas:
  - [ ] Gmail OAuth2
  - [ ] OpenAI API
  - [ ] PostgreSQL
  - [ ] osTicket API Key (nos headers HTTP)
- [ ] Todos workflows ATIVOS (toggle verde)
- [ ] Execuções rodando sem erros

### Testes
- [ ] Email de teste enviado e recebido
- [ ] Email classificado corretamente
- [ ] Ticket criado no osTicket
- [ ] Dados visíveis no PostgreSQL
- [ ] Logs de execução gravados

### Metabase
- [ ] Database conectado
- [ ] Dashboard "Overview" criado e funcionando
- [ ] Dashboard "Alertas" criado e funcionando
- [ ] Auto-refresh configurado (5 min)
- [ ] Dashboards compartilhados

### Monitoramento
- [ ] Workflow "Dashboard Alerts" ativo
- [ ] Logs sendo gravados
- [ ] Queries de monitoramento testadas

---

## 🎉 SISTEMA PRONTO!

Se todos os checks acima estão ✅, o sistema Email Classifier está **100% OPERACIONAL!**

### Próximos Passos Opcionais:

1. **Otimizações:**
   - Ajustar frequência de triggers conforme volume
   - Refinar prompts OpenAI para melhor acurácia
   - Adicionar mais regras de auto-aprovação de spam

2. **Expansões:**
   - Adicionar notificações Slack/Telegram
   - Criar dashboard público para clientes
   - Implementar respostas automáticas para categorias específicas
   - Adicionar análise de sentimento avançada

3. **Manutenção:**
   - Revisar logs semanalmente
   - Ajustar SLAs conforme necessário
   - Treinar equipe para uso do Metabase
   - Documentar casos de uso e melhorias

---

## 📞 SUPORTE

Em caso de dúvidas ou problemas:

1. **Documentação:**
   - README.md
   - ARCHITECTURE.md
   - SETUP.md
   - TROUBLESHOOTING.md

2. **Logs:**
   - N8N: Executions
   - PostgreSQL: `automation_email_classifier.execution_logs`
   - osTicket: Admin Panel → Logs

3. **Contato:**
   - Email: fmunizm@gmail.com
   - Repositório: https://github.com/fmunizmcorp/automation-email-classifier

---

**Data de Criação**: 2025-12-29  
**Versão**: 1.0  
**Status**: ✅ Pronto para Deploy
