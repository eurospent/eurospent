import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

import argparse
import json
import csv
import sys

##python3 generate_style.py -i ./nuts0/nuts0_transactions.csv -c 28 -g N0T -o ./nuts0/result/N0T

ap = argparse.ArgumentParser()
ap.add_argument("-i", "--input", required = True, help = "Path to the input stats file")
ap.add_argument("-c", "--colors", required = True, help = "Number of colors to generate")
ap.add_argument("-g", "--geometryfilename", required = True, help = "Name the geometry file for output")
ap.add_argument("-o", "--output", required = True, help = "Name of output file")

args = vars(ap.parse_args())
csvfile = args["input"]
colors = args["colors"]
geometryfilename = args["geometryfilename"]
output = args["output"]


buckets_over_avg = int(round((int(colors) / 2 ),0))
buckets_under_avg = int(colors) - buckets_over_avg

transactions = []
nonnull_trans = []

with open(csvfile) as infile:
	reader = csv.reader(infile, delimiter=",", lineterminator='\n')
	next(reader)
	for i in reader:
		transactions.append(float(i[2]))
		if float(i[2]) > 0:
			nonnull_trans.append(float(i[2]))

average_trans = 0
for i in transactions:
	average_trans += i

trans_sorted = list(sorted(nonnull_trans))

#CALCULATE WITH AVERAGE
#middle_point = average_trans / len(nonnull_trans)

#CALCULATE WITH MEDIAN
middle_point = trans_sorted[int(len(nonnull_trans) / 2)]

midpoint_index = trans_sorted.index(min(trans_sorted, key=lambda x:abs(x-middle_point)))

bucketsize_under_midpoint = int(midpoint_index / buckets_under_avg)
bucketsize_above_midpoint = int((len(nonnull_trans)+1 - midpoint_index) / buckets_over_avg)
lows = []
highs = []

counter_lows = len(transactions) - len(nonnull_trans) + 1

for i in range(0, buckets_under_avg):
	lows.append(counter_lows)
	counter_lows += bucketsize_under_midpoint

counter = midpoint_index
for i in range(0, buckets_over_avg):
	highs.append(counter)
	counter += bucketsize_above_midpoint

final = []

for i in lows:
	final.append((sorted(transactions)[i]))

for i in highs:
	final.append((sorted(transactions)[i + len(transactions) - len(nonnull_trans)]))


#SEE FOR DETAILS: http://seaborn.pydata.org/tutorial/color_palettes.html

#CURRENT BEST
pal = sns.diverging_palette(220, 15, sep=1, n=int(colors), center="light").as_hex()


#BLUE PALETTE 
#pal = sns.cubehelix_palette(colors, start=0, rot=-.25, gamma=.7, dark=.9, light=0.1, reverse=True).as_hex()


#pal = sns.diverging_palette(210, 15, n=int(colors)).as_hex()
#pal = sns.diverging_palette(145, 85, s=70, l=25, sep=1, n=int(colors)).as_hex()
#pal = sns.color_palette("coolwarm", int(colors)).as_hex()
#pal = sns.cubehelix_palette(int(colors), start=1.8, rot=-.25, gamma=.7, dark=.9, light=0.1).as_hex()

#sns.palplot(sns.cubehelix_palette(colors, rot=0.7, gamma=1.2).as_hex())

#CURRENT BEST
#sns.palplot(sns.diverging_palette(220, 15, sep=1, n=int(colors), center="light"))


#BLUE PALETTE
#sns.palplot(sns.cubehelix_palette(colors, start=0, rot=-.25, gamma=.7, dark=.9, light=0.1, reverse=True))


#sns.palplot(sns.diverging_palette(220, 15, n=int(colors)).as_hex())
#sns.palplot(sns.diverging_palette(145, 85, s=70, l=25, sep=1, n=int(colors)).as_hex())
#sns.palplot(sns.color_palette("coolwarm", int(colors)).as_hex())
#sns.palplot(sns.cubehelix_palette(int(colors), start=1.8, rot=-.25, gamma=.7, dark=.9, light=0.1).as_hex())

layerlist = []

for i in range(1,int(colors)+1):
	layerlist.append('l'+str(i))

