
INSERT INTO it_final (transaction_id,project_name,beneficiary_name,total_ammount,eu_cofinancing_amount,amount,amount_kind,beneficiary_country_code,beneficiary_id,fund_acronym,funding_period,geocoding_state,beneficiary_postal_code,beneficiary_lau2,project_state,project_region,project_county,project_city,project_lau2,project_postal_code,project_address,distributed,geolocation_in_source)
WITH 
sub_act AS (
	SELECT DISTINCT ON ("COD_LOCALE_PROGETTO", "OC_DENOMINAZIONE_SOGG")
		"COD_LOCALE_PROGETTO", "OC_DENOMINAZIONE_SOGG", "CAP_SOGG"
	FROM subject
	WHERE "SOGG_COD_RUOLO"::INT = 2
	ORDER BY "COD_LOCALE_PROGETTO", "OC_DENOMINAZIONE_SOGG", "CAP_SOGG" ASC NULLS LAST
),

sub_prog AS (
	SELECT DISTINCT ON ("COD_LOCALE_PROGETTO", "OC_DENOMINAZIONE_SOGG")
		"COD_LOCALE_PROGETTO", "OC_DENOMINAZIONE_SOGG", "CAP_SOGG"
	FROM subject AS s
	WHERE 
		"SOGG_COD_RUOLO"::INT = 1 
		AND NOT EXISTS (
			SELECT "COD_LOCALE_PROGETTO" 
			FROM sub_act AS s2
			WHERE s."COD_LOCALE_PROGETTO" = s2."COD_LOCALE_PROGETTO"
		)
	ORDER BY "COD_LOCALE_PROGETTO", "OC_DENOMINAZIONE_SOGG", "CAP_SOGG" ASC NULLS LAST
),

sub AS (
	SELECT * FROM sub_act
	UNION
	SELECT * FROM sub_prog
),

pre_project AS (
	SELECT 
		p."COD_LOCALE_PROGETTO",
		p."OC_TITOLO_PROGETTO" AS project_name,
		(CASE REPLACE("FINANZ_TOTALE_PUBBLICO", ',', '.')::FLOAT WHEN 0 THEN REPLACE("FINANZ_PRIVATO", ',', '.')::FLOAT ELSE REPLACE("FINANZ_TOTALE_PUBBLICO", ',', '.')::FLOAT END) AS total_amount,
		REPLACE("FINANZ_UE", ',', '.')::FLOAT AS eu_cofinancing_amount,
		s."OC_DENOMINAZIONE_SOGG" AS beneficiary_name,
		s."CAP_SOGG" AS beneficiary_postal_code,
		count(s."OC_DENOMINAZIONE_SOGG") OVER (PARTITION BY p."COD_LOCALE_PROGETTO") AS beneficiary_count,
		row_number() OVER (PARTITION BY p."COD_LOCALE_PROGETTO") AS beneficiary_row
	FROM project as p 
	INNER JOIN sub as s on s."COD_LOCALE_PROGETTO" = p."COD_LOCALE_PROGETTO"
),

project AS (
	SELECT 
		md5("COD_LOCALE_PROGETTO" || beneficiary_row::varchar) as transaction_id,
		*,
		round((total_amount*1.0 / beneficiary_count)::numeric, 1) AS recalc_total_amount,
		round((eu_cofinancing_amount*1.0 / beneficiary_count)::numeric, 1) AS recalc_eu_cofinancing_amount
	FROM pre_project
),

loc AS (
	SELECT * FROM (
	SELECT *, min(loc_type) OVER (PARTITION BY "COD_LOCALE_PROGETTO") AS min_loc_type FROM (
		SELECT 
			*, 
			CASE "OC_TERRITORIO_PROG" 
				WHEN 'C' THEN 1
				WHEN 'P' THEN 2
				WHEN 'R' THEN 3
				WHEN 'N' THEN 4
				WHEN 'E' THEN 5
			END AS loc_type
		FROM loc) AS vw
	) AS vw2
	WHERE min_loc_type = loc_type
),


