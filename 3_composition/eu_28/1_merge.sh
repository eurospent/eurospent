echo 'country_code,code,sum' > 2_lau2.csv

for i in ../*/result.csv; do
	tail -n+2 $i >> 2_lau2.csv
done