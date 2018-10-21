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
  beneficiary_city,
  beneficiary_address,
  beneficiary_postal_code,
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
  FROM dk_population
),

lau2_units AS (
  SELECT DISTINCT
    nuts2_name,
    lau1_name,
    lau2_code
  FROM pre_population
),

base AS (
  SELECT
    md5(CONCAT('DK',ROW_NUMBER() OVER()::text)) AS transaction_id,
    *,
    CASE
      WHEN nuts2 = 'Bornholm' THEN 'Hovedstaden'
      ELSE nuts2
    END AS nuts2_corr
  FROM dk_transactions
),

lau1_beneficiary_name AS (
  SELECT
    b.transaction_id,
    array_remove(array_agg(u.lau2_code), NULL) AS code,
    TRUE AS distributed,
    'lau1' AS geolocation_in_source
  FROM base AS b
  INNER JOIN lau2_units AS u ON
    CASE
      WHEN b.nuts2 = 'Konkurrenceudsat pulje' AND LOWER(b.beneficiary_name) LIKE CONCAT('%',LOWER(u.lau1_name),'%') THEN 1
      WHEN LOWER(b.nuts2_corr) = LOWER(REPLACE(u.nuts2_name, 'Region ', '')) AND LOWER(b.beneficiary_name) LIKE CONCAT('%',LOWER(u.lau1_name),'%') THEN 1
      ELSE 0
    END = 1
  GROUP BY 1,3,4
),

lau1_partner AS (
  SELECT DISTINCT
    b.transaction_id,
    array_remove(array_agg(u.lau2_code), NULL) AS code,
    TRUE AS distributed,
    'lau1' AS geolocation_in_source
  FROM base AS b
  LEFT JOIN lau1_beneficiary_name AS p ON b.transaction_id = p.transaction_id
  INNER JOIN lau2_units AS u ON
    CASE
      WHEN b.nuts2 = 'Konkurrenceudsat pulje' AND LOWER(b.partner) LIKE CONCAT('%',LOWER(u.lau1_name),'%') THEN 1
      WHEN LOWER(b.nuts2_corr) = LOWER(REPLACE(u.nuts2_name, 'Region ', '')) AND LOWER(b.partner) LIKE CONCAT('%',LOWER(u.lau1_name),'%') THEN 1
      ELSE 0
    END = 1
  WHERE p.transaction_id IS NULL
    --AND lower(b.partner) LIKE '%kommune%'
  GROUP BY 1,3,4
),

lau1_description AS (
  SELECT DISTINCT
    b.transaction_id,
    array_remove(array_agg(u.lau2_code), NULL) AS code,
    TRUE AS distributed,
    'lau1' AS geolocation_in_source
  FROM base AS b
  LEFT JOIN lau1_beneficiary_name AS lb ON b.transaction_id = lb.transaction_id
  LEFT JOIN lau1_partner AS lp ON b.transaction_id = lp.transaction_id
  INNER JOIN lau2_units AS u ON
    CASE
      WHEN b.nuts2 = 'Konkurrenceudsat pulje' AND LOWER(b.project_description) LIKE CONCAT('%',LOWER(u.lau1_name),'%') THEN 1
      WHEN LOWER(b.nuts2_corr) = LOWER(REPLACE(u.nuts2_name, 'Region ', '')) AND LOWER(b.project_description) LIKE CONCAT('%',LOWER(u.lau1_name),'%') THEN 1
      ELSE 0
    END = 1
  WHERE lb.transaction_id IS NULL
    AND lp.transaction_id IS NULL
  GROUP BY 1,3,4
),

lau1_beneficiary_city AS (
  SELECT DISTINCT
    b.transaction_id,
    array_remove(array_agg(u.lau2_code), NULL) AS code,
    TRUE AS distributed,
    'lau1' AS geolocation_in_source
  FROM base AS b
  LEFT JOIN lau1_beneficiary_name AS lb ON b.transaction_id = lb.transaction_id
  LEFT JOIN lau1_partner AS lp ON b.transaction_id = lp.transaction_id
  LEFT JOIN lau1_description AS ld ON b.transaction_id = ld.transaction_id
  INNER JOIN lau2_units AS u ON
    CASE
      WHEN b.nuts2 = 'Konkurrenceudsat pulje' AND LOWER(b.beneficiary_city) LIKE CONCAT('%',LOWER(u.lau1_name),'%') THEN 1
      WHEN LOWER(b.nuts2_corr) = LOWER(REPLACE(u.nuts2_name, 'Region ', '')) AND LOWER(b.beneficiary_city) LIKE CONCAT('%',LOWER(u.lau1_name),'%') THEN 1
      ELSE 0
    END = 1
  WHERE lb.transaction_id IS NULL
    AND lp.transaction_id IS NULL
    AND ld.transaction_id IS NULL
  GROUP BY 1,3,4
),

