#!/usr/bin/env python3
"""
ETL: carrega CSVs (GA4 mock, CRM leads, contratos) para BigQuery.
Uso: python load_to_bigquery.py [--config CONFIG] [--dry-run]
Config via YAML: project_id, dataset_raw, csv_paths.
"""
import argparse
import logging
import os
import sys
from pathlib import Path

import pandas as pd
import yaml
from google.cloud import bigquery
from google.cloud.exceptions import NotFound

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

# Tipos BigQuery para cada tabela (para autodetect ou schema explícito)
SCHEMA_GA4 = [
    {"name": "event_date", "field_type": "DATE"},
    {"name": "event_timestamp", "field_type": "INTEGER"},
    {"name": "user_id", "field_type": "STRING"},
    {"name": "session_id", "field_type": "STRING"},
    {"name": "event_name", "field_type": "STRING"},
    {"name": "page_location", "field_type": "STRING"},
    {"name": "device_category", "field_type": "STRING"},
    {"name": "geo_country", "field_type": "STRING"},
    {"name": "traffic_source", "field_type": "STRING"},
    {"name": "traffic_medium", "field_type": "STRING"},
    {"name": "traffic_campaign", "field_type": "STRING"},
    {"name": "engagement_time_msec", "field_type": "INTEGER"},
    {"name": "value", "field_type": "FLOAT"},
]
SCHEMA_LEADS = [
    {"name": "lead_id", "field_type": "STRING"},
    {"name": "user_id", "field_type": "STRING"},
    {"name": "lead_created_at", "field_type": "TIMESTAMP"},
    {"name": "lead_source", "field_type": "STRING"},
    {"name": "company_size", "field_type": "STRING"},
    {"name": "segment", "field_type": "STRING"},
    {"name": "status", "field_type": "STRING"},
]
SCHEMA_CONTRACTS = [
    {"name": "contract_id", "field_type": "STRING"},
    {"name": "lead_id", "field_type": "STRING"},
    {"name": "contract_created_at", "field_type": "TIMESTAMP"},
    {"name": "plan_type", "field_type": "STRING"},
    {"name": "monthly_revenue", "field_type": "FLOAT"},
    {"name": "contract_term_months", "field_type": "INTEGER"},
]


def load_config(config_path: str) -> dict:
    path = Path(config_path)
    if not path.exists():
        raise FileNotFoundError(f"Arquivo de config não encontrado: {config_path}")
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def resolve_path(cfg: dict, key: str, base_dir: Path) -> Path:
    raw = cfg.get("csv_paths", {}).get(key, "")
    p = Path(raw)
    if not p.is_absolute():
        p = base_dir / p
    return p.resolve()


def load_csv(path: Path) -> pd.DataFrame:
    df = pd.read_csv(path)
    logger.info("CSV carregado: %s (%d linhas)", path.name, len(df))
    return df


def prepare_ga4(df: pd.DataFrame) -> pd.DataFrame:
    if "event_date" in df.columns and df["event_date"].dtype == object:
        df["event_date"] = pd.to_datetime(df["event_date"]).dt.date
    if "engagement_time_msec" in df.columns:
        df["engagement_time_msec"] = pd.to_numeric(df["engagement_time_msec"], errors="coerce").fillna(0).astype("Int64")
    return df


def prepare_leads(df: pd.DataFrame) -> pd.DataFrame:
    if "lead_created_at" in df.columns:
        df["lead_created_at"] = pd.to_datetime(df["lead_created_at"], utc=True)
    return df


def prepare_contracts(df: pd.DataFrame) -> pd.DataFrame:
    if "contract_created_at" in df.columns:
        df["contract_created_at"] = pd.to_datetime(df["contract_created_at"], utc=True)
    return df


def bq_schema_from_list(schema_list: list) -> list:
    return [bigquery.SchemaField(x["name"], x["field_type"]) for x in schema_list]


