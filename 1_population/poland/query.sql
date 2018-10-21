WITH 
base AS (
	SELECT 
		*,
		CASE WHEN "AREA" IS NULL THEN '84700000' ELSE "AREA" END AS area_fix,
		CASE WHEN "LAU1_NAT_CODE" IS NULL THEN '5020321' ELSE "LAU1_NAT_CODE" END AS lau1_fix
	FROM "1_nuts" AS n
	LEFT JOIN "1_population" AS p ON p.shape_lau LIKE 'PL%' AND p.shape_lau LIKE n.nuts3 || '%'
	LEFT JOIN "1_territory" AS t ON p.lau = t."LAU2_NAT_CODE"
),
lau1 AS (
	SELECT REPLACE(SUBSTRING("NTS 4", 2, LENGTH("NTS 4")), '.', '') AS lau1_code, f8 AS lau1_name
	FROM "1_lau1" 
	WHERE "NTS 4" IS NOT NULL
),
add_lau1 AS (
	SELECT *
	FROM base AS b
	LEFT JOIN lau1 AS l ON b.lau1_fix = lau1_code
)
SELECT 
	nuts1_name,
	nuts1 AS nuts1_code,
	nuts2_name,
	nuts2 AS nuts2_code,
	nuts3_name,
	nuts3 AS nuts3_code,
	lau1_name AS lau1_name,
	lau1_code AS lau1_code,
	"name" AS lau2_name,
	shape_lau AS lau2_code,
	population,
	round("area_fix"::INT * 1.0 / 1000000, 2) AS territory,
	round((population::INT * 1.0) / ("area_fix"::INT * 1.0 / 1000000), 2) AS density
FROM add_lau1
