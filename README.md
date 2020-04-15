### Modis 数据爬取
*ModisSpider.py*：如下示例,依次是产品ID，开始的年份-结束年份，1-361是开始天数到截至天数其中8是时间间隔(建议不用修改)，研究区MODIS的行列号
python ModisSpider.py MOD09A1,2006-2016,1-361-8,h26v05-h26v04-h27v04-h27v05

*McdSpider.py*：对于MODIS分类产品（MCD12Q1）爬取
python MCDSpider.py MCD12Q1,2006-2016,h26v05-h26v04-h27v04-h27v05

*Modis.zip*: Modis数据全国行列号
如上爬取的只是影像的链接，可以通过迅雷下载，也可以在服务器下载（微软服务器测试可以达到10m/s）
服务器下载： screen -l wget -i 下载链接.txt
将数据传回电脑 scp username@ip:path localpath 其中path是服务器路径，localpath是本地路径

### Sentinel 数据爬取
https://pypi.org/project/sentinelsat/
可以下载哨兵1,2,3，速度十分快，命令行操作十分简单，容易上手
