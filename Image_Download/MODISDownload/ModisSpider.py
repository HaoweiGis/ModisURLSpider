# https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/6/MOD13A1/2002/?process=ftpAsHttp&path=allData%2f6%2fMOD13A1%2f2002
# https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/6/

import requests
from bs4 import BeautifulSoup
import re
import sys


class ModisSpider():
    def __init__(self, modType, year, day, ImageId):
        self.urlBase = 'https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/6/'
        self.modType = modType
        self.year = year
        self.day = day
        self.ImageId = ImageId.split('-')
        self.headers = {
            'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/\
            537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36'
        }

    def StructureUrl(self):
        YearArr = self.year.split('-')
        DayArr = self.day.split('-')
        UrlArr = []
        for year in range(int(YearArr[0]), int(YearArr[1]) + 1):
            for Daytime in range(
                    int(DayArr[0]),
                    int(DayArr[1]) + int(DayArr[2]), int(DayArr[2])):
                # print(Daytime)
                if Daytime < 10:
                    Daytime = '00' + str(Daytime)
                elif Daytime < 100:
                    Daytime = '0' + str(Daytime)
                else:
                    Daytime = Daytime
                self.url = self.urlBase + self.modType + '/' + str(
                    year) + '/' + str(Daytime)
                # print(self.url)
                UrlArr.append(self.url)
        # print(UrlArr)
        return UrlArr

    def ModTypeSelect(self):
        UrlArr = self.StructureUrl()
        UrlNewArr = []
        for url in UrlArr:
            Response = requests.get(url, headers=self.headers)
            Soup = BeautifulSoup(Response.text, 'html.parser')
            Sclass = Soup.findAll('a')
            # print(Sclass)
            for Atag in Sclass:
                # print(Atag.string)
                for imge in self.ImageId:
                    if re.search(str(imge), str(Atag.string)):
                        urlNew = url + '/' + Atag.string
                        print(urlNew)
                        UrlNewArr.append(urlNew)
        for line in UrlNewArr:
            filename = self.modType + '_' + self.year + '_' + '-'.join(self.ImageId) + '.txt'
            FileWrite(filename, line+'\n')


def FileWrite(filename, lineW):
    with open(filename, 'a', encoding='utf-8') as f:
        f.write(lineW)
        f.close()


if __name__ == '__main__':     #python ModisSpider.py MOD09A1,2006-2016,1-361-8,h26v05-h26v04-h27v04-h27v05
    DataIndex = sys.argv[-1].split(',')
    modType = DataIndex[0]
    year = DataIndex[1]
    day = DataIndex[2]
    ImageId = DataIndex[3]
    # modType = 'MOD13A1'
    # year = '2006-2016'
    # day = '1-353-16'
    # ImageId = 'h27v05'
    ModisSpider(modType, year, day, ImageId).ModTypeSelect()
