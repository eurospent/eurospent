import scrapy
import re
import html2text
converter = html2text.HTML2Text()

class LatviaScraper(scrapy.Spider):
	name = 'latviascraper'
	start_urls = ['http://www.esfondi.lv/aktivitates?&page=1']
	pagination = 1

	def parse(self, response):
		for ids in response.xpath('//*[contains(@onclick, "open_project")]').extract():
			project_id = re.search(r'open_project\((.*?)\)', ids).group(1)
			href = 'http://www.esfondi.lv/aktivitates/open_project?project_id='+str(project_id)
			yield response.follow(href, self.get_link)

		# follow pagination links
		if self.pagination < 851:
			self.pagination +=1
			href = 'http://www.esfondi.lv/aktivitates?&page='+str(self.pagination)
			yield response.follow(href, self.parse)

	def get_link(self, response):
		link = response.css('td.field-value a::text').extract_first()
		yield response.follow(link, self.parse_transaction_page)

	def parse_transaction_page(self, response):
		def extract_with_css(query):
			if response.css(query).extract_first():
				return converter.handle(response.css(query).extract_first()).strip()

		yield {
			'project_title': extract_with_css('h1::text'),
			'activity_subactivity_title': extract_with_css('.data-table tr:nth-child(1) td.field-value::text'),
			'project_number': extract_with_css('.data-table tr:nth-child(2) td.field-value::text'),
			'beneficiary': extract_with_css('.data-table tr:nth-child(3) td.field-value::text'),
			'project_partner': extract_with_css('.data-table tr:nth-child(4) td.field-value::text'),
			'beneficiary_address': extract_with_css('.data-table tr:nth-child(5) td.field-value::text'),
			'project_region': extract_with_css('.data-table tr:nth-child(6) td.field-value::text'),
			'management_authority': extract_with_css('.data-table tr:nth-child(7) td.field-value::text'),
			'coordination_office': extract_with_css('.data-table tr:nth-child(8) td.field-value::text'),
			'contract_date': extract_with_css('.data-table tr:nth-child(9) td.field-value::text'),
			'duration': extract_with_css('.data-table tr:nth-child(10) td.field-value::text'),
			'fund_acronym': extract_with_css('.data-table tr:nth-child(11) td.field-value::text'),
			'eu_cofinancing_amount': extract_with_css('.data-table tr:nth-child(12) td.field-value::text'),
			'member_state_amount': extract_with_css('.data-table tr:nth-child(13) td.field-value::text'),
			'private_funding_amount': extract_with_css('.data-table tr:nth-child(14) td.field-value::text'),
			'total_amount': extract_with_css('.data-table tr:nth-child(15) td.field-value::text'),
			'paid_amount': extract_with_css('.data-table tr:nth-child(16) td.field-value::text'),
			'project_description': extract_with_css('.data-table tr:nth-child(17) td.field-value::text')
		}