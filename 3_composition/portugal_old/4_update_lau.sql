UPDATE beneficiary_geocode SET lau = sub.shape_lau
FROM (
SELECT eg.shape_lau, eg.lau, g.id 
FROM beneficiary_geocode as g
LEFT JOIN eu_geometry as eg on 
    (g.result_lat BETWEEN eg.lat_min AND eg.lat_max) 
    AND (g.result_long BETWEEN eg.long_min AND eg.long_max) 
    AND substr(eg.shape_lau,0,3) = query_country_code
WHERE g.lau is null 
	AND result_lat IS NOT NULL
    AND g.query_country = 'Portugal' 
    AND st_contains(geojson_geometry, st_point(result_long, result_lat)) IS TRUE) as sub
WHERE sub.id = beneficiary_geocode.id;