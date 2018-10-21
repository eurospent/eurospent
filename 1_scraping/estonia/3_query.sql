INSERT INTO public."final" (
  transaction_id,
  project_name,
  beneficiary_name,
  total_amount,
  eu_cofinancing_amount,
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
  beneficiary_country_code,
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
  FROM ee_population
),

base AS (
  SELECT
    t.*,
    md5(CONCAT('EE',ROW_NUMBER() OVER ()::text)) AS transaction_id,
    r.region_corr
  FROM ee_transactions AS t
  LEFT JOIN ee_region_translator AS r ON t.region = r.region
  WHERE t.end_date > '2006-12-31'
    AND t.start_date < '2014-01-01'
    AND t.fund_acronym IN ('ERDF', 'ESF', 'CF')
),

base_split AS (
  SELECT
    *,
    TRIM(UNNEST(STRING_TO_ARRAY(region_corr,','))) AS region_split
  FROM base
  UNION ALL
  SELECT
    *,
    NULL::text
  FROM base
  WHERE region_corr IS NULL
),

national_projects AS (
  SELECT
    t.*,
    p.*,
    TRUE AS distributed,
    'national' AS geolocation_in_source
  FROM base_split AS t
  CROSS JOIN pre_population AS p
  WHERE t.region_split IS NULL
    OR t.region_split = 'Üleriigilised projektid'
),

lau1_projects AS (
  SELECT
    t.*,
    p.*,
    TRUE AS distributed,
    'lau1' AS geolocation_in_source
  FROM base_split AS t
  LEFT JOIN pre_population AS p ON t.region_split = p.lau1_name
  WHERE LOWER(t.region_split) LIKE '%maakond%'
    AND (t.region_split IS NOT NULL AND t.region_split != 'Üleriigilised projektid')
),

lau2_projects AS (
  SELECT
    t.*,
    p.*,
    TRUE AS distributed,
    'lau2' AS geolocation_in_source
  FROM base_split AS t
  LEFT JOIN pre_population AS p ON t.region_split = p.lau2_name
  WHERE LOWER(t.region_split) NOT LIKE '%maakond%'
    AND t.region_split IS NOT NULL
    AND t.region_split != 'Üleriigilised projektid'
),

all_transactions AS (
  SELECT * FROM national_projects
  UNION ALL
  SELECT * FROM lau1_projects
  UNION ALL
  SELECT * FROM lau2_projects
),

all_transaction_sums AS (
  SELECT
    *,
    population_corr*1.0 / SUM(population_corr) OVER (PARTITION BY transaction_id) * total_amount AS total_amount_d,
    population_corr*1.0 / SUM(population_corr) OVER (PARTITION BY transaction_id) * eu_cofinancing_amount AS eu_cofinancing_amount_d
  FROM all_transactions
),

vw AS (
  SELECT
    transaction_id,
    project_name,
    beneficiary AS beneficiary_name,
    total_amount_d AS total_amount,
    eu_cofinancing_amount_d AS eu_cofinancing_amount,
    UNACCENT(LOWER(beneficiary)) AS beneficiary_id,
    fund_acronym,
    '2017-2013' AS funding_period,
    distributed,
    geolocation_in_source,
    nuts1_name AS project_state,
    nuts2_name AS project_region,
    nuts3_name AS project_county,
    nuts3_code AS project_nuts3,
    lau2_name AS project_city,
    lau2_code AS project_lau2,
    'Estonia' AS country,
    'EE' AS country_code,
    'EE' AS beneficiary_country_code,
    start_date,
    end_date
  FROM all_transaction_sums
)

SELECT * FROM vw