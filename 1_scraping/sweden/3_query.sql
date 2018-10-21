INSERT INTO public."se_final" (
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
  FROM se_population
),

lau1_units AS (
  SELECT DISTINCT
    lau1_name
  FROM pre_population
),

--amount_granted_sek and public_funding_amount conversion is calculated on the basis of the daily EUR-SEK average rates between 2007-2013, downloaded from:
--https://www.investing.com/currencies/eur-sek-historical-data.

transactions_base AS (
  SELECT
    (amount_granted_sek / 8.9453) + amount_granted_euro + (public_funding_amount / 8.9453) As total_amount,
    (amount_granted_sek / 8.9453) + amount_granted_euro AS eu_cofinancing_amount,
    public_funding_amount / 8.9453 AS amount,
    md5(CONCAT('SE',ROW_NUMBER() OVER ()::text)) AS transaction_id,
    *
  FROM se_transactions
),

lau2_transactions AS (
  SELECT
    *,
    NULL AS lau_name_split,
    TRIM(UNNEST(STRING_TO_ARRAY(lau2_name, ','))) AS lau_name_mined,
    'lau2' AS unit_type
  FROM transactions_base
  WHERE lau2_name IS NOT NULL
),

lau1_transactions_base AS (
  SELECT
    t.*
  FROM transactions_base AS t
  LEFT JOIN lau2_transactions AS l ON t.transaction_id = l.transaction_id
  WHERE l.transaction_id IS NULL
),

lau1_transactions_base_2 AS (
  SELECT
    *,
    TRIM(UNNEST(STRING_TO_ARRAY(nuts3_name, ','))) AS lau_name_split
  FROM lau1_transactions_base
  WHERE nuts3_name IS NOT NULL
),

lau1_transactions AS (
  SELECT
    *,
  CASE
    WHEN lau_name_split = 'Åsterbotten' THEN 'Västerbottens län'
    WHEN lau_name_split = 'Dalarna' THEN 'Dalarnas län'
    WHEN lau_name_split = 'Gävleborg' THEN 'Gävleborgs län'
    WHEN lau_name_split = 'Halland' THEN 'Hallands län'
    WHEN lau_name_split = 'Jämtland' THEN 'Jämtlands län'
    WHEN lau_name_split = 'Jönköping' THEN 'Jönköpings län'
    WHEN lau_name_split = 'Örebro' THEN 'Örebro län'
    WHEN lau_name_split = 'Skåne' THEN 'Skåne län'
    WHEN lau_name_split = 'Stockholm' THEN 'Stockholms län'
    WHEN lau_name_split = 'Värmland' THEN 'Värmlands län'
    WHEN lau_name_split = 'Västerbotten' THEN 'Västerbottens län'
    WHEN lau_name_split = 'Västernorrland' THEN 'Västernorrlands län'
    WHEN lau_name_split = 'Västra Götaland' THEN 'Västra Götalands län'
  END AS lau_name_mined,
  'lau1' AS unit_type
  FROM lau1_transactions_base_2
  WHERE lau_name_split NOT IN ('Akershus fylke',
    					   		'Aust-Agder',
    					   		'Buskerud',
    					   		'Hedmarks fylke',
    					   		'Mellersta Österbotten',
    					   		'Nord tröndelags fylke',
    					   		'Nordlands fylke',
    					   		'Opplands fylke',
    					   		'Oslo kommun',
    					   		'Österbotten',
    					   		'Östfolds fylke',
    					   		'Region Hovedstaden',
    					   		'Region Midtjylland',
    					   		'Region Nordjylland',
    					   		'Region Sjaelland',
    					   		'Satakunta',
    					   		'Södra Österbotten',
    					   		'Sör tröndelags fylke',
    					   		'Telemark fylke',
    					   		'Vest-Agder',
    					   		'Vestfold')
),

national_transactions AS (
  SELECT
    *,
    NULL AS lau_name_split,
    NULL AS lau_name_mined,
    'nuts1' AS unit_type
  FROM lau1_transactions_base
  WHERE nuts3_name IS NULL
),

all_transactions AS (
  SELECT * FROM lau2_transactions
  UNION ALL
  SELECT * FROM lau1_transactions
  UNION ALL
  SELECT * FROM national_transactions
),

vw AS (
  SELECT
    t.transaction_id,
    t.project_name_long AS project_name,
    t.beneficiary_long AS beneficiary_name,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.total_amount AS total_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.eu_cofinancing_amount AS eu_cofinancing_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY t.transaction_id) * t.amount AS amount,
    'Member_state_contribution' AS amount_kind,
    UNACCENT(t.beneficiary_long) AS beneficiary_id,
    NULL AS fund_acronym,
    '2007-2013' AS funding_period,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    'Sweden' AS country,
    'SE' AS country_code,
    'SE' AS beneficiary_country_code,
    to_char(start_date, 'YYYY-MM-DD')::date AS start_date,
    to_char(end_date, 'YYYY-MM-DD')::date AS end_date
  FROM all_transactions AS t
  LEFT JOIN pre_population As p ON
    CASE
      WHEN t.unit_type = 'lau2' AND t.lau_name_mined = p.lau2_name THEN 1
      WHEN t.unit_type = 'lau1' AND t.lau_name_mined = p.lau1_name THEN 1
      WHEN t.unit_type = 'nuts1' THEN 1
      ELSE 0
    END = 1
)

SELECT * FROM vw;