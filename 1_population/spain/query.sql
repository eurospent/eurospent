WITH 
base AS (
	SELECT * 
	FROM "1_es_nuts" AS n
	LEFT JOIN "1_population" AS p ON p.shape_lau LIKE 'ES%' AND p.shape_lau LIKE n.nuts3 || '%'
	LEFT JOIN "1_territory" AS t ON p.lau = t."LAU2_NAT_CODE"
	
)
SELECT 
	nuts1_name,
	nuts1 AS nuts1_code,
	nuts2_name,
	nuts2 AS nuts2_code,
	nuts3_name,
	nuts3 AS nuts3_code,
	nuts3_name AS lau1_name,
	nuts3 AS lau1_code,
	"name" AS lau2_name,
	shape_lau AS lau2_code,
	population,
	round("AREA"::INT * 1.0 / 1000000, 2) AS territory,
	round((population::INT * 1.0) / ("AREA"::INT * 1.0 / 1000000), 2) AS density
FROM base
