import scrapy
import json
import csv
import re

class SubsidyItem(scrapy.Item):
	project_title = scrapy.Field()
	beneficiary = scrapy.Field()
	operational_programe = scrapy.Field()
	thematical_priority = scrapy.Field()
	description = scrapy.Field()
	budget = scrapy.Field()
	payments = scrapy.Field()
	start_date = scrapy.Field()
	end_date = scrapy.Field()
	nr_of_subprojects = scrapy.Field()
	transaction_id = scrapy.Field()
	coordinates = scrapy.Field()

class GreeceScraper(scrapy.Spider):
	codes = []
	name = 'greece'
	headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'}
	with open('02a_result.csv', mode='r') as infile:
		reader = csv.reader(infile)
		next(reader, None)
		start_urls = ['http://2013.anaptyxi.gov.gr/ergopopup.aspx?mis='+row[11].strip() for row in reader if row[11] != '']

	def parse(self,response):
		item = SubsidyItem()
		item["project_title"] = response.xpath('//span[@id="dnn_ctr521_View_txtTitlos"]/text()').extract()
		item["beneficiary"] = response.xpath('//span[@id="dnn_ctr521_View_txtForeas"]/text()').extract()
		item["operational_programe"] = response.xpath('//span[@id="dnn_ctr521_View_txtEPTitle"]/text()').extract()
		item["thematical_priority"] = response.xpath('//span[@id="dnn_ctr521_View_txtAnapt"]/text()').extract()
		item["description"] = response.xpath('//textarea[@id="dnn_ctr521_View_perigrafi"]/text()').extract()
		if response.xpath('//span[@id="dnn_ctr521_View_txtCostErgou"]/text()').extract().replace('.','').replace(' €','') == '':
			item["budget"] = 0
		else:
			item["budget"] = response.xpath('//span[@id="dnn_ctr521_View_txtCostErgou"]/text()').extract().replace('.','').replace(' €','')
		if response.xpath('//span[@id="dnn_ctr521_View_txtPliromes"]/text()').extract().replace('.','').replace(' €','') == ''
			item["payments"] = 0
		else:
			item["payments"] = response.xpath('//span[@id="dnn_ctr521_View_txtPliromes"]/text()').extract().replace('.','').replace(' €','')		
		item["start_date"] = response.xpath('//span[@id="dnn_ctr521_View_txtEnarji"]/text()').extract()
		item["end_date"] = response.xpath('//span[@id="dnn_ctr521_View_txtLiji"]/text()').extract()
		item["nr_of_subprojects"] = response.xpath('//span[@id="dnn_ctr521_View_txtCountIpoerga"]/text()').extract()
		item["transaction_id"] = str(response.request.url).replace('http://2013.anaptyxi.gov.gr/ergopopup.aspx?mis=','')
		
		js_scripts = str(response.xpath('//script/text()').extract())
		regex = r'\<coordinates\>\s?(.+?)\s?\<\/coordinates\>'
		coordinates = str(re.findall(regex, js_scripts)).replace('[','').replace(']','')
		coordinates = coordinates.replace(" , ",",").replace(", ",",").replace(" ,",",").replace(',0.00,',' ').replace(',0.00','').replace('0.00,','').replace('0.00','').replace(',0,',' ').replace(',0','').replace('0,','').replace('  ',' ')
		coordinates = coordinates.split("','")
		coordinates = [i.replace("'","").replace(' , ',',').replace(", ",",").replace(" ,","") for i in coordinates]
		new_coords = []
		for i in coordinates:
			single_coords = i.split(',')
			if len(single_coords) == 2:
				switched_coords = str(single_coords[1]+','+single_coords[0])
				new_coords.append(switched_coords)
			elif len(single_coords) > 2:
				corrected_coords = i.split(' ')
				for coord in corrected_coords:
					switched_coords = str(coord.split(',')[1].strip(',')+','+coord.split(',')[0].strip(','))
					new_coords.append(switched_coords)

		coordinates = new_coords
		if len(coordinates) == 1 and coordinates[0] == '':
			coordinates = []
		coordinates = ";".join(coordinates)
		item["coordinates"] = ";".join(coordinates)
		yield item