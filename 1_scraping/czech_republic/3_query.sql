
INSERT INTO final (transaction_id,country,country_code,project_name,beneficiary_name,total_ammount,eu_cofinancing_amount,amount,amount_kind,beneficiary_country_code,beneficiary_id,fund_acronym,funding_period,geocoding_state,beneficiary_state,beneficiary_region,beneficiary_county,beneficiary_nuts3,beneficiary_city,beneficiary_lau2,beneficiary_postal_code,beneficiary_address,beneficiary_lat,beneficiary_long,project_state,project_region,project_county,project_nuts3,project_city,project_lau2,project_postal_code,project_address,project_lat,project_long)
WITH
base0 AS (
  SELECT
    project_id,
    ROW_NUMBER () OVER() AS transaction_id
    FROM czech_english
    GROUP BY project_id
),

base AS (
  SELECT
    l.*, 
    md5(CONCAT('CZ',r.transaction_id::text)) AS transaction_id
  FROM czech_english AS l
  INNER JOIN base0 AS r ON l.project_id = r.project_id
),

prepolish AS (
  SELECT
    *,
    (ROUND(paid_eu::numeric,2) + paid_member_state) AS paid_total,
    CASE
      WHEN project_lau2_name IN (
        'M. st. Warszawa',
        'M. Bielsko-Biała',
        'M. Chorzów',
        'M. Gliwice',
        'M. Katowice',
        'M. Zabrze',
        'M. Jastrzębie-Zdrój',
        'M. Rybnik',
        'M. Żory',
        'M. Jelenia Góra',
        'M. Wrocław',
        'M. Opole'
      ) THEN replace(replace(project_lau2_name, 'M. ', ''), 'st. ', '')
      ELSE project_lau2_name
    END AS project_lau2_name_f
  FROM base
  WHERE project_lau2 LIKE 'PL%'
),

polish AS (
  SELECT
    l.*,
    r.lau2_code AS lau2_code_f,
    GREATEST(r.population,1) AS population,
    l.transaction_order AS transaction_order_f
  FROM prepolish AS l
  LEFT JOIN czech_pop AS r ON l.project_lau2_name_f = r.lau2_name
),

preempties AS (
  SELECT
    *,
    (ROUND(paid_eu::numeric,2) + paid_member_state) AS paid_total,
    project_lau2_name AS project_lau2_name_f
  FROM base
  WHERE project_lau2 = ''
),

empties AS (
  SELECT
    l.*,
    r.lau2_code AS lau2_code_f,
    GREATEST(r.population,1) AS population,
    l.transaction_order AS transaction_order_f 
  FROM preempties AS l
  LEFT JOIN czech_pop AS r ON
    CASE
      WHEN LENGTH(l.beneficiary_lau2) = 6 THEN l.beneficiary_lau2
      ELSE SUBSTRING(l.beneficiary_lau2, 7, 7)
    END = SUBSTRING(r.lau2_code, 7, 7)
  WHERE l.transaction_order != 0
),

prelau1 AS (
  SELECT
    *,
    (ROUND(paid_eu::numeric,2) + paid_member_state) AS paid_total
FROM base
WHERE LENGTH(project_lau2) = 6 AND project_lau2 NOT LIKE 'PL%'
),

lau1 AS (
  SELECT
    l.*,
    rr.lau2_name AS project_lau2_name_f,
    rr.lau2_code AS lau2_code_f,
    GREATEST(rr.population,1) AS population,
    CASE
      WHEN l.transaction_order = 1 THEN ROW_NUMBER() OVER (PARTITION BY l.project_id)
      ELSE 2
    END AS transaction_order_f
  FROM prelau1 AS l
  LEFT JOIN czech_lau_translate AS r ON l.project_lau2 = r.lau1_code
  LEFT JOIN czech_pop AS rr ON r.lau2_code = SUBSTRING(rr.lau2_code, 7, 7)
),

