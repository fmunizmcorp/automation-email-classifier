-- Migration: 003_create_emails_table.sql
-- Description: Tabela principal de emails processados
-- Created: 2025-12-29
-- Schema: automation_email_classifier

-- ===================================================================
-- TABELA: emails
-- Descrição: Armazena todos os emails processados do Google Workspace
-- ===================================================================

CREATE TABLE IF NOT EXISTS automation_email_classifier.emails (
    -- Primary Key
    id SERIAL PRIMARY KEY,
    
    -- Gmail Integration
    gmail_message_id VARCHAR(255) UNIQUE NOT NULL,
    gmail_thread_id VARCHAR(255),
    gmail_labels TEXT[],
    
    -- Email Headers
    from_email VARCHAR(500) NOT NULL,
    from_name VARCHAR(500),
    to_emails TEXT[] NOT NULL,
    cc_emails TEXT[],
    bcc_emails TEXT[],
    reply_to VARCHAR(500),
    
    -- Content
    subject TEXT NOT NULL,
    body_text TEXT,
    body_html TEXT,
    snippet TEXT, -- Resumo curto do email
    
    -- Metadata
    received_at TIMESTAMP WITH TIME ZONE NOT NULL,
    sent_at TIMESTAMP WITH TIME ZONE,
    has_attachments BOOLEAN DEFAULT FALSE,
    attachment_count INTEGER DEFAULT 0,
    attachments_metadata JSONB, -- Nome, tipo, tamanho dos anexos
    
    -- Size
    size_bytes BIGINT,
    
    -- Processing Status
    processing_status VARCHAR(50) DEFAULT 'pending', -- pending, processing, completed, failed
    processing_started_at TIMESTAMP WITH TIME ZONE,
    processing_completed_at TIMESTAMP WITH TIME ZONE,
    processing_error TEXT,
    processing_attempts INTEGER DEFAULT 0,
    
    -- Integration IDs
    classification_id INTEGER, -- FK para classifications
    ticket_id INTEGER, -- FK para tickets
    
    -- Flags
    is_spam BOOLEAN DEFAULT FALSE,
    is_automated BOOLEAN DEFAULT FALSE, -- Email automático (newsletter, notificação, etc)
    is_reply BOOLEAN DEFAULT FALSE,
    is_forward BOOLEAN DEFAULT FALSE,
    requires_attention BOOLEAN DEFAULT FALSE,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_by VARCHAR(100) DEFAULT 'n8n_workflow'
);

-- ===================================================================
-- INDEXES
-- ===================================================================

CREATE INDEX idx_emails_gmail_message ON automation_email_classifier.emails(gmail_message_id);
CREATE INDEX idx_emails_gmail_thread ON automation_email_classifier.emails(gmail_thread_id);
CREATE INDEX idx_emails_from ON automation_email_classifier.emails(from_email);
CREATE INDEX idx_emails_received ON automation_email_classifier.emails(received_at DESC);
CREATE INDEX idx_emails_status ON automation_email_classifier.emails(processing_status);
CREATE INDEX idx_emails_classification ON automation_email_classifier.emails(classification_id);
CREATE INDEX idx_emails_ticket ON automation_email_classifier.emails(ticket_id);
CREATE INDEX idx_emails_spam ON automation_email_classifier.emails(is_spam) WHERE is_spam = TRUE;
CREATE INDEX idx_emails_attention ON automation_email_classifier.emails(requires_attention) WHERE requires_attention = TRUE;

-- Full-text search index
CREATE INDEX idx_emails_subject_search ON automation_email_classifier.emails USING GIN(to_tsvector('portuguese', subject));
CREATE INDEX idx_emails_body_search ON automation_email_classifier.emails USING GIN(to_tsvector('portuguese', body_text));

-- ===================================================================
-- COMMENTS
-- ===================================================================

COMMENT ON TABLE automation_email_classifier.emails IS 'Emails processados do Google Workspace';
COMMENT ON COLUMN automation_email_classifier.emails.gmail_message_id IS 'ID único da mensagem no Gmail';
COMMENT ON COLUMN automation_email_classifier.emails.gmail_thread_id IS 'ID da thread/conversa no Gmail';
COMMENT ON COLUMN automation_email_classifier.emails.processing_status IS 'Status: pending, processing, completed, failed';
COMMENT ON COLUMN automation_email_classifier.emails.attachments_metadata IS 'JSON com informações dos anexos (nome, tipo, tamanho, url)';

-- ===================================================================
-- TRIGGER: Update timestamp
-- ===================================================================

CREATE TRIGGER trigger_emails_updated_at
    BEFORE UPDATE ON automation_email_classifier.emails
    FOR EACH ROW
    EXECUTE FUNCTION automation_email_classifier.update_updated_at_column();

-- ===================================================================
-- VALIDATION
-- ===================================================================

DO $$
BEGIN
    RAISE NOTICE 'Migration 003 completed successfully: emails table created';
END $$;
