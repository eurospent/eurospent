WITH 
transactions AS (
    SELECT * 
    FROM address AS a
    LEFT JOIN transaction_amount as ta ON a.address_id = ta.address_id
    LEFT JOIN "transaction" as t ON t.transaction_id = ta.transaction_id
    WHERE a.lau2_code IS NOT NULL and address_type = 'project'
        AND t.country_code = 'FR'
),

project_lau AS (
    SELECT 
        lau2_code AS lau,
        sum(COALESCE(eu_cofinancing_amount, amount, total_amount, 0)) as sum_amount
    FROM transactions
    GROUP BY 1
)

SELECT 'FR' AS query_country_code, lau AS lau, sum(sum_amount) AS sum 
FROM project_lau
GROUP BY 1,2;
