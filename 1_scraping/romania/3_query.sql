INSERT INTO public."ro_final" (
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
  country_code
)
WITH
pre_population AS (
  SELECT
    *,
    CASE
      WHEN population > 0 THEN population
      ELSE 1
    END AS population_corr
  FROM ro_population
),

base AS (
  SELECT
    md5(CONCAT('RO',ROW_NUMBER() OVER()::text)) AS transaction_id,
    *, 
    total_amount/4.0826088123 As total_amount_c,
    eu_cofinancing_amount/4.0826088123 AS eu_cofinancing_amount_c,
    (total_amount - eu_cofinancing_amount)/4.0826088123 As amount_c,
    CASE
      WHEN fund_acronym = 'ERDF' AND nuts2_name = 'AM POR' THEN 'nuts1'
      WHEN fund_acronym = 'ERDF' AND nuts2_name = 'Bucuresti Ilfov' THEN 'București-Ilfov'
      WHEN fund_acronym = 'ERDF' AND nuts2_name = 'Centru' THEN 'Centru'
      WHEN fund_acronym = 'ERDF' AND nuts2_name = 'Nord Est' THEN 'Nord-Est'
      WHEN fund_acronym = 'ERDF' AND nuts2_name = 'Nord Vest' THEN 'Nord-Vest'
      WHEN fund_acronym = 'ERDF' AND nuts2_name = 'OI Turism' THEN 'nuts1'
      WHEN fund_acronym = 'ERDF' AND nuts2_name = 'Sud' THEN 'Sud-Muntenia'
      WHEN fund_acronym = 'ERDF' AND nuts2_name = 'Sud Est' THEN 'Sud-Est'
      WHEN fund_acronym = 'ERDF' AND nuts2_name = 'Sud Vest' THEN 'Sud-Vest Oltenia'
      WHEN fund_acronym = 'ERDF' AND nuts2_name = 'Vest' THEN 'Vest'
      WHEN fund_acronym = 'ERDF' THEN 'nuts1'
      ELSE NULL
    END AS nuts2_name_c
  FROM ro_transactions
),

all_spending AS (
  SELECT
    SUM(eu_cofinancing_amount) AS all_eu
  FROM base
),

spending_beneficiary AS (
  SELECT
    beneficiary,
    SUM(eu_cofinancing_amount) AS eu_cofinancing_amount
  FROM base
  GROUP BY beneficiary
),

top_spenders AS (
  SELECT
    a.beneficiary,
    a.eu_cofinancing_amount / b.all_eu*100.0 AS rate
  FROM spending_beneficiary AS a
  CROSS JOIN all_spending AS b
  WHERE a.eu_cofinancing_amount / b.all_eu*100.0 >= 0.1
),

erdf AS (
  SELECT
    *,
    TRIM(UNNEST(string_to_array(lau2_name,','))) AS lau2_units
  FROM base
  WHERE fund_acronym = 'ERDF'
  AND lau2_name IS NOT NULL
),

