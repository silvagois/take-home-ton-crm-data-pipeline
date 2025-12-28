'''
- Todas as tabelas raw foram criadas localmente apartir dos arquivos csv compartilhados para o desafio
- Para esse desafio usei DuckDb + Dbeaver
- Caso necessitem criar essas tabelas no DuckDb + Dbeaver é so colocar o path dos arquivos csv no campo path_arquivo.csv
'''
CREATE TABLE raw_sfmc_email_logs AS 
FROM read_csv_auto('path_arquivo.csv',header=True, sep=',');

CREATE TABLE raw_whatsapp_provider AS 
SELECT * FROM read_csv_auto('path_arquivo.csv',header=True, sep=',');

CREATE TABLE crm_user_base AS 
SELECT * FROM read_csv_auto('path_arquivo.csv',header=True, sep=',');