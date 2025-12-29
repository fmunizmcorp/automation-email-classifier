-- Seed: 002_seed_slas.sql
-- Description: Dados iniciais de SLAs por tipo de chamado
-- Created: 2025-12-29

-- ===================================================================
-- SEED: SLAs (Service Level Agreements)
-- ===================================================================

INSERT INTO automation_email_classifier.slas
(code, name, description, ticket_type, category, priority, 
 response_time_minutes, resolution_time_minutes, escalation_time_minutes,
 business_hours_only, notify_on_creation, notify_on_deadline, is_active)
VALUES

-- ===== CLIENTE/PACIENTE =====

-- Informação - Cliente - Normal
('SLA_CLIENT_INFO_NORMAL',
 'Cliente - Informação - Normal',
 'Solicitações de informação de clientes com prioridade normal',
 'INFORMACAO', 'Cliente', 2,
 60,    -- 1 hora para responder
 480,   -- 8 horas para resolver
 240,   -- 4 horas para escalonamento
 TRUE, TRUE, TRUE, TRUE),

-- Informação - Cliente - Alta
('SLA_CLIENT_INFO_HIGH',
 'Cliente - Informação - Alta',
 'Solicitações de informação de clientes com prioridade alta',
 'INFORMACAO', 'Cliente', 3,
 30,    -- 30 minutos para responder
 240,   -- 4 horas para resolver
 120,   -- 2 horas para escalonamento
 TRUE, TRUE, TRUE, TRUE),

-- Orçamento - Cliente - Normal
('SLA_CLIENT_QUOTE_NORMAL',
 'Cliente - Orçamento - Normal',
 'Solicitações de orçamento de clientes',
 'ORCAMENTO', 'Cliente', 2,
 120,   -- 2 horas para responder
 1440,  -- 24 horas para resolver
 480,   -- 8 horas para escalonamento
 TRUE, TRUE, TRUE, TRUE),

-- Orçamento - Cliente - Alta
('SLA_CLIENT_QUOTE_HIGH',
 'Cliente - Orçamento - Alta',
 'Solicitações de orçamento urgentes',
 'ORCAMENTO', 'Cliente', 3,
 60,    -- 1 hora para responder
 480,   -- 8 horas para resolver
 240,   -- 4 horas para escalonamento
 TRUE, TRUE, TRUE, TRUE),

-- Serviço - Cliente - Normal
('SLA_CLIENT_SERVICE_NORMAL',
 'Cliente - Serviço - Normal',
 'Solicitações de serviço de clientes',
 'SERVICO', 'Cliente', 2,
 60,    -- 1 hora para responder
 720,   -- 12 horas para resolver
 360,   -- 6 horas para escalonamento
 TRUE, TRUE, TRUE, TRUE),

-- Serviço - Cliente - Alta
('SLA_CLIENT_SERVICE_HIGH',
 'Cliente - Serviço - Alta',
 'Solicitações de serviço urgentes',
 'SERVICO', 'Cliente', 3,
 30,    -- 30 minutos para responder
 240,   -- 4 horas para resolver
 120,   -- 2 horas para escalonamento
 TRUE, TRUE, TRUE, TRUE),

-- Urgência - Cliente
('SLA_CLIENT_URGENCY',
 'Cliente - Urgência',
 'Situações urgentes de clientes',
 'URGENCIA', 'Cliente', 4,
 15,    -- 15 minutos para responder
 120,   -- 2 horas para resolver
 60,    -- 1 hora para escalonamento
 FALSE, TRUE, TRUE, TRUE),  -- Não respeita horário comercial

-- ===== ADMINISTRATIVO =====

-- Informação - Admin - Normal
('SLA_ADMIN_INFO_NORMAL',
 'Administrativo - Informação - Normal',
 'Solicitações administrativas de informação',
 'INFORMACAO', 'Administrativo', 2,
 120,   -- 2 horas para responder
 720,   -- 12 horas para resolver
 360,   -- 6 horas para escalonamento
 TRUE, TRUE, TRUE, TRUE),

-- Serviço - Admin - Normal (NF, Boletos, etc)
('SLA_ADMIN_SERVICE_NORMAL',
 'Administrativo - Serviço - Normal',
 'Serviços administrativos (NF, boletos, documentos)',
 'SERVICO', 'Administrativo', 2,
 240,   -- 4 horas para responder
 1440,  -- 24 horas para resolver
 720,   -- 12 horas para escalonamento
 TRUE, TRUE, TRUE, TRUE),

-- Urgência - Admin
('SLA_ADMIN_URGENCY',
 'Administrativo - Urgência',
 'Situações urgentes administrativas',
 'URGENCIA', 'Administrativo', 4,
 30,    -- 30 minutos para responder
 240,   -- 4 horas para resolver
 120,   -- 2 horas para escalonamento
 FALSE, TRUE, TRUE, TRUE),

-- ===== SPAM/PROMOÇÕES =====

-- Aprovação de Spam
('SLA_SPAM_APPROVAL',
 'Spam - Aprovação',
 'Aprovação de descadastramento de spam/promoções',
 'INFORMACAO', 'Spam', 1,
 1440,  -- 24 horas para aprovar
 2880,  -- 48 horas para processar
 1440,  -- 24 horas para escalonamento
 TRUE, FALSE, TRUE, TRUE)

ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    ticket_type = EXCLUDED.ticket_type,
    category = EXCLUDED.category,
    priority = EXCLUDED.priority,
    response_time_minutes = EXCLUDED.response_time_minutes,
    resolution_time_minutes = EXCLUDED.resolution_time_minutes,
    escalation_time_minutes = EXCLUDED.escalation_time_minutes,
    business_hours_only = EXCLUDED.business_hours_only,
    notify_on_creation = EXCLUDED.notify_on_creation,
    notify_on_deadline = EXCLUDED.notify_on_deadline,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = 'seed_script';

-- ===================================================================
-- VALIDATION
-- ===================================================================

DO $$
DECLARE
    sla_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO sla_count FROM automation_email_classifier.slas;
    RAISE NOTICE 'Seed 002 completed: % SLAs inserted/updated', sla_count;
    
    -- Show summary
    RAISE NOTICE 'SLA Summary:';
    RAISE NOTICE '  - Cliente: % SLAs', (SELECT COUNT(*) FROM automation_email_classifier.slas WHERE category = 'Cliente');
    RAISE NOTICE '  - Administrativo: % SLAs', (SELECT COUNT(*) FROM automation_email_classifier.slas WHERE category = 'Administrativo');
    RAISE NOTICE '  - Spam: % SLAs', (SELECT COUNT(*) FROM automation_email_classifier.slas WHERE category = 'Spam');
END $$;
