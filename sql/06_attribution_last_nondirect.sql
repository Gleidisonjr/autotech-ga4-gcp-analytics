-- =============================================================================
-- 06_attribution_last_nondirect.sql
-- Atribuição simplificada: last non-direct click.
-- Para cada user_id (e conversão), atribui o canal da última sessão que NÃO foi
-- (direct) / none. É uma aproximação: em produção usaríamos session_id de
-- conversão e percorrer sessões anteriores; aqui usamos última sessão não direta
-- por user_id como proxy.
-- Substitua autotechb2b.trusted pelo seu ID.
-- =============================================================================

-- Última sessão não direta por user_id (source/medium não (direct)/none)
WITH session_channel AS (
  SELECT
    user_id,
    session_id,
    session_date,
    traffic_source,
    traffic_medium,
    traffic_campaign,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY session_date DESC, session_id
    ) AS rn
  FROM `autotechb2b.trusted.trusted_sessions`
  WHERE NOT (LOWER(COALESCE(traffic_source, '')) = '(direct)' AND LOWER(COALESCE(traffic_medium, '')) IN ('none', '(none)', ''))
     OR (traffic_source IS NULL AND traffic_medium IS NULL)
),
last_nondirect AS (
  SELECT user_id, session_id, session_date, traffic_source, traffic_medium, traffic_campaign
  FROM session_channel
  WHERE rn = 1
),
-- Usuários que converteram (lead)
converters AS (
  SELECT DISTINCT user_id FROM `autotechb2b.trusted.trusted_leads`
)
SELECT
  COALESCE(lnd.traffic_source, '(direct)') AS attributed_source,
  COALESCE(lnd.traffic_medium, 'none') AS attributed_medium,
  COALESCE(lnd.traffic_campaign, '(not set)') AS attributed_campaign,
  COUNT(DISTINCT c.user_id) AS attributed_conversions
FROM converters c
LEFT JOIN last_nondirect lnd ON lnd.user_id = c.user_id
GROUP BY 1, 2, 3
ORDER BY attributed_conversions DESC;
