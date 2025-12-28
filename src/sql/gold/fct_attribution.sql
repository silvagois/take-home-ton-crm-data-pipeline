'''
- Através desta tabela fato, podemos responder a pergunta, Qual campanha gerou esta conversão, que é o entregável desta solução

'''

CREATE OR REPLACE
TABLE gold.fct_attribution AS
WITH eligible AS (
SELECT
	i.*,
	u.conversion_at
FROM
	silver.user_interactions i
JOIN bronze.stg_users u
		USING (user_id)
WHERE
	u.conversion_at IS NOT NULL
	AND i.event_at BETWEEN
        u.conversion_at - INTERVAL 7 DAY
        AND u.conversion_at
),
ranked AS (
SELECT
	*,
	ROW_NUMBER() OVER (
      PARTITION BY user_id
ORDER BY
	DATE(event_at) DESC,
	interaction_weight ASC,
	event_at DESC
    ) AS rn
FROM
	eligible
)
SELECT
	user_id,
	campaign_code,
	channel,
	interaction_type,
	event_at,
	conversion_at
FROM
	ranked
WHERE
	rn = 1;