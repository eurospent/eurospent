INSERT INTO final2 (
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
  geolocation_in_source,
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
  FROM at_population
),

geocode_success_address_nuts2 AS (
  SELECT
    *
  FROM geocode_result
  WHERE lau IS NOT NULL
    AND query_address IS NOT NULL
    AND query_region IS NOT NULL
),


geocode_success_address AS (
  SELECT
    *
  FROM geocode_result
  WHERE lau IS NOT NULL
    AND query_address IS NOT NULL
    AND query_region IS NULL
),

geocode_success_nuts2 AS (
  SELECT
    g.*
  FROM geocode_result AS g
  WHERE g.lau IS NOT NULL
    AND g.query_address IS NULL
    AND g.query_region IS NOT NULL
),

geocode_success_no_info AS (
  SELECT
    g.*
  FROM geocode_result AS g
  WHERE g.lau IS NOT NULL
    AND g.query_region IS NULL
    AND g.query_address IS NULL
),

geocode_fail_nuts2 AS (
  SELECT
    *
  FROM geocode_result
  WHERE lau IS NULL
    AND query_region IS NOT NULL
    AND query_address IS NULL
),

geocoded_address_nuts2 AS (
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
    FALSE AS distributed,
    'geocoded' AS geolocation_in_source,
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
    t.end_date
  FROM final AS t
  INNER JOIN geocode_success_address AS g ON t.beneficiary_id = g.beneficiary_id AND t.beneficiary_address = g.query_address AND t.project_region = g.query_region
  INNER JOIN population AS p ON g.lau = SUBSTRING(p.lau2_code,7) 
),

geocoded_address AS (
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
    FALSE AS distributed,
    'geocoded' AS geolocation_in_source,
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
    t.end_date
  FROM final AS t
  INNER JOIN geocode_success_address AS g ON t.beneficiary_id = g.beneficiary_id AND t.beneficiary_address = g.query_address AND t.project_lau2 IS NULL AND t.beneficiary_address IS NOT NULL
  INNER JOIN population AS p ON g.lau = SUBSTRING(p.lau2_code,7) 
),

geocoded_nuts2 AS (
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
    FALSE AS distributed,
    'geocoded' AS geolocation_in_source,
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
    t.end_date
  FROM final AS t
  INNER JOIN geocode_success_nuts2 AS g ON t.beneficiary_id = g.beneficiary_id AND t.project_region = g.query_region
  INNER JOIN population AS p ON g.lau = SUBSTRING(p.lau2_code,7) 
  WHERE t.project_lau2 IS NULL
    AND t.beneficiary_address IS NULL
    AND t.project_region IS NOT NULL
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
    FALSE AS distributed,
    'geocoded' AS geolocation_in_source,
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
    t.end_date
  FROM final AS t
  INNER JOIN geocode_success_no_info AS g ON t.beneficiary_id = g.beneficiary_id
  INNER JOIN population AS p ON g.lau = SUBSTRING(p.lau2_code,7) 
  WHERE t.project_lau2 IS NULL
    AND t.beneficiary_address IS NULL
    AND t.project_region IS NULL
),

unidentified_distributed_nuts2 AS (
  SELECT
    t.transaction_id,
    t.country,
    t.country_code,
    t.project_name,
    t.beneficiary_name,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.total_amount AS total_amount,
    t.eu_cofinancing_amount,
    t.amount,
    t.amount_kind,
    t.beneficiary_country_code,
    t.beneficiary_id,
    t.fund_acronym,
    t.funding_period,
    t.geocoding_state,
    TRUE AS distributed,
    'nuts2' AS geolocation_in_source,
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
    t.end_date
  FROM final AS t
  INNER JOIN geocode_fail_nuts2 AS g ON t.beneficiary_id = g.beneficiary_id AND g.query_region = t.project_region
  INNER JOIN population AS p ON t.project_region = p.nuts2_name
  WHERE t.project_lau2 IS NULL
    AND t.project_region IS NOT NULL
    AND t.beneficiary_address IS NULL
),

blacklist AS (
  SELECT DISTINCT transaction_id FROM geocoded_address_nuts2
  UNION ALL
  SELECT DISTINCT transaction_id FROM geocoded_address
  UNION ALL
  SELECT DISTINCT transaction_id FROM geocoded_nuts2
  UNION ALL
  SELECT DISTINCT transaction_id FROM geocoded
  UNION ALL
  SELECT DISTINCT transaction_id FROM unidentified_distributed_nuts2
),

unidentified AS (
  SELECT
    b.*
  FROM final AS b
  LEFT JOIN blacklist AS bl ON b.transaction_id = bl.transaction_id
  WHERE bl.transaction_id IS NULL
),

unidentified_distributed_nationally AS (
  SELECT
    t.transaction_id,
    t.country,
    t.country_code,
    t.project_name,
    t.beneficiary_name,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.total_amount AS total_amount,
    t.eu_cofinancing_amount,
    t.amount,
    t.amount_kind,
    t.beneficiary_country_code,
    t.beneficiary_id,
    t.fund_acronym,
    t.funding_period,
    t.geocoding_state,
    TRUE AS distributed,
    'national' AS geolocation_in_source,
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
    t.end_date
  FROM unidentified AS t
  CROSS JOIN population AS p 
),

vw AS (
  SELECT * FROM geocoded_address_nuts2
  UNION ALL
  SELECT * FROM geocoded_address
  UNION ALL
  SELECT * FROM geocoded_nuts2
  UNION ALL
  SELECT * FROM geocoded
  UNION ALL
  SELECT * FROM unidentified_distributed_nuts2
  UNION ALL
  SELECT * FROM unidentified_distributed_nationally

)
SELECT * FROM vw;