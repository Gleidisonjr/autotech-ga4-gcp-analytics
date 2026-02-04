# Roadmap de melhorias

Evoluções sugeridas após a base do portfólio estar funcionando.

## Dados reais

- **GA4 → BigQuery**: ativar exportação contínua do GA4 para BigQuery e substituir o CSV de eventos mock pela tabela de eventos reais (events_*). Ajustar schemas e particionamento.
- **CRM**: integrar leads via API ou export (CSV/Cloud Storage) com sincronização agendada; manter user_id ou chave equivalente para join com eventos.
- **Contratos**: conectar fonte de dados de vendas (CRM ou ERP) para atualização automática de contratos e receita.

## Modelagem e pipeline

- **Dataform ou dbt**: versionar modelos SQL (trusted e analytics) com testes (unicidade, nulos, integridade) e documentação. Agendar execuções no BigQuery.
- **Looker / LookerML**: se usar Looker Studio Plus ou Looker, definir métricas reutilizáveis (LookML) para conversão, receita e tempo até conversão.

## Qualidade e monitoramento

- **Data Quality checks**: rodar `08_data_quality_checks.sql` via agendamento (Cloud Scheduler + BigQuery ou Dataform) e enviar alertas (e-mail, Slack) quando failures > 0.
- **Monitoramento de custo**: alertas no GCP para orçamento e uso de bytes escaneados no BigQuery.

## Atribuição e análise

- **Modelos de atribuição**: além do last non-direct, implementar multi-touch (linear, time decay, position-based) sobre histórico de sessões por user_id.
- **Segmentação**: análises por segmento (fleet, dealership, insurance), company_size e região (geo_country) de forma sistemática nas views analytics.

Este roadmap demonstra capacidade de evoluir o projeto de um MVP com dados sintéticos para um pipeline corporativo com dados reais, governança e monitoramento.
