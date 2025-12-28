'''
- As tabelas não estão particionadas, mas num cenário produtivo dentro do Bigquery podemos fazer a criação destas
particionando-as por alguma coluna dependeno da regra de cada tabela, ou por data ou por alguma outra coluna de negocio, 
além de usar clusterização caso necessário
'''

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