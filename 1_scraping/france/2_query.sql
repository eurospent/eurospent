INSERT INTO final (transaction_id,project_name,beneficiary_name,total_ammount,eu_cofinancing_amount,amount,amount_kind,beneficiary_country_code,beneficiary_id,fund_acronym,funding_period,project_state,project_region,project_county,project_city,project_lau2,geolocation_in_source,distributed)
WITH 
pre_base AS (
	SELECT
		*,
		CASE 
			WHEN loc = 'SEINE-MARITIME / ROUEN / BOIS-GUILLAUME / BIHOREL' THEN 'SEINE-MARITIME / ROUEN / BOIS-GUILLAUME'
			WHEN loc = 'GUADELOUPE / SAINT-MARTIN-SAINT-BARTHELEMY / SAINT-MARTIN-SAINT-BARTHELEMY / SAINT-MARTIN' THEN 'GUADELOUPE'
			ELSE loc
		END AS fixed_loc
	FROM transactions
),

base AS (
	SELECT 
		"row_number"() OVER () AS transaction_id, 
		*,
		CASE fund WHEN 'FED' THEN 'ERDF' WHEN 'FSE' THEN 'ESF' END AS fixed_fund,
		CASE WHEN fixed_loc LIKE '%/%' THEN (string_to_array(fixed_loc, ' / ')) ELSE NULL END as loc_array,
		lower(beneficiary_loc) AS lower_beneficiary_loc,
		unaccent(lower(beneficiary_loc)) AS lower_unaccent_beneficiary_loc
	FROM pre_base
),

translate AS (
	SELECT 
		fr.*, 
		a.arr, 
		a.arr_name,
		p.population::int AS population,
		p.shape_lau,
		lower(fr.lau2_name) AS lower_lau2_name,
		unaccent(lower(fr.lau2_name)) AS lower_unaccent_lau2_name,
		lower(fr.nuts3_name) AS lower_nuts3_name,
		unaccent(lower(fr.nuts3_name)) AS lower_unaccent_nuts3_name
	FROM population AS p
	LEFT join fr_translate AS fr ON fr.lau2 = p.lau 
	LEFT join arr_translate AS a ON fr.lau2 = a.lau2
	WHERE p.shape_lau LIKE 'FR%'
),


can_translate AS (
	SELECT 
		t.*, 
		c.lau1,
		c.lau1_name
	FROM translate AS t
	LEFT join can_translate as c on t.lau2 = c.lau2
),

region_project AS (
	SELECT 
		b.*,
		t.lau2_name,
		t.shape_lau,
		t.population*1.0 / sum(t.population) OVER (PARTITION BY b.transaction_id) AS population_multiplier
	FROM base AS b
	LEFT JOIN translate AS t ON replace(lower(b.fixed_loc),'´','’') = unaccent(lower(t.nuts2_name))
	WHERE fixed_loc NOT LIKE '%/%' AND fixed_loc != '' AND fixed_loc != 'Multilocalisation' AND fixed_loc != 'France' AND fixed_loc != 'HORS FRANCE'
		AND fixed_loc IN (
			'RHONE-ALPES',
			'NORD-PAS-DE-CALAIS',
			'AQUITAINE',
			'PROVENCE-ALPES-COTE D´AZUR',
			'ILE-DE-FRANCE',
			'PAYS DE LA LOIRE',
			'MIDI-PYRENEES',
			'HAUTE-NORMANDIE',
			'LORRAINE',
			'LANGUEDOC-ROUSSILLON',
			'BASSE-NORMANDIE',
			'CENTRE',
			'BRETAGNE',
			'ALSACE',
			'BOURGOGNE',
			'AUVERGNE',
			'POITOU-CHARENTES',
			'CHAMPAGNE-ARDENNE',
			'PICARDIE',
			'LIMOUSIN',
			'FRANCHE-COMTE',
			'CORSE')
),

vw_region_project AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		total_amount * population_multiplier AS total_ammount,
		eu_amount * population_multiplier AS eu_cofinancing_amount,
		eu_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'FR' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_state,
		fixed_loc AS project_region,
		NULL AS project_county,
		lau2_name AS project_city,
		shape_lau AS project_lau2,
		'nuts2' AS geolocation_in_source,
		TRUE AS distributed
	FROM region_project
),

county_project AS (
	SELECT 
		b.*,
		t.lau2_name,
		t.shape_lau,
		t.population*1.0 / sum(t.population) OVER (PARTITION BY b.transaction_id) AS population_multiplier
	FROM base AS b
	LEFT JOIN translate AS t ON replace(lower(b.fixed_loc),'´','’') = unaccent(lower(t.nuts3_name))
	WHERE fixed_loc NOT LIKE '%/%' AND fixed_loc != '' AND fixed_loc != 'Multilocalisation' AND fixed_loc != 'France' AND fixed_loc != 'HORS FRANCE'
		AND fixed_loc NOT IN ('RHONE-ALPES',
			'NORD-PAS-DE-CALAIS',
			'AQUITAINE',
			'PROVENCE-ALPES-COTE D´AZUR',
			'ILE-DE-FRANCE',
			'PAYS DE LA LOIRE',
			'MIDI-PYRENEES',
			'HAUTE-NORMANDIE',
			'LORRAINE',
			'LANGUEDOC-ROUSSILLON',
			'BASSE-NORMANDIE',
			'CENTRE',
			'BRETAGNE',
			'ALSACE',
			'BOURGOGNE',
			'AUVERGNE',
			'POITOU-CHARENTES',
			'CHAMPAGNE-ARDENNE',
			'PICARDIE',
			'LIMOUSIN',
			'FRANCHE-COMTE',
			'CORSE')
),

vw_county_project AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		total_amount * population_multiplier AS total_ammount,
		eu_amount * population_multiplier AS eu_cofinancing_amount,
		eu_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'FR' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_state,
		NULL AS project_region,
		fixed_loc AS project_county,
		lau2_name AS project_city,
		shape_lau AS project_lau2,
		'nuts3' AS geolocation_in_source,
		TRUE AS distributed
	FROM county_project
),

pre_two_length_project AS (
	SELECT 
		*,
		loc_array[1] AS county,
		CASE
			WHEN loc_array[2] = 'SAINT-DIE' THEN 'Saint-Dié-des-Vosges'
			WHEN loc_array[2] = 'CHATEAU-CHINON(VILLE)' THEN 'Château-Chinon (Ville)'
			WHEN loc_array[2] = 'FOUGERES' THEN 'Fougères-Vitré'
			WHEN loc_array[2] = 'MONTMORENCY' THEN 'Sarcelles'
			WHEN loc_array[2] = e'L\' HAY-LES-ROSES' THEN e'L\'Haÿ-les-Roses'
			ELSE loc_array[2]
		END AS arr
	FROM base 
	WHERE fixed_loc LIKE '%/%' AND array_length(loc_array, 1) = 2
),

two_length_project AS (
	SELECT 
		b.*,
		CASE WHEN b.arr = 'SAINT-MARTIN-SAINT-BARTHELEMY' THEN 'GUADELOUPE' ELSE fixed_loc END AS fixed_loc2,
		t.lau2_name,
		t.shape_lau,
		t.population*1.0 / sum(t.population) OVER (PARTITION BY b.transaction_id) AS population_multiplier
	FROM pre_two_length_project AS b
	LEFT JOIN translate AS t 
	ON replace(unaccent(lower(b.county)),'´','’') = unaccent(lower(t.nuts3_name))
	AND (replace(unaccent(lower(b.arr)),'´','’') = unaccent(lower(t.arr_name)) OR b.arr = 'SAINT-MARTIN-SAINT-BARTHELEMY')
),

vw_two_length_project AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		total_amount * population_multiplier AS total_ammount,
		eu_amount * population_multiplier AS eu_cofinancing_amount,
		eu_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'FR' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_state,
		NULL AS project_region,
		fixed_loc2 AS project_county,
		lau2_name AS project_city,
		shape_lau AS project_lau2,
		'nuts3' AS geolocation_in_source,
		TRUE AS distributed
	FROM two_length_project
),

