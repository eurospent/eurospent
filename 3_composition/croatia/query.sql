WITH 

transactions AS (
	SELECT * 
	FROM transactions 
	WHERE country = 'Croatia'
),

project_lau AS (
	SELECT 
		project_lau2 AS lau,
		ROUND(sum(COALESCE(eu_cofinancing_amount, amount, total_amount, 0))) as sum_amount
	FROM transactions
	WHERE project_lau2 IS NOT NULL
	GROUP BY 1
)

SELECT 'HR' AS query_country_code, lau AS lau, sum(sum_amount) AS sum 
FROM project_lau
GROUP BY 1,2;
