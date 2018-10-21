\cd :filepath
\copy public.transaction (transaction_id,country,country_code,project_name,beneficiary_name,beneficiary_country_code,fund_acronym,fund_period,geolocation_in_source,distributed,contract_date,start_date,end_date) FROM 'transaction.csv' WITH DELIMITER ',' QUOTE '"' CSV HEADER;
\copy public.transaction_amount (transaction_id,address_id,total_amount,eu_cofinancing_amount,amount,amount_kind) FROM 'transaction_amount.csv' WITH DELIMITER ',' QUOTE '"' CSV HEADER;
\copy public.address (address_id,address_type,nuts1_name,nuts1_code,nuts2_name,nuts2_code,nuts3_name,nuts3_code,lau1_name,lau1_code,lau2_name,lau2_code,postal_code,address,lat,long) FROM 'address.csv' WITH DELIMITER ',' QUOTE '"' CSV HEADER;

