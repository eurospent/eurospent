# -*- coding: utf-8 -*-

import scrapy
import sys
from bs4 import BeautifulSoup

class ScrapeSpider(scrapy.Spider):
    name = 'spider'
    start_urls = ['http://www.mapadotacji.gov.pl/projekty/%s/50?lata=2007' % page for page in xrange(1,2278)]

    def parse(self, response):
        try:
            hxs = scrapy.Selector(response)
            rows = hxs.xpath('//div[@class="lista_projektow_div"]/div')
            for row in rows:
                data = {
                    'title': next(iter(row.xpath('div[@class="projectTitle"]/a/text()').extract()), '').strip(),
                    'beneficiary': next(iter(row.xpath('div[@class="beneficjent"]/text()').extract()), '').strip(),
                    'total_amount': next(iter(row.xpath('div[@class="wartosc"]/text()').extract()), '').strip(),
                    'eu_amount': next(iter(row.xpath('div[@class="dofinansowanie"]/text()').extract()), '').strip(),
                    'field': next(iter(row.xpath('div[@class="sektor"]/span/text()').extract()), '').strip(),
                    'link': row.xpath('div[@class="projectTitle"]/a/@href').extract()[0]
                }

                yield scrapy.Request('http://www.mapadotacji.gov.pl/' + (data['link'][1:] if data['link'][0] == '/' else data['link']), 
                   meta=data, 
                   callback=self.parse_page)
        except:
            print sys.exc_info()[0]
            raise scrapy.exceptions.CloseSpider(data)

    def parse_page(self, response):
        hxs = scrapy.Selector(response)
        content = hxs.xpath('//div[@class="smal_content_middle"]').extract()[0]
        soup = BeautifulSoup(content, "lxml")
        data = response.meta

        key = ["".join(a.get_text().strip().split()) for a in soup.find_all("div", class_="left_line")]
        value = [a.get_text().strip() for a in soup.find_all("div", class_="right_line")]
        parameters = dict(zip(key, value))

        data['fund'] = parameters['fundusz:']
        data['program'] = parameters['program:']
        data['action'] = parameters[u'działanie:']
        a1=parameters.get(u'województwo:powiat:')
        a2=parameters.get(u'województwo:powiaty:')
        a3=parameters.get(u'województwa:powiat:')
        a4=parameters.get(u'województwa:powiaty:')
        if not (a1 or a2 or a3 or a4):
            raise 'ures'
        data['loc'] = (a1 or a2 or a3 or a4)

        yield data

'''
        
        print '-----------------------------------------'
        for e in parameters.extract():
            soup = BeautifulSoup(e)
            #print e
            print soup.find("div", class_="left_line").get_text().strip()
            #print soup.find("div", class_="right_line")
            #print 'key: ', e.xpath('//div/div[@class="left_line"]').re('.*')
            #print 'value: ',e.xpath('//div/div[@class="right_line"]').re('.*')
'''