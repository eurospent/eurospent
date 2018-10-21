CREATE TABLE "public"."transaction" (
    "transaction_id" varchar(32) COLLATE "default",
    "country" varchar(20) COLLATE "default",
    "country_code" varchar(2) COLLATE "default",
    "project_name" text COLLATE "default",
    "beneficiary_name" text COLLATE "default",
    "beneficiary_country_code" varchar(2) COLLATE "default",
    "fund_acronym" varchar(10) COLLATE "default",
    "fund_period" varchar(20) COLLATE "default",
    "geolocation_in_source" varchar(30) COLLATE "default",
    "distributed" bool,
    "contract_date" date,
    "start_date" date,
    "end_date" date
)
WITH (OIDS=FALSE);

CREATE TABLE "public"."address" (
    "address_id" varchar(32) COLLATE "default",
    "address_type" varchar(15) COLLATE "default", -- Values: 'beneficiary', 'project',
    "nuts1_name" varchar(100) COLLATE "default",
    "nuts1_code" varchar(20) COLLATE "default",
    "nuts2_name" varchar(100) COLLATE "default",
    "nuts2_code" varchar(20) COLLATE "default",
    "nuts3_name" varchar(100) COLLATE "default",
    "nuts3_code" varchar(20) COLLATE "default",
    "lau1_name" varchar(100) COLLATE "default",
    "lau1_code" varchar(40) COLLATE "default",
    "lau2_name" varchar(100) COLLATE "default",
    "lau2_code" varchar(40) COLLATE "default",
    "postal_code" varchar(100) COLLATE "default",
    "address" text COLLATE "default",
    "lat" numeric,
    "long" numeric
)
WITH (OIDS=FALSE);

CREATE TABLE "public"."transaction_amount" (
    "transaction_id" varchar(32) COLLATE "default",
    "address_id" varchar(32) COLLATE "default",
    "total_amount" numeric,
    "eu_cofinancing_amount" numeric,
    "amount" numeric,
    "amount_kind" varchar(30) COLLATE "default"
)
WITH (OIDS=FALSE);