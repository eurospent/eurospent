SELECT 
	p.nuts0_code AS country_code,
	p.lau2_code AS code,
	ROUND(SUM(COALESCE(b.sum, '0')::NUMERIC), 2) AS sum
INTO lau2
FROM "2_eu28_population" AS p
LEFT JOIN "2_lau2" AS b ON p.lau2_code = b.code
GROUP BY 1,2
ORDER BY 1,2;

SELECT 
	p.nuts0_code AS country_code,
	p.lau1_code AS code,
	ROUND(SUM(COALESCE(b.sum, '0')::NUMERIC), 2) AS sum
INTO lau1
FROM "2_eu28_population" AS p
LEFT JOIN "2_lau2" AS b ON p.lau2_code = b.code
GROUP BY 1,2
ORDER BY 1,2;

SELECT 
	p.nuts0_code AS country_code,
	p.nuts3_code AS code,
	ROUND(SUM(COALESCE(b.sum, '0')::NUMERIC), 2) AS sum
INTO nuts3
FROM "2_eu28_population" AS p
LEFT JOIN "2_lau2" AS b ON p.lau2_code = b.code
GROUP BY 1,2
ORDER BY 1,2;

SELECT 
	p.nuts0_code AS country_code,
	p.nuts2_code AS code,
	ROUND(SUM(COALESCE(b.sum, '0')::NUMERIC), 2) AS sum
INTO nuts2
FROM "2_eu28_population" AS p
LEFT JOIN "2_lau2" AS b ON p.lau2_code = b.code
GROUP BY 1,2
ORDER BY 1,2;

SELECT 
	p.nuts0_code AS country_code,
	p.nuts1_code AS code,
	ROUND(SUM(COALESCE(b.sum, '0')::NUMERIC), 2) AS sum
INTO nuts1
FROM "2_eu28_population" AS p
LEFT JOIN "2_lau2" AS b ON p.lau2_code = b.code
GROUP BY 1,2
ORDER BY 1,2;

SELECT 
	p.nuts0_code AS country_code,
	p.nuts0_code AS code,
	ROUND(SUM(COALESCE(b.sum, '0')::NUMERIC), 2) AS sum
INTO nuts0
FROM "2_eu28_population" AS p
LEFT JOIN "2_lau2" AS b ON p.lau2_code = b.code
GROUP BY 1,2
ORDER BY 1,2;