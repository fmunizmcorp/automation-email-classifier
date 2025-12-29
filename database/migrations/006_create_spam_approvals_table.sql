-- Migration: 006_create_spam_approvals_table.sql
-- Description: Tabela de aprovações de spam por gestores
-- Created: 2025-12-29
-- Schema: automation_email_classifier

-- ===================================================================
-- TABELA: spam_approvals
-- Descrição: Aprovações de spam/promoções por gestores antes do descadastramento
-- ===================================================================

CREATE TABLE IF NOT EXISTS automation_email_classifier.spam_approvals (
    -- Primary Key
    id SERIAL PRIMARY KEY,
    
    -- Foreign Keys
    email_id INTEGER NOT NULL REFERENCES automation_email_classifier.emails(id) ON DELETE CASCADE,
    classification_id INTEGER REFERENCES automation_email_classifier.classifications(id),
    
    -- Spam Details
    spam_type VARCHAR(50) NOT NULL, -- PROMOTIONAL, NEWSLETTER, MARKETING, PHISHING, OTHER
    sender_email VARCHAR(500) NOT NULL,
    sender_domain VARCHAR(255),
    subject TEXT NOT NULL,
    
    -- Detection
    detection_reason TEXT, -- Por que foi classificado como spam
    spam_indicators TEXT[], -- Indicadores específicos (palavras-chave, padrões)
    spam_score DECIMAL(5,2), -- Score de spam (0-100)
    
    -- Approval Process
    approval_status VARCHAR(50) DEFAULT 'pending', -- pending, approved, rejected, auto_approved
    approval_requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    approval_deadline TIMESTAMP WITH TIME ZONE, -- Prazo para aprovação
    
    -- Approver
    approver_email VARCHAR(255),
    approver_name VARCHAR(255),
    approved_at TIMESTAMP WITH TIME ZONE,
    approval_notes TEXT,
    
    -- Action Taken
    action_taken VARCHAR(100), -- UNSUBSCRIBED, MARKED_SPAM, WHITELISTED, IGNORED
    action_taken_at TIMESTAMP WITH TIME ZONE,
    unsubscribe_method VARCHAR(100), -- EMAIL, LINK, API, MANUAL
    unsubscribe_success BOOLEAN,
    unsubscribe_error TEXT,
    
    -- Gmail Actions
    gmail_label_added VARCHAR(100), -- Label adicionado no Gmail
    gmail_archived BOOLEAN DEFAULT FALSE,
    gmail_deleted BOOLEAN DEFAULT FALSE,
    
    -- Sender Tracking
    sender_previous_spam_count INTEGER DEFAULT 0,
    sender_whitelisted BOOLEAN DEFAULT FALSE,
    sender_blacklisted BOOLEAN DEFAULT FALSE,
    
    -- Auto-approval Rules
    auto_approved BOOLEAN DEFAULT FALSE,
    auto_approval_rule VARCHAR(200), -- Regra que causou auto-aprovação
    
    -- Notification
    notification_sent BOOLEAN DEFAULT FALSE,
    notification_sent_at TIMESTAMP WITH TIME ZONE,
    reminder_sent_count INTEGER DEFAULT 0,
    last_reminder_at TIMESTAMP WITH TIME ZONE,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ===================================================================
-- INDEXES
-- ===================================================================

CREATE INDEX idx_spam_approvals_email ON automation_email_classifier.spam_approvals(email_id);
CREATE INDEX idx_spam_approvals_classification ON automation_email_classifier.spam_approvals(classification_id);
CREATE INDEX idx_spam_approvals_status ON automation_email_classifier.spam_approvals(approval_status);
CREATE INDEX idx_spam_approvals_sender ON automation_email_classifier.spam_approvals(sender_email);
CREATE INDEX idx_spam_approvals_domain ON automation_email_classifier.spam_approvals(sender_domain);
CREATE INDEX idx_spam_approvals_approver ON automation_email_classifier.spam_approvals(approver_email);
CREATE INDEX idx_spam_approvals_pending ON automation_email_classifier.spam_approvals(approval_status, approval_requested_at) WHERE approval_status = 'pending';
CREATE INDEX idx_spam_approvals_deadline ON automation_email_classifier.spam_approvals(approval_deadline) WHERE approval_status = 'pending';

-- ===================================================================
-- COMMENTS
-- ===================================================================

COMMENT ON TABLE automation_email_classifier.spam_approvals IS 'Aprovações de spam/promoções por gestores';
COMMENT ON COLUMN automation_email_classifier.spam_approvals.spam_type IS 'Tipo: PROMOTIONAL, NEWSLETTER, MARKETING, PHISHING, OTHER';
COMMENT ON COLUMN automation_email_classifier.spam_approvals.approval_status IS 'Status: pending, approved, rejected, auto_approved';
COMMENT ON COLUMN automation_email_classifier.spam_approvals.action_taken IS 'Ação: UNSUBSCRIBED, MARKED_SPAM, WHITELISTED, IGNORED';

-- ===================================================================
-- TRIGGER: Update timestamp
-- ===================================================================

CREATE TRIGGER trigger_spam_approvals_updated_at
    BEFORE UPDATE ON automation_email_classifier.spam_approvals
    FOR EACH ROW
    EXECUTE FUNCTION automation_email_classifier.update_updated_at_column();

-- ===================================================================
-- VALIDATION
-- ===================================================================

DO $$
BEGIN
    RAISE NOTICE 'Migration 006 completed successfully: spam_approvals table created';
END $$;
