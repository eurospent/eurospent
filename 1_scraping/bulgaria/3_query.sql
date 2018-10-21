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
  beneficiary_country_code,
  contract_date,
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
  FROM bg_population
),

--total_amount conversion is calculated on the basis of the daily BNG-EUR average rates between 2007-2013, downloaded from:
--https://www.investing.com/currencies/eur-bgn-historical-data.

transactions_base AS (
  SELECT
    md5(CONCAT('BG',ROW_NUMBER() OVER ()::text)) AS transaction_id,
    CASE
      WHEN t.fund_acronym = 'ЕСФ   ==>' THEN 'ESF'
      WHEN t.fund_acronym = 'ЕФРР   ==>' THEN 'ERDF'
      ELSE 'CF'
    END AS fund_acronym,
    t.performers,
    ROUND(t.total_value/1.95588,2) AS total_value,
    ROUND(t.actually_paid/1.95588,2) AS actually_paid,
    ROUND(t.grants/1.95588,2) AS grants,
    t.name_of_contract,
    t.contract_date,
    t.start_date,
    t.end_date,
    t.duration,
    t.place_of_execution,
    t.business_address,
    t.beneficiary,
    l.country,
    l.nuts1,
    l.nuts2,
    l.nuts3,
    l.lau1
  FROM bg_transactions AS t
  INNER JOIN bg_locations_translated AS l ON t.place_of_execution = l.location_bg
  WHERE (t.contract_date > '2006-12-31' OR t.contract_date IS NULL)
    AND (t.contract_date < '2014-01-01' OR t.contract_date IS NULL)
    AND l.country = 'Bulgaria'
    AND actually_paid > 0.0000
),

projects_national AS (
  SELECT
    t.*,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.actually_paid AS total_amount,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.grants AS eu_cofinancing_amount,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.actually_paid - p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.grants AS amount,
    'Member state contribution' AS amount_kind,
    p.*,
    TRUE AS distributed,
    'national' AS geolocation_in_source
  FROM transactions_base AS t
  CROSS JOIN pre_population AS p
  WHERE nuts1 IS NULL
),

projects_nuts1 AS (
  SELECT
    t.*,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.actually_paid AS total_amount,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.grants AS eu_cofinancing_amount,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.actually_paid - p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.grants AS amount,
    'Member state contribution' AS amount_kind,
    p.*,
    TRUE AS distributed,
    'nuts1' AS geolocation_in_source
  FROM transactions_base AS t
  INNER JOIN pre_population AS p ON t.nuts1 = p.nuts1_name
  WHERE t.nuts1 IS NOT NULL
    AND t.nuts2 IS NULL
),

projects_nuts2 AS (
  SELECT
    t.*,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.actually_paid AS total_amount,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.grants AS eu_cofinancing_amount,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.actually_paid - p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.grants AS amount,
    'Member state contribution' AS amount_kind,
    p.*,
    TRUE AS distributed,
    'nuts2' AS geolocation_in_source
  FROM transactions_base AS t
  INNER JOIN pre_population AS p ON t.nuts1 = p.nuts1_name AND t.nuts2 = p.nuts2_name_english
  WHERE t.nuts1 IS NOT NULL
    AND t.nuts2 IS NOT NULL
    AND t.nuts3 IS NULL

),

projects_nuts3 AS (
  SELECT
    t.*,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.actually_paid AS total_amount,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.grants AS eu_cofinancing_amount,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.actually_paid - p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.grants AS amount,
    'Member state contribution' AS amount_kind,
    p.*,
    TRUE AS distributed,
    'nuts3' AS geolocation_in_source
  FROM transactions_base AS t
  INNER JOIN pre_population AS p ON t.nuts1 = p.nuts1_name AND t.nuts2 = p.nuts2_name_english AND t.nuts3 = p.nuts3_name 
  WHERE t.nuts1 IS NOT NULL
    AND t.nuts2 IS NOT NULL
    AND t.nuts3 IS NOT NULL
    AND t.lau1 IS NULL

),

projects_lau1 AS (
  SELECT
    t.*,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.actually_paid AS total_amount,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.grants AS eu_cofinancing_amount,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.actually_paid - p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.grants AS amount,
    'Member state contribution' AS amount_kind,
    p.*,
    TRUE AS distributed,
    'lau1' AS geolocation_in_source
  FROM transactions_base AS t
  INNER JOIN pre_population AS p ON
    t.nuts1 = p.nuts1_name AND
    t.nuts2 = p.nuts2_name_english AND
    t.nuts3 = p.nuts3_name AND
    t.lau1 = p.lau1_name
  WHERE t.nuts1 IS NOT NULL
    AND t.nuts2 IS NOT NULL
    AND t.nuts3 IS NOT NULL
    AND t.lau1 IS NOT NULL
),

vw AS (
  SELECT * FROM projects_national
  UNION ALL
  SELECT * FROM projects_nuts1
  UNION ALL
  SELECT * FROM projects_nuts2
  UNION ALL
  SELECT * FROM projects_nuts3
  UNION ALL
  SELECT * FROM projects_lau1
)

SELECT
  transaction_id,
  name_of_contract,
  beneficiary,
  total_amount,
  eu_cofinancing_amount,
  amount,
  'Member_state_contribution' AS amount_kind,
  UNACCENT(beneficiary) AS beneficiary_id,
  fund_acronym,
  '2007-2013' AS funding_period,
  distributed,
  geolocation_in_source,
  nuts1_name AS project_state,
  nuts2_name_english AS project_region,
  nuts3_name AS project_county,
  nuts3_code AS project_nuts3,
  lau2_name AS project_city,
  lau2_code AS project_lau2,
  country,
  'BG' AS country_code,
  'BG' AS beneficiary_country_code,
  contract_date,
  start_date,
  end_date
FROM vw;