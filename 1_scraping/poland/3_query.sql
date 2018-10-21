INSERT INTO final (transaction_id,project_name,beneficiary_name,total_ammount,eu_cofinancing_amount,amount,amount_kind,beneficiary_country_code,beneficiary_id,fund_acronym,funding_period,project_state,project_region,project_county,project_city,project_lau2,geolocation_in_source,distributed)
WITH 
base AS (
	SELECT 
		*,
		md5(link) AS transaction_id,
		title AS project_name,
		beneficiary AS beneficiary_name,
		CASE fund 
			WHEN 'Europejski Fundusz Rozwoju Regionalnego' THEN 'ERDF'
			WHEN 'Europejski Fundusz Społeczny' THEN 'ESF'
			WHEN 'Fundusz Spójności' THEN 'CF'
		END as fixed_fund,
		split_part(replace(replace(loc, E'\t', ''), E'\r\n', '|'),'|',1) AS region,
		split_part(replace(replace(loc, E'\t', ''), E'\r\n', '|'),'|',2) AS county,
		replace(replace(total_amount, ' zł', ''), ' ', '')::float / 4.0161 AS fixed_total_amount,
		replace(replace(eu_amount, ' zł', ''), ' ', '')::float / 4.0161 AS fixed_eu_amount
	FROM transactions
),

population AS (
	SELECT 
		name, 
		population, 
		CASE 
			WHEN lau = '502032109' THEN '0265' 
			ELSE substring(lau, 2, 2) || substring(lau, 6, 2) 
		END AS lau1, 
		lau AS lau2, 
		shape_lau 
	FROM population
	WHERE shape_lau LIKE 'PL%' 
),

pre_country_loc AS (
	SELECT 
		transaction_id,
		unnest(string_to_array(county,', ')) as county
	FROM base
	WHERE county != 'brak'
),

county_loc AS (
	SELECT 
		c.transaction_id, 
		c.county AS original_county, 
		COALESCE(l.lau1, l2.lau1) AS lau1, 
		p.shape_lau, 
		p.population, 
		p.name AS city_name,
		CASE WHEN l.lau1 IS NOT NULL THEN 'lau1' ELSE 'nuts2' END AS dist
	FROM pre_country_loc AS c
	LEFT JOIN lau1 AS l ON replace(replace(c.county, 'm. ', ''), 'm.st. ', '') = l.name
	LEFT JOIN nuts2 AS n ON l.lau1 IS NULL AND c.county LIKE '%(' || lower(n.name) || ')%'
	LEFT JOIN lau1 AS l2 ON l.lau1 IS NULL AND c.county LIKE l2.name || '%' AND n.code = substring(l2.lau1, 0, 3)
	LEFT JOIN population AS p ON p.lau1 = COALESCE(l.lau1, l2.lau1)
),

county_projects AS (
	SELECT  
		*,
		b.transaction_id AS id,
		p.population::INT*1.0 / sum(p.population::INT) OVER (PARTITION BY b.transaction_id) AS population_multiplier
	FROM base AS b
	LEFT JOIN county_loc AS p ON b.transaction_id = p.transaction_id
	WHERE b.county != 'brak'
),

vw_county_project AS (
	SELECT
		id AS transaction_id,
		project_name,
		beneficiary_name,
		fixed_total_amount * population_multiplier AS total_ammount,
		fixed_eu_amount * population_multiplier AS eu_cofinancing_amount,
		fixed_eu_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'PL' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_state,
		NULL AS project_region,
		original_county AS project_county,
		city_name AS project_city,
		shape_lau AS project_lau2,
		dist AS geolocation_in_source,
		TRUE AS distributed
	FROM county_projects
),

pre_region_loc AS (
	SELECT 
		transaction_id,
		unnest(string_to_array(region,', ')) as region
	FROM base
	WHERE county = 'brak' and region != 'brak' and region != 'projekt ogólnopolski'
),

region_loc AS (
	SELECT 
		c.transaction_id, 
		c.region AS original_region,
		l.lau1,
		p.shape_lau, 
		p.population, 
		p.name AS city_name
	FROM pre_region_loc AS c
	LEFT JOIN nuts2 AS n ON c.region = lower(n.name)
	LEFT JOIN lau1 AS l ON n.code = substring(l.lau1, 0, 3)
	LEFT JOIN population AS p ON p.lau1 = l.lau1
	WHERE region != 'projekt ogólnopolski'
),

