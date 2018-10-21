color: generate
	python3 generate_style.py -i ./low_resolution/nuts0/2_result.csv -c 28 -g N0T -o ./low_resolution/nuts0/4_result/N0T
	python3 generate_style.py -i ./low_resolution/nuts1/2_result.csv -c 28 -g N1T -o ./low_resolution/nuts1/4_result/N1T
	python3 generate_style.py -i ./low_resolution/nuts2/2_result.csv -c 28 -g N2T -o ./low_resolution/nuts2/4_result/N2T
	python3 generate_style.py -i ./low_resolution/nuts3/2_result.csv -c 28 -g N3T -o ./low_resolution/nuts3/4_result/N3T
	python3 generate_style.py -i ./low_resolution/lau1/2_result.csv -c 28 -g L1T -o ./low_resolution/lau1/4_result/L1T
	python3 generate_style.py -i ./low_resolution/lau2/2_result.csv -c 28 -g L2T -o ./low_resolution/lau2/4_result/L2T

generate: convert
	tippecanoe -P -f -o N0T.mbtiles -Z0 -z8 -D9 -m9 --grid-low-zooms --no-polygon-splitting -y A -y T -ab -pf ./low_resolution/nuts0/4_result/N0T.json
	rm -rf ./low_resolution/nuts0/4_result/N0T.json
	mv N0T.mbtiles ./low_resolution/nuts0/4_result/N0T.mbtiles

	tippecanoe -P -f -o N1T.mbtiles -Z0 -z8 -D9 -m9 --grid-low-zooms --no-polygon-splitting -y A -y T -ab -pf ./low_resolution/nuts1/4_result/N1T.json
	rm -rf ./low_resolution/nuts1/4_result/N1T.json
	mv N1T.mbtiles ./low_resolution/nuts1/4_result/N1T.mbtiles

	tippecanoe -P -f -o N2T.mbtiles -Z0 -z8 -D9 -m9 --grid-low-zooms --no-polygon-splitting -y A -y T -ab -pf ./low_resolution/nuts2/4_result/N2T.json
	rm -rf ./low_resolution/nuts2/4_result/N2T.json
	mv N2T.mbtiles ./low_resolution/nuts2/4_result/N2T.mbtiles

	tippecanoe -P -f -o N3T.mbtiles -Z0 -z8 -D9 -m9 --grid-low-zooms --no-polygon-splitting -y A -y T -ab -pf ./low_resolution/nuts3/4_result/N3T.json
	rm -rf ./low_resolution/nuts3/4_result/N3T.json
	mv N3T.mbtiles ./low_resolution/nuts3/4_result/N3T.mbtiles

	tippecanoe -P -f -o L1T.mbtiles -Z0 -z8 -D9 -m9 --grid-low-zooms --no-polygon-splitting -y A -y T -ab -pf ./low_resolution/lau1/4_result/L1T.json
	rm -rf ./low_resolution/lau1/4_result/L1T.json
	mv L1T.mbtiles ./low_resolution/lau1/4_result/L1T.mbtiles

	tippecanoe -P -f -o L2T.mbtiles -Z0 -z8 -D9 -m9 --grid-low-zooms --no-polygon-splitting -y A -y T -M660000 -ab -pf ./low_resolution/lau2/4_result/L2T.json
	rm -rf ./low_resolution/lau2/4_result/L2T.json
	mv L2T.mbtiles ./low_resolution/lau2/4_result/L2T.mbtiles