#Green
#seacolor = '#83a99e'
#seashade = 0.6

#Blue
#seacolor = '#00578a'
#seashade = 0.2

#GmapsBlue
seacolor = '#a0afc0'
seashade = 1

base =  {
	"version": 8,
	"name": geometryfilename,
	"metadata": {
		"mapbox:autocomposite": True,
		"mapbox:type": "template"
	},
	"sources": {
		geometryfilename: {
			"url": "mbtiles://"+geometryfilename+".mbtiles",
			"type": "vector"
    	},
		"EU2": {
			"url": "mbtiles://EU2.mbtiles",
			"type": "vector"
		},
		"world": {
			"url": "mbtiles://world.mbtiles",
			"type": "vector"
		}
	},
	"layers": [
		{
			"id": "background",
			"type": "background",
			"paint": {
				"background-color": seacolor,
				"background-opacity": seashade
			},
			"interactive": True
    	},
    	{
    		"id": "worldbase",
			"type": "fill",
			"source": "world",
			"source-layer": "world",
			"paint": {
				"fill-color": "#a9a9a9",
			},
			"interactive": True
    	},
    	{
    		"id": "worldboundaries",
			"type": "line",
			"source": "world",
			"source-layer": "world",
			"paint": {
				"line-color": {
					"stops": [
						[4, "#666666"],
						[5, "#666666"],
						[6, "#666666"],
						[7, "#666666"],
						[8, "#666666"],
						[9, "#666666"],
						[10, "#666666"]
					]
				},
				"line-opacity": 0.4,
				"line-width": 1
			},
			"interactive": True
        },
    	{
			"id": "l0",
			"type": "fill",
			"source": geometryfilename,
			"source-layer": geometryfilename,
			"filter": [
				">=",
				"A",
				0
			],
			"filter": [
            	"==",
        		"T",
        		"Y"
      		],
			"paint": {
				"fill-color": pal[0],
				"fill-outline-color": {
					"stops": [
						[4, pal[0]],
						[5, pal[0]],
						[6, pal[0]],
						[7, "#999999"],
						[8, "#999999"],
						[9, "#999999"],
						[10, "#999999"]
					]
				},
				"fill-opacity": 1
			},
			"interactive": True
		}
    ]
}

for i in range(1, int(colors)+1):
	element = {
		"id": layerlist[i-1],
		"type": "fill",
		"source": geometryfilename,
		"source-layer": geometryfilename,
		"filter": [
			">=",
			"A",
			final[i-1]
		],
		"paint": {
			"fill-color":  pal[i-1],
			"fill-outline-color": {
				"stops": [
					[4,  pal[i-1]],
					[5,  pal[i-1]],
					[6,  pal[i-1]],
					[7, "#999999"],
					[8, "#999999"],
					[9, "#999999"],
					[10, "#999999"]
				]
			},
			"fill-opacity": 1
		},
		"interactive": True
	}

	base["layers"].append(element)

errorlayer = {
	"id": "ERROR",
	"type": "fill",
	"source": geometryfilename,
	"source-layer": geometryfilename,
	"filter": [
		"==",
		"T",
		"N"
	],
	"paint": {
		"fill-color": "#a9a9a9",
		"fill-outline-color": {
			"stops": [
				[4, "#a9a9a9"],
				[5, "#a9a9a9"],
				[6, "#a9a9a9"],
				[7, "#999999"],
				[8, "#999999"],
				[9, "#999999"],
				[10, "#999999"]
			]
		},
		"fill-opacity": 1
	},
	"interactive": True
}

countrylayer = {
	"id": "EU0",
	"type": "line",
	"source": "EU2",
	"source-layer": "EU2",
	"paint": {
		"line-color": {
			"stops": [
				[4, "#333333"],
				[5, "#333333"],
				[6, "#333333"],
				[7, "#333333"],
				[8, "#333333"],
				[9, "#333333"],
				[10, "#333333"]
			]
		},
		"line-opacity": 0.4,
		"line-width": 1
	},
	"interactive": True
}


base["layers"].append(errorlayer)
base["layers"].append(countrylayer)


with open(output+'.json', 'w+') as outfile:
    json.dump(base, outfile)

#plt.show()