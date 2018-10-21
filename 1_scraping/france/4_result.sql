\cd :filepath
\copy transaction TO '5_transaction.csv' WITH DELIMITER ',' QUOTE '"' CSV HEADER;
\copy transaction_amount TO '5_transaction_amount.csv' WITH DELIMITER ',' QUOTE '"' CSV HEADER;
\copy address TO '5_address.csv' WITH DELIMITER ',' QUOTE '"' CSV HEADER;