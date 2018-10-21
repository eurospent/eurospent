INSERT INTO public."sk_final" (
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
  FROM sk_population
),

base AS (
  SELECT
    md5(CONCAT('SK',ROW_NUMBER() OVER()::text)) AS transaction_id,
    *
  FROM sk_transactions
  WHERE project_code IN ('11S1', '11S2', '11T1', '11T2', '11U1', '11U2')
),

bratislava AS (
  SELECT
    *
  FROM pre_population
  WHERE UNACCENT(LOWER(lau2_name)) LIKE '%bratislava%'
),

kosice AS (
  SELECT
    *
  FROM pre_population
  WHERE UNACCENT(LOWER(lau2_name)) LIKE '%kosice%'
),

identified_beneficiary_county AS (
  SELECT
  t.*,
  p.*,
  p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY t.transaction_id) AS population_multiplier
  FROM base AS t
  INNER JOIN sk_translator_benef AS r ON t.beneficiary = r.beneficiary AND r.benef_type = 'county'
  INNER JOIN pre_population AS p ON r.lau2_name = p.nuts3_name
),

identified_beneficiary_lau2 AS (
  SELECT
  t.*,
  p.*,
  1.00 AS population_multiplier
  FROM base AS t
  INNER JOIN sk_translator_benef AS r ON t.beneficiary = r.beneficiary
  LEFT JOIN pre_population AS p ON p.lau2_code = r.lau2_code
  WHERE (r.benef_type = 'city'
    OR r.benef_type = 'village'
    OR r.benef_type = 'identified')
),

identified_beneficiary_bratislava AS (
  SELECT
  t.*,
  b.*,
  b.population_corr*1.0 / sum(b.population_corr) OVER (PARTITION BY t.transaction_id) AS population_multiplier
  FROM base AS t
  INNER JOIN sk_translator_benef AS r ON t.beneficiary = r.beneficiary AND r.benef_type = 'Bratislava'
  CROSS JOIN bratislava AS b

),

identified_beneficiary_kosice AS (
  SELECT
  t.*,
  k.*,
  k.population_corr*1.0 / sum(k.population_corr) OVER (PARTITION BY t.transaction_id) AS population_multiplier
  FROM base AS t
  INNER JOIN sk_translator_benef As r ON t.beneficiary = r.beneficiary AND r.benef_type = 'Kosice'
  CROSS JOIN kosice AS k

),

location_description_kosice AS (
  SELECT
    beneficiary,
    project_title,
    k.lau2_code
  FROM sk_translator_descript
  CROSS JOIN kosice AS k
  WHERE distribution_level = 'Kosice'
),

location_description_kosice_project AS (
  SELECT
    t.*,
    p.*,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) AS population_multiplier
  FROM base AS t
  INNER JOIN location_description_kosice AS k ON t.beneficiary = k.beneficiary AND t.project_title = k.project_title
  INNER JOIN kosice AS p ON k.lau2_code = p.lau2_code
),


location_description_bratislava AS (
  SELECT
    beneficiary,
    project_title,
    b.lau2_code
  FROM sk_translator_descript
  CROSS JOIN bratislava AS b
  WHERE distribution_level = 'Bratislava'
),

location_description_bratislava_project AS (
  SELECT
    t.*,
    p.*,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) AS population_multiplier
  FROM base AS t
  INNER JOIN location_description_bratislava AS b ON t.beneficiary = b.beneficiary AND t.project_title = b.project_title
  INNER JOIN bratislava AS p ON b.lau2_code = p.lau2_code
),

location_description_lau1 AS (
  SELECT
    beneficiary,
    project_title,
    UNNEST(string_to_array(unit,',')) AS lau1_name
  FROM sk_translator_descript
  WHERE distribution_level = 'lau1'
),

location_description_lau1_project AS (
  SELECT
  t.*,
  p.*,
  p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY t.transaction_id) AS population_multiplier
  FROM base AS t
  INNER JOIN location_description_lau1 AS d ON t.beneficiary = d.beneficiary AND t.project_title = d.project_title
  INNER JOIN pre_population AS p ON d.lau1_name = p.lau1_name
),

location_description_lau2 AS (
  SELECT
    beneficiary,
    project_title,
    UNNEST(string_to_array(codes,',')) AS lau2_code
  FROM
  sk_translator_descript
  WHERE distribution_level = 'lau2'
),

location_description_lau2_project AS (
  SELECT
  t.*,
  p.*,
  p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY t.transaction_id) AS population_multiplier
  FROM base AS t
  INNER JOIN location_description_lau2 AS d ON t.beneficiary = d.beneficiary AND t.project_title = d.project_title
  INNER JOIN pre_population AS p ON d.lau2_code = p.lau2_code
),

