WITH
transactions AS (
    SELECT * 
    FROM transactions 
    WHERE country = 'Cyprus'
),
 
project_lau AS (
    SELECT
        COALESCE(project_lau2, beneficiary_lau2) AS lau,
        SUM(COALESCE(total_amount, eu_cofinancing_amount, amount, 0)) as sum_amount
    FROM transactions
    GROUP BY 1
)
 
SELECT 'CY' AS query_country_code, lau AS lau, ROUND(SUM(sum_amount)) AS sum
FROM project_lau
GROUP BY 1,2;