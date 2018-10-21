WITH 
lau1 AS (
	SELECT distinct "RS,C,12" AS lau1_code, "GEN,C,50" AS lau1_name
	FROM "1_lau1"
),
base AS (
	SELECT p.*, n.*,
		CASE 
			WHEN t."AREA" IS NULL AND shape_lau = 'DE141_08415971' THEN '64630000'
			WHEN t."AREA" IS NULL AND shape_lau = 'DED2C_14625525' THEN '8480000'
			WHEN t."AREA" IS NULL AND shape_lau = 'DED2D_14626085' THEN '20450000'
			WHEN t."AREA" IS NULL AND shape_lau = 'DED44_14523365' THEN '67340000'
			WHEN t."AREA" IS NULL AND shape_lau = 'DEE0B_15088216' THEN '126900000'
			WHEN t."AREA" IS NULL AND shape_lau = 'DEE0D_15090546' THEN '31180000'
			WHEN t."AREA" IS NULL AND shape_lau = 'DEE0E_15091241' THEN '115200000'
			WHEN t."AREA" IS NULL AND shape_lau = 'DEE0E_15091391' THEN '148500000'
			WHEN t."AREA" IS NULL AND shape_lau = 'DEG06_16061116' THEN '31340000'
			WHEN t."AREA" IS NULL AND shape_lau = 'DEG07_16062064' THEN '20960000'
			ELSE t."AREA"
		END AS area_fix,
		CASE 
			WHEN COALESCE(l.lau1_code, l2.lau1_code) IS NOT NULL THEN COALESCE(l."lau1_name", l2."lau1_name")
			WHEN COALESCE(t2."LAU1_NAT_CODE", t."LAU1_NAT_CODE") = '160695052' THEN 'Schleusingen, Stadt'
			WHEN COALESCE(t2."LAU1_NAT_CODE", t."LAU1_NAT_CODE") IS NOT NULL AND COALESCE(t2."LAU1_NAT_CODE", t."LAU1_NAT_CODE") != 'n.a.' THEN p.name
			ELSE NULL
		END AS lau1_name,
		CASE 
			WHEN COALESCE(l.lau1_code, l2.lau1_code) IS NOT NULL THEN COALESCE(l.lau1_code, l2.lau1_code)
			WHEN COALESCE(t2."LAU1_NAT_CODE", t."LAU1_NAT_CODE") != 'n.a.' THEN COALESCE(t2."LAU1_NAT_CODE", t."LAU1_NAT_CODE")
			ELSE NULL
		END AS lau1_code
	FROM "1_population" AS p
	LEFT JOIN "1_nuts" AS n ON p.shape_lau LIKE n.nuts3 || '%'
	LEFT JOIN "1_territory" AS t ON p.lau = t."LAU2_NAT_CODE"
	LEFT JOIN "lau1" AS l ON l."lau1_code" = t."LAU1_NAT_CODE"
	LEFT JOIN "old_1_territory" AS t2 ON l."lau1_code" IS NULL AND p.lau = t2."LAU2_NAT_CODE"
	LEFT JOIN "lau1" AS l2 ON l."lau1_code" IS NULL AND l2."lau1_code" = t2."LAU1_NAT_CODE"
	where p.shape_lau LIKE 'DE%'
),
vw AS (
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
		round("area_fix"::INT * 1.0 / 1000000, 2) AS territory,
		round((population::INT * 1.0) / ("area_fix"::INT * 1.0 / 1000000), 2) AS density
	FROM base
)
SELECT * FROM vw 
