CREATE TABLE "public"."gr_locations" (
	"coordinate_id" varchar(32) COLLATE "default",
    "transaction_id" varchar(32) COLLATE "default",
	"project_name" text COLLATE "default",
	"beneficiary_name" text COLLATE "default",
	"description" text COLLATE "default",
	"operational_programe" text COLLATE "default",
	"thematical_priority" text COLLATE "default",
	"nr_of_subprojects" numeric,
	"budget" numeric,
	"contracts" numeric,
	"payments" numeric,
	"start_date" date,
	"end_date" date,
	"region" varchar(32) COLLATE "default",
	"lau1_code" varchar(32) COLLATE "default",
	"project_lat" numeric,
	"project_long" numeric
)
WITH (OIDS=FALSE);