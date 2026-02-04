# Passo a passo: "Qual o volume do funil e a receita total no período?" (Overview — Cards + gráfico de linha)

Siga na ordem. Use a **mesma conta Google** do projeto **autotechb2b**.

---

## Parte 0 — Ter as fontes conectadas

1. Acesse **https://lookerstudio.google.com** e faça login.
2. Abra seu relatório (ou **Criar** → **Relatório**).
3. Se ainda não conectou os dados:
   - **Adicionar dados** (ou ícone de banco de dados).
   - Escolha **BigQuery**.
   - Navegue: **Projetos** → **autotechb2b** → **analytics**.
   - Selecione e adicione:
     - **analytics_funnel_daily**
     - **analytics_revenue_kpis**
   - Clique em **Adicionar**.

Você vai usar duas fontes: **analytics_funnel_daily** (funil) e **analytics_revenue_kpis** (receita).

---

## Parte 1 — Cards do funil (Sessões, Leads, Demos, Contratos)

Cada card mostra o **total no período** para uma métrica.

### Card 1 — Sessões

1. No menu superior: **Inserir** → **Scorecard** (ou arraste o ícone de “número”/card para a tela).
2. O painel **Dados** à direita abre. Em **Fonte de dados**, selecione **analytics_funnel_daily**.
3. Em **Métrica**, clique no campo e escolha **sessions** (e agregação **Soma** — geralmente já vem como “Soma de sessions”).
4. Em **Rótulo** (ou nas propriedades do scorecard), digite: **Sessões**.
5. Posicione o card no canto superior esquerdo da página.

### Card 2 — Leads

1. **Inserir** → **Scorecard**.
2. Fonte: **analytics_funnel_daily**.
3. Métrica: **leads** (Soma).
4. Rótulo: **Leads**.
5. Coloque ao lado do card Sessões (mesma linha).

### Card 3 — Demos

1. **Inserir** → **Scorecard**.
2. Fonte: **analytics_funnel_daily**.
3. Métrica: **demos** (Soma).
4. Rótulo: **Demos**.
5. Ao lado do card Leads.

### Card 4 — Contratos

1. **Inserir** → **Scorecard**.
2. Fonte: **analytics_funnel_daily**.
3. Métrica: **contracts** (Soma).
4. Rótulo: **Contratos**.
5. Ao lado do card Demos.

Você deve ter **uma linha com 4 cards**: Sessões | Leads | Demos | Contratos.

---

## Parte 2 — Cards de receita (Receita total, MRR, Total de contratos)

### Card 5 — Receita total

1. **Inserir** → **Scorecard**.
2. Fonte: **analytics_revenue_kpis** (mude da funnel_daily para esta).
3. Métrica: **total_revenue** (já é um total na view; use o campo como está ou “Soma” se aparecer).
4. Rótulo: **Receita total**.
5. Formato: em **Estilo** do scorecard, defina **Formato do número** como Moeda (R$ ou USD), se quiser.
6. Coloque abaixo da primeira linha de cards (segunda linha, primeira posição).

### Card 6 — MRR

1. **Inserir** → **Scorecard**.
2. Fonte: **analytics_revenue_kpis**.
3. Métrica: **mrr_total**.
4. Rótulo: **MRR**.
5. Formato: Moeda (opcional).
6. Ao lado do card Receita total.

### Card 7 — Total de contratos (receita)

1. **Inserir** → **Scorecard**.
2. Fonte: **analytics_revenue_kpis**.
3. Métrica: **total_contracts**.
4. Rótulo: **Total de contratos** (ou “Contratos (receita)” para não confundir com o card do funil).
5. Ao lado do MRR.

Você deve ter **duas linhas de cards**:  
Linha 1: Sessões | Leads | Demos | Contratos  
Linha 2: Receita total | MRR | Total de contratos  

Isso responde: **“Qual o volume do funil e a receita total no período?”**

---

## Parte 3 — Gráfico de linha (evolução no tempo)

Para mostrar **como** sessões e leads evoluem ao longo dos dias:

1. **Inserir** → **Gráfico de linhas** (ou “Gráfico de série temporal”).
2. No painel **Dados**:
   - **Fonte de dados:** **analytics_funnel_daily**.
   - **Dimensão (eixo X / quebra):** **funnel_date**.
   - **Métricas (eixo Y):** adicione:
     - **Soma de sessions** (ou “sessions” com agregação Soma).
     - **Soma de leads** (ou “leads” com agregação Soma).
3. Título do gráfico: **Sessões e leads ao longo do tempo** (em Propriedades → Título ou na barra do gráfico).
4. (Opcional) **Estilo** → **Série**: cores diferentes para “Sessions” e “Leads”; marque **Mostrar legenda**.
5. Coloque o gráfico **abaixo dos cards**, ocupando boa parte da largura.

Resultado: um gráfico com **duas linhas** — uma para o total de sessões por dia e outra para o total de leads por dia.

---

## Resumo do que você tem ao terminar

- **7 cards:** volume do funil (4) + receita/contratos (3).
- **1 gráfico de linha:** sessões e leads por dia.

Isso cobre a pergunta: **“Qual o volume do funil e a receita total no período?”** com números do período (cards) e tendência no tempo (gráfico de linha).

---

## Dica: filtro de data (opcional)

Para o usuário poder escolher o período:

1. **Inserir** → **Controles** → **Controle de intervalo de datas**.
2. Associe ao campo **funnel_date** da fonte **analytics_funnel_daily** (e, se possível, defina essa fonte como “fonte de dados padrão do relatório” para o filtro aplicar aos gráficos que usam ela).
3. Coloque o filtro no topo da página.

Assim, ao mudar o intervalo, os cards do funil e o gráfico de linha passam a refletir só o período selecionado.
