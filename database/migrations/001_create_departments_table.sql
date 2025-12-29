-- Migration: 001_create_departments_table.sql
-- Description: Tabela de departamentos para roteamento de chamados
-- Created: 2025-12-29
-- Schema: automation_email_classifier

-- ===================================================================
-- TABELA: departments
-- Descrição: Armazena os departamentos da empresa para roteamento
-- ===================================================================

CREATE TABLE IF NOT EXISTS automation_email_classifier.departments (
    -- Primary Key
    id SERIAL PRIMARY KEY,
    
    -- Identification
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    
    -- Configuration
    email_patterns TEXT[], -- Padrões de email que devem ser roteados para este departamento
    keywords TEXT[], -- Palavras-chave que indicam este departamento
    priority_default INTEGER DEFAULT 2 CHECK (priority_default BETWEEN 1 AND 4),
    
    -- osTicket Integration
    osticket_department_id INTEGER,
    osticket_topic_id INTEGER,
    
    -- Team
    manager_email VARCHAR(255),
    team_emails TEXT[],
    
    -- Workflow Settings
    workflow_id VARCHAR(100), -- ID do workflow N8N responsável
    auto_assign BOOLEAN DEFAULT TRUE,
    requires_approval BOOLEAN DEFAULT FALSE,
    
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

CREATE INDEX idx_departments_code ON automation_email_classifier.departments(code);
CREATE INDEX idx_departments_active ON automation_email_classifier.departments(is_active);
CREATE INDEX idx_departments_osticket ON automation_email_classifier.departments(osticket_department_id);

-- ===================================================================
-- COMMENTS
-- ===================================================================

COMMENT ON TABLE automation_email_classifier.departments IS 'Departamentos da empresa para roteamento de chamados';
COMMENT ON COLUMN automation_email_classifier.departments.code IS 'Código único do departamento (ex: ATENDIMENTO, FINANCEIRO, TI)';
COMMENT ON COLUMN automation_email_classifier.departments.email_patterns IS 'Padrões regex de emails (ex: [".*@financeiro\\..*", ".*contabilidade.*"])';
COMMENT ON COLUMN automation_email_classifier.departments.keywords IS 'Palavras-chave que indicam este departamento (ex: ["pagamento", "boleto", "nota fiscal"])';
COMMENT ON COLUMN automation_email_classifier.departments.priority_default IS 'Prioridade padrão (1=Baixa, 2=Normal, 3=Alta, 4=Urgente)';

-- ===================================================================
-- TRIGGER: Update timestamp
-- ===================================================================

CREATE OR REPLACE FUNCTION automation_email_classifier.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_departments_updated_at
    BEFORE UPDATE ON automation_email_classifier.departments
    FOR EACH ROW
    EXECUTE FUNCTION automation_email_classifier.update_updated_at_column();

-- ===================================================================
-- VALIDATION
-- ===================================================================

DO $$
BEGIN
    RAISE NOTICE 'Migration 001 completed successfully: departments table created';
END $$;
