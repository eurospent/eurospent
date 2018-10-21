INSERT INTO public."lt_final" (
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
      WHEN population > 0 THEN population
      ELSE 1
    END AS population_corr
  FROM lt_population
),

transactions_base AS (
  SELECT
    md5(CONCAT('LT',ROW_NUMBER() OVER ()::text)) AS transaction_id,
    *
  FROM lt_transactions
),

distributed AS (
  SELECT
    p.*,
    t.*,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.total_paid AS total_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.eu_paid AS eu_cofinancing_amount
  FROM pre_population AS p
  INNER JOIN transactions_base AS t ON REPLACE(p.lau1_name,' savivaldybė','') = REPLACE(t.lau1, 'raj.', 'rajono')
),

vw AS (
  SELECT
    transaction_id,
    project_title AS project_name,
    beneficiary AS beneficiary_name,
    total_amount,
    eu_cofinancing_amount,
    total_amount - eu_cofinancing_amount As amount,
    'Member_state_contribution' AS amount_kind,
    UNACCENT(beneficiary) AS beneficiary_id,
    NULL AS fund_acronym,
    '2007-2013' AS funding_period,
    nuts1_name AS project_state,
    nuts2_name AS project_region,
    nuts3_name AS project_county,
    nuts3_code AS project_nuts3,
    lau2_name AS project_city,
    lau2_code AS project_lau2,
    'Lithuania' AS country,
    'LT' AS country_code,
    'LT' AS beneficiary_country_code,
    start_date,
    end_date
  FROM distributed
)

SELECT * FROM vw;