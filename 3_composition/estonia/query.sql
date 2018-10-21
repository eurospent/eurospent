WITH
transactions AS (
    SELECT * 
    FROM transactions 
    WHERE country = 'Estonia'
),
 
project_lau AS (
    SELECT
        project_lau2 AS lau,
        sum(COALESCE(eu_cofinancing_amount, amount, total_ammount, 0)) as sum_amount
    FROM transactions
    WHERE project_lau2 IS NOT NULL
    GROUP BY 1
)
 
SELECT 'EE' AS query_country_code, lau AS lau, round(sum(sum_amount)) AS sum
FROM project_lau
GROUP BY 1,2;