<!--
  =====================================================================
  GRAPHIFY - Bloco de instrucoes obrigatorias (gerado automaticamente)
  Colocado AQUI NO TOPO para que o Claude.ai web siga sem dica adicional.
  Workflow .github/workflows/graphify.yml mantem o grafo atualizado.
  =====================================================================
-->

# CLAUDE.md - Instrucoes Mestras

> **VOCE (Claude) DEVE LER ESTE ARQUIVO INTEIRO ANTES DE FAZER QUALQUER COISA.**
> **Em seguida, OBRIGATORIAMENTE consultar os arquivos listados abaixo.**

## ZERO. PROTOCOLO DE ATIVACAO (executar SEMPRE no inicio da conversa)

Voce DEVE ler nesta ordem antes de responder o usuario:

1. **Este CLAUDE.md inteiro** (regras, contexto, conhecimento)
2. **`graphify-out/GRAPH_REPORT.md`** - mapa do codigo (God Nodes, Communities, conexoes)
3. **`graphify-out/manifest.json`** - lista de arquivos analisados
4. **`.claude/skills.md`** - skills aplicaveis a este projeto
5. **(opcional) `graphify-out/graph.json`** - grafo estruturado para localizar simbolos

So abra outros arquivos APOS consultar o grafo. Use `graph.json` como indice. Nunca varra a arvore de arquivos.

Se algum desses arquivos nao existir, AVISE o usuario que o repo precisa rodar
o workflow Graphify ou que o grafo esta defasado.

## ZERO.1 PROTOCOLO DE EXCELENCIA (sempre vale)

- **Tudo e importante**: nao julgar prioridades. Ordenar so por dependencia tecnica.
- **Nada parcial**: completar 100% antes de seguir. Nada de "principal primeiro".
- **Nao perguntar no meio**: seguir ate o final, relatar erros e tratar imediatamente.
- **Microsprints**: 1 detalhe = 1 sprint. PDCA a cada ciclo de 5-10 sprints.
- **Testes completos**: testar cada campo, botao, rota, link individualmente.
- **PT-BR obrigatorio**: variaveis, comentarios, mensagens, commits em portugues.
- **UTF-8 + timezone America/Sao_Paulo**.
- **Validacoes Brasil quando aplicavel**: CPF, CNPJ, CEP, telefone.
- **LGPD prioritaria** para dados pessoais.
- **Versionamento**: SemVer (MAJOR.MINOR.PATCH) atualizado em todos os locais.
- **Documentacao continua**: atualizar este CLAUDE.md ao final de cada sessao.
- **GitHub + deploy**: commit + push + deploy + validacao final em producao.

## ZERO.2 SKILLS APLICAVEIS

Veja `.claude/skills.md` para a lista completa. Resumo basal (sempre validas):
`excelencia-total`, `scrum-microsprints`, `documentacao-continua`,
`versionamento-sistema`, `testes-completos`. Skills condicionais e
tecnologia-especificas listadas em `.claude/skills.md`.

---

## 1. IDENTIDADE DO PROJETO

- **Repositorio:** `fmunizmcorp/automation-email-classifier`
- **Descricao:** Sistema inteligente de classificação de emails com IA e criação automática de chamados osTicket
- **Tamanho:** ~70 KB
- **Skill stack:** generico
- **Visualizacao:** `graphify-out/graph.html` e `graphify-out/GRAPH_TREE.html`

## 2. GOD NODES (estrutura central detectada pelo grafo)



## 3. COMMUNITIES (modulos detectados)



## 4. CONTEXTO DO PROJETO (extraido do README)

# ð§ AutomaÃ§Ã£o: Email Classifier com IA

## ð¯ Objetivo

Sistema inteligente de classificaÃ§Ã£o automÃ¡tica de emails do Google Workspace com IA (OpenAI GPT-4), criaÃ§Ã£o automÃ¡tica de chamados no osTicket, roteamento inteligente por departamento e prioridade, cache Redis para base de conhecimento e dashboards em tempo real no Metabase.

## ð DescriÃ§Ã£o

Esta automaÃ§Ã£o processa emails recebidos nas contas/grupos do Google Workspace da empresa, utilizando InteligÃªncia Artificial para:

