-- =============================================================================
-- 04_funnel_analysis.sql
-- Funil completo: sessões → form_start → form_submit → lead → demo → contract
-- Taxas por etapa e quebra por device_category e campaign.
-- Substitua autotechb2b.trusted e autotechb2b.analytics pelos seus IDs.
-- =============================================================================

-- Funil agregado global (todas as datas)
WITH funnel_agg AS (
  SELECT
    COUNT(DISTINCT session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN form_starts > 0 THEN session_id END) AS form_starts,
    COUNT(DISTINCT CASE WHEN form_submits > 0 THEN session_id END) AS form_submits,
    COUNT(DISTINCT CASE WHEN lead_events > 0 THEN session_id END) AS leads,
    COUNT(DISTINCT CASE WHEN demo_events > 0 THEN session_id END) AS demos
  FROM `autotechb2b.trusted.trusted_sessions`
),
contracts_agg AS (
  SELECT COUNT(*) AS contracts
  FROM `autotechb2b.trusted.trusted_contracts`
)
SELECT
  f.sessions,
  f.form_starts,
  f.form_submits,
  f.leads,
  f.demos,
  c.contracts,
  SAFE_DIVIDE(f.form_starts, f.sessions) AS rate_form_start,
  SAFE_DIVIDE(f.form_submits, f.form_starts) AS rate_form_submit,
  SAFE_DIVIDE(f.leads, f.form_submits) AS rate_lead,
  SAFE_DIVIDE(f.demos, f.leads) AS rate_demo,
  SAFE_DIVIDE(c.contracts, f.demos) AS rate_demo_to_contract
FROM funnel_agg f
CROSS JOIN contracts_agg c;

-- Funil por device_category
SELECT
  device_category,
  COUNT(DISTINCT session_id) AS sessions,
  COUNT(DISTINCT CASE WHEN form_starts > 0 THEN session_id END) AS form_starts,
  COUNT(DISTINCT CASE WHEN form_submits > 0 THEN session_id END) AS form_submits,
  COUNT(DISTINCT CASE WHEN lead_events > 0 THEN session_id END) AS leads,
  COUNT(DISTINCT CASE WHEN demo_events > 0 THEN session_id END) AS demos,
  SAFE_DIVIDE(COUNT(DISTINCT CASE WHEN lead_events > 0 THEN session_id END), COUNT(DISTINCT session_id)) AS conversion_rate
FROM `autotechb2b.trusted.trusted_sessions`
GROUP BY device_category;

-- Funil por traffic_campaign
SELECT
  COALESCE(traffic_campaign, '(not set)') AS campaign,
  COUNT(DISTINCT session_id) AS sessions,
  COUNT(DISTINCT CASE WHEN form_starts > 0 THEN session_id END) AS form_starts,
  COUNT(DISTINCT CASE WHEN lead_events > 0 THEN session_id END) AS leads,
  COUNT(DISTINCT CASE WHEN demo_events > 0 THEN session_id END) AS demos
FROM `autotechb2b.trusted.trusted_sessions`
GROUP BY traffic_campaign;
