# Plano de mensuração GA4

## Escopo

Plano de implementação do **Google Analytics 4** para o cenário AutoTech B2B, cobrindo eventos, parâmetros e dimensões necessários para funil (Web/App → Lead → Demo → Contrato) e performance de canais.

## Objetivos de mensuração

| Objetivo | Métrica / evento principal |
|----------|-----------------------------|
| Tráfego e engajamento | page_view, session_start, engagement_time |
| Início do funil | form_start, form_submit (formulário de contato/demo) |
| Conversão lead | lead_generated (ou event customizado vinculado ao CRM) |
| Solicitação de demo | demo_requested |
| Comportamento logado | login, feature_usage (opcional) |

## Eventos recomendados

| Nome do evento | Gatilho sugerido | Parâmetros principais |
|----------------|------------------|------------------------|
| `page_view` | Todas as páginas (GA4 nativo ou GTM) | page_location, page_title |
| `view_item` | Visualização de página de produto/solução | item_id, item_name, segment |
| `form_start` | Foco no primeiro campo do formulário | form_name, form_destination |
| `form_submit` | Envio do formulário | form_name, form_destination |
| `lead_generated` | Página de thank-you ou webhook CRM | value (opcional) |
| `demo_requested` | Confirmação de agendamento de demo | value (opcional) |
| `login` | Login no app | method (opcional) |
| `feature_usage` | Uso de feature no app | feature_name, engagement_time_msec |

## Dimensões de tráfego

- **traffic_source** (utm_source ou default)
- **traffic_medium** (utm_medium ou default)
- **traffic_campaign** (utm_campaign)
- **device_category** (desktop / mobile / tablet)
- **geo_country** (país)

Garantir que UTM seja preenchido em campanhas pagas e que o GTM envie esses campos nos eventos relevantes.

## User ID e sessão

- **user_id**: enviar quando o usuário estiver identificado (login ou identificador persistente).
- **session_id**: mantido pelo GA4; em export BigQuery corresponde ao conceito de sessão do GA4.

Para atribuição e tempo até conversão, a exportação para BigQuery permite cruzar eventos com CRM/contratos via user_id ou session_id conforme modelagem do projeto.

## Integração com BigQuery

- Ativar **exportação contínua** do GA4 para BigQuery (diária ou streaming).
- Datasets esperados: eventos em tabelas particionadas por data (ex.: `events_*`).
- Neste repositório, os dados são **mock** em CSV espelhando a estrutura esperada; em produção substituir pela exportação real.

## Próximos passos

- Implementar eventos e parâmetros no GTM conforme `03_taxonomia_eventos_parametros.md`.
- Validar com `04_checklist_gtm_ga4_qa.md`.
- Configurar link do GA4 ao BigQuery e replicar a modelagem (raw/trusted/analytics) sobre os eventos reais.
