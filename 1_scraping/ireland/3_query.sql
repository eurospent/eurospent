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
  FROM ie_population
),

lau1_units AS (
  SELECT DISTINCT
    lau1_name
  FROM pre_population
),

transactions_base AS (
  SELECT
    md5(CONCAT('IE',ROW_NUMBER() OVER ()::text)) AS transaction_id,
    *,
    CASE
      WHEN county = 'Cork City' THEN 'Cork'
      WHEN county = 'Cork County' THEN 'Cork County Borough'
      WHEN county = 'Dublin City' THEN 'Dublin County Borough'
      WHEN county = 'Dun Laoghaire-Rathdowne' THEN 'Dun Laoghaire-Rathdown'
      WHEN county = 'Limerick City' THEN 'Limerick'
      WHEN county = 'Limerick County' THEN 'Limerick County Borough'
      WHEN county = 'North Tipperary' THEN 'Tipperary North'
      WHEN county = 'South Tipperary' THEN 'Tipperary South'
      WHEN county = 'Waterford City' THEN 'Waterford'
      WHEN county = 'Waterford County' THEN 'Waterford County Borough'
      ELSE county
    END AS county_corr
  FROM ie_transactions
  WHERE total_amount > 0
),

lau1_transactions AS (
  SELECT
    *,
    county_corr AS county_mined
  FROM transactions_base
  WHERE county IS NOT NULL
),

lau1_councils AS (
  SELECT
    t.*,
    CASE
      WHEN LOWER(beneficiary_name) = 'dceb' THEN 'Dublin County Borough'
      WHEN LOWER(beneficiary_name) = 'galwya ceb' THEN 'Galway'
      WHEN LOWER(beneficiary_name) = 'leitim ceb' THEN 'Leitrim'
      WHEN LOWER(beneficiary_name) = 'rooscommon ceb' THEN 'Roscommon'
      WHEN LOWER(beneficiary_name) = 'ropscommon ceb' THEN 'Roscommon'
      WHEN LOWER(beneficiary_name) = 'roscommon co co' THEN 'Roscommon'
      WHEN LOWER(beneficiary_name) = 'loais ceb' THEN 'Laois'
      WHEN LOWER(beneficiary_name) = 'drogheda borough council' THEN 'Louth'
      WHEN LOWER(beneficiary_name) IN ('nuig', 'nui galway') THEN 'Galway'
      ELSE l.lau1_name
    END AS county_mined
  FROM transactions_base AS t
  LEFT JOIN lau1_units AS l ON LOWER(beneficiary_name) LIKE CONCAT('%',LOWER(l.lau1_name), '%')
  WHERE t.county IS NULL
    AND (LOWER(t.beneficiary_name) LIKE '%county%'
      OR LOWER(t.beneficiary_name) LIKE '%ceb%'
      OR LOWER(t.beneficiary_name) LIKE '%dceb%'
      OR LOWER(t.beneficiary_name) LIKE '%council%'
      OR LOWER(t.beneficiary_name) LIKE '%enterprise board%'
      OR LOWER(t.beneficiary_name) IN ('nuig', 'nui galway', 'roscommon co co'))
),

identified AS (
  SELECT * FROM lau1_transactions
  UNION ALL
  SELECT * FROM lau1_councils
),

unidentified AS (
  SELECT
    b.*,
    NULL AS county_mined
  FROM transactions_base AS b
  LEFT JOIN identified AS i ON b.transaction_id = i.transaction_id
  WHERE i.transaction_id IS NULL
),

all_transactions AS (
  SELECT * FROM identified
  UNION ALL
  SELECT * FROM unidentified
),

vw AS (
  SELECT
    a.transaction_id,
    a.project_name,
    a.beneficiary_name,
    NULL::INT AS total_amount,
    CASE
      WHEN county_mined IS NOT NULL THEN p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY a.transaction_id) * a.total_amount
      ELSE total_amount
    END AS eu_cofinancing_amount,
    NULL::INT AS amount,
    NULL::TEXT AS amount_kind,
    COALESCE(LOWER(UNACCENT(beneficiary_name)), LOWER(SUBSTRING(a.project_name,1,254))) AS beneficiary_id,
    CASE
      WHEN fund IN ('ERDF','ESF','CF') THEN fund
      ELSE NULL
    END AS fund_acronym,
    '2007-2013' AS funding_period,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    'Ireland' AS country,
    'IE' AS country_code,
    'IE' AS beneficiary_country_code,
    to_char(a.start_year, 'YYYY-MM-DD')::DATE AS start_date,
    to_char(a.end_year, 'YYYY-MM-DD')::DATE AS end_date
  FROM all_transactions AS a
  LEFT JOIN pre_population AS p ON a.county_mined = p.lau1_name
)

SELECT * FROM vw;