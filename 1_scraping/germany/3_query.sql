WITH 
vw_1_de1_baden_wuerttemberg_erdf AS (
	SELECT
		beneficiary_name,
		project_name,
		NULL::INT AS contract_date,
		year_of_payment::INT AS end_date,
		NULLIF(REPLACE(approved_amount, ',', '.')::FLOAT, 0) AS approved_amount,
		NULLIF(REPLACE(final_amount, ',', '.')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DE1' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_de1_baden_wuerttemberg_erdf"
),
vw_1_de1_baden_wuerttemberg_esf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULL::INT AS contract_date,
		year_of_payment::INT AS end_date,
		NULLIF(REPLACE(approved_amount, ',', '.')::FLOAT, 0) AS approved_amount,
		NULLIF(REPLACE(final_amount, ',', '.')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DE1' AS nuts2,
		'ESF' AS fund_type
	FROM "1_de1_baden_wuerttemberg_esf"
),
vw_1_de2_bayern_erdf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULL::INT AS contract_date,
		year_of_payment::INT AS end_date,
		NULLIF(NULLIF(approved_amount, '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(final_amount, '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DE2' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_de2_bayern_erdf"
),
vw_1_de2_bayern_esf AS (
	SELECT 
		REPLACE(beneficiary_name, '"', '') AS beneficiary_name,
		project_name,
		NULL::INT AS contract_date,
		year_of_payment::INT AS end_date,
		NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.')::FLOAT, 0) AS approved_amount,
		NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DE2' AS nuts2,
		'ESF' AS fund_type
	FROM "1_de2_bayern_esf"
),
vw_1_de3_berlin_erdf AS (
	SELECT 
		beneficiary_name,
		COALESCE(NULLIF(project_name, ''), beneficiary_name) AS project_name,
		NULLIF(year_of_approval, '')::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(approved_amount, ' €', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(final_amount, ' €', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		'Berlin, Stadt' AS loc,
		'DE3' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_de3_berlin_erdf"
),
vw_1_de3_berlin_esf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULL::INT AS contract_date,
		RIGHT(year_of_payment, 4)::INT AS end_date,
		NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.')::FLOAT, 0) AS approved_amount,
		NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		'Berlin, Stadt' AS loc,
		'DE3' AS nuts2,
		'ESF' AS fund_type
	FROM "1_de3_berlin_esf"
),
vw_1_de4_brandenburg_erdf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULLIF(year_of_approval, '')::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT as end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(approved_amount, ' €', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(final_amount, ' €', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DE4' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_de4_brandenburg_erdf"
),
vw_1_de4_brandenburg_esf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULL::INT AS contract_date,
		year_of_payment::INT AS end_date,
		NULLIF(REPLACE(approved_amount, ',', '.')::FLOAT, 0) AS approved_amount,
		NULLIF(REPLACE(final_amount, ',', '.')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DE4' AS nuts2,
		'ESF' AS fund_type
	FROM "1_de4_brandenburg_esf"
),
vw_1_de5_bremen_erdf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULLIF(year_of_approval, '')::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(approved_amount, ' €', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(final_amount, ' €', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		'Bremen, Bremerhaven' AS loc,
		'DE5' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_de5_bremen_erdf"
),
vw_1_de5_bremen_esf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULLIF(year_of_approval, '')::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(approved_amount, ' €', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(final_amount, ' €', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		'Bremen, Bremerhaven' AS loc,
		'DE5' AS nuts2,
		'ESF' AS fund_type
	FROM "1_de5_bremen_esf"
),
vw_1_de6_hamburg_erdf AS (
	SELECT 
		beneficiary_name,
		project_name,
		year_of_approval::INT AS contract_date,
		NULL::INT AS end_date,
		NULLIF(REPLACE(approved_amount, '.', '')::FLOAT, 0) AS approved_amount,
		NULLIF(REPLACE(final_amount, '.', '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		'Hamburg' AS loc,
		'DE6' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_de6_hamburg_erdf"
),
vw_1_de6_hamburg_esf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULL::INT AS contract_date,
		('20' || RIGHT(end_date, 2))::INT as end_date,
		NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.')::FLOAT, 0) AS approved_amount,
		NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.')::FLOAT, 0) AS final_amount,
		NULLIF(REPLACE(REPLACE(full_amount, '.', ''), ',', '.')::FLOAT, 0) AS full_amount,
		'Hamburg' AS loc,
		'DE6' AS nuts2,
		'ESF' AS fund_type
	FROM "1_de6_hamburg_esf"
),
vw_1_de7_hessen_erdf AS (
	SELECT 
		beneficiary_name,
		project_name,
		year_of_approval::INT AS contract_date,
		NULL::INT AS end_date,
		NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.')::FLOAT, 0) AS approved_amount,
		NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		CASE 
			WHEN beneficiary_name ilike '%,%' THEN trim((regexp_split_to_array(beneficiary_name, ','))[array_upper(regexp_split_to_array(beneficiary_name, ','), 1)]) 
			ELSE NULL 
		END AS loc,
		'DE7' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_de7_hessen_erdf"
),
vw_1_de7_hessen_esf AS (
	SELECT
		beneficiary_name,
		project_name,
		NULL::INT AS contract_date,
		RIGHT(end_date, 4)::INT as end_date,
		NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.')::FLOAT, 0) AS approved_amount,
		NULL::FLOAT AS final_amount,
		NULL::FLOAT AS full_amount,
		city AS loc,
		'DE7' AS nuts2,
		'ESF' AS fund_type
	FROM "1_de7_hessen_esf"
),
vw_1_de8_mecklenburg_vorpommern_erdf AS (
	SELECT 
		beneficiary_name,
		COALESCE(project_name, beneficiary_name) AS project_name,
		NULL::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT as end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(approved_amount, ' €', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(final_amount, ' €', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DE8' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_de8_mecklenburg_vorpommern_erdf"
),
vw_1_de8_mecklenburg_vorpommern_esf AS (
	SELECT 
		REPLACE(beneficiary_name, '"', '') AS beneficiary_name,
		COALESCE(REPLACE(project_name, '"', ''), REPLACE(beneficiary_name, '"', '')) AS project_name,
		NULL::INT AS contract_date,
		year_of_payment::INT AS end_date,
		NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.')::FLOAT, 0) AS approved_amount,
		NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DE8' AS nuts2,
		'ESF' AS fund_type
	FROM "1_de8_mecklenburg_vorpommern_esf"
),
vw_1_de9_niedersachsen_erdf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULLIF(year_of_approval, '')::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DE9' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_de9_niedersachsen_erdf"
),
vw_1_de9_niedersachsen_esf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULLIF(year_of_approval, '')::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DE9' AS nuts2,
		'ESF' AS fund_type
	FROM "1_de9_niedersachsen_esf"
),
vw_1_dea_nordrhein_westfalen_erdf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULL::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT as end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DEA' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_dea_nordrhein_westfalen_erdf"
),
vw_1_dea_nordrhein_westfalen_esf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULLIF(year_of_approval, '')::INT as contract_date,
		NULL::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(approved_amount, ' €', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULL::FLOAT AS final_amount,
		NULL::FLOAT AS full_amount,
		CASE WHEN city IN (
			'01210 Wien',
			'34000 Mopntpellier',
			'8010 Graz',
			'9020 Klagenfurt',
			'AK Vaals',
			'AP Kerkrade',
			'AT Nederasselt',
			'Aldrans',
			'Amsterdam',
			'Antwerpen',
			'Aschau',
			'Avila',
			'B 1090 Bruxelles',
			'B 4700 Eupen',
			'B 4731 Eynatten',
			'BD Rhenen',
			'BL Landgraaf',
			'BM Gennep',
			'BP Genemuiden',
			'BZ Epe',
			'Baar',
			'Bad Zurzach',
			'Balgach',
			'Barcelona',
			'Basel',
			'Bassano del Grappa',
			'Beatenberg',
			'Belp',
			'Beringen',
			'Besancon Cedex',
			'Biel-Benken',
			'Blackheath, West Midlands B65 OH',
			'Boulder,Co',
			'Bregenz',
			'Broek op Langedijk',
			'Bruxelles',
			'Buenos Aires',
			'Büllingen',
			'CB Breda',
			'CH Embrach',
			'Cala Mandia',
			'Ciudad Quesada',
			'Cork',
			'DR Wierden',
			'Debrecen',
			'Delemont',
			'Delft',
			'Devon TQ3 2AF',
			'Diano San Pietro',
			'Dornach 1',
			'Dublin 2',
			'Dublin 6, Ireland',
			'E 07560 Cala Millor Mallorca',
			'E 11140 Conil',
			'EX Eindhoven',
			'Effretikon',
			'Elbigenalp',
			'Enschede',
			'Ernstbrunn',
			'Eschenbach SG',
			'Ex Eindhoven',
			'F 75015 Paris',
			'F 75005 Paris',
			'F 75009 Paris',
			'Firenze/Italien',
			'GB London N19 5SU',
			'Gent',
			'George St. Bath',
			'GER',
			'Girona',
			'Gonten',
			'Graz',
			'Hasselt',
			'Hechtel/Belgien',
			'Helsinki',
			'Hoeilaart',
			'Hombrechtikon',
			'Hünenberg/Zug',
			'I 30123 Venezia',
			'IT 00046 Grottaferrata',
			'Innsbruck',
			'Irl Dubiln',
			'KD Sittard',
			'Klagenfurt',
			'Kobenhavn K',
			'Kollerschlag',
			'Kreuzlingen',
			'Kruibeke',
			'Köflach',
			'Küsnacht',
			'Küsnacht/Zürich',
			'Küssnacht/Zürich',
			E'L\'Arbresle',
			'LT Amsterdam',
			'LU 6637 Wasserbillig',
			'LU Junglinster',
			'La Kapelle',
			'Le Val',
			'London',
			'London E1 4NS',
			'London W14 8DZ',
			'Lyon',
			'Maaseik',
			'Madrid',
			'Malaga',
			'Malta',
			'Marcoussis-cedex',
			'Meikirch/Bern',
			'Meilen',
			'Meythet',
			'Mondsee',
			'Montreux',
			'Montuiri',
			'Münchenbuchsee',
			'Münschecker',
			'NL 1399 GN Muiderberg',
			'NL 2585 Den Haag',
			'NL 3812 RS Amersfoort',
			'NL 4301 CK Zierikzee',
			'NL 6525 ED Nijmegen',
			'NL 7513 KB Enschede',
			'NL 7559 KJ Hengelo',
			'New York',
			'Newbury',
			'Newbury/Berkshire Great Britain',
			'Nijmegen',
			'Oberdiessbach',
			'Oelstykke',
			'PD Vassen',
			'Palma de Mallorca',
			'Paris',
			'Portsmouth PO1 2AH',
			'Poznan',
			'Puch bei Salzburg',
			'RG Enschede',
			'RP Amsterdam',
			'RS Amersfoort',
			'Rebstein',
			'Reith bei Kitzbühel',
			'Romanshorn',
			'Roncocampocanneto
Parma',
			'Rüti ZH',
			'SE 11436 Stockholm',
			'SL Tegelen',
			'SW Enschede',
			'San Francisco',
			'Sant Josep de sa Talaia/Ibiza',
			'Schalchen',
			'St. Die',
			'St. Gallen',
			'St. Pölten',
			'St. Stefan im Rosental',
			'St. Stefsn',
			'Stalden',
			'Stans',
			'Stein am Rhein',
			'Spa',
			'Thalwil',
			'Turin',
			'UK Brighton',
			'USA 34238 Sarasota, Florida',
			'USA Long Beach CA 90803',
			'Urdorf',
			'Valencia',
			'Verona',
			'Volketswil',
			'WC2B5LQ London',
			'WC2N 6DF London',
			'WE Groningen',
			'Walchsee',
			'Walchsee/Tirol',
			'Waldegg-Beatenberg
Schweiz',
			'Wangen',
			'Wasserbillig',
			'Wetzikon',
			'Wexford',
			'Wien',
			'Winterthur',
			'Wissembourg',
			'XN Den Haag',
			'XT Leiden',
			'Zug',
			'Zürich'
		) THEN 'Ausland ' || city ELSE city END AS loc,
		'DEA' AS nuts2,
		'ESF' AS fund_type
	FROM "1_dea_nordrhein_westfalen_esf"
),
vw_1_deb_rheinland_pfalz_erdf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULL::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT as end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DEB' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_deb_rheinland_pfalz_erdf"
),
vw_1_deb_rheinland_pfalz_esf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULLIF(year_of_approval, '')::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DEB' AS nuts2,
		'ESF' AS fund_type
	FROM "1_deb_rheinland_pfalz_esf"
),
vw_1_dec_saarland_erdf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULLIF(year_of_approval, '')::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(approved_amount, '€', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(final_amount, '€', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		CASE 
			WHEN beneficiary_name ilike '%,%' AND beneficiary_name != 'Ministerium für Wirt- schaft, Arbeit, Energie'
				THEN trim((regexp_split_to_array(beneficiary_name, ','))[array_upper(regexp_split_to_array(beneficiary_name, ','), 1)]) 
			ELSE NULL 
		END AS loc,
		'DEC' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_dec_saarland_erdf"
),
vw_1_dec_saarland_esf AS (
	SELECT 
		beneficiary_name,
		beneficiary_name AS project_name,
		NULL::INT AS contract_date,
		RIGHT(end_date, 4)::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULL::FLOAT AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DEC' AS nuts2,
		'ESF' AS fund_type
	FROM "1_dec_saarland_esf"
),
vw_1_ded_sachsen_erdf AS (
	SELECT 
		beneficiary_name,
		COALESCE(NULLIF(project_name, ''), beneficiary_name) AS project_name,
		NULLIF(year_of_approval, '')::INT as contract_date,
		NULL::INT AS end_date,
		NULLIF(REPLACE(REPLACE(approved_amount, ',', ''),' ','')::FLOAT, 0) AS approved_amount,
		NULLIF(REPLACE(REPLACE(final_amount, ',', ''),' ','')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DED' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_ded_sachsen_erdf"
	WHERE final_amount NOT LIKE '-%'
),
vw_1_ded_sachsen_esf AS (
	SELECT 
		NULLIF(beneficiary_name, '') AS beneficiary_name,
		project_name,
		NULLIF(year_of_approval, '')::INT AS contract_date,
		NULL::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(approved_amount, ',', ''),' ',''),'')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(final_amount, ',', ''),' ',''),'')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DED' AS nuts2,
		'ESF' AS fund_type
	FROM "1_ded_sachsen_esf"
),
vw_1_dee_sachsen_anhalt_erdf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULLIF(year_of_approval, '')::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DEE' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_dee_sachsen_anhalt_erdf"
),
vw_1_dee_sachsen_anhalt_esf AS (
	SELECT 
		beneficiary_name,
		COALESCE(project_name, beneficiary_name) AS project_name,
		NULLIF(year_of_approval, '')::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DEE' AS nuts2,
		'ESF' AS fund_type
	FROM "1_dee_sachsen_anhalt_esf"
),
vw_1_def_schleswig_holstein_erdf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULLIF(year_of_approval, '')::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(approved_amount, '€', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(REPLACE(final_amount, '€', ''), '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DEF' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_def_schleswig_holstein_erdf"
),
vw_1_def_schleswig_holstein_esf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULL::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		CASE 
			WHEN beneficiary_name ilike '%\n%' or beneficiary_name ilike '%\r%' OR regexp_replace(beneficiary_name, E'[\\n\\r]+', '|', 'g' ) ilike '%|%' 
			THEN trim((regexp_split_to_array(beneficiary_name, '\n'))[array_upper(regexp_split_to_array(beneficiary_name, '\n'), 1)]) 
			ELSE NULL 
		END AS loc,
		'DEF' AS nuts2,
		'ESF' AS fund_type
	FROM "1_def_schleswig_holstein_esf"
),
vw_1_deg_thueringen_erdf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULL::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DEG' AS nuts2,
		'ERDF' AS fund_type
	FROM "1_deg_thueringen_erdf"
),
vw_1_deg_thueringen_esf AS (
	SELECT 
		beneficiary_name,
		project_name,
		NULL::INT AS contract_date,
		NULLIF(year_of_payment, '')::INT AS end_date,
		NULLIF(NULLIF(REPLACE(REPLACE(approved_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS approved_amount,
		NULLIF(NULLIF(REPLACE(REPLACE(final_amount, '.', ''), ',', '.'), '')::FLOAT, 0) AS final_amount,
		NULL::FLOAT AS full_amount,
		NULL AS loc,
		'DEG' AS nuts2,
		'ESF' AS fund_type
	FROM "1_deg_thueringen_esf"
),
vw_de_union AS (
	SELECT *, row_number() OVER () AS transaction_id FROM (
		SELECT * FROM vw_1_de1_baden_wuerttemberg_erdf
		UNION ALL
		SELECT * FROM vw_1_de1_baden_wuerttemberg_esf
		UNION ALL
		SELECT * FROM vw_1_de2_bayern_erdf
		UNION ALL
		SELECT * FROM vw_1_de2_bayern_esf
		UNION ALL
		SELECT * FROM vw_1_de3_berlin_erdf
		UNION ALL
		SELECT * FROM vw_1_de3_berlin_esf
		UNION ALL
		SELECT * FROM vw_1_de4_brandenburg_erdf
		UNION ALL
		SELECT * FROM vw_1_de4_brandenburg_esf
		UNION ALL
		SELECT * FROM vw_1_de5_bremen_erdf
		UNION ALL
		SELECT * FROM vw_1_de5_bremen_esf
		UNION ALL
		SELECT * FROM vw_1_de6_hamburg_erdf
		UNION ALL
		SELECT * FROM vw_1_de6_hamburg_esf
		UNION ALL
		SELECT * FROM vw_1_de7_hessen_erdf
		UNION ALL
		SELECT * FROM vw_1_de7_hessen_esf
		UNION ALL
		SELECT * FROM vw_1_de8_mecklenburg_vorpommern_erdf
		UNION ALL
		SELECT * FROM vw_1_de8_mecklenburg_vorpommern_esf
		UNION ALL
		SELECT * FROM vw_1_de9_niedersachsen_erdf
		UNION ALL
		SELECT * FROM vw_1_de9_niedersachsen_esf
		UNION ALL
		SELECT * FROM vw_1_dea_nordrhein_westfalen_erdf
		UNION ALL
		SELECT * FROM vw_1_dea_nordrhein_westfalen_esf
		UNION ALL
		SELECT * FROM vw_1_deb_rheinland_pfalz_erdf
		UNION ALL
		SELECT * FROM vw_1_deb_rheinland_pfalz_esf
		UNION ALL
		SELECT * FROM vw_1_dec_saarland_erdf
		UNION ALL
		SELECT * FROM vw_1_dec_saarland_esf
		UNION ALL
		SELECT * FROM vw_1_ded_sachsen_erdf
		UNION ALL
		SELECT * FROM vw_1_ded_sachsen_esf
		UNION ALL
		SELECT * FROM vw_1_dee_sachsen_anhalt_erdf
		UNION ALL
		SELECT * FROM vw_1_dee_sachsen_anhalt_esf
		UNION ALL
		SELECT * FROM vw_1_def_schleswig_holstein_erdf
		UNION ALL
		SELECT * FROM vw_1_def_schleswig_holstein_esf
		UNION ALL
		SELECT * FROM vw_1_deg_thueringen_erdf
		UNION ALL
		SELECT * FROM vw_1_deg_thueringen_esf
	) AS vw
)

SELECT * INTO "vw_de_union" FROM vw_de_union;

INSERT INTO public.final (transaction_id,project_name,beneficiary_name,total_ammount,eu_cofinancing_amount,amount,amount_kind,beneficiary_country_code,beneficiary_id,fund_acronym,funding_period,geocoding_state,beneficiary_postal_code,beneficiary_lau2,project_state,project_region,project_county,project_city,project_nuts2,project_nuts3,project_lau2,project_postal_code,project_address,contract_date,end_date)
WITH
vw_loc AS (
	SELECT u.*, 
		COALESCE(p.shape_lau, p2.shape_lau) AS shape_lau,
		COALESCE(p.name, p2.name) AS location_name,
		COALESCE(p.population, p2.population)::INT AS population
	FROM vw_de_union as u
	LEFT JOIN "1_population" as p ON p.shape_lau LIKE 'DE%' AND 
		((
			p.shape_lau ILIKE u.nuts2 || '%' 
			AND (p.name = u.loc 
			OR p.name ILIKE (u.loc || '%')
			OR (u.loc = 'Bremen, Bremerhaven' AND p.name IN ('Bremen, Stadt', 'Bremerhaven, Stadt'))
			OR (u.loc LIKE 'Sylt%' AND p.name = 'Sylt')
			OR (u.loc = 'Saarbrü- cken' AND p.name = 'Saarbrücken, Landeshauptstadt')
			OR (u.loc IN ('Limburg a. d. Lahn', 'Limburg a.d.Lahn') AND p.name = 'Limburg a.d. Lahn, Kreisstadt')
			OR (u.loc = 'Lichtenfels OT Dalwigksthal' AND p.name = 'Lichtenfels, Stadt')
			OR (u.loc = 'Bad Endbach-Schlierbach' AND p.name = 'Bad Endbach')
			OR (u.loc = 'Homberg/Efze' AND p.name = 'Homberg (Efze), Kreisstadt')
			OR (u.project_name = 'Errichtung einer Betriebsstätte in 34537 Bad Wildungen' AND p.name = 'Bad Wildungen, Stadt')
			OR (u.loc = 'Kleinlüder' AND p.name = 'Großenlüder')
			OR (u.loc = 'Giessen' AND p.name = 'Gießen, Universitätsstadt')
			OR (u.loc = 'Coelbe' AND p.name = 'Cölbe')
			OR (u.loc = 'Klarenthal' AND p.name = 'Saarbrücken, Landeshauptstadt')
			OR (u.loc = 'Dirmingen' AND p.name = 'Eppelborn')
			OR (u.loc = 'Ilingen' AND p.name = 'Neunkirchen, Kreisstadt')
			OR (u.loc = 'Pütt- lingen' AND p.name = 'Püttlingen, Stadt')
			OR (u.loc = 'Tholey-Hasborn' AND p.name = 'Tholey')
			OR (u.loc = '66299 Friedrichtsthal' AND p.name = 'Friedrichsthal, Stadt')
			OR (u.loc = '66450 Bexbach' AND p.name = 'Bexbach, Stadt')
			OR (u.loc = '66740Saar- louis' AND p.name = 'Saarlouis, Kreisstadt')
			OR (u.loc = '66386 St. Ingbert' AND p.name = 'St. Ingbert, Stadt')
			OR (u.loc = 'Dudweiler' AND p.name = 'Saarbrücken, Landeshauptstadt')
			OR (u.loc = 'Westerland' AND p.name = 'Sylt')
			OR (u.loc = 'Sereetz' AND p.name = 'Ratekau')
			OR (u.loc = 'Pansdorf' AND p.name = 'Ratekau')
			OR (u.loc = 'St. Michaelisdonn' AND p.name = 'Sankt Michaelisdonn')
			OR (u.loc = 'Friedensthal' AND p.name = 'Windeby')
			OR (u.loc = 'Tinnum/Sylt-Ost' AND p.name = 'Sylt')
			OR (u.loc = 'Tinnum /Sylt-Ost' AND p.name = 'Sylt')
			OR (u.loc = 'Lauenburg/Elbe' AND p.name = 'Lauenburg/ Elbe, Stadt')
			OR (u.loc = 'Techau' AND p.name = 'Ratekau')
			OR (u.loc = 'Rantum' AND p.name = 'Sylt')
			OR (u.loc = 'Weddinghusen' AND p.name = 'Weddingstedt')
			OR (u.loc = 'Raisdorf' AND p.name = 'Schwentinental, Stadt')
			OR (u.loc = 'Langeness' AND p.name = 'Langeneß')
			OR (u.loc = 'Leezen/ Heiderfeld' AND p.name = 'Leezen' AND p.lau = '01060053')
			OR (u.loc = 'Beusloe/Schashagen' AND p.name = 'Schashagen')
			OR (u.loc = 'Groß Meinsdorf' AND p.name = 'Süsel')
			OR (u.loc = 'Lübeck-Travemünde' AND p.name = 'Lübeck, Hansestadt')
			OR (u.loc = 'Neustadt/Holstein' AND p.name = 'Neustadt in Holstein, Stadt')
			OR (u.loc = 'Oevelgönne' AND p.name = 'Sierksdorf')
			OR (u.loc = 'Krembs' AND p.name = 'Gremersdorf')
			)
			AND u.loc NOT IN (
				'Ahrenviöl',
				'Bedburg',
				'Bendorf',
				'Berg',
				'Buchholz',
				'Burbach',
				'Büsum',
				'Elmenhorst',
				'Fulda',
				'Garding',
				'Greven',
				'Halle',
				'Hamm',
				'Harmsdorf',
				'Hausen',
				'Hattstedt',
				'Heide',
				'Langen',
				'Neunkirchen',
				'Schenefeld',
				'Schönberg',
				'Wisch',
				'Hennstedt',
				'Hollingstedt',
				'Horst',
				'Hünfeld',
				'Kall',
				'Kleve',
				'Krempe',
				'Marne',
				'Neuendorf',
				'Neukirchen',
				'Nidda',
				'Nortorf',
				'Oldenburg',
				'Ostenfeld',
				'Quickborn',
				'Rethwisch',
				'Rosdorf',
				'Rotenburg',
				'Seedorf',
				'Senden',
				'Stein',
				'Steinberg',
				'Tangstedt',
				'Vaale',
				'Wees',
				'Wesselburen',
				'Neustadt'
			)
		)
		OR (
			nuts2 = 'DEA' AND fund_type = 'ESF' AND (
				(u.loc = 'Achberg b Lindau' AND p.name = 'Achberg')
				OR (u.loc = 'Achim b Bremen' AND p.name = 'Achim, Stadt')
				OR (u.loc = 'Aichach a d Paar' AND p.name = 'Aichach, St')
				OR (u.loc = 'Altdorf b Nürnberg' AND p.name = 'Altdorf b.Nürnberg, St')
				OR (u.loc = 'Altenhof b Eckernförde' AND p.name = 'Altenhof' AND p.lau = '01058004')
				OR (u.loc = 'Arolsen' AND p.name = 'Bad Arolsen, Stadt')
				OR (u.loc = 'Aschau i Chiemgau' AND p.name = 'Aschau i.Chiemgau')
				OR (u.loc = 'Bad Homburg v d Höhe' AND p.name = 'Bad Homburg v. d. Höhe, Stadt')
				OR (u.loc = 'Bechhofen a d Heide' AND p.name = 'Bechhofen, M')
				OR (u.loc = 'Bernau b Berlin' AND p.name = 'Bernau bei Berlin, Stadt')
				OR (u.loc = 'Birkenau- Nieder Liebersbach' AND p.name = 'Birkenau')
				OR (u.loc = 'Blankenfelde b Zossen b Berlin' AND p.name = 'Zossen, Stadt')
				OR (u.loc = 'Borstel b Neumünster' AND p.name = 'Neumünster, Stadt')
				OR (u.loc = 'Brackel b Winsen' AND p.name = 'Brackel')
				OR (u.loc = 'Burgneudorf' AND p.name = 'Spreetal')
				OR (u.loc = 'Börm b Schleswig' AND p.name = 'Börm')
				OR (u.loc = 'Bötersheim' AND p.name = 'Kakenstorf')
				OR (u.loc = 'Bücken b Hoya' AND p.name = 'Bücken, Flecken')
				OR (u.loc = 'Caputh' AND p.name = 'Schwielowsee')
				OR (u.loc = 'Charlottenberg b Holzappel' AND p.name = 'Charlottenberg')
				OR (u.loc = 'Dahlwitz-Hoppegarten' AND p.name = 'Hoppegarten')
				OR (u.loc = 'Dernbach b Dierdorf' AND p.name = 'Dernbach' AND p.lau = '07138011')
				OR (u.loc = 'Dernbach b Montabaur' AND p.name = 'Dernbach (Westerwald)')
				OR (u.loc = 'Dietfurt a d Altmühl' AND p.name = 'Dietfurt a.d.Altmühl, St')
				OR (u.loc = 'Dießen a Ammersee' AND p.name = 'Dießen am Ammersee, M')
				OR (u.loc = 'Dießen/Landsberg am Lech' AND p.name = 'Dießen am Ammersee, M')
				OR (u.loc = 'Dillingen a d Donau' AND p.name = 'Dillingen a.d.Donau, GKSt')
				OR (u.loc = 'Dörnberg b Holzappel' AND p.name = 'Dörnberg')
				OR (u.loc = 'Ebenhausen' AND p.name = 'Baar-Ebenhausen')
				OR (u.loc = 'Eichenau b München' AND p.name = 'Eichenau')
				OR (u.loc = 'Forst b Wissen' AND p.name = 'Forst' AND p.lau = '07132034')
				OR (u.loc = 'Freetz' AND p.name = 'Lengenbostel')
				OR (u.loc = 'Friedensau' AND p.name = 'Möckern, Stadt')
				OR (u.loc = 'Gehrde b Bersenbrück' AND p.name = 'Gehrde')
				OR (u.loc = 'Grafelfing' AND p.name = 'Gräfelfing')
				OR (u.loc = 'Grafing b München' AND p.name = 'Grafing b.München, St')
				OR (u.loc = 'Grafschaft b Bad Neuenahr-Ahrweil' AND p.name = 'Grafschaft')
				OR (u.loc = 'Gronau-Epe' AND p.name = 'Gronau (Westf.), Stadt')
				OR (u.loc = 'Grönenbach' AND p.name = 'Bad Grönenbach, M')
				OR (u.loc = 'Gumpenweiler b Kreßberg' AND p.name = 'Kreßberg')
				OR (u.loc = 'Halle in Westfalen' AND p.name = 'Halle (Westf.), Stadt')
				OR (u.loc = 'Halle/Westfalen' AND p.name = 'Halle (Westf.), Stadt')
				OR (u.loc = 'Hansestadt Salzwedel' AND p.name = 'Salzwedel, Hansestadt')
				OR (u.loc = 'Harztor' AND p.name = 'Ilfeld')
				OR (u.loc = 'Heiligenhaus b Velbert' AND p.name = 'Heiligenhaus, Stadt')
				OR (u.loc = 'Hellwege b Rotenburg' AND p.name = 'Hellwege')
				OR (u.loc = 'Herrenberg im Gäu' AND p.name = 'Herrenberg, Stadt')
				OR (u.loc = 'Herrsching a Ammersee' AND p.name = 'Herrsching a.Ammersee')
				OR (u.loc = 'Hespe b Stadthagen' AND p.name = 'Hespe')
				OR (u.loc = 'Hirschberg a d Bergstraße' AND p.name = 'Hirschberg an der Bergstraße')
				OR (u.loc = 'Hohenroth b Bad Neustadt a d Saal' AND p.name = 'Hohenroth')
				OR (u.loc = 'Holle b Hildesheim' AND p.name = 'Holle')
				OR (u.loc = 'Höchst i Odw' AND p.name = 'Höchst i. Odw.')
				OR (u.loc = 'Hüde b Diepholz' AND p.name = 'Hüde')
				OR (u.loc = 'Inning a Ammersee' AND p.name = 'Inning a.Ammersee')
				OR (u.loc = 'Inning a Holz' AND p.name = 'Inning a.Holz')
				OR (u.loc = 'Kalbe b Sittensen' AND p.name = 'Kalbe')
				OR (u.loc = 'Karlstein a Main' AND p.name = 'Karlstein a.Main')
				OR (u.loc = 'Kesselsdorf' AND p.name = 'Wilsdruff, Stadt')
				OR (u.loc = 'Kirchheim b München' AND p.name = 'Kirchheim b.München')
				OR (u.loc = 'Koblenz am Rhein' AND p.name = 'Koblenz, Stadt')
				OR (u.loc = 'Kraiburg a Inn' AND p.name = 'Kraiburg a.Inn, M')
				OR (u.loc = 'Kötzting' AND p.name = 'Bad Kötzting, St')
				OR (u.loc = 'Laatzen b Hannover' AND p.name = 'Laatzen, Stadt')
				OR (u.loc = 'Langenbach b Kirburg' AND p.name = 'Langenbach bei Kirburg')
				OR (u.loc = 'Langerwisch Süd' AND p.name = 'Michendorf')
				OR (u.loc = 'Lehnin' AND p.name = 'Kloster Lehnin')
				OR (u.loc = 'Lehrte b Hannover' AND p.name = 'Lehrte, Stadt')
				OR (u.loc = 'Leppin b Strasburg' AND p.name = 'Lindetal')
				OR (u.loc = 'Limburg a d Lahn' AND p.name = 'Limburg a.d. Lahn, Kreisstadt')
				OR (u.loc = 'Lindau/Bodensee' AND p.name = 'Lindau (Bodensee), GKSt')
				OR (u.loc = 'Linz a Rhein' AND p.name = 'Linz am Rhein, Stadt')
				OR (u.loc = 'Lobenstein' AND p.name = 'Bad Lobenstein, Stadt')
				OR (u.loc = 'Lutherstadt Wittenberg' AND p.name = 'Wittenberg, Lutherstadt')
				OR (u.loc = 'Mainz a Rhein' AND p.name = 'Mainz, Stadt')
				OR (u.loc = 'Mainz-Kastel' AND p.name = 'Wiesbaden, Landeshauptstadt')
				OR (u.loc = 'Mainz-Kostheim' AND p.name = 'Wiesbaden, Landeshauptstadt')
				OR (u.loc = 'Marienfeld' AND p.name = 'Harsewinkel, Stadt')
				OR (u.loc = 'Meerbusch-Osterath' AND p.name = 'Meerbusch, Stadt')
				OR (u.loc = 'Meinhard b Eschwege' AND p.name = 'Meinhard')
				OR (u.loc = 'Mittelbach b Chemnitz' AND p.name = 'Chemnitz, Stadt')
				OR (u.loc = 'Mitterdorf' AND p.name = 'Philippsreut')
				OR (u.loc = 'Moosburg a d Isar' AND p.name = 'Moosburg a.d.Isar, St')
				OR (u.loc = 'Murnau a Staffelsee' AND p.name = 'Murnau a.Staffelsee, M')
				OR (u.loc = 'Mühldorf a Inn' AND p.name = 'Mühldorf a.Inn, St')
				OR (u.loc = 'Münster b Dieburg' AND p.name = 'Münster' AND p.lau = '06432015')
				OR (u.loc = 'Neuburg a d Donau' AND p.name = 'Neuburg a.d.Donau, GKSt')
				OR (u.loc = 'Neuburg an der Donau' AND p.name = 'Neuburg a.d.Donau, GKSt')
				OR (u.loc = 'Neudietendorf' AND p.name = 'Nesse-Apfelstädt')
				OR (u.loc = 'Neuenhagen b Berlin' AND p.name = 'Neuenhagen bei Berlin')
				OR (u.loc = 'Neuenkirchen b Bramsche' AND p.name = 'Neuenkirchen' AND p.lau = '03459027')
				OR (u.loc = 'Neufahrn b Freising' AND p.name = 'Neufahrn b.Freising')
				OR (u.loc = 'Neuhaus a Inn' AND p.name = 'Neuhaus a.Inn')
				OR (u.loc = 'Niedererbach b Montabaur' AND p.name = 'Niedererbach')
				OR (u.loc = 'Nienstedt b Sangerhausen' AND p.name = 'Allstedt, Stadt')
				OR (u.loc = 'Oberasbach b Nürnberg' AND p.name = 'Oberasbach, St')
				OR (u.loc = 'Oberhaching b München' AND p.name = 'Oberhaching')
				OR (u.loc = 'Obermichelbach b Fürth' AND p.name = 'Obermichelbach')
				OR (u.loc = 'Obernburg a Main' AND p.name = 'Obernburg a.Main, St')
				OR (u.loc = 'Oberrot b Gaildorf' AND p.name = 'Oberrot')
				OR (u.loc = 'Offenbach a d Queich' AND p.name = 'Offenbach an der Queich')
				OR (u.loc = 'Osdorf b Kiel' AND p.name = 'Osdorf')
				OR (u.loc = 'Ostseebad Wustrow' AND p.name = 'Wustrow' AND p.lau = '13057094')
				OR (u.loc = 'Ottersberg b Bremen' AND p.name = 'Ottersberg, Flecken')
				OR (u.loc = 'Pattensen b Hannover' AND p.name = 'Pattensen, Stadt')
				OR (u.loc = 'Pfaffing a d Attel' AND p.name = 'Pfaffing')
				OR (u.loc = 'Prien a Chiemsee' AND p.name = 'Prien a.Chiemsee, M')
				OR (u.loc = 'Prittitz' AND p.name = 'Teuchern, Stadt')
				OR (u.loc = 'Pullach i Isartal' AND p.name = 'Pullach i.Isartal')
				OR (u.loc = 'Pähl OT Aidenried' AND p.name = 'Pähl')
				OR (u.loc = 'Raisdorf' AND p.name = 'Schwentinental, Stadt')
				OR (u.loc = 'Ried b Mering' AND p.name = 'Ried')
				OR (u.loc = 'Rieden a Forggensee' AND p.name = 'Rieden am Forggensee')
				OR (u.loc = 'Riemerling' AND p.name = 'Hohenbrunn')
				OR (u.loc = 'Rodenbach b Altenkirchen' AND p.name = 'Rodenbach bei Puderbach')
				OR (u.loc = 'Roderath' AND p.name = 'Nettersheim')
				OR (u.loc = 'Rosbach v d Höhe' AND p.name = 'Rosbach v. d. Höhe, Stadt')
				OR (u.loc = 'Rotenburg a d Fulda' AND p.name = 'Rotenburg a. d. Fulda, Stadt')
				OR (u.loc = 'Rotenburg/Wümme' AND p.name = 'Rotenburg (Wümme), Stadt')
				OR (u.loc = 'Roth b Stromberg' AND p.name = 'Roth' AND p.lau = '07133085')
				OR (u.loc = 'Roßdorf b Darmstadt' AND p.name = 'Roßdorf' AND p.lau = '06432020')
				OR (u.loc = 'Schneiderkrug' AND p.name = 'Emstek')
				OR (u.loc = 'Schwaig b Nürnberg' AND p.name = 'Schwaig b.Nürnberg')
				OR (u.loc = 'Schwarzach a Main' AND p.name = 'Schwarzach a.Main, M')
				OR (u.loc = 'Schönau a Königssee' AND p.name = 'Schönau a.Königssee')
				OR (u.loc = 'Schönfließ' AND p.name = 'Mühlenbecker Land')
				OR (u.loc = 'Schörghof' AND p.name = 'Wielenbach')
				OR (u.loc = 'Seebad Heringsdorf' AND p.name = 'Heringsdorf' AND p.lau = '13059112')
				OR (u.loc = 'Seehausen a Staffelsee' AND p.name = 'Seehausen a.Staffelsee')
				OR (u.loc = 'Sevelten' AND p.name = 'Cappeln (Oldenburg)')
				OR (u.loc = 'Simbach a Inn' AND p.name = 'Simbach a.Inn, St')
				OR (u.loc = 'Sonnenstein' AND p.name = 'Weißenborn-Lüderode')
				OR (u.loc = 'St Andreasberg' AND p.name = 'Sankt Andreasberg, Bergstadt')
				OR (u.loc = 'St Johann' AND p.name = 'St. Johann')
				OR (u.loc = 'St Peter-Ording' AND p.name = 'Sankt Peter-Ording')
				OR (u.loc = 'St Wendel' AND p.name = 'St. Wendel, Kreisstadt')
				OR (u.loc = 'Stiege' AND p.name = 'Oberharz am Brocken, Stadt')
				OR (u.loc = 'Stellshagen' AND p.name = 'Damshagen')
				OR (u.loc = 'Stockdorf' AND p.name = 'Gauting')
				OR (u.loc = 'Stockstadt a Main' AND p.name = 'Stockstadt a.Main, M')
				OR (u.loc = 'Tünsdorf' AND p.name = 'Mettlach')
				OR (u.loc = 'Uffing a Staffelsee' AND p.name = 'Uffing a.Staffelsee')
				OR (u.loc = 'Varrel b Sulingen' AND p.name = 'Varrel')
				OR (u.loc = 'Walchensee' AND p.name = 'Kochel a.See')
				OR (u.loc = 'Wangen/Allgäu' AND p.name = 'Wangen im Allgäu, Stadt')
				OR (u.loc = 'Weiler b Bingen am Rhein' AND p.name = 'Weiler bei Bingen')
				OR (u.loc = 'Weiler b Mayen' AND p.name = 'Weiler' AND p.lau = '07137110')
				OR (u.loc = 'Weilheim/OB' AND p.name = 'Weilheim i.OB, St')
				OR (u.loc = 'Weilheim/Teck' AND p.name = 'Weilheim an der Teck, Stadt')
				OR (u.loc = 'Weimar/Lahn' AND p.name = 'Weimar (Lahn)')
				OR (u.loc = 'Welden b Augsburg' AND p.name = 'Welden, M')
				OR (u.loc = 'Wernesgrün' AND p.name = 'Steinberg' AND p.lau = '14523380')
				OR (u.loc = 'Wertheim a Main' AND p.name = 'Wertheim, Stadt')
				OR (u.loc = 'Westerland' AND p.name = 'Sylt')
				OR (u.loc = 'Winterbach b Schorndorf' AND p.name = 'Winterbach' AND p.lau = '08119086')
				OR (u.loc = 'Wünnenberg' AND p.name = 'Bad Wünnenberg, Stadt')
				OR (u.loc = 'Zeitlarn b Regensburg' AND p.name = 'Zeitlarn')
				OR (u.loc = 'Zell/Main' AND p.name = 'Zell a.Main, M')
				OR (u.loc = 'Zell/Wiesental' AND p.name = 'Zell im Wiesental, Stadt')
				OR (u.loc = 'Zossen b Berlin' AND p.name = 'Zossen, Stadt')
			)
		)
		OR 
		(
			(u.loc = 'Affing' AND p.name = 'Affing')
			OR (u.loc = 'Ahrenviöl' AND p.name = 'Ahrenviöl')
			OR (u.loc = 'Altenkirchen' AND p.name = 'Altenkirchen (Westerwald), Stadt')
			OR (u.loc = 'Arnstein' AND p.name = 'Arnstein, St')
			OR (u.loc = 'Asbach' AND p.name = 'Asbach' AND p.lau = '07138003')
			OR (u.loc = 'Aue' AND p.name = 'Aue, Stadt')
			OR (u.loc = 'Bad König' AND p.name = 'Bad König, Stadt')
			OR (u.loc = 'Battenberg' AND p.name = 'Battenberg (Eder), Stadt')
			OR (u.loc = 'Bedburg' AND p.name = 'Bedburg, Stadt')
			OR (u.loc = 'Bendorf' AND p.name = 'Bendorf, Stadt')
			OR (u.loc = 'Berg' AND p.name = 'Berg' AND p.lau = '09188113')
			OR (u.loc = 'Bergen' AND p.name = 'Bergen an der Dumme, Flecken')
			OR (u.loc = 'Berlin' AND p.name = 'Berlin, Stadt')
			OR (u.loc = 'Bevern' AND p.name = 'Bevern, Flecken')
			OR (u.loc = 'Birkenfeld' AND p.name = 'Birkenfeld, Stadt')
			OR (u.loc = 'Bonn' AND p.name = 'Bonn, Stadt')
			OR (u.loc = 'Breitscheid' AND p.name = 'Breitscheid' AND p.lau = '06532004')
			OR (u.loc = 'Bruchweiler' AND p.name = 'Bruchweiler-Bärenbach')
			OR (u.loc = 'Brücken' AND p.name = 'Brücken (Pfalz)')
			OR (u.loc = 'Buchholz' AND p.name = 'Buchholz (Westerwald)')
			OR (u.loc = 'Burbach' AND p.name = 'Saarbrücken, Landeshauptstadt')
			OR (u.loc = 'Burgdorf' AND p.name = 'Burgdorf, Stadt')
			OR (u.loc = 'Bühl' AND p.name = 'Bühl, Stadt')
			OR (u.loc = 'Büsum' AND p.name = 'Büsum')
			OR (u.loc = 'Denkendorf' AND p.name = 'Denkendorf' AND p.lau = '08116015')
			OR (u.loc = 'Dürnau' AND p.name = 'Dürnau' AND p.lau = '08117017')
			OR (u.loc = 'Eching' AND p.name = 'Eching' AND p.lau = '09178120')
			OR (u.loc = 'Elmenhorst' AND p.name = 'Elmenhorst' AND p.lau = '01062016')
			OR (u.loc = 'Eching' AND p.name = 'Eching' AND p.lau = '09178120')
			OR (u.loc = 'Erbach' AND p.name = 'Erbach, Kreisstadt' AND p.lau = '06437006')
			OR (u.loc = 'Essen' AND p.name = 'Essen, Stadt')
			OR (u.loc = 'Essingen' AND p.name = 'Essingen' AND p.lau = '08136021')
			OR (u.loc = 'Feucht' AND p.name = 'Feucht, M')
			OR (u.loc = 'Forchheim' AND p.name = 'Forchheim, GKSt')
			OR (u.loc = 'Forst' AND p.name = 'Forst' AND p.lau = '08215021')
			OR (u.loc = 'Frankenberg' AND p.name = 'Frankenberg (Eder), Stadt')
			OR (u.loc = 'Frankfurt' AND p.name = 'Frankfurt am Main, Stadt')
			OR (u.loc = 'Freiberg' AND p.name = 'Freiberg, Stadt')
			OR (u.loc = 'Friedberg' AND p.name = 'Friedberg (Hessen), Kreisstadt')
			OR (u.loc = 'Friedrichsthal' AND p.name = 'Friedrichsthal, Stadt')
			OR (u.loc = 'Friedland' AND p.name = 'Friedland')
			OR (u.loc = 'Fulda' AND p.name = 'Fulda, Stadt')
			OR (u.loc = 'Fürth' AND p.name = 'Fürth' AND p.lau = '09563000')
			OR (u.loc = 'Garding' AND p.name = 'Garding, Stadt')
			OR (u.loc = 'Gera' AND p.name = 'Gera, Stadt')
			OR (u.loc = 'Goldbach' AND p.name = 'Goldbach, M')
			OR (u.loc = 'Greven' AND p.name = 'Greven, Stadt')
			OR (u.loc = 'Gundelfingen' AND p.name = 'Gundelfingen')
			OR (u.loc = 'Haar' AND p.name = 'Haar')
			OR (u.loc = 'Haiger' AND p.name = 'Haiger, Stadt')
			OR (u.loc = 'Haldenwang' AND p.name = 'Haldenwang' AND p.lau = '09780122')
			OR (u.loc = 'Haiger' AND p.name = 'Haiger, Stadt')
			OR (u.loc = 'Halle' AND p.name = 'Halle (Westf.), Stadt')
			OR (u.loc = 'Hamberge' AND p.name = 'Hamberge')
			OR (u.loc = 'Hamm' AND p.name = 'Hamm, Stadt')
			OR (u.loc = 'Harmsdorf' AND p.name = 'Harmsdorf' AND p.lau = '01055020')
			OR (u.loc = 'Hausen' AND p.name = 'Hausen (Wied)')
			OR (u.loc = 'Hattstedt' AND p.name = 'Hattstedt')
			OR (u.loc = 'Heide' AND p.name = 'Heide, Stadt')
			OR (u.loc = 'Hemmingen' AND p.name = 'Hemmingen')
			OR (u.loc = 'Hennstedt' AND p.name = 'Hennstedt' AND p.lau = '01051049')
			OR (u.loc = 'Herborn' AND p.name = 'Herborn, Stadt')
			OR (u.loc = 'Herold' AND p.name = 'Herold')
			OR (u.loc = 'Hof' AND p.name = 'Hof' AND p.lau = '09464000')
			OR (u.loc = 'Holdorf' AND p.name = 'Holdorf' AND p.lau = '03460005')
			OR (u.loc = 'Hollingstedt' AND p.name = 'Hollingstedt' AND p.lau = '01059039')
			OR (u.loc = 'Holzkirchen' AND p.name = 'Holzkirchen')
			OR (u.loc = 'Holzminden' AND p.name = 'Holzminden, Stadt')
			OR (u.loc = 'Homberg' AND p.name = 'Homberg (Ohm), Stadt')
			OR (u.loc = 'Horhausen' AND p.name = 'Horhausen (Westerwald)')
			OR (u.loc = 'Horst' AND p.name = 'Horst (Holstein)')
			OR (u.loc = 'Hungen' AND p.name = 'Hungen, Stadt')
			OR (u.loc = 'Husum' AND p.name = 'Husum, Stadt')
			OR (u.loc = 'Hünfeld' AND p.name = 'Hünfeld, Konrad-Zuse-Stadt')
			OR (u.loc = 'Isen' AND p.name = 'Isen, M')
			OR (u.loc = 'Jena' AND p.name = 'Jena, Stadt')
			OR (u.loc = 'Kall' AND p.name = 'Kall')
			OR (u.loc = 'Karlsdorf' AND p.name = 'Karlsdorf-Neuthard')
			OR (u.loc = 'Kastl' AND p.name = 'Kastl' AND p.lau = '09171121')
			OR (u.loc = 'Kehl' AND p.name = 'Kehl, Stadt')
			OR (u.loc = 'Kirchberg' AND p.name = 'Kirchberg (Hunsrück), Stadt')
			OR (u.loc = 'Kirchen' AND p.name = 'Kirchen (Sieg), Stadt')
			OR (u.loc = 'Kleve' AND p.name = 'Kleve' AND p.lau = '01051060')
			OR (u.loc = 'Krempe' AND p.name = 'Krempe, Stadt')
			OR (u.loc = 'Lahn' AND p.name = 'Lahn')
			OR (u.loc = 'Lahr' AND p.name = 'Lahr/Schwarzwald, Stadt')
			OR (u.loc = 'Landscheid' AND p.name = 'Landscheid')
			OR (u.loc = 'Langen' AND p.name = 'Langen (Hessen), Stadt')
			OR (u.loc = 'Langenbach' AND p.name = 'Langenbach' AND p.lau = '09178138')
			OR (u.loc = 'Lauterbach' AND p.name = 'Lauterbach (Hessen), Kreisstadt')
			OR (u.loc = 'Leonberg' AND p.name = 'Leonberg, Stadt')
			OR (u.loc = 'Lichtenfels' AND p.name = 'Lichtenfels, St')
			OR (u.loc = 'Lindau' AND p.name = 'Lindau (Bodensee), GKSt')
			OR (u.loc = 'Lingen' AND p.name = 'Lingen (Ems), Stadt')
			OR (u.loc = 'Lüchow' AND p.name = 'Lüchow (Wendland), Stadt')
			OR (u.loc = 'Luckau' AND p.name = 'Luckau (Wendland)')
			OR (u.loc = 'Malberg' AND p.name = 'Malberg' AND p.lau = '07132066')
			OR (u.loc = 'Malsch' AND p.name = 'Malsch' AND p.lau = '08215046')
			OR (u.loc = 'Marne' AND p.name = 'Marne, Stadt')
			OR (u.loc = 'Mauer' AND p.name = 'Mauer')
			OR (u.loc = 'Meißen' AND p.name = 'Meißen, Stadt')
			OR (u.loc = 'Melle' AND p.name = 'Melle, Stadt')
			OR (u.loc = 'Metten' AND p.name = 'Metten, M')
			OR (u.loc = 'Müden' AND p.name = 'Müden (Aller)')
			OR (u.loc = 'München' AND p.name = 'München, Landeshauptstadt')
			OR (u.loc = 'Münsing' AND p.name = 'Münsing')
			OR (u.loc = 'Neuendorf' AND p.name = 'Neuendorf b. Elmshorn')
			OR (u.loc = 'Neuhausen' AND p.name = 'Neuhausen')
			OR (u.loc = 'Neukirchen' AND p.name = 'Neukirchen' AND p.lau = '01055031')
			OR (u.loc = 'Neumarkt' AND p.name = 'Neumarkt i.d.OPf., GKSt')
			OR (u.loc = 'Neunkirchen' AND p.name = 'Neunkirchen, Kreisstadt')
			OR (u.loc = 'Neuried' AND p.name = 'Neuried' AND p.lau = '09184132')
			OR (u.loc = 'Neustadt' AND p.name = 'Neustadt i. Sa., Stadt')
			OR (u.loc = 'Nidda' AND p.name = 'Nidda, Stadt')
			OR (u.loc = 'Nienburg' AND p.name = 'Nienburg (Weser), Stadt')
			OR (u.loc = 'Nienhagen' AND p.name = 'Nienhagen' AND p.lau = '03351018')
			OR (u.loc = 'Norden' AND p.name = 'Norden, Stadt')
			OR (u.loc = 'Nortorf' AND p.name = 'Nortorf, Stadt')
			OR (u.loc = 'Oberau' AND p.name = 'Oberau')
			OR (u.loc = 'Obrigheim' AND p.name = 'Obrigheim')
			OR (u.loc = 'Oldenburg' AND p.name = 'Oldenburg (Oldenburg), Stadt')
			OR (u.loc = 'Ostenfeld' AND p.name = 'Ostenfeld (Husum)')
			OR (u.loc = 'Petersberg' AND p.name = 'Petersberg' AND p.lau = '06631020')
			OR (u.loc = 'Pohl' AND p.name = 'Pohl')
			OR (u.loc = 'Preetz' AND p.name = 'Preetz, Stadt')
			OR (u.loc = 'Quern' AND p.name = 'Quern')
			OR (u.loc = 'Quickborn' AND p.name = 'Quickborn, Stadt')
			OR (u.loc = 'Rattelsdorf' AND p.name = 'Rattelsdorf, M')
			OR (u.loc = 'Rehling' AND p.name = 'Rehling')
			OR (u.loc = 'Rehlingen' AND p.name = 'Rehlingen-Siersburg')
			OR (u.loc = 'Reichelsheim' AND p.name = 'Reichelsheim (Wetterau), Stadt')
			OR (u.loc = 'Reichenbach' AND p.name = 'Reichenbach im Vogtland, Stadt')
			OR (u.loc = 'Rethwisch' AND p.name = 'Rethwisch' AND p.lau = '01062062')
			OR (u.loc = 'Rimbach' AND p.name = 'Rimbach' AND p.lau = '06431019')
			OR (u.loc = 'Rohrdorf' AND p.name = 'Rohrdorf' AND p.lau = '09187169')
			OR (u.loc = 'Rosdorf' AND p.name = 'Rosdorf' AND p.lau = '03152021')
			OR (u.loc = 'Rosengarten' AND p.name = 'Rosengarten' AND p.lau = '03353029')
			OR (u.loc = 'Rosenheim' AND p.name = 'Rosenheim')
			OR (u.loc = 'Rotenburg' AND p.name = 'Rotenburg (Wümme), Stadt')
			OR (u.loc = 'Rottenburg' AND p.name = 'Rottenburg am Neckar, Stadt')
			OR (u.loc = 'Rust' AND p.name = 'Rust')
			OR (u.loc = 'Röthenbach' AND p.name = 'Röthenbach a.d.Pegnitz, St')
			OR (u.loc = 'Rüdesheim' AND p.name = 'Rüdesheim am Rhein, Stadt')
			OR (u.loc = 'Schenefeld' AND p.name = 'Schenefeld, Stadt')
			OR (u.loc = 'Schmölln' AND p.name = 'Schmölln, Stadt')
			OR (u.loc = 'Schopfloch' AND p.name = 'Schopfloch')
			OR (u.loc = 'Schorndorf' AND p.name = 'Schorndorf, Stadt')
			OR (u.loc = 'Schwalbach' AND p.name = 'Schwalbach')
			OR (u.loc = 'Schwerin' AND p.name = 'Schwerin, Landeshauptstadt')
			OR (u.loc = 'Schönau' AND p.name = 'Schönau, Stadt')
			OR (u.loc = 'Schönberg' AND p.name = 'Schönberg (Holstein)')
			OR (u.loc = 'Schöneck' AND p.name = 'Schöneck')
			OR (u.loc = 'Seedorf' AND p.name = 'Seedorf' AND p.lau = '01060075')
			OR (u.loc = 'Sehlem' AND p.name = 'Lamspringe, Flecken')
			OR (u.loc = 'Senden' AND p.name = 'Senden')
			OR (u.loc = 'Siegen' AND p.name = 'Siegen, Stadt')
			OR (u.loc = 'Speicher' AND p.name = 'Speicher')
			OR (u.loc = 'Stade' AND p.name = 'Stade, Hansestadt')
			OR (u.loc = 'Stein' AND p.name = 'Stein')
			OR (u.loc = 'Steinberg' AND p.name = 'Steinberg' AND p.lau = '01059164')
			OR (u.loc = 'Steinebach' AND p.name = 'Steinebach/ Sieg')
			OR (u.loc = 'Steinen' AND p.name = 'Steinen' AND p.lau = '08336084')
			OR (u.loc = 'Steinfeld' AND p.name = 'Steinfeld (Oldenburg)')
			OR (u.loc = 'Stelle' AND p.name = 'Stelle')
			OR (u.loc = 'Stockheim' AND p.name = 'Stockheim' AND p.lau = '09476178')
			OR (u.loc = 'Suhl' AND p.name = 'Suhl, Stadt')
			OR (u.loc = 'Sulzbach' AND p.name = 'Sulzbach/ Saar, Stadt')
			OR (u.loc = 'Sulzfeld' AND p.name = 'Sulzfeld') AND p.lau = '09673173'
			OR (u.loc = 'Tangstedt' AND p.name = 'Tangstedt' AND p.lau = '01056047')
			OR (u.loc = 'Taufkirchen' AND p.name = 'Taufkirchen' AND p.lau = '09184145')
			OR (u.loc = 'Trier' AND p.name = 'Trier, Stadt')
			OR (u.loc = 'Ulm' AND p.name = 'Ulm, Universitätsstadt')
			OR (u.loc = 'Vaale' AND p.name = 'Vaalermoor')
			OR (u.loc = 'Waldbrunn' AND p.name = 'Waldbrunn' AND p.lau = '08225118')
			OR (u.loc = 'Waldeck' AND p.name = 'Waldeck, Stadt')
			OR (u.loc = 'Waldenburg' AND p.name = 'Waldenburg, Stadt' AND p.lau = '08126085')
			OR (u.loc = 'Walldorf' AND p.name = 'Walldorf, Stadt')
			OR (u.loc = 'Wees' AND p.name = 'Wees')
			OR (u.loc = 'Weidenbach' AND p.name = 'Weidenbach, M')
			OR (u.loc = 'Weimar' AND p.name = 'Weimar, Stadt')
			OR (u.loc = 'Weingarten' AND p.name = 'Weingarten, Stadt')
			OR (u.loc = 'Wentorf' AND p.name = 'Wentorf bei Hamburg')
			OR (u.loc = 'Wesselburen' AND p.name = 'Wesselburen, Stadt')
			OR (u.loc = 'Weyhe' AND p.name = 'Weyhe')
			OR (u.loc = 'Wielen' AND p.name = 'Wielen')
			OR (u.loc = 'Wiesenbach' AND p.name = 'Wiesenbach' AND p.lau = '08226097')
			OR (u.loc = 'Wilhelmsdorf' AND p.name = 'Wilhelmsdorf' AND p.lau = '08436083')
			OR (u.loc = 'Winsen' AND p.name = 'Winsen (Aller)')
			OR (u.loc = 'Wisch' AND p.name = 'Wisch' AND p.lau = '01057088')
			OR (u.loc = 'Wittenberge' AND p.name = 'Wittenberge, Stadt')
			OR (u.loc = 'Wolfsburg' AND p.name = 'Wolfsburg, Stadt')
			OR (u.loc = 'Wört' AND p.name = 'Wört')
			OR (u.loc = 'Wörth' AND p.name = 'Wörth am Rhein, Stadt')
			OR (u.loc = 'Zell' AND p.name = 'Zell (Mosel), Stadt')
			OR (u.loc = 'Zimmern' AND p.name = 'Zimmern ob Rottweil')
		)
		)
	LEFT JOIN "1_population" as p2 ON p.shape_lau IS NULL AND p2.shape_lau LIKE 'DE%' 
		AND (p2.name = u.loc 
		OR p2.name ILIKE (u.loc || '%')
		)
),
distribution AS (
	SELECT 
		*,
		CASE WHEN sum(population) OVER (PARTITION BY transaction_id) != 0 THEN
			population*1.0 / sum(population) OVER (PARTITION BY transaction_id) 
			ELSE 1
		END AS population_multiplier
	FROM vw_loc
),
vw AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
	  NULL::numeric AS total_ammount,
		COALESCE(final_amount,approved_amount) * population_multiplier AS eu_cofinancing_amount,
		COALESCE(final_amount,approved_amount) * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'DE' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fund_type AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS geocoding_state,
		NULL AS beneficiary_postal_code,
		NULL AS beneficiary_lau2,
		NULL AS project_state,
		NULL AS project_region,
		NULL AS project_county,
		COALESCE(location_name, loc) AS project_city,
		nuts2 AS project_nuts2,
		SUBSTRING(shape_lau,0,6) AS project_nuts3,
		shape_lau AS project_lau2,
		NULL AS project_postal_code,
		NULL AS project_address,
	  (contract_date || '-01-01')::date AS contract_date,
		(end_date || '-01-01')::date AS end_date
	FROM distribution
)
SELECT * FROM vw;