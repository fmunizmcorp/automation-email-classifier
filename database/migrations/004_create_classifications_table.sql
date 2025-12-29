-- Migration: 004_create_classifications_table.sql
-- Description: Tabela de classificações de IA para emails
-- Created: 2025-12-29
-- Schema: automation_email_classifier

-- ===================================================================
-- TABELA: classifications
-- Descrição: Classificações de IA (OpenAI) para cada email
-- ===================================================================

CREATE TABLE IF NOT EXISTS automation_email_classifier.classifications (
    -- Primary Key
    id SERIAL PRIMARY KEY,
    
    -- Foreign Keys
    email_id INTEGER NOT NULL REFERENCES automation_email_classifier.emails(id) ON DELETE CASCADE,
    
    -- Classification Result
    classification_type VARCHAR(50) NOT NULL, -- SPAM, CLIENT, ADMIN
    confidence_score DECIMAL(5,2) NOT NULL CHECK (confidence_score BETWEEN 0 AND 100),
    
    -- Sub-classification
    sub_category VARCHAR(100), -- Para CLIENT: atendimento, orçamento, agendamento; Para ADMIN: financeiro, RH, TI
    ticket_type VARCHAR(50), -- INFORMACAO, ORCAMENTO, SERVICO, URGENCIA
    priority_suggested INTEGER CHECK (priority_suggested BETWEEN 1 AND 4),
    
    -- Department Routing
    department_id INTEGER REFERENCES automation_email_classifier.departments(id),
    department_confidence DECIMAL(5,2),
    
    -- SLA Recommendation
    sla_id INTEGER REFERENCES automation_email_classifier.slas(id),
    estimated_response_time INTEGER, -- em minutos
    estimated_resolution_time INTEGER, -- em minutos
    
    -- AI Analysis
    ai_model VARCHAR(100) DEFAULT 'gpt-4', -- Modelo usado na classificação
    ai_prompt TEXT, -- Prompt usado
    ai_response_raw JSONB, -- Resposta completa da IA em JSON
    ai_reasoning TEXT, -- Raciocínio da IA para a classificação
    
    -- Extracted Information
    extracted_customer_name VARCHAR(500),
    extracted_customer_id VARCHAR(100),
    extracted_keywords TEXT[],
    extracted_entities JSONB, -- Pessoas, organizações, locais mencionados
    sentiment VARCHAR(50), -- POSITIVE, NEUTRAL, NEGATIVE, URGENT
    intent TEXT, -- Intenção principal do email
    
    -- Processing
    processing_time_ms INTEGER, -- Tempo de processamento da IA
    tokens_used INTEGER, -- Tokens usados na API
    cost_usd DECIMAL(10,6), -- Custo da chamada à API
    
    -- Validation & Feedback
    is_validated BOOLEAN DEFAULT FALSE,
    validated_by VARCHAR(100),
    validated_at TIMESTAMP WITH TIME ZONE,
    validation_feedback TEXT,
    was_correct BOOLEAN, -- Feedback se a classificação estava correta
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ===================================================================
-- INDEXES
-- ===================================================================

CREATE INDEX idx_classifications_email ON automation_email_classifier.classifications(email_id);
CREATE INDEX idx_classifications_type ON automation_email_classifier.classifications(classification_type);
CREATE INDEX idx_classifications_department ON automation_email_classifier.classifications(department_id);
CREATE INDEX idx_classifications_sla ON automation_email_classifier.classifications(sla_id);
CREATE INDEX idx_classifications_confidence ON automation_email_classifier.classifications(confidence_score DESC);
CREATE INDEX idx_classifications_sentiment ON automation_email_classifier.classifications(sentiment);
CREATE INDEX idx_classifications_validated ON automation_email_classifier.classifications(is_validated);

-- GIN index for JSON search
CREATE INDEX idx_classifications_extracted_entities ON automation_email_classifier.classifications USING GIN(extracted_entities);

-- ===================================================================
-- COMMENTS
-- ===================================================================

COMMENT ON TABLE automation_email_classifier.classifications IS 'Classificações de IA (OpenAI) para emails';
COMMENT ON COLUMN automation_email_classifier.classifications.classification_type IS 'Tipo principal: SPAM, CLIENT, ADMIN';
COMMENT ON COLUMN automation_email_classifier.classifications.confidence_score IS 'Confiança da classificação (0-100%)';
COMMENT ON COLUMN automation_email_classifier.classifications.sentiment IS 'Sentimento: POSITIVE, NEUTRAL, NEGATIVE, URGENT';
COMMENT ON COLUMN automation_email_classifier.classifications.ai_response_raw IS 'Resposta completa da OpenAI em JSON';

-- ===================================================================
-- TRIGGER: Update timestamp
-- ===================================================================

CREATE TRIGGER trigger_classifications_updated_at
    BEFORE UPDATE ON automation_email_classifier.classifications
    FOR EACH ROW
    EXECUTE FUNCTION automation_email_classifier.update_updated_at_column();

-- ===================================================================
-- VALIDATION
-- ===================================================================

DO $$
BEGIN
    RAISE NOTICE 'Migration 004 completed successfully: classifications table created';
END $$;
