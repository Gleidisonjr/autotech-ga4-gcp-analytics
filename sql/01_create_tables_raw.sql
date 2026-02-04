-- =============================================================================
-- 01_create_tables_raw.sql
-- Criação das tabelas na camada RAW (espelho dos CSVs).
-- Executar após criar o dataset raw (00_create_datasets.sql).
-- Particionamento por data onde fizer sentido para custo e performance.
-- =============================================================================

-- Ajuste o dataset conforme sua escolha (dataset único ou raw)
-- Ex.: `autotechb2b.raw` ou `autotechb2b.autotech_b2b`

-- -----------------------------------------------------------------------------
-- raw_ga4_events: eventos simulados do GA4
-- Particionada por event_date para consultas por período.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `autotechb2b.raw.raw_ga4_events` (
  event_date          DATE,
  event_timestamp     INT64,       -- epoch em milissegundos
  user_id             STRING,
  session_id          STRING,
  event_name          STRING,
  page_location       STRING,
  device_category     STRING,
  geo_country         STRING,
  traffic_source      STRING,
  traffic_medium      STRING,
  traffic_campaign    STRING,
  engagement_time_msec INT64,
  value               FLOAT64
)
PARTITION BY event_date
OPTIONS(
  description = 'Eventos GA4 mock - camada raw',
  require_partition_filter = false
);

-- -----------------------------------------------------------------------------
-- raw_crm_leads: leads do CRM
-- Sem particionamento (tabela pequena); lead_created_at para filtros.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `autotechb2b.raw.raw_crm_leads` (
  lead_id         STRING,
  user_id         STRING,
  lead_created_at TIMESTAMP,
  lead_source     STRING,
  company_size    STRING,
  segment         STRING,
  status          STRING
)
OPTIONS(description = 'Leads CRM - camada raw');

-- -----------------------------------------------------------------------------
-- raw_contracts: contratos fechados
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `autotechb2b.raw.raw_contracts` (
  contract_id          STRING,
  lead_id              STRING,
  contract_created_at  TIMESTAMP,
  plan_type            STRING,
  monthly_revenue      FLOAT64,
  contract_term_months INT64
)
OPTIONS(description = 'Contratos - camada raw');
