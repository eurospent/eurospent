WITH 
"erdf_be1_brussel" AS (
	SELECT 
		"Bénéficiaire / Begunstigde" AS beneficiary_name,
		"Opération / Actie" AS project_name,
		NULL::date AS contract_date,
		(SUBSTRING("Année d'allocation / Jaar van toewijzing", 0, 5) || '-01-01')::date AS start_date,
		NULL::date AS end_date,
		"Financement total du projet / Totale projectfinanciering (€)"::float AS total_amount,
		"Financement FEDER (UE) / EFRO-financiering (EU) (€)"::float AS eu_amount,
		NULL::float AS eu_amount_b,
		'BE1' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be1_brussel"
),

"erdf_be2_vlaams_gewest" AS (
	SELECT
		"PROMOTOR_manueel" AS beneficiary_name,
		"PROJECTNAAM_manueel" AS project_name,
		NULL::date AS contract_date,
		"STARTDATUM_PROJECT"::date AS start_date,
		"EINDDATUM_PROJECT"::date AS end_date,
		"SUBSIDIABELE_KOST"::float AS total_amount,
		"EFRO_STEUN"::float AS eu_amount,
		NULL::float AS eu_amount_b,
		'BE2' AS nuts1,
		'ERDF' AS fund,
		"PLAATSUITVOERING" AS loc,
		"POSTCODE" AS postalcode,
		"GEMEENTE" AS city,
		"STRAAT" || ' ' || "HUISNUMMER" AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be2_vlaams_gewest"	
),

