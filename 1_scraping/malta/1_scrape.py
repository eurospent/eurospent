import scrapy
import re
import html2text
converter = html2text.HTML2Text()

class MaltaScraper(scrapy.Spider):
	name = 'maltascraper'
	start_urls = ['https://investinginyourfuture.gov.mt/project/research-science-and-technology-education/science-popularisation-campaign-33947740']

	def parse(self, response):
		for project in response.css('div.project-contentpage-wrapper'):
			yield {
			    'project_ref_code': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectRefCode::text').extract_first(),
				'project_title': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectTitle::text').extract_first(),
				'beneficiary': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectCostBeneficiaryItem_divBeneficiaryValue::text').extract_first(),
				'project_cost': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectCostBeneficiaryItem_divCostValue::text').extract_first().replace(',','').replace('€',''),
				'ministry': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectDetails_tdLineMinistry::text').extract_first(),
				'start_date': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectDetails_tdStartDate::text').extract_first(),
				'end_date': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectDetails_tdEndDate::text').extract_first(),
				'end_date': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectDetails_tdEndDate::text').extract_first(),
				'project_description': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectDetails_divNonTechnicalShortSummaryContent p::text').extract_first(),
				'operational_programme': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectDetails_tdOperationalProgramme::text').extract_first(),
				'fund_acronym': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectDetails_tdFund::text').extract_first(),
				'operational_objective': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectDetails_tdOperationalObjective::text').extract_first(),
				'priority_axis': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectDetails_tdPriorityAxis::text').extract_first(),
				'focus_area': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectDetails_tdFocusAreaOfIntervention1::text').extract_first(),
				'project_objectives': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectDetails_divProjectObjectives p::text').extract_first(),
				'project_results': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectDetails_divProjectResults p::text').extract_first(),
				'project_purpose': response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_projectDetails_divProjectPurpose p::text').extract_first()
			}

		next_page = response.css('#mainPlaceHolder_coreContentPlaceHolder_mainContentPlaceHolder_PrevNextBackProject_aNextProject::attr(href)').extract_first()
		if next_page is not None:
			next_page = response.urljoin(next_page)
			yield scrapy.Request(next_page, callback=self.parse)