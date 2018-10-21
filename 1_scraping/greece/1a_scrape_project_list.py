import scrapy
import json

class SubsidyItem(scrapy.Item):
	project_status = scrapy.Field()
	project_title = scrapy.Field()
	beneficiary = scrapy.Field()
	budget = scrapy.Field()
	contracts = scrapy.Field()
	payments = scrapy.Field()
	region = scrapy.Field()
	start_date = scrapy.Field()
	end_date = scrapy.Field()
	nr_of_subprojects = scrapy.Field()
	program_code = scrapy.Field()
	transaction_id = scrapy.Field()

class GreeceScraper(scrapy.Spider):
	name = 'greece'
	start_urls = ['http://2013.anaptyxi.gov.gr/GetData.ashx?queryType=projects&pagesize=1000&pagenum=1']
	pagination = 1
	headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'}

	
	def parse(self,response):
		jsonresponse = json.loads(response.body_as_unicode())
		for i in jsonresponse:
			item = SubsidyItem()
			item["project_status"] = i["trexousaKatastash"]
			item["project_title"] = i["title"]
			item["beneficiary"] = i["body"]
			item["budget"] = i["budget"]
			item["contracts"] = i["contracts"]
			item["payments"] = i["payments"]
			item["region"] = i["perifereia"]
			item["start_date"] = i["startDate"]
			item["end_date"] = i["endDate"]
			item["nr_of_subprojects"] = i["countIpoergon"]
			item["program_code"] = i["epKodikos"]
			item["transaction_id"] = i["kodikos"]
			yield item

		if self.pagination < 143:
			self.pagination +=1
			href = 'http://2013.anaptyxi.gov.gr/GetData.ashx?queryType=projects&pagesize=1000&pagenum='+str(self.pagination)
			yield scrapy.Request(href, headers=self.headers, callback=self.parse)