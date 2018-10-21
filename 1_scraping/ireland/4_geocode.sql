SELECT DISTINCT
    beneficiary_id,
	'IE' AS query_country_code,
	'Ireland' AS query_country,
	'project' AS query_type,
	NULL AS query_state,
	NULL AS "query_region",
	NULL AS "query_county",
	NULL AS "query_city",
	NULL AS "query_postal_code",
	NULL AS "query_address"
FROM ie_final as t
WHERE project_lau2 is NULL;