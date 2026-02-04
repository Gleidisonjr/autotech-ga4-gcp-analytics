# Passo a passo — O que fazer agora

Este guia explica **uma coisa de cada vez**, na ordem certa, para você deixar o projeto rodando no seu GCP e no Looker Studio.

---

## Visão geral da ordem

1. **Passo 1** — Ter (ou criar) um projeto no Google Cloud e ativar o BigQuery  
2. **Passo 2** — Autenticar seu computador no GCP  
3. **Passo 3** — Criar os datasets no BigQuery  
4. **Passo 4** — Ajustar e executar o SQL que cria as tabelas raw  
5. **Passo 5** — Configurar e rodar o ETL (carregar os CSVs no BigQuery)  
6. **Passo 6** — Executar os SQLs das views (trusted e analytics)  
7. **Passo 7** — Rodar as queries de análise e qualidade (opcional mas recomendado)  
8. **Passo 8** — Conectar o Looker Studio e criar o dashboard  

Cada passo abaixo está explicado em detalhe. Só avance quando o passo atual estiver concluído.

---

## Passo 1 — Projeto GCP e BigQuery

**O que é:** Você precisa de um projeto no Google Cloud onde o BigQuery vai rodar. Esse projeto tem um **ID** (ex.: `meu-projeto-123`), que você usará em todo o resto.

**O que fazer:**