erdf_corrected AS (
  SELECT
    *,
    CASE
      WHEN nuts3_name = 'Caras-Severin' AND lau2_units = 'TIMISOARA'  THEN 'Timis'
      WHEN nuts3_name = 'Caras-Severin' THEN 'Caras-Severin'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Bozovici' THEN 'Caras-Severin'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Brad' THEN 'Hunedoara'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Baru Mare' THEN 'Hunedoara'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Caransebes' THEN 'Caras-Severin'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Deva' THEN 'Hunedoara'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Hunedoara' THEN 'Hunedoara'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Ilia' THEN 'Hunedoara'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Lugoj' THEN 'Timiș'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Moldova Noua' THEN 'Caras-Severin'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Orastie' THEN 'Hunedoara'
      WHEN LOWER(UNACCENT(lau2_units)) = 'bucuresti' THEN 'Bucuresti'
      WHEN nuts3_name = 'Bistrita-Nasaud' AND lau2_units = 'Turda' THEN 'Cluj'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Oravita' THEN 'Caras-Severin'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Petrosani' THEN 'Hunedoara'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Resita' THEN 'Caras-Severin'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Sannicolau Mare' THEN 'Timis'
      WHEN nuts3_name = 'Arad' AND lau2_units = 'Timisoara' THEN 'Timis'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'ARAD' THEN 'Arad'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Baru Mare' THEN 'Hunedoara'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Barzava' THEN 'Arad'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Bozovici' THEN 'Caras-Severin'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Brad' THEN 'Hunedoara'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Caransebes' THEN 'Caras-Severin'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Chisineu Cris' THEN 'Arad'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Deva' THEN 'Hunedoara'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Gurahont' THEN 'Arad'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Hunedoara' THEN 'Hunedoara'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Ilia' THEN 'Hunedoara'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Ineu' THEN 'Arad'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Lugoj' THEN 'Timis'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Moldova Noua' THEN 'Caras-Severin'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Orastie' THEN 'Hunedoara'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Oravita' THEN 'Caras-Severin'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Petrosani' THEN 'Hunedoara'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Resita' THEN 'Caras-Severin'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Sannicolau Mare' THEN 'Timis'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Sebis' THEN 'Arad'
      WHEN nuts3_name = 'Arad, Caras-Severin, Hunedoara, Timis' AND lau2_units = 'Timisoara' THEN 'Timis'
      WHEN nuts3_name = 'Arges' AND lau2_units = 'PERSANI' THEN 'Brasov'
      WHEN nuts3_name = 'Arges' AND lau2_units = 'ZARNESTI' THEN 'Brasov'
      WHEN nuts3_name = 'Bihor' AND lau2_units = 'ORAS BAIA SPRIE' THEN 'Maramureș'
      WHEN nuts3_name = 'Bihor' AND lau2_units = 'Tasnad' THEN 'Satu Mare'
      WHEN nuts3_name = 'Botosani' AND lau2_units = 'Buda' THEN 'Buzău'
      WHEN nuts3_name = 'Braila' AND lau2_units = 'BUZAU' THEN 'Buzău'
      WHEN nuts3_name = 'Braila' AND lau2_units IN ('Galati', 'GALATI') THEN 'Galati'
      WHEN nuts3_name = 'Brasov' AND lau2_units = 'MUNICIPIUL ALBA IULIA' THEN 'Alba'
      WHEN nuts3_name = 'Buzau' AND lau2_units = 'Intorsura Buzaului' THEN 'Covasna'
      WHEN LOWER(nuts3_name) = 'covasna' AND lau2_units IN ('SFANTU GHEORGHE','Sfantu Gheorghe', 'MUNICIPIUL SFaNTU GHEORGHE') THEN 'Brasov'
      WHEN nuts3_name = 'Calarasi' AND lau2_units = 'CAMPINA'  THEN 'Prahova'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Baia Mare'  THEN 'Maramures'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Beclean'  THEN 'Brasov'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Beius'  THEN 'Bihor'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Bistrita'  THEN 'Bistrița-Năsăud'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Bogdan Voda'  THEN 'Maramures'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Carei'  THEN 'Satu Mare'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Cehu Silvaniei'  THEN 'Salaj'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Ileanda'  THEN 'Salaj'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Jibou'  THEN 'Salaj'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Marghita'  THEN 'Bihor'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Nasaud'  THEN 'Bistrița-Năsăud'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Negresti Oas'  THEN 'Satu Mare'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Oradea'  THEN 'Bihor'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Prundu Bargaului'  THEN 'Bistrița-Năsăud'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Salonta'  THEN 'Bihor'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Sangeorz-Bai'  THEN 'Bistrița-Năsăud'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Satu Mare'  THEN 'Satu Mare'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Sighetu Marmatiei'  THEN 'Maramureș'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Simleu Silvaniei'  THEN 'Salaj'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Somcuta Mare'  THEN 'Maramureș'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Tasnad'  THEN 'Satu Mare'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Turt'  THEN 'Satu Mare'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Viseu de Sus'  THEN 'Maramureș'
      WHEN nuts3_name = 'Cluj' AND lau2_units = 'Zalau'  THEN 'Salaj'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Adjud'  THEN 'Vrancea'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Babadag'  THEN 'Tulcea'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Beresti'  THEN 'Galati'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Braila'  THEN 'Braila'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Buzau'  THEN 'Buzau'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Crisan'  THEN 'Tulcea'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Faurei'  THEN 'Braila'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Focsani'  THEN 'Vrancea'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Galati'  THEN 'Galati'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Ianca'  THEN 'Braila'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Insuratei'  THEN 'Braila'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Macin'  THEN 'Tulcea'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Maruntisu'  THEN 'Buzau'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'POPESTI LEORDENI'  THEN 'Ilfov'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Panciu'  THEN 'Vrancea'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Ramnicu Sarat'  THEN 'Buzau'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Targu Bujor'  THEN 'Galati'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Tecuci'  THEN 'Galati'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Tulcea'  THEN 'Tulcea'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'Vidra'  THEN 'Vrancea'
      WHEN nuts3_name = 'Covasna' AND lau2_units = 'GHEORGHENI'  THEN 'Harghita'
      WHEN nuts3_name = 'Dambovita' AND lau2_units = 'SINAIA'  THEN 'Prahova'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Baia de Fier'  THEN 'Gorj'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Bals'  THEN 'Iasi'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Brezoi' THEN 'Valcea'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Caracal' THEN 'Olt'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Corabia' THEN 'Olt'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Dragasani' THEN 'Valcea'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Drobeta-Turnu Severin' THEN 'Mehedinți'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Govora' THEN 'Valcea'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Gradistea' THEN 'Valcea'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Hurezani' THEN 'Gorj'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Motru' THEN 'Gorj'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Novaci' THEN 'Gorj'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Orsova' THEN 'Mehedinți'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Osica' THEN 'Olt'
      WHEN nuts3_name = 'Dolj' AND LOWER(lau2_units) = 'ramnicu valcea' THEN 'Valcea'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Scornicesti' THEN 'Olt'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Slatina' THEN 'Olt'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Stoenesti' THEN 'Olt'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Strehaia' THEN 'Mehedinți'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Targu Jiu' THEN 'Gorj'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Turceni' THEN 'Gorj'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Vanju Mare' THEN 'Mehedinți'
      WHEN nuts3_name = 'Giurgiu' AND lau2_units = 'Mogosesti' THEN 'Iasi'
      WHEN nuts3_name = 'Gorj' AND lau2_units = 'CRAIOVA' THEN 'Dolj'
      WHEN nuts3_name = 'HUNEDOARA' AND lau2_units = 'Sat Santandrei' THEN 'Bihor'
      WHEN nuts3_name = 'Hunedoara' AND lau2_units = 'Resita' THEN 'Caras-Severin'
      WHEN nuts3_name = 'Hunedoara' AND lau2_units = 'Straja' THEN 'Suceava'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Bacau' THEN 'Bacau'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Barlad' THEN 'Vaslui'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Botosani' THEN 'Botosani'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Campulung Moldovenesc' THEN 'Suceava'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Dorohoi' THEN 'Botosani'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Falticeni' THEN 'Suceava'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Husi' THEN 'Vaslui'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Moinesti' THEN 'Bacau'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Onesti' THEN 'Bacau'
      WHEN nuts3_name = 'Iasi' AND LOWER(lau2_units) IN ('piatra neamt', 'piatra-neamt') THEN 'Neamt'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Poiana Teiului' THEN 'Neamt'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Radauti' THEN 'Suceava'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Saveni' THEN 'Ialomița'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Slobozia' THEN 'Ialomița'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Stefanesti' THEN 'Botosani'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Suceava' THEN 'Suceava'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Targu Neamt' THEN 'Neamt'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Trusesti' THEN 'Botosani'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Vaslui' THEN 'Vaslui'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'Vatra Dornei' THEN 'Suceava'
      WHEN nuts3_name = 'Iasi - Vaslui' AND lau2_units = 'Ciurea' THEN 'Iasi'
      WHEN nuts3_name = 'Iasi - Vaslui' AND lau2_units = 'Grajduri' THEN 'Iasi'
      WHEN nuts3_name = 'Iasi - Vaslui' AND lau2_units = 'Mogosesti' THEN 'Iasi'
      WHEN nuts3_name = 'Iasi - Vaslui' AND lau2_units = 'Rebricea' THEN 'Vaslui'
      WHEN nuts3_name = 'Iasi - Vaslui' AND lau2_units = 'Scanteia' THEN 'Iasi'
      WHEN nuts3_name = 'Iasi - Vaslui' AND lau2_units = 'Vulturesti' THEN 'Vaslui'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'bacau' THEN 'Bacau'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'bacau' THEN 'Bacau'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'barlad' THEN 'Vaslui'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'botosani' THEN 'Botosani'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'campulung moldovenesc' THEN 'Suceava'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'dorohoi' THEN 'Botosani'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'falticeni' THEN 'Suceava'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'husi' THEN 'Vaslui'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'iasi' THEN 'Iasi'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'moinesti' THEN 'Bacau'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'onesti' THEN 'Bacau'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'oras targu frumos' THEN 'Iasi'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'oras targu neamt' THEN 'Neamt'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'pascani' THEN 'Iasi'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'piatra-neamt' THEN 'Neamt'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'podu turcului' THEN 'Bacau'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'radauti' THEN 'Suceava'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'roman' THEN 'Iasi'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'suceava' THEN 'Suceava'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'targu mures' THEN 'Mures'
      WHEN nuts3_name = 'Iasi, Bacau' AND LOWER(lau2_units) = 'vaslui' THEN 'Vaslui'
      WHEN nuts3_name = 'Maramures' AND LOWER(lau2_units) = 'cluj napoca' THEN 'Cluj'
      WHEN nuts3_name = 'Mehedinti' AND LOWER(lau2_units) = 'craiova' THEN 'Dolj'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'agnita' THEN 'Sibiu'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'aiud' THEN 'Alba'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'alba iulia' THEN 'Alba'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'blaj' THEN 'Alba'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'brasov' THEN 'Brasov'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'campeni' THEN 'Alba'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'fagaras' THEN 'Brasov'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'gheorgheni' THEN 'Harghita'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'intorsura buzaului' THEN 'Covasna'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'medias' THEN 'Sibiu'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'miercurea ciuc' THEN 'Harghita'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'odorheiu secuiesc' THEN 'Harghita'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'predeal' THEN 'Brasov'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'raciu' THEN 'Dambovita'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'sfantu gheorghe' THEN 'Brasov'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'sibiu' THEN 'Sibiu'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'targu secuiesc' THEN 'Covasna'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'toplita' THEN 'Harghita'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'valeni' THEN 'Vaslui'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'victoria' THEN 'Brasov'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'zarnesti' THEN 'Brasov'
      WHEN nuts3_name = 'Neamt' AND LOWER(lau2_units) = 'bacau' THEN 'Bacau'
      WHEN nuts3_name = 'Olt' AND LOWER(lau2_units) = 'pitesti' THEN 'Arges'
      WHEN nuts3_name = 'Olt' AND LOWER(lau2_units) = 'ranca' THEN 'Gorj'
      WHEN nuts3_name = 'Prahova' AND LOWER(lau2_units) = 'brasov' THEN 'Brasov'
      WHEN nuts3_name = 'Prahova' AND LOWER(lau2_units) = 'cornesti' THEN 'Cluj'
      WHEN nuts3_name = 'Prahova' AND LOWER(lau2_units) = 'giurgiu' THEN 'Giurgiu'
      WHEN nuts3_name = 'Prahova' AND LOWER(lau2_units) = 'rasnov' THEN 'Brasov'
      WHEN nuts3_name = 'Salaj' AND LOWER(lau2_units) = 'oradea' THEN 'Bihor'
      WHEN nuts3_name = 'Salaj - Cluj' AND LOWER(lau2_units) = 'ciucea' THEN 'Cluj'
      WHEN nuts3_name = 'Salaj - Cluj' AND LOWER(lau2_units) = 'cizer' THEN 'Salaj'
      WHEN nuts3_name = 'Salaj - Cluj' AND LOWER(lau2_units) = 'crasna' THEN 'Salaj'
      WHEN nuts3_name = 'Salaj - Cluj' AND LOWER(lau2_units) = 'varsolt' THEN 'Salaj'
      WHEN nuts3_name = 'Sibiu' AND LOWER(lau2_units) = 'brasov' THEN 'Brasov'
      WHEN nuts3_name = 'Sibiu' AND LOWER(lau2_units) = 'dumbrava' THEN 'Timis'
      WHEN nuts3_name = 'Sibiu-Alba' AND LOWER(lau2_units) = 'jina' THEN 'Sibiu'
      WHEN nuts3_name = 'Sibiu-Alba' AND LOWER(lau2_units) = 'sugag' THEN 'Alba'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'baicoi' THEN 'Prahova'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'borcea' THEN 'Calarasi'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'budesti' THEN 'Calarasi'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'calarasi' THEN 'Calarasi'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'campina' THEN 'Prahova'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'campulung' THEN 'Arges'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'cheia' THEN 'Prahova'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'boldesti' THEN 'Prahova'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'chiselet' THEN 'Calarasi'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'cornesti' THEN 'Cluj'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'curtea de arges' THEN 'Arges'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'dragalina' THEN 'Calarasi'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'fetesti' THEN 'Ialomita'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'fieni' THEN 'Dambovita'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'gaesti' THEN 'Dambovita'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'gaujani' THEN 'Giurgiu'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'costesti' THEN 'Arges'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'ghimpati' THEN 'Giurgiu'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'giurgiu' THEN 'Giurgiu'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'lehliu gara' THEN 'Calarasi'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'maneciu' THEN 'Prahova'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'mihai bravu' THEN 'Giurgiu'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'mioveni' THEN 'Arges'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'mizil' THEN 'Prahova'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'moreni' THEN 'Dambovita'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'oltenita' THEN 'Calarasi'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'pitesti' THEN 'Arges'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'ploiesti' THEN 'Prahova'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'pucioasa' THEN 'Dambovita'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'racari' THEN 'Dambovita'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'sinaia' THEN 'Prahova'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'tandarei' THEN 'Ialomita'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'targoviste' THEN 'Dambovita'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'titu' THEN 'Dambovita'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'topoloveni' THEN 'Arges'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'urlati' THEN 'Prahova'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'urziceni' THEN 'Ialomita'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'valenii de munte' THEN 'Prahova'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'voinesti' THEN 'Dambovita'
      WHEN nuts3_name = 'Valcea' AND LOWER(lau2_units) = 'izvorul rece' THEN 'Dolj'
      WHEN nuts3_name = 'Vrancea' AND LOWER(lau2_units) = 'onesti' THEN 'Bacau'
      WHEN nuts3_name = 'Vrancea' AND LOWER(lau2_units) = 'unirea' THEN 'Dolj'
      ELSE nuts3_name
    END AS nuts3_name_corr,
    CASE
      WHEN LOWER(UNACCENT(nuts3_name)) = 'bucuresti' THEN 'Bucuresti'
      WHEN lau2_units = 'Baru Mare' THEN 'Baru'
      WHEN lau2_units = 'SAMOVA' THEN 'Somova'
      WHEN lau2_units = 'Chisineu Cris' THEN 'Chisineu-Cris'
      WHEN lau2_units = 'Moftinu' THEN 'Moftin'
      WHEN LOWER(lau2_units) = 'barlad' THEN 'Birlad'
      WHEN lau2_units = 'Bradetu' THEN 'Bradu'
      WHEN lau2_units = 'Campulung Muscel' THEN 'Campulung'
      WHEN LOWER(UNACCENT(lau2_units)) = 'cluj napoca' THEN 'cluj-napoca'
      WHEN nuts3_name = 'Arges' AND lau2_units = 'Golesti' THEN 'Schitu Golesti'
      WHEN nuts3_name = 'Arges' AND lau2_units = 'Molivisu' THEN 'Arefu'
      WHEN nuts3_name = 'Arges' AND lau2_units = 'Poenari' THEN 'Arefu'
      WHEN nuts3_name = 'Arges' AND lau2_units = 'Mun Curtea de Arges' THEN 'Curtea de Arges'
      WHEN nuts3_name = 'Arges' AND lau2_units = 'PERSANI' THEN 'Făgăraş'
      WHEN nuts3_name = 'Arges' AND lau2_units = 'Toploveni' THEN 'Topoloveni'
      WHEN nuts3_name = 'Arges' AND lau2_units = 'VALENI' THEN 'Salatrucu'
      WHEN nuts3_name = 'Arges' AND lau2_units IN ('Valea Mare','Valea Mare - Pravat') THEN 'Valea Mare Pravat'
      WHEN nuts3_name = 'Bihor' AND lau2_units = 'Marghit' THEN 'Marghita'
      WHEN nuts3_name = 'Bihor' AND lau2_units = 'Sacuieni' THEN 'Sacueni'
      WHEN nuts3_name = 'Bistrita-Nasaud' AND lau2_units = 'Bistrita-Nasaud' THEN 'Nasaud'
      WHEN nuts3_name = 'Bistrita-Nasaud' AND lau2_units = 'Petris' THEN 'Cetate'
      WHEN nuts3_name = 'Bistrita-Nasaud' AND lau2_units = 'Susenii Birgaului' THEN 'Prundu Bargaului'
      WHEN nuts3_name = 'Botosani' AND lau2_units = 'Oroftiana' THEN 'Suharau'
      WHEN nuts3_name = 'Botosani' AND lau2_units = 'Padureni' THEN 'Sendriceni'
      WHEN nuts3_name = 'Braila' AND lau2_units = 'Cuza Voda' THEN 'Stancuta'
      WHEN nuts3_name = 'Braila' AND lau2_units = 'Lacu Sarat' THEN 'Chiscani'
      WHEN nuts3_name = 'Braila' AND lau2_units = 'Mihai Bravu' THEN 'Victoria'
      WHEN nuts3_name = 'Buzau' AND lau2_units = 'Valcele' THEN 'Valcelele'
      WHEN lau2_units IN ('Cluj - Napoca','Cluj Napoca','Cluj Napoaca','CLIJ -NAPOCA','NAPOCA') THEN 'Cluj-Napoca'
      WHEN nuts3_name = 'CONSTANTA' AND lau2_units = 'NEPTUN' THEN 'Mangalia'
      WHEN lau2_units IN ('SFANTU GHEORGHE','Sfantu Gheorghe', 'MUNICIPIUL SFaNTU GHEORGHE') THEN 'Sfantul Gheorghe'
      WHEN nuts3_name = 'Calarasi' AND lau2_units = 'Lehliu-Gara' THEN 'Lehliu Gara'
      WHEN lau2_units = 'Negresti Oas' THEN 'Negresti-Oas'
      WHEN nuts3_name = 'Constanta' AND LOWER(lau2_units) = 'eforie sud'  THEN 'Eforie'
      WHEN nuts3_name = 'Constanta' AND lau2_units = 'JUPITER'  THEN 'Mangalia'
      WHEN nuts3_name = 'Constanta' AND LOWER(lau2_units) = 'mamaia'  THEN 'Constanta'
      WHEN nuts3_name = 'Constanta' AND LOWER(lau2_units) = 'maruntisu'  THEN 'Patarlagele'
      WHEN nuts3_name = 'Constanta' AND LOWER(lau2_units) = 'poarta alba - ovidiu'  THEN 'Poarta Alba'
      WHEN nuts3_name = 'Dambovita' AND lau2_units = 'GAIESTI'  THEN 'Gaesti'
      WHEN nuts3_name = 'Dambovita' AND lau2_units IN ('TARGAVISTE','Targosviste') THEN 'Targoviste'
      WHEN nuts3_name = 'Dolj' AND lau2_units = 'Barca' THEN 'Goicea'
      WHEN lau2_units = 'Govora' THEN 'Oras Baile Govora'
      WHEN lau2_units = 'Osica' THEN 'Osica de Jos'
      WHEN nuts3_name = 'Giurgiu' AND lau2_units IN ('Bolintin - Vale','Bolintin Vale') THEN 'Bolintin-Vale'
      WHEN nuts3_name = 'Giurgiu' AND lau2_units = 'Mironesti' THEN 'Gostinari'
      WHEN nuts3_name = 'Giurgiu' AND lau2_units = 'Naipu' THEN 'Ghimpati'
      WHEN nuts3_name = 'Gorj' AND lau2_units = 'BOTOROGI' THEN 'Danesti'
      WHEN nuts3_name = 'Gorj' AND lau2_units = 'Bradiceni' THEN 'Pestisani'
      WHEN nuts3_name = 'Gorj' AND lau2_units = 'Buduhala' THEN 'Telesti'
      WHEN nuts3_name = 'Gorj' AND lau2_units = 'Bumbesti Jiu' THEN 'Bumbesti-Jiu'
      WHEN lau2_units IN ('Dobrita', 'RANCA') THEN 'Runcu'
      WHEN nuts3_name = 'Gorj' AND lau2_units = 'Fintanele' THEN 'Urdari'
      WHEN nuts3_name = 'Gorj' AND lau2_units = 'GORNOVITA' THEN 'Tismana'
      WHEN nuts3_name = 'Gorj' AND lau2_units IN ('TARGU CARBUNESTI', 'Targu - Carbunesti', 'Targu Carbunesti - Ticleni - Balteni', 'Targu-Jiu') THEN 'Targu Jiu'
      WHEN lau2_units = 'Sat Santandrei' THEN 'Santandrei'
      WHEN lau2_units = 'Harghita Bai' THEN 'Miercurea Ciuc'
      WHEN nuts3_name = 'Harghita' AND lau2_units = 'Madarasi' THEN 'Madaras'
      WHEN nuts3_name = 'Harghita' AND lau2_units = 'ODORHEIU SECIUESC' THEN 'Odorheiu Secuiesc'
      WHEN nuts3_name = 'Hunedoara' AND lau2_units IN ('Orastioara', ' Orastioara de Sus') THEN 'Orastioara de Sus'
      WHEN nuts3_name = 'Hunedoara' AND lau2_units = 'Vulcan - pasul Valcan' THEN 'Vulcan'
      WHEN nuts3_name = 'IALOMITA' AND lau2_units = 'Ialomita' THEN 'Slobozia'
      WHEN nuts3_name = 'Iasi' AND lau2_units = 'PODUL ILOAIEI' THEN 'Podu Iloaiei'
      WHEN nuts3_name IN ('Iasi, Bacau', 'Iasi') AND LOWER(lau2_units) = 'roman' THEN 'Romanesti'
      WHEN LOWER(lau2_units) = 'piatra-neamt' THEN 'Piatra Neamt'
      WHEN LOWER(lau2_units) = 'darasti' THEN 'Darasti-Ilfov'
      WHEN nuts3_name = 'Ilfov' AND lau2_units IN('Dragomiresti','Dragomiresti Vale') THEN 'Dragomiresti-Vale'
      WHEN nuts3_name = 'Ilfov' AND lau2_units = 'Popesti-Leordeni' THEN 'Popesti Leordeni'
      WHEN nuts3_name = 'Ilfov' AND lau2_units = 'Saftica' THEN 'Balotesti'
      WHEN nuts3_name = 'Ilfov' AND lau2_units = 'Stefanesti' THEN 'Stefanestii de Jos'
      WHEN nuts3_name = 'Maramures' AND lau2_units = 'Baia-Mare' THEN 'Baia Mare'
      WHEN nuts3_name = 'Maramures' AND lau2_units = 'Copalnic Manastur' THEN 'Copalnic-Manastur'
      WHEN nuts3_name = 'Maramures' AND lau2_units = 'Rohia' THEN 'Targu Lapus'
      WHEN nuts3_name = 'Maramures' AND lau2_units = 'Rozalvea' THEN 'Rozavlea'
      WHEN nuts3_name = 'Maramures' AND lau2_units = 'SIGHETUL MARMATIEI' THEN 'SIGHETU MARMATIEI'
      WHEN nuts3_name = 'Maramures' AND lau2_units = 'Silistea de Sus' THEN 'Salistea de Sus'
      WHEN nuts3_name = 'Maramures' AND LOWER(lau2_units) IN ('tautii magheraus','tautii magherus') THEN 'Tautii-Magheraus'
      WHEN nuts3_name = 'Mehedinti' AND LOWER(lau2_units) = 'crivina' THEN 'Burila Mare'
      WHEN nuts3_name = 'Mehedinti' AND LOWER(lau2_units) IN ('drobeta turnu severin','drobeta turnu-severin', 'turnu severin') THEN 'Drobeta-Turnu Severin'
      WHEN nuts3_name = 'Mehedinti' AND LOWER(lau2_units) = 'izvoru anestilor' THEN 'Izvoru Barzii'
      WHEN nuts3_name = 'Mehedinti' AND LOWER(lau2_units) = 'ostrovu mare' THEN 'Gogosu'
      WHEN nuts3_name = 'Mehedinti' AND LOWER(lau2_units) = 'stignita' THEN 'Poroina Mare'
      WHEN nuts3_name = 'Mures' AND LOWER(lau2_units) = 'ceausu de campie' THEN 'Ceuasu de Campie'
      WHEN LOWER(lau2_units) = 'intorsura buzaului' THEN 'Intorsura Buzaului'
      WHEN LOWER(lau2_units) = 'magherani - sarateni' THEN 'Magherani'
      WHEN LOWER(lau2_units) = 'pagaceaua' THEN 'Pogaceaua'
      WHEN nuts3_name = 'Neamt' AND LOWER(lau2_units) = 'municipiul piatra-neamt' THEN 'Piatra Neamt'
      WHEN nuts3_name = 'Neamt' AND LOWER(lau2_units) = 'oslobeni' THEN 'Bodesti'
      WHEN nuts3_name = 'Olt' AND LOWER(lau2_units) IN ('draganesti','draganesti - olt') THEN 'Draganesti-Olt'
      WHEN LOWER(lau2_units) = 'boldesti scaieni' THEN 'Boldesti-Scaeni'
      WHEN nuts3_name = 'Prahova' AND LOWER(lau2_units) = 'slanic prahova' THEN 'Slanic'
      WHEN nuts3_name = 'Prahova' AND LOWER(lau2_units) IN ('targusoru vechi','targusorul vechi') THEN 'Targsoru Vechi'
      WHEN nuts3_name = 'Prahova' AND LOWER(lau2_units) = 'tatarai' THEN 'Poienarii Burchii'
      WHEN nuts3_name = 'SATU MARE' AND LOWER(lau2_units) = 'satu mate' THEN 'Satu Mare'
      WHEN nuts3_name = 'Salaj' AND LOWER(lau2_units) IN ('orasul simleu silvaniei','simleul silvaniei') THEN 'Oras Simleu Silvaniei'
      WHEN nuts3_name = 'Salaj' AND LOWER(lau2_units) = 'sig' THEN 'Sag'
      WHEN nuts3_name = 'Salaj' AND LOWER(lau2_units) = 'somes odorhei' THEN 'Somes-Odorhei'
      WHEN nuts3_name = 'Satu Mare' AND LOWER(lau2_units) = 'negresti oas' THEN 'Negresti-Oas'
      WHEN nuts3_name = 'Sibiu' AND LOWER(lau2_units) = 'barghis' THEN 'Birghis'
      WHEN nuts3_name = 'Sibiu' AND LOWER(lau2_units) = 'dirlos' THEN 'Darlos'
      WHEN nuts3_name = 'Sibiu' AND LOWER(lau2_units) = 'haghilag' THEN 'Hoghilag'
      WHEN nuts3_name = 'Suceava' AND LOWER(lau2_units) = 'comuna volovat' THEN 'Volovat'
      WHEN nuts3_name = 'Suceava' AND LOWER(lau2_units) = 'dorna arini' THEN 'Dorna-Arini'
      WHEN nuts3_name = 'Suceava' AND LOWER(lau2_units) = 'sv' THEN 'Suceava'
      WHEN nuts3_name = 'Suceava' AND LOWER(lau2_units) = 'sasca mica' THEN 'Cornu Luncii'
      WHEN nuts3_name = 'Suceava' AND LOWER(lau2_units) = 'voronet' THEN 'Gura Humorului'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'boldesti' THEN 'Boldesti-Scaeni'
      WHEN LOWER(lau2_units) = 'cheia' THEN 'Maneciu'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'rosiorii de vede' THEN 'Rosiori de Vede'
      WHEN nuts3_name = 'Teleorman' AND LOWER(lau2_units) = 'slobozia' THEN 'Slobozia Mandra'
      WHEN nuts3_name = 'Valcea' AND LOWER(lau2_units) = 'casa veche-olanu' THEN 'Olanu'
      WHEN nuts3_name = 'Valcea' AND LOWER(lau2_units) = 'madulani' THEN 'Madulari'
      WHEN nuts3_name = 'Valcea' AND LOWER(lau2_units) = 'marita' THEN 'Vaideeni'
      WHEN nuts3_name = 'Valcea' AND LOWER(lau2_units) = 'pausesti-malgasi' THEN 'Pausesti-Maglasi'
      WHEN nuts3_name = 'Valcea' AND LOWER(lau2_units) IN ('rm valcea','valcea') THEN 'Ramnicu Valcea'
      WHEN nuts3_name = 'Valcea' AND LOWER(lau2_units) = 'valcea' THEN 'Ramnicu Valcea'
      WHEN LOWER(lau2_units) = 'izvorul rece' THEN 'Craiova'
      WHEN nuts3_name = 'Vaslui' AND LOWER(lau2_units) = 'drinceni' THEN 'Dranceni'
      WHEN nuts3_name = 'Vaslui' AND LOWER(lau2_units) = 'municipiul barlad' THEN 'Birlad'
      WHEN nuts3_name = 'Vrancea' AND LOWER(lau2_units) = 'virtescoiu' THEN 'Vartescoiu'
      ELSE lau2_units
    END AS lau2_name_corr
  FROM erdf
  WHERE lau2_units != ''
),

