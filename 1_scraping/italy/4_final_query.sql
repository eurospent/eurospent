INSERT INTO "transaction" ("transaction_id","country","country_code","project_name","beneficiary_name","beneficiary_country_code","fund_acronym","fund_period","geolocation_in_source","distributed","contract_date","start_date","end_date")
SELECT distinct
	"transaction_id",
	'Italy' AS "country",
	'IT' AS "country_code",
	"project_name",
	"beneficiary_name",
	"beneficiary_country_code",
	"fund_acronym",
	funding_period AS "fund_period",
	"geolocation_in_source",
	"distributed",
	NULL::DATE AS "contract_date",
	NULL::DATE AS "start_date",
	NULL::DATE AS "end_date"
FROM it_final;

INSERT INTO "address" ("address_id","address_type","nuts1_name","nuts1_code","nuts2_name","nuts2_code","nuts3_name","nuts3_code","lau1_name","lau1_code","lau2_name","lau2_code","postal_code","address","lat","long")
SELECT distinct
	MD5('IT_project' || COALESCE(project_state, '') || COALESCE(project_region, '') || COALESCE(project_county, '') || COALESCE(project_city, '') || COALESCE(project_lau2, '') || COALESCE(project_postal_code, '') || COALESCE(project_address, '')) AS "address_id",
	'project' AS "address_type",
	project_state AS "nuts1_name",
	NULL AS "nuts1_code",
	project_region AS "nuts2_name",
	NULL AS "nuts2_code",
	project_county AS "nuts3_name",
	NULL AS "nuts3_code",
	NULL AS "lau1_name",
	NULL AS "lau1_code",
	project_city AS "lau2_name",
	project_lau2 AS "lau2_code",
	project_postal_code AS "postal_code",
	project_address AS "address",
	NULL::numeric AS "lat",
	NULL::numeric AS "long"
FROM it_final
WHERE COALESCE(project_state,project_region,project_county,project_city,project_lau2,project_postal_code,project_address) IS NOT NULL
UNION ALL 
SELECT distinct
	MD5('IT_beneficiary' || COALESCE(beneficiary_lau2, '') || COALESCE(beneficiary_postal_code, '')) AS "address_id",
	'beneficiary' AS "address_type",
	NULL AS "nuts1_name",
	NULL AS "nuts1_code",
	NULL AS "nuts2_name",
	NULL AS "nuts2_code",
	NULL AS "nuts3_name",
	NULL AS "nuts3_code",
	NULL AS "lau1_name",
	NULL AS "lau1_code",
	NULL AS "lau2_name",
	beneficiary_lau2 AS "lau2_code",
	beneficiary_postal_code AS "postal_code",
	NULL AS "address",
	NULL::numeric AS "lat",
	NULL::numeric AS "long"
FROM it_final
WHERE beneficiary_postal_code IS NOT NULL OR beneficiary_lau2 IS NOT NULL
;

INSERT INTO "transaction_amount" ("transaction_id","address_id","total_amount","eu_cofinancing_amount","amount","amount_kind")
SELECT 
	"transaction_id",
	MD5('IT_project' || COALESCE(project_state, '') || COALESCE(project_region, '') || COALESCE(project_county, '') || COALESCE(project_city, '') || COALESCE(project_lau2, '') || COALESCE(project_postal_code, '') || COALESCE(project_address, '')) AS "address_id",
	"total_ammount" AS "total_amount",
	"eu_cofinancing_amount",
	"amount",
	"amount_kind"
FROM it_final
WHERE COALESCE(project_state,project_region,project_county,project_city,project_lau2,project_postal_code,project_address) IS NOT NULL
UNION ALL
SELECT 
	"transaction_id",
	MD5('IT_beneficiary' || COALESCE(beneficiary_lau2, '') || COALESCE(beneficiary_postal_code, '')) AS "address_id",
	NULL AS "total_amount",
	NULL AS "eu_cofinancing_amount",
	NULL AS "amount",
	NULL AS "amount_kind"
FROM it_final
WHERE beneficiary_postal_code IS NOT NULL OR beneficiary_lau2 IS NOT NULL;