convert: pair
	mapshaper ./low_resolution/nuts0/4_result/*.shp -o ./low_resolution/nuts0/4_result format=geojson
	mapshaper ./low_resolution/nuts1/4_result/*.shp -o ./low_resolution/nuts1/4_result format=geojson
	mapshaper ./low_resolution/nuts2/4_result/*.shp -o ./low_resolution/nuts2/4_result format=geojson
	mapshaper ./low_resolution/nuts3/4_result/*.shp -o ./low_resolution/nuts3/4_result format=geojson
	mapshaper ./low_resolution/lau1/4_result/*.shp -o ./low_resolution/lau1/4_result format=geojson
	mapshaper ./low_resolution/lau2/4_result/*.shp -o ./low_resolution/lau2/4_result format=geojson

	rm -rf ./low_resolution/nuts0/4_result/*.dbf
	rm -rf ./low_resolution/nuts0/4_result/*.shp
	rm -rf ./low_resolution/nuts0/4_result/*.prj
	rm -rf ./low_resolution/nuts0/4_result/*.shx

	rm -rf ./low_resolution/nuts1/4_result/*.dbf
	rm -rf ./low_resolution/nuts1/4_result/*.shp
	rm -rf ./low_resolution/nuts1/4_result/*.prj
	rm -rf ./low_resolution/nuts1/4_result/*.shx

	rm -rf ./low_resolution/nuts2/4_result/*.dbf
	rm -rf ./low_resolution/nuts2/4_result/*.shp
	rm -rf ./low_resolution/nuts2/4_result/*.prj
	rm -rf ./low_resolution/nuts2/4_result/*.shx

	rm -rf ./low_resolution/nuts3/4_result/*.dbf
	rm -rf ./low_resolution/nuts3/4_result/*.shp
	rm -rf ./low_resolution/nuts3/4_result/*.prj
	rm -rf ./low_resolution/nuts3/4_result/*.shx

	rm -rf ./low_resolution/lau1/4_result/*.dbf
	rm -rf ./low_resolution/lau1/4_result/*.shp
	rm -rf ./low_resolution/lau1/4_result/*.prj
	rm -rf ./low_resolution/lau1/4_result/*.shx

	rm -rf ./low_resolution/lau2/4_result/*.dbf
	rm -rf ./low_resolution/lau2/4_result/*.shp
	rm -rf ./low_resolution/lau2/4_result/*.prj
	rm -rf ./low_resolution/lau2/4_result/*.shx

pair: scaffold
	cp ./low_resolution/nuts0/3_geometry/EU7.prj ./low_resolution/nuts0/4_result/N0T.prj
	cp ./low_resolution/nuts0//3_geometry/EU7.shp ./low_resolution/nuts0/4_result/N0T.shp
	cp ./low_resolution/nuts0//3_geometry/EU7.shx ./low_resolution/nuts0/4_result/N0T.shx
	python3 pair_transactions.py -i ./low_resolution/nuts0/2_result.csv -d ./low_resolution/nuts0//3_geometry/EU7.dbf -o ./low_resolution/nuts0/4_result/N0T

	cp ./low_resolution/nuts1/3_geometry/EU7.prj ./low_resolution/nuts1/4_result/N1T.prj
	cp ./low_resolution/nuts1/3_geometry/EU7.shp ./low_resolution/nuts1/4_result/N1T.shp
	cp ./low_resolution/nuts1/3_geometry/EU7.shx ./low_resolution/nuts1/4_result/N1T.shx
	python3 pair_transactions.py -i ./low_resolution/nuts1/2_result.csv -d ./low_resolution/nuts1/3_geometry/EU7.dbf -o ./low_resolution/nuts1/4_result/N1T

	cp ./low_resolution/nuts2/3_geometry/EU7.prj ./low_resolution/nuts2/4_result/N2T.prj
	cp ./low_resolution/nuts2/3_geometry/EU7.shp ./low_resolution/nuts2/4_result/N2T.shp
	cp ./low_resolution/nuts2/3_geometry/EU7.shx ./low_resolution/nuts2/4_result/N2T.shx
	python3 pair_transactions.py -i ./low_resolution/nuts2/2_result.csv -d ./low_resolution/nuts2/3_geometry/EU7.dbf -o ./low_resolution/nuts2/4_result/N2T

	cp ./low_resolution/nuts3/3_geometry/EU7.prj ./low_resolution/nuts3/4_result/N3T.prj
	cp ./low_resolution/nuts3/3_geometry/EU7.shp ./low_resolution/nuts3/4_result/N3T.shp
	cp ./low_resolution/nuts3/3_geometry/EU7.shx ./low_resolution/nuts3/4_result/N3T.shx
	python3 pair_transactions.py -i ./low_resolution/nuts3/2_result.csv -d ./low_resolution/nuts3/3_geometry/EU7.dbf -o ./low_resolution/nuts3/4_result/N3T

	cp ./low_resolution/lau1/3_geometry/EU7.prj ./low_resolution/lau1/4_result/L1T.prj
	cp ./low_resolution/lau1/3_geometry/EU7.shp ./low_resolution/lau1/4_result/L1T.shp
	cp ./low_resolution/lau1/3_geometry/EU7.shx ./low_resolution/lau1/4_result/L1T.shx
	python3 pair_transactions.py -i ./low_resolution/lau1/2_result.csv -d ./low_resolution/lau1/3_geometry/EU7.dbf -o ./low_resolution/lau1/4_result/L1T

	cp ./low_resolution/lau2/3_geometry/EU7.prj ./low_resolution/lau2/4_result/L2T.prj
	cp ./low_resolution/lau2/3_geometry/EU7.shp ./low_resolution/lau2/4_result/L2T.shp
	cp ./low_resolution/lau2/3_geometry/EU7.shx ./low_resolution/lau2/4_result/L2T.shx
	python3 pair_transactions.py -i ./low_resolution/lau2/2_result.csv -d ./low_resolution/lau2/3_geometry/EU7.dbf -o ./low_resolution/lau2/4_result/L2T

scaffold: nuke
	mkdir ./low_resolution/nuts0/4_result
	mkdir ./low_resolution/nuts1/4_result
	mkdir ./low_resolution/nuts2/4_result
	mkdir ./low_resolution/nuts3/4_result
	mkdir ./low_resolution/lau1/4_result
	mkdir ./low_resolution/lau2/4_result

nuke:
	rm -rf ./low_resolution/nuts0/4_result
	rm -rf ./low_resolution/nuts1/4_result
	rm -rf ./low_resolution/nuts2/4_result
	rm -rf ./low_resolution/nuts3/4_result
	rm -rf ./low_resolution/lau1/4_result
	rm -rf ./low_resolution/lau2/4_result
