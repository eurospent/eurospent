import scrapy
import sys

class FinlandSpider(scrapy.Spider):
    name = 'finlandspider'
    start_urls = ['https://www.eura2007.fi/rrtiepa/projektilista.php?rahasto=ALL']

    def parse(self, response):
        hxs = scrapy.Selector(response)
        rows = hxs.xpath('//tr')
        for row in rows:
            a = row.xpath('td/a/text()').extract()
            b = row.xpath('td/text()').extract()
            if len(a) == 0 or len(b) == 0:
                continue
            yield scrapy.Request('https://www.eura2007.fi/rrtiepa/' + row.xpath('td/a/@href').extract()[0], 
               meta={'attr': a+b}, 
               callback=self.parse_page)

    def parse_page(self, response):
        hxs = scrapy.Selector(response)
        data = response.meta['attr']
        country, region, county, city, extra_data = None, None, None, None, None

        try:
            region_array = hxs.xpath("//h3[contains(text(), '3.1 Maantieteellinen kohdealue')]/following-sibling::p[1]/text()").extract()
            if len(region_array) > 0 and region_array[0] == "Valtakunnallinen projekti":
                country = 'National project'
            elif region_array:
                region = region_array[0].split(':')[1]
                county = hxs.xpath("//h3[contains(text(), '3.1 Maantieteellinen kohdealue')]/following-sibling::p[2]/text()").extract()[0].split(':')[1]
                city = hxs.xpath("//h3[contains(text(), '3.1 Maantieteellinen kohdealue')]/following-sibling::p[3]/text()").extract()[0].split(':')[1]
        except:
            print sys.exc_info()[0]
            raise scrapy.exceptions.CloseSpider(data)

        row = {
            'code': data[0],
            'project_name': data[1],
            'fund': data[2],
            'partition': data[3],
            'priority': data[4],
            'authoritative': data[5],
            'status': data[6],
            'start_date': data[7],
            'end_date': data[8],
            'beneficiary': data[9],
            'granted_eu_state_funding': data[10],
            'realized_eu_state_funding': data[11],
            'planned_public_funding': data[12],
            'total_public_funding': data[13],
            'country': country,
            'region': region,
            'county': county,
            'city': city,
            'extra_data': extra_data
        }

        return {k: (v.strip() if v else v) for k, v in row.iteritems()}
