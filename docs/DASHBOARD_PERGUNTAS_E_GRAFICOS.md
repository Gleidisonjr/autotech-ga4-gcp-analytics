# Dashboard AutoTech B2B — Perguntas de negócio e gráficos passo a passo

Este documento mapeia **perguntas de negócio** aos dados que você tem no GCP, indica **qual fonte usar** e descreve **passo a passo** como montar cada gráfico/relatório no Looker Studio.

---

## Visão da estrutura de dados disponível

| Fonte (view BigQuery) | O que traz |
|----------------------|------------|
| **analytics_funnel_daily** | Por dia: sessions, form_starts, form_submits, leads, demos, contracts |
| **analytics_channel_kpis** | Por canal (source/medium/campaign) e device: sessions, leads, demos, contracts, conversion_rate, monthly_revenue, total_revenue |
| **analytics_conversion_time** | Por lead: segment, hours_to_lead, hours_lead_to_contract (e datas) |
| **analytics_revenue_kpis** | Uma linha: mrr_total, total_revenue, total_contracts, avg_mrr_per_contract, avg_term_months |

**Observação:** Para análise por **segmento** (fleet / dealership / insurance) use **analytics_conversion_time** (tem o campo `segment`). Para análise por **canal** use **analytics_channel_kpis**.

---

## Guia passo a passo (clique a clique) para cada gráfico

**Arquivo completo:** [dashboards/PASSO_A_PASSO_12_PERGUNTAS.md](../dashboards/PASSO_A_PASSO_12_PERGUNTAS.md) — contém o passo a passo detalhado para as 12 perguntas abaixo.

---

## Dashboard final do projeto

O dashboard **AutoTechB2B - Overview** implementado inclui: 8 scorecards (funil + receita), receita por dispositivo (pizza), tráfego por canal (barras), receita por tipo de plano (treemap), sessões e leads no tempo (linha) e filtro de data. As perguntas abaixo servem como **referência para expansão** (páginas adicionais ou novos gráficos); não é necessário implementar todas.

---

## Mapa: perguntas de negócio → página e gráfico

| # | Pergunta de negócio | Página sugerida | Gráfico / componente |
|---|--------------------|-----------------|------------------------|
| 1 | Qual o volume do funil e a receita total no período? | Overview | Cards + gráfico de linha |
| 2 | Como evolui tráfego e conversões ao longo do tempo? | Overview | Gráfico de linha (sessões e leads por dia) |
| 3 | Quais canais trazem mais sessões e mais receita? | Overview / Canais | Tabela e barras |
| 4 | Qual a taxa de conversão em cada etapa do funil? | Funil | Barras + métricas calculadas |
| 5 | O funil está melhorando ou piorando ao longo do tempo? | Funil | Linha por etapa ou tabela por período |
| 6 | Qual canal converte melhor (sessão → lead → contrato)? | Canais | Tabela + barras (conversion_rate, contracts, total_revenue) |
| 7 | Desktop ou mobile converte mais? | Canais | Tabela ou gráfico por device_category |
| 8 | Quanto tempo em média da primeira visita até o lead? | Tempo até conversão | Métrica + tabela + distribuição |
| 9 | Quanto tempo da geração do lead até o contrato? | Tempo até conversão | Métrica + tabela |
| 10 | Qual segmento (fleet/dealership/insurance) demora mais para converter? | Tempo até conversão | Tabela ou gráfico por segment |
| 11 | Qual a receita total e o MRR? Quantos contratos? | Overview / Receita | Cards (analytics_revenue_kpis) |
| 12 | Qual plano (basic/pro/enterprise) gera mais receita? | Receita* | Requer join com contratos — ver nota abaixo |

\* Para plano (plan_type) seria necessário usar **trusted_contracts** ou uma view que exponha plan_type; hoje a camada analytics não tem essa view. Você pode criar uma view no BigQuery que agregue por plan_type e conectar depois.

---

# Passo a passo por pergunta e gráfico

---

## PÁGINA 1 — Overview (visão executiva)

**Objetivo:** Responder às perguntas 1, 2, 3 e 11 em um só lugar.

---

### Pergunta 1 e 11 — Qual o volume do funil e a receita total no período?

**Por que importa:** Direção precisa de “quanto tráfego temos”, “quantos leads/contratos” e “quanto revenue” no período.

**Fonte:**  
- **analytics_funnel_daily** (soma de sessions, leads, demos, contracts no período).  
- **analytics_revenue_kpis** (total_revenue, mrr_total, total_contracts).

**Passo a passo no Looker Studio:**

1. Adicione ao relatório as fontes **analytics_funnel_daily** e **analytics_revenue_kpis** (BigQuery → autotechb2b → analytics).
2. Crie uma **página** e nomeie como "Overview".
3. **Cards de métricas (funil):**
   - Menu **Inserir** → **Scorecard** (ou arraste o ícone de número).
   - Selecione a fonte **analytics_funnel_daily**.
   - No scorecard 1: métrica **Soma de sessions** → renomeie o rótulo para "Sessões".
   - Repita para mais 3 scorecards: **Soma de leads** ("Leads"), **Soma de demos** ("Demos"), **Soma de contracts** ("Contratos").
