SELECT DISTINCT
	NULL AS beneficiary_id,
	'NL' AS query_country_code,
	'Netherlands' AS query_country,
	'coordinate' AS query_type,
	NULL AS query_state,
	NULL AS "query_region",
	NULL AS "query_county",
	NULL AS "query_city",
	NULL AS "query_postal_code",
	NULL AS "query_address",
	lat AS result_lat,
	long AS result_long,
	TRUE AS geocoded
FROM vw_nl_union as t
WHERE shape_lau IS NULL AND lat IS NOT NULL
AND long >= 3.358333 AND long <= 7.227778
AND lat >= 50.750417 AND lat <= 53.555

UNION ALL

SELECT DISTINCT
	loc AS beneficiary_id,
	'NL' AS query_country_code,
	'Netherlands' AS query_country,
	'location' AS query_type,
	NULL AS query_state,
	NULL AS "query_region",
	NULL AS "query_county",
	NULL AS "query_city",
	NULL AS "query_postal_code",
	NULL AS "query_address",
	NULL::NUMERIC AS result_lat,
	NULL::NUMERIC AS result_long,
	FALSE AS geocoded
FROM vw_nl_union as t
WHERE shape_lau IS NULL AND 
(
	(
		lat IS NOT NULL
		AND (long < 3.358333 OR long > 7.227778)
		AND (lat < 50.750417 OR lat > 53.555)
		AND loc IS NOT NULL
	)
	OR (
		lat IS NULL AND
		loc IS NOT NULL
	)
)

UNION ALL

SELECT DISTINCT
	beneficiary_name AS beneficiary_id,
	'NL' AS query_country_code,
	'Netherlands' AS query_country,
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
FROM vw_nl_union as t
WHERE shape_lau IS NULL AND 
(
	(
		lat IS NOT NULL
		AND (long < 3.358333 OR long > 7.227778)
		AND (lat < 50.750417 OR lat > 53.555)
		AND loc IS NULL
	)
	OR (
		lat IS NULL AND
		loc IS NULL
	)
)