project_with_loc AS (
	SELECT *, 
		LPAD("COD_PROVINCIA"::varchar,3,'0') as county_code,
		LPAD("COD_PROVINCIA"::varchar,3,'0') || LPAD("COD_COMUNE"::varchar,3,'0') as lau
	FROM project AS p
	LEFT JOIN loc AS l ON l."COD_LOCALE_PROGETTO" = p."COD_LOCALE_PROGETTO"
),

abroad AS (
	SELECT 
		*,
		"DEN_REGIONE" AS project_state,
		CASE beneficiary_postal_code
			WHEN '34127' THEN 'ITH44_032006'
			WHEN '34137' THEN 'ITH44_032006'
			WHEN '34149' THEN 'ITH44_032006'
			WHEN '80121' THEN 'ITF33_063049'
			WHEN '80132' THEN 'ITF33_063049'
			WHEN '83100' THEN 'ITF34_064008'
			WHEN '84125' THEN 'ITF35_065116'
			WHEN '33100' THEN 'ITH42_030129'
			WHEN '34133' THEN 'ITH44_032006'
			WHEN '33170' THEN 'ITH41_093033'
			ELSE NULL
		END AS beneficiary_lau2
	FROM project_with_loc
	WHERE loc_type = 5 AND beneficiary_postal_code != ' '
),

vw_aborad AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		recalc_total_amount AS total_ammount,
		recalc_eu_cofinancing_amount AS eu_cofinancing_amount,
		recalc_eu_cofinancing_amount AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'IT' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		'ERDF' AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS geocoding_state,
		beneficiary_postal_code,
		beneficiary_lau2,
		project_state,
		NULL AS project_region,
		NULL AS project_county,
		NULL AS project_city,
		NULL AS project_lau2,
		NULL AS project_postal_code,
		NULL AS project_address,
		FALSE AS distributed,
		'lau2' AS geolocation_in_source
	FROM abroad
),

country AS (
	SELECT 
		*,
		'Italia' AS project_state,
		p.population::INT*1.0 / sum(p.population::INT) OVER (PARTITION BY transaction_id) AS population_multiplier
	FROM project_with_loc
	CROSS JOIN it_population as p
	WHERE loc_type = 4 OR (loc_type = 5 AND beneficiary_postal_code = ' ')
),

vw_country AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		recalc_total_amount * population_multiplier AS total_ammount,
		recalc_eu_cofinancing_amount * population_multiplier AS eu_cofinancing_amount,
		recalc_eu_cofinancing_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'IT' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		'ERDF' AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS geocoding_state,
		beneficiary_postal_code,
		NULL AS beneficiary_lau2,
		project_state,
		NULL AS project_region,
		NULL AS project_county,
		NULL AS project_city,
		shape_lau AS project_lau2,
		NULL AS project_postal_code,
		NULL AS project_address,
		TRUE AS distributed,
		'national' AS geolocation_in_source
	FROM country
),

region_translate AS (
	SELECT 
		DISTINCT "Codice Regione"::int AS region_code, "Codice NUTS2 2010 (3) " AS nuts2
	FROM it_translate 
	WHERE "Codice Regione" != ''
),

region AS (
	SELECT 
		*,
		p.population::int*1.0 / sum(p.population::int) OVER (PARTITION BY transaction_id) AS population_multiplier
	FROM project_with_loc as pr
	INNER JOIN region_translate as t ON pr."COD_REGIONE"::INT = t.region_code
	INNER JOIN it_population as p ON t.nuts2 = substr(split_part(shape_lau,'_',1),0,5)
	WHERE loc_type = 3
),

vw_region AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		recalc_total_amount * population_multiplier AS total_ammount,
		recalc_eu_cofinancing_amount * population_multiplier AS eu_cofinancing_amount,
		recalc_eu_cofinancing_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'IT' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		'ERDF' AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS geocoding_state,
		beneficiary_postal_code,
		NULL AS beneficiary_lau2,
		NULL AS project_state,
		"DEN_REGIONE" AS project_region,
		NULL AS project_county,
		NULL AS project_city,
		shape_lau AS project_lau2,
		NULL AS project_postal_code,
		NULL AS project_address,
		TRUE AS distributed,
		'nuts2' AS geolocation_in_source
	FROM region
),

