CREATE OR REPLACE
TABLE bronze.stg_sfmc_email AS
SELECT
	event_id,
	LOWER(TRIM(user_email)) AS email_normalized,
	event_timestamp AT TIME ZONE 'America/Sao_Paulo' AS event_at,
	TRIM(event_type) as event_type,
	LOWER(json_extract_string(message_details, '$.campaign_code')) AS campaign_code
FROM
	raw.raw_sfmc_email_logs
WHERE
	json_valid(message_details);