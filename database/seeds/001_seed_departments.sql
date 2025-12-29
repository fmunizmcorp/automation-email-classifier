-- Seed: 001_seed_departments.sql
-- Description: Dados iniciais de departamentos da clínica
-- Created: 2025-12-29

-- ===================================================================
-- SEED: Departamentos
-- ===================================================================

INSERT INTO automation_email_classifier.departments 
(code, name, description, email_patterns, keywords, priority_default, manager_email, is_active)
VALUES
-- Atendimento ao Paciente
('ATENDIMENTO', 
 'Atendimento ao Paciente', 
 'Departamento responsável pelo atendimento geral aos pacientes, agendamentos e informações',
 ARRAY['.*atendimento.*', '.*contato.*', '.*paciente.*'],
 ARRAY['agendamento', 'consulta', 'marcação', 'horário', 'atendimento', 'informação', 'dúvida'],
 2,
 'atendimento@clinfec.com.br',
 TRUE),

-- Financeiro
('FINANCEIRO',
 'Financeiro',
 'Departamento financeiro responsável por pagamentos, boletos, notas fiscais',
 ARRAY['.*financeiro.*', '.*pagamento.*', '.*cobranca.*'],
 ARRAY['pagamento', 'boleto', 'nota fiscal', 'nf', 'fatura', 'cobrança', 'recibo', 'valor'],
 2,
 'financeiro@clinfec.com.br',
 TRUE),

-- Clínico/Médico
('CLINICO',
 'Clínico',
 'Departamento clínico para questões médicas e exames',
 ARRAY['.*clinico.*', '.*medico.*', '.*exame.*'],
 ARRAY['exame', 'resultado', 'laudo', 'médico', 'doutor', 'tratamento', 'diagnóstico'],
 3,
 'clinico@clinfec.com.br',
 TRUE),

-- Orçamento
('ORCAMENTO',
 'Orçamento',
 'Departamento de orçamentos e cotações',
 ARRAY['.*orcamento.*', '.*cotacao.*'],
 ARRAY['orçamento', 'cotação', 'preço', 'quanto custa', 'valor', 'custo'],
 2,
 'orcamento@clinfec.com.br',
 TRUE),

-- TI/Suporte Técnico
('TI',
 'TI - Tecnologia da Informação',
 'Departamento de tecnologia e suporte técnico',
 ARRAY['.*ti@.*', '.*suporte.*', '.*tecnico.*'],
 ARRAY['sistema', 'erro', 'acesso', 'senha', 'login', 'tecnologia', 'suporte'],
 2,
 'ti@clinfec.com.br',
 TRUE),

-- RH - Recursos Humanos
('RH',
 'Recursos Humanos',
 'Departamento de recursos humanos',
 ARRAY['.*rh@.*', '.*recursos.*humanos.*'],
 ARRAY['contratação', 'vaga', 'emprego', 'funcionário', 'colaborador', 'currí  culo'],
 2,
 'rh@clinfec.com.br',
 TRUE),

-- Urgência/Emergência
('URGENCIA',
 'Urgência/Emergência',
 'Departamento para situações urgentes e emergenciais',
 ARRAY['.*urgente.*', '.*emergencia.*'],
 ARRAY['urgente', 'emergência', 'imediato', 'agora', 'prioridade', 'crítico'],
 4,
 'urgencia@clinfec.com.br',
 TRUE),

-- Administrativo Geral
('ADMIN',
 'Administrativo',
 'Departamento administrativo geral',
 ARRAY['.*admin.*', '.*administrativo.*'],
 ARRAY['documento', 'protocolo', 'processo', 'certificado', 'atestado'],
 2,
 'admin@clinfec.com.br',
 TRUE)

ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    email_patterns = EXCLUDED.email_patterns,
    keywords = EXCLUDED.keywords,
    priority_default = EXCLUDED.priority_default,
    manager_email = EXCLUDED.manager_email,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = 'seed_script';

-- ===================================================================
-- VALIDATION
-- ===================================================================

DO $$
DECLARE
    dept_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO dept_count FROM automation_email_classifier.departments;
    RAISE NOTICE 'Seed 001 completed: % departments inserted/updated', dept_count;
END $$;
