INSERT INTO "transaction" (
	"transaction_id",
	"country",
	"country_code",
	"project_name",
	"beneficiary_name",
	"beneficiary_country_code",
	"fund_acronym",
	"fund_period",
	"geolocation_in_source",
	"distributed",
	"contract_date",
	"start_date",
	"end_date")
SELECT DISTINCT
	"transaction_id",
	"country",
	"country_code",
	"project_name",
	"beneficiary_name",
	'DK' AS "beneficiary_country_code",
	"fund_acronym",
	funding_period AS "fund_period",
	"geolocation_in_source",
	"distributed",
	NULL::date AS contract_date,
	start_date,
	end_date
FROM final;


INSERT INTO "address" (
	"address_id",
	"address_type",
	"nuts1_name",
	"nuts1_code",
	"nuts2_name",
	"nuts2_code",
	"nuts3_name",
	"nuts3_code",
	"lau1_name",
	"lau1_code",
	"lau2_name",
	"lau2_code",
	"postal_code",
	"address",
	"lat",
	"long")
SELECT DISTINCT
	MD5(COALESCE(f.project_city, '') || COALESCE(f.project_lau2, '')) AS "address_id",
	'project' AS "address_type",
	p.nuts1_name AS "nuts1_name",
	p.nuts1_code AS "nuts1_code",
	p.nuts2_name AS "nuts2_name",
	p.nuts2_code AS "nuts2_code",
	p.nuts3_name AS "nuts3_name",
	p.nuts3_code AS "nuts3_code",
	p.lau1_name AS "lau1_name",
	p.lau1_code AS "lau1_code",
	f.project_city AS "lau2_name",
	f.project_lau2 AS "lau2_code",
	NULL AS "postal_code",
	NULL AS "address",
	NULL::numeric AS "lat",
	NULL::numeric AS "long"
FROM final AS f
INNER JOIN dk_population AS p ON f.project_lau2 = p.lau2_code;


INSERT INTO "transaction_amount" (
	"transaction_id",
	"address_id",
	"total_amount",
	"eu_cofinancing_amount",
	"amount",
	"amount_kind")
SELECT 
	"transaction_id",
	MD5(COALESCE(project_city, '') || COALESCE(project_lau2, '')) AS "address_id",
	"total_amount",
	"eu_cofinancing_amount",
	"amount",
	"amount_kind"
FROM final;