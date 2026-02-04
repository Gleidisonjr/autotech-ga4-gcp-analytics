-- =============================================================================
-- 03_analytics_models.sql
-- Tabelas/views da camada ANALYTICS para dashboards e relatórios.
-- Depende de: 02_trusted_views.sql
-- Substitua autotechb2b.trusted e autotechb2b.analytics pelos seus IDs.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- analytics_funnel_daily: funil diário por etapa (sessões → lead → demo → contrato)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `autotechb2b.analytics.analytics_funnel_daily` AS
WITH daily_sessions AS (
  SELECT session_date AS funnel_date, COUNT(DISTINCT session_id) AS sessions
  FROM `autotechb2b.trusted.trusted_sessions`
  GROUP BY 1
),
daily_form_start AS (
  SELECT session_date AS funnel_date, COUNT(DISTINCT session_id) AS form_starts
  FROM `autotechb2b.trusted.trusted_sessions`
  WHERE form_starts > 0
  GROUP BY 1
),
daily_form_submit AS (
  SELECT session_date AS funnel_date, COUNT(DISTINCT session_id) AS form_submits
  FROM `autotechb2b.trusted.trusted_sessions`
  WHERE form_submits > 0
  GROUP BY 1
),
daily_leads AS (
  SELECT lead_date AS funnel_date, COUNT(*) AS leads
  FROM `autotechb2b.trusted.trusted_leads`
  GROUP BY 1
),
daily_demos AS (
  SELECT session_date AS funnel_date, COUNT(DISTINCT session_id) AS demos
  FROM `autotechb2b.trusted.trusted_sessions`
  WHERE demo_events > 0
  GROUP BY 1
),
daily_contracts AS (
  SELECT contract_date AS funnel_date, COUNT(*) AS contracts
  FROM `autotechb2b.trusted.trusted_contracts`
  GROUP BY 1
),
calendar AS (
  SELECT funnel_date FROM UNNEST(
    (SELECT ARRAY_AGG(d ORDER BY d) FROM (
      SELECT session_date AS d FROM `autotechb2b.trusted.trusted_sessions`
    ))
  ) AS funnel_date
)
SELECT
  c.funnel_date,
  COALESCE(s.sessions, 0) AS sessions,
  COALESCE(fs.form_starts, 0) AS form_starts,
  COALESCE(fsb.form_submits, 0) AS form_submits,
  COALESCE(l.leads, 0) AS leads,
  COALESCE(d.demos, 0) AS demos,
  COALESCE(ct.contracts, 0) AS contracts
FROM (SELECT DISTINCT session_date AS funnel_date FROM `autotechb2b.trusted.trusted_sessions`) c
LEFT JOIN daily_sessions s ON s.funnel_date = c.funnel_date
LEFT JOIN daily_form_start fs ON fs.funnel_date = c.funnel_date
LEFT JOIN daily_form_submit fsb ON fsb.funnel_date = c.funnel_date
LEFT JOIN daily_leads l ON l.funnel_date = c.funnel_date
LEFT JOIN daily_demos d ON d.funnel_date = c.funnel_date
LEFT JOIN daily_contracts ct ON ct.funnel_date = c.funnel_date
ORDER BY c.funnel_date;

-- -----------------------------------------------------------------------------
-- analytics_channel_kpis: KPIs por source/medium/campaign
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `autotechb2b.analytics.analytics_channel_kpis` AS
WITH sess AS (
  SELECT
    session_id,
    user_id,
    session_date,
    traffic_source,
    traffic_medium,
    traffic_campaign,
    device_category,
    lead_events,
    demo_events
  FROM `autotechb2b.trusted.trusted_sessions`
),
leads_agg AS (
  SELECT user_id, lead_date, lead_id
  FROM `autotechb2b.trusted.trusted_leads`
),
contracts_agg AS (
  SELECT lead_id, monthly_revenue, monthly_revenue * contract_term_months AS total_value
  FROM `autotechb2b.trusted.trusted_contracts`
),
enriched AS (
  SELECT
    s.session_id,
    s.traffic_source,
    s.traffic_medium,
    s.traffic_campaign,
    s.device_category,
    s.lead_events,
    s.demo_events,
    l.lead_id,
    c.monthly_revenue,
    c.total_value
  FROM sess s
  LEFT JOIN leads_agg l ON l.user_id = s.user_id AND l.lead_date = s.session_date
  LEFT JOIN contracts_agg c ON c.lead_id = l.lead_id
)
SELECT
  COALESCE(traffic_source, '(not set)') AS traffic_source,
  COALESCE(traffic_medium, '(not set)') AS traffic_medium,
  COALESCE(traffic_campaign, '(not set)') AS traffic_campaign,
  device_category,
  COUNT(DISTINCT session_id) AS sessions,
  COUNT(DISTINCT CASE WHEN lead_id IS NOT NULL THEN session_id END) AS leads,
  COUNT(DISTINCT CASE WHEN demo_events > 0 THEN session_id END) AS demos,
  COUNT(DISTINCT CASE WHEN total_value IS NOT NULL THEN session_id END) AS contracts,
  SAFE_DIVIDE(COUNT(DISTINCT CASE WHEN lead_id IS NOT NULL THEN session_id END), COUNT(DISTINCT session_id)) AS conversion_rate,
  SUM(COALESCE(monthly_revenue, 0)) AS monthly_revenue,
  SUM(COALESCE(total_value, 0)) AS total_revenue
FROM enriched
GROUP BY 1, 2, 3, 4;

-- -----------------------------------------------------------------------------
-- analytics_conversion_time: tempo até lead e até contrato (base para mediana/P75/P90)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `autotechb2b.analytics.analytics_conversion_time` AS
WITH first_touch AS (
  SELECT user_id, MIN(session_start) AS first_seen
  FROM `autotechb2b.trusted.trusted_sessions`
  GROUP BY user_id
),
lead_time AS (
  SELECT
    l.user_id,
    l.lead_id,
    l.lead_date,
    l.segment,
    ft.first_seen,
    l.lead_created_at,
    TIMESTAMP_DIFF(l.lead_created_at, ft.first_seen, HOUR) AS hours_to_lead
  FROM `autotechb2b.trusted.trusted_leads` l
  JOIN first_touch ft ON ft.user_id = l.user_id
),
contract_time AS (
  SELECT
    lt.*,
    c.contract_created_at,
    TIMESTAMP_DIFF(c.contract_created_at, lt.lead_created_at, HOUR) AS hours_lead_to_contract
  FROM lead_time lt
  LEFT JOIN `autotechb2b.trusted.trusted_contracts` c ON c.lead_id = lt.lead_id
)
SELECT
  user_id,
  lead_id,
  lead_date,
  segment,
  first_seen,
  lead_created_at,
  contract_created_at,
  hours_to_lead,
  hours_lead_to_contract
FROM contract_time;

-- -----------------------------------------------------------------------------
-- analytics_revenue_kpis: receita agregada e KPIs simulados (CAC, LTV, ROI)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `autotechb2b.analytics.analytics_revenue_kpis` AS
SELECT
  SUM(monthly_revenue) AS mrr_total,
  SUM(total_contract_value) AS total_revenue,
  COUNT(*) AS total_contracts,
  COUNT(DISTINCT lead_id) AS unique_leads_with_contract,
  AVG(monthly_revenue) AS avg_mrr_per_contract,
  AVG(contract_term_months) AS avg_term_months
FROM `autotechb2b.trusted.trusted_contracts`;