erdf_lau2 AS (
  SELECT
    b.transaction_id,
    b.project_name,
    b.beneficiary AS beneficiary_name,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.total_amount_c AS total_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.eu_cofinancing_amount_c AS eu_cofinancing_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.amount_c AS amount,
    'member_state_contribution' AS amount_kind,
    LOWER(UNACCENT(b.beneficiary)) AS beneficiary_id,
    fund_acronym,
    '2007-2013' AS funding_period,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    'Romania' AS country,
    'RO' AS country_code
  FROM erdf_corrected AS b
  LEFT JOIN pre_population As p ON TRIM(REPLACE(REPLACE(UNACCENT(LOWER(p.lau2_name)), 'municipiul',''),'oras ','')) = TRIM(REPLACE(REPLACE(UNACCENT(LOWER(b.lau2_name_corr)), 'municipiul', ''),'oras ',''))
    AND TRIM(REPLACE(LOWER(UNACCENT(p.nuts3_name)),'judetul','')) = TRIM(REPLACE(LOWER(UNACCENT(b.nuts3_name_corr)),'judetul',''))
),

erdf_nuts2 AS (
  SELECT
    b.transaction_id,
    b.project_name,
    b.beneficiary AS beneficiary_name,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.total_amount_c AS total_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.eu_cofinancing_amount_c AS eu_cofinancing_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.amount_c AS amount,
    'member_state_contribution' AS amount_kind,
    LOWER(UNACCENT(b.beneficiary)) AS beneficiary_id,
    fund_acronym,
    '2007-2013' AS funding_period,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    'Romania' AS country,
    'RO' AS country_code
  FROM base AS b
  LEFT JOIN pre_population AS p ON
    CASE
      WHEN b.nuts2_name_c = 'nuts1' THEN 1
      WHEN b.nuts2_name_c = p.nuts2_name THEN 1
      ELSE 0
    END = 1
  WHERE b.fund_acronym = 'ERDF'
    AND b.lau2_name IS NULL
),

