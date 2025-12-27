-- Todas as tabelas raw foram criadas localmente apartir dos arquivos csv compartilhados para o desafio
CREATE TABLE raw_sfmc_email_logs AS 
FROM read_csv_auto('path_arquivo.csv',header=True, sep=',');

CREATE TABLE raw_whatsapp_provider AS 
SELECT * FROM read_csv_auto('path_arquivo.csv',header=True, sep=',');

CREATE TABLE crm_user_base AS 
SELECT * FROM read_csv_auto('path_arquivo.csv',header=True, sep=',');