CREATE OR REPLACE
TABLE silver.user_interactions AS
SELECT
	u.user_id,
	e.event_at,
	e.campaign_code,
	'email' AS channel,
	e.event_type AS interaction_type,
	CASE
		WHEN e.event_type = 'click' THEN 2
		WHEN e.event_type = 'open' THEN 3
		ELSE 4
	END AS interaction_weight
FROM
	bronze.stg_sfmc_email e
JOIN bronze.stg_users u
		USING (email_normalized)
UNION ALL

SELECT
	u.user_id,
	w.event_at,
	w.campaign_code,
	'whatsapp' AS channel,
	w.status AS interaction_type,
	CASE
		WHEN w.status = 'read' THEN 1
		WHEN w.status = 'delivered' THEN 4
		ELSE 5
	END AS interaction_weight
FROM
	bronze.stg_whatsapp w
JOIN bronze.stg_users u
		USING (phone_normalized);