# Dashboards Looker Studio

Instruções para montar o relatório no **Looker Studio** usando as tabelas/views da camada **analytics** no BigQuery.

**Dashboard final do projeto (Overview):** uma página com 8 KPIs (funil + receita), gráfico de receita por dispositivo, tráfego por canal, receita por tipo de plano e sessões/leads ao longo do tempo, com filtro de data. As 12 perguntas de negócio documentadas são **opções de expansão** (páginas Funil, Canais, Tempo até conversão); não é obrigatório implementar todas.

**Guia completo (perguntas de negócio + passo a passo de cada gráfico):** [docs/DASHBOARD_PERGUNTAS_E_GRAFICOS.md](../docs/DASHBOARD_PERGUNTAS_E_GRAFICOS.md)

## Fonte de dados

Conecte uma fonte de dados **BigQuery** ao seu projeto e dataset (ex.: `autotechb2b.analytics`). Use as seguintes entidades:

| Entidade | Uso principal |
|----------|----------------|
| `analytics_funnel_daily` | Funil diário (sessões, form_start, form_submit, leads, demos, contracts) |
| `analytics_channel_kpis` | KPIs por canal (source/medium/campaign, device), receita |
| `analytics_conversion_time` | Tempo até lead e até contrato (hours_to_lead, hours_lead_to_contract) |
| `analytics_revenue_kpis` | Receita agregada (MRR, total revenue, médias) |

## Páginas sugeridas

### 1. Overview (KPIs principais)

- **Objetivo**: visão executiva do funil e receita.
- **Componentes**:
  - Métricas em cards: total de sessões, leads, demos, contratos (período selecionado).
  - Métrica: receita total (a partir de `analytics_revenue_kpis` ou soma em `analytics_channel_kpis`).
  - Gráfico de linha: evolução diária de sessões e leads (fonte: `analytics_funnel_daily`).
  - Tabela resumo: top canais por sessões e por receita (`analytics_channel_kpis`).
- **Filtros**: intervalo de datas (se sua fonte tiver campo de data).

### 2. Funnel (taxas por etapa)

- **Objetivo**: funil de conversão e taxas entre etapas.
- **Fonte**: `analytics_funnel_daily`.
- **Componentes**:
  - Gráfico de funil ou barras empilhadas: sessões → form_start → form_submit → leads → demos → contracts.
  - Cálculos no Looker Studio: taxa form_start/sessões, form_submit/form_start, lead/form_submit, demo/lead, contract/demo.
  - Tabela com métricas por dia.
- **Filtros**: data; opcional: device (se usar tabela enriquecida por device).

### 3. Channels (source/medium/campaign)

- **Objetivo**: performance por canal de aquisição.
- **Fonte**: `analytics_channel_kpis`.
- **Componentes**:
  - Tabela: traffic_source, traffic_medium, traffic_campaign, device_category, sessions, leads, demos, contracts, conversion_rate, monthly_revenue, total_revenue.
  - Gráfico de barras: total_revenue ou sessions por source/medium.
  - Gráfico de pizza ou barras: distribuição de sessões por device_category.
- **Filtros**: source, medium, campaign.

### 4. Conversion Time (tempo até conversão)

- **Objetivo**: tempo entre first touch e lead, e entre lead e contrato.
- **Fonte**: `analytics_conversion_time`.
- **Componentes**:
  - Métricas: mediana (ou média) de `hours_to_lead` e `hours_lead_to_contract` (calcule no Looker ou use resultado do `07_time_to_convert.sql` exportado).
  - Tabela: user_id, lead_id, segment, hours_to_lead, hours_lead_to_contract.
  - Gráfico de distribuição (histograma) de hours_to_lead por segment ou canal.
- **Dica**: para mediana/P75/P90 por canal ou segmento, use a saída da query `07_time_to_convert.sql` (pode ser salva como view ou tabela e conectada como fonte).

## Placeholders de imagens

- **dashboard_mockup.png**: mockup ou wireframe do layout do relatório (uma página ou todas). Gere um desenho ou screenshot após criar o dashboard.
- **screenshots/**: adicione prints das páginas publicadas com os nomes:
  - `overview.png` — página Overview
  - `funnel.png` — página Funnel
  - `channels.png` — página Channels
  - `conversion_time.png` — página Conversion Time