nuts2 AS (
  SELECT
    b.transaction_id,
    array_remove(array_agg(u.lau2_code), NULL) AS code,
    TRUE AS distributed,
    'nuts2' AS geolocation_in_source
  FROM base AS b
  LEFT JOIN lau1_beneficiary_name AS lb ON b.transaction_id = lb.transaction_id
  LEFT JOIN lau1_partner AS lp ON b.transaction_id = lp.transaction_id
  LEFT JOIN lau1_description AS ld ON b.transaction_id = ld.transaction_id
  LEFT JOIN lau1_beneficiary_city AS lbc ON b.transaction_id = lbc.transaction_id
  INNER JOIN lau2_units AS u ON
    CASE
      WHEN LOWER(b.nuts2_corr) = LOWER(REPLACE(u.nuts2_name, 'Region ', '')) THEN 1
      ELSE 0
    END = 1
  WHERE lb.transaction_id IS NULL
    AND lp.transaction_id IS NULL
    AND ld.transaction_id IS NULL
    AND lbc.transaction_id IS NULL
  GROUP BY 1,3,4
),

nuts1 AS (
  SELECT
    b.transaction_id,
    array_remove(array_agg(u.lau2_code), NULL) AS code,
    TRUE AS distributed,
    'national' AS geolocation_in_source
  FROM base AS b
  LEFT JOIN lau1_beneficiary_name AS lb ON b.transaction_id = lb.transaction_id
  LEFT JOIN lau1_partner AS lp ON b.transaction_id = lp.transaction_id
  LEFT JOIN lau1_description AS ld ON b.transaction_id = ld.transaction_id
  LEFT JOIN lau1_beneficiary_city AS lbc ON b.transaction_id = lbc.transaction_id
  LEFT JOIN nuts2 AS n ON b.transaction_id = n.transaction_id
  CROSS JOIN lau2_units AS u
  WHERE lb.transaction_id IS NULL
    AND lp.transaction_id IS NULL
    AND ld.transaction_id IS NULL
    AND lbc.transaction_id IS NULL
    AND n.transaction_id IS NULL
  GROUP BY 1,3,4
),

collected AS (
  SELECT * FROM lau1_beneficiary_name
  UNION ALL
  SELECT * FROM lau1_partner
  UNION ALL
  SELECT * FROM lau1_description
  UNION ALL
  SELECT * FROM lau1_beneficiary_city
  UNION ALL
  SELECT * FROM nuts2
  UNION ALL
  SELECT * FROM nuts1
),

distributed AS (
  SELECT
    transaction_id,
    distributed,
    geolocation_in_source,
    UNNEST(code) AS lau2_code
    FROM collected
),


--total_amount conversion and eu_cofinancing_amount is calculated on the basis of the daily DKK-EUR average rates between 2007-2013, downloaded from:
--https://www.investing.com/currencies/eur-dkk-historical-data.
vw AS (
  SELECT
    b.transaction_id,
    b.project_title AS project_name,
    b.beneficiary_name,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY d.transaction_id)*total_amount/7.4503891626 AS total_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY d.transaction_id)*eu_cofinancing_amount/7.4503891626 AS eu_cofinancing_amount,
    (p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY d.transaction_id)*total_amount) - (p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY d.transaction_id)*eu_cofinancing_amount)/7.4503891626 AS amount,
    'member state contribution' AS amount_kind,
    UNACCENT(LOWER(b.beneficiary_name)) AS beneficiary_id,
    CASE
      WHEN b.fund_acronym IN ('ERDFN','ERDFD','ERDFS','ERDFM','ERDFB','ERDFH','ERDFK') THEN 'ERDF'
      WHEN b.fund_acronym IN ('ESFN','ESFK','ESFH','ESFB','ESFS','ESFD','ESFM') THEN 'ESF'
      ELSE 'N/A'
    END AS fund_acronym,
    '2007-2013' AS funding_period,
    d.distributed,
    d.geolocation_in_source,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    'Denmark' AS country,
    'DK' AS country_code,
    'DK' AS beneficiary_country_code,
    b.beneficiary_city,
    b.address AS beneficiary_address,
    b.postcode AS beneficiary_postal_code,
    b.start_date,
    b.end_date 
  FROM distributed AS d
  INNER JOIN base AS b on d.transaction_id = b.transaction_id
  INNER JOIN pre_population AS p ON d.lau2_code = p.lau2_code
)

SELECT * FROM vw;