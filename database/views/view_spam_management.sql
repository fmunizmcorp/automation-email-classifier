-- View: spam_management
-- Description: Análise de aprovações de spam e ações tomadas
-- Created: 2025-12-29

CREATE OR REPLACE VIEW automation_email_classifier.view_spam_management AS
SELECT
    -- Spam Approval Details
    sa.id as spam_approval_id,
    sa.spam_type,
    sa.approval_status,
    sa.action_taken,
    
    -- Sender Information
    sa.sender_email,
    sa.sender_domain,
    sa.sender_previous_spam_count,
    sa.sender_whitelisted,
    sa.sender_blacklisted,
    
    -- Email Details
    e.id as email_id,
    e.gmail_message_id,
    sa.subject,
    e.received_at,
    e.has_attachments,
    
    -- Detection
    sa.detection_reason,
    sa.spam_score,
    CARDINALITY(sa.spam_indicators) as spam_indicators_count,
    
    -- Approval Process
    sa.approval_requested_at,
    sa.approval_deadline,
    sa.approver_email,
    sa.approver_name,
    sa.approved_at,
    sa.approval_notes,
    
    -- Time to Approve (in hours)
    CASE 
        WHEN sa.approved_at IS NOT NULL THEN
            ROUND(EXTRACT(EPOCH FROM (sa.approved_at - sa.approval_requested_at)) / 3600, 2)
        ELSE
            ROUND(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - sa.approval_requested_at)) / 3600, 2)
    END as approval_time_hours,
    
    -- Deadline Status
    CASE 
        WHEN sa.approval_status = 'pending' AND sa.approval_deadline < CURRENT_TIMESTAMP THEN 'OVERDUE'
        WHEN sa.approval_status = 'pending' AND sa.approval_deadline < CURRENT_TIMESTAMP + INTERVAL '2 hours' THEN 'DUE_SOON'
        WHEN sa.approval_status = 'pending' THEN 'PENDING'
        ELSE 'COMPLETED'
    END as approval_deadline_status,
    
    -- Action Details
    sa.action_taken_at,
    sa.unsubscribe_method,
    sa.unsubscribe_success,
    sa.unsubscribe_error,
    
    -- Gmail Actions
    sa.gmail_label_added,
    sa.gmail_archived,
    sa.gmail_deleted,
    
    -- Auto-approval
    sa.auto_approved,
    sa.auto_approval_rule,
    
    -- Notification Status
    sa.notification_sent,
    sa.reminder_sent_count,
    sa.last_reminder_at,
    
    -- Classification Info
    c.confidence_score as classification_confidence,
    c.ai_model as classification_model,
    
    -- Timestamps
    sa.created_at,
    sa.updated_at,
    
    -- Calculated Fields
    DATE_TRUNC('day', sa.created_at) as spam_date,
    DATE_TRUNC('week', sa.created_at) as spam_week,
    EXTRACT(DOW FROM sa.created_at) as day_of_week

FROM automation_email_classifier.spam_approvals sa
INNER JOIN automation_email_classifier.emails e ON sa.email_id = e.id
LEFT JOIN automation_email_classifier.classifications c ON sa.classification_id = c.id
ORDER BY sa.created_at DESC;

COMMENT ON VIEW automation_email_classifier.view_spam_management IS 'Análise de aprovações de spam com status de ações e deadlines';
