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
  FROM cy_population
),

base AS (
  SELECT
    md5(CONCAT('CY',ROW_NUMBER() OVER()::text)) AS transaction_id,
    *
  FROM cy_transactions  
),

nuts1 AS (
  SELECT
    *
  FROM base
  WHERE beneficiary IN ('Τμήμα Δημοσίων Έργων',
              'Τμήμα Αναπτύξεως Υδάτων',
              'Αρχή Λιμένων Κύπρου',
              'Υπουργείο Εσωτερικών',
              'ΥΠΠ',
              'ΚΕΠΑ',
              'Αρχή Ανάπτυξης Ανθρώπινου Δυναμικού',
              'Σχέδιο Χορηγιών προς Μικρές και Μεσαίαες Επιχειρήσεις για προώθηση του Αγροτουρισμού',
              'Διαχειριστική Αρχή',
              'Δημιουργία Κυβερνητικής Αποθήκης Πληροφοριών',
              'Τμήμα Πολεοδομίας και Οικήσεως',
              'ΑνΑΔ',
              'Δημιουργία Κυβερνητικής Διαδικτυακής Διόδου Ασφαλείας',
              'Υπηρεσία Ενέργειας',
              'Υπηρεσίες Κοινωνικής Ευημερίας',
              'Ινστιτούτο Νευρολογίας και Γενετικής Κύπρου',
              'Τμήμα Ελέγχου στο Υπουργείο Συγκοινωνιών και Έργων',
              'Ινστιτούτο Κύπρου',
              'Υπηρεσία Εσωτερικού Ελέγχου',
              'Υπουργείο Εμπορίου, Βιομηχανίας και Τουρισμού',
              'Κυπριακός Οργανισμός Τουρισμού',
              'Οργανισμός Εργοδοτών και Βιομηχάνων',
              'Σύστημα Υποβολής Εγγράφων για Εγγραφή Εταιρειών μέσω του Διαδικτύου Δημιουργία Ηλεκτρονικού Φακέλου για κάθε Εταιρεία',
              'Κυπριακός Οργανισμός Τουρισμού (ΚΟΤ)',
              'Σύστημα Διαχείρισης και Υποστήριξης Δικτύων και Συστημάτων',
              'Κέντρο Παραγωγικότητας',
              'Τμήμα Δημόσιας Διοίκησης και Προσωπικού',
              'Ινστιτούτο Νευρολογίας και Γενετικής',
              'Ακαδημαϊκό Ινστιτούτο Ερευνών Κύπρου',
              'Αναθεώρηση της Στρατηγικής για την Πληροφορική στη Δημόσια Υπηρεσία μέσα στα πλαίσια της Ηλεκρονικής Διακυβέρνησης',
              'Γενικό Χημείο του Κράτους')
),

nuts1_distributed AS (
  SELECT
    b.transaction_id,
    b.project_title AS project_name,
    b.beneficiary AS beneficiary_name,   
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.eu_cofinancing_amount AS total_amount,
    NULL::int AS eu_cofinancing_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.total_amount AS amount,
    'pending_amount_at_completion' AS amount_kind,
    LOWER(b.beneficiary) AS beneficiary_id,
    b.fund_acronym,
    '2007-2013' AS funding_period,
    TRUE AS distributed,
    'nuts1' AS geolocation_in_source,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    'Cyprus' AS country,
    'CY' AS country_code,
    to_date(b.start_date::varchar, 'yyyy') AS start_date,
    to_date(b.end_date::varchar, 'yyyy') AS end_date
  FROM nuts1 AS b
  CROSS JOIN pre_population AS p
),

lau1 AS (
  SELECT
    *,
    CASE
      WHEN beneficiary = 'Δήμος Πάφου' THEN '6'
      WHEN beneficiary = 'Δήμος Λεμεσού' THEN '5'
      WHEN beneficiary = 'Δήμος Λάρνακας' THEN '4'
      WHEN beneficiary = 'Δήμος Λευκωσίας' THEN '1'
      WHEN beneficiary = 'Δήμος Αγίου Αθανασίου' THEN '5'
      WHEN beneficiary = 'Δήμος Πέγειάς' THEN '6'
      WHEN beneficiary = 'Δήμος Στροβόλου' THEN '1'
      WHEN beneficiary = 'Επαρχιακή Διοίκηση Λευκωσίας' THEN '1'
      WHEN beneficiary = 'Επαρχιακή Διοίκηση Πάφου' THEN '6'
      WHEN beneficiary = 'Επαρχιακή Διοίκηση Λεμεσού' THEN '5'
      WHEN beneficiary = 'Επαρχιακή Διοίκηση Λάρνακας' THEN '4'
    END AS lau1_code
  FROM base
  WHERE beneficiary IN ('Δήμος Λεμεσού',
              'Δήμος Λευκωσίας',
              'Δήμος Πάφου',
              'Δήμος Λάρνακας',
              'Δήμος Αγίου Αθανασίου',
              'Δήμος Πέγειάς',
              'Δήμος Στροβόλου',
              'Επαρχιακή Διοίκηση Λευκωσίας',
              'Επαρχιακή Διοίκηση Πάφου',
              'Επαρχιακή Διοίκηση Λεμεσού',
              'Επαρχιακή Διοίκηση Λάρνακας')
),

