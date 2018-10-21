WITH vw_erdf AS (
	SELECT *, 'ERDF' AS fund_type, 'ES11' AS nuts2 FROM "1_erdf_es11_galicia"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES12' AS nuts2 FROM "1_erdf_es12_asturias"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES13' AS nuts2 FROM "1_erdf_es13_cantabria"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES21' AS nuts2 FROM "1_erdf_es21_basque"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES22' AS nuts2 FROM "1_erdf_es22_navarre"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES23' AS nuts2 FROM "1_erdf_es23_larioja"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES24' AS nuts2 FROM "1_erdf_es24_aragon"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES30' AS nuts2 FROM "1_erdf_es30_madrid"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES41' AS nuts2 FROM "1_erdf_es41_castile-leon"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES42' AS nuts2 FROM "1_erdf_es42_castile-lamancha"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES43' AS nuts2 FROM "1_erdf_es43_extremadura"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES51' AS nuts2 FROM "1_erdf_es51_catalonia"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES52' AS nuts2 FROM "1_erdf_es52_valencian_community"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES53' AS nuts2 FROM "1_erdf_es53_balearicislands"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES61' AS nuts2 FROM "1_erdf_es61_andalusia"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES62' AS nuts2 FROM "1_erdf_es62_murcia"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES63' AS nuts2 FROM "1_erdf_es63_ceuta"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES64' AS nuts2 FROM "1_erdf_es64_melilla"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'ES70' AS nuts2 FROM "1_erdf_es70_canaryislands"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'multiregional_economy' AS nuts2 FROM "1_erdf_multiregional_economy"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'multiregional_technologicalfund' AS nuts2 FROM "1_erdf_multiregional_technologicalfund"
	UNION ALL
	SELECT *, 'ERDF' AS fund_type, 'multiregional_tecnicalassistance' AS nuts2 FROM "1_erdf_multiregional_tecnicalassistance"
	UNION ALL
	SELECT *, 'CF' AS fund_type, 'multiregional' AS nuts2 FROM "1_cf_multiregional"
),
vw_esf AS (
	SELECT *, 'ESF' AS fund_type, 'ES11' AS nuts2 FROM "1_esf_es11_galicia"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES12' AS nuts2 FROM "1_esf_es12_asturias"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES13' AS nuts2 FROM "1_esf_es13_cantabria"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES21' AS nuts2 FROM "1_esf_es21_basque"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES22' AS nuts2 FROM "1_esf_es22_navarre"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES23' AS nuts2 FROM "1_esf_es23_larioja"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES24' AS nuts2 FROM "1_esf_es24_aragon"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES30' AS nuts2 FROM "1_esf_es30_madrid"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES41' AS nuts2 FROM "1_esf_es41_castile-leon"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES42' AS nuts2 FROM "1_esf_es42_castile-lamancha"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES43' AS nuts2 FROM "1_esf_es43_extremadura"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES51' AS nuts2 FROM "1_esf_es51_catalonia"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES52' AS nuts2 FROM "1_esf_es52_valencian_community"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES53' AS nuts2 FROM "1_esf_es53_balearicislands"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES61' AS nuts2 FROM "1_esf_es61_andalusia"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES62' AS nuts2 FROM "1_esf_es62_murcia"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES63' AS nuts2 FROM "1_esf_es63_ceuta"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES64' AS nuts2 FROM "1_esf_es64_melilla"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'ES70' AS nuts2 FROM "1_esf_es70_canaryislands"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'multiregional_employment' AS nuts2 FROM "1_esf_multiregional_employment_1"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'multiregional_employment' AS nuts2 FROM "1_esf_multiregional_employment_2"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'multiregional_employment' AS nuts2 FROM "1_esf_multiregional_employment_3"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'multiregional_employment' AS nuts2 FROM "1_esf_multiregional_employment_4"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'multiregional_employment' AS nuts2 FROM "1_esf_multiregional_employment_5"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'multiregional_fightagainstdiscrimination' AS nuts2 FROM "1_esf_multiregional_fightagainstdiscrimination"
	UNION ALL
	SELECT *, 'ESF' AS fund_type, 'multiregional_tecnicalassistance' AS nuts2 FROM "1_esf_multiregional_tecnicalassistance"
),
vw_union AS (
	SELECT 
		beneficiary AS beneficiary_name,
		"operation" AS project_name,
		NULL::INT AS contract_year,
		NULL::INT8 AS approved_amount,
		NULLIF(round(NULLIF(REPLACE(REPLACE(spending, '.', ''), ',', '.'), '')::FLOAT), 0)::INT8 AS final_amount,
		fund_type,
		nuts2
	FROM vw_esf
	UNION ALL
	SELECT 
		nombre_beneficiario AS beneficiary_name,
		nombre_operacion AS project_name,
		NULLIF(ano_de_la_concesion, '')::INT AS contract_year,
		NULLIF(round(NULLIF(REPLACE(REPLACE(montante_concedido, '.', ''), ',', '.'), '')::FLOAT), 0)::INT8 AS approved_amount,
		NULLIF(round(NULLIF(REPLACE(REPLACE(montante_pagado_final_operacion, '.', ''), ',', '.'), '')::FLOAT), 0)::INT8 AS final_amount,
		fund_type,
		nuts2
	FROM vw_erdf
)
SELECT
	beneficiary_name,
	project_name,
	fund_type,
	nuts2,
	SUM(CASE WHEN final_amount IS NULL OR final_amount = 0 THEN approved_amount ELSE final_amount END) AS amount
INTO vw_es_union 
FROM vw_union
GROUP BY 	beneficiary_name,
	project_name,
	fund_type,
	nuts2;


INSERT INTO public.final (transaction_id,project_name,beneficiary_name,total_ammount,eu_cofinancing_amount,amount,amount_kind,beneficiary_country_code,beneficiary_id,fund_acronym,funding_period,geocoding_state,beneficiary_postal_code,beneficiary_lau2,project_state,project_region,project_county,project_city,project_nuts3,project_lau2,project_postal_code,project_address,project_nuts2)
WITH
es_union AS (
	SELECT 
		md5('ES' || (row_number() OVER ())::VARCHAR) AS transaction_id,
		*
	FROM vw_es_union
),
vw AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
	  NULL::numeric AS total_ammount,
		amount AS eu_cofinancing_amount,
		amount AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'ES' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fund_type AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS geocoding_state,
		NULL AS beneficiary_postal_code,
		NULL AS beneficiary_lau2,
		NULL AS project_state,
		NULL AS project_region,
		NULL AS project_county,
		NULL AS project_city,
		NULL AS project_nuts3,
		NULL AS project_lau2,
		NULL AS project_postal_code,
		NULL AS project_address,
		CASE WHEN nuts2 NOT LIKE 'multiregional%' THEN nuts2 ELSE NULL END AS project_nuts2
	FROM es_union
)
SELECT * FROM vw;