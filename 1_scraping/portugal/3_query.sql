INSERT INTO public."pt_final" (
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
  start_date
)
WITH
pre_population AS (
  SELECT
    *,
    CASE
      WHEN population > 0 THEN population
      ELSE 1
    END AS population_corr
  FROM pt_population
),

nuts3_units AS (
  SELECT DISTINCT
    nuts2_name,
    nuts3_name,
    nuts3_code
  FROM pre_population
),

lau1_units AS (
  SELECT DISTINCT
    nuts2_name,
    lau1_name,
    lau1_code
  FROM pre_population
),

base AS (
  SELECT
    md5(CONCAT('PT',ROW_NUMBER() OVER ()::text)) AS transaction_id,
    CASE
      WHEN nuts2 = 'Madeira' THEN 'Região Autónoma da Madeira'
      WHEN nuts2 = 'Açores' THEN 'Região Autónoma dos Açores'
      ELSE nuts2
    END AS nuts2_c,
    CASE
      WHEN fund_acronym = 'FEDER' THEN 'ERDF'
      WHEN fund_acronym = 'FSE' THEN 'ESF'
      WHEN fund_acronym = 'FC' THEN 'CF'
      ELSE NULL
    END AS fund_acronym_c,
    start_date::date AS start_date_c,
    *
  FROM pt_transactions
),

national_transactions AS (
  SELECT
    b.*,
    ARRAY[NULL] AS distribution_units,
    'national' AS distribution_level
  FROM base AS b
  WHERE b.nuts2 IN ('Multi-regional convergência', 'Multiregional dentro de NUTS Y', 'Não regionalizável dentro de NUTS Z','Não Regionalizável','Não Regionalizável')
),

nuts2_transactions AS (
  SELECT
    b.*,
    ARRAY[b.nuts2] AS distribution_units,
    'nuts2' AS distribution_level
  FROM base AS b
  WHERE b.nuts2 NOT IN ('Multi-regional convergência', 'Multiregional dentro de NUTS Y', 'Não regionalizável dentro de NUTS Z','Não Regionalizável')
    AND (b.lau1_code = 'YYYY'
    OR b.lau1_code = 'ZZZZ')
),

lau1_transactions AS (
  SELECT
    b.*,
    ARRAY[lau1_code] AS distribution_units,
    'lau1' AS distribution_level
  FROM base AS b
  WHERE b.nuts2 NOT IN ('Multi-regional convergência', 'Multiregional dentro de NUTS Y', 'Não regionalizável dentro de NUTS Z', 'Não Regionalizável')
    AND b.lau1_code IS NOT NULL
    AND b.lau1_code != 'YYYY'
    AND b.lau1_code != 'ZZZZ'
),

unidentified_beneficiaries AS (
  SELECT DISTINCT
    b.beneficiary,
    b.nuts2_c
  FROM base AS b
  WHERE b.nuts2 NOT IN ('Multi-regional convergência', 'Multiregional dentro de NUTS Y', 'Não regionalizável dentro de NUTS Z', 'Não Regionalizável')
  AND b.lau1_code IS NULL
),

beneficiaries_nuts3 AS (
  SELECT
    u.beneficiary,
    u.nuts2_c,
    n.nuts3_code
  FROM unidentified_beneficiaries AS u
  LEFT JOIN nuts3_units AS n ON
    CASE
      WHEN LOWER(UNACCENT(u.beneficiary)) LIKE CONCAT('% ',LOWER(UNACCENT(n.nuts3_name))) AND u.nuts2_c = n.nuts2_name THEN 1
      WHEN LOWER(UNACCENT(u.beneficiary)) LIKE CONCAT(LOWER(UNACCENT(n.nuts3_name)),'%') AND u.nuts2_c = n.nuts2_name THEN 1
      WHEN LOWER(UNACCENT(u.beneficiary)) LIKE CONCAT('% ',LOWER(UNACCENT(n.nuts3_name)),' %') AND u.nuts2_c = n.nuts2_name THEN 1
      ELSE 0
    END = 1      
  WHERE n.nuts3_name IS NOT NULL
  AND (LOWER(UNACCENT(u.beneficiary)) LIKE '%comunidade intermunicipal%'
    OR LOWER(UNACCENT(u.beneficiary)) LIKE 'area metropolitana')
),

transactions_beneficiaries_nuts3 AS (
  SELECT
    b.*,
    ARRAY[bn.nuts3_code] AS distribution_units,
    'nuts3' AS distribution_level
    FROM base AS b
    INNER JOIN beneficiaries_nuts3 AS bn ON b.beneficiary = bn.beneficiary AND b.nuts2_c = bn.nuts2_c
    WHERE b.nuts2 NOT IN ('Multi-regional convergência', 'Multiregional dentro de NUTS Y', 'Não regionalizável dentro de NUTS Z', 'Não Regionalizável')
      AND b.lau1_code IS NULL
),

