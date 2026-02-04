# KPIs e métricas

Definições e aproximações utilizadas no projeto (dados sintéticos).

## Funil

| Métrica | Definição |
|---------|-----------|
| **Sessões** | Contagem distinta de session_id (trusted_sessions). |
| **Form start** | Sessões com pelo menos um evento form_start. |
| **Form submit** | Sessões com pelo menos um evento form_submit. |
| **Leads** | Contagem de registros em trusted_leads (ou sessões com lead_generated no mesmo dia/user). |
| **Demos** | Sessões com pelo menos um evento demo_requested. |
| **Contratos** | Contagem de registros em trusted_contracts. |

Taxas entre etapas: por exemplo, taxa lead = leads / form_submits; taxa demo = demos / leads; taxa contrato = contracts / demos.

## Canais

| Métrica | Definição |
|---------|-----------|
| **Sessions por canal** | Agrupamento por traffic_source, traffic_medium, traffic_campaign (e device). |
| **Conversion rate** | leads / sessions (por canal). |
| **Receita por canal** | Soma de monthly_revenue ou total_contract_value atribuída ao canal da sessão de conversão (mesmo dia/user). |

## Atribuição

- **Last non-direct**: atribuição simplificada que considera a última sessão **não direta** (source ≠ (direct) ou medium ≠ none) por user_id como canal da conversão. Aproximação; em produção pode-se refinar por session de conversão e janela de lookback.

## Tempo até conversão

| Métrica | Definição |
|---------|-----------|
| **Hours to lead** | Diferença em horas entre first_seen (primeira sessão do user) e lead_created_at. |
| **Hours lead to contract** | Diferença em horas entre lead_created_at e contract_created_at. |

Relatórios podem usar mediana, P75 e P90 por canal ou segmento (query `07_time_to_convert.sql`).

## Receita e KPIs simulados

| KPI | Definição / aproximação |
|-----|--------------------------|
| **MRR** | Soma de monthly_revenue dos contratos ativos. |
| **Total revenue** | Soma de (monthly_revenue × contract_term_months) no período. |
| **CAC (simulado)** | Custo de aquisição por cliente: neste projeto não há custo real de mídia; pode-se simular como (custo total de campanha estimado) / contratos. Não calculado automaticamente nos scripts. |
| **LTV (simulado)** | Receita total do contrato (ou MRR × vida média do cliente). Aqui: total_contract_value por contrato; média = LTV médio. |
| **ROI (simulado)** | (Receita atribuída ao canal - custo do canal) / custo do canal. Requer dados de custo (não presentes nos mocks). |

As definições de CAC, LTV e ROI são **aproximações** para fins de portfólio; em produção seriam alimentadas por custos reais de campanha e regras de atribuição acordadas.
