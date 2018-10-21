INSERT INTO public."final" (
  transaction_id,
  project_name,
  beneficiary_name,
  total_amount,
  eu_cofinancing_amount,
  amount,
  amount_kind,
  beneficiary_id,
  fund_acronym,
  funding_period,
  distributed,
  geolocation_in_source,
  project_state,
  project_region,
  project_county,
  project_nuts3,
  project_city,
  project_lau2,
  country,
  country_code,
  start_date,
  end_date
)
WITH
pre_population AS (
  SELECT
    *,
    CASE
      WHEN population > 0 THEN population
      ELSE 1
    END AS population_corr
  FROM gr_population
),

base AS (
  SELECT DISTINCT
    md5(CONCAT('EL',transaction_id)) AS transaction_id,
    project_name,
    beneficiary_name,
    budget,
    contracts,
    payments,
    start_date,
    end_date,
    lau1_code,
    CASE
      WHEN region = '0' THEN NULL
      WHEN region = '1' THEN 'EL51'
      WHEN region = '2' THEN 'EL52'
      WHEN region = '3' THEN 'EL53'
      WHEN region = '4' THEN 'EL54'
      WHEN region = '5' THEN 'EL61'
      WHEN region = '6' THEN 'EL62'
      WHEN region = '7' THEN 'EL63'
      WHEN region = '8' THEN 'EL64'
      WHEN region = '9' THEN 'EL41'
      WHEN region = '10' THEN 'EL65'
      WHEN region = '11' THEN 'EL41'
      WHEN region = '12' THEN 'EL42'
      WHEN region = '13' THEN 'EL43'
      ELSE NULL
    END AS region
  FROM gr_locations
),

lau1 AS (
  SELECT
    b.*,
    NULL::int AS total_amount, 
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.payments AS eu_cofinancing_amount,  
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.budget AS amount,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    true::BOOL AS distributed,
    'lau1'::TEXT AS geolocation_in_source
  FROM base AS b
  INNER JOIN pre_population AS p ON b.lau1_code = p.lau1_code
WHERE b.lau1_code IS NOT NULL
),

undefined_nuts2 AS (
  SELECT
    b.*,
    NULL::int AS total_amount, 
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.payments AS eu_cofinancing_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.budget AS amount,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    true::BOOL AS distributed,
   'nuts2'::TEXT AS geolocation_in_source
  FROM base AS b
  INNER JOIN pre_population AS p ON b.region = p.nuts2_code
  LEFT JOIN lau1 AS l ON b.transaction_id = l.transaction_id
  WHERE b.region IS NOT NULL
    AND b.lau1_code IS NULL
    AND l.transaction_id IS NULL
),

undefined_national AS (
  SELECT
    b.*,
    NULL::int AS total_amount, 
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.payments AS eu_cofinancing_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.budget AS amount,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    true::BOOL AS distributed,
    'national'::TEXT AS geolocation_in_source
  FROM base AS b
  CROSS JOIN pre_population AS p
  LEFT JOIN lau1 AS l ON b.transaction_id = l.transaction_id
  LEFT JOIN undefined_nuts2 AS n ON b.transaction_id = n.transaction_id
  WHERE b.region IS NULL
    AND b.lau1_code IS NULL
    AND l.transaction_id IS NULL
    AND n.transaction_id IS NULL
),

transactions_distributed AS (
  SELECT * FROM undefined_national
  UNION ALL
  SELECT * FROM undefined_nuts2
  UNION ALL
  SELECT * FROM lau1
),

vw AS (
  SELECT
    transaction_id,
    project_name,
    beneficiary_name,
    total_amount,
    eu_cofinancing_amount,
    amount,
    'budget_appproved_by_eu' AS amount_kind,
    LOWER(UNACCENT(beneficiary_name)) AS beneficiary_id,
    NULL::text AS fund_acronym,
    '2007-2013' AS funding_period,
    distributed,
    geolocation_in_source,
    project_state,
    project_region,
    project_county,
    project_nuts3,
    project_city,
    project_lau2,
    'Greece' AS country,
    'EL' AS country_code,
    start_date,
    end_date
  FROM transactions_distributed 
)

SELECT * FROM vw;