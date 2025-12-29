-- View: knowledge_base_stats
-- Description: Estatísticas da base de conhecimento e uso
-- Created: 2025-12-29

CREATE OR REPLACE VIEW automation_email_classifier.view_knowledge_base_stats AS
SELECT
    -- Knowledge Base Item Details
    kb.id as knowledge_id,
    kb.content_type,
    kb.category,
    kb.title,
    kb.status,
    kb.visibility,
    
    -- Quality Metrics
    kb.relevance_score,
    kb.quality_score,
    kb.usage_count,
    kb.helpful_count,
    kb.not_helpful_count,
    
    -- Helpfulness Rate
    CASE 
        WHEN (kb.helpful_count + kb.not_helpful_count) > 0 THEN
            ROUND((kb.helpful_count::DECIMAL / (kb.helpful_count + kb.not_helpful_count) * 100), 2)
        ELSE 0
    END as helpfulness_rate_pct,
    
    -- Keywords & Topics
    CARDINALITY(kb.keywords) as keywords_count,
    CARDINALITY(kb.topics) as topics_count,
    CARDINALITY(kb.tags) as tags_count,
    CARDINALITY(kb.questions) as questions_count,
    
    -- Source References
    kb.email_id,
    kb.ticket_id,
    e.subject as source_email_subject,
    e.from_email as source_email_from,
    e.received_at as source_email_date,
    t.osticket_ticket_number as source_ticket_number,
    t.status as source_ticket_status,
    
    -- Language
    kb.language,
    
    -- Access Control
    CARDINALITY(kb.allowed_departments) as allowed_departments_count,
    CARDINALITY(kb.allowed_roles) as allowed_roles_count,
    
    -- Versioning
    kb.version,
    kb.is_latest_version,
    kb.previous_version_id,
    
    -- Lifecycle
    kb.published_at,
    kb.expires_at,
    kb.last_reviewed_at,
    kb.reviewed_by,
    
    -- Days since last review
    CASE 
        WHEN kb.last_reviewed_at IS NOT NULL THEN
            EXTRACT(DAY FROM (CURRENT_TIMESTAMP - kb.last_reviewed_at))
        ELSE NULL
    END as days_since_review,
    
    -- Status Flags
    CASE 
        WHEN kb.expires_at IS NOT NULL AND kb.expires_at < CURRENT_TIMESTAMP THEN 'EXPIRED'
        WHEN kb.last_reviewed_at IS NULL OR kb.last_reviewed_at < CURRENT_TIMESTAMP - INTERVAL '90 days' THEN 'NEEDS_REVIEW'
        WHEN kb.status = 'active' THEN 'ACTIVE'
        ELSE kb.status
    END as lifecycle_status,
    
    -- Redis Cache
    kb.redis_key,
    kb.cached_at,
    kb.cache_ttl,
    
    -- Cache freshness (in hours)
    CASE 
        WHEN kb.cached_at IS NOT NULL THEN
            ROUND(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - kb.cached_at)) / 3600, 2)
        ELSE NULL
    END as cache_age_hours,
    
    -- Related Content
    CARDINALITY(kb.related_knowledge_ids) as related_items_count,
    
    -- Chat Usage (aggregated)
    (SELECT COUNT(*) 
     FROM automation_email_classifier.chat_history ch 
     WHERE kb.id = ANY(ch.knowledge_base_sources)
    ) as chat_references_count,
    
    (SELECT AVG(relevance_score) 
     FROM automation_email_classifier.chat_history ch 
     WHERE kb.id = ANY(ch.knowledge_base_sources)
    ) as avg_chat_relevance_score,
    
    -- Timestamps
    kb.created_at,
    kb.updated_at,
    kb.created_by,
    
    -- Calculated Fields
    DATE_TRUNC('day', kb.created_at) as created_date,
    DATE_TRUNC('week', kb.created_at) as created_week,
    DATE_TRUNC('month', kb.created_at) as created_month

FROM automation_email_classifier.knowledge_base kb
LEFT JOIN automation_email_classifier.emails e ON kb.email_id = e.id
LEFT JOIN automation_email_classifier.tickets t ON kb.ticket_id = t.id
ORDER BY kb.usage_count DESC, kb.relevance_score DESC;

COMMENT ON VIEW automation_email_classifier.view_knowledge_base_stats IS 'Estatísticas da base de conhecimento com métricas de uso e qualidade';
