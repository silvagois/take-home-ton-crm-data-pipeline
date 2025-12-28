'''
- As tabelas não estão particionadas, mas num cenário produtivo dentro do Bigquery podemos fazer a criação destas
particionando-as por alguma coluna dependeno da regra de cada tabela, ou por data ou por alguma outra coluna de negocio, 
além de usar clusterização caso necessário
'''

CREATE OR REPLACE
TABLE BRONZE.STG_WHATSAPP AS
SELECT
	MESSAGE_ID,
	REPLACE(PHONE_CLEAN::VARCHAR, '.', '') AS PHONE_NORMALIZED,
	SENT_AT_BRT AT TIME ZONE 'AMERICA/SAO_PAULO' AS EVENT_AT,
	STATUS,
	LOWER(TRIM(REPLACE(
	REPLACE(
		REPLACE(
			REPLACE(CAMPAIGN_TAG, '-', '_'),
			' ', '_'),
		'___', '_'),
	'[WA]_', ''))) AS CAMPAIGN_CODE
	-- DA PRA MELHORAR ISSO
FROM
	RAW.RAW_WHATSAPP_PROVIDER;