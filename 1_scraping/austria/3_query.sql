INSERT INTO public."final" (
  transaction_id,
  project_name,
  beneficiary_name,
  total_amount,
  beneficiary_id,
  fund_acronym,
  funding_period,
  project_state,
  project_region,
  beneficiary_address,
  country,
  country_code,
  beneficiary_country_code,
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
  FROM at_population
),


nuts2_regions AS (
  SELECT DISTINCT
    nuts1_name,
    nuts2_name,
    nuts2_code
  FROM pre_population
),


transactions_base AS (
  SELECT
    md5(CONCAT('AT',ROW_NUMBER() OVER ()::text)) AS transaction_id,
    *,
    CASE
      WHEN region IS NOT NULL THEN region
      WHEN region IS NULL AND funding_agency = 'Land Steiermark' THEN 'AT22'
      WHEN region IS NULL AND funding_agency = 'RMB - Regionalmanagement Burgenland Ges.m.b.H.' THEN 'AT11'
      WHEN region IS NULL AND funding_agency = 'Amt der Burgenländischen Landesregierung, Abt. 5 (Anlagenrecht, Umweltschutz und Verkehr, HR Tourismus)' THEN 'AT11'
      WHEN region IS NULL AND funding_agency = 'Land Oberösterreich' THEN 'AT31'
      WHEN region IS NULL AND funding_agency = 'WAFF – Wiener ArbeitnehmerInnenförderungsfonds' THEN 'AT13'
      WHEN region IS NULL AND funding_agency = 'Wiener ArbeitnehmerInnen Förderungsfonds (WAFF)' THEN 'AT13'     
      WHEN region IS NULL AND funding_agency = 'Wirtschaft Burgenland GmbH - WiBuG' THEN 'AT11'
      WHEN region IS NULL AND funding_agency = 'Land Salzburg' THEN 'AT32'
      WHEN region IS NULL AND funding_agency = 'WAFF' THEN 'AT13'
      WHEN region IS NULL AND funding_agency = 'Land Kärnten' THEN 'AT21'
      WHEN region IS NULL AND funding_agency = 'Burgenland' THEN 'AT11'
      WHEN region IS NULL AND funding_agency = 'Land Vorarlberg' THEN 'AT34'      
      WHEN region IS NULL AND funding_agency = 'Wiener ArbeitnehmerInnen Förderungsfonds (WAFF)' THEN 'AT13'
      WHEN region IS NULL AND funding_agency = 'Amt der Burgenländischen Landesregierung, Abt. 7 (Kultur, Wissenschaft und Archiv)' THEN 'AT11'      
      WHEN region IS NULL AND funding_agency = 'Land Niederösterreich' THEN 'AT12'
      WHEN region IS NULL AND funding_agency = 'Land Tirol' THEN 'AT33'
      ELSE NULL
    END AS region_c
  FROM at_transactions
),

esf_burgenland AS (
  SELECT DISTINCT
    beneficiary,
    beneficiary_address
  FROM at_esf_burgenland
),

address_filled AS (
  SELECT
    *
  FROM transactions_base
  WHERE beneficiary_address IS NOT NULL
),

burgenland_address AS (
  SELECT
    b.transaction_id,
    b.id,
    b.status,
    b.fund_acronym,
    b.project_title,
    b.funding_agency,
    b.region,
    b.beneficiary,
    b.project_description,
    eb.beneficiary_address,
    b.end_year,
    b.total_amount,
    b.region_c
  FROM transactions_base AS b
  LEFT JOIN esf_burgenland AS eb ON LOWER(b.beneficiary) = LOWER(eb.beneficiary)
  LEFT JOIN address_filled AS a ON b.transaction_id = a.transaction_id
  WHERE eb.beneficiary_address IS NOT NULL
    AND a.transaction_id IS NULL
),

no_address AS (
  SELECT
    b.*
  FROM transactions_base AS b
  LEFT JOIN address_filled AS af ON b.transaction_id = af.transaction_id
  LEFT JOIN burgenland_address AS ba ON b.transaction_id = ba.transaction_id
  WHERE af.transaction_id IS NULL
    AND ba.transaction_id IS NULL
    
),

pre_base AS (
  SELECT * FROM no_address
  UNION ALL
  SELECT * FROM address_filled
  UNION ALL
  SELECT * FROM burgenland_address
),

base_rownum AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY transaction_id) AS rownum
  FROM pre_base
),

base AS (
  SELECT
    b.*,
    n.nuts1_name,
    n.nuts2_name
  FROM base_rownum AS b
  LEFT JOIN nuts2_regions AS n ON b.region_c = n.nuts2_code
  WHERE rownum = 1
),

vw AS (
  SELECT
    transaction_id,
    project_title AS project_name,
    beneficiary AS beneficiary_name,
    total_amount,
    UNACCENT(LOWER(beneficiary)) AS beneficiary_id,
    fund_acronym,
    '2007-2013' AS funding_period,
    nuts1_name AS project_state,
    nuts2_name AS project_region,
    beneficiary_address,
    'Austria' AS country,
    'AT' AS country_code,
    'AT' AS beneficiary_country_code,
    to_date(end_year::varchar, 'yyyy') AS end_date
  FROM base
)

SELECT * FROM vw;