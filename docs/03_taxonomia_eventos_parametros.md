# Taxonomia de eventos e parâmetros

## Convenção de nomenclatura

- **Eventos**: `snake_case`, em inglês, minúsculo (ex.: `form_start`, `lead_generated`).
- **Parâmetros**: `snake_case`, em inglês (ex.: `page_location`, `traffic_source`).
- **Valores**: preferir códigos ou IDs quando possível; labels em português apenas em dimensões de relatório, não em nomes de evento.

## Eventos utilizados no projeto

| Evento | Descrição | Parâmetros típicos |
|--------|-----------|--------------------|
| `page_view` | Visualização de página | page_location, page_title |
| `view_item` | Visualização de item/solução | page_location, item_id (opcional) |
| `form_start` | Início de preenchimento de formulário | form_name, page_location |
| `form_submit` | Envio de formulário | form_name, page_location |
| `lead_generated` | Lead criado (thank-you ou sync CRM) | value (opcional) |
| `demo_requested` | Demo agendada | value (opcional) |
| `login` | Login no app | method (opcional) |
| `feature_usage` | Uso de funcionalidade no app | feature_name, engagement_time_msec |

## Parâmetros comuns (dimensões de evento)

| Parâmetro | Tipo | Exemplo | Observação |
|-----------|------|---------|------------|
| page_location | string | https://autotech.com/demo | URL da página |
| page_title | string | Solicitar demo | Título da página |
| traffic_source | string | google, linkedin, (direct) | Origem do tráfego |
| traffic_medium | string | cpc, organic, referral | Meio |
| traffic_campaign | string | campaign_fleet_q4 | Campanha (utm_campaign) |
| device_category | string | desktop, mobile | Dispositivo |
| geo_country | string | BR | País |
| engagement_time_msec | number | 15000 | Tempo de engajamento em ms |
| value | number | 1 | Valor (conversão, receita simulada) |

## Exemplos de payload (GTM / GA4)

**form_submit (formulário de demo):**
```json
{
  "event": "form_submit",
  "page_location": "https://autotech.com/demo",
  "form_name": "demo_request",
  "traffic_source": "google",
  "traffic_medium": "cpc",
  "traffic_campaign": "campaign_fleet_q4"
}
```

**lead_generated (thank-you):**
```json
{
  "event": "lead_generated",
  "page_location": "https://autotech.com/thank-you",
  "value": 1
}
```

Consistência entre GA4, GTM e a estrutura dos CSVs/raw no BigQuery facilita a futura troca do mock pela exportação real.
