#!/usr/bin/python
# -*- coding: utf-8 -*-

import csv
import json
import dbf
import argparse

#python3 pair_transactions.py -i ./nuts0/nuts0t.csv -d ./nuts0/EU7.dbf -o nuts0/result/nuts0
#python3 pair_transactions.py -i ./lau2/lau2t.csv -d ./lau2/EU7.dbf -o lau2/result/lau2

ap = argparse.ArgumentParser()
ap.add_argument("-i", "--input", required = True, help = "Path to the input stats file")
ap.add_argument("-d", "--dbffile", required = True, help = "Path to the input dbf file")
ap.add_argument("-o", "--output", required = True, help = "Path to the output file")

args = vars(ap.parse_args())
csvfile = args["input"]
dbffile = args["dbffile"]
outputfile = args["output"]

shapecodes = []

table = dbf.Table(dbffile)
table.open()
for record in table:
	shapecodes.append(str(record.code).replace("'","").strip())

new_table = dbf.Table(outputfile, 'S C(32); A N(19,2); T C(1)', codepage='utf8')

new_table.open(mode=dbf.READ_WRITE)

LAU2_stats = {}

with open(csvfile, 'rU') as fin:
	reader = csv.reader(fin, delimiter=",", lineterminator='\n')
	next(reader, None)
	for row in reader:
		LAU2_stats[row[1]] = [row[2]]

tuples = []

paired = 0
not_paired = 0
alls = 0

for i in shapecodes:
	if i != "":
		if LAU2_stats.get(i.strip()):
			new_row = tuple([str(i)] + LAU2_stats[i] + ["Y"])
			paired +=1
		else:
			if i[0:2] not in ["IS", "NO", "CH", "LI"]:
				not_paired += 1
				new_row = tuple([str(i)] + [0] + ["Y"])
			else:
				new_row = tuple([str(i)] + [0] + ["N"])
		tuples.append(new_row)
	else:
		pass
	if i[0:2] not in ["IS", "NO", "CH", "LI"]:
		alls += 1

tuples2 = tuple(tuples)

for municipality in tuples2:
	new_table.append(municipality)

print("All:", str(alls))
print("Good:", str(paired))
print("No transaction found:", str(not_paired))