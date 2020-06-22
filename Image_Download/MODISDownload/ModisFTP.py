import os
import requests
import re
import urllib
from ftplib import FTP
import sys
import re
# 'MOD09A1.A2010105.h10v04.006.2015207023933.hdf'
#python wget.py MYD11A2 2006 2015 41 289 8 h09v05_h09v06_h10v04_h10v05_h10v06_h11v04_h11v05_h12v04_h12v05
def FtpDownLoad(ftpFile,allindex):
    dirs = str(ftpFile).split("/")
    # print(dirs)
    if len(dirs) < 4:
        return False
    server = dirs[2]
    # print(server)
    srcFile = ""
    for item in dirs[3:]:
        srcFile += "/" + str(item)
    print(srcFile)
    ftp = FTP(server)
    ftp.connect(server)
    ftp.login('anonymous','Recar@Recar.com')
    ftp.cwd(os.path.dirname(srcFile).lstrip("/"))
    modis_group = ftp.nlst()
    modis = []
    allindex = allindex.split('_')
    for sigle in modis_group:
        for index in allindex:
            if re.search(str(index),str(sigle)):
                modis.append(sigle)
    for i in range(len(modis)):
        url_single = ftpFile + modis[i]
        print(url_single)
    # url2 = ftpFile + modis[1]
        url.append(url_single)
    # url.append(url2)

    #print(url)




if __name__ == "__main__":#python wegt.py MOD09A1 2006 2013 41 289 8

    ftpFile = 'ftp://ladsweb.nascom.nasa.gov/allData/6/MYD11A2/2009/97/'
    dirs = str(ftpFile).split("/")
    url , pathsum = [],[]
    #satellite,from year,to year ,from day , to day,day time
    satellite = sys.argv[1]
    dirs[5] = satellite
    print('start download:',satellite)
    from_year, to_year, from_day, to_day, day_time = sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5],sys.argv[6]
    index= sys.argv[7]

    for year in range(int(from_year),int(to_year)+1):
        dirs[6] = year
        for day in range(int(from_day),int(to_day)+int(day_time),int(day_time)):
            print(day)
            if day <10:
                dirs[7] = '00'+str(day)
            elif day <100:
                dirs[7] = '0'+str(day)
            else:
                dirs[7] = day
            path = '/'.join(str(i) for i in dirs)
            pathsum.append(path)
            # print(dirs[7])
            # print(dirs)
    # print(pathsum)

    for i in pathsum:
        FtpDownLoad(i,index)

    for i in url:

        file = open('modis_url.txt', 'a')
        file.writelines( i + '\n')
    # print(url)
    print('ok')

    # modis = os.system()
