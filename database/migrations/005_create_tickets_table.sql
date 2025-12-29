-- Migration: 005_create_tickets_table.sql
-- Description: Tabela de chamados integrados com osTicket
-- Created: 2025-12-29
-- Schema: automation_email_classifier

-- ===================================================================
-- TABELA: tickets
-- Descrição: Chamados criados automaticamente no osTicket
-- ===================================================================

CREATE TABLE IF NOT EXISTS automation_email_classifier.tickets (
    -- Primary Key
    id SERIAL PRIMARY KEY,
    
    -- Foreign Keys
    email_id INTEGER NOT NULL REFERENCES automation_email_classifier.emails(id) ON DELETE CASCADE,
    classification_id INTEGER REFERENCES automation_email_classifier.classifications(id),
    department_id INTEGER REFERENCES automation_email_classifier.departments(id),
    sla_id INTEGER REFERENCES automation_email_classifier.slas(id),
    
    -- osTicket Integration
    osticket_ticket_id INTEGER UNIQUE,
    osticket_ticket_number VARCHAR(50) UNIQUE,
    osticket_url TEXT,
    
    -- Ticket Information
    subject TEXT NOT NULL,
    description TEXT,
    ticket_type VARCHAR(50), -- INFORMACAO, ORCAMENTO, SERVICO, URGENCIA
    category VARCHAR(100),
    priority INTEGER NOT NULL DEFAULT 2 CHECK (priority BETWEEN 1 AND 4),
    status VARCHAR(50) DEFAULT 'open', -- open, assigned, in_progress, on_hold, resolved, closed
    
    -- Customer Information
    customer_name VARCHAR(500),
    customer_email VARCHAR(500),
    customer_phone VARCHAR(50),
    customer_id VARCHAR(100),
    
    -- Assignment
    assigned_to VARCHAR(200),
    assigned_at TIMESTAMP WITH TIME ZONE,
    assigned_by VARCHAR(200),
    
    -- SLA Tracking
    sla_response_deadline TIMESTAMP WITH TIME ZONE,
    sla_resolution_deadline TIMESTAMP WITH TIME ZONE,
    first_response_at TIMESTAMP WITH TIME ZONE,
    resolved_at TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE,
    
    -- SLA Compliance
    response_sla_met BOOLEAN,
    resolution_sla_met BOOLEAN,
    response_time_minutes INTEGER,
    resolution_time_minutes INTEGER,
    
    -- Escalation
    escalation_level INTEGER DEFAULT 0 CHECK (escalation_level BETWEEN 0 AND 3),
    escalated_at TIMESTAMP WITH TIME ZONE,
    escalation_reason TEXT,
    
    -- Activity Tracking
    last_activity_at TIMESTAMP WITH TIME ZONE,
    messages_count INTEGER DEFAULT 1,
    attachments_count INTEGER DEFAULT 0,
    
    -- Satisfaction
    satisfaction_score INTEGER CHECK (satisfaction_score BETWEEN 1 AND 5),
    satisfaction_feedback TEXT,
    satisfaction_collected_at TIMESTAMP WITH TIME ZONE,
    
    -- Resolution
    resolution_notes TEXT,
    resolution_type VARCHAR(100), -- resolved, cancelled, merged, spam
    
    -- Metadata
    tags TEXT[],
    custom_fields JSONB,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) DEFAULT 'n8n_workflow'
);

-- ===================================================================
-- INDEXES
-- ===================================================================

CREATE INDEX idx_tickets_email ON automation_email_classifier.tickets(email_id);
CREATE INDEX idx_tickets_classification ON automation_email_classifier.tickets(classification_id);
CREATE INDEX idx_tickets_department ON automation_email_classifier.tickets(department_id);
CREATE INDEX idx_tickets_sla ON automation_email_classifier.tickets(sla_id);
CREATE INDEX idx_tickets_osticket_id ON automation_email_classifier.tickets(osticket_ticket_id);
CREATE INDEX idx_tickets_osticket_number ON automation_email_classifier.tickets(osticket_ticket_number);
CREATE INDEX idx_tickets_status ON automation_email_classifier.tickets(status);
CREATE INDEX idx_tickets_priority ON automation_email_classifier.tickets(priority);
CREATE INDEX idx_tickets_customer_email ON automation_email_classifier.tickets(customer_email);
CREATE INDEX idx_tickets_assigned ON automation_email_classifier.tickets(assigned_to);
CREATE INDEX idx_tickets_created ON automation_email_classifier.tickets(created_at DESC);
CREATE INDEX idx_tickets_sla_response ON automation_email_classifier.tickets(sla_response_deadline) WHERE status IN ('open', 'assigned', 'in_progress');
CREATE INDEX idx_tickets_sla_resolution ON automation_email_classifier.tickets(sla_resolution_deadline) WHERE status IN ('open', 'assigned', 'in_progress');

-- ===================================================================
-- COMMENTS
-- ===================================================================

COMMENT ON TABLE automation_email_classifier.tickets IS 'Chamados criados automaticamente no osTicket';
COMMENT ON COLUMN automation_email_classifier.tickets.priority IS 'Prioridade (1=Baixa, 2=Normal, 3=Alta, 4=Urgente)';
COMMENT ON COLUMN automation_email_classifier.tickets.status IS 'Status: open, assigned, in_progress, on_hold, resolved, closed';
COMMENT ON COLUMN automation_email_classifier.tickets.escalation_level IS 'Nível de escalonamento (0=Nenhum, 1=Supervisor, 2=Gerente, 3=Diretor)';

-- ===================================================================
-- TRIGGER: Update timestamp
-- ===================================================================

CREATE TRIGGER trigger_tickets_updated_at
    BEFORE UPDATE ON automation_email_classifier.tickets
    FOR EACH ROW
    EXECUTE FUNCTION automation_email_classifier.update_updated_at_column();

-- ===================================================================
-- VALIDATION
-- ===================================================================

DO $$
BEGIN
    RAISE NOTICE 'Migration 005 completed successfully: tickets table created';
END $$;
