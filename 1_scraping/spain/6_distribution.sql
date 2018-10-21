--CREATE INDEX final_project_name_gin  ON public.final USING gin (project_name gin_trgm_ops);

WITH 
population AS (
	SELECT 
		*,
		unaccent(name) AS u_name, 
		string_to_array(unaccent(name), ', ') AS name_arr
	FROM "1_population" 
	WHERE shape_lau LIKE 'ES%'
),
location_combinations AS (
	SELECT 
		u_name AS name,
		lau,
		shape_lau
	FROM population
	WHERE name NOT LIKE '%,%'
	UNION ALL
	SELECT 
		name_arr[2] || (CASE WHEN name_arr[2] LIKE E'%\'' THEN '' ELSE ' ' END) || name_arr[1] AS name,
		lau,
		shape_lau
	FROM population
	WHERE name LIKE '%,%'
	UNION ALL
	SELECT 
		name_arr[1] AS name,
		lau,
		shape_lau
	FROM population
	WHERE name LIKE '%,%'
),
nuts_words AS (
	SELECT 'galicia' AS nuts2_name, 'ES11' AS nuts2 UNION 
	SELECT 'asturias' AS nuts2_name, 'ES12' AS nuts2 UNION 
	SELECT 'cantabria' AS nuts2_name, 'ES13' AS nuts2 UNION 
	SELECT 'pais vasco' AS nuts2_name, 'ES21' AS nuts2 UNION 
	SELECT 'basque' AS nuts2_name, 'ES21' AS nuts2 UNION 
	SELECT 'navarre' AS nuts2_name, 'ES22' AS nuts2 UNION 
	SELECT 'rioja' AS nuts2_name, 'ES23' AS nuts2 UNION 
	SELECT 'aragon' AS nuts2_name, 'ES24' AS nuts2 UNION 
	SELECT 'madrid' AS nuts2_name, 'ES30' AS nuts2 UNION 
	SELECT 'castilla y leon' AS nuts2_name, 'ES41' AS nuts2 UNION 
	SELECT 'la mancha' AS nuts2_name, 'ES42' AS nuts2 UNION 
	SELECT 'extremadura' AS nuts2_name, 'ES43' AS nuts2 UNION 
	SELECT 'cataluna' AS nuts2_name, 'ES51' AS nuts2 UNION 
	SELECT 'valencian' AS nuts2_name, 'ES52' AS nuts2 UNION 
	SELECT 'baleares' AS nuts2_name, 'ES53' AS nuts2 UNION 
	SELECT 'andalucia' AS nuts2_name, 'ES61' AS nuts2 UNION 
	SELECT 'murcia' AS nuts2_name, 'ES62' AS nuts2 UNION 
	SELECT 'ceuta' AS nuts2_name, 'ES63' AS nuts2 UNION 
	SELECT 'melilla' AS nuts2_name, 'ES64' AS nuts2 UNION 
	SELECT 'canarias' AS nuts2_name, 'ES70' AS nuts2 
),
base AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		eu_cofinancing_amount,
		amount, 
		amount_kind,
		beneficiary_country_code,
		beneficiary_id,
		fund_acronym,
		funding_period,
		project_nuts2
	FROM public.final
),
nuts_fix AS (
	select b.*, COALESCE(project_nuts2, n.nuts2) AS fixed_project_nuts2
	FROM base AS b
	LEFT JOIN nuts_words AS n ON 
		(unaccent(b.project_name) ILIKE '%' || n.nuts2_name || '%' OR unaccent(b.beneficiary_name) ILIKE '%' || n.nuts2_name || '%')
		AND b.project_nuts2 IS NULL
),
beneficiary_aggregation AS (
	SELECT 
		beneficiary_id, 
		count(distinct transaction_id) AS transaction_count,
		sum(eu_cofinancing_amount) AS sum_amount, 
		(sum(eu_cofinancing_amount) * 1.0 / 48152396664) * 100 AS amount_percentage
	FROM nuts_fix
	GROUP BY beneficiary_id
),
transaction_aggregation AS (
	SELECT 
		transaction_id,
		eu_cofinancing_amount AS sum_amount, 
		(eu_cofinancing_amount * 1.0 / 48152396664) * 100 AS amount_percentage
	FROM base
),
project_identifiaction_transactions AS (
	SELECT f.*, project_nuts2 AS fixed_project_nuts2, g.lau AS found_lau, 'project_identification' AS transaction_type
	FROM base AS f
	INNER JOIN beneficiary_aggregation AS ba ON ba.transaction_count >= 10 AND f.beneficiary_id = ba.beneficiary_id
	INNER JOIN transaction_aggregation AS ta ON ta.amount_percentage < 0.1 AND f.transaction_id = ta.transaction_id
	INNER JOIN geocode_result AS g ON g.query_type = 'project' AND g.lau IS NOT NULL AND f.project_name = g.beneficiary_id
),
project_identifiaction_transactions_by_loc_name AS (
	SELECT f.*, project_nuts2 AS fixed_project_nuts2, loc.lau AS found_lau, 'project_identification_by_loc_name' AS transaction_type
	FROM base AS f
	INNER JOIN beneficiary_aggregation AS ba ON ba.transaction_count >= 10 AND f.beneficiary_id = ba.beneficiary_id
	INNER JOIN transaction_aggregation AS ta ON ta.amount_percentage < 0.1 AND f.transaction_id = ta.transaction_id
	INNER JOIN location_combinations AS loc	ON LENGTH(loc.name) >= 5 AND 
		(project_nuts2 IS NULL OR project_nuts2 = SUBSTRING(shape_lau, 0,5))
		AND
		(project_name ILIkE '% ' || loc.name || ' %' 
		OR project_name ILIKE loc.name || ' %' 
		OR project_name ILIKE '% ' || loc.name
		OR project_name ILIKE '%(' || loc.name || ')%' 
		OR project_name ILIKE '%(' || loc.name || ')')
	WHERE NOT EXISTS (SELECT 1 FROM project_identifiaction_transactions AS t WHERE f.transaction_id = t.transaction_id)
),
project_anonymised_transactions AS (
	SELECT 
		MIN(b.transaction_id) AS transaction_id,
		'proyecto anonimizado',
		beneficiary_id AS beneficiary_name,
		SUM(eu_cofinancing_amount) AS eu_cofinancing_amount,
		SUM(amount) AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'ES' AS beneficiary_country_code,
		beneficiary_id AS beneficiary_id,
		'ERDF' AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_nuts2,
		NULL AS fixed_project_nuts2,
		NULL AS found_lau, 
		'project_anonymised' AS transaction_type
	FROM nuts_fix AS b
	WHERE NOT EXISTS (SELECT 1 FROM project_identifiaction_transactions AS t WHERE b.transaction_id = t.transaction_id)
		AND NOT EXISTS (SELECT 1 FROM project_identifiaction_transactions_by_loc_name AS t4 WHERE b.transaction_id = t4.transaction_id)
		AND fixed_project_nuts2 IS NULL AND beneficiary_id IN ('UNIVERSIDAD NACIONAL DE EDUCACIÓN A DISTANCIA, UNED', 'Ministerio de Hacienda y Administraciones Públicas(Dirección General de 
Fondos Comunitarios)')
	GROUP BY b.beneficiary_id
),
top_beneficaries_transactions AS (
	SELECT b.*, NULL AS found_lau, 'top_distribution' AS transaction_type
	FROM nuts_fix AS b
	INNER JOIN beneficiary_aggregation AS ba ON b.beneficiary_id = ba.beneficiary_id AND ba.amount_percentage >= 0.1
	WHERE NOT EXISTS (SELECT 1 FROM project_identifiaction_transactions AS t WHERE b.transaction_id = t.transaction_id)
		AND NOT EXISTS (SELECT 1 FROM project_identifiaction_transactions_by_loc_name AS t2 WHERE b.transaction_id = t2.transaction_id)
		AND NOT (b.fixed_project_nuts2 IS NULL AND b.beneficiary_id IN ('UNIVERSIDAD NACIONAL DE EDUCACIÓN A DISTANCIA, UNED', 'Ministerio de Hacienda y Administraciones Públicas(Dirección General de 
Fondos Comunitarios)'))
),
benefciary_identifiaction_transactions AS (
	SELECT b.*, project_nuts2 AS fixed_project_nuts2, g.lau AS found_lau, 'benefciary_identification' AS transaction_type
	FROM base AS b
	INNER JOIN geocode_result AS g ON g.query_type = 'beneficiary' AND g.lau IS NOT NULL AND b.beneficiary_id = g.beneficiary_id
	WHERE NOT EXISTS (SELECT 1 FROM project_identifiaction_transactions AS t WHERE b.transaction_id = t.transaction_id)
		AND NOT EXISTS (SELECT 1 FROM top_beneficaries_transactions AS t2 WHERE b.transaction_id = t2.transaction_id)
		AND NOT EXISTS (SELECT 1 FROM project_identifiaction_transactions_by_loc_name AS t3 WHERE b.transaction_id = t3.transaction_id)		
		AND NOT (project_nuts2 IS NULL AND b.beneficiary_id IN ('UNIVERSIDAD NACIONAL DE EDUCACIÓN A DISTANCIA, UNED', 'Ministerio de Hacienda y Administraciones Públicas(Dirección General de 
Fondos Comunitarios)'))
),
unemployement_transactions AS (
	SELECT 
		MIN(b.transaction_id) AS transaction_id,
		b.project_name,
		'beneficiario anonimizado' AS beneficiary_name,
		SUM(eu_cofinancing_amount) AS eu_cofinancing_amount,
		SUM(amount) AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'ES' AS beneficiary_country_code,
		'beneficiario anonimizado' AS beneficiary_id,
		'ESF' AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_nuts2,
		NULL AS fixed_project_nuts2,
		NULL AS found_lau, 
		'unemployed_anonymised' AS transaction_type
	FROM nuts_fix AS b
	WHERE NOT EXISTS (SELECT 1 FROM project_identifiaction_transactions AS t WHERE b.transaction_id = t.transaction_id)
		AND NOT EXISTS (SELECT 1 FROM top_beneficaries_transactions AS t2 WHERE b.transaction_id = t2.transaction_id)
		AND NOT EXISTS (SELECT 1 FROM benefciary_identifiaction_transactions AS t3 WHERE b.transaction_id = t3.transaction_id)
		AND NOT EXISTS (SELECT 1 FROM project_identifiaction_transactions_by_loc_name AS t4 WHERE b.transaction_id = t4.transaction_id)
		AND fixed_project_nuts2 IS NULL AND project_name = 'Mejorar la empleabilidad de las personas desempleadas'
	GROUP BY b.project_name
),
rest_transactions AS (
	SELECT b.*, NULL AS found_lau, 'rest_for_distribution' AS transaction_type
	FROM nuts_fix AS b
	WHERE NOT EXISTS (SELECT 1 FROM project_identifiaction_transactions AS t WHERE b.transaction_id = t.transaction_id)
		AND NOT EXISTS (SELECT 1 FROM top_beneficaries_transactions AS t2 WHERE b.transaction_id = t2.transaction_id)
		AND NOT EXISTS (SELECT 1 FROM benefciary_identifiaction_transactions AS t3 WHERE b.transaction_id = t3.transaction_id)
		AND NOT EXISTS (SELECT 1 FROM project_identifiaction_transactions_by_loc_name AS t4 WHERE b.transaction_id = t4.transaction_id)
		AND NOT (fixed_project_nuts2 IS NULL AND project_name = 'Mejorar la empleabilidad de las personas desempleadas')
		AND NOT (fixed_project_nuts2 IS NULL AND beneficiary_id IN ('UNIVERSIDAD NACIONAL DE EDUCACIÓN A DISTANCIA, UNED', 'Ministerio de Hacienda y Administraciones Públicas(Dirección General de 
Fondos Comunitarios)'))
),
result_union AS (
	SELECT * FROM project_identifiaction_transactions
	UNION ALL
	SELECT * FROM project_identifiaction_transactions_by_loc_name
	UNION ALL 
	SELECT * FROM top_beneficaries_transactions
	UNION ALL 
	SELECT * FROM benefciary_identifiaction_transactions
	UNION ALL
	SELECT * FROM unemployement_transactions
	UNION ALL 
	SELECT * FROM project_anonymised_transactions
	UNION ALL 
	SELECT * FROM rest_transactions
),
join_loc AS (
	SELECT 
		b.*, 
		COALESCE(p1.shape_lau, p2.shape_lau, p3.shape_lau) AS shape_lau, 
		COALESCE(p1.name, p2.name, p3.name) AS city_name, 
		COALESCE(p1.population, p2.population, p3.population) AS population,
		CASE 
			WHEN b.transaction_type IN ('benefciary_identification', 'project_identification') THEN 'geocoded'
			WHEN b.transaction_type = 'project_identification_by_loc_name' THEN 'lau2'
			WHEN b.transaction_type IN ('project_anonymised', 'unemployed_anonymised') THEN 'anonymised'
			WHEN b.fixed_project_nuts2 IS NOT NULL THEN 'nuts2'
			ELSE 'national'
		END AS geolocation_in_source,
		CASE 
			WHEN b.transaction_type IN ('benefciary_identification', 'project_identification', 'project_identification_by_loc_name') THEN FALSE
			ELSE TRUE
		END AS distributed
	FROM result_union as b
	LEFT JOIN "population" as p1 
		ON b.transaction_type IN ('benefciary_identification', 'project_identification', 'project_identification_by_loc_name') AND b.found_lau = p1.lau
	LEFT JOIN "population" as p2
		ON b.transaction_type NOT IN ('benefciary_identification', 'project_identification', 'project_identification_by_loc_name') 
		AND b.fixed_project_nuts2 IS NOT NULL AND b.fixed_project_nuts2 = SUBSTRING(p2.shape_lau, 0, 5)
	LEFT JOIN "population" as p3
		ON b.transaction_type NOT IN ('benefciary_identification', 'project_identification', 'project_identification_by_loc_name') 
		AND b.fixed_project_nuts2 IS NULL
),
distribution AS (
	SELECT *,
		CASE 
			WHEN shape_lau IS NOT NULL AND (sum(population::INT) OVER (PARTITION BY transaction_id)) = 0 AND (count(*) OVER (PARTITION BY transaction_id)) = 1 THEN 1
			WHEN shape_lau IS NOT NULL AND (sum(population::INT) OVER (PARTITION BY transaction_id)) = 0 AND (count(*) OVER (PARTITION BY transaction_id)) > 1 THEN 0
			WHEN shape_lau IS NOT NULL THEN (population::INT * 1.0) / sum(population::INT) OVER (PARTITION BY transaction_id)
			ELSE 1
		END AS population_multiplier
	FROM join_loc
)
SELECT
	transaction_id,
	project_name,
	beneficiary_name,
	population_multiplier * eu_cofinancing_amount AS eu_cofinancing_amount,
	population_multiplier * amount AS amount, 
	amount_kind,
	beneficiary_country_code,
	beneficiary_id,
	fund_acronym,
	funding_period,
	project_nuts2,
	shape_lau AS project_lau2, 
	city_name AS project_city,
	geolocation_in_source,
	distributed
INTO public.final2
FROM distribution;