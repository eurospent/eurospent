WITH 
fix_nuts AS (
	SELECT 
		*,
		CASE nuts3
			WHEN 'NL331' THEN 'NL337'
			WHEN 'NL334' THEN 'NL338'
			WHEN 'NL335' THEN 'NL339'
			WHEN 'NL336' THEN 'NL33A'
			ELSE nuts3
		END AS nuts3_fix
	FROM "1_nuts" AS n
),
base AS (
	SELECT *, COALESCE(t."AREA", t2."AREA") AS area_fix
	FROM "fix_nuts" AS n
	LEFT JOIN "1_population" AS p ON p.shape_lau LIKE 'NL%' AND p.shape_lau LIKE n.nuts3_fix || '%'
	LEFT JOIN "1_territory" AS t ON p.lau = t."LAU2_NAT_CODE"
	LEFT JOIN "old_1_territory" AS t2 ON t."AREA" IS NULL AND p.lau = t2."LAU2_NAT_CODE"
)
SELECT 
	nuts1_name,
	nuts1 AS nuts1_code,
	nuts2_name,
	nuts2 AS nuts2_code,
	nuts3_name,
	nuts3_fix AS nuts3_code,
	nuts3_name AS lau1_name,
	nuts3 AS lau1_code,
	"name" AS lau2_name,
	shape_lau AS lau2_code,
	population,
	round(area_fix::INT * 1.0 / 1000000, 2) AS territory,
	round((population::INT * 1.0) / (area_fix::INT * 1.0 / 1000000), 2) AS density
FROM base