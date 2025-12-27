# 📥 Pipeline de Ingestão SFMC Email — Airflow

## 🎯 Objetivo

Este módulo implementa a **etapa de ingestão de dados de Email do Salesforce Marketing Cloud (SFMC)** utilizando **Apache Airflow**, seguindo boas práticas de Engenharia de Dados e princípios de design modular.

O objetivo principal é **extrair, validar e carregar** os logs de interação de Email de forma segura e governada, garantindo que **dados inválidos não entrem no Data Lake**.

---

## 🧠 Visão Geral da Arquitetura

```
Salesforce Marketing Cloud (API)
            │
            ▼
┌──────────────────────┐
│ Airflow DAG          │
│ sfmc_email_ingestion │
└─────────┬────────────┘
          │
          ▼
┌──────────────────────────────┐
│ Extract (Python)             │
│ - Consome API SFMC           │
│ - Gera CSV temporário        │
└─────────┬────────────────────┘
          │
          ▼
┌──────────────────────────────┐
│ Quality Gate (Python)        │
│ - Valida JSON message_details│
│ - Bloqueia linhas inválidas  │
│ - Loga erros                 │
└─────────┬────────────────────┘
          │
          ▼
┌──────────────────────────────┐
│ Load (Python)                │
│ - Envia CSV validado ao GCS  │
│ - Bucket RAW                 │
└──────────────────────────────┘
```

> 🔑 **Princípio-chave**: Dados inválidos **não entram** no Data Lake.

---

## 📁 Estrutura de Pastas

```
airflow/
│
├── dags/
│   └── sfmc_email_ingestion_dag.py
│
├── ingestion/
│   ├── extract/
│   │   └── sfmc_extractor.py
│   │
│   ├── validation/
│   │   └── json_quality_gate.py
│   │
│   ├── load/
│   │   └── gcs_loader.py
│   │
│   └── utils/
│       └── logger.py
│
└── README.md
```

### 🧱 Separação de Responsabilidades

| Camada     | Responsabilidade           |
| ---------- | -------------------------- |
| Extract    | Comunicação com SFMC / API |
| Validation | Regras de qualidade (JSON) |
| Load       | Persistência no Data Lake  |
| DAG        | Orquestração apenas        |

Essa separação facilita **testes, manutenção e escalabilidade**.

---

## 🔁 Airflow DAG

### Nome do DAG

`sfmc_email_raw_ingestion`

### Frequência

* Execução diária (`@daily`)
* Sem `catchup`

### Dependências

```
extract_sfmc_email_logs
        ↓
validate_message_details_json
        ↓
load_raw_to_gcs
```

### Responsabilidade do Airflow

* Orquestrar a execução
* Controlar retries
* Gerenciar falhas e alertas

> ⚠️ **Importante**: Airflow não contém regra de negócio nem transformação de dados.

---

## 🐍 Detalhamento dos Scripts Python

### 1️⃣ Extract — `sfmc_extractor.py`

**Responsabilidade:**

* Simular a extração de logs via API do Salesforce Marketing Cloud
* Persistir os dados brutos em CSV temporário

**Características:**

* Não realiza validação
* Não altera dados
* Atua como *source of truth* da ingestão

---

### 2️⃣ Quality Gate — `json_quality_gate.py`

**Responsabilidade:**

* Validar o campo `message_details`
* Garantir que o JSON esteja bem formado

**Regras de Qualidade:**

* JSON inválido → linha descartada
* Erro logado com `event_id`
* Pipeline continua apenas com dados válidos

**Benefícios:**

* Evita dados corrompidos no RAW
* Reduz complexidade nas camadas downstream

---

### 3️⃣ Load — `gcs_loader.py`

**Responsabilidade:**

* Enviar o CSV validado para o bucket RAW no Google Cloud Storage

**Padrões adotados:**

* Bucket exclusivo para RAW
* Nome de arquivo previsível
* Pronto para External Tables no BigQuery

Exemplo de destino:

```
gs://crm-raw-data/sfmc/raw_sfmc_email_logs.csv
```

---

## 📊 Observabilidade e Logs

* Logs centralizados via `logger.py`
* Cada erro de qualidade é explicitamente logado
* Compatível com logs nativos do Airflow

Exemplo:

```
ERROR - Invalid JSON detected | event_id=evt_002
```

---

## 🧪 Qualidade de Dados (Filosofia)

Este pipeline segue o conceito de **Shift Left Data Quality**:

* Qualidade aplicada **antes** do Data Lake
* Redução de retrabalho em SQL/dbt
* Maior confiabilidade analítica

---

## 🔐 Segurança e Produção (Considerações)

Em ambiente produtivo:

* Credenciais SFMC → Secret Manager
* Acesso GCS via Service Account
* Alertas Airflow (Slack / Email)

---

## 🔁 Reprocessamento (Backfill)

* DAG idempotente
* Arquivos sobrescritos por data de execução
* Compatível com backfill controlado via Airflow

---

## 🚀 Próximos Passos

* Integração com dbt (Bronze → Gold)
* Testes unitários com pytest
* Métricas de volume e SLA
* Monitoramento de anomalias

---

**Autor:** Marcos_Gois - Analytics / Data Engineering Team
