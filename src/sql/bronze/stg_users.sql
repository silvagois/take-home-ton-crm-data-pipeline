'''
- As tabelas não estão particionadas, mas num cenário produtivo dentro do Bigquery podemos fazer a criação destas
particionando-as por alguma coluna dependeno da regra de cada tabela, ou por data ou por alguma outra coluna de negocio, 
além de usar clusterização caso necessário
'''

CREATE OR REPLACE
TABLE bronze.stg_users AS
SELECT
	user_id,
	LOWER(TRIM(email)) AS email_normalized,
	REGEXP_REPLACE(phone, '\D', '', 'g') as phone_normalized,
	CASE
		WHEN LENGTH(REGEXP_REPLACE(phone, '\D', '', 'g')) BETWEEN 10 AND 13
	  THEN REGEXP_REPLACE(phone, '\D', '', 'g')
		ELSE NULL
	END AS phone_normalized_validation,
	conversion_at AT TIME ZONE 'America/Sao_Paulo' AS conversion_at
FROM
	raw.crm_user_base;