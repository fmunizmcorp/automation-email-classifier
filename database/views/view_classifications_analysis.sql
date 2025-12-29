-- View: classifications_analysis
-- Description: Análise detalhada de classificações por tipo, confiança e departamento
-- Created: 2025-12-29

CREATE OR REPLACE VIEW automation_email_classifier.view_classifications_analysis AS
SELECT
    -- Classification Details
    c.id as classification_id,
    c.classification_type,
    c.sub_category,
    c.ticket_type,
    c.priority_suggested,
    c.confidence_score,
    c.sentiment,
    c.ai_model,
    
    -- Email Information
    e.id as email_id,
    e.from_email,
    e.subject,
    e.received_at,
    e.has_attachments,
    
    -- Department
    d.name as department_name,
    d.code as department_code,
    c.department_confidence,
    
    -- SLA
    s.name as sla_name,
    s.response_time_minutes as sla_response_minutes,
    s.resolution_time_minutes as sla_resolution_minutes,
    
    -- AI Performance
    c.processing_time_ms,
    c.tokens_used,
    c.cost_usd,
    
    -- Validation
    c.is_validated,
    c.was_correct,
    c.validated_by,
    c.validated_at,
    
    -- Timestamps
    c.created_at,
    
    -- Calculated Fields
    CASE 
        WHEN c.confidence_score >= 90 THEN 'High'
        WHEN c.confidence_score >= 70 THEN 'Medium'
        ELSE 'Low'
    END as confidence_level,
    
    DATE_TRUNC('day', c.created_at) as classification_date,
    DATE_TRUNC('hour', c.created_at) as classification_hour,
    EXTRACT(DOW FROM c.created_at) as day_of_week,
    EXTRACT(HOUR FROM c.created_at) as hour_of_day

FROM automation_email_classifier.classifications c
INNER JOIN automation_email_classifier.emails e ON c.email_id = e.id
LEFT JOIN automation_email_classifier.departments d ON c.department_id = d.id
LEFT JOIN automation_email_classifier.slas s ON c.sla_id = s.id
ORDER BY c.created_at DESC;

COMMENT ON VIEW automation_email_classifier.view_classifications_analysis IS 'Análise detalhada de classificações de IA por tipo, confiança e departamento';
