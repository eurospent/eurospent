# -*- coding: utf-8 -*-

import scrapy
import sys
from bs4 import BeautifulSoup

class ScrapeSpider(scrapy.Spider):
    name = 'spider'
    start_urls = ['https://www.esf-vlaanderen.be/nl/projectenkaart?vrij_zoek=&field_programs_target_id=9&field_themes_target_id=All&province=&field_products_target_id_op=&title_1=&field_call_id_value=&title_2=&title=&field_project_id_value=&field_file_number_value=&field_priority_target_id=All&title_3=&filter_minimum_one_product=&page={0}' .format(page) for page in xrange(0,76)]


    def parse(self, response):
        #try:
        hxs = scrapy.Selector(response)
        rows = hxs.xpath('//div[@class="view-content"]/div[@class="item-list"]/ul/li/article/header/h2/a')
        for row in rows:
            yield scrapy.Request('https://www.esf-vlaanderen.be' + row.xpath('@href').extract()[0], 
                #meta={'url':row.xpath('@href').extract()[0]}, 
                callback=self.parse_page)
        #except:
        #    print sys.exc_info()[0]
        #    raise scrapy.exceptions.CloseSpider(data)

    @staticmethod
    def get_item(hxs, name):
        return next(iter(hxs.xpath(name).extract()), '').strip()

    def parse_page(self, response):
        hxs = scrapy.Selector(response)

        data = dict()
        data['beneficiary_org'] = self.get_item(hxs, '//div[@class="organization-name"]/text()')
        data['beneficiary_street'] = self.get_item(hxs, '//div[@class="adr"]/div/span[@class="street-address"]/text()')
        data['beneficiary_postalcode'] = self.get_item(hxs, '//div[@class="adr"]/div/span[@class="postal-code"]/text()')
        data['beneficiary_city'] = self.get_item(hxs, '//div[@class="adr"]/div/span[@class="locality"]/text()')
        data['beneficiary_url'] = self.get_item(hxs, '//div[@class="url"]/div[@class="value"]/a/text()')

        loc_script = self.get_item(hxs, '//div[@class="field field-name-field-address"]/script/text()')
        exec(loc_script.replace('<!--//--><![CDATA[//><!--', '').replace('\n', '').replace(';//--><!]]>', '').replace('Drupal.getlocations_data["key_1"] = ', 'loc_coordinates = '))
        data['beneficiary_lat'] = loc_coordinates['latlons'][0][0]
        data['beneficiary_long'] = loc_coordinates['latlons'][0][1]

        data['beneficiary_name'] = self.get_item(hxs, '//div[@class="field field-name-mf-hcard"]/div[@class="vcard"]/div/span[@class="family-name"]/text()')
        data['beneficiary_tel'] = self.get_item(hxs, '//div[@class="field field-name-mf-hcard"]/div/div[@class="tel"]/div[@class="value"]/text()')
        data['beneficiary_email'] = self.get_item(hxs, '//div[@class="field field-name-mf-hcard"]/div/div[@class="email"]/div[@class="value"]/a/text()')

        data['project_partners'] = ';'.join(hxs.xpath('//div[@class="field field-name-field-partner"]/div/ul/li/text()').extract())

        data['project_name'] = self.get_item(hxs, '//div[@class="field field-name-title"]/h1/text()')
        data['project_description'] = self.get_item(hxs, '//div[@class="field field-name-field-content"]/p/text()')

        data['esf_requested'] = self.get_item(hxs, '//div[@class="group-finance-request field-group-div "]/div[@class="field field-name-field-fin-esf-app-req"]/text()')
        data['vcf_requested'] = self.get_item(hxs, '//div[@class="group-finance-request field-group-div "]/div[@class="field field-name-field-fin-vcf-app-req"]/text()')
        data['other_requested'] = self.get_item(hxs, '//div[@class="group-finance-request field-group-div "]/div[@class="field field-name-field-fin-oth-fin-app-req"]/text()')
        data['total_requested'] = self.get_item(hxs, '//div[@class="group-finance-request field-group-div "]/div[@class="field field-name-field-fin-tot-app-req"]/text()')

        data['esf_paid'] = self.get_item(hxs, '//div[@class="group-finance-approval field-group-div "]/div[@class="field field-name-field-fin-esf-paid"]/text()')
        data['vcf_paid'] = self.get_item(hxs, '//div[@class="group-finance-approval field-group-div "]/div[@class="field field-name-field-fin-vcf-paid"]/text()')
        data['other_paid'] = self.get_item(hxs, '//div[@class="group-finance-approval field-group-div "]/div[@class="field field-name-field-fin-oth-fin-paid"]/text()')
        data['total_paid'] = self.get_item(hxs, '//div[@class="group-finance-approval field-group-div "]/div[@class="field field-name-field-fin-tot-paid"]/text()')

        data['eu_rate'] = self.get_item(hxs, '//div[@class="field field-name-field-co-financing-rate-european"]/text()')

        data['project_id'] = self.get_item(hxs, '//div[@class="field field-name-field-project-id"]/text()')
        data['project_call'] = self.get_item(hxs, '//div[@class="field field-name-call"]/text()')
        data['project_theme'] = ';'.join(hxs.xpath('//div[@class="field field-name-field-themes"]/div[@class="item-list"]/ul/li/text()').extract())
        data['project_fund'] = self.get_item(hxs, '//div[@class="field field-name-field-programs"]/text()')
        data['project_priority'] = self.get_item(hxs, '//div[@class="field field-name-field-priority"]/text()')
        data['project_status'] = self.get_item(hxs, '//div[@class="field field-name-field-project-status"]/text()')
        data['project_last_update'] = self.get_item(hxs, '//div[@class="field field-name-field-last-update"]/span/text()')
        data['project_start'] = self.get_item(hxs, '//div[@class="field field-name-field-project-duration"]/div[@class="date-display-range"]/span[@class="date-display-start"]/text()')
        data['project_start'] = self.get_item(hxs, '//div[@class="field field-name-field-project-duration"]/div[@class="date-display-range"]/span[@class="date-display-end"]/text()')
        data['project_website'] = self.get_item(hxs, '//div[@class="field field-name-field-website"]/a/text()')

        yield data
