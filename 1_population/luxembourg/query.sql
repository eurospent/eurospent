WITH 
base AS (
	SELECT * 
	FROM "1_population" AS p
	LEFT JOIN "1_territory" AS n ON p.lau = n."LAU2_NAT_CODE"
	WHERE p.shape_lau LIKE 'LU%'

),
vw AS (
	SELECT 
		'Luxembourg' AS nuts1_name,
		'LU0' AS nuts1_code,
		'Luxembourg' AS nuts2_name,
		'LU00' AS nuts2_code,
		'Luxembourg' AS nuts3_name,
		'LU000' AS nuts3_code,
		CASE "LAU1_NAT_CODE" 
			WHEN '00' THEN 'Luxembourg'
			WHEN '02' THEN 'Capellen'
			WHEN '03' THEN 'Esch-sur-Alzette'
			WHEN '04' THEN 'Luxembourg (canton)'
			WHEN '05' THEN 'Mersch'
			WHEN '06' THEN 'Clervaux'
			WHEN '07' THEN 'Diekirch'
			WHEN '08' THEN 'Redange'
			WHEN '09' THEN 'Wiltz'
			WHEN '10' THEN 'Vianden'
			WHEN '11' THEN 'Echternach'
			WHEN '12' THEN 'Grevenmacher'
			WHEN '13' THEN 'Remich'
		END AS lau1_name,
		"LAU1_NAT_CODE" AS lau1_code,
		"name" AS lau2_name,
		shape_lau AS lau2_code,
		population,
		round("AREA"::INT * 1.0 / 1000000, 2) AS territory,
		round((population::INT * 1.0) / ("AREA"::INT * 1.0 / 1000000), 2) AS density
	FROM base
)
SELECT * FROM vw order by lau1_code, lau2_name