esf AS (
  SELECT
    *
  FROM base
  WHERE fund_acronym = 'ESF'
),

esf_nuts1 AS (
  SELECT
    b.transaction_id,
    b.project_name,
    b.beneficiary AS beneficiary_name,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.total_amount_c AS total_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.eu_cofinancing_amount_c AS eu_cofinancing_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.amount_c AS amount,
    'member_state_contribution' AS amount_kind,
    LOWER(UNACCENT(b.beneficiary)) AS beneficiary_id,
    fund_acronym,
    '2007-2013' AS funding_period,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    'Romania' AS country,
    'RO' AS country_code
   FROM esf AS b
   INNER JOIN ro_nuts1_nuts2_translate AS t ON LOWER(UNACCENT(b.beneficiary)) = LOWER(UNACCENT(t.beneficiary))
   CROSS JOIN pre_population AS p
   WHERE t.nuts_level = 'nuts1'
),

esf_nuts2 AS (
  SELECT
    b.transaction_id,
    b.project_name,
    b.beneficiary AS beneficiary_name,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.total_amount_c AS total_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.eu_cofinancing_amount_c AS eu_cofinancing_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.amount_c AS amount,
    'member_state_contribution' AS amount_kind,
    LOWER(UNACCENT(b.beneficiary)) AS beneficiary_id,
    fund_acronym,
    '2007-2013' AS funding_period,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    'Romania' AS country,
    'RO' AS country_code
   FROM esf AS b
   INNER JOIN ro_nuts1_nuts2_translate AS t ON LOWER(UNACCENT(b.beneficiary)) = LOWER(UNACCENT(t.beneficiary))
   INNER JOIN pre_population AS p ON LOWER(UNACCENT(t.nuts_name)) = LOWER(UNACCENT(p.nuts2_name))
   WHERE t.nuts_level = 'nuts2'
),

