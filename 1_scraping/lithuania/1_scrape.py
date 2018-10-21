import scrapy
import html2text
converter = html2text.HTML2Text()


class LithuaniaScraper(scrapy.Spider):
    name = 'lithuaniascraper'
    start_urls = ['http://www.esparama.lt/igyvendinami-projektai?pgsz=10&order=&page=1']
    pagination = 1

    def parse(self, response):
        for href in response.css('.first a::attr(href)'):
            yield response.follow(href, self.parse_tabular)

        # follow pagination links

        if self.pagination < 3:
        #if self.pagination < 828:
            self.pagination +=1
            href = 'http://www.esparama.lt/igyvendinami-projektai?pgsz=10&order=&page='+str(self.pagination)
            yield response.follow(href, self.parse)

    def parse_tabular(self, response):
        def extract_with_css(query, column_type):
            if response.css(query).extract_first():
                if column_type == 'projekt_status':
                    return converter.handle(response.css(query).extract_first()).replace('|', '').replace('**Projekto būsena:** ','').replace('\n', ' ').strip()
                if column_type == 'beneficiary':
                    return converter.handle(response.css(query).extract_first()).replace('|', '').replace('**Projekto vykdytojas:** ','').replace('\n', ' ').strip()
                if column_type == 'start_date':
                    return converter.handle(response.css(query).extract_first()).replace('|', '').split('**Projekto pabaiga:**')[0].replace('**Projekto pradžia:** ','').replace('\n', ' ').strip()
                if column_type == 'end_date':
                    try:
                      resp = converter.handle(response.css(query).extract_first()).replace('|', '').split('**Projekto pabaiga:**')[1].replace('\n', ' ').strip()
                    except:
                        resp = ''
                    return resp
                if column_type == 'total_value':
                    return converter.handle(response.css(query).extract_first()).replace('|', '').replace(' €**','').replace(' ','').replace(',','.').replace('\n', ' ').strip().replace('Bendraprojektovertė:  **','')
                if column_type == 'total_funding':
                    return converter.handle(response.css(query).extract_first()).replace('|', '').replace(' €**','').replace(' ','').replace(',','.').replace('\n', ' ').strip().replace('Projektuiskirtasfinansavimas:  **','')
                if column_type == 'total_paid':
                    return converter.handle(response.css(query).extract_first()).replace('|', '').replace(' €**','').replace(' ','').replace(',','.').replace('\n', ' ').strip().replace('Projektuiišmokėtalėšų:  **','')
                if column_type == 'eu_funding':
                    return converter.handle(response.css(query).extract_first()).replace('|', '').replace(' €**','').replace(' ','').replace(',','.').replace('\n', ' ').strip().replace('IšjoESdalis:  **','')
                if column_type == 'eu_paid':
                    return converter.handle(response.css(query).extract_first()).replace('|', '').replace(' €**','').replace(' ','').replace(',','.').replace('\n', ' ').strip().replace('IšjoESdalis:  **','')
                else:
                    return converter.handle(response.css(query).extract_first()).replace('|', '').replace('\n', ' ').strip()

        yield {
            'project_title': extract_with_css('h1.heading1.p-right4::text', 'project_title'),
            'projekt_status': extract_with_css('.bg-color1 tr td.text-color1.p2.p-bottom div:nth-child(1)', 'projekt_status'),
            'beneficiary': extract_with_css('.bg-color1 tr td.text-color1.p2.p-bottom div:nth-child(2)', 'beneficiary'),
            'start_date': extract_with_css('.bg-color1 tr td.text-color1.p2.p-bottom div:nth-child(3)', 'start_date'),
            'end_date': extract_with_css('.bg-color1 tr td.text-color1.p2.p-bottom div:nth-child(3)', 'end_date'),
            'total_value': extract_with_css('.bg-color1 tr:nth-child(2) td.p2:nth-child(1) div', 'total_value'),
            'total_funding': extract_with_css('.bg-color1 tr:nth-child(2) td.p2:nth-child(2) div', 'total_funding'),
            'total_paid': extract_with_css('.bg-color1 tr:nth-child(2) td.p2:nth-child(3) div', 'total_paid'),
            'eu_funding': extract_with_css('.bg-color1 tr:nth-child(3) td.p2:nth-child(1) div', 'eu_funding'),
            'eu_paid': extract_with_css('.bg-color1 tr:nth-child(3) td.p2:nth-child(2) div', 'eu_paid'),
            'description': extract_with_css('.p3.p-top2', 'description'),
            'action_program': extract_with_css('.portlet-body table.table10 tr:nth-child(1) td', 'action_program'),
            'priority_of_action_program': extract_with_css('.portlet-body table.table10 tr:nth-child(2) td', 'priority_of_action_program'),
            'priority_action_program': extract_with_css('.portlet-body table.table10 tr:nth-child(3) td', 'priority_action_program'),
            'invitation_number': extract_with_css('.portlet-body table.table10 tr:nth-child(4) td', 'invitation_number'),
            'project_code': extract_with_css('.portlet-body table.table10 tr:nth-child(5) td', 'project_code'),
            'nuts3': extract_with_css('.portlet-body table.table10 tr:nth-child(6) td', 'nuts3'),
            'lau1': extract_with_css('.portlet-body table.table10 tr:nth-child(7) td', 'lau1')
        }