region_projects AS (
	SELECT  
		*,
		b.transaction_id AS id,
		p.population::INT*1.0 / sum(p.population::INT) OVER (PARTITION BY b.transaction_id) AS population_multiplier
	FROM base AS b
	LEFT JOIN region_loc AS p ON b.transaction_id = p.transaction_id
	WHERE county = 'brak' and region != 'brak' and region != 'projekt ogólnopolski'
),

vw_region_project AS (
	SELECT
		id AS transaction_id,
		project_name,
		beneficiary_name,
		fixed_total_amount * population_multiplier AS total_ammount,
		fixed_eu_amount * population_multiplier AS eu_cofinancing_amount,
		fixed_eu_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'PL' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_state,
		original_region AS project_region,
		NULL AS project_county,
		city_name AS project_city,
		shape_lau AS project_lau2,
		'nuts2' AS geolocation_in_source,
		TRUE AS distributed
	FROM region_projects
),

country_projects AS (
	SELECT  
		b.*,
		p.shape_lau,
		p.name AS city_name,
		p.population::INT*1.0 / sum(p.population::INT) OVER (PARTITION BY b.transaction_id) AS population_multiplier
	FROM base AS b
	CROSS JOIN population AS p
	WHERE county = 'brak' and region = 'projekt ogólnopolski'
),

vw_country_project AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		fixed_total_amount * population_multiplier AS total_ammount,
		fixed_eu_amount * population_multiplier AS eu_cofinancing_amount,
		fixed_eu_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'PL' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		'Poland' AS project_state,
		NULL AS project_region,
		NULL AS project_county,
		city_name AS project_city,
		shape_lau AS project_lau2,
		'national' AS geolocation_in_source,
		TRUE AS distributed
	FROM country_projects
),

city_projects AS (
	SELECT  
		b.*,
		p.shape_lau,
		p.name AS city_name,
		p.population::INT*1.0 / sum(p.population::INT) OVER (PARTITION BY b.transaction_id) AS population_multiplier
	FROM base AS b
	INNER JOIN (SELECT distinct on (name) name, population, shape_lau FROM population ORDER BY name, population DESC) as p 
		ON replace(replace(replace(replace(b.beneficiary_name, 'Gmina ', ''), 'Miasto ', ''), 'Miejska ', ''), 'Miasta ', '') = p.name
	WHERE county = 'brak' and region = 'brak' AND (b.beneficiary_name LIKE '%Gmina%' OR b.beneficiary_name LIKE '%Miasto%' OR b.beneficiary_name LIKE '%Miejska%' OR b.beneficiary_name LIKE '%Miasta%')
),

vw_city_project AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		fixed_total_amount * population_multiplier AS total_ammount,
		fixed_eu_amount * population_multiplier AS eu_cofinancing_amount,
		fixed_eu_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'PL' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_state,
		NULL AS project_region,
		NULL AS project_county,
		city_name AS project_city,
		shape_lau AS project_lau2,
		'lau2' AS geolocation_in_source,
		FALSE AS distributed
	FROM city_projects
),

beneficiary_projects AS (
	SELECT  
		b.*,
		p.shape_lau,
		p.name AS city_name,
		p.population::INT*1.0 / sum(p.population::INT) OVER (PARTITION BY b.transaction_id) AS population_multiplier
	FROM base AS b
	CROSS JOIN population AS p
	WHERE county = 'brak' and region = 'brak' AND transaction_id NOT IN (SELECT transaction_id FROM city_projects)
),

vw_beneficiary_project AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		population_multiplier * fixed_total_amount AS total_ammount,
		population_multiplier * fixed_eu_amount AS eu_cofinancing_amount,
		population_multiplier * fixed_eu_amount AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'PL' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_state,
		NULL AS project_region,
		NULL AS project_county,
		city_name AS project_city,
		shape_lau AS project_lau2,
		'national' AS geolocation_in_source,
		TRUE AS distributed
	FROM beneficiary_projects
)

--select * from vw_county_project;
--select * from vw_region_project;
--select * from vw_country_project;
--select * from vw_city_project;
select * from vw_beneficiary_project;