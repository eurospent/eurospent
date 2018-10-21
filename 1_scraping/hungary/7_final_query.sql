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
	"distributed")
SELECT DISTINCT
	"transaction_id",
	"country",
	"country_code",
	"project_name",
	"beneficiary_name",
	'HU' AS "beneficiary_country_code",
	"fund_acronym",
	funding_period AS "fund_period",
	"geolocation_in_source",
	"distributed"
FROM final_with_geo;


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
	"lat","long")
SELECT DISTINCT
	MD5('HU_project' || COALESCE(f.project_state, '') || COALESCE(f.project_region, '') || COALESCE(f.project_county, '') || COALESCE(f.project_nuts3, '') || COALESCE(f.project_city, '') || COALESCE(f.project_lau2, '') || COALESCE(f.project_postal_code, '') || COALESCE(f.project_address, '')) AS "address_id",
	'project' AS "address_type",
	p.nuts1_name,
	p.nuts1_code,
	p.nuts2_name,
	p.nuts2_code,
	p.nuts3_name,
	p.nuts3_code,
	p.lau1_name,
	p.lau1_code,
	f.project_city AS "lau2_name",
	f.project_lau2 AS "lau2_code",
	f.project_postal_code AS "postal_code",
	f.project_address AS "address",
	NULL::numeric AS "lat",
	NULL::numeric AS "long"
FROM final_with_geo AS f
INNER JOIN hu_population AS p ON f.project_lau2 = p.lau2_code
WHERE f.project_lau2 IS NOT NULL
UNION ALL 
SELECT DISTINCT
	MD5('HU_beneficiary' || COALESCE(f2.beneficiary_lau2, '') || COALESCE(f2.beneficiary_postal_code, '')) AS "address_id",
	'beneficiary' AS "address_type",
	p2.nuts1_name,
	p2.nuts1_code,
	p2.nuts2_name,
	p2.nuts2_code,
	p2.nuts3_name,
	p2.nuts3_code,
	p2.lau1_name,
	p2.lau1_code,
	p2.lau2_name,
	f2.beneficiary_lau2 AS "lau2_code",
	f2.beneficiary_postal_code AS "postal_code",
	f2.beneficiary_address AS "address",
	f2.beneficiary_lat::numeric AS "lat",
	f2.beneficiary_long::numeric AS "long"
FROM final_with_geo AS f2
INNER JOIN hu_population AS p2 ON f2.beneficiary_lau2 = p2.lau2_code
WHERE f2.beneficiary_lau2 IS NOT NULL;


INSERT INTO "transaction_amount" (
	"transaction_id",
	"address_id",
	"total_amount",
	"eu_cofinancing_amount",
	"amount",
	"amount_kind")
SELECT 
	"transaction_id",
	MD5('HU_project' || COALESCE(project_state, '') || COALESCE(project_region, '') || COALESCE(project_county, '') || COALESCE(project_nuts3, '') || COALESCE(project_city, '') || COALESCE("project_lau2", '') || COALESCE(project_postal_code, '') || COALESCE(project_address, '')) AS "address_id",
	"total_amount",
	"eu_cofinancing_amount",
	"amount",
	"amount_kind"
FROM final_with_geo
WHERE project_lau2 IS NOT NULL
UNION ALL
SELECT 
	"transaction_id",
	MD5('HU_beneficiary' || COALESCE(beneficiary_lau2, '') || COALESCE(beneficiary_postal_code, '')) AS "address_id",
	"total_amount",
	"eu_cofinancing_amount",
	"amount",
	"amount_kind"
FROM final_with_geo
WHERE beneficiary_lau2 IS NOT NULL;