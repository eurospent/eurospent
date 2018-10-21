import scrapy

class SubsidyItem(scrapy.Item):
	beneficiary = scrapy.Field()
	business_address = scrapy.Field()
	place_of_execution = scrapy.Field()
	name_of_contract = scrapy.Field()
	total_value = scrapy.Field()
	grants = scrapy.Field()
	funding_beneficiary = scrapy.Field()
	actually_paid = scrapy.Field()
	duration = scrapy.Field()
	status = scrapy.Field()
	performers = scrapy.Field()
	fund_acronym = scrapy.Field()
	contract_date = scrapy.Field()
	start_date = scrapy.Field()
	end_date = scrapy.Field()
	order = scrapy.Field()

class BulgariaScraper(scrapy.Spider):
	name = 'bulgariascraper'
	start_urls = ['http://umispublic.government.bg/prProcedureProjectsInfo.aspx?op=-1&proc=-2&clear=1']
	order = 1

	@staticmethod
	def clean(cell):
		if len(cell) > 0:
			return [i.strip().replace("'", "").replace('"','').replace(';',',') for i in cell.extract()]
		else:
			return cell.extract()

	def parse(self, response):

		yield scrapy.FormRequest(
			'http://umispublic.government.bg/prProcedureProjectsInfo.aspx?op=-1&proc=-2&clear=1',
			formdata={
				'__VIEWSTATE': response.css('input#__VIEWSTATE::attr(value)').extract_first(),
				'ctl00$ContentPlaceHolder1$txtPartyFullName': '',
				'ctl00$ContentPlaceHolder1$txtSettlement': '',
				'ctl00$ContentPlaceHolder1$txtProjectName': '',
				'ctl00$ContentPlaceHolder1$ddlState': ['-1'],
				'ctl00$txtFastSrch': '',
				'tvMainMenu_ExpandState': 'ennnnnnnennnnnnnennnenenenen',
				'tvMainMenu_SelectedNode': 'tvMainMenut21',
				'__EVENTTARGET': '',
				'__EVENTARGUMENT': '',
				'tvMainMenu_PopulateLog': '',
				'__VIEWSTATEGENERATOR': '5F70208E'
			},
			callback=self.parse_tabular
		)
		for next_page in response.css('a#ContentPlaceHolder1_CtlListPager1_hlNextPage').extract():
		#for next_page in response.xpath('//a[@id="ContentPlaceHolder1_CtlListPager1_hlNextPage"]/@href').extract():
			yield scrapy.FormRequest(
			'http://umispublic.government.bg/prProcedureProjectsInfo.aspx?op=-1&proc=-2&clear=1',
			formdata={
				'__VIEWSTATE': response.css('input#__VIEWSTATE::attr(value)').extract_first(),
				'ctl00$ContentPlaceHolder1$txtPartyFullName': '',
				'ctl00$ContentPlaceHolder1$txtSettlement': '',
				'ctl00$ContentPlaceHolder1$txtProjectName': '',
				'ctl00$ContentPlaceHolder1$ddlState': ['-1'],
				'ctl00$txtFastSrch': '',
				'tvMainMenu_ExpandState': 'ennnnnnnennnnnnnennnenenenen',
				'tvMainMenu_SelectedNode': 'tvMainMenut21',
				'__EVENTTARGET': 'ctl00$ContentPlaceHolder1$CtlListPager1$hlNextPage',
				'__EVENTARGUMENT': '',
				'tvMainMenu_PopulateLog': '',
				'__VIEWSTATEGENERATOR': '5F70208E'
			},
			callback=self.parse
		)

	def parse_tabular(self, response):

		rows = response.css('table.InfoTableProposal>tr')
		for row in rows:
			item = SubsidyItem()
			meta = {
				'a': self.clean(row.xpath('td[1]/text()')),
				'b': self.clean(row.xpath('td[2]/text()')),
				'c': self.clean(row.xpath('td[3]/text()')),
				'd': self.clean(row.xpath('td[4]/a/text()')),
				'e': self.clean(row.xpath('td[5]/text()')),
				'f': self.clean(row.xpath('td[6]/text()')),
				'g': self.clean(row.xpath('td[7]/text()')),
				'h': self.clean(row.xpath('td[8]/text()')),
				'i': self.clean(row.xpath('td[9]/text()')),
				'j': self.clean(row.xpath('td[10]/text()')),
				'k': self.clean(row.xpath('td[11]/a/text()')),
				'l': self.order
			}
			self.order += 1
			yield scrapy.Request('http://umispublic.government.bg/' + row.xpath('td[4]/a/@href').extract()[0],
				meta=meta,
				callback=self.parse_page)

	def parse_page(self, response):
		item = SubsidyItem()
		item['beneficiary'] = response.meta['a']
		item['business_address'] = response.meta['b']
		item['place_of_execution'] = response.meta['c']
		item['name_of_contract'] = response.meta['d']
		item['total_value'] = response.meta['e']
		item['grants'] = response.meta['f']
		item['funding_beneficiary'] = response.meta['g']
		item['actually_paid'] = response.meta['h']
		item['duration'] = response.meta['i']
		item['status'] = response.meta['j']
		item['performers'] = response.meta['k']
		item['fund_acronym'] = self.clean(response.xpath('//span[@id="ContentPlaceHolder1_lblPartnersFinanceSource"]/text()'))
		item['contract_date'] = self.clean(response.xpath('//span[@id="ContentPlaceHolder1_lblRealApproved_Text"]/text()'))
		item['start_date'] = self.clean(response.xpath('//span[@id="ContentPlaceHolder1_lblProjectStart_Text"]/text()'))
		item['end_date'] = self.clean(response.xpath('//span[@id="ContentPlaceHolder1_lblProjectEnd_Text"]/text()'))
		item['order'] = response.meta['l']
		yield item
