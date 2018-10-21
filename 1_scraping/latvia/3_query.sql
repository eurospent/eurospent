INSERT INTO public."lv_final" (
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
  project_state,
  project_region,
  project_county,
  project_nuts3,
  project_city,
  project_lau2,
  country,
  country_code,
  beneficiary_country_code,
  contract_date,
  beneficiary_address
)
WITH
pre_population AS (
  SELECT
    *,
    CASE
      WHEN population < 1 THEN 1
      ELSE population
    END AS population_corr
  FROM lv_population
),

base AS (
  SELECT
    *,
    md5(CONCAT('LV',ROW_NUMBER() OVER ()::text)) AS transaction_id,
    CASE
      WHEN project_region LIKE '%Visa Latvija%' THEN 'Visa Latvija'
      ELSE project_region
    END AS project_region_corr    
  FROM lv_transactions
),

regions AS (
  SELECT DISTINCT
    *,
    TRIM(unnest(string_to_array(project_region_corr,','))) AS nuts3
  FROM base
),

regions_corrected AS (
  SELECT
    *,
    CASE
      WHEN nuts3 = 'Rīgas reģions' THEN 'Pierīga'
      ELSE nuts3
    END AS nuts3_corr
  FROM regions
),

national_projects AS (
  SELECT
    r.*,
    p.*,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY r.transaction_id) * r.total_amount AS total_amount_d,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY r.transaction_id) * r.eu_cofinancing_amount AS eu_cofinancing_amount_d,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY r.transaction_id) * r.member_state_amount AS amount_d
  FROM regions_corrected AS r
  CROSS JOIN pre_population AS p
  WHERE r.nuts3 = 'Visa Latvija'
),

nuts3_projects AS (
  SELECT
     r.*,
     p.*,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY r.transaction_id) * r.total_amount AS total_amount_d,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY r.transaction_id) * r.eu_cofinancing_amount AS eu_cofinancing_amount_d,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY r.transaction_id) * r.member_state_amount AS amount_d
   FROM regions_corrected AS r
   LEFT JOIN pre_population AS p ON LOWER(r.nuts3_corr) = LOWER(p.nuts3_name)
   WHERE r.nuts3 != 'Visa Latvija'
),

all_transactions AS (
  SELECT * FROM national_projects
  UNION ALL
  SELECT * FROM nuts3_projects
),

vw AS (
  SELECT
    transaction_id,
    project_title As project_name,
    beneficiary AS beneficiary_name,
    total_amount_d AS total_amount,
    eu_cofinancing_amount_d AS eu_cofinancing_amount,
    amount_d AS amount,
    'memeber state contribution' AS amount_kind,
    UNACCENT(LOWER(beneficiary)) AS beneficiary_id,
    CASE
      WHEN fund_acronym = 'KF' THEN 'CF'
      WHEN fund_acronym = 'ESF' THEN 'ESF'
      WHEN fund_acronym = 'ERAF' THEN 'ERDF'
      ELSE 'ERDF'
    END AS fund_acronym,
    '2017-2013' AS funding_period,
    nuts1_name AS project_state,
    nuts2_name AS project_region,
    nuts3_name AS project_county,
    nuts3_code AS project_nuts3,
    lau2_name AS project_city,
    lau2_code AS project_lau2,
    'Latvia' AS country,
    'LV' AS country_code,
    'LV' AS beneficiary_country_code,
    contract_date,
    beneficiary_address
  FROM all_transactions
)

SELECT * FROM vw;