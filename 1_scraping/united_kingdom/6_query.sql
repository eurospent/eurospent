INSERT INTO final_with_geo (
  transaction_id,
  country,
  country_code,
  project_name,
  beneficiary_name,
  total_amount,
  eu_cofinancing_amount,
  amount,
  amount_kind,
  beneficiary_country_code,
  beneficiary_id,
  fund_acronym,
  funding_period,
  geocoding_state,
  distributed,
  beneficiary_state,
  beneficiary_region,
  beneficiary_county,
  beneficiary_nuts3,
  beneficiary_city,
  beneficiary_lau2,
  beneficiary_postal_code,
  beneficiary_address,
  beneficiary_lat,
  beneficiary_long,
  project_state,
  project_region,
  project_county,
  project_nuts3,
  project_city,
  project_lau2,
  project_postal_code,
  project_address,
  project_lat,
  project_long,
  start_date,
  end_date
)

WITH
population AS (
  SELECT
    *,
    CASE
      WHEN population > 0 THEN population
      ELSE 1
    END AS population_corr,
    CASE
      WHEN nuts2_name = 'Highlands and Islands' THEN 'Highlands and Islands'
      WHEN nuts1_name = 'Scotland' AND nuts2_name != 'Highlands and Islands' THEN 'Lowlands and Uplands'
      WHEN nuts2_name = 'Cornwall and Isles of Scilly' THEN 'Cornwall and the Isles of Scilly'
      WHEN nuts2_name = 'Merseyside' THEN 'Merseyside'
      WHEN nuts2_name = 'South Yorkshire' THEN 'South Yorkshire'
      WHEN nuts1_name = 'Wales' THEN 'Wales'
      WHEN nuts1_name = 'East Midlands (England)' THEN 'East Midlands'
      WHEN nuts1_name = 'East of England' THEN 'East of England'
      WHEN nuts1_name = 'London' THEN 'London'
      WHEN nuts1_name = 'North East (England)' THEN 'North East'
      WHEN nuts1_name = 'North West (England)' THEN 'North West'
      WHEN nuts1_name = 'South East (England)' THEN 'South East'
      WHEN nuts1_name = 'South West (England)' THEN 'South West'
      WHEN nuts1_name = 'West Midlands (England)' THEN 'West Midlands'
      WHEN nuts1_name = 'Yorkshire and The Humber' THEN 'Yorkshire and the Humber'
      WHEN nuts1_name = 'Northern Ireland' THEN 'Northern Ireland'
    END AS region_corr
  FROM uk_population
),

identified AS (
  SELECT 
    *
  FROM uk_final
  WHERE project_lau2 IS NOT NULL
),

geocode_success AS (
  SELECT
    *
  FROM geocode_result
  WHERE lau IS NOT NULL
),

geocoded AS (
  SELECT
    t.transaction_id,
    t.country,
    t.country_code,
    t.project_name,
    t.beneficiary_name,
    t.total_amount,
    t.eu_cofinancing_amount,
    t.amount,
    t.amount_kind,
    t.beneficiary_country_code,
    t.beneficiary_id,
    t.fund_acronym,
    t.funding_period,
    'geocoded' AS geocoding_state,
    t.distributed,
    p.nuts2_name AS beneficiary_state,
    p.lau1_name AS beneficiary_region,
    p.nuts3_name AS beneficiary_county,
    p.nuts3_code::text AS beneficiary_nuts3,
    p.lau2_name AS beneficiary_city,
    p.lau2_code As beneficiary_lau2,
    g.result_postal_code AS beneficiary_postal_code,
    g.result_full_address AS beneficiary_address,
    g.result_lat AS beneficiary_lat,
    g.result_long AS beneficiary_long,
    t.project_state,
    t.project_region,
    t.project_county,
    t.project_nuts3,
    t.project_city,
    t.project_lau2,
    t.project_postal_code,
    t.project_address,
    t.project_lat,
    t.project_long,
    t.start_date,
    t.end_date
  FROM uk_final AS t
  INNER JOIN geocode_success AS g ON
    CASE
      WHEN t.project_state = 'Northern Ireland' AND g.query_state = 'Northern Ireland' AND t.beneficiary_id = g.beneficiary_id THEN 1
      WHEN t.beneficiary_id = g.beneficiary_id AND t.project_state = g.query_state AND t.project_region = g.query_region THEN 1
      ELSE 0
    END = 1
  LEFT JOIN population AS p ON g.lau = split_part(p.lau2_code, '_', 2)
  WHERE t.project_lau2 IS NULL
),

unidentified_distributed AS (
  SELECT
    t.transaction_id,
    t.country,
    t.country_code,
    t.project_name,
    t.beneficiary_name,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.total_amount AS total_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.eu_cofinancing_amount AS eu_cofinancing_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.amount AS amount,
    t.amount_kind,
    t.beneficiary_country_code,
    t.beneficiary_id,
    t.fund_acronym,
    t.funding_period,
    t.geocoding_state,
    t.distributed,
    t.beneficiary_state,
    t.beneficiary_region,
    t.beneficiary_county,
    t.beneficiary_nuts3,
    t.beneficiary_city,
    t.beneficiary_lau2,
    t.beneficiary_postal_code,
    t.beneficiary_address,
    t.beneficiary_lat,
    t.beneficiary_long,
    p.nuts2_name AS project_state,
    p.lau1_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code::text AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    t.project_postal_code,
    t.project_address,
    t.project_lat,
    t.project_long,
    t.start_date,
    t.end_date
  FROM uk_final AS t
  LEFT JOIN geocode_success AS g ON
    CASE
      WHEN t.project_state = 'Northern Ireland' AND g.query_state = 'Northern Ireland' AND t.beneficiary_id = g.beneficiary_id THEN 1
      WHEN t.beneficiary_id = g.beneficiary_id AND t.project_state = g.query_state AND t.project_region = g.query_region THEN 1
      ELSE 0
    END = 1
  INNER JOIN population AS p ON
    CASE
      WHEN t.project_region = p.region_corr THEN 1
      WHEN t.project_region = '' AND t.project_state = 'Northern Ireland' AND p.region_corr = 'Northern Ireland' THEN 1
      WHEN t.project_region = 'National' AND p.nuts1_name NOT IN ('Northern Ireland', 'Scotland', 'Wales') THEN 1
      WHEN t.project_region = 'Highland and Islands' AND p.region_corr = 'Highlands and Islands' THEN 1
      WHEN t.project_region = 'Yorkshire' AND p.region_corr = 'Yorkshire and the Humber' THEN 1
      ELSE 0
    END = 1 
  WHERE t.project_lau2 IS NULL
    AND g.beneficiary_id IS NULL
),

vw AS (
  SELECT * FROM identified
  UNION ALL
  SELECT * FROM geocoded
  UNION ALL
  SELECT * FROM unidentified_distributed
)

SELECT * FROM vw;