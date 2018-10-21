INSERT INTO public."mt_final" (
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
  FROM mt_population
),

transaction_base AS (
  SELECT
    md5(CONCAT('MT',ROW_NUMBER() OVER()::text)) AS transaction_id,
    *
  FROM mt_transactions
),

place_names_detected AS (
  SELECT
    b.transaction_id,
    ARRAY_REMOVE(ARRAY[p1.lau2_code,p2.lau2_code,p3.lau2_code,p4.lau2_code,p5.lau2_code], NULL) AS places_array
  FROM transaction_base AS b
  LEFT JOIN pre_population AS p1 ON LOWER(UNACCENT(b.project_description)) LIKE CONCAT('%',LOWER(UNACCENT(p1.lau2_name)),'%')
  LEFT JOIN pre_population AS p2 ON LOWER(UNACCENT(b.project_purpose)) LIKE CONCAT('%',LOWER(UNACCENT(p2.lau2_name)),'%')
  LEFT JOIN pre_population AS p3 ON LOWER(UNACCENT(b.project_objectives)) LIKE CONCAT('%',LOWER(UNACCENT(p3.lau2_name)),'%')
  LEFT JOIN pre_population AS p4 ON LOWER(UNACCENT(b.project_results)) LIKE CONCAT('%',LOWER(UNACCENT(p4.lau2_name)),'%')
  LEFT JOIN pre_population AS p5 ON LOWER(UNACCENT(b.beneficiary)) LIKE CONCAT('%',LOWER(UNACCENT(p5.lau2_name)),'%')
),

place_names_unnested AS (
  SELECT DISTINCT
    transaction_id,
    UNNEST(CASE WHEN places_array <> '{}' THEN places_array ELSE '{null}' END) AS place_codes
  FROM place_names_detected
),

place_names_array AS (
  SELECT
    transaction_id,
    ARRAY_AGG(place_codes) AS places_array
  FROM place_names_unnested
  GROUP BY transaction_id
),

base_extended_with_placenames AS (
  SELECT
    b.*,
    UNNEST(CASE WHEN pn.places_array <> '{}' THEN pn.places_array ELSE '{null}' END) AS lau_code
  FROM transaction_base AS b
  LEFT JOIN place_names_array AS pn ON b.transaction_id = pn.transaction_id
),

vw AS (
  SELECT
     b.transaction_id,
     b.project_title AS project_name,
     b.beneficiary AS beneficiary_name,
     CASE
       WHEN b.lau_code IS NULL THEN project_cost
       ELSE p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id) * b.project_cost
     END AS total_amount,
     CASE
       WHEN b.lau_code IS NULL THEN project_cost*0.85
       ELSE p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id) * b.project_cost*0.85
     END AS eu_cofinancing_amount,
     CASE
       WHEN b.lau_code IS NULL THEN project_cost*0.15
       ELSE p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id) * b.project_cost*0.15
     END AS amount,
    'member_state_contribution' AS amount_kind,
    LOWER(UNACCENT(beneficiary)) AS beneficiary_id,
    CASE
      WHEN fund_acronym = 'European Regional Development Fund' THEN 'ERDF'
      WHEN fund_acronym = 'European Social Fund' THEN 'ESF'
      WHEN fund_acronym = 'Cohesion Fund' THEN 'CF'
      ELSE NULL
    END AS fund_acronym,
    '2007-2013' AS funding_period,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    'Malta' AS country,
    'MT' AS country_code,
    'MT' AS beneficiary_country_code,
    CASE
      WHEN start_date = '01/03/2010' THEN '2010-03-01'::date
      WHEN start_date = '30/11/2009' THEN '2009-11-30'::date
      WHEN start_date = '31/01/2011' THEN '2011-01-31'::date
      WHEN start_date = 'Q1 2013' THEN '2013-01-01'::date
      WHEN start_date = 'Q2 2009' THEN '2009-04-01'::date
      WHEN start_date = 'Q3 2009' THEN '2009-07-01'::date
      WHEN start_date = 'Tuesday, January 31, 2012' THEN '2012-01-31'::date
      WHEN start_date = 'Tuesday, October 18, 2011' THEN '2011-10-18'::date
      WHEN start_date = 'Wednesday, October 12, 2011' THEN '2011-10-12'::date
      WHEN start_date ~ '^([0-9]+[.]?[0-9]*|[.][0-9]+)$' THEN to_date(start_date::varchar, 'yyyy')
      ELSE NULL
    END AS start_date,
    CASE
      WHEN end_date = '02/01/2012' THEN '2012-01-02'::date
      WHEN end_date = '04/02/2011' THEN '2011-02-04'::date
      WHEN end_date = '29/09/2013' THEN '2013-09-29'::date
      WHEN end_date = 'Monday, July 16, 2012' THEN '2012-07-16'::date
      WHEN end_date = 'Q2 2011' THEN '2011-06-30'::date
      WHEN end_date = 'Q3 2015' THEN '2015-09-30'::date
      WHEN end_date = 'Q4 2011' THEN '2011-12-31'::date
      WHEN end_date = 'Sunday, June 30, 2013' THEN '2013-06-30'::date
      WHEN end_date = 'Thursday, October 20, 2011' THEN '2011-10-20'::date
      WHEN end_date  ~ '^([0-9]+[.]?[0-9]*|[.][0-9]+)$' THEN to_date(start_date::varchar, 'yyyy')
      ELSE NULL
    END AS end_date
  FROM base_extended_with_placenames AS b
  LEFT JOIN pre_population As p ON b.lau_code = p.lau2_code
)

SELECT * FROM vw;