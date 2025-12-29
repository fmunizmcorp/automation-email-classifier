-- View: tickets_by_department
-- Description: Análise de tickets agrupados por departamento
-- Created: 2025-12-29

CREATE OR REPLACE VIEW automation_email_classifier.view_tickets_by_department AS
SELECT
    d.id as department_id,
    d.code as department_code,
    d.name as department_name,
    d.manager_email,
    
    -- Ticket Counts by Status
    COUNT(t.id) as total_tickets,
    COUNT(t.id) FILTER (WHERE t.status = 'open') as tickets_open,
    COUNT(t.id) FILTER (WHERE t.status = 'assigned') as tickets_assigned,
    COUNT(t.id) FILTER (WHERE t.status = 'in_progress') as tickets_in_progress,
    COUNT(t.id) FILTER (WHERE t.status = 'on_hold') as tickets_on_hold,
    COUNT(t.id) FILTER (WHERE t.status = 'resolved') as tickets_resolved,
    COUNT(t.id) FILTER (WHERE t.status = 'closed') as tickets_closed,
    
    -- Ticket Counts by Priority
    COUNT(t.id) FILTER (WHERE t.priority = 1) as priority_low,
    COUNT(t.id) FILTER (WHERE t.priority = 2) as priority_normal,
    COUNT(t.id) FILTER (WHERE t.priority = 3) as priority_high,
    COUNT(t.id) FILTER (WHERE t.priority = 4) as priority_urgent,
    
    -- Ticket Counts by Type
    COUNT(t.id) FILTER (WHERE t.ticket_type = 'INFORMACAO') as type_information,
    COUNT(t.id) FILTER (WHERE t.ticket_type = 'ORCAMENTO') as type_quote,
    COUNT(t.id) FILTER (WHERE t.ticket_type = 'SERVICO') as type_service,
    COUNT(t.id) FILTER (WHERE t.ticket_type = 'URGENCIA') as type_urgency,
    
    -- Time-based Metrics
    COUNT(t.id) FILTER (WHERE t.created_at >= CURRENT_DATE) as tickets_today,
    COUNT(t.id) FILTER (WHERE t.created_at >= CURRENT_DATE - INTERVAL '7 days') as tickets_this_week,
    COUNT(t.id) FILTER (WHERE t.created_at >= DATE_TRUNC('month', CURRENT_DATE)) as tickets_this_month,
    
    -- SLA Metrics
    COUNT(t.id) FILTER (WHERE t.response_sla_met = TRUE) as response_sla_met,
    COUNT(t.id) FILTER (WHERE t.response_sla_met = FALSE AND t.first_response_at IS NOT NULL) as response_sla_missed,
    COUNT(t.id) FILTER (WHERE t.resolution_sla_met = TRUE) as resolution_sla_met,
    COUNT(t.id) FILTER (WHERE t.resolution_sla_met = FALSE AND t.resolved_at IS NOT NULL) as resolution_sla_missed,
    
    -- SLA Compliance Rates
    ROUND(
        (COUNT(t.id) FILTER (WHERE t.response_sla_met = TRUE)::DECIMAL / 
         NULLIF(COUNT(t.id) FILTER (WHERE t.first_response_at IS NOT NULL), 0) * 100), 
        2
    ) as response_sla_compliance_pct,
    
    ROUND(
        (COUNT(t.id) FILTER (WHERE t.resolution_sla_met = TRUE)::DECIMAL / 
         NULLIF(COUNT(t.id) FILTER (WHERE t.resolved_at IS NOT NULL), 0) * 100), 
        2
    ) as resolution_sla_compliance_pct,
    
    -- Performance Metrics
    ROUND(AVG(t.response_time_minutes), 2) as avg_response_time_minutes,
    ROUND(AVG(t.resolution_time_minutes), 2) as avg_resolution_time_minutes,
    
    -- Escalation Metrics
    COUNT(t.id) FILTER (WHERE t.escalation_level > 0) as tickets_escalated,
    
    -- Satisfaction Metrics
    ROUND(AVG(t.satisfaction_score), 2) as avg_satisfaction_score,
    COUNT(t.id) FILTER (WHERE t.satisfaction_score IS NOT NULL) as satisfaction_responses,
    
    -- Active Tickets (not resolved/closed)
    COUNT(t.id) FILTER (WHERE t.status NOT IN ('resolved', 'closed')) as active_tickets,
    
    -- Timestamps
    MAX(t.created_at) as last_ticket_created_at,
    MAX(t.updated_at) as last_ticket_updated_at,
    CURRENT_TIMESTAMP as report_generated_at

FROM automation_email_classifier.departments d
LEFT JOIN automation_email_classifier.tickets t ON d.id = t.department_id
WHERE d.is_active = TRUE
GROUP BY d.id, d.code, d.name, d.manager_email
ORDER BY total_tickets DESC;

COMMENT ON VIEW automation_email_classifier.view_tickets_by_department IS 'Análise de tickets agrupados por departamento com métricas de performance e SLA';
