from metl.utils import *
import googlemaps, psycopg2

keys = [
    'ENTER_API_KEY'
]
key_num = 0
current_key = keys[key_num]
print "New key:", current_key
gmaps = googlemaps.Client(key=current_key)
conn=psycopg2.connect("dbname='' host='' user='' password=''")
num = 0


class Geocode(Modifier):

	def modify(self, record):
		global num
		num = num + 1
		print num

		query_id = record.getField('query_id').getValue()
		state = record.getField('query_state').getValue()
		region = record.getField('query_region').getValue()
		county = record.getField('query_county').getValue()
		country = record.getField('query_country').getValue()
		address = record.getField('query_address').getValue()
		beneficiary_id = record.getField('beneficiary_id').getValue()

		combinations = []


		if address:
			combinations.append(Geocode.uniencoder(u"{} {}".format(country, address)))

		if region:
			combinations.append(Geocode.uniencoder(u"{} {} {}".format(beneficiary_id, country, region)))
			combinations.append(Geocode.uniencoder(u"{} {}".format(beneficiary_id, region)))

		if state:
			combinations.append(Geocode.uniencoder(u"{} {} {}".format(beneficiary_id, country, state)))
			combinations.append(Geocode.uniencoder(u"{} {}".format(beneficiary_id, state)))

		if county:
			combinations.append(Geocode.uniencoder(u"{} {} {}".format(beneficiary_id, country, county)))
			combinations.append(Geocode.uniencoder(u"{} {}".format(beneficiary_id, county)))

		combinations.append(Geocode.uniencoder(u"{} {}".format(beneficiary_id, country)))
		combinations.append(Geocode.uniencoder(unicode(beneficiary_id)))

		result = Geocode.query_company(combinations)

		global conn
		cur = conn.cursor()

		result = result.items()
		cur.execute('UPDATE geocode SET geocoded = TRUE ' + \
			' '.join([", {} = %s".format(v[0]) for v in result if v[1]]) + \
			' WHERE id = %s;', tuple(v[1] for v in result if v[1])+(query_id,))
		conn.commit()

		return record

	@staticmethod
	def query_company(combinations):
		global gmaps, current_key, keys, key_num

		for c in combinations:
			try:
				result = gmaps.places(c)
			except googlemaps.exceptions.Timeout:
				print "Timed out key:", current_key

				key_num = key_num+1
				if key_num == len(keys):
					key_num = 0

				current_key = keys[key_num]
				print "New key:", current_key

				gmaps = googlemaps.Client(key=current_key)
				result = gmaps.places(c)

			except googlemaps.exceptions.HTTPError:
				continue

			if result["status"] != "OK" or not result["results"]:
				continue

			place = Geocode.query_place(result["results"][0])
			if not Geocode.query_place(result["results"][0]):
				continue

			return place
		return dict()

	@staticmethod
	def query_place(place):
		try:
			result = gmaps.place(place['place_id'], fields=address_component,adr_address,alt_id,formatted_address,geometry,icon,id,name,permanently_closed,photo,place_id,plus_code,scope,type,url,utc_offset,vicinity)
		except googlemaps.exceptions.ApiError:
			return None

		if result["status"] != "OK" or not result['result']:
			return None

		result_place = dict()

		result_place['result_lat'] = result['result']['geometry']['location']['lat']
		result_place['result_long'] = result['result']['geometry']['location']['lng']
		result_place['result_full_address'] = Geocode.uniencoder(result['result']['formatted_address'])
		for i in result['result']["address_components"]:
			if len(i["types"]) == 0:
				continue
			if i["types"][0] == u"locality":
				result_place['result_city'] = Geocode.uniencoder(i["long_name"])
			if i["types"][0] == u"postal_code":
				result_place['result_postal_code'] = Geocode.uniencoder(i["long_name"])
			if i["types"][0] == u"administrative_area_level_1":
				result_place['result_region'] = Geocode.uniencoder(i["long_name"])
			if i["types"][0] == u"administrative_area_level_2":
				result_place['result_county'] = Geocode.uniencoder(i["long_name"])
			if i["types"][0] == u"route":
				result_place['result_street'] = Geocode.uniencoder(i["long_name"])
			if i["types"][0] == u"street_number":
				result_place['result_number'] = Geocode.uniencoder(i["long_name"])
			if i["types"][0] == u"country":
				result_place['result_country'] = Geocode.uniencoder(i["long_name"])

		return result_place

	@staticmethod
	def uniencoder(s):
		if not s:
			return None
		if isinstance(s,basestring):
			return s.encode('utf8')
		return unicode(s).encode('utf8')


