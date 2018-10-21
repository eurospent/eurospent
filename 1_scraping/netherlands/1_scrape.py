# -*- coding: utf-8 -*-

import scrapy
import sys
from bs4 import BeautifulSoup

class ScrapeSpider(scrapy.Spider):
    name = 'spider'
    #start_urls = ['https://www.europaomdehoek.nl/projecten/?page={0}&map=&radius=&projectFund%5B0%5D=EFRO&projectFund%5B1%5D=ESF&projectFund%5B2%5D=EFRO&projectFund%5B3%5D=ESF&projectStartDate%5B0%5D=2013&projectStartDate%5B1%5D=2012&projectStartDate%5B2%5D=2011&projectStartDate%5B3%5D=2010&projectStartDate%5B4%5D=2009&projectStartDate%5B5%5D=2008&projectStartDate%5B6%5D=2007&projectStartDate%5B7%5D=2013&projectStartDate%5B8%5D=2012&projectStartDate%5B9%5D=2011&projectStartDate%5B10%5D=2010&projectStartDate%5B11%5D=2009&projectStartDate%5B12%5D=2008&projectStartDate%5B13%5D=2007' .format(page) for page in xrange(1,136)]
    start_urls = ['https://www.europaomdehoek.nl/projecten/?page={0}&map=&radius=&projectFund%5B0%5D=EFRO&projectFund%5B1%5D=INTERREG&projectFund%5B2%5D=EFRO&projectFund%5B3%5D=INTERREG&projectStartDate%5B0%5D=2013&projectStartDate%5B1%5D=2012&projectStartDate%5B2%5D=2011&projectStartDate%5B3%5D=2010&projectStartDate%5B4%5D=2009&projectStartDate%5B5%5D=2008&projectStartDate%5B6%5D=2007&projectStartDate%5B7%5D=2013&projectStartDate%5B8%5D=2012&projectStartDate%5B9%5D=2011&projectStartDate%5B10%5D=2010&projectStartDate%5B11%5D=2009&projectStartDate%5B12%5D=2008&projectStartDate%5B13%5D=2007' .format(page) for page in xrange(1,62)]


    def parse(self, response):
        #try:
        hxs = scrapy.Selector(response)
        rows = hxs.xpath('//div[@class="project--list-view"]/div/div/div/a')
        for row in rows:
            yield scrapy.Request('https://www.europaomdehoek.nl/' + row.xpath('@href').extract()[0], 
                # meta=data, 
                callback=self.parse_page)
        #except:
        #    print sys.exc_info()[0]
        #    raise scrapy.exceptions.CloseSpider(data)

    def parse_page(self, response):
        hxs = scrapy.Selector(response)

        data = dict()
        data['project_name'] = next(iter(hxs.xpath('//div[@class="wrapper-container"]/section/div/h1/text()').extract()), '').strip()
        data['duration'] = next(iter(hxs.xpath('//div[@class="wrapper-container"]/section/div/div[@class="date--project"]/text()').extract()), '').strip()
        data['description'] = ' '.join([desc.strip() for desc in hxs.xpath('//div[@class="wrapper-container"]/section[@class="content__middle"]/div/div/p/text()').extract()])
        data['beneficiary_name'] = next(iter(hxs.xpath('//div[@class="wrapper-container"]/aside[@class="sidebar sidebar__right"]/div/div[1]/span[2]/text()').extract()), '').strip()
        data['address'] = next(iter(hxs.xpath('//div[@class="wrapper-container"]/aside[@class="sidebar sidebar__right"]/div/div[2]/span[3]/text()').extract()), '').strip()
        
        amount_script = next(iter(hxs.xpath('//div[@class="wrapper-container"]/aside[@class="sidebar sidebar__right"]/div/div[3]/script/text()').extract()), '').strip()
        exec(unicode(amount_script.replace('var', '').replace(';', '').replace(u'€', '').strip()))
        amounts = dict(chartData)
        data['eu_amount'] = amounts.get('EU-subsidie')
        data['public_cofinancing'] = amounts.get('Publieke cofinanciering')
        data['private_cofinancing'] = amounts.get('Private cofinanciering')

        data['fund'] = next(iter(hxs.xpath('//div[@class="wrapper-container"]/aside[@class="sidebar sidebar__right"]/div/div[4]/span[2]/a/text()').extract()), '').strip()

        loc_script = next(iter(hxs.xpath('//div[@class="wrapper-container"]/aside[@class="sidebar sidebar__right"]/div/div[5]/script/text()').extract()), '').strip()
        exec(unicode(loc_script.replace('var', '').replace(';', '').replace('icon', "'icon'").replace('latitude', "'latitude'").replace('longitude', "'longitude'").strip()))
        data['long'] = mapsData['longitude'] 
        data['lat'] = mapsData['latitude']

        yield data

