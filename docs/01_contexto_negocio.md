# Contexto de negócio — AutoTech B2B

## Cenário

A **AutoTech B2B** atua no mercado B2B com soluções de software e dados para três segmentos principais:

- **Frotas**: gestão de frotas, telemetria, manutenção e compliance.
- **Concessionárias**: CRM, vendas e pós-venda para redes de concessionárias.
- **Seguradoras**: dados e analytics para precificação e sinistros no setor auto.

O ciclo de venda típico passa por **tráfego digital (site/app) → lead (formulário) → solicitação de demo → negociação → contrato**. Canais de aquisição incluem Google (orgânico e paid), LinkedIn, parceiros e tráfego direto.

## Problema de negócio

- **Visibilidade fragmentada**: eventos de site (GA4), leads (CRM) e contratos (vendas) ficam em sistemas distintos, sem uma visão unificada de funil e atribuição.
- **Atribuição de conversão**: é difícil responder “qual canal trouxe este contrato?” e “quanto tempo leva da primeira visita ao fechamento?”.
- **Qualidade e governança**: decisões dependem de dados consistentes, com regras claras de modelagem e validação.

## Objetivos do projeto

1. **Unificar** dados de web (GA4), CRM (leads) e contratos em um único ambiente analítico (BigQuery).
2. **Modelar** em camadas (raw → trusted → analytics) para reprodutibilidade e governança.
3. **Medir** funil (sessões → lead → demo → contrato), performance por canal, atribuição simplificada (ex.: last non-direct) e tempo até conversão.
4. **Documentar** plano de mensuração GA4, taxonomia, checklist GTM/GA4 e arquitetura para uso em portfólio e alinhamento com times.

Este repositório **simula** esse fluxo com dados sintéticos, permitindo que qualquer pessoa com acesso ao GCP reproduza o pipeline sem depender de GA4 ou CRM reais.