1. **Classificar automaticamente** em 3 categorias:
   - ðï¸ **Spam/PromoÃ§Ãµes**: Listados para aprovaÃ§Ã£o do gestor â Descadastramento automÃ¡tico
   - ð¤ **Cliente/Paciente**: CriaÃ§Ã£o automÃ¡tica de chamado no osTicket com SLA apropriado
   - ð **Administrativo**: CriaÃ§Ã£o de chamado para Ã¡rea administrativa (NF, boletos, etc.)

2. **Processar inteligentemente**:
   - ExtraÃ§Ã£o de anexos e salvamento na pasta do paciente/cliente
   - IdentificaÃ§Ã£o de tipo de solicitaÃ§Ã£o (informaÃ§Ã£o, orÃ§amento, serviÃ§o, urgÃªncia)
   - CÃ¡lculo automÃ¡tico de prioridade e tempo de SLA
   - Roteamento para departamento responsÃ¡vel

3. **Base de Conhecimento**:
   - Armazenamento de todos os emails processados
   - Cache Redis para acesso rÃ¡pido pela IA
   - Interface de chat para consulta organizada
   - HistÃ³rico completo de interaÃ§Ãµes

## ðï¸ Arquitetura

```
âââââââââââââââââââ
â Google Workspaceâ
â   (Gmail API)   â
ââââââââââ¬âââââââââ
         â
         â¼
âââââââââââââââââââ
â  N8N Workflow   â
â  Email Reader   â
ââââââââââ¬âââââââââ
         â
         â¼
âââââââââââââââââââ
â   OpenAI GPT-4  â
â  (ClassificaÃ§Ã£o)â
ââââââââââ¬âââââââââ
         â
    ââââââ´âââââ
    â¼         â¼         â¼
âââââââââ ââââââââ ââââââââââ
â Spam  â âClientâ â  Admin â
âManagerâ âTicketâ â Ticket â
âââââââââ ââââââââ ââââââââââ
    â         â         â
    â¼         â¼         â¼
âââââââââââââââââââââââââââ
â      osTicket API       â
âââââââââââââââââââââââââââ
         â
         â¼
âââââââââââââââââââââââââââ
â  PostgreSQL Database    â
â  + Redis Cache          â
âââââââââââââââââââââââââââ
         â
         â¼
âââââââââââââââââââââââââââ
â   Metabase Dashboard    â
âââââââââââââââââââââââââââ
```

## ðï¸ Estrutura do Projeto

```
automation-email-classifier/
âââ README.md                 # Este arquivo
âââ .gitignore               # Arquivos ignorados pelo Git
âââ database/                # Banco de dados
â   âââ migrations/          # Migrations SQL (8 tabelas)
â   âââ seeds/               # Dados iniciais
â   âââ views/               # Views para Metabase
âââ n8n/                     # Workflows N8N
â   âââ workflows/           # 6 workflows JSON
âââ docs/                    # DocumentaÃ§Ã£o completa
â   âââ ARCHITECTURE.md      # Arquitetura detalhada
â   âââ SETUP.md            # Guia de instalaÃ§Ã£o
â   âââ API.md              # DocumentaÃ§Ã£o de APIs
â   âââ TROUBLESHOOTING.md  # ResoluÃ§Ã£o de problemas
âââ scripts/                 # Scripts utilitÃ¡rios
â   âââ deploy.sh           # Script de deployment
â   âââ backup.sh           # Sc


[README continua em README.md]

## 6. ESTRUTURA DA RAIZ

```
.claude
.github
.gitignore
CLAUDE.md
IMPORT_MANUAL_GUIDE.md
README.md
STATUS_FINAL.md
database
docs
graphify-out
n8n
```

---

## ENTREGA OBRIGATORIA AO FINAL DE CADA TAREFA

- [ ] Codigo completo (nao so a parte principal)
- [ ] Testes executados em cada detalhe
- [ ] Este CLAUDE.md atualizado com aprendizados
- [ ] CHANGELOG ou docs atualizados
- [ ] Versao incrementada em todos os locais (SemVer)
- [ ] commit + push para GitHub
- [ ] Deploy em producao executado
- [ ] Validacao final em producao
- [ ] Grafo Graphify regenerado (workflow automatico cuida)

---

> **Versao deste CLAUDE.md:** v2 - Graphify integrado em 2026-05-04
> **Mantido por:** workflow .github/workflows/graphify.yml + edicao manual quando necessario
