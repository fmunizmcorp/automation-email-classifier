-- Migration: 008_create_chat_history_table.sql
-- Description: Tabela de histórico de chat/conversas com IA
-- Created: 2025-12-29
-- Schema: automation_email_classifier

-- ===================================================================
-- TABELA: chat_history
-- Descrição: Histórico de conversas/consultas à base de conhecimento
-- ===================================================================

CREATE TABLE IF NOT EXISTS automation_email_classifier.chat_history (
    -- Primary Key
    id SERIAL PRIMARY KEY,
    
    -- Session
    session_id UUID NOT NULL,
    session_started_at TIMESTAMP WITH TIME ZONE,
    
    -- User
    user_email VARCHAR(255) NOT NULL,
    user_name VARCHAR(255),
    user_role VARCHAR(100),
    user_department VARCHAR(100),
    
    -- Message
    message_type VARCHAR(50) NOT NULL, -- USER_QUESTION, AI_RESPONSE, SYSTEM_MESSAGE
    message_text TEXT NOT NULL,
    message_order INTEGER NOT NULL, -- Ordem na conversa
    
    -- AI Processing
    ai_model VARCHAR(100), -- Modelo de IA usado
    ai_prompt TEXT, -- Prompt enviado à IA
    ai_response_raw JSONB, -- Resposta completa da IA
    ai_processing_time_ms INTEGER,
    ai_tokens_used INTEGER,
    ai_cost_usd DECIMAL(10,6),
    
    -- Knowledge Base Integration
    knowledge_base_sources INTEGER[], -- IDs da knowledge_base usados
    related_emails INTEGER[], -- IDs de emails relacionados
    related_tickets INTEGER[], -- IDs de tickets relacionados
    sources_used_count INTEGER DEFAULT 0,
    
    -- Search & Retrieval
    search_query TEXT, -- Query de busca usada
    search_method VARCHAR(50), -- SEMANTIC, KEYWORD, HYBRID, VECTOR
    search_results_count INTEGER,
    top_results JSONB, -- Top resultados da busca
    
    -- Intent & Context
    intent VARCHAR(100), -- Intenção detectada (busca, ajuda, suporte, etc)
    context JSONB, -- Contexto da conversa
    entities_extracted JSONB, -- Entidades extraídas da mensagem
    
    -- Quality & Feedback
    relevance_score DECIMAL(5,2), -- Quão relevante foi a resposta
    user_feedback VARCHAR(50), -- HELPFUL, NOT_HELPFUL, PARTIALLY_HELPFUL
    user_feedback_text TEXT,
    user_feedback_at TIMESTAMP WITH TIME ZONE,
    
    -- Actions Taken
    action_triggered VARCHAR(100), -- CREATED_TICKET, SENT_EMAIL, SCHEDULED_CALL, etc
    action_details JSONB,
    action_status VARCHAR(50),
    
    -- Follow-up
    requires_human_followup BOOLEAN DEFAULT FALSE,
    followup_assigned_to VARCHAR(255),
    followup_completed BOOLEAN DEFAULT FALSE,
    followup_notes TEXT,
    
    -- Device & Channel
    channel VARCHAR(50), -- WEB, API, MOBILE, EMAIL
    device_info JSONB,
    ip_address INET,
    user_agent TEXT,
    
    -- Performance
    response_time_ms INTEGER,
    cache_hit BOOLEAN DEFAULT FALSE,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ===================================================================
-- INDEXES
-- ===================================================================

CREATE INDEX idx_chat_history_session ON automation_email_classifier.chat_history(session_id);
CREATE INDEX idx_chat_history_user ON automation_email_classifier.chat_history(user_email);
CREATE INDEX idx_chat_history_type ON automation_email_classifier.chat_history(message_type);
CREATE INDEX idx_chat_history_created ON automation_email_classifier.chat_history(created_at DESC);
CREATE INDEX idx_chat_history_session_order ON automation_email_classifier.chat_history(session_id, message_order);
CREATE INDEX idx_chat_history_intent ON automation_email_classifier.chat_history(intent);
CREATE INDEX idx_chat_history_feedback ON automation_email_classifier.chat_history(user_feedback);
CREATE INDEX idx_chat_history_followup ON automation_email_classifier.chat_history(requires_human_followup) WHERE requires_human_followup = TRUE;

-- Full-text search
CREATE INDEX idx_chat_history_message_search ON automation_email_classifier.chat_history USING GIN(to_tsvector('portuguese', message_text));

-- GIN indexes for arrays
CREATE INDEX idx_chat_history_kb_sources ON automation_email_classifier.chat_history USING GIN(knowledge_base_sources);
CREATE INDEX idx_chat_history_related_emails ON automation_email_classifier.chat_history USING GIN(related_emails);
CREATE INDEX idx_chat_history_related_tickets ON automation_email_classifier.chat_history USING GIN(related_tickets);

-- ===================================================================
-- COMMENTS
-- ===================================================================

COMMENT ON TABLE automation_email_classifier.chat_history IS 'Histórico de conversas/consultas à base de conhecimento';
COMMENT ON COLUMN automation_email_classifier.chat_history.message_type IS 'Tipo: USER_QUESTION, AI_RESPONSE, SYSTEM_MESSAGE';
COMMENT ON COLUMN automation_email_classifier.chat_history.search_method IS 'Método: SEMANTIC, KEYWORD, HYBRID, VECTOR';
COMMENT ON COLUMN automation_email_classifier.chat_history.user_feedback IS 'Feedback: HELPFUL, NOT_HELPFUL, PARTIALLY_HELPFUL';

-- ===================================================================
-- TRIGGER: Update timestamp
-- ===================================================================

CREATE TRIGGER trigger_chat_history_updated_at
    BEFORE UPDATE ON automation_email_classifier.chat_history
    FOR EACH ROW
    EXECUTE FUNCTION automation_email_classifier.update_updated_at_column();

-- ===================================================================
-- VALIDATION
-- ===================================================================

DO $$
BEGIN
    RAISE NOTICE 'Migration 008 completed successfully: chat_history table created';
END $$;
