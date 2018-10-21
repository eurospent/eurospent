WITH
pre_population AS (
SELECT
  *,
  CASE
    WHEN population >= 1 THEN population
    ELSE 1
  END AS population_corrected
FROM eu28_population
),

transactions AS (
  SELECT
    *
  FROM eu28_transactions
),

vw AS (
  SELECT
    t.query_country_code,
    p.nuts3_code,
    --p.population,
    SUM(t.sum) AS sum
  FROM transactions AS t
  LEFT JOIN pre_population AS p ON t.lau = p.lau2_code
  GROUP BY 1,2
)

SELECT * FROM vw
ORDER BY 3 DESC;