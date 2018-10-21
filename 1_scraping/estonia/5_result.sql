\cd :filepath
\copy transaction TO '6_transaction.csv' WITH DELIMITER ',' QUOTE '"' CSV HEADER;
\copy transaction_amount TO '6_transaction_amount.csv' WITH DELIMITER ',' QUOTE '"' CSV HEADER;
\copy address TO '6_address.csv' WITH DELIMITER ',' QUOTE '"' CSV HEADER;