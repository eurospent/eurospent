#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
USAGE: python3 2_govt_institutions.py government_institutions.csv 2_municipality_names.csv 2_govt_translate.csv
'''

import csv
import sys
import re

list_of_govs = []
list_of_towns = []
govs_and_towns = {}

def open_csv (csv_file, targetlist):
	with open(csv_file, 'r+', encoding='UTF-8', newline='') as f:
		reader = csv.reader(f)
		for row in reader:
			targetlist.append(row[0])

def print_dictionary (dictionary, result_file):
	with open(result_file,'w+', encoding='UTF-8', newline='') as f:
		w = csv.writer(f, delimiter=',')
		w.writerow(['beneficiary','city'])
		for row in govs_and_towns.items():
			w.writerow(['"'+row[0]+'"', '"'+', '.join(row[1])+'"'])

if __name__ == '__main__':
	gov_file = sys.argv[1]
	town_file = sys.argv[2]
	result_file = sys.argv[3]
	open_csv(gov_file, list_of_govs)
	open_csv(town_file, list_of_towns)
	for gov in list_of_govs:
		govs_and_towns.setdefault(gov, [])
		list_of_strings = re.findall(r"[\w']+", gov)
		for i in list_of_strings:
			if i.capitalize() in list_of_towns:
				govs_and_towns.setdefault(gov, []).append(i.capitalize())
			elif i.capitalize().strip('i') in list_of_towns:
				govs_and_towns.setdefault(gov, []).append(i.capitalize().strip('i'))
		for key in govs_and_towns:
			govs_and_towns[key] = list(set(govs_and_towns[key]))
	print_dictionary(govs_and_towns, result_file)