def load_to_bigquery(
    client: bigquery.Client,
    project_id: str,
    dataset_id: str,
    table_id: str,
    df: pd.DataFrame,
    schema_list: list,
    write_disposition: str = "WRITE_TRUNCATE",
    dry_run: bool = False,
) -> int:
    table_ref = f"{project_id}.{dataset_id}.{table_id}"
    if dry_run:
        logger.info("[DRY-RUN] Seria enviado para %s: %d linhas", table_ref, len(df))
        return len(df)
    job_config = bigquery.LoadJobConfig(
        schema=bq_schema_from_list(schema_list),
        write_disposition=write_disposition,
    )
    job = client.load_table_from_dataframe(df, table_ref, job_config=job_config)
    job.result()
    logger.info("Tabela carregada: %s (%d linhas)", table_ref, job.output_rows)
    return job.output_rows or len(df)


def main():
    parser = argparse.ArgumentParser(description="Carrega CSVs para BigQuery")
    parser.add_argument("--config", "-c", default="config.yaml", help="Caminho do YAML de configuração")
    parser.add_argument("--dry-run", action="store_true", help="Não gravar no BigQuery, apenas validar e logar")
    args = parser.parse_args()

    base_dir = Path(__file__).resolve().parent
    config_path = Path(args.config)
    if not config_path.is_absolute():
        config_path = base_dir / config_path

    try:
        cfg = load_config(str(config_path))
    except Exception as e:
        logger.error("Erro ao carregar config: %s", e)
        sys.exit(1)

    project_id = cfg.get("project_id") or ""
    dataset_raw = cfg.get("dataset_raw") or "raw"
    paths = cfg.get("csv_paths", {})
    tables = cfg.get("table_names", {})

    if not project_id or project_id == "seu-projeto-gcp":
        logger.error("Defina project_id no config (config.yaml).")
        sys.exit(1)

    os.environ["GOOGLE_CLOUD_PROJECT"] = project_id

    ga4_path = resolve_path(cfg, "ga4_events", base_dir)
    leads_path = resolve_path(cfg, "crm_leads", base_dir)
    contracts_path = resolve_path(cfg, "contracts", base_dir)

    for p in (ga4_path, leads_path, contracts_path):
        if not p.exists():
            logger.error("Arquivo não encontrado: %s", p)
            sys.exit(1)

    if args.dry_run:
        logger.info("Modo dry-run ativado: nenhum dado será gravado no BigQuery.")

    counts = {}
    try:
        df_ga4 = load_csv(ga4_path)
        counts["ga4"] = len(df_ga4)
        df_ga4 = prepare_ga4(df_ga4)

        df_leads = load_csv(leads_path)
        counts["leads"] = len(df_leads)
        df_leads = prepare_leads(df_leads)

        df_contracts = load_csv(contracts_path)
        counts["contracts"] = len(df_contracts)
        df_contracts = prepare_contracts(df_contracts)
    except Exception as e:
        logger.exception("Erro ao ler CSVs: %s", e)
        sys.exit(1)

    client = None
    if not args.dry_run:
        try:
            client = bigquery.Client(project=project_id)
        except Exception as e:
            logger.error("Erro ao criar cliente BigQuery (verifique auth): %s", e)
            sys.exit(1)

    # Carregar cada tabela
    try:
        load_to_bigquery(
            client,
            project_id,
            dataset_raw,
            tables.get("ga4_events", "raw_ga4_events"),
            df_ga4,
            SCHEMA_GA4,
            dry_run=args.dry_run,
        )
        load_to_bigquery(
            client,
            project_id,
            dataset_raw,
            tables.get("crm_leads", "raw_crm_leads"),
            df_leads,
            SCHEMA_LEADS,
            dry_run=args.dry_run,
        )
        load_to_bigquery(
            client,
            project_id,
            dataset_raw,
            tables.get("contracts", "raw_contracts"),
            df_contracts,
            SCHEMA_CONTRACTS,
            dry_run=args.dry_run,
        )
    except Exception as e:
        logger.exception("Erro ao carregar no BigQuery: %s", e)
        sys.exit(1)

    logger.info("Resumo: ga4=%d leads=%d contracts=%d", counts["ga4"], counts["leads"], counts["contracts"])
    if args.dry_run:
        logger.info("Dry-run concluído. Execute sem --dry-run para gravar.")


if __name__ == "__main__":
    main()
