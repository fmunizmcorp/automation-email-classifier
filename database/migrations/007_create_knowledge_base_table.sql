-- Migration: 007_create_knowledge_base_table.sql
-- Description: Tabela de base de conhecimento para IA e chat
-- Created: 2025-12-29
-- Schema: automation_email_classifier

-- ===================================================================
-- TABELA: knowledge_base
-- Descrição: Base de conhecimento construída a partir dos emails e tickets
-- ===================================================================

CREATE TABLE IF NOT EXISTS automation_email_classifier.knowledge_base (
    -- Primary Key
    id SERIAL PRIMARY KEY,
    
    -- Source References
    email_id INTEGER REFERENCES automation_email_classifier.emails(id) ON DELETE CASCADE,
    ticket_id INTEGER REFERENCES automation_email_classifier.tickets(id),
    classification_id INTEGER REFERENCES automation_email_classifier.classifications(id),
    
    -- Content Type
    content_type VARCHAR(50) NOT NULL, -- EMAIL, TICKET, FAQ, PROCEDURE, TEMPLATE
    category VARCHAR(100), -- Categorização do conhecimento
    
    -- Main Content
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    summary TEXT, -- Resumo gerado pela IA
    keywords TEXT[],
    
    -- Extracted Knowledge
    questions TEXT[], -- Perguntas respondidas por este conteúdo
    answers TEXT[], -- Respostas correspondentes
    entities JSONB, -- Entidades mencionadas (pessoas, produtos, serviços)
    topics TEXT[], -- Tópicos abordados
    
    -- Language & Embedding
    language VARCHAR(10) DEFAULT 'pt-BR',
    -- embedding_vector VECTOR(1536), -- Vector embedding do OpenAI para semantic search (requer pgvector extension)
    embedding_text TEXT, -- Texto usado para gerar embedding (armazenado para referência)
    embedding_model VARCHAR(100) DEFAULT 'text-embedding-ada-002',
    
    -- Relevance & Quality
    relevance_score DECIMAL(5,2) DEFAULT 50.00, -- Score de relevância (0-100)
    quality_score DECIMAL(5,2) DEFAULT 50.00, -- Score de qualidade (0-100)
    usage_count INTEGER DEFAULT 0, -- Quantas vezes foi usado/referenciado
    helpful_count INTEGER DEFAULT 0, -- Quantas vezes foi marcado como útil
    not_helpful_count INTEGER DEFAULT 0, -- Quantas vezes foi marcado como não útil
    
    -- Access Control
    visibility VARCHAR(50) DEFAULT 'internal', -- public, internal, restricted, private
    allowed_departments TEXT[],
    allowed_roles TEXT[],
    
    -- Versioning
    version INTEGER DEFAULT 1,
    is_latest_version BOOLEAN DEFAULT TRUE,
    previous_version_id INTEGER REFERENCES automation_email_classifier.knowledge_base(id),
    
    -- Status & Lifecycle
    status VARCHAR(50) DEFAULT 'active', -- active, archived, deprecated, deleted
    published_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    last_reviewed_at TIMESTAMP WITH TIME ZONE,
    reviewed_by VARCHAR(200),
    
    -- Metadata
    tags TEXT[],
    related_knowledge_ids INTEGER[],
    source_url TEXT,
    attachments JSONB,
    
    -- Redis Cache
    redis_key VARCHAR(255), -- Chave no Redis para cache
    cached_at TIMESTAMP WITH TIME ZONE,
    cache_ttl INTEGER DEFAULT 86400, -- TTL em segundos (padrão 24h)
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) DEFAULT 'system'
);

-- ===================================================================
-- INDEXES
-- ===================================================================

CREATE INDEX idx_knowledge_base_email ON automation_email_classifier.knowledge_base(email_id);
CREATE INDEX idx_knowledge_base_ticket ON automation_email_classifier.knowledge_base(ticket_id);
CREATE INDEX idx_knowledge_base_type ON automation_email_classifier.knowledge_base(content_type);
CREATE INDEX idx_knowledge_base_category ON automation_email_classifier.knowledge_base(category);
CREATE INDEX idx_knowledge_base_status ON automation_email_classifier.knowledge_base(status);
CREATE INDEX idx_knowledge_base_relevance ON automation_email_classifier.knowledge_base(relevance_score DESC);
CREATE INDEX idx_knowledge_base_usage ON automation_email_classifier.knowledge_base(usage_count DESC);
CREATE INDEX idx_knowledge_base_latest ON automation_email_classifier.knowledge_base(is_latest_version) WHERE is_latest_version = TRUE;

-- Full-text search indexes
CREATE INDEX idx_knowledge_base_title_search ON automation_email_classifier.knowledge_base USING GIN(to_tsvector('portuguese', title));
CREATE INDEX idx_knowledge_base_content_search ON automation_email_classifier.knowledge_base USING GIN(to_tsvector('portuguese', content));

-- GIN indexes for array fields
CREATE INDEX idx_knowledge_base_keywords ON automation_email_classifier.knowledge_base USING GIN(keywords);
CREATE INDEX idx_knowledge_base_topics ON automation_email_classifier.knowledge_base USING GIN(topics);
CREATE INDEX idx_knowledge_base_tags ON automation_email_classifier.knowledge_base USING GIN(tags);

-- Vector similarity search (requires pgvector extension - disabled for now)
-- Uncomment and run after installing pgvector:
-- ALTER TABLE automation_email_classifier.knowledge_base ADD COLUMN embedding_vector VECTOR(1536);
-- CREATE INDEX idx_knowledge_base_embedding ON automation_email_classifier.knowledge_base USING ivfflat (embedding_vector vector_cosine_ops);

-- ===================================================================
-- COMMENTS
-- ===================================================================

COMMENT ON TABLE automation_email_classifier.knowledge_base IS 'Base de conhecimento construída a partir dos emails e tickets';
COMMENT ON COLUMN automation_email_classifier.knowledge_base.content_type IS 'Tipo: EMAIL, TICKET, FAQ, PROCEDURE, TEMPLATE';
COMMENT ON COLUMN automation_email_classifier.knowledge_base.embedding_text IS 'Texto usado para gerar embedding (armazenado para referência)';
COMMENT ON COLUMN automation_email_classifier.knowledge_base.visibility IS 'Visibilidade: public, internal, restricted, private';

-- ===================================================================
-- TRIGGER: Update timestamp
-- ===================================================================

CREATE TRIGGER trigger_knowledge_base_updated_at
    BEFORE UPDATE ON automation_email_classifier.knowledge_base
    FOR EACH ROW
    EXECUTE FUNCTION automation_email_classifier.update_updated_at_column();

-- ===================================================================
-- VALIDATION
-- ===================================================================

DO $$
BEGIN
    RAISE NOTICE 'Migration 007 completed successfully: knowledge_base table created';
    RAISE NOTICE 'Note: Vector similarity search requires pgvector extension';
END $$;
