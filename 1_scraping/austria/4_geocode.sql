SELECT DISTINCT
	beneficiary_id,
	'AT' AS query_country_code,
	'Austria' AS query_country,
	'project' AS query_type,
	project_state AS "query_state",
	project_region AS "query_region",
	NULL AS "query_county",
	NULL AS "query_city",
	NULL AS "query_postal_code",
	beneficiary_address AS "query_address"
FROM final as t
WHERE project_lau2 is null