county AS (
	SELECT 
		*,
		p.population::int*1.0 / sum(p.population::int) OVER (PARTITION BY transaction_id) AS population_multiplier
	FROM project_with_loc as pr
	INNER JOIN it_population as p ON pr.county_code = substr(p.lau,0,4)
	WHERE loc_type = 2
),

vw_county AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		recalc_total_amount * population_multiplier AS total_ammount,
		recalc_eu_cofinancing_amount * population_multiplier AS eu_cofinancing_amount,
		recalc_eu_cofinancing_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'IT' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		'ERDF' AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS geocoding_state,
		beneficiary_postal_code,
		NULL AS beneficiary_lau2,
		NULL AS project_state,
		NULL AS project_region,
		"DEN_PROVINCIA" AS project_county,
		NULL AS project_city,
		shape_lau AS project_lau2,
		NULL AS project_postal_code,
		NULL AS project_address,
		TRUE AS distributed,
		'nuts3' AS geolocation_in_source
	FROM county
),

lau_fix AS (
	SELECT '093053' AS o_lau, '093003' AS t_lau UNION
	SELECT '093053' AS o_lau, '093048' AS t_lau UNION
	SELECT '013252' AS o_lau, '013225' AS t_lau UNION
	SELECT '013252' AS o_lau, '013172' AS t_lau UNION
	SELECT '013252' AS o_lau, '013125' AS t_lau UNION
	SELECT '013252' AS o_lau, '013148' AS t_lau UNION
	SELECT '041068' AS o_lau, '041012' AS t_lau UNION
	SELECT '041068' AS o_lau, '041056' AS t_lau UNION
	SELECT '042050' AS o_lau, '042009' AS t_lau UNION
	SELECT '042050' AS o_lau, '042028' AS t_lau UNION
	SELECT '042050' AS o_lau, '042039' AS t_lau UNION
	SELECT '025071' AS o_lau, '025009' AS t_lau UNION
	SELECT '025071' AS o_lau, '025031' AS t_lau UNION
	SELECT '064121' AS o_lau, '064062' AS t_lau UNION
	SELECT '064121' AS o_lau, '064061' AS t_lau UNION
	SELECT '025070' AS o_lau, '025042' AS t_lau UNION
	SELECT '025070' AS o_lau, '025064' AS t_lau
),

city AS (
	SELECT 
		*,
		CASE WHEN sum(p.population::int) OVER (PARTITION BY transaction_id) != 0 THEN
			p.population::int*1.0 / sum(p.population::int) OVER (PARTITION BY transaction_id) 
			ELSE 1
		END AS population_multiplier
	FROM project_with_loc AS pr
	LEFT JOIN lau_fix AS lf ON pr.lau = lf.o_lau
	LEFT JOIN it_population as p ON COALESCE(lf.t_lau, pr.lau) = p.lau
	WHERE loc_type = 1
),

vw_city AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
	  recalc_total_amount * population_multiplier AS total_ammount,
		recalc_eu_cofinancing_amount * population_multiplier AS eu_cofinancing_amount,
		recalc_eu_cofinancing_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'IT' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		'ERDF' AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS geocoding_state,
		beneficiary_postal_code,
		NULL AS beneficiary_lau2,
		NULL AS project_state,
		NULL AS project_region,
		NULL AS project_county,
		"DEN_COMUNE" AS project_city,
		shape_lau AS project_lau2,
		NULL AS project_postal_code,
		NULL AS project_address,
		FALSE AS distributed,
		'lau2' AS geolocation_in_source
	FROM city
)


--select * from vw_aborad;
--select * from vw_country;
--select * from vw_region;
--select * from vw_county;
select * from vw_city;
--;

