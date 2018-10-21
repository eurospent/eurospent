SELECT DISTINCT
	beneficiary_id,
	'HU' AS query_country_code,
	'Hungary' AS query_country,
	'project' AS query_type,
	NULL AS query_state,
	NULL AS "query_region",
	project_county AS "query_county",
	NULL AS "query_city",
	NULL AS "query_postal_code",
	NULL AS "query_address"
FROM final as t
WHERE project_lau2 is null