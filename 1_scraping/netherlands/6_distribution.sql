INSERT INTO public.final (transaction_id,project_name,beneficiary_name,total_ammount,eu_cofinancing_amount,amount,amount_kind,beneficiary_country_code,beneficiary_id,fund_acronym,funding_period,geocoding_state,beneficiary_postal_code,beneficiary_lau2,project_state,project_region,project_county,project_city,project_nuts3,project_lau2,project_postal_code,project_address,start_date,end_date,geolocation_in_source,distributed)
WITH join_loc AS (
	SELECT b.*,
		COALESCE(b.shape_lau, p.shape_lau) AS fixed_shape_lau,
		COALESCE(p.name, b.loc) AS fixed_loc,
		CASE 
			WHEN b.shape_lau IS NOT NULL THEN 'lau2'
			ELSE 'geocoded'
		END AS geolocation_in_source,
		FALSE AS distributed
	FROM vw_nl_union AS b
	LEFT JOIN geocode_result AS g ON b.shape_lau IS NULL AND g.query_type = 'coordinate' AND g.result_lat = b.lat AND g.result_long = b.long
	LEFT JOIN geocode_result AS g2 ON b.shape_lau IS NULL AND g.lau IS NULL AND g2.query_type = 'location' AND b.loc = g2.beneficiary_id
	LEFT JOIN geocode_result AS g3 ON b.shape_lau IS NULL AND g.lau IS NULL AND g2.lau IS NULL AND g3.query_type = 'beneficiary' AND b.beneficiary_name = g3.beneficiary_id
	LEFT JOIN (
		SELECT 'DeSah B.V.' AS beneficiary_id, '1900' AS lau UNION
		SELECT 'Stichting Het Zeeuwse Landschap' AS beneficiary_id, '0664' AS lau UNION
		SELECT 'Recreatieschap Drenthe' AS beneficiary_id, '1701' AS lau UNION
		SELECT 'Regionaal Bureau voor Toerisme Arnhem Nijmegen' AS beneficiary_id, '1734' AS lau UNION
		SELECT 'Stg Syntens' AS beneficiary_id, '0356' AS lau UNION
		SELECT 'Winc West Brabant B.V. i.o.' AS beneficiary_id, '0758' AS lau UNION
		SELECT 'Gemeente Helmond Projectbureau' AS beneficiary_id, '0794' AS lau UNION
		SELECT 'Hulphond Nederland' AS beneficiary_id, '0828' AS lau UNION
		SELECT 'Oosterschelde Tidal Power 2 B.V. vanuit OPZuid' AS beneficiary_id, '0717' AS lau
	) AS g4 ON b.shape_lau IS NULL AND g.lau IS NULL AND g2.lau IS NULL AND g3.lau IS NULL AND b.beneficiary_name = g4.beneficiary_id
	LEFT JOIN "1_population" AS p ON p.shape_lau LIKE 'NL%' AND COALESCE(g.lau, g2.lau, g3.lau, g4.lau) = p.lau
),
vw AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
	  full_amount AS total_ammount,
		eu_amount AS eu_cofinancing_amount,
		eu_amount AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'NL' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS geocoding_state,
		NULL AS beneficiary_postal_code,
		NULL AS beneficiary_lau2,
		NULL AS project_state,
		NULL AS project_region,
		NULL AS project_county,
		fixed_loc AS project_city,
		NULL AS project_nuts3,
		fixed_shape_lau AS project_lau2,
		NULL AS project_postal_code,
		NULL AS project_address,
	    start_date AS start_date,
		end_date AS end_date,
		geolocation_in_source,
		distributed
	FROM join_loc
	WHERE (program IS NULL OR program != 'INTERREG') OR (program = 'INTERREG' AND fixed_shape_lau IS NOT NULL)
)
SElECT * FROM vw

