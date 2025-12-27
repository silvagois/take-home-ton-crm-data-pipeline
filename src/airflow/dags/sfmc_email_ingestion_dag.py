from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

from ingestion.extract.sfmc_extractor import extract_sfmc_email_logs
from ingestion.validation.json_quality_gate import validate_email_logs
from ingestion.load.gcs_loader import load_to_gcs

default_args = {
    "owner": "data-engineering",
    "retries": 1,
}

with DAG(
    dag_id="sfmc_email_raw_ingestion",
    start_date=datetime(2023, 10, 1),
    schedule_interval="@daily",
    catchup=False,
    default_args=default_args,
    tags=["sfmc", "ingestion", "raw"],
) as dag:

    extract_task = PythonOperator(
        task_id="extract_sfmc_email_logs",
        python_callable=extract_sfmc_email_logs,
    )

    validate_task = PythonOperator(
        task_id="validate_message_details_json",
        python_callable=validate_email_logs,
    )

    load_task = PythonOperator(
        task_id="load_raw_to_gcs",
        python_callable=load_to_gcs,
    )

    extract_task >> validate_task >> load_task
