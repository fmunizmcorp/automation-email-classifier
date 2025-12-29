-- View: sla_performance
-- Description: Análise de performance de SLA (resposta e resolução)
-- Created: 2025-12-29

CREATE OR REPLACE VIEW automation_email_classifier.view_sla_performance AS
SELECT
    -- Ticket Details
    t.id as ticket_id,
    t.osticket_ticket_number,
    t.subject,
    t.ticket_type,
    t.priority,
    t.status,
    
    -- Customer
    t.customer_name,
    t.customer_email,
    
    -- Department
    d.name as department_name,
    d.code as department_code,
    
    -- SLA Configuration
    s.name as sla_name,
    s.response_time_minutes as sla_response_target,
    s.resolution_time_minutes as sla_resolution_target,
    
    -- SLA Deadlines
    t.sla_response_deadline,
    t.sla_resolution_deadline,
    t.first_response_at,
    t.resolved_at,
    
    -- SLA Compliance
    t.response_sla_met,
    t.resolution_sla_met,
    t.response_time_minutes as actual_response_time,
    t.resolution_time_minutes as actual_resolution_time,
    
    -- Time Differences (in minutes)
    CASE 
        WHEN t.first_response_at IS NOT NULL THEN
            EXTRACT(EPOCH FROM (t.sla_response_deadline - t.first_response_at)) / 60
        ELSE
            EXTRACT(EPOCH FROM (t.sla_response_deadline - CURRENT_TIMESTAMP)) / 60
    END as response_time_remaining,
    
    CASE 
        WHEN t.resolved_at IS NOT NULL THEN
            EXTRACT(EPOCH FROM (t.sla_resolution_deadline - t.resolved_at)) / 60
        ELSE
            EXTRACT(EPOCH FROM (t.sla_resolution_deadline - CURRENT_TIMESTAMP)) / 60
    END as resolution_time_remaining,
    
    -- Status Flags
    CASE 
        WHEN t.first_response_at IS NULL AND t.sla_response_deadline < CURRENT_TIMESTAMP THEN 'BREACHED'
        WHEN t.first_response_at IS NULL AND t.sla_response_deadline < CURRENT_TIMESTAMP + INTERVAL '1 hour' THEN 'AT_RISK'
        WHEN t.first_response_at IS NULL THEN 'ON_TRACK'
        WHEN t.response_sla_met = TRUE THEN 'MET'
        ELSE 'MISSED'
    END as response_sla_status,
    
    CASE 
        WHEN t.resolved_at IS NULL AND t.sla_resolution_deadline < CURRENT_TIMESTAMP THEN 'BREACHED'
        WHEN t.resolved_at IS NULL AND t.sla_resolution_deadline < CURRENT_TIMESTAMP + INTERVAL '2 hours' THEN 'AT_RISK'
        WHEN t.resolved_at IS NULL THEN 'ON_TRACK'
        WHEN t.resolution_sla_met = TRUE THEN 'MET'
        ELSE 'MISSED'
    END as resolution_sla_status,
    
    -- Assignment
    t.assigned_to,
    t.assigned_at,
    
    -- Escalation
    t.escalation_level,
    t.escalated_at,
    
    -- Timestamps
    t.created_at,
    t.updated_at,
    t.last_activity_at,
    
    -- Calculated Fields
    DATE_TRUNC('day', t.created_at) as ticket_date,
    EXTRACT(DOW FROM t.created_at) as day_of_week,
    EXTRACT(HOUR FROM t.created_at) as hour_of_day

FROM automation_email_classifier.tickets t
INNER JOIN automation_email_classifier.departments d ON t.department_id = d.id
INNER JOIN automation_email_classifier.slas s ON t.sla_id = s.id
ORDER BY t.created_at DESC;

COMMENT ON VIEW automation_email_classifier.view_sla_performance IS 'Análise de performance de SLA com status de resposta e resolução';
