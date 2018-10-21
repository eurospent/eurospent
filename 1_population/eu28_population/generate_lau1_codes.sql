WITH
base AS (
  SELECT
    *,
    CASE
      WHEN nuts0_code IN ('CY', 'DK', 'EE', 'FI', 'FR', 'DE', 'EL', 'HU', 'IE', 'LT', 'LU', 'PL', 'PT', 'SK', 'SI', 'SE') THEN CONCAT(nuts3_code, '_', lau1_code)
      ELSE lau1_code
    END AS lau1_code_corrected
  FROM eu28_population
),

vw AS (
  SELECT
    nuts0_name,
    nuts0_code,
    nuts1_name,
    nuts1_code,
    nuts2_name,
    nuts2_code,
    nuts3_name,
    nuts3_code,
    lau1_name,
    lau1_code_corrected AS lau1_code,
    lau2_name,
    lau2_code,
    population,
    territory,
    density
  FROM base
)

SELECT * FROM vw;