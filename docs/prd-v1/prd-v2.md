from pathlib import Path

content = r"""# Drone Data Platform Brasil — PRD Mestre, Backlog, ERD, Banco de Dados, Seeds e ActiveAdmin

## 1. Resumo executivo

Este documento define o produto, o backlog inicial, as regras de negócio, o modelo de dados, as seeds, a estrutura de ActiveAdmin e a base para usar **Rails + ActiveAdmin como backend operacional e administrativo** de uma plataforma enterprise de **drone data sob demanda**, inspirada no racional da Globhe e adaptada para o mercado brasileiro.

A plataforma conecta:

- **Clientes B2B** que criam pedidos de coleta/análise com drones
- **Operadores verificados** que enviam propostas e executam missões
- **Admin/ops** que controlam matching, QA, compliance, billing e suporte

---

## 2. Visão do produto

### 2.1 Objetivo
Construir uma infraestrutura digital para contratação, execução, validação e entrega de dados geoespaciais capturados por drones.

### 2.2 Proposta de valor
- contratação padronizada
- rede qualificada de operadores
- comparativo de propostas
- gestão de missão ponta a ponta
- controle de qualidade
- compliance operacional e documental
- billing e payout integrados
- capacidade futura de API, library e recorrência

### 2.3 Posicionamento
> Plataforma brasileira de drone data sob demanda para empresas, com operadores verificados, compliance nativo e entrega técnica padronizada.

---

## 3. Problema

Hoje, no Brasil:

- contratação de operador é fragmentada
- qualidade do dado é inconsistente
- falta rastreabilidade operacional
- grande parte do mercado funciona por WhatsApp e indicação
- não há padrão de bidding/aceite
- não há camada de trust/reputation escalável
- não há visão centralizada para grandes clientes multi-site

---

## 4. Objetivos do produto

### 4.1 Objetivos primários
- permitir criação de pedidos com especificação técnica
- habilitar matching e bidding entre pedido e operador
- transformar proposta vencedora em missão
- receber e validar entregáveis técnicos
- controlar financeiro de cobrança e repasse
- usar ActiveAdmin como base de operação interna

### 4.2 Objetivos secundários
- disponibilizar recorrência
- criar motor de reputação
- expor API para clientes enterprise
- habilitar data library futura

---

## 5. Escopo do MVP enterprise

### Incluído
- autenticação
- organizações e membros
- perfis de operador
- equipamentos e sensores
- pedidos
- propostas
- missões
- datasets
- QA
- compliance documental
- faturas
- pagamentos
- repasses
- conversas e mensagens
- logs de auditoria
- webhooks
- SaaS plans/subscriptions/leads
- ActiveAdmin completo

### Não incluído no MVP
- billing recorrente avançado
- recomendação por ML
- roteamento automatizado sofisticado
- processamento geoespacial pesado
- marketplace público de datasets
- app mobile nativo

---

## 6. Personas

### 6.1 Cliente enterprise
Empresas de energia, agro, infraestrutura, telecom, mineração ou facilities que precisam contratar serviços de drone em escala.

### 6.2 Operador
Piloto individual ou empresa operadora com drone, sensores e capacidade técnica para executar missões.

### 6.3 Admin/ops
Equipe da plataforma responsável por verificação, matching, qualidade, compliance, suporte e financeiro.

### 6.4 Financeiro
Usuário cliente ou interno que acompanha faturas, pagamentos e repasses.

---

## 7. Jornadas principais

### 7.1 Jornada do cliente
1. cadastro / convite
2. criação de organização
3. criação de pedido
4. upload de escopo e área
5. recebimento de propostas
6. seleção da proposta
7. acompanhamento da missão
8. QA / aprovação
9. recebimento do dataset
10. pagamento / histórico

### 7.2 Jornada do operador
1. cadastro
2. onboarding em etapas
3. envio de documentos
4. cadastro de equipamento
5. definição de capabilities
6. recebimento de oportunidade
7. envio de proposta
8. execução da missão
9. upload dos arquivos
10. repasse

### 7.3 Jornada do admin
1. revisão de operador
2. verificação documental
3. curadoria de matching
4. acompanhamento da missão
5. validação QA
6. cobrança / repasse
7. suporte / auditoria

---

## 8. PRD por módulos

# Módulo A — Identity & Access

## Objetivo
Gerenciar usuários, organizações, memberships, permissões e API keys.

## User stories

### US-A1
Como usuário, quero criar minha conta para acessar a plataforma.

**Critérios de aceite**
- email obrigatório e único
- senha obrigatória
- conta nasce com status `active` ou `invited` conforme fluxo
- timestamps registrados

### US-A2
Como organização, quero convidar membros para colaborar na minha operação.

**Critérios de aceite**
- membership deve vincular user + organization
- role obrigatório
- status do membership deve permitir `invited`, `active`, `revoked`

### US-A3
Como cliente enterprise, quero gerar uma API key para integração.

**Critérios de aceite**
- token não pode ser salvo em texto puro
- a key deve ter escopos
- a key pode ser revogada
- uso deve registrar `last_used_at`

---

# Módulo B — SaaS

## Objetivo
Suportar planos, assinaturas, acessos e leads.

## User stories

### US-B1
Como admin, quero cadastrar planos para monetizar funcionalidades.

**Critérios de aceite**
- nome obrigatório
- preço e ciclo obrigatórios
- plano deve ter status

### US-B2
Como organização, quero ter assinatura ativa para acessar recursos premium.

**Critérios de aceite**
- subscription pertence à organization
- subscription referencia um plano
- status: trialing, active, past_due, cancelled, expired

### US-B3
Como operação comercial, quero registrar leads.

**Critérios de aceite**
- lead deve registrar origem
- lead deve suportar qualificação
- deve haver status comercial

---

# Módulo C — Network / Operator Supply

## Objetivo
Onboarding, verificação e gestão de operadores.

## User stories

### US-C1
Como operador, quero completar meu onboarding para receber jobs.

**Critérios de aceite**
- onboarding com etapas
- progresso salvo parcialmente
- validações por etapa

### US-C2
Como admin, quero verificar documentos do operador.

**Critérios de aceite**
- documento com status `pending`, `valid`, `expired`, `rejected`
- documentos vencidos devem ser sinalizados
- operador pode ser bloqueado por compliance

### US-C3
Como plataforma, quero saber quais equipamentos e sensores o operador possui.

**Critérios de aceite**
- operador pode ter múltiplos equipamentos
- equipamento pode ter sensor associado
- capability deve ser derivável ou cadastrável

---

# Módulo D — Orders / Bids / Missions

## Objetivo
Transformar demanda em execução controlada.

## User stories

### US-D1
Como cliente, quero criar um pedido com escopo técnico.

**Critérios de aceite**
- título obrigatório
- tipo de serviço obrigatório
- organização obrigatória
- status inicial `draft`
- deve aceitar múltiplos sites

### US-D2
Como operador, quero enviar proposta para um pedido compatível.

**Critérios de aceite**
- proposta deve ter preço > 0
- prazo obrigatório
- operador obrigatório
- pedido deve estar apto a receber proposta

### US-D3
Como cliente/admin, quero aceitar uma proposta e gerar missão.

**Critérios de aceite**
- uma proposta aceita por pedido
- missão herda order, bid, operator
- missão recebe código único

### US-D4
Como cliente, quero acompanhar a missão.

**Critérios de aceite**
- missão deve ter timeline/status
- deve registrar início/fim programado e real
- deve permitir estados operacionais

---

# Módulo E — Data Delivery / QA

## Objetivo
Receber, validar e entregar datasets.

## User stories

### US-E1
Como operador, quero subir arquivos da missão.

**Critérios de aceite**
- dataset pertence a missão
- dataset aceita múltiplos arquivos
- deve suportar versionamento

### US-E2
Como QA/admin, quero revisar a qualidade do dataset.

**Critérios de aceite**
- review associada à missão
- checklist detalhado
- resultado: approved, rejected, revision_requested

### US-E3
Como cliente, quero acessar os arquivos aprovados.

**Critérios de aceite**
- apenas datasets com status entregável devem aparecer
- arquivos devem conter metadados mínimos
- deve ser possível baixar ou consumir via integração futura

---

# Módulo F — Finance

## Objetivo
Cobrança do cliente e repasse ao operador.

## User stories

### US-F1
Como financeiro, quero emitir fatura.

**Critérios de aceite**
- invoice com número único
- totais consistentes
- status da fatura auditável

### US-F2
Como plataforma, quero registrar pagamento.

**Critérios de aceite**
- payment pertence a invoice
- provider e status obrigatórios
- permitir manual ou gateway

### US-F3
Como operador, quero receber repasse pela missão concluída.

**Critérios de aceite**
- payout vinculado à mission + operator
- cálculo com gross, fee, net
- status controlado

---

# Módulo G — Communication / Support

## Objetivo
Centralizar conversas e tickets.

## User stories

### US-G1
Como cliente e operador, quero conversar dentro do pedido ou missão.

**Critérios de aceite**
- conversation associada a order ou mission
- message pertence à conversation e user
- mensagens devem ter histórico

### US-G2
Como usuário, quero abrir ticket de suporte.

**Critérios de aceite**
- ticket com categoria, prioridade e status
- pode estar ligado a order ou mission
- pode ser atribuído a um agente interno

---

# Módulo H — Core Platform

## Objetivo
Garantir observabilidade, auditoria e integração.

## User stories

### US-H1
Como admin, quero trilha de auditoria para ações críticas.

**Critérios de aceite**
- audit log com actor, action, auditable
- changeset e request_id quando possível
- histórico imutável

### US-H2
Como cliente enterprise, quero receber webhooks.

**Critérios de aceite**
- endpoint com secret
- eventos assináveis
- delivery com status e tentativas

---

## 9. Regras de negócio globais

1. Um `order` pode ter várias `bids`.
2. Apenas uma `bid` pode ser aceita por `order`.
3. Uma `mission` só nasce a partir de uma `bid` aceita.
4. Um `dataset` só pode existir vinculado a uma `mission`.
5. Operador com compliance inválido não pode receber missão nova.
6. `invoice.total_cents = subtotal_cents + tax_cents - discount_cents`.
7. `payout.net_amount_cents = gross_amount_cents - platform_fee_cents`.
8. API key deve ser armazenada apenas como digest.
9. Arquivos devem ter checksum sempre que possível.
10. Toda mudança crítica deve gerar audit log.

---

## 10. Modelo conceitual do domínio

```mermaid
erDiagram
    USERS ||--o{ MEMBERSHIPS : has
    ORGANIZATIONS ||--o{ MEMBERSHIPS : has
    USERS ||--o| OPERATOR_PROFILES : may_have
    ORGANIZATIONS ||--o{ OPERATOR_PROFILES : employs
    ORGANIZATIONS ||--o{ ORDERS : creates
    USERS ||--o{ ORDERS : requests

    OPERATOR_PROFILES ||--o{ OPERATOR_EQUIPMENTS : has
    EQUIPMENTS ||--o{ OPERATOR_EQUIPMENTS : assigned
    SENSOR_TYPES ||--o{ EQUIPMENTS : classifies

    ORDERS ||--o{ ORDER_SITES : includes
    SITES ||--o{ ORDER_SITES : linked

    ORDERS ||--o{ BIDS : receives
    OPERATOR_PROFILES ||--o{ BIDS : submits

    BIDS ||--o| MISSIONS : wins
    ORDERS ||--o| MISSIONS : becomes
    OPERATOR_PROFILES ||--o{ MISSIONS : executes

    MISSIONS ||--o{ DATASETS : produces
    DATASETS ||--o{ DATASET_FILES : contains

    MISSIONS ||--o{ QA_REVIEWS : reviewed
    QA_REVIEWS ||--o{ QA_REVIEW_ITEMS : items

    ORDERS ||--o{ INVOICES : bills
    INVOICES ||--o{ PAYMENTS : receives
    MISSIONS ||--o{ PAYOUTS : generates

    OPERATOR_PROFILES ||--o{ COMPLIANCE_DOCUMENTS : owns

    ORDERS ||--o{ CONVERSATIONS : has
    MISSIONS ||--o{ CONVERSATIONS : has
    CONVERSATIONS ||--o{ MESSAGES : stores
    USERS ||--o{ MESSAGES : sends

    ORGANIZATIONS ||--o{ WEBHOOKS : configures
    USERS ||--o{ AUDIT_LOGS : performs