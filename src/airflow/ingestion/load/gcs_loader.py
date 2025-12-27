from google.cloud import storage
from ingestion.utils.logger import get_logger

logger = get_logger()

BUCKET_NAME = "crm-raw-data"
DESTINATION_PATH = "sfmc/raw_sfmc_email_logs.csv"
LOCAL_FILE = "/tmp/sfmc_email_valid.csv"

def load_to_gcs():
    """
    Load do CSV validado para bucket RAW no GCS
    """
    logger.info("Starting load to GCS")

    client = storage.Client()
    bucket = client.bucket(BUCKET_NAME)
    blob = bucket.blob(DESTINATION_PATH)

    blob.upload_from_filename(LOCAL_FILE)

    logger.info(
        f"File uploaded to gs://{BUCKET_NAME}/{DESTINATION_PATH}"
    )
