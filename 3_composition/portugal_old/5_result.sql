WITH 

transactions AS (
	SELECT * 
	FROM transactions 
	WHERE country = 'Portugal'
),

geocode AS (
	SELECT * 
	FROM beneficiary_geocode 
	WHERE query_country = 'Portugal' 
		and lau is not null
		and query_type = 'project'
),

project_lau AS (
	SELECT 
		project_lau2 AS lau,
		sum(COALESCE(eu_cofinancing_amount, amount, total_ammount, 0)) as sum_amount
	FROM transactions
	WHERE project_lau2 IS NOT NULL
	GROUP BY 1
),

pre_beneficiary AS (
	SELECT DISTINCT ON (t.id)
		t.id,
		t.transaction_id,
		b.lau,
		COALESCE(eu_cofinancing_amount, amount, total_ammount, 0) as amount
	FROM transactions as t
	INNER JOIN geocode as b ON t.beneficiary_id = b.beneficiary_id
	WHERE t.project_lau2 IS NULL
),

beneficiary AS (
	SELECT 
		lau, 
		sum(amount) as sum_amount 
	FROM pre_beneficiary
	GROUP BY 1
)

SELECT 'PT' AS query_country_code, lau, sum(sum_amount) AS sum 
FROM (
SELECT * FROM project_lau
UNION
SELECT * FROM beneficiary
) as vw
GROUP BY 1,2;
