-- =============================================================================
-- 02_trusted_views.sql
-- Views na camada TRUSTED: agregação por sessão/usuário e normalização.
-- Depende de: 01_create_tables_raw.sql (e dados carregados).
-- Substitua autotechb2b.raw e autotechb2b.trusted pelos seus IDs.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- trusted_sessions: uma linha por session_id com métricas agregadas
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `autotechb2b.trusted.trusted_sessions` AS
SELECT
  session_id,
  ANY_VALUE(user_id) AS user_id,
  MIN(event_date) AS session_date,
  MIN(TIMESTAMP_MILLIS(event_timestamp)) AS session_start,
  MAX(TIMESTAMP_MILLIS(event_timestamp)) AS session_end,
  COUNT(*) AS event_count,
  COUNTIF(event_name = 'page_view') AS page_views,
  COUNTIF(event_name = 'form_start') AS form_starts,
  COUNTIF(event_name = 'form_submit') AS form_submits,
  COUNTIF(event_name = 'lead_generated') AS lead_events,
  COUNTIF(event_name = 'demo_requested') AS demo_events,
  ANY_VALUE(device_category) AS device_category,
  ANY_VALUE(geo_country) AS geo_country,
  ANY_VALUE(traffic_source) AS traffic_source,
  ANY_VALUE(traffic_medium) AS traffic_medium,
  ANY_VALUE(traffic_campaign) AS traffic_campaign,
  SUM(COALESCE(engagement_time_msec, 0)) AS total_engagement_msec
FROM `autotechb2b.raw.raw_ga4_events`
GROUP BY session_id;

-- -----------------------------------------------------------------------------
-- trusted_users: comportamento agregado por user_id
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `autotechb2b.trusted.trusted_users` AS
SELECT
  user_id,
  MIN(event_date) AS first_seen_date,
  MAX(event_date) AS last_seen_date,
  COUNT(DISTINCT session_id) AS total_sessions,
  COUNT(*) AS total_events,
  COUNTIF(event_name = 'page_view') AS total_page_views,
  COUNTIF(event_name = 'lead_generated') AS lead_count,
  COUNTIF(event_name = 'demo_requested') AS demo_count,
  ANY_VALUE(device_category) AS last_device_category,
  ANY_VALUE(traffic_source) AS last_traffic_source,
  ANY_VALUE(traffic_medium) AS last_traffic_medium,
  ANY_VALUE(traffic_campaign) AS last_traffic_campaign
FROM `autotechb2b.raw.raw_ga4_events`
GROUP BY user_id;

-- -----------------------------------------------------------------------------
-- trusted_leads: leads com tipos normalizados e datas em DATE
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `autotechb2b.trusted.trusted_leads` AS
SELECT
  lead_id,
  user_id,
  DATE(lead_created_at) AS lead_date,
  lead_created_at AS lead_created_at,
  LOWER(TRIM(lead_source)) AS lead_source,
  LOWER(TRIM(company_size)) AS company_size,
  LOWER(TRIM(segment)) AS segment,
  LOWER(TRIM(status)) AS status
FROM `autotechb2b.raw.raw_crm_leads`;

-- -----------------------------------------------------------------------------
-- trusted_contracts: contratos com receita total (MRR * termo) e datas
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `autotechb2b.trusted.trusted_contracts` AS
SELECT
  contract_id,
  lead_id,
  DATE(contract_created_at) AS contract_date,
  contract_created_at AS contract_created_at,
  LOWER(TRIM(plan_type)) AS plan_type,
  monthly_revenue,
  contract_term_months,
  monthly_revenue * contract_term_months AS total_contract_value
FROM `autotechb2b.raw.raw_contracts`;