pre_three_length_project AS (
	SELECT 
		*,
		replace(loc_array[1],'´','’') AS county,
		replace(loc_array[2],'´','’') AS arr,
		replace(loc_array[3],'´','’') AS can
	FROM base 
	WHERE fixed_loc LIKE '%/%' AND array_length(loc_array, 1) = 3
),

three_length_project_loc AS (
	SELECT DISTINCT 
		b.transaction_id, t.lau2_name, t.shape_lau, t.population
	FROM pre_three_length_project as b
	LEFT JOIN can_translate AS t 
	ON unaccent(lower(b.county)) = unaccent(lower(t.nuts3_name))
	AND (unaccent(lower(b.can)) = unaccent(lower(t.lau1_name)) 
	  OR unaccent(lower('LE ' || b.can)) = unaccent(lower(t.lau1_name))
	  OR unaccent(lower('LA ' || b.can)) = unaccent(lower(t.lau1_name))
	  OR unaccent(lower('LES ' || b.can)) = unaccent(lower(t.lau1_name))
	  OR unaccent(lower(e'L\'' || b.can)) = unaccent(lower(t.lau1_name))
	  OR trim(replace(replace(unaccent(lower(b.can)), '_canton', ''), '-',' ')) = trim(replace(replace(replace(unaccent(lower(t.lau1_name)), 'canton', ''), '-',' '), '  ', ' '))
	  OR trim(replace(replace(unaccent(lower('LA ' || b.can)), '_canton', ''), '-',' ')) = trim(replace(replace(replace(unaccent(lower(t.lau1_name)), 'canton', ''), '-',' '), '  ', ' '))  
	  OR trim(replace(replace(unaccent(lower('LE ' || b.can)), '_canton', ''), '-',' ')) = trim(replace(replace(replace(unaccent(lower(t.lau1_name)), 'canton', ''), '-',' '), '  ', ' '))      
	  OR (lower(b.can) LIKE 'paris%' AND lower(t.lau1_name) = 'paris')
	  OR (lower(b.can) = 'amiens-1er' AND lower(t.lau1_name) = 'amiens  1er (ouest)')
	  OR (lower(b.can) = 'aimargues' AND lower(t.lau2_name) = 'aimargues')
	  OR (lower(b.can) = 'bastia-6e' AND lower(t.lau1_name) = 'bastia  6e  (canton furiani-montésoro)')
	  OR (lower(b.can) = 'reignier' AND lower(t.lau1_name) = 'reignier-ésery')
	  OR (lower(b.can) = 'octeville' AND lower(t.lau1_name) = 'cherbourg-octeville')
	  OR (lower(b.can) = 'cherbourg' AND lower(t.lau1_name) = 'cherbourg-octeville')
	  OR (lower(b.can) = 'montfort' AND lower(t.lau1_name) = 'montfort-sur-meu')
	  OR (lower(b.can) = 'montauban' AND lower(t.lau1_name) = 'montauban-de-bretagne')
	  OR (lower(b.can) = 'montereau-faut-yonne' AND lower(t.lau1_name) = 'montereau-fault-yonne')
	  OR (lower(b.can) = 'cordes' AND lower(t.lau1_name) = 'cordes-sur-ciel')
	  OR (lower(b.can) = 'chalons-sur-marne' AND lower(t.lau1_name) = 'châlons-en-champagne')
	  OR (lower(b.can) = 'brest-1er' AND lower(t.lau1_name) IN ('brest-plouzané', 'brest-saint-pierre'))
	  OR (lower(b.can) = 'brest-7e' AND lower(t.lau1_name) = 'brest-kerichen')
	  OR (lower(b.can) = 'beaumont' AND lower(t.lau1_name) = 'beaumont-hague')
	  OR (lower(b.can) = e'ile-d\'abeau' AND lower(t.lau1_name) = e'l\'isle-d\'abeau')
	  OR (lower(b.can) = e'l\' etang-sale' AND lower(t.lau1_name) = e'l\'étang-salé')
	  OR (lower(b.can) = 'nay-bourdettes-est' AND lower(t.lau1_name) = 'nay-est')
	  OR (lower(b.can) = 'nay-bourdettes-ouest' AND lower(t.lau1_name) = 'nay-ouest')
	  OR (lower(b.can) = 'vileneuve-sur-lot' AND lower(t.lau1_name) = 'villeneuve-sur-lot')
	)
	where lau1 is not null
),

three_length_project AS (
	SELECT 
		b.*,
		t.lau2_name,
		t.shape_lau,
		t.population*1.0 / sum(t.population) OVER (PARTITION BY b.transaction_id) AS population_multiplier
	FROM pre_three_length_project AS b
	LEFT JOIN three_length_project_loc AS t ON b.transaction_id = t.transaction_id
),

vw_three_length_project AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		total_amount * population_multiplier AS total_ammount,
		eu_amount * population_multiplier AS eu_cofinancing_amount,
		eu_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'FR' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_state,
		NULL AS project_region,
		fixed_loc AS project_county,
		lau2_name AS project_city,
		shape_lau AS project_lau2,
		'lau1' AS geolocation_in_source,
		TRUE AS distributed
	FROM three_length_project
),

pre_four_length_project AS (
	SELECT 
		*,
		replace(loc_array[1],'´','’') AS county,
		replace(loc_array[2],'´','’') AS arr,
		replace(loc_array[3],'´','’') AS can,
		replace(loc_array[4],'´','’') AS city,
		replace(loc_array[5],'´','’') AS dist
	FROM base 
	WHERE fixed_loc LIKE '%/%' AND array_length(loc_array, 1) IN (4,5) AND fixed_loc NOT LIKE '%HORS FRANCE%'
),

four_length_project_loc AS (
	SELECT DISTINCT 
		b.transaction_id, t.lau2_name, t.shape_lau, t.population
	FROM pre_four_length_project as b
	LEFT JOIN translate AS t 
	ON 
	unaccent(lower(b.county)) = unaccent(lower(t.nuts3_name))
	AND (unaccent(lower(b.city)) = unaccent(lower(t.lau2_name))
	 OR (lower(b.city) = 'luc' AND lower(t.lau2_name) = 'luc-la-primaube')
	 OR (lower(b.city) = 'guitalens' AND lower(t.lau2_name) = e'guitalens-l\'albarède')
	 OR (lower(b.city) = 'cherbourg' AND lower(t.lau2_name) = 'cherbourg-octeville')
	 OR (lower(b.city) = 'octeville' AND lower(t.lau2_name) = 'cherbourg-octeville')
	 OR (lower(b.city) = 'laudun' AND lower(t.lau2_name) = e'laudun-l\'ardoise')
	 OR (lower(b.city) = 'le vanneau' AND lower(t.lau2_name) = 'le vanneau-irleau')
	 OR (lower(b.city) = 'charly' AND lower(t.lau2_name) = 'charly-sur-marne')
	 OR (lower(b.city) = 'chatelguyon' AND lower(t.lau2_name) = 'châtel-guyon')
	 OR (lower(b.city) = 'saint-julien' AND lower(t.lau2_name) = 'saint-julien-sur-garonne')
	 OR (lower(b.city) = 'kirrwiller-bosselshausen' AND lower(t.lau2_name) IN ('kirrwiller', 'bosselshausen'))
	 OR (lower(b.city) = 'araches' AND lower(t.lau2_name) = 'arâches-la-frasse')
	 OR (lower(b.city) = 'arnouville-les-gonesse' AND lower(t.lau2_name) = 'arnouville')
	 OR (lower(b.city) = 'tritteling' AND lower(t.lau2_name) = 'tritteling-redlach')
	 OR (lower(b.city) = 'terrasson-la-villedieu' AND lower(t.lau2_name) = 'terrasson-lavilledieu')
	 OR (lower(b.city) = 'saint-pol-sur-mer' AND lower(t.lau2_name) = 'dunkerque')
	 OR (lower(b.city) = 'saint-die' AND lower(t.lau2_name) = 'saint-dié-des-vosges')
	 OR (lower(b.city) = 'reignier' AND lower(t.lau2_name) = 'reignier-esery')
	 OR (lower(b.city) = 'plobannalec' AND lower(t.lau2_name) = 'plobannalec-lesconil')
	 OR (lower(b.city) = 'nueil-sur-argent' AND lower(t.lau2_name) = 'nueil-les-aubiers')
	 OR (lower(b.city) = 'lomme' AND lower(t.lau2_name) = 'lille')
	 OR (lower(b.city) = 'les aubiers' AND lower(t.lau2_name) = 'nueil-les-aubiers')
	 OR (lower(b.city) = 'lentillac-lauzes' AND lower(t.lau2_name) = 'lentillac-du-causse')
	 OR (lower(b.city) = 'fort-mardyck' AND lower(t.lau2_name) = 'dunkerque')
	 OR (lower(b.city) = 'dinsheim' AND lower(t.lau2_name) = 'dinsheim-sur-bruche')
	 OR (lower(b.city) = 'ciriere' AND lower(t.lau2_name) = 'cirières')
	 OR (lower(b.city) = 'boesse' AND lower(t.lau2_name) = 'argenton-les-vallées')
	 OR (lower(b.city) = 'sanzay' AND lower(t.lau2_name) = 'argenton-les-vallées')
	 OR (lower(b.city) = 'chateaurenard' AND lower(t.lau2_name) = 'château-renard')
	)
),