lau1_distributed AS (
  SELECT
    b.transaction_id,
    b.project_title AS project_name,
    b.beneficiary AS beneficiary_name,   
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.eu_cofinancing_amount AS total_amount,
    NULL::int AS eu_cofinancing_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.total_amount AS amount,
    'pending_amount_at_completion' AS amount_kind,
    LOWER(b.beneficiary) AS beneficiary_id,
    b.fund_acronym,
    '2007-2013' AS funding_period,
    TRUE AS distributed,
    'lau1' AS geolocation_in_source,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    'Cyprus' AS country,
    'CY' AS country_code,
    to_date(b.start_date::varchar, 'yyyy') AS start_date,
    to_date(b.end_date::varchar, 'yyyy') AS end_date
  FROM lau1 AS b
  INNER JOIN pre_population AS p ON
  CASE
    WHEN beneficiary = 'Δήμος Πάφου' AND p.lau1_code = '6' THEN 1
    WHEN beneficiary = 'Δήμος Λεμεσού' AND p.lau1_code = '5' THEN 1
    WHEN beneficiary = 'Δήμος Λάρνακας' AND p.lau1_code = '4' THEN 1
    WHEN beneficiary = 'Δήμος Λευκωσίας' AND p.lau1_code = '1' THEN 1
    WHEN beneficiary = 'Δήμος Αγίου Αθανασίου' AND p.lau1_code = '5' THEN 1
    WHEN beneficiary = 'Δήμος Πέγειάς' AND p.lau1_code = '6' THEN 1
    WHEN beneficiary = 'Δήμος Στροβόλου' AND p.lau1_code = '1' THEN 1
    WHEN beneficiary = 'Επαρχιακή Διοίκηση Λευκωσίας' AND p.lau1_code = '1' THEN 1
    WHEN beneficiary = 'Επαρχιακή Διοίκηση Πάφου' AND p.lau1_code = '6' THEN 1
    WHEN beneficiary = 'Επαρχιακή Διοίκηση Λεμεσού' AND p.lau1_code = '5' THEN 1
    WHEN beneficiary = 'Επαρχιακή Διοίκηση Λάρνακας' AND p.lau1_code = '4' THEN 1
    ELSE 0
    END = 1
 ),
 
unidentified AS (
  SELECT
    b.transaction_id,
    b.project_title AS project_name,
    b.beneficiary AS beneficiary_name,   
    b.eu_cofinancing_amount AS total_amount,
    NULL::int AS eu_cofinancing_amount,
    b.total_amount AS amount,
    'pending_amount_at_completion' AS amount_kind,
    LOWER(b.beneficiary) AS beneficiary_id,
    b.fund_acronym,
    '2007-2013' AS funding_period,
    NULL::bool AS distributed,
    NULL::text AS geolocation_in_source,
    NULL AS project_state,
    NULL AS project_region,
    NULL AS project_county,
    NULL AS project_nuts3,
    NULL AS project_city,
    NULL AS project_lau2,
    'Cyprus' AS country,
    'CY' AS country_code,
    to_date(b.start_date::varchar, 'yyyy') AS start_date,
    to_date(b.end_date::varchar, 'yyyy') AS end_date
  FROM base AS b
  LEFT JOIN nuts1 AS n ON b.transaction_id = n.transaction_id
  LEFT JOIN lau1 AS l ON b.transaction_id = l.transaction_id
  WHERE n.transaction_id IS NULL
    AND l.transaction_id IS NULL
),

vw AS (
  SELECT * FROM nuts1_distributed
  UNION ALL
  SELECT * FROM lau1_distributed
  UNION ALL
  SELECT * FROM unidentified
)

SELECT * FROM vw;