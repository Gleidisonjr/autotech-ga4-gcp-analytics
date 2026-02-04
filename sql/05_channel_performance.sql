-- =============================================================================
-- 05_channel_performance.sql
-- KPIs por source/medium/campaign: sessions, leads, demos, contracts, conversion_rate, revenue.
-- Utiliza a view analytics_channel_kpis ou replica a lógica para relatório dedicado.
-- Substitua autotechb2b.analytics pelo seu ID.
-- =============================================================================

SELECT
  traffic_source,
  traffic_medium,
  traffic_campaign,
  device_category,
  sessions,
  leads,
  demos,
  contracts,
  ROUND(conversion_rate, 4) AS conversion_rate,
  ROUND(monthly_revenue, 2) AS monthly_revenue,
  ROUND(total_revenue, 2) AS total_revenue
FROM `autotechb2b.analytics.analytics_channel_kpis`
ORDER BY sessions DESC, total_revenue DESC;
