\cd :filepath
\copy public.transactions (download_timeout,fund,link,loc,total_amount,title,beneficiary,field,depth,program,eu_amount,action,download_latency,download_slot) FROM '2_transactions.csv' WITH DELIMITER ',' QUOTE '"' CSV HEADER;

