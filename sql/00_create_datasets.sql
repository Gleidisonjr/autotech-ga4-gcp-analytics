-- =============================================================================
-- 00_create_datasets.sql
-- Criação dos datasets no BigQuery para camadas raw, trusted e analytics.
-- Executar no console BigQuery ou via CLI: bq mk ...
-- =============================================================================

-- ABORDAGEM RECOMENDADA: três datasets separados
-- Vantagens: isolamento de custos, permissões por camada, clareza de governança.
-- Substitua PROJECT_ID e LOCATION pelos seus valores (ex.: us, southamerica-east1).

-- Dataset RAW: dados brutos (ingestão sem transformação)
-- bq mk --location=LOCATION PROJECT_ID:raw

-- Dataset TRUSTED: dados limpos e modelados para negócio
-- bq mk --location=LOCATION PROJECT_ID:trusted

-- Dataset ANALYTICS: agregações e métricas para relatórios
-- bq mk --location=LOCATION PROJECT_ID:analytics

-- -----------------------------------------------------------------------------
-- ALTERNATIVA: um único dataset com prefixos de tabela
-- Use se preferir menos datasets (ex.: autotech_b2b com tabelas raw_*, trusted_*, analytics_*).
-- bq mk --location=LOCATION PROJECT_ID:autotech_b2b
-- Nesse caso, em 01 e nos demais scripts use o mesmo dataset e os nomes de tabela
-- raw_ga4_events, raw_crm_leads, raw_contracts, etc. já contemplam o prefixo.
-- -----------------------------------------------------------------------------

-- Exemplo concreto (descomente e ajuste):
-- bq mk --location=southamerica-east1 meu-projeto-gcp:raw
-- bq mk --location=southamerica-east1 meu-projeto-gcp:trusted
-- bq mk --location=southamerica-east1 meu-projeto-gcp:analytics