esf_nuts1_2 AS (
  SELECT DISTINCT transaction_id FROM esf_nuts1
  UNION
  SELECT DISTINCT transaction_id FROM esf_nuts2
),

nuts3_names AS (
  SELECT DISTINCT nuts3_name FROM ro_population
),

esf_nuts3 AS (
  SELECT
    b.transaction_id,
    b.project_name,
    b.beneficiary AS beneficiary_name,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.total_amount_c AS total_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.eu_cofinancing_amount_c AS eu_cofinancing_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.amount_c AS amount,
    'member_state_contribution' AS amount_kind,
    LOWER(UNACCENT(b.beneficiary)) AS beneficiary_id,
    b.fund_acronym,
    '2007-2013' AS funding_period,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    'Romania' AS country,
    'RO' AS country_code
    FROM esf AS b
    INNER JOIN nuts3_names AS n ON
      CASE
        WHEN REPLACE(LOWER(UNACCENT(n.nuts3_name)),'judetul','') = 'olt' AND LOWER(UNACCENT(b.beneficiary)) LIKE CONCAT('% ',REPLACE(LOWER(UNACCENT(n.nuts3_name)),'judetul',''),' %') THEN 1
        WHEN LOWER(UNACCENT(b.beneficiary)) LIKE CONCAT('%',REPLACE(LOWER(UNACCENT(n.nuts3_name)),'judetul',''),'%') THEN 1
        ELSE 0
      END = 1
    INNER JOIN pre_population AS p ON LOWER(UNACCENT(n.nuts3_name)) = LOWER(UNACCENT(p.nuts3_name))
    LEFT JOIN esf_nuts1_2 AS n1 ON b.transaction_id = n1.transaction_id
    WHERE n1.transaction_id IS NULL 
      AND LOWER(UNACCENT(b.beneficiary)) NOT LIKE '%municipiul%'
      AND LOWER(UNACCENT(b.beneficiary)) NOT LIKE '%oras %'
      AND LOWER(UNACCENT(b.beneficiary)) NOT LIKE '%comuna%'
      AND LOWER(UNACCENT(b.beneficiary)) NOT LIKE '%comunei%'
      AND LOWER(UNACCENT(b.beneficiary)) NOT LIKE '%local%'
      AND LOWER(UNACCENT(b.beneficiary)) NOT LIKE 'sc %'
      AND LOWER(UNACCENT(b.beneficiary)) NOT LIKE 's.c.%'
      AND LOWER(UNACCENT(b.beneficiary)) NOT LIKE '%universit%'
      AND LOWER(UNACCENT(b.beneficiary)) NOT LIKE '%s.r.l.%'
),

