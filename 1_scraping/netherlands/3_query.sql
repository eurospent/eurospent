WITH 
population AS (
	SELECT 
		* 
	FROM "1_population"
	WHERE shape_lau LIKE 'NL%'
),
erdf AS (
	SELECT 
		md5('NL' || 'ERDF' || (row_number() OVER ())::VARCHAR) AS transaction_id,
		*
	FROM "1_erdf_transactions"
),
esf AS (
	SELECT 
		md5('NL' || 'ESF' || (row_number() OVER ())::VARCHAR) AS transaction_id,
		e.*
	FROM "1_esf_transactions" as e
),
vw_erdf AS (
	SELECT 
		transaction_id,
		project_name,
		COALESCE(beneficiary_name, project_name) AS beneficiary_name,
		fund AS fund,
		eu_amount::INT AS eu_amount,
		CASE 
			WHEN public_cofinancing IS NOT NULL OR private_cofinancing IS NOT NULL THEN 
				eu_amount::INT + COALESCE(public_cofinancing, '0')::INT + COALESCE(private_cofinancing, '0')::INT 
			ELSE NULL
		END AS full_amount,
		replace(replace(replace(replace(replace(replace(replace(replace(
			trim(substring(duration from 'van(.+)tot')),
			'januari', 'january'),
			'februari', 'february'),
			'maart', 'march'),
			'mei', 'may'),
			'juni', 'jun'),
			'juli', 'july'),
			'augustus', 'august'),
			'oktober', 'october')::DATE
		AS start_date,
		nullif(replace(replace(replace(replace(replace(replace(replace(replace(
			trim(substring(duration from 'tot(.+)')),
			'januari', 'january'),
			'februari', 'february'),
			'maart', 'march'),
			'mei', 'may'),
			'juni', 'jun'),
			'juli', 'july'),
			'augustus', 'august'),
			'oktober', 'october'), '-')::DATE
		AS end_date,
		address AS loc,
		NULL AS shape_lau,
		NULL AS population,
		lat::NUMERIC,
		long::NUMERIC,
		fund AS program
	FROM erdf
	WHERE (fund = 'INTERREG' AND
		(lat IS NOT NULL
		AND long::NUMERIC >= 3.358333 AND long::NUMERIC <= 7.227778
		AND lat::NUMERIC >= 50.750417 AND lat::NUMERIC <= 53.555))
		OR fund != 'INTERREG'
),
vw_esf AS (
	SELECT 
		transaction_id,
		project_name,
		beneficiary_name,
		'ESF' AS fund,
		final_eu_amount::INT AS eu_amount,
		final_eu_amount::INT + final_eligible_expenditure::INT AS full_amount,
		CASE 
			WHEN start_date NOT LIKE '____-__-__' THEN ('20' || SUBSTRING(start_date, 7, 2) || '-' || SUBSTRING(start_date, 4, 2) || '-' || SUBSTRING(start_date, 0, 3))::DATE
			ELSE start_date::DATE
		END AS start_date,
		end_date::DATE AS end_date,
		COALESCE(p.name, "location") AS loc,
		p.shape_lau,
		p.population,
		NULL::NUMERIC AS lat,
		NULL::NUMERIC AS long,
		NULL::VARCHAR AS program
	FROM esf AS e
	LEFT JOIN population AS p ON trim(lower(e.location)) = lower(p.name)
),
vw AS (
	SELECT * FROM vw_erdf
	UNION ALL 
	SELECT * FROM vw_esf
)
SELECT * 
INTO vw_nl_union 
FROM vw;


