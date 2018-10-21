INSERT INTO public."si_final" (
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
      WHEN population < 1 THEN 0
      ELSE population
    END AS population_corr
  FROM si_population
),

base AS (
  SELECT
    *,
    md5(CONCAT('SI',ROW_NUMBER() OVER ()::text)) AS transaction_id,
    CASE
      WHEN lau2 = 'BREZOVICA PRI LJUBLJANI' THEN 'Brezovica'
      WHEN lau2 = 'DOBROVA-POLHOV GRADEC' THEN 'Dobrova - Polhov Gradec'
      WHEN lau2 = 'DOBROVNIK' THEN 'Dobronak'
      WHEN lau2 = 'HODOŠ' THEN 'Hodos'
      WHEN lau2 = 'HOČE-SLIVNICA' THEN 'Hoče - Slivnica'
      WHEN lau2 = 'HRPELJE-KOZINA' THEN 'Hrpelje - Kozina'
      WHEN lau2 = 'IZOLA' THEN 'Isola'
      WHEN lau2 = 'KANAL OB SOČI' THEN 'Kanal'
      WHEN lau2 = 'KOPER' THEN 'Capodistria'
      WHEN lau2 = 'LENDAVA' THEN 'Lendva'
      WHEN lau2 = 'LOG-DRAGOMER' THEN 'Log - Dragomer'
      WHEN lau2 = 'MIKLAVŽ' THEN 'Miklavž na Dravskem polju'
      WHEN lau2 = 'MIRNA' THEN 'Mirna Peč'
      WHEN lau2 = 'MOKRONOG -TREBELNO' THEN 'Mokronog - Trebelno'
      WHEN lau2 = 'PIRAN' THEN 'Pirano'
      WHEN lau2 = 'RENČE-VOGRSKO' THEN 'Renče - Vogrsko'
      WHEN lau2 = 'SVETA TROJICA V SLOVENSKIH GORICAH' THEN 'Sveta Trojica v Slov. goricah'
      WHEN lau2 = 'SVETI ANDRAŽ V SLOVENSKIH GORICAH' THEN 'Sveti Andraž v Slov. goricah'
      WHEN lau2 = 'SVETI JURIJ OB ŠČAVNICI' THEN 'Sveti Jurij'
      WHEN lau2 = 'SVETI JURIJ V SLOVENSKIH GORICAH' THEN 'Sveti Jurij v Slov. goricah'
      WHEN lau2 = 'VIUZENICA' THEN 'Vuzenica'
      WHEN lau2 = 'ŠENTJANŽ PRI DRAVOGRADU' THEN 'Dravograd'
      WHEN lau2 = 'ŠENTJUR PRI CELJU' THEN 'Šentjur'
      WHEN lau2 = 'ŽEČEZNIKI' THEN 'Železniki'
      ELSE lau2
    END AS lau2_name_corr
  FROM si_transactions
),

national_projects AS (
  SELECT
    b.*,
    p.*,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id) * b.total_amount AS total_amount_d,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id) * b.eu_cofinancing_amount AS eu_cofinancing_amount_d,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id) * b.member_state_amount AS amount_d
  FROM base AS b
  CROSS JOIN pre_population AS p
  WHERE (b.lau2 IS NULL OR b.lau2 = 'VEČ OBČIN')
    AND b.nuts3 IN ('PROJEKT Z VPLIVOM V VEČ REGIJ',
               'PROJEKT Z VPLIVOM V VSE REGIJE',
               'PROJEKTI Z VPLIVOM V VSE REGIJE',
               'SLOVENIJA')
),

regional_projects AS (
  SELECT
    *
  FROM base
  WHERE (lau2 IS NULL OR lau2 = 'VEČ OBČIN')
    AND nuts3 NOT IN ('PROJEKT Z VPLIVOM V VEČ REGIJ',
               'PROJEKT Z VPLIVOM V VSE REGIJE',
               'PROJEKTI Z VPLIVOM V VSE REGIJE',
               'SLOVENIJA')
),

