# Dicionário de dados

Principais tabelas e colunas utilizadas no projeto.

## raw_ga4_events

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| event_date | DATE | Data do evento (partição) |
| event_timestamp | INT64 | Timestamp do evento (epoch em milissegundos) |
| user_id | STRING | Identificador do usuário (ou anônimo) |
| session_id | STRING | Identificador da sessão |
| event_name | STRING | Nome do evento (page_view, form_submit, lead_generated, etc.) |
| page_location | STRING | URL da página |
| device_category | STRING | desktop, mobile, tablet |
| geo_country | STRING | Código do país |
| traffic_source | STRING | Origem do tráfego (utm_source ou default) |
| traffic_medium | STRING | Meio (utm_medium ou default) |
| traffic_campaign | STRING | Campanha (utm_campaign) |
| engagement_time_msec | INT64 | Tempo de engajamento em milissegundos |
| value | FLOAT64 | Valor opcional (ex.: conversão = 1) |

## raw_crm_leads

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| lead_id | STRING | ID único do lead |
| user_id | STRING | ID do usuário (vínculo com GA4) |
| lead_created_at | TIMESTAMP | Data/hora de criação do lead |
| lead_source | STRING | inbound, outbound, referral |
| company_size | STRING | SMB, Enterprise |
| segment | STRING | fleet, dealership, insurance |
| status | STRING | new, qualified, disqualified |

## raw_contracts

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| contract_id | STRING | ID único do contrato |
| lead_id | STRING | ID do lead que originou o contrato |
| contract_created_at | TIMESTAMP | Data/hora de assinatura |
| plan_type | STRING | basic, pro, enterprise |
| monthly_revenue | FLOAT64 | Receita mensal recorrente (MRR) |
| contract_term_months | INT64 | Duração do contrato em meses |

## trusted_sessions (view)

Uma linha por session_id: métricas agregadas (event_count, page_views, form_starts, form_submits, lead_events, demo_events), datas de início/fim, device, geo e canal (traffic_source, traffic_medium, traffic_campaign).

## trusted_leads (view)

Leads com lead_date (DATE), lead_created_at e campos normalizados (lowercase/trim) para lead_source, company_size, segment, status.

## trusted_contracts (view)

Contratos com contract_date (DATE) e total_contract_value = monthly_revenue * contract_term_months.

## analytics_funnel_daily (view)

Métricas diárias: funnel_date, sessions, form_starts, form_submits, leads, demos, contracts (valores numéricos por dia).

## analytics_channel_kpis (view)

Por traffic_source, traffic_medium, traffic_campaign, device_category: sessions, leads, demos, contracts, conversion_rate, monthly_revenue, total_revenue.

## analytics_conversion_time (view)

Por lead: user_id, lead_id, lead_date, segment, first_seen, lead_created_at, contract_created_at, hours_to_lead, hours_lead_to_contract.

## analytics_revenue_kpis (view)

Uma linha: mrr_total, total_revenue, total_contracts, unique_leads_with_contract, avg_mrr_per_contract, avg_term_months.