esf_nuts1_2_3 AS (
  SELECT DISTINCT transaction_id FROM esf_nuts1_2
  UNION
  SELECT DISTINCT transaction_id FROM esf_nuts3
),

national_projects AS (
  SELECT
    a.*
  FROM esf AS a
  LEFT JOIN esf_nuts1_2_3 AS d ON a.transaction_id = d.transaction_id
  WHERE a.program IN ('Sectoral Transport Operational Program', 'Sectoral Operational Program Environment', 'Operational Program Technical Assistance', 'Administrative Capacity Development Operational Program')
    AND d.transaction_id IS NULL
    AND LOWER(UNACCENT(a.beneficiary)) NOT LIKE '%municipiul%'
    AND LOWER(UNACCENT(a.beneficiary)) NOT LIKE '%oras %'
    AND LOWER(UNACCENT(a.beneficiary)) NOT LIKE '%comuna%'
    AND LOWER(UNACCENT(a.beneficiary)) NOT LIKE '%comunei%'
    AND LOWER(UNACCENT(a.beneficiary)) NOT LIKE '%local%'
    AND LOWER(UNACCENT(a.beneficiary)) NOT LIKE 'sc %'
    AND LOWER(UNACCENT(a.beneficiary)) NOT LIKE 's.c.%'
    AND LOWER(UNACCENT(a.beneficiary)) NOT LIKE '%universit%'
    AND LOWER(UNACCENT(a.beneficiary)) NOT LIKE '%s.r.l.%'
),

