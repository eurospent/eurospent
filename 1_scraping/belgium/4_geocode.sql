SELECT DISTINCT
	NULL AS beneficiary_id,
	'BE' AS query_country_code,
	'Belgium' AS query_country,
	'coordinate' AS query_type,
	NULL AS query_state,
	NULL AS "query_region",
	NULL AS "query_county",
	NULL AS "query_city",
	NULL AS "query_postal_code",
	NULL AS "query_address",
	lat::NUMERIC AS result_lat,
	long::NUMERIC AS result_long,
	TRUE AS geocoded
FROM be_union2 as t
WHERE shape_lau IS NULL AND lat IS NOT NULL

UNION ALL

SELECT DISTINCT
	beneficiary_name AS beneficiary_id,
	'BE' AS query_country_code,
	'Belgium' AS query_country,
	'beneficiary' AS query_type,
	NULL AS query_state,
	NULL AS "query_region",
	NULL AS "query_county",
	NULL AS "query_city",
	NULL AS "query_postal_code",
	NULL AS "query_address",
	NULL::NUMERIC AS result_lat,
	NULL::NUMERIC AS result_long,
	FALSE AS geocoded
FROM be_union2 as t
WHERE shape_lau IS NULL AND lat IS NULL