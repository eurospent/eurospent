#echo 'CREATE TABLE'
#source 1_db_cred.sh && psql -f 1_table.sql

#echo 'Belgium'
#source 1_db_cred.sh && psql -v filepath=$(PWD)/data/belgium -f 1_load.sql

#echo 'Finland'
#source 1_db_cred.sh && psql -v filepath=$(PWD)/data/finland -f 1_load.sql

#echo 'Luxembourg'
#source 1_db_cred.sh && psql -v filepath=$(PWD)/data/luxembourg -f 1_load.sql

#echo 'Netherlands'
#source 1_db_cred.sh && psql -v filepath=$(PWD)/data/netherlands -f 1_load.sql

#echo 'France'
#source 1_db_cred.sh && psql -v filepath=$(PWD)/data/france -f 1_load.sql

#echo 'Germany'
#source 1_db_cred.sh && psql -v filepath=$(PWD)/data/germany -f 1_load.sql

#echo 'Italy'
#source 1_db_cred.sh && psql -v filepath=$(PWD)/data/italy -f 1_load.sql

#echo 'Poland'
#source 1_db_cred.sh && psql -v filepath=$(PWD)/data/poland -f 1_load.sql

echo 'Spain'
source 1_db_cred.sh && psql -v filepath=$(PWD)/data/spain -f 1_load.sql