projects_pre_nuts3 AS (
  SELECT DISTINCT
    a.*,
    n.nuts3_name AS nuts3_pair
  FROM national_projects AS a
  LEFT JOIN nuts3_names AS n ON
  CASE
    WHEN REPLACE(LOWER(UNACCENT(n.nuts3_name)),'judetul','') = 'olt' AND LOWER(UNACCENT(a.project_name)) LIKE CONCAT('% ',REPLACE(LOWER(UNACCENT(n.nuts3_name)),'judetul',''),' %') THEN 1
    WHEN LOWER(UNACCENT(a.project_name)) LIKE CONCAT('%',REPLACE(LOWER(UNACCENT(n.nuts3_name)),'judetul',''),'%') THEN 1
    ELSE 0
  END = 1
),

projects_nuts3 AS (
  SELECT  
    b.transaction_id,
    b.project_name,
    b.beneficiary AS beneficiary_name,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.total_amount_c AS total_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.eu_cofinancing_amount_c AS eu_cofinancing_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.amount_c AS amount,
    'member_state_contribution' AS amount_kind,
    LOWER(UNACCENT(b.beneficiary)) AS beneficiary_id,
    b.fund_acronym,
    '2007-2013' AS funding_period,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    'Romania' AS country,
    'RO' AS country_code
  FROM projects_pre_nuts3 AS b
  INNER JOIN pre_population AS p ON LOWER(UNACCENT(b.nuts3_pair)) = LOWER(UNACCENT(p.nuts3_name))
  WHERE b.nuts3_pair IS NOT NULL
),

