WITH distribution AS (
	SELECT 
		f.*,
		SUBSTRING(COALESCE(p.shape_lau, d.shape_lau),0,6) AS nuts3,
		COALESCE(p.shape_lau, d.shape_lau) AS shape_lau,
		COALESCE(p.name, d.name) AS city_name,
		CASE WHEN p.name IS NOT NULL THEN FALSE ELSE TRUE END AS distributed2,
		CASE WHEN p.name IS NOT NULL THEN 'geocoded' ELSE 'nuts2' END AS distribution_type,
		CASE 
			WHEN d.shape_lau IS NOT NULL THEN (d.population::INT * 1.0) / sum(d.population::INT) OVER (PARTITION BY transaction_id)
			ELSE 1
		END AS population_multiplier
	FROM final AS f
	LEFT JOIN geocode_result AS g ON f.beneficiary_id = g.beneficiary_id
	LEFT JOIN "1_population" AS p ON p.shape_lau LIKE 'DE%' AND p.lau = g.lau 
	LEFT JOIN "1_population" AS d ON p.shape_lau IS NULL AND d.shape_lau LIKE 'DE%' AND d.shape_lau LIKE f.project_nuts2 || '%'
	WHERE f.project_lau2 IS NULL
),
vw AS (
	SELECT
		md5('DE' || transaction_id) AS transaction_id,
		project_name,
		beneficiary_name,
	  total_ammount,
		eu_cofinancing_amount * population_multiplier AS eu_cofinancing_amount,
		amount * population_multiplier AS amount,
		amount_kind,
		beneficiary_country_code,
		beneficiary_id,
		fund_acronym,
		funding_period,
		geocoding_state,
		beneficiary_postal_code,
		beneficiary_lau2,
		project_state,
		project_region,
		project_county,
		city_name AS project_city,
		project_nuts2,
		nuts3 AS project_nuts3,
		shape_lau AS project_lau2,
		project_postal_code,
		project_address,
	  contract_date,
		end_date,
		distribution_type,
		distributed2 AS distributed
	FROM distribution
	UNION ALL
		SELECT
		md5('DE' || transaction_id) AS transaction_id,
		project_name,
		beneficiary_name,
	  total_ammount,
		eu_cofinancing_amount AS eu_cofinancing_amount,
		amount AS amount,
		amount_kind,
		beneficiary_country_code,
		beneficiary_id,
		fund_acronym,
		funding_period,
		geocoding_state,
		beneficiary_postal_code,
		beneficiary_lau2,
		project_state,
		project_region,
		project_county,
		project_city,
		project_nuts2,
		project_nuts3,
		project_lau2,
		project_postal_code,
		project_address,
	  contract_date,
		end_date,
		'lau2' AS distribution_type,
		FALSE AS distributed
	FROM final
	WHERE project_lau2 IS NOT NULL
)
SELECT * INTO final2 FROM vw;