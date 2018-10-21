INSERT INTO final (
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
  FROM hr_population
),

base AS (
  SELECT
    md5(CONCAT('CY',ROW_NUMBER() OVER()::text)) AS transaction_id,
    *
  FROM hr_transactions  
),

--total_amount conversion is calculated on the basis of the daily HUF-EUR average rates between 2007-2013, downloaded from:
--https://www.investing.com/currencies/eur-hrk-historical-data.

vw AS (
  SELECT
    b.transaction_id,
    b.project_name,
    b.beneficiary AS beneficiary_name,
    p.population*1.0 / sum(p.population) OVER (PARTITION BY b.transaction_id) * b.total_amount/7.4825 AS total_amount,
    p.population*1.0 / sum(p.population) OVER (PARTITION BY b.transaction_id) * b.eu_cofinancing_amount/7.4825 AS eu_cofinancing_amount,
    (p.population*1.0 / sum(p.population) OVER (PARTITION BY b.transaction_id) * b.total_amount/7.4825) - (p.population*1.0 / sum(p.population) OVER (PARTITION BY b.transaction_id) * b.eu_cofinancing_amount/7.4825) AS amount,
    'member_state_contribution' AS amount_kind,
    LOWER(UNACCENT(b.beneficiary)) AS beneficiary_id,
    CASE
      WHEN fund_acronym = 'Europski fond za regionalni razvoj' THEN 'ERDF'
      WHEN fund_acronym = 'Europski socijani fond' THEN 'ESF'
      WHEN fund_acronym = 'Kohezijski fond' THEN 'CF'
    END AS fund_acronym,
    '2007-2013' AS funding_period,
    TRUE AS distributed,
    'nuts3' AS geolocation_in_source,
    TRIM(p.nuts1_name) AS project_state,
    TRIM(p.nuts2_name) AS project_region,
    TRIM(p.nuts3_name) AS project_county,
    TRIM(p.nuts3_code) AS project_nuts3,
    TRIM(p.lau2_name) AS project_city,
    TRIM(p.lau2_code) AS project_lau2,
    'Croatia' AS country,
    'HR' AS country_code,
    start_date::date AS start_date,
    end_date::date AS end_date    
  FROM base AS b
  INNER JOIN pre_population AS p ON TRIM(LOWER(UNACCENT(b.nuts3_name))) = TRIM(LOWER(UNACCENT(p.nuts3_name)))
  WHERE b.start_date::date < '2015-01-01'
)

SELECT * FROM vw;