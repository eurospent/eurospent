WITH 
base AS (
	SELECT n.*, p.*, t.*,
		CASE 
			WHEN p.lau = '946' THEN '1499910000'
			ELSE "AREA"
		END AS area_fix,
		CASE WHEN "LAU1_NAT_CODE" IS NULL THEN '152' ELSE "LAU1_NAT_CODE" END AS lau1_code,
		l.name AS lau1_name
	FROM "1_nuts" AS n
	LEFT JOIN "1_population" AS p ON p.shape_lau LIKE 'FI%' AND p.shape_lau LIKE n.nuts3 || '%'
	LEFT JOIN "1_territory" AS t ON p.lau = trim(t."LAU2_NAT_CODE")
	LEFT JOIN "1_lau1" AS l ON l.code = (CASE WHEN "LAU1_NAT_CODE" IS NULL THEN '152' ELSE "LAU1_NAT_CODE" END)
	
),
vw AS (
	SELECT 
		nuts1_name,
		nuts1 AS nuts1_code,
		nuts2_name,
		nuts2 AS nuts2_code,
		nuts3_name,
		nuts3 AS nuts3_code,
		lau1_name,
		lau1_code,
		"name" AS lau2_name,
		shape_lau AS lau2_code,
		population,
		round("area_fix"::BIGINT * 1.0 / 1000000, 2) AS territory,
		round((population::INT * 1.0) / ("area_fix"::BIGINT * 1.0 / 1000000), 2) AS density
	FROM base
	
)
SELECT * 
FROM vw 