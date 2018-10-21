INSERT INTO public.final (transaction_id,project_name,beneficiary_name,total_ammount,eu_cofinancing_amount,amount,amount_kind,beneficiary_country_code,beneficiary_id,fund_acronym,funding_period,geocoding_state,beneficiary_postal_code,beneficiary_lau2,project_state,project_region,project_county,project_city,project_nuts3,project_lau2,project_postal_code,project_address,contract_date,start_date,end_date,geolocation_in_source,distributed)
WITH 
loc AS (
	SELECT
		*
	FROM "1_population"
	WHERE shape_lau LIKE 'BE%'
),
base AS (
	SELECT 
		*,
		COALESCE(b.shape_lau, l.shape_lau, l2.shape_lau) AS new_shape_lau,
		COALESCE(b.loc_name, l.name, l2.name) AS new_loc_name,
		CASE 
			WHEN b.shape_lau IS NOT NULL THEN geolocation_in_source
			ELSE 'geocoded'
		END AS new_geolocation_in_source,
		CASE 
			WHEN b.shape_lau IS NOT NULL THEN distributed
			ELSE FALSE
		END AS new_distributed
	FROM be_union2 AS b
	LEFT JOIN geocode_result AS g ON b.shape_lau IS NULL AND b.lat IS NOT NULL AND g.lau IS NOT NULL AND g.beneficiary_id IS NULL AND b.lat::FLOAT = g.result_lat AND b.long::FLOAT = g.result_long
	LEFT JOIN loc AS l ON g.lau IS NOT NULL AND g.lau = l.lau
	LEFT JOIN geocode_result AS g2 ON b.shape_lau IS NULL AND b.lat IS NULL AND g2.lau IS NOT NULL AND g2.beneficiary_id IS NOT NULL AND g2.beneficiary_id = b.beneficiary_name
	LEFT JOIN loc AS l2 ON g2.lau IS NOT NULL AND g2.lau = l2.lau
),
v1 AS (
	SELECT 
		*
	FROM base AS b
	WHERE new_shape_lau IS NOT NULL
),
v1_final AS (
	SELECT 
			transaction_id,
			project_name,
			beneficiary_name,
			total_amount AS total_ammount,
			eu_amount AS eu_cofinancing_amount,
			eu_amount AS amount,
			'eu_cofinancing_amount' AS amount_kind,
			'BE' AS beneficiary_country_code,
			beneficiary_name AS beneficiary_id,
			fund AS fund_acronym,
			'2007-2013' AS funding_period,
			NULL AS geocoding_state,
			NULL AS beneficiary_postal_code,
			NULL AS beneficiary_lau2,
			nuts1 AS project_state,
			NULL AS project_region,
			NULL AS project_county,
			new_loc_name AS project_city,
			NULL AS project_nuts3,
			new_shape_lau AS project_lau2,
			NULL AS project_postal_code,
			NULL AS project_address,
			contract_date,
			start_date,
			end_date,
			new_geolocation_in_source AS geolocation_in_source,
			new_distributed AS distributed
	FROM v1
),
v2 AS (
	SELECT 
		b.*,
		p.shape_lau AS new_shape_lau2,
		p.name AS new_loc_name2,
		CASE 
			WHEN sum(p.population::INT) OVER (PARTITION BY transaction_id) IS NULL OR sum(p.population::INT) OVER (PARTITION BY transaction_id) = 0 THEN 1
			ELSE p.population::INT*1.0 / sum(p.population::INT) OVER (PARTITION BY transaction_id)
		END AS population_multiplier
	FROM base AS b
	LEFT JOIN loc AS p ON p.shape_lau LIKE 'BE3%'
	WHERE new_shape_lau IS NULL
),
v2_final AS (
	SELECT 
			transaction_id,
			project_name,
			beneficiary_name,
			population_multiplier * total_amount AS total_ammount,
			population_multiplier * eu_amount AS eu_cofinancing_amount,
			population_multiplier * eu_amount AS amount,
			'eu_cofinancing_amount' AS amount_kind,
			'BE' AS beneficiary_country_code,
			beneficiary_name AS beneficiary_id,
			fund AS fund_acronym,
			'2007-2013' AS funding_period,
			NULL AS geocoding_state,
			NULL AS beneficiary_postal_code,
			NULL AS beneficiary_lau2,
			nuts1 AS project_state,
			NULL AS project_region,
			NULL AS project_county,
			new_loc_name2 AS project_city,
			NULL AS project_nuts3,
			new_shape_lau2 AS project_lau2,
			NULL AS project_postal_code,
			NULL AS project_address,
			contract_date,
			start_date,
			end_date,
			'nuts1' AS geolocation_in_source,
			TRUE AS distributed
	FROM v2
),
vw AS (
	SELECT * FROM v1_final
	UNION ALL
	SELECT * FROM v2_final
)
SELECT * FROM vw;