four_length_project AS (
	SELECT 
		b.*,
		t.lau2_name,
		t.shape_lau,
		t.population*1.0 / (CASE WHEN sum(t.population) OVER (PARTITION BY b.transaction_id) != 0 
			THEN sum(t.population) OVER (PARTITION BY b.transaction_id) 
			ELSE count(*) OVER (PARTITION BY b.transaction_id)
		END) AS population_multiplier
	FROM pre_four_length_project AS b
	LEFT JOIN four_length_project_loc AS t ON b.transaction_id = t.transaction_id
),

vw_four_length_project AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		total_amount * population_multiplier AS total_ammount,
		eu_amount * population_multiplier AS eu_cofinancing_amount,
		eu_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'FR' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_state,
		NULL AS project_region,
		county AS project_county,
		lau2_name AS project_city,
		shape_lau AS project_lau2,
		'lau2' AS geolocation_in_source,
		FALSE AS distributed
	FROM four_length_project
),

pre_beneficiary_project AS (
	SELECT 
		*
	FROM base 
	WHERE fixed_loc = '' OR fixed_loc = 'HORS FRANCE' OR fixed_loc LIKE '%HORS FRANCE%' OR 
	fixed_loc = 'Multilocalisation'
),

beneficiary_project_loc AS (
	SELECT DISTINCT
		b.transaction_id, t.lau2_name, t.shape_lau, t.population
	FROM pre_beneficiary_project as b
	INNER JOIN translate AS t ON 
		(b.lower_beneficiary_loc NOT IN ('l etang sale les bains','le molard','le puy st bonnet','modenheim',
			'pigerolles','port cros','riviere salee petit bourg','ste marie','ste rose','tampon 14eme km',
			'templeuve en pevele','terre sainte','zornthal','villehardouin', 'calas', 'charrel', 'cros de cagnes',
			'ile pelee', 'l ile st denis', 'la couronne carro','la fontonne','labuissiere','laxou champleboeuf',
			'le bizet','le cap d agde','le port zup','le puits des mezes','le sambuc','les gresillons','les olives',
			'les praz de chamonix','maxeville champleboeuf','moigne','narbonne plage','notre dame','octeville',
			'pas des lanciers','plascassier','pont rean','port grimaud','rebouillon','romette','sous cote',
			'st denis chaudron', 'denouval','frais marais','st just sur loire','st laurent de la mer',
			'st louis la chaussee','st martin en coailleux','st roman de bellet','st servan sur mer',
			'st sulpice la pointe','st thegonnec loc eguiner','ste pezenne','ste therese','tamaris sur mer',
			'tardais','targe','terrenoire','teteghem coudekerque village','tregomar','trezelan','val d oust','val de briey',
			'valorbiquet','vasouy','vaufrege','vaux warnimont','veyziat','vielaines','vieugy','vigny les paray','vilde la marine',
			'villalbe','ville issey','villeneuve du bosc','villeneuve en perseigne','terre et marais','villeneuve les salines',
			'villeziers','vire normandie','vizzavona','vouel','wesserling','yevre le chatel','fontaine','la garde','le port zup',
			'le port','merignac','orival','st benoit','st savin','venon','villeneuve','warcq','neuvy','vitrolles',
			'villiers le sec','ternay','st leonard','polignac','laval','st paul','st denis','st denis chaudron',
			'beaucaire','mondeville','lesperon','st pierre','st andre','valence','st apollinaire','st apollinaire','st servais',
			'ste luce','rochefort','arques','beaumont','villard','villers le sec','st nicolas la chapelle','sully','savigneux',
			'vouille','vaudeville','bompas','sonnac','st jean le vieux','st juery','sailly','vion','vion','moussey',
			'st pardoux le neuf','vaux','chelles','voisines','dury','desertines','nointel','vesly','senlis','grigny','grigny',
			'st vallier','velennes','perreux','perreux','st prix','st prix','versonnex','villegats','ste catherine','la trinite',
			'le passage','villeroy','st raphael','st cyprien','ste agnes','vallieres','bagneux','st verand','montagnac','fresnes',
			'tremont','moutiers','st pierre des ifs','st laurent des bois','buxerolles','moulins','villedieu','ste reine',
			'st sauvant','poligny','st beauzire','st nazaire','vernon','vaudricourt','villiers','ste christine','st remy',
			'ste genevieve','vineuil','st flour','st martin des champs','vauville','evry','marly','st pere','st ouen',
			'villers bocage','port louis','villereau','warlus','tauriac','vareilles','vieux moulin','chaumont','st eloi','st priest',
			'st priest','viry','st pierre le vieux','st sauveur','vabres','villars','montreuil','massy','torcy','chatillon',
			'la rochelle','vouhe','st projet','vitre','montesquieu','viviers en charnie')
			AND
		
			(b.lower_unaccent_beneficiary_loc = replace(replace(t.lower_unaccent_lau2_name,'-', ' '), e'\'', ' ')
			OR replace(replace(b.lower_unaccent_beneficiary_loc, 'st ', 'saint '), 'ste ', 'sainte ') = replace(replace(t.lower_unaccent_lau2_name,'-', ' '), e'\'', ' ')
			OR (b.lower_unaccent_beneficiary_loc LIKE 'st %' AND 'saint ' || substr(b.lower_unaccent_beneficiary_loc, 4) = trim(replace(replace(t.lower_unaccent_lau2_name,'-', ' '), e'\'', ' ')))
			OR (b.lower_unaccent_beneficiary_loc LIKE 'ste %' AND 'sainte ' || substr(b.lower_unaccent_beneficiary_loc, 5) = trim(replace(replace(t.lower_unaccent_lau2_name,'-', ' '), e'\'', ' ')))
			OR (b.lower_beneficiary_loc LIKE 'paris%' AND t.lower_lau2_name = 'paris')
			OR (b.lower_beneficiary_loc LIKE 'marseille%' AND t.lower_lau2_name = 'marseille')
			OR (b.lower_beneficiary_loc LIKE 'lyon%' AND t.lower_lau2_name = 'lyon')))
		
		OR 
		
		(b.lower_beneficiary_loc IN ('l etang sale les bains','le molard','le puy st bonnet','modenheim',
			'pigerolles','port cros','riviere salee petit bourg','ste marie','ste rose','tampon 14eme km',
			'templeuve en pevele','terre sainte','zornthal','villehardouin', 'calas', 'charrel', 'cros de cagnes',
			'ile pelee', 'l ile st denis', 'la couronne carro','la fontonne','labuissiere','laxou champleboeuf',
			'le bizet','le cap d agde','le port zup','le puits des mezes','le sambuc','les gresillons','les olives',
			'les praz de chamonix','maxeville champleboeuf','moigne','narbonne plage','notre dame','octeville',
			'pas des lanciers','plascassier','pont rean','port grimaud','rebouillon','romette','sous cote',
			'st denis chaudron', 'denouval','frais marais','st just sur loire','st laurent de la mer',
			'st louis la chaussee','st martin en coailleux','st roman de bellet','st servan sur mer',
			'st sulpice la pointe','st thegonnec loc eguiner','ste pezenne','ste therese','tamaris sur mer',
			'tardais','targe','terrenoire','teteghem coudekerque village','tregomar','trezelan','val d oust','val de briey',
			'valorbiquet','vasouy','vaufrege','vaux warnimont','veyziat','vielaines','vieugy','vigny les paray','vilde la marine',
			'villalbe','ville issey','villeneuve du bosc','villeneuve en perseigne','terre et marais','villeneuve les salines',
			'villeziers','vire normandie','vizzavona','vouel','wesserling','yevre le chatel','fontaine','la garde','le port zup',
			'le port','merignac','orival','st benoit','st savin','venon','villeneuve','warcq','neuvy','vitrolles',
			'villiers le sec','ternay','st leonard','polignac','laval','st paul','st denis','st denis chaudron',
			'beaucaire','mondeville','lesperon','st pierre','st andre','valence','st apollinaire','st apollinaire','st servais',
			'ste luce','rochefort','arques','beaumont','villard','villers le sec','st nicolas la chapelle','sully','savigneux',
			'vouille','vaudeville','bompas','sonnac','st jean le vieux','st juery','sailly','vion','vion','moussey',
			'st pardoux le neuf','vaux','chelles','voisines','dury','desertines','nointel','vesly','senlis','grigny','grigny',
			'st vallier','velennes','perreux','perreux','st prix','st prix','versonnex','villegats','ste catherine','la trinite',
			'le passage','villeroy','st raphael','st cyprien','ste agnes','vallieres','bagneux','st verand','montagnac','fresnes',
			'tremont','moutiers','st pierre des ifs','st laurent des bois','buxerolles','moulins','villedieu','ste reine',
			'st sauvant','poligny','st beauzire','st nazaire','vernon','vaudricourt','villiers','ste christine','st remy',
			'ste genevieve','vineuil','st flour','st martin des champs','vauville','evry','marly','st pere','st ouen',
			'villers bocage','port louis','villereau','warlus','tauriac','vareilles','vieux moulin','chaumont','st eloi','st priest',
			'st priest','viry','st pierre le vieux','st sauveur','vabres','villars','montreuil','massy','torcy','chatillon',
			'la rochelle','vouhe','st projet','vitre','montesquieu','viviers en charnie')
			AND
			((b.lower_beneficiary_loc = 'l etang sale les bains' AND t.lower_lau2_name = e'l\' étang-salé')
			OR (b.lower_beneficiary_loc = 'le molard' AND t.lower_lau2_name = 'saint-étienne-le-molard')
			OR (b.lower_beneficiary_loc = 'le puy st bonnet' AND t.lower_lau2_name = 'cholet')
			OR (b.lower_beneficiary_loc = 'modenheim' AND t.lower_lau2_name = 'illzach')
			OR (b.lower_beneficiary_loc = 'viviers en charnie' AND t.lower_lau2_name = 'torcé-viviers-en-charnie')
			OR (b.lower_beneficiary_loc = 'pigerolles' AND t.lower_lau2_name = 'gentioux-pigerolles')
			OR (b.lower_beneficiary_loc = 'port cros' AND t.lower_lau2_name = 'hyères')
			OR (b.lower_beneficiary_loc = 'riviere salee petit bourg' AND t.lower_lau2_name = 'rivière-salée')
			OR (b.lower_beneficiary_loc = 'ste marie' AND t.lower_lau2_name = 'sainte-marie' AND t.lower_nuts3_name = 'réunion')
			OR (b.lower_beneficiary_loc = 'ste rose' AND t.lower_lau2_name = 'sainte-rose' AND t.lower_nuts3_name = 'guadeloupe')
			OR (b.lower_beneficiary_loc = 'tampon 14eme km' AND t.lower_lau2_name = 'le tampon')
			OR (b.lower_beneficiary_loc = 'templeuve en pevele' AND t.lower_lau2_name = 'templeuve')
			OR (b.lower_beneficiary_loc = 'terre sainte' AND t.lower_lau2_name = 'saint-pierre' AND t.lower_nuts3_name = 'réunion')
			OR (b.lower_beneficiary_loc = 'zornthal' AND t.lower_lau2_name = 'schwindratzheim')
			OR (b.lower_beneficiary_loc = 'villehardouin' AND t.lower_lau2_name = e'val-d\'auzon')
			OR (b.lower_beneficiary_loc = 'calas' AND t.lower_lau2_name = 'calais')
			OR (b.lower_beneficiary_loc = 'charrel' AND t.lower_lau2_name = 'charre')
			OR (b.lower_beneficiary_loc = 'cros de cagnes' AND t.lower_lau2_name = 'cagnes-sur-mer')
			OR (b.lower_beneficiary_loc = 'ile pelee' AND t.lower_lau2_name = 'cherbourg-octeville')
			OR (b.lower_beneficiary_loc = 'l ile st denis' AND t.lower_lau2_name = e'l\' île-saint-denis')
			OR (b.lower_beneficiary_loc = 'la couronne carro' AND t.lower_lau2_name = 'martigues')
			OR (b.lower_beneficiary_loc = 'la fontonne' AND t.lower_lau2_name = 'antibes')
			OR (b.lower_beneficiary_loc = 'labuissiere' AND t.lower_lau2_name = 'la buissière')
			OR (b.lower_beneficiary_loc = 'laxou champleboeuf' AND t.lower_lau2_name = 'laxou')
			OR (b.lower_beneficiary_loc = 'le bizet' AND t.lower_lau2_name = 'armentières')
			OR (b.lower_beneficiary_loc = 'le cap d agde' AND t.lower_lau2_name = 'agde')
			OR (b.lower_beneficiary_loc = 'le port zup' AND t.lower_lau2_name = 'le port' AND t.lower_nuts3_name = 'réunion')
			OR (b.lower_beneficiary_loc = 'le puits des mezes' AND t.lower_lau2_name = 'biesles')
			OR (b.lower_beneficiary_loc = 'le sambuc' AND t.lower_lau2_name = 'arles')
			OR (b.lower_beneficiary_loc = 'les gresillons' AND t.lower_lau2_name = 'gennevilliers')
			OR (b.lower_beneficiary_loc = 'les olives' AND t.lower_lau2_name = 'marseille')
			OR (b.lower_beneficiary_loc = 'les praz de chamonix' AND t.lower_lau2_name = 'chamonix-mont-blanc')
			OR (b.lower_beneficiary_loc = 'maxeville champleboeuf' AND t.lower_lau2_name = 'maxéville')
			OR (b.lower_beneficiary_loc = 'moigne' AND t.lower_lau2_name = 'le rheu')
			OR (b.lower_beneficiary_loc = 'narbonne plage' AND t.lower_lau2_name = 'narbonne')
			OR (b.lower_beneficiary_loc = 'notre dame' AND t.lower_lau2_name = 'paris')
			OR (b.lower_beneficiary_loc = 'octeville' AND t.lower_lau2_name = 'cherbourg-octeville')
			OR (b.lower_beneficiary_loc = 'pas des lanciers' AND t.lower_lau2_name = 'marignane')
			OR (b.lower_beneficiary_loc = 'plascassier' AND t.lower_lau2_name = 'grasse')
			OR (b.lower_beneficiary_loc = 'pont rean' AND t.lower_lau2_name = 'bruz')
			OR (b.lower_beneficiary_loc = 'port grimaud' AND t.lower_lau2_name = 'grimaud')
			OR (b.lower_beneficiary_loc = 'rebouillon' AND t.lower_lau2_name = 'châteaudouble' AND t.lower_nuts3_name = 'var')
			OR (b.lower_beneficiary_loc = 'romette' AND t.lower_lau2_name = 'gap')
			OR (b.lower_beneficiary_loc = 'sous cote' AND t.lower_lau2_name = 'pont-évêque')
			OR (b.lower_beneficiary_loc = 'st denis chaudron' AND t.lower_lau2_name = 'saint-denis' AND t.lower_nuts3_name = 'réunion')
			OR (b.lower_beneficiary_loc = 'denouval' AND t.lower_lau2_name = 'andrésy')
			OR (b.lower_beneficiary_loc = 'frais marais' AND t.lower_lau2_name = 'douai')
			OR (b.lower_beneficiary_loc = 'st just sur loire' AND t.lower_lau2_name = 'saint-just-saint-rambert')
			OR (b.lower_beneficiary_loc = 'st laurent de la mer' AND t.lower_lau2_name = 'plérin')
			OR (b.lower_beneficiary_loc = 'st louis la chaussee' AND t.lower_lau2_name = 'saint-louis' AND t.lower_nuts3_name = 'haut-rhin')
			OR (b.lower_beneficiary_loc = 'st martin en coailleux' AND t.lower_lau2_name = 'saint-chamond')
			OR (b.lower_beneficiary_loc = 'st roman de bellet' AND t.lower_lau2_name = 'nice')
			OR (b.lower_beneficiary_loc = 'st servan sur mer' AND t.lower_lau2_name = 'saint-malo')
			OR (b.lower_beneficiary_loc = 'st sulpice la pointe' AND t.lower_lau2_name = 'saint-sulpice' AND t.lower_nuts3_name = 'tarn')
			OR (b.lower_beneficiary_loc = 'st thegonnec loc eguiner' AND t.lower_lau2_name = 'saint-thégonnec')
			OR (b.lower_beneficiary_loc = 'ste pezenne' AND t.lower_lau2_name = 'niort')
			OR (b.lower_beneficiary_loc = 'ste therese' AND t.lower_lau2_name = 'lisieux')
			OR (b.lower_beneficiary_loc = 'tamaris sur mer' AND t.lower_lau2_name = 'la seyne-sur-mer')
			OR (b.lower_beneficiary_loc = 'tardais' AND t.lower_lau2_name = 'senonches')
			OR (b.lower_beneficiary_loc = 'targe' AND t.lower_lau2_name = 'châtellerault')
			OR (b.lower_beneficiary_loc = 'terrenoire' AND t.lower_lau2_name = 'saint-étienne')
			OR (b.lower_beneficiary_loc = 'teteghem coudekerque village' AND t.lower_lau2_name = 'téteghem')
			OR (b.lower_beneficiary_loc = 'tregomar' AND t.lower_lau2_name = 'lamballe')
			OR (b.lower_beneficiary_loc = 'trezelan' AND t.lower_lau2_name = 'bégard')
			OR (b.lower_beneficiary_loc = 'val d oust' AND t.lower_lau2_name = 'le roc-saint-andré')
			OR (b.lower_beneficiary_loc = 'val de briey' AND t.lower_lau2_name = 'briey')
			OR (b.lower_beneficiary_loc = 'valorbiquet' AND t.lower_lau2_name = 'saint-cyr-du-ronceray')
			OR (b.lower_beneficiary_loc = 'vasouy' AND t.lower_lau2_name = 'honfleur')
			OR (b.lower_beneficiary_loc = 'vaufrege' AND t.lower_lau2_name = 'marseille')
			OR (b.lower_beneficiary_loc = 'vaux warnimont' AND t.lower_lau2_name = 'cosnes-et-romain')
			OR (b.lower_beneficiary_loc = 'veyziat' AND t.lower_lau2_name = 'oyonnax')
			OR (b.lower_beneficiary_loc = 'vielaines' AND t.lower_lau2_name = 'rosières-près-troyes')
			OR (b.lower_beneficiary_loc = 'vieugy' AND t.lower_lau2_name = 'seynod')
			OR (b.lower_beneficiary_loc = 'vigny les paray' AND t.lower_lau2_name = 'digoin')
			OR (b.lower_beneficiary_loc = 'vilde la marine' AND t.lower_lau2_name = 'hirel')
			OR (b.lower_beneficiary_loc = 'villalbe' AND t.lower_lau2_name = 'carcassonne')
			OR (b.lower_beneficiary_loc = 'ville issey' AND t.lower_lau2_name = 'euville')
			OR (b.lower_beneficiary_loc = 'villeneuve du bosc' AND t.lower_lau2_name = 'saint-jean-de-verges')
			OR (b.lower_beneficiary_loc = 'villeneuve en perseigne' AND t.lower_lau2_name = 'la fresnaye-sur-chédouet')
			OR (b.lower_beneficiary_loc = 'terre et marais' AND t.lower_lau2_name = 'sainteny')
			OR (b.lower_beneficiary_loc = 'villeneuve les salines' AND t.lower_lau2_name = 'la rochelle' AND t.lower_nuts3_name = 'charente-maritime')
			OR (b.lower_beneficiary_loc = 'villeziers' AND t.lower_lau2_name = 'saint-jean-de-beauregard')
			OR (b.lower_beneficiary_loc = 'vire normandie' AND t.lower_lau2_name = 'vire')
			OR (b.lower_beneficiary_loc = 'vizzavona' AND t.lower_lau2_name = 'vivario')
			OR (b.lower_beneficiary_loc = 'vouel' AND t.lower_lau2_name = 'tergnier')
			OR (b.lower_beneficiary_loc = 'wesserling' AND t.lower_lau2_name = 'husseren-wesserling')
			OR (b.lower_beneficiary_loc = 'yevre le chatel' AND t.lower_lau2_name = 'yèvre-la-ville')
			OR (b.lower_beneficiary_loc = 'fontaine' AND t.lower_lau2_name = 'fontaine' AND t.lower_nuts3_name = 'isère')
			OR (b.lower_beneficiary_loc = 'la garde' AND t.lower_lau2_name = 'la garde' AND t.lower_nuts3_name = 'var')
			OR (b.lower_beneficiary_loc = 'le port zup' AND t.lower_lau2_name = 'le port' AND t.lower_nuts3_name = 'réunion')
			OR (b.lower_beneficiary_loc = 'le port' AND t.lower_lau2_name = 'le port' AND t.lower_nuts3_name = 'réunion')
			OR (b.lower_beneficiary_loc = 'merignac' AND t.lower_lau2_name = 'mérignac' AND t.lower_nuts3_name = 'gironde')
			OR (b.lower_beneficiary_loc = 'orival' AND t.lower_lau2_name = 'orival' AND t.lower_nuts3_name = 'seine-maritime')
			OR (b.lower_beneficiary_loc = 'st benoit' AND t.lower_lau2_name = 'saint-benoît' AND t.lower_nuts3_name = 'réunion')
			OR (b.lower_beneficiary_loc = 'st savin' AND t.lower_lau2_name = 'saint-savin' AND t.lower_nuts3_name = 'isère')
			OR (b.lower_beneficiary_loc = 'venon' AND t.lower_lau2_name = 'venon' AND t.lower_nuts3_name = 'isère')
			OR (b.lower_beneficiary_loc = 'villeneuve' AND t.lower_lau2_name = 'villeneuve' AND t.lower_nuts3_name = 'puy-de-dôme')
			OR (b.lower_beneficiary_loc = 'warcq' AND t.lower_lau2_name = 'warcq' AND t.lower_nuts3_name = 'ardennes')
			OR (b.lower_beneficiary_loc = 'neuvy' AND t.lower_lau2_name = 'neuvy' AND t.lower_nuts3_name = 'allier')
			OR (b.lower_beneficiary_loc = 'vitrolles' AND t.lower_lau2_name = 'vitrolles' AND t.lower_nuts3_name = 'bouches-du-rhône')
			OR (b.lower_beneficiary_loc = 'villiers le sec' AND t.lower_lau2_name = 'villiers-le-sec' AND t.lower_nuts3_name = 'haute-marne')
			OR (b.lower_beneficiary_loc = 'ternay' AND t.lower_lau2_name = 'ternay' AND t.lower_nuts3_name = 'rhône')
			OR (b.lower_beneficiary_loc = 'st leonard' AND t.lower_lau2_name = 'saint-léonard' AND t.lower_nuts3_name = 'pas-de-calais')
			OR (b.lower_beneficiary_loc = 'polignac' AND t.lower_lau2_name = 'polignac' AND t.lower_nuts3_name = 'haute-loire')
			OR (b.lower_beneficiary_loc = 'laval' AND t.lower_lau2_name = 'laval' AND t.lower_nuts3_name = 'mayenne')
			OR (b.lower_beneficiary_loc = 'st paul' AND t.lower_lau2_name = 'saint-paul' AND t.lower_nuts3_name = 'réunion')
			OR (b.lower_beneficiary_loc = 'st denis' AND t.lower_lau2_name = 'saint-denis' AND t.lower_nuts3_name = 'réunion')
			OR (b.lower_beneficiary_loc = 'st denis chaudron' AND t.lower_lau2_name = 'saint-denis' AND t.lower_nuts3_name = 'réunion')
			OR (b.lower_beneficiary_loc = 'beaucaire' AND t.lower_lau2_name = 'beaucaire' AND t.lower_nuts3_name = 'gard')
			OR (b.lower_beneficiary_loc = 'mondeville' AND t.lower_lau2_name = 'mondeville' AND t.lower_nuts3_name = 'calvados')
			OR (b.lower_beneficiary_loc = 'lesperon' AND t.lower_lau2_name = 'lespéron' AND t.lower_nuts3_name = 'ardèche')
			OR (b.lower_beneficiary_loc = 'st pierre' AND t.lower_lau2_name = 'saint-pierre' AND t.lower_nuts3_name = 'alpes-de-haute-provence')
			OR (b.lower_beneficiary_loc = 'st andre' AND t.lower_lau2_name = 'saint-andré' AND t.lower_nuts3_name = 'réunion')
			OR (b.lower_beneficiary_loc = 'valence' AND t.lower_lau2_name = 'valence' AND t.lower_nuts3_name = 'drôme')
			OR (b.lower_beneficiary_loc = 'st apollinaire' AND t.lower_lau2_name = 'saint-apollinaire' AND t.lower_nuts3_name = 'côte-d’or' AND lower(beneficiary_name) LIKE 'syndicat%')
			OR (b.lower_beneficiary_loc = 'st apollinaire' AND t.lower_lau2_name = 'saint-apollinaire' AND t.lower_nuts3_name = 'hautes-alpes' AND lower(beneficiary_name) LIKE 'université%')
			OR (b.lower_beneficiary_loc = 'st servais' AND t.lower_lau2_name = 'saint-servais' AND t.lower_nuts3_name = 'finistère')
			OR (b.lower_beneficiary_loc = 'ste luce' AND t.lower_lau2_name = 'sainte-luce' AND t.lower_nuts3_name = 'martinique')
			OR (b.lower_beneficiary_loc = 'rochefort' AND t.lower_lau2_name = 'rochefort' AND t.lower_nuts3_name = 'charente-maritime')
			OR (b.lower_beneficiary_loc = 'arques' AND t.lower_lau2_name = 'arques' AND t.lower_nuts3_name = 'pas-de-calais')
			OR (b.lower_beneficiary_loc = 'beaumont' AND t.lower_lau2_name = 'beaumont' AND t.lower_nuts3_name = 'puy-de-dôme')
			OR (b.lower_beneficiary_loc = 'villard' AND t.lower_lau2_name = 'villard' AND t.lower_nuts3_name = 'haute-savoie')
			OR (b.lower_beneficiary_loc = 'villers le sec' AND t.lower_lau2_name = 'villers-le-sec' AND t.lower_nuts3_name = 'haute-saône')
			OR (b.lower_beneficiary_loc = 'st nicolas la chapelle' AND t.lower_lau2_name = 'saint-nicolas-la-chapelle' AND t.lower_nuts3_name = 'savoie')
			OR (b.lower_beneficiary_loc = 'sully' AND t.lower_lau2_name = 'sully' AND t.lower_nuts3_name = 'saône-et-loire')
			OR (b.lower_beneficiary_loc = 'savigneux' AND t.lower_lau2_name = 'savigneux' AND t.lower_nuts3_name = 'loire')
			OR (b.lower_beneficiary_loc = 'vouille' AND t.lower_lau2_name = 'vouillé' AND t.lower_nuts3_name = 'deux-sèvres')
			OR (b.lower_beneficiary_loc = 'vaudeville' AND t.lower_lau2_name = 'vaudéville' AND t.lower_nuts3_name = 'vosges')
			OR (b.lower_beneficiary_loc = 'bompas' AND t.lower_lau2_name = 'bompas' AND t.lower_nuts3_name = 'pyrénées-orientales')
			OR (b.lower_beneficiary_loc = 'sonnac' AND t.lower_lau2_name = 'sonnac' AND t.lower_nuts3_name = 'aveyron')
			OR (b.lower_beneficiary_loc = 'st jean le vieux' AND t.lower_lau2_name = 'saint-jean-le-vieux' AND t.lower_nuts3_name = 'isère')
			OR (b.lower_beneficiary_loc = 'st juery' AND t.lower_lau2_name = 'saint-juéry' AND t.lower_nuts3_name = 'tarn')
			OR (b.lower_beneficiary_loc = 'sailly' AND t.lower_lau2_name = 'sailly' AND t.lower_nuts3_name = 'yvelines')
			OR (b.lower_beneficiary_loc = 'vion' AND t.lower_lau2_name = 'vion' AND t.lower_nuts3_name = 'sarthe' AND lower(beneficiary_name) LIKE 'maine%')
			OR (b.lower_beneficiary_loc = 'vion' AND t.lower_lau2_name = 'vion' AND t.lower_nuts3_name = 'ardèche' AND lower(beneficiary_name) LIKE 'association%')
			OR (b.lower_beneficiary_loc = 'moussey' AND t.lower_lau2_name = 'moussey' AND t.lower_nuts3_name = 'moselle')
			OR (b.lower_beneficiary_loc = 'st pardoux le neuf' AND t.lower_lau2_name = 'saint-pardoux-le-neuf' AND t.lower_nuts3_name = 'creuse')
			OR (b.lower_beneficiary_loc = 'vaux' AND t.lower_lau2_name = 'vaux' AND t.lower_nuts3_name = 'allier')
			OR (b.lower_beneficiary_loc = 'chelles' AND t.lower_lau2_name = 'chelles' AND t.lower_nuts3_name = 'seine-et-marne')
			OR (b.lower_beneficiary_loc = 'voisines' AND t.lower_lau2_name = 'voisines' AND t.lower_nuts3_name = 'haute-marne')
			OR (b.lower_beneficiary_loc = 'dury' AND t.lower_lau2_name = 'dury' AND t.lower_nuts3_name = 'somme')
			OR (b.lower_beneficiary_loc = 'desertines' AND t.lower_lau2_name = 'désertines' AND t.lower_nuts3_name = 'allier')
			OR (b.lower_beneficiary_loc = 'nointel' AND t.lower_lau2_name = 'nointel' AND t.lower_nuts3_name = 'oise')
			OR (b.lower_beneficiary_loc = 'vesly' AND t.lower_lau2_name = 'vesly' AND t.lower_nuts3_name = 'manche')
			OR (b.lower_beneficiary_loc = 'senlis' AND t.lower_lau2_name = 'senlis' AND t.lower_nuts3_name = 'oise')
			OR (b.lower_beneficiary_loc = 'grigny' AND t.lower_lau2_name = 'grigny' AND t.lower_nuts3_name = 'rhône' AND (lower(beneficiary_name) LIKE 'les%' OR lower(beneficiary_name) LIKE 'la%' OR lower(beneficiary_name) LIKE 'association%'))
			OR (b.lower_beneficiary_loc = 'grigny' AND t.lower_lau2_name = 'grigny' AND t.lower_nuts3_name = 'essonne' AND (lower(beneficiary_name) LIKE 'groupement%' OR lower(beneficiary_name) LIKE 'boutique%'))
			OR (b.lower_beneficiary_loc = 'st vallier' AND t.lower_lau2_name = 'saint-vallier' AND t.lower_nuts3_name = 'saône-et-loire')
			OR (b.lower_beneficiary_loc = 'velennes' AND t.lower_lau2_name = 'velennes' AND t.lower_nuts3_name = 'oise')
			OR (b.lower_beneficiary_loc = 'perreux' AND t.lower_lau2_name = 'perreux' AND t.lower_nuts3_name = 'loire')
			OR (b.lower_beneficiary_loc = 'perreux' AND t.lower_lau2_name = 'perreux' AND t.lower_nuts3_name = 'loire')
			OR (b.lower_beneficiary_loc = 'st prix' AND t.lower_lau2_name = 'saint-prix' AND t.lower_nuts3_name = 'ardèche' AND lower(beneficiary_name) LIKE 'cefora%')
			OR (b.lower_beneficiary_loc = 'st prix' AND t.lower_lau2_name = 'saint-prix' AND t.lower_nuts3_name = 'val-d’oise' AND lower(beneficiary_name) LIKE 'centre%')
			OR (b.lower_beneficiary_loc = 'versonnex' AND t.lower_lau2_name = 'versonnex' AND t.lower_nuts3_name = 'haute-savoie')
			OR (b.lower_beneficiary_loc = 'villegats' AND t.lower_lau2_name = 'villegats' AND t.lower_nuts3_name = 'charente')
			OR (b.lower_beneficiary_loc = 'ste catherine' AND t.lower_lau2_name = 'sainte-catherine' AND t.lower_nuts3_name = 'pas-de-calais')
			OR (b.lower_beneficiary_loc = 'la trinite' AND t.lower_lau2_name = 'la trinité' AND t.lower_nuts3_name = 'martinique')
			OR (b.lower_beneficiary_loc = 'le passage' AND t.lower_lau2_name = 'le passage' AND t.lower_nuts3_name = 'lot-et-garonne')
			OR (b.lower_beneficiary_loc = 'villeroy' AND t.lower_lau2_name = 'villeroy' AND t.lower_nuts3_name = 'yonne')
			OR (b.lower_beneficiary_loc = 'st raphael' AND t.lower_lau2_name = 'saint-raphaël' AND t.lower_nuts3_name = 'var')
			OR (b.lower_beneficiary_loc = 'st cyprien' AND t.lower_lau2_name = 'saint-cyprien' AND t.lower_nuts3_name = 'loire')
			OR (b.lower_beneficiary_loc = 'ste agnes' AND t.lower_lau2_name = 'sainte-agnès' AND t.lower_nuts3_name = 'alpes-maritimes')
			OR (b.lower_beneficiary_loc = 'vallieres' AND t.lower_lau2_name = 'vallières' AND t.lower_nuts3_name = 'haute-savoie')
			OR (b.lower_beneficiary_loc = 'bagneux' AND t.lower_lau2_name = 'bagneux' AND t.lower_nuts3_name = 'hauts-de-seine')
			OR (b.lower_beneficiary_loc = 'st verand' AND t.lower_lau2_name = 'saint-vérand' AND t.lower_nuts3_name = 'isère')
			OR (b.lower_beneficiary_loc = 'montagnac' AND t.lower_lau2_name = 'montagnac' AND t.lower_nuts3_name = 'hérault')
			OR (b.lower_beneficiary_loc = 'fresnes' AND t.lower_lau2_name = 'fresnes' AND t.lower_nuts3_name = 'val-de-marne')
			OR (b.lower_beneficiary_loc = 'tremont' AND t.lower_lau2_name = 'trémont' AND t.lower_nuts3_name = 'maine-et-loire')
			OR (b.lower_beneficiary_loc = 'moutiers' AND t.lower_lau2_name = 'moutiers' AND t.lower_nuts3_name = 'meurthe-et-moselle')
			OR (b.lower_beneficiary_loc = 'st pierre des ifs' AND t.lower_lau2_name = 'saint-pierre-des-ifs' AND t.lower_nuts3_name = 'calvados')
			OR (b.lower_beneficiary_loc = 'st laurent des bois' AND t.lower_lau2_name = 'saint-laurent-des-bois' AND t.lower_nuts3_name = 'eure')
			OR (b.lower_beneficiary_loc = 'buxerolles' AND t.lower_lau2_name = 'buxerolles' AND t.lower_nuts3_name = 'vienne')
			OR (b.lower_beneficiary_loc = 'moulins' AND t.lower_lau2_name = 'moulins' AND t.lower_nuts3_name = 'allier')
			OR (b.lower_beneficiary_loc = 'villedieu' AND t.lower_lau2_name = 'villedieu' AND t.lower_nuts3_name = 'cantal')
			OR (b.lower_beneficiary_loc = 'ste reine' AND t.lower_lau2_name = 'sainte-reine' AND t.lower_nuts3_name = 'savoie')
			OR (b.lower_beneficiary_loc = 'st sauvant' AND t.lower_lau2_name = 'saint-sauvant' AND t.lower_nuts3_name = 'vienne')
			OR (b.lower_beneficiary_loc = 'poligny' AND t.lower_lau2_name = 'poligny' AND t.lower_nuts3_name = 'jura')
			OR (b.lower_beneficiary_loc = 'st beauzire' AND t.lower_lau2_name = 'saint-beauzire' AND t.lower_nuts3_name = 'puy-de-dôme')
			OR (b.lower_beneficiary_loc = 'st nazaire' AND t.lower_lau2_name = 'saint-nazaire' AND t.lower_nuts3_name = 'loire-atlantique')
			OR (b.lower_beneficiary_loc = 'vernon' AND t.lower_lau2_name = 'vernon' AND t.lower_nuts3_name = 'eure')
			OR (b.lower_beneficiary_loc = 'vaudricourt' AND t.lower_lau2_name = 'vaudricourt' AND t.lower_nuts3_name = 'somme')
			OR (b.lower_beneficiary_loc = 'villiers' AND t.lower_lau2_name = 'villiers' AND t.lower_nuts3_name = 'indre')
			OR (b.lower_beneficiary_loc = 'ste christine' AND t.lower_lau2_name = 'sainte-christine' AND t.lower_nuts3_name = 'puy-de-dôme')
			OR (b.lower_beneficiary_loc = 'st remy' AND t.lower_lau2_name = 'saint-rémy' AND t.lower_nuts3_name = 'saône-et-loire')
			OR (b.lower_beneficiary_loc = 'ste genevieve' AND t.lower_lau2_name = 'sainte-geneviève' AND t.lower_nuts3_name = 'seine-maritime')
			OR (b.lower_beneficiary_loc = 'vineuil' AND t.lower_lau2_name = 'vineuil' AND t.lower_nuts3_name = 'loir-et-cher')
			OR (b.lower_beneficiary_loc = 'st flour' AND t.lower_lau2_name = 'saint-flour' AND t.lower_nuts3_name = 'cantal')
			OR (b.lower_beneficiary_loc = 'st martin des champs' AND t.lower_lau2_name = 'saint-martin-des-champs' AND t.lower_nuts3_name = 'finistère')
			OR (b.lower_beneficiary_loc = 'vauville' AND t.lower_lau2_name = 'vauville' AND t.lower_nuts3_name = 'manche')
			OR (b.lower_beneficiary_loc = 'evry' AND t.lower_lau2_name = 'évry' AND t.lower_nuts3_name = 'essonne')
			OR (b.lower_beneficiary_loc = 'marly' AND t.lower_lau2_name = 'marly' AND t.lower_nuts3_name = 'nord')
			OR (b.lower_beneficiary_loc = 'st pere' AND t.lower_lau2_name = 'saint-père' AND t.lower_nuts3_name = 'nièvre')
			OR (b.lower_beneficiary_loc = 'st ouen' AND t.lower_lau2_name = 'saint-ouen' AND t.lower_nuts3_name = 'seine-saint-denis')
			OR (b.lower_beneficiary_loc = 'villers bocage' AND t.lower_lau2_name = 'villers-bocage' AND t.lower_nuts3_name = 'somme')
			OR (b.lower_beneficiary_loc = 'port louis' AND t.lower_lau2_name = 'port-louis' AND t.lower_nuts3_name = 'guadeloupe')
			OR (b.lower_beneficiary_loc = 'villereau' AND t.lower_lau2_name = 'villereau' AND t.lower_nuts3_name = 'loiret')
			OR (b.lower_beneficiary_loc = 'warlus' AND t.lower_lau2_name = 'warlus' AND t.lower_nuts3_name = 'pas-de-calais')
			OR (b.lower_beneficiary_loc = 'tauriac' AND t.lower_lau2_name = 'tauriac' AND t.lower_nuts3_name = 'tarn')
			OR (b.lower_beneficiary_loc = 'vareilles' AND t.lower_lau2_name = 'vareilles' AND t.lower_nuts3_name = 'creuse')
			OR (b.lower_beneficiary_loc = 'vieux moulin' AND t.lower_lau2_name = 'vieux-moulin' AND t.lower_nuts3_name = 'vosges')
			OR (b.lower_beneficiary_loc = 'chaumont' AND t.lower_lau2_name = 'chaumont' AND t.lower_nuts3_name = 'haute-marne')
			OR (b.lower_beneficiary_loc = 'st eloi' AND t.lower_lau2_name = 'saint-éloi' AND t.lower_nuts3_name = 'nièvre')
			OR (b.lower_beneficiary_loc = 'st priest' AND t.lower_lau2_name = 'saint-priest' AND t.lower_nuts3_name = 'rhône' AND lower(beneficiary_name) LIKE 'association%')
			OR (b.lower_beneficiary_loc = 'st priest' AND t.lower_lau2_name = 'saint-priest' AND t.lower_nuts3_name = 'creuse' AND lower(beneficiary_name) LIKE 'communauté%')
			OR (b.lower_beneficiary_loc = 'viry' AND t.lower_lau2_name = 'viry' AND t.lower_nuts3_name = 'saône-et-loire')
			OR (b.lower_beneficiary_loc = 'st pierre le vieux' AND t.lower_lau2_name = 'saint-pierre-le-vieux' AND t.lower_nuts3_name = 'lozère')
			OR (b.lower_beneficiary_loc = 'st sauveur' AND t.lower_lau2_name = 'saint-sauveur' AND t.lower_nuts3_name = 'hautes-alpes')
			OR (b.lower_beneficiary_loc = 'vabres' AND t.lower_lau2_name = 'vabres' AND t.lower_nuts3_name = 'gard')
			OR (b.lower_beneficiary_loc = 'villars' AND t.lower_lau2_name = 'villars' AND t.lower_nuts3_name = 'vaucluse')
			OR (b.lower_beneficiary_loc = 'montreuil' AND t.lower_lau2_name = 'montreuil' AND t.lower_nuts3_name = 'seine-saint-denis')
			OR (b.lower_beneficiary_loc = 'massy' AND t.lower_lau2_name = 'massy' AND t.lower_nuts3_name = 'essonne')
			OR (b.lower_beneficiary_loc = 'torcy' AND t.lower_lau2_name = 'torcy' AND t.lower_nuts3_name = 'saône-et-loire' AND (lower(beneficiary_name) LIKE 'les%' OR lower(beneficiary_name) LIKE 'régie%'))
			OR (b.lower_beneficiary_loc = 'torcy' AND t.lower_lau2_name = 'torcy' AND t.lower_nuts3_name = 'seine-et-marne' AND lower(beneficiary_name) LIKE 'mission%')
			OR (b.lower_beneficiary_loc = 'chatillon' AND t.lower_lau2_name = 'châtillon' AND t.lower_nuts3_name = 'hauts-de-seine')
			OR (b.lower_beneficiary_loc = 'la rochelle' AND t.lower_lau2_name = 'la rochelle' AND t.lower_nuts3_name = 'charente-maritime')
			OR (b.lower_beneficiary_loc = 'vouhe' AND t.lower_lau2_name = 'vouhé' AND t.lower_nuts3_name = 'charente-maritime' AND lower(beneficiary_name) LIKE 'api%')
			OR (b.lower_beneficiary_loc = 'vouhe' AND t.lower_lau2_name = 'vouhé' AND t.lower_nuts3_name = 'deux-sèvres' AND lower(beneficiary_name) LIKE 'a.i.c.%')
			OR (b.lower_beneficiary_loc = 'st projet' AND t.lower_lau2_name = 'saint-projet' AND t.lower_nuts3_name = 'lot' AND (lower(beneficiary_name) LIKE 'communaute%' OR lower(beneficiary_name) LIKE 'mairie%'))
			OR (b.lower_beneficiary_loc = 'st projet' AND t.lower_lau2_name = 'saint-projet' AND t.lower_nuts3_name = 'tarn-et-garonne' AND lower(beneficiary_name) LIKE 'association%')
			OR (b.lower_beneficiary_loc = 'vitre' AND t.lower_lau2_name = 'vitré' AND t.lower_nuts3_name = 'ille-et-vilaine')
			OR (b.lower_beneficiary_loc = 'montesquieu' AND t.lower_lau2_name = 'montesquieu-volvestre' AND t.lower_nuts3_name = 'haute-garonne')
			))
	--WHERE t.lau2 IS NOT NULL
),

