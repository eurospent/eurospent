INSERT INTO beneficiary_geocode (beneficiary_id,query_country_code,query_country,query_type,query_state,query_region,query_county,query_city,query_postal_code,query_address)
SELECT DISTINCT
	beneficiary_id,
	country_code AS query_country_code,
	country AS query_country,
	'project' AS query_type,
	NULL AS query_state,
	NULL AS "query_region",
	NULL AS "query_county",
	NULL AS "query_city",
	NULL AS "query_postal_code",
	NULL AS "query_address"
FROM transactions as t
WHERE country = 'Portugal' and project_lau2 is null
;