-- View: dashboard_overview
-- Description: Visão geral do sistema para dashboard principal
-- Created: 2025-12-29

CREATE OR REPLACE VIEW automation_email_classifier.dashboard_overview AS
SELECT
    -- Métricas de Emails
    COUNT(DISTINCT e.id) as total_emails,
    COUNT(DISTINCT e.id) FILTER (WHERE e.received_at >= CURRENT_DATE) as emails_today,
    COUNT(DISTINCT e.id) FILTER (WHERE e.received_at >= CURRENT_DATE - INTERVAL '7 days') as emails_week,
    COUNT(DISTINCT e.id) FILTER (WHERE e.processing_status = 'pending') as emails_pending,
    COUNT(DISTINCT e.id) FILTER (WHERE e.processing_status = 'completed') as emails_processed,
    COUNT(DISTINCT e.id) FILTER (WHERE e.processing_status = 'failed') as emails_failed,
    COUNT(DISTINCT e.id) FILTER (WHERE e.has_attachments = TRUE) as emails_with_attachments,
    
    -- Métricas de Classificação
    COUNT(DISTINCT c.id) as total_classifications,
    COUNT(DISTINCT c.id) FILTER (WHERE c.classification_type = 'SPAM') as classifications_spam,
    COUNT(DISTINCT c.id) FILTER (WHERE c.classification_type = 'CLIENT') as classifications_client,
    COUNT(DISTINCT c.id) FILTER (WHERE c.classification_type = 'ADMIN') as classifications_admin,
    ROUND(AVG(c.confidence_score), 2) as avg_confidence_score,
    
    -- Métricas de Tickets
    COUNT(DISTINCT t.id) as total_tickets,
    COUNT(DISTINCT t.id) FILTER (WHERE t.status = 'open') as tickets_open,
    COUNT(DISTINCT t.id) FILTER (WHERE t.status IN ('assigned', 'in_progress')) as tickets_in_progress,
    COUNT(DISTINCT t.id) FILTER (WHERE t.status = 'resolved') as tickets_resolved,
    COUNT(DISTINCT t.id) FILTER (WHERE t.priority = 4) as tickets_urgent,
    
    -- Métricas de SLA
    COUNT(DISTINCT t.id) FILTER (WHERE t.response_sla_met = TRUE) as sla_response_met,
    COUNT(DISTINCT t.id) FILTER (WHERE t.response_sla_met = FALSE AND t.first_response_at IS NOT NULL) as sla_response_missed,
    COUNT(DISTINCT t.id) FILTER (WHERE t.resolution_sla_met = TRUE) as sla_resolution_met,
    COUNT(DISTINCT t.id) FILTER (WHERE t.resolution_sla_met = FALSE AND t.resolved_at IS NOT NULL) as sla_resolution_missed,
    ROUND(
        (COUNT(DISTINCT t.id) FILTER (WHERE t.response_sla_met = TRUE)::DECIMAL / 
         NULLIF(COUNT(DISTINCT t.id) FILTER (WHERE t.first_response_at IS NOT NULL), 0) * 100), 
        2
    ) as sla_response_compliance_pct,
    
    -- Métricas de Spam
    COUNT(DISTINCT sa.id) as total_spam_approvals,
    COUNT(DISTINCT sa.id) FILTER (WHERE sa.approval_status = 'pending') as spam_pending_approval,
    COUNT(DISTINCT sa.id) FILTER (WHERE sa.approval_status = 'approved') as spam_approved,
    COUNT(DISTINCT sa.id) FILTER (WHERE sa.action_taken = 'UNSUBSCRIBED') as spam_unsubscribed,
    
    -- Métricas de Knowledge Base
    COUNT(DISTINCT kb.id) as total_knowledge_items,
    COUNT(DISTINCT kb.id) FILTER (WHERE kb.status = 'active') as knowledge_active,
    SUM(kb.usage_count) as knowledge_total_usage,
    
    -- Timestamp da última atualização
    CURRENT_TIMESTAMP as last_updated

FROM automation_email_classifier.emails e
LEFT JOIN automation_email_classifier.classifications c ON e.id = c.email_id
LEFT JOIN automation_email_classifier.tickets t ON e.id = t.email_id
LEFT JOIN automation_email_classifier.spam_approvals sa ON e.id = sa.email_id
LEFT JOIN automation_email_classifier.knowledge_base kb ON e.id = kb.email_id;

COMMENT ON VIEW automation_email_classifier.dashboard_overview IS 'Visão geral do sistema com métricas principais para dashboard';
