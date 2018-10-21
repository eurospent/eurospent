#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
USAGE: python3 2_ee_clean.py
'''

import csv
import sys

lau2_nuts3 = {}
test = []
final = {}

with open('2_ee_population.csv', 'r+', encoding='UTF-8', newline='') as f:
	reader = csv.reader(f)
	for row in reader:
		lau2_nuts3[row[8]] = row[6]


with open('2_result.csv', 'r+', encoding='UTF-8', newline='') as f:
	reader = csv.reader(f)
	for row in reader:
		cities = []
		original = row[4]
		list_of_regions = [x.strip() for x in row[4].split(',')]
		for i in list_of_regions:
			if i in lau2_nuts3.keys():
				cities.append(i)
		for c in cities:
			list_of_regions = [x for x in list_of_regions if x != lau2_nuts3[c]]
		final[original] = list_of_regions


with open('2_region_translator.csv', 'w+') as csv_file:
    writer = csv.writer(csv_file)
    for key, value in final.items():
       writer.writerow([key, ",".join([str(x) for x in value])])