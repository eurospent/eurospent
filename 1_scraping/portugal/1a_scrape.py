
from urllib.request import urlretrieve
import xlrd
import csv

urlretrieve ("http://www.qren.pt/np4/%7B$clientServletPath%7D/?newsId=3001&fileName=Lista_de_projetos_QREN_Set16.xlsx", "1b_result.xls")


def csv_from_excel():
    wb = xlrd.open_workbook('1b_result.xls')
    sh = wb.sheet_by_name('Lista QREN Set16')
    your_csv_file = open('1b_result.csv', 'w')
    wr = csv.writer(your_csv_file, quoting=csv.QUOTE_ALL)

    for rownum in range(sh.nrows):
        wr.writerow(sh.row_values(rownum))

    your_csv_file.close()

# runs the csv_from_excel function:
csv_from_excel()