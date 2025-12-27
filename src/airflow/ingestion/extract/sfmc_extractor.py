import csv
from ingestion.utils.logger import get_logger

logger = get_logger()

EXTRACTED_FILE = "/tmp/sfmc_email_extracted.csv"

def extract_sfmc_email_logs():
    """
    Simula extração via API do Salesforce Marketing Cloud
    """
    logger.info("Starting SFMC email logs extraction")

    # Simulação da resposta da API
    fake_api_response = [
        {
            "event_id": "evt_001",
            "user_email": "camila.nunes@gmail.com",
            "event_timestamp": "2023-09-05T19:40:02Z",
            "event_type": "open",
            "message_details": '{"campaign_code": "CASHBACK_OFFER"}'
        },
        {
            "event_id": "evt_002",
            "user_email": "ana.souza@yahoo.com.br",
            "event_timestamp": "2023-11-16T17:25:44Z",
            "event_type": "sent",
            "message_details": '{"campaign_code": "BROKEN_JSON"'
        }
    ]

    with open(EXTRACTED_FILE, "w") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=fake_api_response[0].keys()
        )
        writer.writeheader()
        writer.writerows(fake_api_response)

    logger.info(f"Extraction finished: {EXTRACTED_FILE}")