beneficiaries_lau1 AS (
  SELECT DISTINCT
    u.beneficiary,
    u.nuts2_c,
    ARRAY_AGG(l.lau1_code) AS lau1_units
  FROM unidentified_beneficiaries AS u
  LEFT JOIN lau1_units AS l ON
    CASE
      WHEN LOWER(UNACCENT(u.beneficiary)) LIKE CONCAT('% ',LOWER(UNACCENT(l.lau1_name))) AND u.nuts2_c = l.nuts2_name THEN 1
      WHEN LOWER(UNACCENT(u.beneficiary)) LIKE CONCAT(LOWER(UNACCENT(l.lau1_name)),'%') AND u.nuts2_c = l.nuts2_name THEN 1
      WHEN LOWER(UNACCENT(u.beneficiary)) LIKE CONCAT('% ',LOWER(UNACCENT(l.lau1_name)),' %') AND u.nuts2_c = l.nuts2_name THEN 1
      ELSE 0
    END = 1  
  LEFT JOIN beneficiaries_nuts3 AS b ON u.beneficiary = b.beneficiary
  WHERE l.lau1_name IS NOT NULL
  AND b.beneficiary IS NULL
  AND (LOWER(UNACCENT(u.beneficiary)) LIKE '%câmara municipal%'
    OR LOWER(UNACCENT(u.beneficiary)) LIKE '%camara do comercio%'
    OR LOWER(UNACCENT(u.beneficiary)) LIKE '%distrito%'
    OR LOWER(UNACCENT(u.beneficiary)) LIKE '%municipio%')
  GROUP BY u.beneficiary, u.nuts2_c
),

transactions_beneficiaries_lau1 AS (
  SELECT
    b.*,
    bl.lau1_units AS distribution_units,
    'lau1' AS distribution_level
    FROM base AS b
    INNER JOIN beneficiaries_lau1 AS bl ON b.beneficiary = bl.beneficiary AND b.nuts2_c = bl.nuts2_c
    WHERE b.nuts2 NOT IN ('Multi-regional convergência', 'Multiregional dentro de NUTS Y', 'Não regionalizável dentro de NUTS Z', 'Não Regionalizável')
      AND b.lau1_code IS NULL
),

distributed AS (
  SELECT * FROM national_transactions
  UNION ALL
  SELECT * FROM nuts2_transactions
  UNION ALL
  SELECT * FROM lau1_transactions
  UNION ALL
  SELECT * FROM transactions_beneficiaries_nuts3
  UNION ALL
  SELECT * FROM transactions_beneficiaries_lau1
),

unidentified_base AS (
  SELECT
    b.*
  FROM base AS b
  LEFT JOIN distributed AS d ON b.transaction_id = d.transaction_id
  WHERE d.transaction_id IS NULL
),

multiple_locations AS (
  SELECT
    beneficiary,
    COUNT(DISTINCT nuts2_c) nuts_count
  FROM unidentified_base
  GROUP BY beneficiary
),

multiple_locations_distinct AS (
  SELECT DISTINCT
    b.beneficiary,
    b.nuts2_c
  FROM unidentified_base AS b
  INNER JOIN multiple_locations AS m ON b.beneficiary = m.beneficiary
  WHERE m.nuts_count > 1
),

multiple_locations_array AS (
  SELECT
    beneficiary,
    ARRAY_AGG(nuts2_c) AS distribution_elements
  FROM multiple_locations_distinct
  GROUP BY beneficiary
),

unidentified_nuts2 AS (
  SELECT
    b.*,
    m.distribution_elements AS distribution_units,
    'nuts2' AS distribution_level
  FROM unidentified_base AS b
  INNER JOIN multiple_locations_array AS m ON b.beneficiary = m.beneficiary
),

to_geocode AS (
  SELECT
    b.*,
    ARRAY[NULL] AS distribution_units,
    'geocode' AS distribution_level
  FROM unidentified_base AS b
  LEFT JOIN unidentified_nuts2 AS u ON b.transaction_id = u.transaction_id
  WHERE u.transaction_id IS NULL
),

distribution_base AS (
  SELECT
    *,
    UNNEST(CASE WHEN distribution_units <> '{}' THEN distribution_units ELSE '{null}' END) AS d_units
  FROM distributed
  UNION ALL
  SELECT
    *,
    UNNEST(CASE WHEN distribution_units <> '{}' THEN distribution_units ELSE '{null}' END) AS d_units
  FROM unidentified_nuts2
  UNION ALL
  SELECT
    *,
    UNNEST(CASE WHEN distribution_units <> '{}' THEN distribution_units ELSE '{null}' END) AS d_units
  FROM to_geocode
),

vw AS (
  SELECT
    b.transaction_id,
    b.project_name,
    b.beneficiary AS beneficiary_name,
    CASE
      WHEN b.distribution_level = 'geocode' THEN b.total_amount
      ELSE p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.total_amount
    END AS total_amount,
    CASE
      WHEN b.distribution_level = 'geocode' THEN b.eu_cofinancing_amount
      ELSE p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.eu_cofinancing_amount
    END AS eu_cofinancing_amount,
    CASE
     WHEN b.distribution_level = 'geocode' THEN b.total_amount - b.eu_cofinancing_amount
     ELSE p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*(b.total_amount - b.eu_cofinancing_amount)
    END AS amount,
    'member_state_contribution' AS amount_kind,
    LOWER(UNACCENT(beneficiary)) AS beneficiary_id,
    fund_acronym_c AS fund_acronym,
    '2007-2013' AS funding_period,
    p.nuts1_name AS project_state,
    COALESCE(p.nuts2_name, b.nuts2_c) AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    'Portugal' AS country,
    'PT' AS country_code,
    'PT' AS beneficiary_country_code,
    start_date_c AS start_date
  FROM distribution_base AS b
  LEFT JOIN pre_population AS p ON
    CASE
      WHEN b.distribution_level = 'national' THEN 1
      WHEN b.distribution_level = 'nuts2' AND b.d_units = p.nuts2_name THEN 1
      WHEN b.distribution_level = 'nuts3' AND b.d_units = p.nuts3_code THEN 1
      WHEN b.distribution_level = 'lau1' AND b.d_units = p.lau1_code THEN 1
      ELSE 0
    END = 1
)

SELECT * FROM vw;