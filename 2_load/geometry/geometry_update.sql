ALTER TABLE eu_geometry ADD geojson_geometry public.geometry;
ALTER TABLE eu_geometry ADD lat_min float4;
ALTER TABLE eu_geometry ADD lat_max float4;
ALTER TABLE eu_geometry ADD long_min float4;
ALTER TABLE eu_geometry ADD long_max float4;

UPDATE eu_geometry 
SET geojson_geometry = ST_GeomFromGeoJSON(geojson);

UPDATE eu_geometry 
SET 
lat_min = st_ymin((geojson_geometry)), 
lat_max = st_ymax((geojson_geometry)),
long_min = st_xmin((geojson_geometry)),
long_max = st_xmax((geojson_geometry));