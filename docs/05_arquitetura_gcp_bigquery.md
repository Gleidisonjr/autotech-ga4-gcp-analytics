# Arquitetura GCP e BigQuery

## Visão geral

O pipeline de dados do projeto utiliza **Google Cloud BigQuery** em três camadas: **raw**, **trusted** e **analytics**. Os dados de entrada são CSVs sintéticos (GA4 events, CRM leads, contratos) carregados via script Python (ETL); em produção, a fonte de eventos seria a exportação contínua do GA4 para BigQuery.

## Componentes

| Componente | Função |
|------------|--------|
| **Data sources** | CSVs (mock) ou GA4 export + CRM/ERP (produção) |
| **ETL** | Python (pandas + google-cloud-bigquery) carrega CSVs nas tabelas raw |
| **BigQuery** | Armazenamento e processamento; views e modelos em SQL |
| **Looker Studio** | Visualização conectada às views/tabelas da camada analytics |

## Datasets e camadas

- **raw**: tabelas espelho da ingestão (raw_ga4_events, raw_crm_leads, raw_contracts). Particionamento por `event_date` em raw_ga4_events.
- **trusted**: views que agregam e normalizam (trusted_sessions, trusted_users, trusted_leads, trusted_contracts).
- **analytics**: views de negócio para relatórios (analytics_funnel_daily, analytics_channel_kpis, analytics_conversion_time, analytics_revenue_kpis).

Recomendação: três datasets (`raw`, `trusted`, `analytics`) para separação de custo e permissão. Alternativa: um dataset único com prefixos de tabela.

## Custos e boas práticas

- **Particionamento**: use `event_date` em tabelas de eventos para reduzir bytes escaneados em consultas por período.
- **Clustering**: em tabelas grandes, cluster por `user_id` ou `session_id` quando as consultas filtrarem por esses campos.
- **Slots**: consultas ad-hoc usam o modelo on-demand; para cargas previsíveis, considerar reserva de slots.
- **Governança**: limitar acesso de escrita à camada raw e ETL; leitura para trusted/analytics e Looker Studio.

## Região

Criar datasets na mesma região do uso principal (ex.: `southamerica-east1` para usuários no Brasil) para evitar custo de transferência e menor latência.
