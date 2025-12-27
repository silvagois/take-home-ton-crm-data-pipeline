import csv
import json
from ingestion.utils.logger import get_logger

logger = get_logger()

INPUT_FILE = "/tmp/sfmc_email_extracted.csv"
VALID_FILE = "/tmp/sfmc_email_valid.csv"

def is_valid_json(value: str) -> bool:
    try:
        json.loads(value)
        return True
    except json.JSONDecodeError:
        return False

def validate_email_logs():
    """
    Quality gate: bloqueia linhas com JSON quebrado
    """
    logger.info("Starting JSON quality validation")

    with open(INPUT_FILE) as infile, open(VALID_FILE, "w") as outfile:
        reader = csv.DictReader(infile)
        writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames)
        writer.writeheader()

        for row in reader:
            if is_valid_json(row["message_details"]):
                writer.writerow(row)
            else:
                logger.error(
                    f"Invalid JSON detected | event_id={row['event_id']}"
                )

    logger.info("JSON validation completed")
