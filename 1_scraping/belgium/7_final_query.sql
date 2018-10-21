INSERT INTO "transaction" ("transaction_id","country","country_code","project_name","beneficiary_name","beneficiary_country_code","fund_acronym","fund_period","geolocation_in_source","distributed","contract_date","start_date","end_date")
SELECT distinct
	"transaction_id",
	'Belgium' AS "country",
	'BE' AS "country_code",
	"project_name",
	"beneficiary_name",
	"beneficiary_country_code",
	"fund_acronym",
	funding_period AS "fund_period",
	"geolocation_in_source",
	"distributed",
	"contract_date",
	"start_date",
	"end_date"
FROM final;


INSERT INTO "address" ("address_id","address_type","nuts1_name","nuts1_code","nuts2_name","nuts2_code","nuts3_name","nuts3_code","lau1_name","lau1_code","lau2_name","lau2_code","postal_code","address","lat","long")
SELECT distinct
	MD5(COALESCE(project_state, '') || COALESCE(project_region, '') || COALESCE(project_county, '') || COALESCE(project_city, '') || COALESCE("project_lau2", '')) AS "address_id",
	'project' AS "address_type",
	project_state AS "nuts1_name",
	NULL AS "nuts1_code",
	NULL AS "nuts2_name",
	NULL AS "nuts2_code",
	NULL AS "nuts3_name",
	NULL AS "nuts3_code",
	NULL AS "lau1_name",
	NULL AS "lau1_code",
	project_city AS "lau2_name",
	"project_lau2" AS "lau2_code",
	NULL AS "postal_code",
	NULL AS "address",
	NULL::numeric AS "lat",
	NULL::numeric AS "long"
FROM final;


INSERT INTO "transaction_amount" ("transaction_id","address_id","total_amount","eu_cofinancing_amount","amount","amount_kind")
SELECT 
	"transaction_id",
	MD5(COALESCE(project_state, '') || COALESCE(project_region, '') || COALESCE(project_county, '') || COALESCE(project_city, '') || COALESCE("project_lau2", '')) AS "address_id",
	"total_ammount" AS "total_amount",
	"eu_cofinancing_amount",
	"amount",
	"amount_kind"
FROM final;

