# Checklist GTM e GA4 — auditoria e validação

Use este checklist para validar a implementação do Google Tag Manager (GTM) e do GA4 antes e após go-live.

## Configuração do container GTM

- [ ] Container publicado com versão descritiva
- [ ] Variáveis de primeira parte (domain, URL) configuradas
- [ ] Variáveis de camada de dados (dataLayer) definidas conforme taxonomia
- [ ] Tags de teste (preview) usadas em ambiente de homologação

## Tag GA4 (Configuration Tag)

- [ ] ID de medição (G-XXXXXXXXXX) correto
- [ ] Envio de user_id quando disponível (ex.: após login)
- [ ] Eventos padrão (page_view, session_start) não duplicados por tags customizadas

## Eventos customizados

- [ ] **form_start**: dispara no primeiro foco do formulário; parâmetros form_name e page_location
- [ ] **form_submit**: dispara no submit; parâmetros form_name, page_location; sem duplo envio (prevent default + send)
- [ ] **lead_generated**: dispara na thank-you ou via callback; value opcional
- [ ] **demo_requested**: dispara na confirmação de agendamento; value opcional
- [ ] **view_item**: dispara em páginas de solução/produto; page_location e item_id (se aplicável)
- [ ] **login** e **feature_usage**: implementados se escopo incluir app

## UTM e tráfego

- [ ] utm_source, utm_medium, utm_campaign mapeados (variáveis GTM ou GA4)
- [ ] Tráfego direto identificado como (direct) / none quando não houver UTM
- [ ] Campanhas pagas testadas com UTM e verificadas no GA4 em tempo real

## BigQuery (quando em uso)

- [ ] Link GA4 ↔ BigQuery ativado
- [ ] Dataset e tabelas de eventos com particionamento por data
- [ ] Teste de consulta sobre eventos exportados (event_name, event_params)

## QA geral

- [ ] Preview GTM ativo; verificação de disparos por evento em cada página crítica
- [ ] GA4 DebugView ou Relatórios em tempo real: eventos e parâmetros corretos
- [ ] Sem erros de console relacionados a GTM/GA4
- [ ] Consent mode (se aplicável) configurado e testado

## Referência

- Taxonomia: `03_taxonomia_eventos_parametros.md`
- Plano de mensuração: `02_plano_mensuracao_ga4.md`