"erdf_be3_wallonne_competitiveness_1" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"project" AS project_name,
		to_date("Date de décision", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		REPLACE(REPLACE("Montant de l'investissement total", '.', ''), ',', '.')::float AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_competitiveness_1"
),
"erdf_be3_wallonne_competitiveness_2" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"project" AS project_name,
		to_date("Date initiale de décision du GW", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		NULL::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
		REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_competitiveness_2"
),
"erdf_be3_wallonne_competitiveness_3" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"Projets" AS project_name,
		to_date("Date de la dernière décision du GW", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_competitiveness_3"
),
"erdf_be3_wallonne_competitiveness_4" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"project" AS project_name,
		to_date("Date de décision", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		REPLACE(REPLACE("Montant de l'investissement total", '.', ''), ',', '.')::float AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("FEDER payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("FEDER décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("FEDER payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_competitiveness_4"
),
"erdf_be3_wallonne_competitiveness_5" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"project" AS project_name,
		NULL::date AS contract_date,
		to_date("Date de la demande", 'DD/MM/YYYY')::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		"Montant total des chèques technologiques"::float + "Feder payées"::float + "Part wallonne payées"::float + "Montants cofinancés payées"::float AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_competitiveness_5"
),
"erdf_be3_wallonne_competitiveness_6" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"Projets" AS project_name,
		to_date("Date de la dernière décision du GW", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_competitiveness_6"
),
"erdf_be3_wallonne_competitiveness_7" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"project" AS project_name,
		to_date("Date de décision", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_competitiveness_7"
),
"erdf_be3_wallonne_competitiveness_8" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"project" AS project_name,
		to_date("Date de début de convention", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_competitiveness_8"
),
"erdf_be3_wallonne_competitiveness_9" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"Projets" AS project_name,
		to_date("Date de la dernière décision du GW", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_competitiveness_9"
),
"erdf_be3_wallonne_competitiveness_10" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"Projets" AS project_name,
		to_date("Date de la dernière décision du GW", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_competitiveness_10"
),
"erdf_be3_wallonne_competitiveness_11" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"Projets" AS project_name,
		to_date("Date de la dernière décision du GW", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_competitiveness_11"
),
"erdf_be3_wallonne_competitiveness_12" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"Projets" AS project_name,
		to_date("Date de la dernière décision du GW", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_competitiveness_12"
),

"erdf_be3_wallonne_convergence_1" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"project" AS project_name,
		to_date("Date de décision", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		REPLACE(REPLACE("Montant de l'investissement total", '.', ''), ',', '.')::float AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_convergence_1"
),
"erdf_be3_wallonne_convergence_2" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"project" AS project_name,
		to_date("Date initiale de décision du GW", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		NULL::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
		REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_convergence_2"
),
"erdf_be3_wallonne_convergence_3" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"Projets" AS project_name,
		to_date("Date de la dernière décision du GW", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_convergence_3"
),
"erdf_be3_wallonne_convergence_4" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"project" AS project_name,
		to_date("Date de décision", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		REPLACE(REPLACE("Montant de l'investissement total", '.', ''), ',', '.')::float AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_convergence_4"
),
"erdf_be3_wallonne_convergence_5" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"project" AS project_name,
		NULL::date AS contract_date,
		to_date("Date de la demande", 'DD/MM/YYYY')::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		"Montant total des chèques technologiques"::float + "Feder payées"::float + "Part wallonne payées"::float + "Montants cofinancés payées"::float AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_convergence_5"
),
"erdf_be3_wallonne_convergence_6" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"Projets" AS project_name,
		to_date("Date de la dernière décision du GW", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_convergence_6"
),
"erdf_be3_wallonne_convergence_7" AS (
	SELECT 
		"Bénéficiaire" AS beneficiary_name,
		"project" AS project_name,
		to_date("Date de décision", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_convergence_7"
),
"erdf_be3_wallonne_convergence_8" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"project" AS project_name,
		to_date("Date de début de convention", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_convergence_8"
),
"erdf_be3_wallonne_convergence_9" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"Projets" AS project_name,
		to_date("Date de la dernière décision du GW", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_convergence_9"
),
"erdf_be3_wallonne_convergence_10" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"Projets" AS project_name,
		to_date("Date de la dernière décision du GW", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_convergence_10"
),
"erdf_be3_wallonne_convergence_11" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"Projets" AS project_name,
		to_date("Date de la dernière décision du GW", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_convergence_11"
),
"erdf_be3_wallonne_convergence_12" AS (
	SELECT 
		"Bénéficiaires" AS beneficiary_name,
		"Projets" AS project_name,
		to_date("Date de la dernière décision du GW", 'DD/MM/YYYY')::date AS contract_date,
		NULL::date AS start_date,
		to_date("Date de clôture", 'DD/MM/YYYY')::date AS end_date,
		COALESCE(NULLIF(REPLACE(REPLACE("Coût total payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Coût total décidées", '.', ''), ',', '.')::float) AS total_amount,
		COALESCE(NULLIF(REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float, 0), REPLACE(REPLACE("Feder décidées", '.', ''), ',', '.')::float) AS eu_amount,
	  REPLACE(REPLACE("Feder payées", '.', ''), ',', '.')::float AS eu_amount_b,
		'BE3' AS nuts1,
		'ERDF' AS fund,
		NULL AS loc,
		NULL AS postalcode,
		NULL AS city,
		NULL AS address,
		NULL AS lat,
		NULL AS long
	FROM "1_erdf_be3_wallonne_convergence_12"
),
"esf_transactions" AS (
	SELECT 
		"beneficiary_org" AS beneficiary_name,
		"project_name" AS project_name,
		NULL::date AS contract_date,
		replace(replace(replace(replace(replace(replace(replace(replace(
			replace(trim(right(project_start, length(project_start) - strpos(project_start, ','))), ',', '') 
			, 'januari', 'january')
			, 'februari', 'february')
			, 'maart', 'march')
			, 'mei', 'may')
			, 'juni', 'jun')
			, 'juli', 'july')
			, 'augustus', 'august')
			, 'oktober', 'october')::date
		AS start_date,
		NULL::date AS end_date,
		COALESCE(
			NULLIF(REPLACE(REPLACE(total_requested, '€', ''), ' ', '')::float, 0), 
			REPLACE(REPLACE(total_requested, '€', ''), ' ', '')::float
		) AS total_amount,
		COALESCE(
			NULLIF(REPLACE(REPLACE(esf_requested, '€', ''), ' ', '')::float, 0), 
			REPLACE(REPLACE(esf_paid, '€', ''), ' ', '')::float
		) AS eu_amount,
		REPLACE(REPLACE(esf_paid, '€', ''), ' ', '')::float AS eu_amount_b,
		NULL AS nuts1,
		'ESF' AS fund,
		beneficiary_city AS loc,
		beneficiary_postalcode AS postalcode,
		beneficiary_city AS city,
		beneficiary_street AS address,
		beneficiary_lat AS lat,
		beneficiary_long AS long
	FROM "1_esf_transactions"	
),
vw AS (
	SELECT * FROM erdf_be1_brussel UNION ALL
	SELECT * FROM erdf_be2_vlaams_gewest UNION ALL
	SELECT * FROM erdf_be3_wallonne_competitiveness_1 UNION ALL
	SELECT * FROM erdf_be3_wallonne_competitiveness_2 UNION ALL
	SELECT * FROM erdf_be3_wallonne_competitiveness_3 UNION ALL
	SELECT * FROM erdf_be3_wallonne_competitiveness_4 UNION ALL
	SELECT * FROM erdf_be3_wallonne_competitiveness_5 UNION ALL
	SELECT * FROM erdf_be3_wallonne_competitiveness_6 UNION ALL
	SELECT * FROM erdf_be3_wallonne_competitiveness_7 UNION ALL
	SELECT * FROM erdf_be3_wallonne_competitiveness_8 UNION ALL
	SELECT * FROM erdf_be3_wallonne_competitiveness_9 UNION ALL
	SELECT * FROM erdf_be3_wallonne_competitiveness_10 UNION ALL
	SELECT * FROM erdf_be3_wallonne_competitiveness_11 UNION ALL
	SELECT * FROM erdf_be3_wallonne_competitiveness_12 UNION ALL
	SELECT * FROM erdf_be3_wallonne_convergence_1 UNION ALL
	SELECT * FROM erdf_be3_wallonne_convergence_2 UNION ALL
	SELECT * FROM erdf_be3_wallonne_convergence_3 UNION ALL
	SELECT * FROM erdf_be3_wallonne_convergence_4 UNION ALL
	SELECT * FROM erdf_be3_wallonne_convergence_5 UNION ALL
	SELECT * FROM erdf_be3_wallonne_convergence_6 UNION ALL
	SELECT * FROM erdf_be3_wallonne_convergence_7 UNION ALL
	SELECT * FROM erdf_be3_wallonne_convergence_8 UNION ALL
	SELECT * FROM erdf_be3_wallonne_convergence_9 UNION ALL
	SELECT * FROM erdf_be3_wallonne_convergence_10 UNION ALL
	SELECT * FROM erdf_be3_wallonne_convergence_11 UNION ALL
	SELECT * FROM erdf_be3_wallonne_convergence_12 UNION ALL
	SELECT * FROM esf_transactions
)

SELECT * 
INTO be_union
FROM vw;


WITH 
loc AS (
	SELECT * 
	FROM "1_population"
	WHERE shape_lau LIKE 'BE%'
),
base AS (
	SELECT
		md5('BE' || "row_number"() OVER ()) AS transaction_id,
		* 
	FROM be_union
),
erdf_be1 AS (
	SELECT 
		b.*,
		COALESCE(l.name, l2.name) AS loc_name,
		COALESCE(l.shape_lau, l2.shape_lau) AS shape_lau,
		COALESCE(l.population, l2.population) AS population,
		CASE WHEN l.shape_lau IS NOT NULL THEN 'lau2' ELSE 'nuts3' END AS geolocation_in_source,
		CASE WHEN l.shape_lau IS NOT NULL THEN FALSE ELSE TRUE END AS distributed
	FROM base AS b
	LEFT JOIN loc AS l ON l.shape_lau LIKE 'BE1%' AND 
		(
			(b.beneficiary_name = E'Commune d\'Anderlecht' AND l.name = 'Anderlecht') OR
			(b.beneficiary_name = 'Commune de Forest' AND l.name = 'Vorst') OR
			(b.beneficiary_name = 'Commune de Molenbeek-Saint-Jean' AND l.name = 'Sint-Jans-Molenbeek') OR
			(b.beneficiary_name = 'Commune de Saint-Gilles' AND l.name = 'Sint-Gillis') OR
			(b.beneficiary_name = 'Commune de Saint-Josse' AND l.name = 'Sint-Joost-ten-Node') OR
			(b.beneficiary_name = 'Commune de Schaerbeek' AND l.name = 'Schaarbeek') OR
			(b.beneficiary_name = 'Ville de Bruxelles' AND l.name = 'Brussel') OR
			(b.beneficiary_name = E'Centre public d\'aide sociale de Bruxelles-Ville' AND l.name = 'Brussel') OR
			(b.beneficiary_name = 'Atrium' AND l.name = 'Sint-Gillis') OR
			(b.beneficiary_name = E'Centre d\'entreprise Dansaert' AND l.name = 'Sint-Gillis') OR
			(b.beneficiary_name = 'Institut Notre-Dame' AND l.name = 'Anderlecht') OR
			(b.beneficiary_name = 'Société de Développement pour la Région de Bruxelles-Capitale' AND l.name = 'Anderlecht') OR
			(b.beneficiary_name = 'Collège La Fraternité' AND l.name = 'Brussel') OR
			(b.beneficiary_name = 'Centre scientifique et technique de la construction' AND l.name = 'Brussel') OR
			(b.beneficiary_name = 'Athénée Royal Serge Creuz' AND l.name = 'Sint-Jans-Molenbeek')  OR
			(b.beneficiary_name = 'Institut Communal Technique Frans Fischer' AND l.name = 'Schaarbeek') OR
			(b.beneficiary_name = 'Abattoirs' AND l.name = 'Anderlecht')   OR
			(b.beneficiary_name = 'Erasmushogeschool' AND l.name = 'Anderlecht')   OR
			(b.beneficiary_name = 'Elmer vzw' AND l.name = 'Schaarbeek')
		)
	LEFT JOIN loc AS l2 ON l.name IS NUlL AND l2.shape_lau LIKE 'BE1%'
	WHERE fund = 'ERDF'
	AND nuts1 = 'BE1'
),
erdf_be2 AS (
	SELECT
		b.*,		
		l.name AS loc_name,
		l.shape_lau AS shape_lau,
		l.population AS population,
		CASE 
			WHEN b.loc = 'Provincie  Antwerpen' THEN 'nuts2'
			WHEN b.loc = 'Provincie Antwerpen' THEN 'nuts2'
			WHEN b.loc = 'Provincie LImburg' THEN 'nuts2'
			WHEN b.loc = 'Provincie Limburg' THEN 'nuts2'
			WHEN b.loc = 'Provincie Oost-Vlaanderen' THEN 'nuts2'
			WHEN b.loc = 'Provincie Vlaams Brabant' THEN 'nuts2'
			WHEN b.loc = 'Provincie Vlaams-Brabant' THEN 'nuts2'
			WHEN b.loc = 'Provincie West-Vlaanderen' THEN 'nuts2'
			WHEN b.loc = 'Stad Antwerpen' THEN 'lau2'
			WHEN b.loc = 'Stad Gent' THEN 'lau2'
			WHEN b.loc = 'Vlaams Gewest' THEN 'nuts1'
			WHEN b.project_name = 'Associëren om te innoveren in Nederland en Duitsland' THEN 'nuts1'
			WHEN b.beneficiary_name = 'Xios Hogeschool Limburg' AND project_name = 'Eur-NORM' THEN 'nuts1'
			WHEN b.beneficiary_name = 'Provincie West-Vlaanderen' THEN 'nuts2'
			WHEN b.beneficiary_name = 'Provincie Limburg' THEN 'nuts2'
			WHEN b.beneficiary_name = 'Kempens Landschap' THEN 'nuts2'
			WHEN b.beneficiary_name = 'Groep T' THEN 'lau2'
			WHEN b.loc = 'BE223 Arr. Tongeren' THEN 'nuts3'
			WHEN b.beneficiary_name = 'Universiteit Hasselt – Instituut CMK' THEN 'lau2'
			WHEN b.beneficiary_name = 'Greenbridge incubatie-en innovatiecentrum Gent-Oostende' THEN 'lau2'
			WHEN b.beneficiary_name = 'Unizo - Internationaal' THEN 'nuts1'
			WHEN b.beneficiary_name = 'UNIZO' THEN 'nuts1'
		END AS geolocation_in_source,
		CASE 
			WHEN b.loc = 'Stad Antwerpen' THEN FALSE
			WHEN b.loc = 'Stad Gent' THEN FALSE
			WHEN b.beneficiary_name = 'Groep T' THEN FALSE
			WHEN b.beneficiary_name = 'Universiteit Hasselt – Instituut CMK' AND b.loc != 'Provincie Limburg' AND b.loc != 'Provincie LImburg' THEN FALSE
			WHEN b.beneficiary_name = 'Greenbridge incubatie-en innovatiecentrum Gent-Oostende' THEN FALSE
			ELSE TRUE
		END AS distributed
	FROM base AS b
	LEFT JOIN loc AS l ON l.shape_lau LIKE 'BE2%' AND 
	(
		(b.loc = 'Provincie  Antwerpen' AND l.shape_lau LIKE 'BE21%') OR
		(b.loc = 'Provincie Antwerpen' AND l.shape_lau LIKE 'BE21%') OR
		(b.loc = 'Provincie LImburg' AND l.shape_lau LIKE 'BE22%') OR
		(b.loc = 'Provincie Limburg' AND l.shape_lau LIKE 'BE22%') OR
		(b.loc = 'Provincie Oost-Vlaanderen' AND l.shape_lau LIKE 'BE23%') OR
		(b.loc = 'Provincie Vlaams Brabant' AND l.shape_lau LIKE 'BE24%') OR
		(b.loc = 'Provincie Vlaams-Brabant' AND l.shape_lau LIKE 'BE24%') OR
		(b.loc = 'Provincie West-Vlaanderen' AND l.shape_lau LIKE 'BE25%') OR
		(b.loc = 'Stad Antwerpen' AND l.shape_lau = 'BE211_11002') OR
		(b.loc = 'Stad Gent' AND l.shape_lau = 'BE234_44021') OR
		(b.loc = 'Vlaams Gewest' AND l.shape_lau LIKE 'BE2%') OR
		(b.project_name = 'Associëren om te innoveren in Nederland en Duitsland' AND l.shape_lau LIKE 'BE2%') OR
		(b.beneficiary_name = 'Xios Hogeschool Limburg' AND project_name = 'Eur-NORM' AND l.shape_lau LIKE 'BE2%') OR
		(b.beneficiary_name = 'Provincie West-Vlaanderen' AND l.shape_lau LIKE 'BE25%') OR
		(b.beneficiary_name = 'Provincie Limburg' AND l.shape_lau LIKE 'BE22%') OR
		(b.beneficiary_name = 'Kempens Landschap' AND l.shape_lau LIKE 'BE21%') OR
		(b.beneficiary_name = 'Groep T' AND l.shape_lau = 'BE242_24062') OR
		(b.loc = 'BE223 Arr. Tongeren' AND l.shape_lau LIKE 'BE223%') OR
		(b.beneficiary_name = 'Universiteit Hasselt – Instituut CMK' AND l.shape_lau = 'BE221_71011') OR
		(b.beneficiary_name = 'Greenbridge incubatie-en innovatiecentrum Gent-Oostende' AND l.shape_lau = 'BE255_35013') OR
		(b.beneficiary_name = 'Unizo - Internationaal' AND l.shape_lau LIKE 'BE2%') OR
		(b.beneficiary_name = 'UNIZO' AND l.shape_lau LIKE 'BE2%')
	)
	WHERE fund = 'ERDF'
	AND nuts1 = 'BE2'
),
erdf_be3 AS (
	SELECT
		b.*,		
		l.name AS loc_name,
		l.shape_lau AS shape_lau,
		l.population AS population,
		CASE WHEN l.shape_lau IS NOT NULL THEN 'lau2' END AS geolocation_in_source,
		CASE WHEN l.shape_lau IS NOT NULL THEN FALSE END AS distributed
	FROM base AS b
	LEFT JOIN loc AS l ON l.shape_lau LIKE 'BE3%' AND 
	(
		(b.beneficiary_name = E'Administration communale d\'AMAY' AND l.shape_lau = 'BE331_61003') OR
		(b.beneficiary_name = E'Administration communale d\'ANTHISNE' AND l.shape_lau = 'BE331_61079') OR
		(b.beneficiary_name = E'Administration communale d\'ENGIS' AND l.shape_lau = 'BE331_61080') OR
		(b.beneficiary_name = E'Administration communale d\'OREYE' AND l.shape_lau = 'BE334_64056') OR
		(b.beneficiary_name = E'Administration communale d\'OUFFET' AND l.shape_lau = 'BE331_61048') OR
		(b.beneficiary_name = 'Administration communale de BERLOZ' AND l.shape_lau = 'BE334_64008') OR
		(b.beneficiary_name = 'Administration communale de BRAIVES' AND l.shape_lau = 'BE334_64015') OR
		(b.beneficiary_name = 'Administration communale de BURDINNE' AND l.shape_lau = 'BE331_61010') OR
		(b.beneficiary_name = 'Administration communale de CLAVIER' AND l.shape_lau = 'BE331_61012') OR
		(b.beneficiary_name = 'Administration communale de CRISNEE' AND l.shape_lau = 'BE334_64021') OR
		(b.beneficiary_name = 'Administration communale de DONCEEL' AND l.shape_lau = 'BE334_64023') OR
		(b.beneficiary_name = 'Administration communale de FAIMES' AND l.shape_lau = 'BE334_64076') OR
		(b.beneficiary_name = 'Administration communale de FERRIERES' AND l.shape_lau = 'BE331_61019') OR
		(b.beneficiary_name = 'Administration communale de FEXHE-LE-HAUT- CLOCHER' AND l.shape_lau = 'BE334_64025') OR
		(b.beneficiary_name = 'Administration communale de GEER' AND l.shape_lau = 'BE334_64029') OR
		(b.beneficiary_name = 'Administration communale de HAMOIR' AND l.shape_lau = 'BE331_61024') OR
		(b.beneficiary_name = 'Administration communale de HERON' AND l.shape_lau = 'BE331_61028') OR
		(b.beneficiary_name = 'Administration communale de LINCENT' AND l.shape_lau = 'BE334_64047') OR
		(b.beneficiary_name = 'Administration communale de MARCHIN' AND l.shape_lau = 'BE331_61039') OR
		(b.beneficiary_name = 'Administration communale de MODAVE' AND l.shape_lau = 'BE331_61041') OR
		(b.beneficiary_name = 'Administration communale de NANDRIN' AND l.shape_lau = 'BE331_61043') OR
		(b.beneficiary_name = 'Administration communale de REMICOURT' AND l.shape_lau = 'BE334_64063') OR
		(b.beneficiary_name = 'Administration communale de SAINT-GEORGES-SUR- MEUSE' AND l.shape_lau = 'BE334_64065') OR
		(b.beneficiary_name = 'Administration communale de Seneffe' AND l.shape_lau = 'BE322_52063') OR
		(b.beneficiary_name = 'Administration communale de TINLOT' AND l.shape_lau = 'BE331_61081') OR
		(b.beneficiary_name = 'Administration communale de VERLAINE' AND l.shape_lau = 'BE331_61063') OR
		(b.beneficiary_name = 'Administration communale de VILLERS-LE-BOUILLET' AND l.shape_lau = 'BE331_61068') OR
		(b.beneficiary_name = 'Administration communale de WANZE' AND l.shape_lau = 'BE331_61072') OR
		(b.beneficiary_name = 'Administration communale de WAREMME' AND l.shape_lau = 'BE334_64074') OR
		(b.beneficiary_name = 'Administration communale de WASSEIGES' AND l.shape_lau = 'BE334_64075') OR
		(b.beneficiary_name = E'Commune d\'Aiseau-Presles' AND l.shape_lau = 'BE322_52074') OR
		(b.beneficiary_name = E'Commune d\'Ans' AND l.shape_lau = 'BE332_62003') OR
		(b.beneficiary_name = E'Commune d\'ENGIS' AND l.shape_lau = 'BE331_61080') OR
		(b.beneficiary_name = 'Commune de Ans' AND l.shape_lau = 'BE332_62003') OR
		(b.beneficiary_name = 'Commune de Bouillon' AND l.shape_lau = 'BE344_84010') OR
		(b.beneficiary_name = 'Commune de Ciney' AND l.shape_lau = 'BE351_91030') OR
		(b.beneficiary_name = 'Commune de DISON' AND l.shape_lau = 'BE335_63020') OR
		(b.beneficiary_name = 'Commune de Farciennes' AND l.shape_lau = 'BE322_52018') OR
		(b.beneficiary_name = 'Commune de Frameries' AND l.shape_lau = 'BE323_53028') OR
		(b.beneficiary_name = 'Commune de Herstal' AND l.shape_lau = 'BE332_62051') OR
		(b.beneficiary_name = 'Commune de Lobbes' AND l.shape_lau = 'BE326_56044') OR
		(b.beneficiary_name = 'Commune de Merbes-le- Château' AND l.shape_lau = 'BE326_56049') OR
		(b.beneficiary_name = 'Commune de Morlanwez' AND l.shape_lau = 'BE326_56087') OR
		(b.beneficiary_name = 'Commune de Peruwelz' AND l.shape_lau = 'BE327_57064') OR
		(b.beneficiary_name = 'Commune de Philippeville' AND l.shape_lau = 'BE353_93056') OR
		(b.beneficiary_name = 'Commune de Sambreville' AND l.shape_lau = 'BE352_92137') OR
		(b.beneficiary_name = 'Ville de Binche' AND l.shape_lau = 'BE326_56011') OR
		(b.beneficiary_name = 'Ville de Charleroi' AND l.shape_lau = 'BE322_52011') OR
		(b.beneficiary_name = 'Ville de Chimay' AND l.shape_lau = 'BE326_56016') OR
		(b.beneficiary_name = 'Ville de HANNUT' AND l.shape_lau = 'BE334_64034') OR
		(b.beneficiary_name = 'Ville de HUY' AND l.shape_lau = 'BE331_61031') OR
		(b.beneficiary_name = 'Ville de La Louvière' AND l.shape_lau = 'BE325_55022') OR
		(b.beneficiary_name = 'Ville de Lessines' AND l.shape_lau = 'BE325_55023') OR
		(b.beneficiary_name = 'Ville de Liège' AND l.shape_lau = 'BE332_62063') OR
		(b.beneficiary_name = 'Ville de Mons' AND l.shape_lau = 'BE323_53053') OR
		(b.beneficiary_name = 'Ville de Mouscron' AND l.shape_lau = 'BE324_54007') OR
		(b.beneficiary_name = 'Ville de Seraing' AND l.shape_lau = 'BE332_62096') OR
		(b.beneficiary_name = 'Ville de Soignies' AND l.shape_lau = 'BE325_55040') OR
		(b.beneficiary_name = 'Ville de Thuin' AND l.shape_lau = 'BE326_56078') OR
		(b.beneficiary_name = 'Ville de Tournai' AND l.shape_lau = 'BE327_57081') OR
		(b.beneficiary_name = 'Ville de Verviers' AND l.shape_lau = 'BE335_63079')
	)
  WHERE fund = 'ERDF'
	AND nuts1 = 'BE3'
),
esf AS (
	SELECT
		b.*,		
		NULL AS loc_name,
		NULL AS shape_lau,
		NULL AS population,
		NULL AS geolocation_in_source,
		NULL::BOOLEAN AS distributed
	FROM base AS b
	WHERE fund = 'ESF'
),
vw_all AS (
	SELECT * FROM erdf_be1 UNION 
	SELECT * FROM erdf_be2 UNION 
	SELECT * FROM erdf_be3 UNION
	SELECT * FROM esf  
),
distribution AS (
	SELECT 
		*, 
		CASE 
			WHEN sum(population::INT) OVER (PARTITION BY transaction_id) IS NULL OR sum(population::INT) OVER (PARTITION BY transaction_id) = 0 THEN 1
			ELSE population::INT*1.0 / sum(population::INT) OVER (PARTITION BY transaction_id)
		 END AS population_multiplier
	FROM vw_all
)

SELECT 
	transaction_id,
	beneficiary_name,
	project_name,
	contract_date,
	start_date,
	end_date,
	population_multiplier * total_amount AS total_amount,
	population_multiplier * eu_amount AS eu_amount,
	nuts1,
	fund,
	loc,
	postalcode,
	city,
	address,
	lat,
	long,
	loc_name,
	shape_lau,
	population,
	geolocation_in_source,
	distributed
INTO be_union2
FROM distribution;