description_all AS (
  SELECT * FROM location_description_kosice_project
  UNION
  SELECT * FROM location_description_bratislava_project
  UNION
  SELECT * FROM location_description_lau1_project
  UNION
  SELECT * FROM location_description_lau2_project
),

all_sums AS (
  SELECT SUM(eu_cofinancing_amount) AS allsum
  FROM sk_transactions
),

benefs_and_perc AS (
SELECT
  t.beneficiary,
  r.benef_type,
  a.allsum,
  SUM(t.eu_cofinancing_amount) AS total_amount,
  SUM(t.eu_cofinancing_amount)*1.0 / a.allsum*100.0 AS perc,
  COUNT(*) AS trans_count
FROM base AS t
INNER JOIN sk_translator_benef As r ON t.beneficiary = r.beneficiary
CROSS JOIN all_sums AS a
GROUP BY t.beneficiary, r.benef_type, a.allsum

),

top_spenders AS (
  SELECT
    *
  FROM benefs_and_perc
  WHERE perc > 0.1
    AND benef_type = 'company'
),

national_projects AS (
  SELECT
    t.*
  FROM base AS t
  INNER JOIN top_spenders AS s ON t.beneficiary = s.beneficiary
  LEFT JOIN description_all AS d ON t.transaction_id = d.transaction_id
  WHERE d.transaction_id IS NULL
),

national_projects_distributed AS (
  SELECT
    n.*,
    p.*,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY n.transaction_id) AS population_multiplier
  FROM national_projects AS n
  CROSS JOIN pre_population AS p
),

unidentified_companies AS (
  SELECT t.* FROM base AS t
  INNER JOIN sk_translator_benef As r ON t.beneficiary = r.beneficiary AND (r.benef_type = 'company' OR r.benef_type = 'foreign')
  LEFT JOIN sk_translator_descript AS d ON t.beneficiary = d.beneficiary AND t.project_title = d.project_title
  LEFT JOIN national_projects AS n ON t.transaction_id = n.transaction_id
  --NEED TO FILTER national_transactions!
  WHERE d.project_title IS NULL
    AND n.transaction_id IS NULL
),

geolocated AS (
  SELECT * FROM national_projects_distributed
  UNION ALL
  SELECT * FROM identified_beneficiary_county
  UNION ALL
  SELECT * FROM identified_beneficiary_lau2
  UNION ALL
  SELECT * FROM identified_beneficiary_bratislava
  UNION ALL
  SELECT * FROM identified_beneficiary_kosice
  UNION ALL
  SELECT * FROM description_all
),

geolocated_view AS (
  SELECT
    transaction_id,
    project_title AS project_name,
    beneficiary AS beneficiary_name,
    eu_cofinancing_amount*population_multiplier AS total_amount,
    eu_cofinancing_amount*population_multiplier AS eu_cofinancing_amount,
    member_state_amount*population_multiplier AS amount,
    'actually_paid_amount' AS amount_kind,
    UNACCENT(LOWER(beneficiary)) AS beneficiary_id,
    CASE
      WHEN project_code IN ('11S1', '11S2') THEN 'ERDF'
      WHEN project_code IN ('11T1', '11T2') THEN 'ESF'
      WHEN project_code IN ('11U1', '11U2') THEN 'CF'
    END AS fund_acronym,
    '2007-2013' AS funding_period,
    nuts1_name AS project_state,
    nuts2_name AS project_region,
    nuts3_name AS project_county,
    nuts3_code AS project_nuts3,
    lau2_name AS project_city,
    lau2_code AS project_lau2,
    'Slovakia' AS country,
    'SK' AS country_code,
    'SK' AS beneficiary_country_code,
    start_date,
    end_date
  FROM geolocated
),

unidentified_view AS (
  SELECT
    transaction_id,
    project_title AS project_name,
    beneficiary AS beneficiary_name,
    eu_cofinancing_amount AS total_amount,
    eu_cofinancing_amount AS eu_cofinancing_amount,
    member_state_amount AS amount,
    'actually_paid_amount' AS amount_kind,
    UNACCENT(LOWER(beneficiary)) AS beneficiary_id,
    CASE
      WHEN project_code IN ('11S1', '11S2') THEN 'ERDF'
      WHEN project_code IN ('11T1', '11T2') THEN 'ESF'
      WHEN project_code IN ('11U1', '11U2') THEN 'CF'
    END AS fund_acronym,
    '2007-2013' AS funding_period,
    NULL::text AS project_state,
    NULL::text AS project_region,
    NULL::text AS project_county,
    NULL::text AS project_nuts3,
    NULL::text AS project_city,
    NULL::text AS project_lau2,
    'Slovakia' AS country,
    'SK' AS country_code,
    'SK' AS beneficiary_country_code,
    start_date,
    end_date
  FROM unidentified_companies
),

vw AS (
  SELECT * FROM geolocated_view
  UNION ALL
  SELECT * FROM unidentified_view
)
SELECT * FROM vw;