4. **Cards de receita:**
   - Novo scorecard com fonte **analytics_revenue_kpis**: métrica **total_revenue** → rótulo "Receita total".
   - Outro: **mrr_total** → "MRR".
   - Outro: **total_contracts** → "Total de contratos".
5. Organize os cards em uma linha (funil) e outra (receita).

---

### Pergunta 2 — Como evolui tráfego e conversões ao longo do tempo?

**Por que importa:** Ver tendência e sazonalidade (ex.: pico em campanhas).

**Fonte:** **analytics_funnel_daily**.

**Passo a passo:**

1. **Inserir** → **Gráfico de linhas**.
2. Fonte de dados: **analytics_funnel_daily**.
3. **Dimensão (eixo X):** `funnel_date`.
4. **Métricas (eixo Y):** adicione **Soma de sessions** e **Soma de leads** (duas linhas no mesmo gráfico).
5. Título: "Sessões e leads ao longo do tempo".
6. Opcional: em **Estilo** → **Série**, dê cores diferentes para cada métrica e ative legenda.

---

### Pergunta 3 — Quais canais trazem mais sessões e mais receita?

**Por que importa:** Saber onde investir em mídia e onde o retorno é maior.

**Fonte:** **analytics_channel_kpis**.

**Passo a passo:**

1. **Inserir** → **Tabela**.
2. Fonte: **analytics_channel_kpis**.
3. **Dimensões:** `traffic_source`, `traffic_medium` (e opcional `traffic_campaign`).
4. **Métricas:** **Soma de sessions**, **Soma de leads**, **Soma de contracts**, **Soma de total_revenue**.
5. Ordenação: por **Soma de total_revenue** decrescente.
6. Título: "Canais por sessões e receita".
7. Opcional: **Inserir** → **Gráfico de barras** com dimensão `traffic_source` e métrica **Soma de total_revenue** para visualização rápida do top canal.

---

## PÁGINA 2 — Funil (taxas por etapa)

**Objetivo:** Responder às perguntas 4 e 5.

---

### Pergunta 4 — Qual a taxa de conversão em cada etapa do funil?

**Por que importa:** Identificar em qual etapa se perde mais gente (form_start, submit, lead, demo, contrato).

**Fonte:** **analytics_funnel_daily** (somas no período).

**Passo a passo:**

1. Nova página: "Funil".
2. **Tabela de funil e taxas:**
   - **Inserir** → **Tabela**.
   - Fonte: **analytics_funnel_daily**.
   - Não use dimensão (ou use funnel_date se quiser por dia). Para “funil agregado”, use **Métricas** com **Soma** de: `sessions`, `form_starts`, `form_submits`, `leads`, `demos`, `contracts`.
   - Para ver totais no período: no Looker Studio você pode criar **Campos calculados** (em Recursos → Gerenciar campos calculados da fonte), por exemplo:
     - `Taxa form_start` = Soma(form_starts) / Soma(sessions)
     - `Taxa form_submit` = Soma(form_submits) / Soma(form_starts)
     - `Taxa lead` = Soma(leads) / Soma(form_submits)
     - `Taxa demo` = Soma(demos) / Soma(leads)
     - `Taxa contrato` = Soma(contracts) / Soma(demos)
   - Adicione esses campos como colunas da tabela.
3. **Gráfico de barras (volume por etapa):**
   - **Inserir** → **Gráfico de barras**.
   - Para um gráfico “uma barra por etapa” você precisa de uma fonte com uma linha por etapa. Como a view é “uma linha por dia”, duas opções:
     - **A)** Use a mesma fonte e coloque **Soma de sessions**, **Soma de form_starts**, etc., como métricas (cada uma vira uma barra se o gráfico for configurado como “métricas agrupadas”).
     - **B)** Crie no BigQuery uma view com uma linha por etapa (etapa, volume) e conecte ao Looker.  
   - Opção A no Looker: tipo de gráfico **Barras horizontais**, dimensão deixe em branco ou use uma constante; adicione as 6 métricas (sessions, form_starts, form_submits, leads, demos, contracts). Ajuste no tipo “Métricas em linhas” ou “Série” conforme a interface.

---

### Pergunta 5 — O funil está melhorando ou piorando ao longo do tempo?

**Por que importa:** Ver se as taxas melhoram por semana/mês.

**Fonte:** **analytics_funnel_daily**.

**Passo a passo:**

1. Na mesma página "Funil" (ou nova).
2. **Gráfico de linhas:** dimensão **funnel_date**, métricas **Soma de sessions**, **Soma de leads**, **Soma de contracts** (três linhas).
3. Ou **tabela** com dimensão **funnel_date** e as mesmas métricas + campos calculados de taxa (se tiver criado) para ver evolução das taxas por dia.

