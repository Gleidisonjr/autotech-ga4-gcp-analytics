# ETL — Carregamento para BigQuery

Este diretório contém o script Python que carrega os CSVs sintéticos (GA4 events, CRM leads, contratos) para as tabelas **raw** no BigQuery.

## Pré-requisitos

- **Python 3.9+**
- Dependências: `pip install -r ../requirements.txt` (na raiz do projeto)
- **Google Cloud**: projeto com BigQuery API ativada
- **Autenticação**: Application Default Credentials

## Autenticação

Use uma das opções:

1. **gcloud (recomendado para desenvolvimento)**  
   ```bash
   gcloud auth application-default login
   ```
   Abre o navegador para login; as credenciais são salvas localmente.

2. **Service Account**  
   Defina a variável `GOOGLE_APPLICATION_CREDENTIALS` apontando para o JSON da conta de serviço com permissão de *BigQuery Data Editor* (e *Job User* se necessário) no projeto.

## Configuração

1. Copie o exemplo de config:
   ```bash
   cp config.example.yaml config.yaml
   ```

2. Edite `config.yaml`:
   - **project_id**: ID do seu projeto GCP
   - **location**: opcional (ex.: `southamerica-east1`)
   - **dataset_raw**: nome do dataset onde estão as tabelas raw (ex.: `raw`)
   - **csv_paths**: caminhos dos CSVs (relativos ao diretório `etl/` ou absolutos)

Exemplo:

```yaml
project_id: meu-projeto-123
location: southamerica-east1
dataset_raw: raw
csv_paths:
  ga4_events: ../data/ga4_events_mock.csv
  crm_leads: ../data/crm_leads.csv
  contracts: ../data/contracts.csv
```

## Como rodar

1. Instalar dependências (na raiz do repositório):
   ```bash
   pip install -r requirements.txt
   ```

2. Executar o ETL (a partir do diretório `etl/` ou passando o caminho do config):
   ```bash
   cd etl
   python load_to_bigquery.py
   ```

3. **Modo dry-run** (valida CSVs e loga contagens, sem gravar no BigQuery):
   ```bash
   python load_to_bigquery.py --dry-run
   ```

4. Usar config em outro caminho:
   ```bash
   python load_to_bigquery.py --config /caminho/para/config.yaml
   ```

## Comportamento

- Lê os três CSVs definidos em `csv_paths`.
- Converte datas/timestamps conforme o schema (event_date como DATE; lead_created_at e contract_created_at como TIMESTAMP).
- Envia para as tabelas no dataset raw (padrão: `raw_ga4_events`, `raw_crm_leads`, `raw_contracts`).
- **Write disposition**: `WRITE_TRUNCATE` — cada execução substitui o conteúdo da tabela.
- Logs no terminal: contagem de linhas lidas e, ao gravar, confirmação por tabela.

## Tratamento de erros

- Se `config.yaml` não existir ou estiver incompleto (ex.: `project_id` não definido), o script encerra com mensagem clara.
- Se algum CSV não for encontrado, o script falha listando o arquivo ausente.
- Falhas de rede ou permissão no BigQuery são logadas; verifique o projeto, a API e as permissões da conta.

## Ordem recomendada

1. Criar datasets e tabelas no BigQuery (scripts `sql/00_create_datasets.sql` e `sql/01_create_tables_raw.sql`).
2. Rodar o ETL para popular as tabelas raw.
3. Executar as views trusted e analytics (`02_trusted_views.sql`, `03_analytics_models.sql`).
