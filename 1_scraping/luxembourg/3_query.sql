INSERT INTO public.final (transaction_id,project_name,beneficiary_name,total_ammount,eu_cofinancing_amount,amount,amount_kind,beneficiary_country_code,beneficiary_id,fund_acronym,funding_period,geocoding_state,beneficiary_postal_code,beneficiary_lau2,project_state,project_region,project_county,project_city,project_nuts3,project_lau2,project_postal_code,project_address,start_date,end_date,geolocation_in_source,distributed)
WITH erdf AS (
	SELECT
		'ERDF' AS fund,
		(CASE 
			WHEN "durée" LIKE '____ - ____' THEN (SUBSTRING("durée", 0, 5) || '-01-01')::DATE
			WHEN "durée" LIKE '__________ - __________' THEN (SUBSTRING("durée", 7,4) || '-' || SUBSTRING("durée", 4,2) || '-' || SUBSTRING("durée", 0,3))::DATE
		END) AS start_date,
		CASE 
			WHEN "durée" LIKE '____ - ____' THEN (SUBSTRING("durée", 8, 4) || '-12-31')::DATE
			WHEN "durée" LIKE '__________ - __________' THEN (SUBSTRING("durée", 20,4) || '-' || SUBSTRING("durée", 17,2) || '-' || SUBSTRING("durée", 14,2))::DATE
		END AS end_date,
		title AS project_title,
		"porteur(s)_de_projet" AS beneficiary_name,
		CASE 
			WHEN feder LIKE '%mio%' THEN trim(REPLACE(REPLACE(REPLACE(feder, '€', ''), 'mio', ''), ',', '.'))::FLOAT * 1000000 
			ELSE REPLACE(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(feder, '€', ''), '.', ''), '-', ''), '(45%)', ''), '(50%)', ''), '(31%)', '')), ',', '.')::FLOAT
		END AS eu_amount,
		CASE 
			WHEN COALESCE("coût_total", "total") LIKE '%mio%' THEN trim(REPLACE(REPLACE(REPLACE(COALESCE("coût_total", "total"), '€', ''), 'mio', ''), ',', '.'))::FLOAT * 1000000 
			ELSE REPLACE(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE("coût_total", "total"), '€', ''), '.', ''), '-', ''), '(45%)', ''), '(50%)', ''), '(31%)', '')), ',', '.')::FLOAT
		END AS total_amount,
	  "commune(s)" AS loc
	FROM "1_transactions"
	WHERE fonds = 'FEDER'
),
esf AS (
	SELECT 
		'ESF' AS fund,
		(SUBSTRING("durée", 7,4) || '-01-01')::DATE AS start_date,
		(SUBSTRING("durée", 20,4) || '-12-31')::DATE AS end_date,
		title AS project_title,
		"porteur_de_projet" AS beneficiary_name,
		REPLACE(REPLACE(REPLACE("part_fse_(50%)", '€', ''), '.', ''), ',', '.')::FLOAT AS eu_amount,
		REPLACE(REPLACE(REPLACE("total", '€', ''), '.', ''), ',', '.')::FLOAT AS total_amount,
		"commune(s)" AS loc
 	FROM "1_transactions"
	WHERE fonds = 'FSE'
	  AND programme = 'Compétitivité Régionale et Emploi (2007-2013)'
),
lu_union AS (
	SELECT 
		md5('LU' || (row_number() OVER ())::VARCHAR) AS transaction_id,
		*
	FROM (
		SELECT * FROM erdf
		UNION 
		SELECT * FROM esf
	) AS vw
),
city_loc AS (
	SELECT 
		b.*, 
		p.shape_lau, 
		p.name AS loc_name, 
		population::INT*1.0 / sum(population::INT) OVER (PARTITION BY transaction_id) AS population_multiplier,
		CASE WHEN count(*) OVER (PARTITION BY transaction_id) > 1 THEN TRUE ELSE FALSE END AS distributed
	FROM lu_union AS b
	LEFT JOIN "1_population" AS p ON p.shape_lau LIKE 'LU%' AND (
		p.name = b.loc
		OR (p.name = 'Beetebuerg' AND b.loc = 'Bettembourg')
		OR (p.name = 'Rouspert' AND b.loc = 'Rosport')
		OR (p.name = 'Esch-Uelzecht' AND b.loc = 'Esch/Alzette')
		OR (p.name = 'Lëtzebuerg' AND b.loc = 'Luxembourg')
		OR (p.name IN ('Ëlwen', 'Ettelbréck', 'Klierf') AND b.loc = 'Troisvierges
Ettelbruck
Clervaux')
		OR (p.name = 'Réimech' AND b.loc = 'Perl (D)')
		OR (p.name = 'Schëtter' AND b.loc = 'Munsbach')
		OR (p.name = 'Monnerech' AND b.loc = 'Mondercange')
		OR (p.name IN ('Esch-Sauer', 'Hengescht') AND b.loc = 'Esch-sur-Sûre
Heinerscheid')
		OR (p.name = 'Wäisswampech' AND b.loc = 'Binsfeld')
		OR (p.name = 'Nidderkäerjeng' AND b.loc = 'Bascharage')
		OR (p.name = 'Esch-Uelzecht' AND b.loc = 'Esch-sur-Alzette')
		OR (p.name = 'Biekerech' AND b.loc = 'Beckerich')
		OR (p.name IN ('Esch-Uelzecht', 'Lëtzebuerg') AND b.loc = 'Luxembourg
Esch/Alzette')
		OR (p.name = 'Kielen' AND b.loc = 'Kehlen')
		OR (p.name = 'Réiden' AND b.loc = 'Redange')
	)
),
vw AS (
	SELECT
		transaction_id,
		project_title AS project_name,
		beneficiary_name,
		population_multiplier * total_amount AS total_ammount,
		population_multiplier * eu_amount AS eu_cofinancing_amount,
		population_multiplier * eu_amount AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'LU' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS geocoding_state,
		NULL AS beneficiary_postal_code,
		NULL AS beneficiary_lau2,
		NULL AS project_state,
		NULL AS project_region,
		NULL AS project_county,
		loc_name AS project_city,
		NULL AS project_nuts3,
		shape_lau AS project_lau2,
		NULL AS project_postal_code,
		NULL AS project_address,
		start_date AS start_date,
		end_date AS end_date,
		'lau2' AS geolocation_in_source,
		distributed AS distributed
	FROM city_loc
)

SELECT * FROM vw