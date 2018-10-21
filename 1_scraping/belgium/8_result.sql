\cd :filepath
\copy transaction TO '9_transaction.csv' WITH DELIMITER ',' QUOTE '"' CSV HEADER;
\copy transaction_amount TO '9_transaction_amount.csv' WITH DELIMITER ',' QUOTE '"' CSV HEADER;
\copy address TO '9_address.csv' WITH DELIMITER ',' QUOTE '"' CSV HEADER;