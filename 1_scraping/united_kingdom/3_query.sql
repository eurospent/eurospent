INSERT INTO public."uk_final" (
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
  start_date,
  end_date
)


WITH
pre_population AS (
  SELECT
    *,
    CASE
      WHEN population < 1 THEN 1
      ELSE population
    END AS population_corr
  FROM uk_population
),

--total_amount conversion is calculated on the basis of the daily GBP-EUR average rates between 2007-2013, downloaded from:
--https://www.investing.com/currencies/gbp-eur-historical-data.
base AS (
  SELECT
    md5(CONCAT('UK',ROW_NUMBER() OVER ()::text)) AS transaction_id,
    project AS project_name,
    CASE
      WHEN RIGHT(organization,6) ~ '^([0-9]+[.]?[0-9]*|[.][0-9]+)$' THEN SUBSTRING(organization,1,(LENGTH(organization)-7))
      ELSE organization
    END AS beneficiary_name,
    CASE
      WHEN total = 0 THEN (subsidy+matching)/1.2246702791
      ELSE total/1.2246702791
    END AS total_amount,
    subsidy/1.2246702791 AS eu_cofinancing_amount,
    CASE
      WHEN matching = 0 AND total != subsidy AND total != 0 THEN (total-subsidy)/1.2246702791
      ELSE matching/1.2246702791
    END AS amount,
    'member_state_contribution' AS amount_kind,
    CASE
      WHEN RIGHT(organization,6) ~ '^([0-9]+[.]?[0-9]*|[.][0-9]+)$' THEN LOWER(SUBSTRING(organization,1,(LENGTH(organization)-7)))
      ELSE LOWER(organization)
    END AS beneficiary_id,
    fund_type AS fund_acronym,
    '2007-2013' AS funding_period,
    state AS project_state,
    region AS project_region,
    start_date,
    end_date,
    organization
  FROM uk_transactions
),

councils AS (
  SELECT
    *,
    TRIM(unnest(string_to_array(codes,','))) AS region_code
  FROM uk_beneficiary_translate
  WHERE org_type = 'council'
),

base_paired AS (
  SELECT
    b.*,
    c.region_code,
    c.distribution_type
  FROM base AS b
  LEFT JOIN councils AS c ON b.organization = c.organization
),

base_distributed AS (
  SELECT
    b.*,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id) * b.total_amount AS total_amount_d,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id) * b.eu_cofinancing_amount AS eu_cofinancing_amount_d,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id) * b.amount AS amount_d,
    p.*
  FROM base_paired AS b
  LEFT JOIN pre_population AS p ON
    CASE
      WHEN b.distribution_type = 'nuts1' AND b.region_code = p.nuts1_code THEN 1
      WHEN b.distribution_type = 'nuts2' AND b.region_code = p.nuts2_code THEN 1
      WHEN b.distribution_type = 'nuts3' AND b.region_code = p.nuts3_code THEN 1
      WHEN b.distribution_type = 'lau1' AND b.region_code = p.lau1_code THEN 1
      WHEN b.distribution_type = 'lau2' AND b.region_code = p.lau2_code THEN 1
      ELSE 0
    END = 1
),

vw AS (
  SELECT
    transaction_id,
    project_name,
    beneficiary_name,
    CASE
      WHEN lau2_code IS NOT NULL THEN total_amount_d
      ELSE total_amount
    END AS total_amount,
    CASE
      WHEN lau2_code IS NOT NULL THEN eu_cofinancing_amount_d
      ELSE eu_cofinancing_amount
    END AS eu_cofinancing_amount,
    CASE
      WHEN lau2_code IS NOT NULL THEN amount_d
      ELSE amount
    END AS amount,
    amount_kind,
    beneficiary_id,
    fund_acronym,
    funding_period,
    REPLACE(project_state, 'N/A','') AS project_state,
    REPLACE(project_region, 'N/A','') AS project_region,
    nuts3_name AS project_county,
    nuts3_code AS project_nuts3,
    lau2_name AS project_city,
    lau2_code AS project_lau2,
    'United Kingdom' AS country,
    'UK' AS country_code,
    'UK' AS beneficiary_country_code,
    start_date,
    end_date
  FROM base_distributed
)

SELECT * FROM vw;