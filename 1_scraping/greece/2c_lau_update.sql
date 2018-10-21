UPDATE gr_locations SET lau1_code = sub.lau1_code
FROM (
SELECT p.lau1_code, l.coordinate_id 
FROM gr_locations as l
LEFT JOIN eu_geometry as eg ON 
    (l.project_lat BETWEEN eg.lat_min AND eg.lat_max) 
    AND (l.project_long BETWEEN eg.long_min AND eg.long_max) 
    AND substr(eg.shape_lau,0,3) = 'EL'
LEFT JOIN gr_population AS p ON eg.shape_lau = p.lau2_code
WHERE l.lau1_code is null
    AND l.project_lat IS NOT NULL
    AND st_contains(geojson_geometry, st_point(l.project_long, l.project_lat)) IS TRUE) as sub
WHERE sub.coordinate_id = gr_locations.coordinate_id;