1. Acesse: [https://console.cloud.google.com](https://console.cloud.google.com)  
2. Faça login na sua conta Google.  
3. **Se já tiver um projeto:**  
   - No topo da página, clique no seletor de projeto (nome do projeto atual).  
   - Anote o **ID do projeto** (não o nome; o ID aparece em cinza, tipo `autotech-b2b-123456`).  
4. **Se não tiver projeto:**  
   - Clique em **“Criar projeto”**.  
   - Dê um nome (ex.: `AutoTech B2B Analytics`).  
   - Anote o **ID do projeto** que o Google mostrar (ou defina um você mesmo).  
   - Clique em **Criar**.  
5. Ative a **BigQuery API** para esse projeto:  
   - No menu (☰), vá em **APIs e serviços** → **Biblioteca**.  
   - Pesquise por **“BigQuery API”**.  
   - Clique em **BigQuery API** e depois em **Ativar** (se ainda não estiver ativa).

**Como saber que deu certo:** No menu lateral, em **BigQuery**, você consegue abrir a interface do BigQuery (Editor de consultas, conjuntos de dados, etc.) sem erro.

**Anote:** `project_id = ________________` (ex.: `meu-projeto-123`).

---

## Passo 2 — Autenticar seu computador no GCP

**O que é:** O script Python (ETL) e o próprio BigQuery precisam “saber” que é você usando o projeto. Isso é feito com credenciais no seu PC.

**O que fazer:**

1. Instale o **Google Cloud SDK** (gcloud) se ainda não tiver:  
   - [https://cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install) — escolha Windows e siga a instalação.  
2. Abra o **PowerShell** ou **Prompt de comando**.  
3. Rode:
   ```bash
   gcloud auth application-default login
   ```
4. Vai abrir o navegador para você fazer login na conta Google que tem acesso ao projeto.  
5. Autorize o acesso. Ao final, deve aparecer algo como “Credentials saved”.

**Como saber que deu certo:** O comando termina sem erro e não pede mais login. Essas credenciais serão usadas automaticamente pelo script Python e pelo BigQuery.

---

## Passo 3 — Criar os datasets no BigQuery

**O que é:** No BigQuery, “dataset” é como uma pasta onde ficam as tabelas. O projeto usa três: `raw`, `trusted` e `analytics`.

**O que fazer:**

1. Acesse [https://console.cloud.google.com/bigquery](https://console.cloud.google.com/bigquery).  
2. No painel à esquerda, clique no **nome do seu projeto**.  
3. Clique nos **três pontinhos** ao lado do projeto → **Criar conjunto de dados**.  
4. **Primeiro dataset — raw:**  
   - ID do conjunto de dados: `raw`  
   - Região: escolha uma (ex.: `us` ou `southamerica-east1`) e **use a mesma em todos**.  
   - Clique em **Criar conjunto de dados**.  
5. Repita para mais dois:  
   - ID: `trusted` (mesma região).  
   - ID: `analytics` (mesma região).

**Como saber que deu certo:** No painel esquerdo, sob o seu projeto, aparecem três conjuntos de dados: `raw`, `trusted`, `analytics`.

---

## Passo 4 — Criar as tabelas raw (SQL)

**O que é:** As tabelas que vão receber os dados dos CSVs (eventos GA4, leads, contratos) precisam existir. O script `01_create_tables_raw.sql` cria essas tabelas, mas está com um nome de projeto genérico — você precisa trocar pelo **seu** projeto.

**O que fazer:**

1. Abra o arquivo do projeto:  
   `sql/01_create_tables_raw.sql`  
2. Em todo o arquivo, substitua **`seu_projeto`** pelo **ID do seu projeto** (o que você anotou no Passo 1).  
   - Exemplo: se o ID é `meu-projeto-123`, onde estiver `seu_projeto.raw` vira `meu-projeto-123.raw`.  
   - Há 3 ocorrências (uma para cada CREATE TABLE).  
3. Salve o arquivo.  
4. No BigQuery (console):  
   - Clique em **+ Adicionar** → **Editor de consulta nova**.  
   - Copie **todo** o conteúdo do `01_create_tables_raw.sql` (já com seu project_id) e cole no editor.  
   - Clique em **Executar**.  
5. Confira: no painel esquerdo, dentro do dataset `raw`, devem aparecer as tabelas:  
   `raw_ga4_events`, `raw_crm_leads`, `raw_contracts`.

**Como saber que deu certo:** As três tabelas existem no dataset `raw` e a consulta terminou sem erro.

---

## Passo 5 — Configurar e rodar o ETL (carregar os CSVs)

**O que é:** O script Python lê os três CSVs da pasta `data/` e envia os dados para as tabelas raw no BigQuery. Para isso, ele usa um arquivo de configuração (`config.yaml`) com o ID do projeto e os caminhos dos arquivos.

**O que fazer:**

1. Abra a pasta do projeto no terminal (PowerShell ou CMD):
   ```bash
   cd c:\Users\dopamine\Desktop\Projetos\AutoTechB2B
   ```
2. Crie o ambiente Python (recomendado):
   ```bash
   python -m venv venv
   venv\Scripts\activate
   ```
3. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```
4. Na pasta `etl`, copie o exemplo de config:
   ```bash
   cd etl
   copy config.example.yaml config.yaml
   ```
5. Abra `etl/config.yaml` no editor e edite:
   - **project_id:** coloque o **ID do seu projeto** (ex.: `meu-projeto-123`).  
   - **dataset_raw:** deve ser `raw` (se você criou o dataset com esse nome).  
   - **csv_paths:** se os CSVs estão em `data/` na raiz do projeto, deixe como está:
     - `ga4_events: ../data/ga4_events_mock.csv`
     - `crm_leads: ../data/crm_leads.csv`
     - `contracts: ../data/contracts.csv`  
   Salve o arquivo.  
6. Primeiro rode em modo teste (não grava nada no BigQuery):
   ```bash
   python load_to_bigquery.py --dry-run
   ```
   Deve aparecer a contagem de linhas de cada CSV e a mensagem de dry-run.  
7. Se estiver tudo certo, rode de verdade:
   ```bash
   python load_to_bigquery.py
   ```
   Deve aparecer algo como “Tabela carregada: … raw_ga4_events (… linhas)” para cada uma das três tabelas.

**Como saber que deu certo:** No BigQuery, ao abrir a tabela `raw.raw_ga4_events` e clicar em “Visualizar”, você vê linhas de dados; o mesmo para `raw_crm_leads` e `raw_contracts`.

---

## Passo 6 — Executar os SQLs das views (trusted e analytics)

**O que é:** As “views” são consultas salvas com nome (trusted_sessions, analytics_funnel_daily, etc.). Elas leem as tabelas raw e trusted e montam as tabelas prontas para análise e dashboard. Os arquivos `02` e `03` criam essas views; de novo, é preciso trocar `seu_projeto` pelo seu project_id.

**O que fazer:**

1. Abra `sql/02_trusted_views.sql`.  
2. Substitua **todas** as ocorrências de **`seu_projeto`** pelo **ID do seu projeto**. Salve.  
3. No BigQuery, **Editor de consulta nova**: copie todo o conteúdo do `02_trusted_views.sql` e execute.  
4. Abra `sql/03_analytics_models.sql`.  
5. Substitua **todas** as ocorrências de **`seu_projeto`** pelo **ID do seu projeto**. Salve.  
6. No BigQuery, nova consulta: copie todo o conteúdo do `03_analytics_models.sql` e execute.

**Como saber que deu certo:** Nos datasets `trusted` e `analytics` aparecem as views (trusted_sessions, trusted_leads, analytics_funnel_daily, analytics_channel_kpis, etc.). Ao abrir uma view e “Visualizar”, ela retorna dados (ou lista vazia se a lógica depender de filtros; o importante é não dar erro).

---

## Passo 7 — Rodar as queries de análise e qualidade (recomendado)

**O que é:** Os arquivos `04` a `08` são consultas de análise (funil, canais, atribuição, tempo até conversão) e de qualidade de dados. Elas usam as views que você criou. Você não “cria” nada novo aqui; só roda as consultas para ver resultados e garantir que está tudo certo.

**O que fazer:**

1. Em cada arquivo `04_...sql` até `08_...sql`, substitua **`seu_projeto`** pelo **ID do seu projeto** (em todos os arquivos que tiverem esse texto).  
2. No BigQuery, para cada arquivo:
   - Abra o arquivo no editor de texto.
   - Copie o conteúdo (já com seu project_id).
   - Cole no Editor de consulta do BigQuery e execute.
3. Confira:
   - **04_funnel_analysis.sql** — deve retornar números de sessões, leads, demos, contratos e taxas.  
   - **05_channel_performance.sql** — linhas por canal (source/medium/campaign).  
   - **06_attribution_last_nondirect.sql** — conversões atribuídas por canal.  
   - **07_time_to_convert.sql** — tempos (mediana, P75, P90).  
   - **08_data_quality_checks.sql** — o ideal é todas as linhas com `failures = 0`.

**Como saber que deu certo:** As consultas rodam sem erro e os resultados fazem sentido (números positivos, taxas entre 0 e 1 onde aplicável, zero falhas nos checks de qualidade).

---

## Passo 8 — Looker Studio e dashboard

**O que é:** Conectar o Looker Studio ao seu projeto BigQuery e montar um relatório usando as views da camada analytics.

**O que fazer:**

1. Acesse [https://lookerstudio.google.com](https://lookerstudio.google.com) e faça login com a mesma conta Google do GCP.  
2. Clique em **Criar** → **Relatório**.  
3. Na tela “Adicionar dados”:  
   - Em “Conectar a dados”, escolha **BigQuery**.  
   - Autorize o Looker Studio a acessar o Google Cloud, se pedir.  
   - Navegue até: **seu projeto** → **analytics** e selecione as views que quiser (ex.: `analytics_funnel_daily`, `analytics_channel_kpis`, `analytics_conversion_time`, `analytics_revenue_kpis`).  
   - Clique em **Adicionar**.  
4. Monte pelo menos uma página **Overview**:  
   - Adicione gráficos/tabelas usando as métricas dessas fontes (sessões, leads, demos, contratos, receita).  
   - Use o guia em `dashboards/README_DASHBOARD.md` para ideias de layout (Overview, Funnel, Channels, Conversion Time).  
5. Salve o relatório e (opcional) adicione screenshots em `dashboards/screenshots/` (overview.png, funnel.png, etc.).

**Como saber que deu certo:** O relatório abre, os dados aparecem nos gráficos/tabelas e você consegue compartilhar o link do relatório.

---

## Resumo rápido (após ter feito tudo)

- **Passo 1:** Projeto GCP criado; BigQuery API ativada.  
- **Passo 2:** `gcloud auth application-default login` executado com sucesso.  
- **Passo 3:** Datasets `raw`, `trusted`, `analytics` criados no BigQuery.  
- **Passo 4:** `01_create_tables_raw.sql` executado (com seu project_id); tabelas raw existem.  
- **Passo 5:** `config.yaml` preenchido; ETL rodou (`load_to_bigquery.py`); tabelas raw com dados.  
- **Passo 6:** `02_trusted_views.sql` e `03_analytics_models.sql` executados; views existem.  
- **Passo 7:** Queries 04 a 08 executadas; resultados e data quality OK.  
- **Passo 8:** Looker Studio conectado ao BigQuery; relatório criado.

Se em algum passo der erro, pare ali e resolva (mensagem de erro, permissões, nomes de projeto/dataset) antes de seguir para o próximo.