prelau2 AS (
  SELECT
    *,
    (ROUND(paid_eu::numeric,2) + paid_member_state) AS paid_total,
    project_lau2_name AS project_lau2_name_f
  FROM base AS l
  WHERE project_lau2 NOT LIKE 'PL%'
    AND LENGTH(project_lau2) != 6
    AND project_lau2 != ''
),

lau2 AS (
  SELECT
    l.*,
    r.lau2_code AS lau2_code_f,
    GREATEST(r.population,1) AS population,
    l.transaction_order AS transaction_order_f
  FROM prelau2 AS l
  LEFT JOIN czech_pop AS r ON
    CASE
      WHEN project_lau2_name LIKE 'Pardubice%' THEN '555134'
      WHEN project_lau2_name LIKE 'Liberec%' THEN '563889'
      WHEN project_lau2_name LIKE 'Ústí nad Labem%' THEN '554804'
      WHEN project_lau2_name LIKE 'Brno%' THEN '582786'
      WHEN project_lau2_name LIKE 'Plzeň%' THEN '554791'
      WHEN project_lau2_name LIKE 'Praha%' THEN '554782'
      WHEN project_lau2_name LIKE 'Nemíž%' THEN '530751'
      WHEN project_lau2_name LIKE 'Krhová%' THEN '590967'
      WHEN project_lau2_name LIKE 'Poličná%' THEN '544621'
      WHEN project_lau2 LIKE 'CZ0805555%' THEN '505927'
      WHEN project_lau2 LIKE 'CZ0806545%' THEN '554821'
      WHEN project_lau2 LIKE 'CZ0806546%' THEN '554821'
      WHEN project_lau2 LIKE 'CZ0806554%' THEN '554821'
      WHEN project_lau2 = 'CZ0805556700' THEN '505927'
      ELSE SUBSTRING(project_lau2, 7, 8)
    END = SUBSTRING(r.lau2_code, 7, 7)
),
alltogether AS (
  SELECT * FROM polish
  UNION
  SELECT * FROM empties
  UNION
  SELECT * FROM lau1
  UNION
  SELECT * FROM lau2
),
vw AS (
    SELECT  
        *,
        b.paid_eu*0.03886196618232*(b.population*1.0 / sum(b.population) OVER (PARTITION BY b.project_id)) AS final_sum_eu2,
        b.paid_total*0.03886196618232*(b.population*1.0 / sum(b.population) OVER (PARTITION BY b.project_id)) AS paid_total_f,
        b.paid_member_state*0.03886196618232*(b.population*1.0 / sum(b.population) OVER (PARTITION BY b.project_id)) AS paid_member_state_f
    FROM alltogether AS b
)
SELECT
  transaction_id AS transaction_id,
  'Czech Republic' AS country,
  'CZ' AS country_code,
  project_name AS project_name,
  beneficiary AS beneficiary_name,
  paid_total_f AS total_ammount,
  final_sum_eu2 AS eu_cofinancing_amount,
  paid_member_state_f AS amount,
  'Member state contribution' AS amount_kind,
  'CZ' AS beneficiary_country_code,
  beneficiary_id AS beneficiary_id,
  NULL AS fund_acronym,
  '2007-2013' AS funding_period,
  NULL AS geocoding_state,
  NULL AS beneficiary_state,
  NULL AS beneficiary_region,
  beneficiary_nuts3_name AS beneficiary_county,
  beneficiary_nuts3 AS beneficiary_nuts3,  
  beneficiary_lau2_name AS beneficiary_city,
  beneficiary_lau2 AS beneficiary_lau2,
  NULL AS beneficiary_postal_code,
  beneficiary_address AS beneficiary_address,
  NULL AS beneficiary_lat,
  NULL AS beneficiary_long,
  NULL AS project_state,
  NULL AS project_region,
  NULL AS project_county,
  NULL AS project_nuts3,
  project_lau2_name_f AS project_city,
  lau2_code_f AS project_lau2,
  NULL AS project_postal_code,
  NULL AS project_address,
  NULL AS project_lat,
  NULL AS project_long
FROM vw;