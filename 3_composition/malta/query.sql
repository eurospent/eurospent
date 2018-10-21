WITH
transactions AS (
    SELECT * 
    FROM transactions 
    WHERE country = 'Malta'
),
 
project_lau AS (
    SELECT
        COALESCE(project_lau2, beneficiary_lau2) AS lau,
        SUM(COALESCE(eu_cofinancing_amount, amount, total_amount, 0)) as sum_amount
    FROM transactions
    GROUP BY 1
)
 
SELECT 'MT' AS query_country_code, lau AS lau, ROUND(SUM(sum_amount)) AS sum
FROM project_lau
GROUP BY 1,2;