INSERT INTO final (transaction_id,project_name,beneficiary_name,total_ammount,eu_cofinancing_amount,amount,amount_kind,beneficiary_country_code,beneficiary_id,fund_acronym,funding_period,project_state,project_region,project_county,project_city,project_lau2,geolocation_in_source,distributed)
WITH base AS (
	SELECT
		*,
		replace(granted_eu_state_funding, ' ', '')::int AS fixed_granted_eu_state_funding,
		replace(realized_eu_state_funding, ' ', '')::int AS fixed_realized_eu_state_funding,
		replace(planned_public_funding, ' ', '')::int AS fixed_planned_public_funding,
		replace(total_public_funding, ' ', '')::int AS fixed_total_public_funding,
		CASE fund WHEN 'ESR' THEN 'ESF' ELSE 'ERDF' END AS fixed_fund,
		REPLACE(city, 'Koski, Tl', 'Koski Tl') AS fixed_city,
		md5(code) AS transaction_id
	FROM project
),
geometry AS (
	SELECT * 
	FROM population
	WHERE shape_lau LIKE 'FI%'
),

pre_cities AS (
	SELECT 
		code,
		unnest(string_to_array(fixed_city,', ')) as city
	FROM base
	WHERE fixed_city IS NOT NULL
),

cities AS (
	SELECT 
		code,
		COALESCE(t.swedish, c.city) AS city,
		c.city AS original_city
	FROM pre_cities AS c
	LEFT JOIN city_translate AS t ON c.city = t.finnish
),

city_projects AS (
	SELECT distinct 
		*,
		p.population::INT*1.0 / sum(p.population::INT) OVER (PARTITION BY transaction_id) AS population_multiplier
	FROM base AS b
	INNER JOIN cities AS c ON b.code = c.code
	INNER JOIN geometry AS p ON c.city = p.name
	WHERE b.fixed_city IS NOT NULL
),

vw_city_project AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary AS beneficiary_name,
		(fixed_total_public_funding + fixed_realized_eu_state_funding) * population_multiplier AS total_ammount,
		fixed_realized_eu_state_funding * population_multiplier AS eu_cofinancing_amount,
		fixed_realized_eu_state_funding * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'FI' AS beneficiary_country_code,
		beneficiary AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_state,
		NULL AS project_region,
		NULL AS project_county,
		original_city AS project_city,
		shape_lau AS project_lau2,
		'lau2' AS geolocation_in_source,
		CASE WHEN count(*) OVER (PARTITION BY transaction_id) > 1 THEN TRUE ELSE FALSE END AS distributed
	FROM city_projects
),

pre_county AS (
	SELECT 
		code,
		unnest(string_to_array(county,', ')) as county
	FROM base
	WHERE fixed_city IS NULL AND county IS NOT NULL
),

county AS (
	SELECT 
		code,
		COALESCE(t.new, c.county) AS county,
		c.county AS original_county
	FROM pre_county AS c
	LEFT JOIN lau1_translate AS t ON c.county = t.original
),

county_projects AS (
	SELECT 
		*,
		p.population::INT*1.0 / sum(p.population::INT) OVER (PARTITION BY transaction_id) AS population_multiplier
	FROM base AS b
	INNER JOIN county AS c ON b.code = c.code
	LEFT JOIN lau1_lau2 as l ON c.county = l.lau1_name
	LEFT JOIN geometry AS p ON l.lau2 = p.lau
	WHERE fixed_city IS NULL AND b.county IS NOT NULL
),

vw_county_project AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary AS beneficiary_name,
		(fixed_total_public_funding + fixed_realized_eu_state_funding) * population_multiplier AS total_ammount,
		fixed_realized_eu_state_funding * population_multiplier AS eu_cofinancing_amount,
		fixed_realized_eu_state_funding * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'FI' AS beneficiary_country_code,
		beneficiary AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_state,
		NULL AS project_region,
		original_county AS project_county,
		name AS project_city,
		shape_lau AS project_lau2,
		'lau1' AS geolocation_in_source,
		TRUE AS distributed
	FROM county_projects
),

