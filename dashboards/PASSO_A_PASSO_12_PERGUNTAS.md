# Passo a passo — Gráficos para as 12 perguntas de negócio

Guia **clique a clique** para montar cada gráfico/relatório no Looker Studio. Siga na ordem que preferir; as fontes são **analytics_funnel_daily**, **analytics_channel_kpis**, **analytics_conversion_time** e **analytics_revenue_kpis** (BigQuery → autotechb2b → analytics).

---

## Índice

1. [Volume do funil e receita total no período (Overview)](#pergunta-1)
2. [Evolução de tráfego e conversões no tempo](#pergunta-2)
3. [Canais com mais sessões e receita](#pergunta-3)
4. [Taxa de conversão em cada etapa do funil](#pergunta-4)
5. [Funil melhorando ou piorando no tempo](#pergunta-5)
6. [Canal que mais converte (sessão → contrato)](#pergunta-6)
7. [Desktop vs mobile – quem converte mais](#pergunta-7)
8. [Tempo médio: primeira visita → lead](#pergunta-8)
9. [Tempo médio: lead → contrato](#pergunta-9)
10. [Qual segmento demora mais para converter](#pergunta-10)
11. [Receita total, MRR e total de contratos](#pergunta-11)
12. [Qual plano gera mais receita](#pergunta-12)

---

<a name="pergunta-1"></a>
## Pergunta 1 — Qual o volume do funil e a receita total no período?

**Página:** Overview  
**Por que importa:** Ver de uma vez “quanto tráfego”, “quantos leads/contratos” e “quanto revenue” no período.  
**Fonte:** analytics_funnel_daily + analytics_revenue_kpis

### Passo a passo

1. Conecte ao relatório: **analytics_funnel_daily** e **analytics_revenue_kpis** (se ainda não conectou).
2. Crie uma página e nomeie: **Overview**.
3. **Cards do funil (4 cards):**
   - **Inserir** → **Scorecard**. Painel Dados: fonte **analytics_funnel_daily**. Métrica: **Soma de sessions**. Rótulo: **Sessões**. Posicione no topo.
   - Repita mais 3 scorecards, mesma fonte: **Soma de leads** → "Leads", **Soma de demos** → "Demos", **Soma de contracts** → "Contratos". Alinhe na mesma linha.
4. **Cards de receita (3 cards):**
   - **Inserir** → **Scorecard**. Fonte: **analytics_revenue_kpis**. Métrica: **total_revenue**. Rótulo: **Receita total**. Formato: Moeda (em Estilo), se quiser.
   - Outro scorecard: **mrr_total** → "MRR".
   - Outro: **total_contracts** → "Total de contratos".
   - Coloque na segunda linha, abaixo dos 4 cards do funil.
5. **Gráfico de linha (evolução no tempo):**
   - **Inserir** → **Gráfico de linhas**. Fonte: **analytics_funnel_daily**.
   - Dimensão (eixo X): **funnel_date**. Métricas (eixo Y): **Soma de sessions** e **Soma de leads**.
   - Título: "Sessões e leads ao longo do tempo". Posicione abaixo dos cards.

---

<a name="pergunta-2"></a>
## Pergunta 2 — Como evolui tráfego e conversões ao longo do tempo?

**Página:** Overview  
**Por que importa:** Ver tendência e picos (ex.: campanhas).  
**Fonte:** analytics_funnel_daily

### Passo a passo

1. **Inserir** → **Gráfico de linhas** (ou “Gráfico de série temporal”).
2. Painel **Dados**: fonte **analytics_funnel_daily**.
3. **Dimensão (eixo X):** **funnel_date**.
4. **Métricas (eixo Y):** adicione **Soma de sessions** e **Soma de leads** (duas linhas).
5. Em **Propriedades** ou **Estilo**: título **"Sessões e leads ao longo do tempo"**; em **Série**, cores diferentes e **Mostrar legenda**.
6. Coloque na página Overview (pode ser o mesmo gráfico da pergunta 1 ou um segundo, com mais métricas).
7. Opcional: adicione **Soma de contracts** como terceira linha para ver evolução de fechamentos.

---

<a name="pergunta-3"></a>
## Pergunta 3 — Quais canais trazem mais sessões e mais receita?

**Página:** Overview ou Canais  
**Por que importa:** Saber onde investir em mídia.  
**Fonte:** analytics_channel_kpis

### Passo a passo

1. **Tabela:**
   - **Inserir** → **Tabela**.
   - Fonte: **analytics_channel_kpis**.
   - **Dimensões:** arraste **traffic_source** e **traffic_medium** (e opcional **traffic_campaign**).
   - **Métricas:** **Soma de sessions**, **Soma de leads**, **Soma de contracts**, **Soma de total_revenue**.
   - Em **Ordenação** da tabela: ordene por **Soma de total_revenue** → **Decrescente**.
   - Título: "Canais por sessões e receita".
2. **Gráfico de barras (opcional):**
   - **Inserir** → **Gráfico de barras**.
   - Fonte: **analytics_channel_kpis**. Dimensão: **traffic_source**. Métrica: **Soma de total_revenue**.
   - Título: "Receita por canal (source)".

---

<a name="pergunta-4"></a>
## Pergunta 4 — Qual a taxa de conversão em cada etapa do funil?

**Página:** Funil  
**Por que importa:** Identificar onde se perde mais gente no funil.  
**Fonte:** analytics_funnel_daily

### Passo a passo

1. Crie uma página **"Funil"**.
2. **Tabela de totais e taxas:**
   - **Inserir** → **Tabela**.
   - Fonte: **analytics_funnel_daily**.
   - **Dimensão:** não use (para ver totais gerais) ou use **funnel_date** se quiser por dia.
   - **Métricas:** adicione **Soma** de: **sessions**, **form_starts**, **form_submits**, **leads**, **demos**, **contracts**.
   - Para **taxas**, crie campos calculados na fonte: **Recursos** (ícone chave inglesa) → **Gerenciar campos calculados** da fonte analytics_funnel_daily. Crie, por exemplo:
     - Nome: `Taxa form_start` | Fórmula: `SAFE_DIVIDE(SUM(form_starts), SUM(sessions))`
     - `Taxa form_submit`: `SAFE_DIVIDE(SUM(form_submits), SUM(form_starts))`
     - `Taxa lead`: `SAFE_DIVIDE(SUM(leads), SUM(form_submits))`
     - `Taxa demo`: `SAFE_DIVIDE(SUM(demos), SUM(leads))`
     - `Taxa contrato`: `SAFE_DIVIDE(SUM(contracts), SUM(demos))`
   - Adicione esses campos calculados como colunas da tabela. Formato: Percentual (0–1 ou 0–100%).
   - Título: "Funil e taxas por etapa".
3. **Gráfico de barras (volume por etapa):**
   - **Inserir** → **Gráfico de barras** → tipo **Barras horizontais**.
   - Fonte: **analytics_funnel_daily**.
   - **Dimensão:** deixe em branco ou use um campo constante (algumas versões permitem “sem dimensão” com várias métricas).
   - **Métricas:** adicione as 6: **Soma de sessions**, **Soma de form_starts**, **Soma de form_submits**, **Soma de leads**, **Soma de demos**, **Soma de contracts**. Cada uma vira uma barra.
   - Título: "Volume por etapa do funil".

---

<a name="pergunta-5"></a>
## Pergunta 5 — O funil está melhorando ou piorando ao longo do tempo?

**Página:** Funil  
**Por que importa:** Ver se as conversões melhoram por período.  
**Fonte:** analytics_funnel_daily

### Passo a passo

1. Na página **Funil** (ou nova).
2. **Inserir** → **Gráfico de linhas**.
3. Fonte: **analytics_funnel_daily**.
4. **Dimensão (eixo X):** **funnel_date**.
5. **Métricas (eixo Y):** **Soma de sessions**, **Soma de leads**, **Soma de contracts** (três linhas).
6. Título: "Evolução do funil no tempo".
7. Opcional: **Tabela** com dimensão **funnel_date** e as mesmas métricas (e taxas calculadas, se tiver criado) para análise dia a dia.

---

<a name="pergunta-6"></a>
## Pergunta 6 — Qual canal converte melhor (sessão → lead → contrato)?

**Página:** Canais  
**Por que importa:** Comparar eficiência dos canais, não só volume.  
**Fonte:** analytics_channel_kpis

### Passo a passo

1. Crie a página **"Canais"** (se ainda não existir).
2. **Tabela:**
   - **Inserir** → **Tabela**. Fonte: **analytics_channel_kpis**.
   - **Dimensões:** **traffic_source**, **traffic_medium**.
   - **Métricas:** **Soma de sessions**, **Soma de leads**, **Soma de contracts**, **Média de conversion_rate** (ou **conversion_rate** se for único por linha), **Soma de total_revenue**.
   - Ordenação: **Soma de contracts** ou **Soma de total_revenue** → Decrescente.
   - Título: "Conversão e receita por canal".
3. **Gráfico de barras:**
   - **Inserir** → **Gráfico de barras**. Fonte: **analytics_channel_kpis**.
   - Dimensão: **traffic_source**. Métrica: **Soma de total_revenue** (ou **Média de conversion_rate**).
   - Título: "Receita por canal" ou "Taxa de conversão por canal".

---

<a name="pergunta-7"></a>
## Pergunta 7 — Desktop ou mobile converte mais?

**Página:** Canais  
**Por que importa:** Decisão de investimento em experiência mobile.  
**Fonte:** analytics_channel_kpis (campo device_category)

### Passo a passo

1. **Tabela:**
   - **Inserir** → **Tabela**. Fonte: **analytics_channel_kpis**.
   - **Dimensão:** **device_category**.
   - **Métricas:** **Soma de sessions**, **Soma de leads**, **Soma de contracts**, **Média de conversion_rate**, **Soma de total_revenue**.
   - Título: "Performance por dispositivo".
2. **Gráfico de pizza ou barras:**
   - **Inserir** → **Gráfico de pizza** (ou **Gráfico de barras**).
   - Dimensão: **device_category**. Métrica: **Soma de sessions** (ou **Soma de total_revenue**).
   - Título: "Sessões por dispositivo" ou "Receita por dispositivo".

---

<a name="pergunta-8"></a>
## Pergunta 8 — Quanto tempo em média da primeira visita até o lead?

**Página:** Tempo até conversão  
**Por que importa:** Velocidade do topo do funil e expectativa de follow-up.  
**Fonte:** analytics_conversion_time

### Passo a passo

1. Conecte **analytics_conversion_time** ao relatório (se ainda não).
2. Crie a página **"Tempo até conversão"**.
3. **Scorecard:**
   - **Inserir** → **Scorecard**. Fonte: **analytics_conversion_time**.
   - Métrica: **Média de hours_to_lead**.
   - Rótulo: **"Média (horas): primeira visita → lead"**.
4. **Tabela (detalhe por lead):**
   - **Inserir** → **Tabela**. Fonte: **analytics_conversion_time**.
   - **Dimensões:** **lead_id**, **segment**.
   - **Métricas:** **hours_to_lead**, **hours_lead_to_contract**.
   - Título: "Tempo até conversão por lead".

---

<a name="pergunta-9"></a>
## Pergunta 9 — Quanto tempo da geração do lead até o contrato?

**Página:** Tempo até conversão  
**Por que importa:** Duração do ciclo comercial.  
**Fonte:** analytics_conversion_time

### Passo a passo

1. **Scorecard:**
   - **Inserir** → **Scorecard**. Fonte: **analytics_conversion_time**.
   - Métrica: **Média de hours_lead_to_contract**.
   - Rótulo: **"Média (horas): lead → contrato"**.
2. A **tabela** da pergunta 8 já tem **hours_lead_to_contract**; use a mesma tabela.
3. Para ver só leads que viraram contrato: no scorecard ou na tabela, em **Filtro** (ou Filtro de dados), adicione condição: **hours_lead_to_contract** **não é nulo** (ou **maior que 0**).

---

<a name="pergunta-10"></a>
## Pergunta 10 — Qual segmento (fleet/dealership/insurance) demora mais para converter?

**Página:** Tempo até conversão  
**Por que importa:** Priorizar segmentos mais rápidos.  
**Fonte:** analytics_conversion_time (campo segment)

### Passo a passo

1. **Tabela:**
   - **Inserir** → **Tabela**. Fonte: **analytics_conversion_time**.
   - **Dimensão:** **segment**.
   - **Métricas:** **Contagem de lead_id** (ou Contagem de registros), **Média de hours_to_lead**, **Média de hours_lead_to_contract**.
   - Título: "Tempo até conversão por segmento".
2. **Gráfico de barras:**
   - **Inserir** → **Gráfico de barras**. Fonte: **analytics_conversion_time**.
   - Dimensão: **segment**.
   - Métricas: **Média de hours_to_lead** e **Média de hours_lead_to_contract** (duas barras por segmento).
   - Título: "Tempo até conversão por segmento (fleet / dealership / insurance)".

---

<a name="pergunta-11"></a>
## Pergunta 11 — Qual a receita total e o MRR? Quantos contratos?

**Página:** Overview (ou Receita)  
**Por que importa:** KPIs de receita em um lugar.  
**Fonte:** analytics_revenue_kpis

### Passo a passo

1. **Inserir** → **Scorecard** (3 vezes).
2. Fonte em todos: **analytics_revenue_kpis**.
   - Card 1: métrica **total_revenue** → rótulo **Receita total**. Formato: Moeda.
   - Card 2: **mrr_total** → **MRR**. Formato: Moeda.
   - Card 3: **total_contracts** → **Total de contratos**.
3. Coloque os 3 na mesma linha (Overview ou página "Receita").  
*(Se você já fez a pergunta 1, esses cards podem ser os mesmos.)*

---

<a name="pergunta-12"></a>
## Pergunta 12 — Qual plano (basic/pro/enterprise) gera mais receita?

**Página:** Receita  
**Por que importa:** Saber qual plano puxa mais receita.  
**Fonte:** Hoje a camada analytics não tem plan_type; é preciso usar **trusted_contracts** (que tem **plan_type**, **monthly_revenue**, **total_contract_value**).

### Pré-requisito no BigQuery

A view **trusted_contracts** está no dataset **trusted** (não em analytics). No Looker Studio, ao adicionar dados, inclua também o dataset **trusted** e selecione **trusted_contracts**.  
(Campos úteis: contract_id, lead_id, contract_date, plan_type, monthly_revenue, contract_term_months, total_contract_value.)

### Passo a passo no Looker Studio

1. **Adicionar dados** → BigQuery → autotechb2b → dataset **trusted** → **trusted_contracts** → Adicionar.
2. Crie a página **"Receita por plano"** (ou use a página Canais/Receita).
3. **Tabela:**
   - **Inserir** → **Tabela**. Fonte: **trusted_contracts**.
   - **Dimensão:** **plan_type**.
   - **Métricas:** **Contagem de contract_id** (ou de registros), **Soma de monthly_revenue**, **Soma de total_contract_value**.
   - Ordenação: **Soma de total_contract_value** → Decrescente.
   - Título: "Receita por plano (basic / pro / enterprise)".
4. **Gráfico de barras:**
   - **Inserir** → **Gráfico de barras**. Fonte: **trusted_contracts**.
   - Dimensão: **plan_type**. Métrica: **Soma de total_contract_value** (ou **Soma de monthly_revenue**).
   - Título: "Receita total por plano".

---

## Ordem sugerida para montar

1. Conectar as 4 fontes (+ **trusted_contracts** se for fazer a pergunta 12).
2. **Overview:** perguntas 1, 2, 3, 11 (cards + gráfico de linha + tabela de canais).
3. **Funil:** perguntas 4 e 5 (tabela com taxas + gráfico de barras por etapa + gráfico de linha no tempo).
4. **Canais:** perguntas 6 e 7 (tabelas e gráficos por source/medium e por device).
5. **Tempo até conversão:** perguntas 8, 9 e 10 (scorecards + tabelas + gráfico por segment).
6. **Receita por plano:** pergunta 12 (tabela e barras com trusted_contracts).

---

## Filtro de data (recomendado)

- **Inserir** → **Controles** → **Controle de intervalo de datas**.
- Associe ao campo **funnel_date** da fonte **analytics_funnel_daily** (e, se possível, à **lead_date** de **analytics_conversion_time**) para que os gráficos respeitem o período escolhido.

Com isso você cobre, passo a passo, os gráficos para as 12 perguntas de negócio.