projects_nuts1 AS (
  SELECT
    b.transaction_id,
    b.project_name,
    b.beneficiary AS beneficiary_name,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.total_amount_c AS total_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.eu_cofinancing_amount_c AS eu_cofinancing_amount,
    p.population_corr*1.0 / SUM(p.population_corr) OVER (PARTITION BY b.transaction_id)*b.amount_c AS amount,
    'member_state_contribution' AS amount_kind,
    LOWER(UNACCENT(b.beneficiary)) AS beneficiary_id,
    b.fund_acronym,
    '2007-2013' AS funding_period,
    p.nuts1_name AS project_state,
    p.nuts2_name AS project_region,
    p.nuts3_name AS project_county,
    p.nuts3_code AS project_nuts3,
    p.lau2_name AS project_city,
    p.lau2_code AS project_lau2,
    'Romania' AS country,
    'RO' AS country_code
   FROM projects_pre_nuts3 AS b
   INNER JOIN top_spenders AS t ON LOWER(UNACCENT(b.beneficiary)) = LOWER(UNACCENT(t.beneficiary)) 
   CROSS JOIN pre_population AS p
   WHERE b.nuts3_pair IS NULL
),

distributed AS (
  SELECT * FROM erdf_lau2
  UNION ALL
  SELECT * FROM erdf_nuts2
  UNION ALL
  SELECT * FROM esf_nuts1
  UNION ALL
  SELECT * FROM esf_nuts2
  UNION ALL
  SELECT * FROM esf_nuts3
  UNION ALL
  SELECT * FROM projects_nuts3
  UNION ALL
  SELECT * FROM projects_nuts1
),

distributed_ids AS (
  SELECT DISTINCT transaction_id FROM distributed
),

undistributed AS (
  SELECT
    b.transaction_id,
    b.project_name,
    b.beneficiary AS beneficiary_name,
    b.total_amount_c AS total_amount,
    b.eu_cofinancing_amount_c AS eu_cofinancing_amount,
    b.amount_c AS amount,
    'member_state_contribution' AS amount_kind,
    LOWER(UNACCENT(b.beneficiary)) AS beneficiary_id,
    b.fund_acronym,
    '2007-2013' AS funding_period,
    NULL AS project_state,
    NULL AS project_region,
    NULL AS project_county,
    NULL AS project_nuts3,
    NULL AS project_city,
    NULL AS project_lau2,
    'Romania' AS country,
    'RO' AS country_code
  FROM base AS b
  LEFT JOIN distributed_ids AS c ON b.transaction_id = c.transaction_id
  WHERE c.transaction_id IS NULL
),

vw AS (
  SELECT * FROM distributed
  UNION ALL
  SELECT * FROM undistributed
)
SELECT * FROM vw;