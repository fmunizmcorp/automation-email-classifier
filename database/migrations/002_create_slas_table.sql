-- Migration: 002_create_slas_table.sql
-- Description: Tabela de SLAs (Service Level Agreements) por tipo de chamado
-- Created: 2025-12-29
-- Schema: automation_email_classifier

-- ===================================================================
-- TABELA: slas
-- Descrição: Configuração de SLAs para diferentes tipos de chamados
-- ===================================================================

CREATE TABLE IF NOT EXISTS automation_email_classifier.slas (
    -- Primary Key
    id SERIAL PRIMARY KEY,
    
    -- Identification
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    
    -- Classification
    ticket_type VARCHAR(50) NOT NULL, -- INFORMACAO, ORCAMENTO, SERVICO, URGENCIA
    category VARCHAR(100), -- Cliente, Paciente, Administrativo, etc.
    priority INTEGER NOT NULL CHECK (priority BETWEEN 1 AND 4), -- 1=Baixa, 2=Normal, 3=Alta, 4=Urgente
    
    -- Time Configuration (in minutes)
    response_time_minutes INTEGER NOT NULL, -- Tempo para primeira resposta
    resolution_time_minutes INTEGER NOT NULL, -- Tempo para resolução
    
    -- Escalation
    escalation_time_minutes INTEGER, -- Tempo para escalonamento
    escalation_level INTEGER DEFAULT 1 CHECK (escalation_level BETWEEN 1 AND 3),
    escalation_emails TEXT[], -- Emails para notificar no escalonamento
    
    -- Business Hours
    business_hours_only BOOLEAN DEFAULT TRUE,
    weekend_enabled BOOLEAN DEFAULT FALSE,
    holiday_enabled BOOLEAN DEFAULT FALSE,
    
    -- Notifications
    notify_on_creation BOOLEAN DEFAULT TRUE,
    notify_on_deadline BOOLEAN DEFAULT TRUE,
    notify_before_minutes INTEGER DEFAULT 60, -- Notificar X minutos antes do deadline
    
    -- Metrics
    success_rate_target DECIMAL(5,2) DEFAULT 95.00, -- Meta de sucesso em %
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) DEFAULT 'system',
    updated_by VARCHAR(100) DEFAULT 'system'
);

-- ===================================================================
-- INDEXES
-- ===================================================================

CREATE INDEX idx_slas_code ON automation_email_classifier.slas(code);
CREATE INDEX idx_slas_type_priority ON automation_email_classifier.slas(ticket_type, priority);
CREATE INDEX idx_slas_active ON automation_email_classifier.slas(is_active);

-- ===================================================================
-- COMMENTS
-- ===================================================================

COMMENT ON TABLE automation_email_classifier.slas IS 'Configuração de SLAs para diferentes tipos de chamados';
COMMENT ON COLUMN automation_email_classifier.slas.ticket_type IS 'Tipo de chamado: INFORMACAO, ORCAMENTO, SERVICO, URGENCIA';
COMMENT ON COLUMN automation_email_classifier.slas.priority IS 'Prioridade (1=Baixa, 2=Normal, 3=Alta, 4=Urgente)';
COMMENT ON COLUMN automation_email_classifier.slas.response_time_minutes IS 'Tempo máximo para primeira resposta em minutos';
COMMENT ON COLUMN automation_email_classifier.slas.resolution_time_minutes IS 'Tempo máximo para resolução completa em minutos';

-- ===================================================================
-- TRIGGER: Update timestamp
-- ===================================================================

CREATE TRIGGER trigger_slas_updated_at
    BEFORE UPDATE ON automation_email_classifier.slas
    FOR EACH ROW
    EXECUTE FUNCTION automation_email_classifier.update_updated_at_column();

-- ===================================================================
-- VALIDATION
-- ===================================================================

DO $$
BEGIN
    RAISE NOTICE 'Migration 002 completed successfully: slas table created';
END $$;