---

## PÁGINA 3 — Canais (performance por source/medium/device)

**Objetivo:** Responder às perguntas 6 e 7.

---

### Pergunta 6 — Qual canal converte melhor (sessão → lead → contrato)?

**Por que importa:** Comparar eficiência dos canais além do volume.

**Fonte:** **analytics_channel_kpis**.

**Passo a passo:**

1. Página "Canais".
2. **Tabela:** dimensões `traffic_source`, `traffic_medium`; métricas **Soma de sessions**, **Soma de leads**, **Soma de contracts**, **conversion_rate** (média ou use o campo já calculado se existir), **Soma de total_revenue**.
3. Ordenar por **Soma de contracts** ou **Soma de total_revenue** (decrescente).
4. **Gráfico de barras:** dimensão `traffic_source`, métrica **Soma de total_revenue** (ou **Média de conversion_rate**).
5. Título: "Conversão e receita por canal".

---

### Pergunta 7 — Desktop ou mobile converte mais?

**Por que importa:** Decisão de investimento em experiência mobile vs desktop.

**Fonte:** **analytics_channel_kpis** (tem `device_category`).

**Passo a passo:**

1. **Tabela:** dimensão `device_category`; métricas **Soma de sessions**, **Soma de leads**, **Soma de contracts**, **Média de conversion_rate**, **Soma de total_revenue**.
2. **Gráfico de pizza ou barras:** dimensão `device_category`, métrica **Soma de sessions** (ou **Soma de total_revenue**).
3. Título: "Performance por dispositivo".

---

## PÁGINA 4 — Tempo até conversão

**Objetivo:** Responder às perguntas 8, 9 e 10.

**Fonte:** **analytics_conversion_time** (tem `hours_to_lead`, `hours_lead_to_contract`, `segment`).

---

### Pergunta 8 — Quanto tempo em média da primeira visita até o lead?

**Por que importa:** Entender velocidade do topo do funil e expectativa de follow-up.

**Passo a passo:**

1. Página "Tempo até conversão".
2. **Scorecard:** fonte **analytics_conversion_time**, métrica **Média de hours_to_lead** → rótulo "Média (horas): visita → lead".
3. Opcional: **Mediana** — no Looker você pode criar campo calculado com percentil (se a função existir) ou usar **Média** como proxy.
4. **Tabela:** dimensões `lead_id`, `segment`; métricas **hours_to_lead**, **hours_lead_to_contract** para ver distribuição por lead.

---

### Pergunta 9 — Quanto tempo do lead até o contrato?

**Por que importa:** Medir duração do ciclo comercial.

**Passo a passo:**

1. **Scorecard:** **Média de hours_lead_to_contract** → "Média (horas): lead → contrato".
2. **Tabela:** inclua **hours_lead_to_contract** (já na tabela do passo 8).
3. Filtro: excluir linhas em que **hours_lead_to_contract** seja nulo (só leads que viraram contrato).

---

### Pergunta 10 — Qual segmento demora mais para converter?

**Por que importa:** Priorizar segmentos mais rápidos ou ajustar expectativas por segmento.

**Passo a passo:**

1. **Tabela:** dimensão `segment`; métricas **Contagem de lead_id**, **Média de hours_to_lead**, **Média de hours_lead_to_contract**.
2. **Gráfico de barras:** dimensão `segment`, métricas **Média de hours_to_lead** e **Média de hours_lead_to_contract** (duas barras por segmento).
3. Título: "Tempo até conversão por segmento (fleet / dealership / insurance)".

---

## Resumo rápido: ordem sugerida para montar no Looker

1. Conectar as 4 fontes (analytics_funnel_daily, analytics_channel_kpis, analytics_conversion_time, analytics_revenue_kpis).
2. **Overview:** cards de funil + receita → gráfico de linha (sessões e leads no tempo) → tabela de canais por sessões e receita.
3. **Funil:** tabela com totais e taxas (campos calculados) → gráfico de linhas no tempo (sessões/leads/contratos).
4. **Canais:** tabela completa por source/medium → gráfico de barras (receita por source) → tabela e gráfico por device_category.
5. **Tempo até conversão:** scorecards (média hours_to_lead e hours_lead_to_contract) → tabela por lead → tabela e gráfico por segment.

---

## Filtros globais recomendados

- **Intervalo de datas:** adicione um **Controle de filtro** com campo de data (ex.: `funnel_date` de analytics_funnel_daily ou `lead_date` de analytics_conversion_time) para que as páginas que usem essas fontes respeitem o período escolhido.
- Se tiver várias fontes, use **Filtros de dados** no relatório ou em cada gráfico para manter consistência (ex.: mesmo intervalo em Overview e Funil).

Com isso você cobre as principais perguntas de negócio sobre funil, canais, receita e tempo até conversão, alinhadas à estrutura atual do seu GCP e do dashboard.
