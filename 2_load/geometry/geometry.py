import requests, codecs, json
from metl.utils import *

import sys
import csv

csv.field_size_limit(sys.maxsize)
num = 0

class Geometry( Modifier ):

	def modify( self, record ):
		global num
		num = num+1
		print num

		data = record.getField('j').getValue().replace('{"type":"Feature","geometry":','').split(',"properties":')
		record.getField('geojson').setValue(data[0])
		try:
			p =json.loads(data[1][:-2])
			record.getField('shape_lau').setValue(p.get('S'))
			record.getField('lau').setValue(p.get('L'))
			record.getField('name').setValue(p.get('N'))
			record.getField('population').setValue(p.get('P'))
			record.getField('density').setValue(p.get('D'))
		except:
			print record.getField('j').getValue()

		return record