/*SELECT DISTINCT
	beneficiary_id,
	'ES' AS query_country_code,
	'España' AS query_country,
	'beneficiary' AS query_type,
	NULL AS query_state,
	NULL AS "query_region",
	NULL AS "query_county",
	NULL AS "query_city",
	NULL AS "query_postal_code",
	NULL AS "query_address"
FROM final as t
WHERE project_lau2 is null
UNION*/
SELECT DISTINCT
	project_name AS beneficiary_id,
	'ES' AS query_country_code,
	'España' AS query_country,
	'project' AS query_type,
	NULL AS query_state,
	NULL AS "query_region",
	NULL AS "query_county",
	NULL AS "query_city",
	NULL AS "query_postal_code",
	NULL AS "query_address"
FROM final as t
WHERE project_lau2 is null