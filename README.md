# 📊 CRM Analytics Data Pipeline

## 🎯 Objetivo do Projeto

Este projeto implementa um **pipeline de dados end-to-end para atribuição de conversão de campanhas de CRM**, cobrindo Email (Salesforce Marketing Cloud) e WhatsApp.

O objetivo é resolver o *"buraco negro" do funil*, saneando dados crus, unificando a visão do cliente e aplicando uma **regra robusta de atribuição de conversão (Weighted Last Touch)** para consumo em dashboards executivos.

---

## 📌 Observação importante 📌

Todo o codigo SQL foi usando baseado na estrutura do DuckDb, o objetivo desse projeto é pensado na arquitetura da GCP e Bigquery, porém os codigo utilizados a sintaxe e a arquitetura podem facilmente ser implementadas na GCP e no Bigquery com poucas alterações no sql, mas a intenção é mostrar uma solução de projeto nos conceitos fundamentais de Engenharia de Dados e Analytics Engineering e na estrutura que consiga ser transferida para outros serviços/clouds.

Criação das Tabelas:
As tabelas não foram criadas particionadas, mas dentro do contexto de Bigquery elas seriam criadas particionadas por alguma coluna de data ou de negocio, e ate mesmo criada clusterização para melhor otimização na leitura e custos de querys.


## 🧠 Visão Geral da Arquitetura

A solução segue uma arquitetura em camadas, separando responsabilidades técnicas, regras de negócio e consumo analítico.

<img width="1702" height="818" alt="architecture" src="https://github.com/user-attachments/assets/bf674813-e403-4872-8d07-dfa49572d836" />


```
┌────────────────────────────┐
│ Fontes de Dados            │
│ - SFMC (Email)             │
│ - WhatsApp Provider        │
│ - CRM (Base Usuários)      │
└─────────────┬──────────────┘
              │
              ▼
┌────────────────────────────┐
│ RAW (Data Lake / BigQuery) │
│ - Dados brutos             │
│ - Sem tratamento           │
└─────────────┬──────────────┘
              │
              ▼
┌────────────────────────────┐
│ BRONZE (Staging)           │
│ - Padronização de chaves   │
│ - Timezone único           │
│ - Parsing de campos        │
└─────────────┬──────────────┘
              │
              ▼
┌────────────────────────────┐
│ SILVER (Intermediário)     │
│ - Interações unificadas    │
│ - Pesos de interação       │
└─────────────┬──────────────┘
              │
              ▼
┌────────────────────────────┐
│ GOLD (Analytics)           │
│ - Atribuição de conversão  │
│ - Fonte para dashboards    │
└────────────────────────────┘
```

O diagrama visual completo encontra-se em:

```
diagrams/architecture.png
```

---

## 📁 Estrutura do Repositório

```
src/
│
├── README.md
│
├── sql/
│   ├── bronze/
│   │   ├── stg_sfmc_email.sql
│   │   ├── stg_whatsapp.sql
│   │   └── stg_users.sql
│   │
│   ├── silver/
│   │   └── int_user_interactions.sql
│   │
│   └── gold/
│       └── fct_attribution.sql
│
├──airflow/
|   │
|   ├── dags/
|   │   └── sfmc_email_ingestion_dag.py
|   │
|   ├── ingestion/
|   │   ├── extract/
|   │   │   └── sfmc_extractor.py
|   │   │
|   │   ├── validation/
|   │   │   └── json_quality_gate.py
|   │   │
|   │   ├── load/
|   │   │   └── gcs_loader.py
|   │   │
|   │   └── utils/
|   │       └── logger.py
|   │
|   └── README.md
│
└── diagrams/
    └── architecture.png
```

---

## 🧱 Camadas de Dados

### 🔹 RAW

* Dados ingeridos exatamente como recebidos
* Sem transformação ou limpeza
* Fonte de auditoria

Exemplos:

* `raw_sfmc_email_logs`
* `raw_whatsapp_provider`
* `crm_user_base`

---

### 🔹 BRONZE — Staging

Responsável por **limpeza técnica** e padronização.

#### Principais transformações:

* Normalização de email e telefone
* Conversão de timezone para `America/Sao_Paulo`
* Parsing de JSON e strings

**Arquivos:**

* `stg_users.sql`
* `stg_sfmc_email.sql`
* `stg_whatsapp.sql`

---

### 🔹 SILVER — Intermediário

Responsável por **modelagem de negócio intermediária**.

#### Atividades:

* Unificação de interações de múltiplos canais
* Enriquecimento com `user_id`
* Definição de peso por tipo de interação

**Arquivo:**

* `user_interactions.sql`

---

### 🔹 GOLD — Analytics

Camada final orientada a consumo analítico.

#### Regras de Atribuição (Weighted Last Touch):

1. Janela de 7 dias antes da conversão
2. Prioridade por peso (não apenas horário):

| Peso | Canal / Interação |
| ---- | ----------------- |
| 1    | WhatsApp Read     |
| 2    | Email Click       |
| 3    | Email Open        |
| 4+   | Sent / Delivered  |

3. Em conflitos no mesmo dia, vence o menor peso

**Arquivo:**

* `fct_attribution.sql`

---

## 🧮 Principais Tabelas

### 🧑 stg_users

* Chave mestre de identidade
* Relaciona email ↔ telefone
* Contém data de conversão

---

### 📩 stg_sfmc_email

* Eventos de Email (open, click, sent)
* JSON validado
* Campaign code extraído

---

### 💬 stg_whatsapp

* Eventos de WhatsApp
* Campaign code limpo via regex
* Status mapeado para peso

---

### 📈 fct_attribution

Tabela fato final que responde:

> **“Qual campanha gerou esta conversão?”**

Campos principais:

* `user_id`
* `campaign_code`
* `channel`
* `interaction_type`
* `event_at`
* `conversion_at`

---

## 🐍 Pipeline Python (Ingestão)

A ingestão de Email SFMC é feita via Python + Airflow, antes do SQL.

### Etapas:

1. **Extract** — simula consumo da API
2. **Validation** — quality gate de JSON
3. **Load** — grava CSV no bucket RAW

Isso garante que **dados inválidos não cheguem ao Data Lake**.

---

## 🧪 Qualidade de Dados

* Validação de JSON na ingestão (Python)
* Normalização de chaves no staging
* Regras explícitas de peso e janela temporal

A qualidade é aplicada **desde a origem até a camada Gold**.

---

## 🔁 Reprocessamento (Backfill)

* Queries idempotentes
* `CREATE OR REPLACE` por camada
* Reprocessamento por período (ex: últimos 7 ou 30 dias)
* Camadas bem definidas Raw, Bronze, Silver e Gold

Estratégia segura para correção de regras de negócio.

---

## 🚀 Evoluções Naturais

* Migração para dbt
* Orquestração com Airflow
* Data Quality com dbt-expectations
* Exposures e métricas de marketing

---

**Autor:** Marcos Gois - Analytics / Data Engineering Team
