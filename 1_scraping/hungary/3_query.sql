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
  beneficiary_country_code
)
WITH
pre_population AS (
  SELECT
    *,
    CASE
      WHEN population > 0 THEN population
      ELSE 1
    END AS population_corr
  FROM hu_population
),


--total_amount conversion is calculated on the basis of the daily EUR-HUF average rates between 2007-2013, downloaded from:
--https://www.investing.com/currencies/eur-huf-historical-data.

alldata AS (
  SELECT
    h.project_name,
    h.beneficiary_name,
    h.beneficiary_id,
    COALESCE(h.total_ammount, h.eu_cofinancing_amount, 0)/274.8695019157 AS total_ammount,
    h.eu_cofinancing_amount,
    0 AS amount,
    h.amount_kind,
    h.fund_acronym,
    h.funding_period,
    h.geocoding_helper_city,
    p.lau2_code AS lau2_base,
    md5(CONCAT('HU',ROW_NUMBER() OVER ()::text)) AS transaction_id
  FROM "1_hungary" AS h
  LEFT JOIN pre_population AS p ON h.geocoding_helper_city = p.lau2_name
  WHERE h.funding_period = '2007-2013'
),

govt_institutions AS (
  SELECT
    *
  FROM alldata
  WHERE lau2_base IS NULL
    AND (UPPER(beneficiary_name) LIKE '%ÖNKORMÁNYZAT%' OR UPPER(beneficiary_name) LIKE '%KÖZSÉG%')
    AND (UPPER(beneficiary_name) NOT IN ('BUDAKÖRNYÉKI ÖNKORMÁNYZATI TÁRSULÁS',
                       'TÁRSULT ÖNKORMÁNYZATOK EGYÜTT SEGÍTŐSZOLGÁLATA',
                       'KÖZSÉGI ÖNKORMÁNYZAT POLGÁRMESTERI HIVATALA',
                       'MINDENNAPI VIZÜNK IVÓVÍZMINŐSÉG-JAVÍTÓ ÖNKORMÁNYZATI TÁRSULÁS',
                       'KÖZSÉGI ÖNKORMÁNYZAT',
                       'TISZTA VÍZ IVÓVÍZMINŐSÉG-JAVÍTÓ ÖNKORMÁNYZATI TÁRSULÁS'
                       ))
),

govt_institutions_distributed AS (
  SELECT
    beneficiary,
    unnest(string_to_array(city,', ')) AS city
  FROM "2_govt_translate"
),

govt_projects AS (
  SELECT distinct 
    a.transaction_id,
    a.project_name,
    a.beneficiary_name,
    p.population_corr*1.0 / sum(p.population_corr) OVER (PARTITION BY a.transaction_id) * a.total_ammount AS total_amount,
    a.eu_cofinancing_amount,
    a.amount,
    a.amount_kind,
    a.beneficiary_id,
    a.fund_acronym,
    a.funding_period,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2
  FROM govt_institutions AS a
  INNER JOIN govt_institutions_distributed AS g ON a.beneficiary_name = g.beneficiary
  INNER JOIN pre_population AS p ON g.city = p.lau2_name
  WHERE g.city != ''
  
),

unidentified_projects AS (
  SELECT
    a.transaction_id,
    a.project_name,
    a.beneficiary_name,
    a.total_ammount AS total_amount,
    a.eu_cofinancing_amount,
    a.amount,
    a.amount_kind,
    a.beneficiary_id,
    a.fund_acronym,
    a.funding_period,
    NULL AS project_state,
    NULL AS project_region,
    NULL AS project_county,
    NULL::text AS project_nuts3,
    NULL AS project_city,
    NULL AS project_lau2
  FROM alldata AS a
  LEFT JOIN govt_institutions AS g on a.beneficiary_name = g.beneficiary_name
  WHERE a.lau2_base IS NULL 
    AND g.beneficiary_name IS NULL 
),

identified_projects AS (
  SELECT
    a.transaction_id,
    a.project_name,
    a.beneficiary_name,
    a.total_ammount AS total_amount,
    a.eu_cofinancing_amount,
    a.amount,
    a.amount_kind,
    a.beneficiary_id,
    a.fund_acronym,
    a.funding_period,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2
  FROM alldata AS a
  LEFT JOIN pre_population AS p ON a.lau2_base = p.lau2_code
  WHERE a.lau2_base IS NOT NULL
),

prepared_data AS (
  SELECT * FROM identified_projects
  UNION ALL
  SELECT * FROM govt_projects
  UNION ALL
  SELECT * FROM unidentified_projects

),

vw AS (
  SELECT
    *,
    'Hungary' AS country,
    'HU' AS country_code,
    'HU' AS beneficiary_country_code
FROM prepared_data
)

SELECT * FROM vw;