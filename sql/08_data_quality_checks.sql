-- =============================================================================
-- 08_data_quality_checks.sql
-- Validações: duplicidade, nulos, integridade lead_id, ranges de receita, consistência temporal.
-- Resultado esperado: 0 falhas em cada check (ou investigar quando > 0).
-- Substitua autotechb2b.raw e autotechb2b.trusted pelos seus IDs.
-- =============================================================================

-- Check 1: Duplicidade de chaves em raw_ga4_events (event_timestamp + session_id + event_name não deve repetir em excesso)
SELECT 'duplicate_ga4_events' AS check_name, COUNT(*) AS failures
FROM (
  SELECT event_timestamp, session_id, event_name, user_id
  FROM `autotechb2b.raw.raw_ga4_events`
  GROUP BY 1, 2, 3, 4
  HAVING COUNT(*) > 1
);

-- Check 2: Duplicidade lead_id em raw_crm_leads
SELECT 'duplicate_lead_id' AS check_name, COUNT(*) AS failures
FROM (
  SELECT lead_id FROM `autotechb2b.raw.raw_crm_leads` GROUP BY lead_id HAVING COUNT(*) > 1
);

-- Check 3: Duplicidade contract_id em raw_contracts
SELECT 'duplicate_contract_id' AS check_name, COUNT(*) AS failures
FROM (
  SELECT contract_id FROM `autotechb2b.raw.raw_contracts` GROUP BY contract_id HAVING COUNT(*) > 1
);

-- Check 4: Nulos em campos críticos - leads (lead_id, user_id, lead_created_at)
SELECT 'null_critical_leads' AS check_name, COUNT(*) AS failures
FROM `autotechb2b.raw.raw_crm_leads`
WHERE lead_id IS NULL OR user_id IS NULL OR lead_created_at IS NULL;

-- Check 5: Nulos em contratos (contract_id, lead_id, contract_created_at)
SELECT 'null_critical_contracts' AS check_name, COUNT(*) AS failures
FROM `autotechb2b.raw.raw_contracts`
WHERE contract_id IS NULL OR lead_id IS NULL OR contract_created_at IS NULL;

-- Check 6: Integridade lead_id — contratos referenciam lead existente
SELECT 'contract_lead_integrity' AS check_name, COUNT(*) AS failures
FROM `autotechb2b.raw.raw_contracts` c
LEFT JOIN `autotechb2b.raw.raw_crm_leads` l ON l.lead_id = c.lead_id
WHERE l.lead_id IS NULL;

-- Check 7: Receita mensal e termo em faixa válida (revenue > 0, term_months >= 1)
SELECT 'invalid_revenue_range' AS check_name, COUNT(*) AS failures
FROM `autotechb2b.raw.raw_contracts`
WHERE monthly_revenue <= 0 OR contract_term_months < 1;

-- Check 8: Consistência temporal — contract_created_at >= lead_created_at para o mesmo lead
SELECT 'temporal_consistency' AS check_name, COUNT(*) AS failures
FROM `autotechb2b.raw.raw_contracts` c
JOIN `autotechb2b.raw.raw_crm_leads` l ON l.lead_id = c.lead_id
WHERE c.contract_created_at < l.lead_created_at;

-- Resumo único (executar todos e revisar)
SELECT check_name, failures FROM (
  SELECT 'duplicate_ga4_events' AS check_name, (SELECT COUNT(*) FROM (SELECT 1 FROM `autotechb2b.raw.raw_ga4_events` GROUP BY event_timestamp, session_id, event_name, user_id HAVING COUNT(*) > 1)) AS failures
  UNION ALL SELECT 'duplicate_lead_id', (SELECT COUNT(*) FROM (SELECT lead_id FROM `autotechb2b.raw.raw_crm_leads` GROUP BY lead_id HAVING COUNT(*) > 1))
  UNION ALL SELECT 'duplicate_contract_id', (SELECT COUNT(*) FROM (SELECT contract_id FROM `autotechb2b.raw.raw_contracts` GROUP BY contract_id HAVING COUNT(*) > 1))
  UNION ALL SELECT 'null_critical_leads', (SELECT COUNT(*) FROM `autotechb2b.raw.raw_crm_leads` WHERE lead_id IS NULL OR user_id IS NULL OR lead_created_at IS NULL)
  UNION ALL SELECT 'null_critical_contracts', (SELECT COUNT(*) FROM `autotechb2b.raw.raw_contracts` WHERE contract_id IS NULL OR lead_id IS NULL OR contract_created_at IS NULL)
  UNION ALL SELECT 'contract_lead_integrity', (SELECT COUNT(*) FROM `autotechb2b.raw.raw_contracts` c LEFT JOIN `autotechb2b.raw.raw_crm_leads` l ON l.lead_id = c.lead_id WHERE l.lead_id IS NULL)
  UNION ALL SELECT 'invalid_revenue_range', (SELECT COUNT(*) FROM `autotechb2b.raw.raw_contracts` WHERE monthly_revenue <= 0 OR contract_term_months < 1)
  UNION ALL SELECT 'temporal_consistency', (SELECT COUNT(*) FROM `autotechb2b.raw.raw_contracts` c JOIN `autotechb2b.raw.raw_crm_leads` l ON l.lead_id = c.lead_id WHERE c.contract_created_at < l.lead_created_at)
)
ORDER BY check_name;