regional_projects_lau2 AS (
  SELECT
    r.*,
    p.*,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY r.transaction_id) * r.total_amount AS total_amount_d,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY r.transaction_id) * r.eu_cofinancing_amount AS eu_cofinancing_amount_d,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY r.transaction_id) * r.member_state_amount AS amount_d
  FROM regional_projects AS r
  INNER JOIN si_beneficiary_translate AS b ON r.beneficiary = b.beneficiary
  INNER JOIN pre_population AS p ON p.lau2_name = b.lau2_name
  WHERE r.beneficiary NOT IN ('DARS',
                  'DIREKCIJA RS ZA INFRASTRUKTURO',
                  'DIREKCIJA RS ZA VODENJE INVESTICIJ V JAVNO ŽELEZNIŠKO INFRASTRUKTURO',
                  'DRSC',
                  'MINISTRSTVO ZA KMETIJSTVO IN OKOLJE',
                  'REGIONALNA RAZVOJNA AGENCIJA MURA D.O.O.',
                  'RRA (SKUPNI) KOROŠKA'
                  )
),

regional_projects_nuts3 AS (
  SELECT
    r.*,
    p.*,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY r.transaction_id) * r.total_amount AS total_amount_d,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY r.transaction_id) * r.eu_cofinancing_amount AS eu_cofinancing_amount_d,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY r.transaction_id) * r.member_state_amount AS amount_d
  FROM regional_projects AS r
  INNER JOIN pre_population AS p ON LOWER(r.nuts3) = LOWER(p.nuts3_name)
  WHERE beneficiary IN ('DARS',
              'DIREKCIJA RS ZA INFRASTRUKTURO',
              'DIREKCIJA RS ZA VODENJE INVESTICIJ V JAVNO ŽELEZNIŠKO INFRASTRUKTURO',
              'DRSC',
              'MINISTRSTVO ZA KMETIJSTVO IN OKOLJE',
              'REGIONALNA RAZVOJNA AGENCIJA MURA D.O.O.',
              'RRA (SKUPNI) KOROŠKA'
              )
),

local_projects_lau2 AS (
  SELECT
    b.*,
    p.*,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id) * b.total_amount AS total_amount_d,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id) * b.eu_cofinancing_amount AS eu_cofinancing_amount_d,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id) * b.member_state_amount AS amount_d
  FROM base AS b
  INNER JOIN pre_population AS p ON LOWER(b.lau2_name_corr) = LOWER(p.lau2_name)
  WHERE b.lau2 IS NOT NULL AND b.lau2 != 'VEČ OBČIN'
),

transactions_distributed AS (
  SELECT * FROM national_projects
  UNION ALL
  SELECT * FROM regional_projects_lau2
  UNION ALL
  SELECT * FROM regional_projects_nuts3
  UNION ALL
  SELECT * FROM local_projects_lau2
),

vw AS (
  SELECT
    transaction_id,
    project_title AS project_name,
    beneficiary AS beneficiary_name,
    total_amount_d AS total_amount,
    eu_cofinancing_amount_d AS eu_cofinancing_amount,
    amount_d AS amount,
    'member_state_contribution' AS amount_kind,
    UNACCENT(LOWER(beneficiary)) AS beneficiary_id,
    CASE
      WHEN fund_acronym = 'ESRR' THEN 'ERDF'
      WHEN fund_acronym = 'ESS' THEN 'ESF'
      ELSE 'CF'
    END AS fund_acronym,
    '2007-2013' AS funding_period,
    nuts1_name AS project_state,
    nuts2_name AS project_region,
    nuts3_name AS project_county,
    nuts3_code AS project_nuts3,
    lau2_name AS project_city,
    lau2_code AS project_lau2,
    'Slovenia' AS country,
    'SI' AS country_code,
    'SI' AS beneficiary_country_code,
    start_date
  FROM transactions_distributed
)

SELECT * FROM vw;