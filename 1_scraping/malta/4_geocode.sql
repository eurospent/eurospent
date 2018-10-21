SELECT DISTINCT
	beneficiary_id,
	'MT' AS query_country_code,
	'Malta' AS query_country,
	'project' AS query_type,
	project_state AS "query_state",
	project_region AS "query_region",
	project_county AS "query_county",
	NULL AS "query_city",
	NULL AS "query_postal_code",
	NULL AS "query_address"
FROM final as t
WHERE project_lau2 is null