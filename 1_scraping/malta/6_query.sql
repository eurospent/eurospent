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
    END AS population_corr
  FROM mt_population
),

identified AS (
  SELECT 
    *
  FROM mt_final
  WHERE project_lau2 IS NOT NULL
),

geocode_success AS (
  SELECT
    *
  FROM geocode_result
  WHERE lau IS NOT NULL
),

geocode_fail AS (
  SELECT
    *
  FROM geocode_result
  WHERE lau IS NULL
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
  FROM mt_final AS t
  INNER JOIN geocode_success AS g ON t.beneficiary_id = g.beneficiary_id
  INNER JOIN population AS p ON g.lau = SUBSTRING(p.lau2_code,7) 
  WHERE t.project_lau2 IS NULL
),

unidentified_distributed AS (
  SELECT
    t.transaction_id,
    t.country,
    t.country_code,
    t.project_name,
    t.beneficiary_name,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.total_amount AS total_amount,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.eu_cofinancing_amount AS eu_cofinancing_amount,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.total_amount AS amount,
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
    start_date,
    end_date
  FROM mt_final AS t
  INNER JOIN geocode_fail AS g ON t.beneficiary_id = g.beneficiary_id
  CROSS JOIN population AS p 
  WHERE t.project_lau2 IS NULL
),

vw AS (
  SELECT * FROM identified
  UNION ALL
  SELECT * FROM geocoded
  UNION ALL
  SELECT * FROM unidentified_distributed

)

SELECT * FROM vw;