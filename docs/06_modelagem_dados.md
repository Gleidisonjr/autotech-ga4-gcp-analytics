# Modelagem de dados

## Camadas

### Raw

- **Objetivo**: preservar os dados como recebidos, sem regras de negócio.
- **Conteúdo**: tabelas com a mesma estrutura dos CSVs (ou do export GA4/CRM). Tipos e nomes de colunas alinhados à origem.
- **Rationale**: reprodutibilidade, auditoria e reprocessamento sem perda de informação.

### Trusted

- **Objetivo**: dados limpos, deduplicados e modelados para uso analítico (sessões, usuários, leads, contratos).
- **Conteúdo**: views que agregam eventos por session_id e user_id; normalização de tipos (lowercase, trim) e datas; joins mínimos apenas para enriquecimento necessário.
- **Rationale**: uma única fonte de verdade para “sessão”, “lead” e “contrato” consumida pela camada analytics.

### Analytics

- **Objetivo**: métricas e agregações prontas para relatórios e dashboards.
- **Conteúdo**: views/tabelas como funnel diário, KPIs por canal, tempo até conversão, receita agregada.
- **Rationale**: evitar lógica complexa no Looker Studio; reutilizar definições entre relatórios.

## Fluxo de entidades

- **Eventos (GA4)** → agregação por **session_id** → trusted_sessions; agregação por **user_id** → trusted_users.
- **Leads (CRM)** → normalização → trusted_leads. Ligação com eventos via **user_id** e data (lead_date = session_date quando conversão na mesma sessão).
- **Contratos** → trusted_contracts. Ligação com leads via **lead_id**.
- **Funil e canais**: trusted_sessions + trusted_leads + trusted_contracts → analytics_funnel_daily, analytics_channel_kpis, analytics_conversion_time, analytics_revenue_kpis.

## Dicionário

Detalhamento das colunas principais em `07_dicionario_dados.md`.