beneficiary_project AS (
	SELECT 
		b.*,
		t.lau2_name,
		t.shape_lau,
		t.population*1.0 / sum(t.population) OVER (PARTITION BY b.transaction_id) AS population_multiplier
	FROM pre_beneficiary_project AS b
	LEFT JOIN beneficiary_project_loc AS t ON b.transaction_id = t.transaction_id
),

vw_beneficiary_project AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		total_amount * population_multiplier AS total_ammount,
		eu_amount * population_multiplier AS eu_cofinancing_amount,
		eu_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'FR' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		NULL AS project_state,
		NULL AS project_region,
		NULL AS project_county,
		lau2_name AS project_city,
		shape_lau AS project_lau2,
		'lau2' AS geolocation_in_source,
		FALSE AS distributed
	FROM beneficiary_project
),

country_project AS (
	SELECT 
		b.*,
		t.lau2_name,
		t.shape_lau,
		t.population*1.0 / sum(t.population) OVER (PARTITION BY b.transaction_id) AS population_multiplier
	FROM base as b
	CROSS JOIN translate AS t
	WHERE fixed_loc = 'France' 
),

vw_country_project AS (
	SELECT
		transaction_id,
		project_name,
		beneficiary_name,
		total_amount * population_multiplier AS total_ammount,
		eu_amount * population_multiplier AS eu_cofinancing_amount,
		eu_amount * population_multiplier AS amount,
		'eu_cofinancing_amount' AS amount_kind,
		'FR' AS beneficiary_country_code,
		beneficiary_name AS beneficiary_id,
		fixed_fund AS fund_acronym,
		'2007-2013' AS funding_period,
		'France' AS project_state,
		NULL AS project_region,
		NULL AS project_county,
		lau2_name AS project_city,
		shape_lau AS project_lau2,
		'national' AS geolocation_in_source,
		TRUE AS distributed
	FROM country_project
)

--select * from vw_region_project;
--select * from vw_county_project;
--select * from vw_two_length_project;
--select * from vw_three_length_project;
--select * from vw_four_length_project;
--select * from vw_beneficiary_project;
--select * from vw_country_project;