region_projects AS (
	SELECT 
		*,
		p.population::INT*1.0 / sum(p.population::INT) OVER (PARTITION BY transaction_id) AS population_multiplier
	FROM base AS b
	LEFT JOIN nuts3 as n ON b.region = n.nuts3_name
	LEFT JOIN geometry AS p ON p.shape_lau LIKE (n.nuts3 || '%')
	WHERE fixed_city IS NULL AND county IS NULL AND region IS NOT NULL
),

vw_region_project AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary AS beneficiary_name,
		(fixed_total_public_funding + fixed_realized_eu_state_funding) * population_multiplier AS total_ammount,
		fixed_realized_eu_state_funding * population_multiplier AS eu_cofinancing_amount,
		fixed_realized_eu_state_funding * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'FI' AS beneficiary_country_code,
		beneficiary AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_state,
		NULL AS project_region,
		region AS project_county,
		name AS project_city,
		shape_lau AS project_lau2,
		'nuts3' AS geolocation_in_source,
		TRUE AS distributed
	FROM region_projects
),

country_projects AS (
	SELECT 
		*,
		p.population::INT*1.0 / sum(p.population::INT) OVER (PARTITION BY transaction_id) AS population_multiplier
	FROM base AS b
	CROSS JOIN geometry AS p
	where country = 'National project' 
		OR (fixed_city IS NULL AND county IS NULL AND region IS NULL AND "partition" = 'Valtakunnallinen osio')
),

vw_country_project AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary AS beneficiary_name,
		(fixed_total_public_funding + fixed_realized_eu_state_funding) * population_multiplier AS total_ammount,
		fixed_realized_eu_state_funding * population_multiplier AS eu_cofinancing_amount,
		fixed_realized_eu_state_funding * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'FI' AS beneficiary_country_code,
		beneficiary AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		'Finland' AS project_state,
		NULL AS project_region,
		NULL AS project_county,
		name AS project_city,
		shape_lau AS project_lau2,
		'national' AS geolocation_in_source,
		TRUE AS distributed
	FROM country_projects
),

empty_projects AS (
	SELECT 
		*,
		p.population::INT*1.0 / sum(p.population::INT) OVER (PARTITION BY transaction_id) AS population_multiplier
	FROM base AS b
	LEFT JOIN geometry AS p ON p.shape_lau LIKE (
		CASE "partition"
			WHEN 'Itä-Suomen suuralueosio' THEN 'FI1D'
			WHEN 'Etelä-Suomi' THEN 'FI1C'
			WHEN 'Itä-Suomi' THEN 'FI1D'
			WHEN 'Länsi-Suomi' THEN 'FI19'
			WHEN 'Pohjois-Suomi' THEN 'FI1D'
		END || '%'
	)
	WHERE fixed_city IS NULL AND county IS NULL AND region IS NULL AND country IS NULL AND "partition" != 'Valtakunnallinen osio'
),

vw_empty_projects AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary AS beneficiary_name,
		(fixed_total_public_funding + fixed_realized_eu_state_funding) * population_multiplier AS total_ammount,
		fixed_realized_eu_state_funding * population_multiplier AS eu_cofinancing_amount,
		fixed_realized_eu_state_funding * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'FI' AS beneficiary_country_code,
		beneficiary AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_state,
		"partition" AS project_region,
		NULL AS project_county,
		name AS project_city,
		shape_lau AS project_lau2,
		'nuts2' AS geolocation_in_source,
		TRUE AS distributed
	FROM empty_projects
)


--SELECT * FROM vw_empty_projects
--SELECT * FROM vw_country_project
--SELECT * FROM vw_region_project
--SELECT * FROM vw_county_project
SELECT * FROM vw_city_project
