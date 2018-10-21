source 2_local_db_cred.sh && psql -f 2_table_transactions.sql && psql -v filepath=$(PWD) -f 2_load_transactions.sql
