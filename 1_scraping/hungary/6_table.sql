CREATE TABLE "public"."final_with_geo" (
	"transaction_id" varchar(32) COLLATE "default",
	"country" varchar(20) COLLATE "default",
	"country_code" varchar(2) COLLATE "default",
	"project_name" text COLLATE "default",
	"beneficiary_name" text COLLATE "default",
	"total_amount" numeric,
	"eu_cofinancing_amount" numeric,
	"amount" numeric,
	"amount_kind" varchar(30) COLLATE "default",
	"beneficiary_country_code" varchar(2) COLLATE "default",
	"beneficiary_id" text COLLATE "default",
	"fund_acronym" varchar(10) COLLATE "default",
	"funding_period" varchar(20) COLLATE "default",
	"geocoding_state" varchar(10) COLLATE "default",
	"distributed" bool,
	"geolocation_in_source" varchar(30) COLLATE "default",
	"beneficiary_state" varchar(100) COLLATE "default",
	"beneficiary_region" varchar(100) COLLATE "default",
	"beneficiary_county" varchar(100) COLLATE "default",
	"beneficiary_nuts3" varchar(20) COLLATE "default",
	"beneficiary_city" varchar(100) COLLATE "default",
	"beneficiary_lau2" varchar(20) COLLATE "default",
	"beneficiary_postal_code" varchar(100) COLLATE "default",
	"beneficiary_address" text COLLATE "default",
	"beneficiary_lat" numeric,
	"beneficiary_long" numeric,
	"project_state" varchar(100) COLLATE "default",
	"project_region" varchar(100) COLLATE "default",
	"project_county" varchar(255) COLLATE "default",
	"project_nuts3" varchar(20) COLLATE "default",
	"project_city" varchar(100) COLLATE "default",
	"project_lau2" varchar(20) COLLATE "default",
	"project_postal_code" varchar(100) COLLATE "default",
	"project_address" varchar(200) COLLATE "default",
	"project_lat" numeric,
	"project_long" numeric
)
WITH (OIDS=FALSE);