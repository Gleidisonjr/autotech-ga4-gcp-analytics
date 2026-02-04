-- =============================================================================
-- 07_time_to_convert.sql
-- Tempo até conversão: first_seen → lead_created_at e lead_created_at → contract_created_at.
-- Mediana, P75 e P90 por canal (source/medium) e por segmento.
-- Substitua autotechb2b.trusted e autotechb2b.analytics pelos seus IDs.
-- =============================================================================

-- Base: analytics_conversion_time já tem hours_to_lead e hours_lead_to_contract.
-- Precisamos enriquecer com canal (da sessão de conversão ou primeira sessão).

WITH conv_with_channel AS (
  SELECT
    ct.user_id,
    ct.lead_id,
    ct.segment,
    ct.hours_to_lead,
    ct.hours_lead_to_contract,
    s.traffic_source,
    s.traffic_medium
  FROM `autotechb2b.analytics.analytics_conversion_time` ct
  LEFT JOIN `autotechb2b.trusted.trusted_sessions` s
    ON s.user_id = ct.user_id
   AND s.session_date = ct.lead_date
  QUALIFY ROW_NUMBER() OVER (PARTITION BY ct.lead_id ORDER BY s.session_start DESC) = 1
),
channel_ AS (
  SELECT
    COALESCE(traffic_source, '(direct)') AS channel_source,
    COALESCE(traffic_medium, 'none') AS channel_medium,
    hours_to_lead,
    hours_lead_to_contract
  FROM conv_with_channel
  WHERE hours_to_lead IS NOT NULL
),
segment_ AS (
  SELECT
    COALESCE(segment, '(not set)') AS segment,
    hours_to_lead,
    hours_lead_to_contract
  FROM conv_with_channel
  WHERE hours_to_lead IS NOT NULL
)
-- Mediana, P75, P90 por canal (time to lead)
SELECT
  'by_channel' AS breakdown,
  channel_source AS dimension_1,
  channel_medium AS dimension_2,
  APPROX_QUANTILES(hours_to_lead, 100)[OFFSET(50)] AS median_hours_to_lead,
  APPROX_QUANTILES(hours_to_lead, 100)[OFFSET(75)] AS p75_hours_to_lead,
  APPROX_QUANTILES(hours_to_lead, 100)[OFFSET(90)] AS p90_hours_to_lead,
  APPROX_QUANTILES(hours_lead_to_contract, 100)[OFFSET(50)] AS median_hours_lead_to_contract,
  APPROX_QUANTILES(hours_lead_to_contract, 100)[OFFSET(75)] AS p75_hours_lead_to_contract,
  APPROX_QUANTILES(hours_lead_to_contract, 100)[OFFSET(90)] AS p90_hours_lead_to_contract
FROM channel_
GROUP BY 1, 2, 3
UNION ALL
-- Mediana, P75, P90 por segmento
SELECT
  'by_segment' AS breakdown,
  segment AS dimension_1,
  CAST(NULL AS STRING) AS dimension_2,
  APPROX_QUANTILES(hours_to_lead, 100)[OFFSET(50)] AS median_hours_to_lead,
  APPROX_QUANTILES(hours_to_lead, 100)[OFFSET(75)] AS p75_hours_to_lead,
  APPROX_QUANTILES(hours_to_lead, 100)[OFFSET(90)] AS p90_hours_to_lead,
  APPROX_QUANTILES(hours_lead_to_contract, 100)[OFFSET(50)] AS median_hours_lead_to_contract,
  APPROX_QUANTILES(hours_lead_to_contract, 100)[OFFSET(75)] AS p75_hours_lead_to_contract,
  APPROX_QUANTILES(hours_lead_to_contract, 100)[OFFSET(90)] AS p90_hours_lead_to_contract
FROM segment_
GROUP BY 1, 2, 3
ORDER BY breakdown, dimension_1, dimension_2;
