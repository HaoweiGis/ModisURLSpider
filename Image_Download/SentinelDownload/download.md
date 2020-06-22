`screen -L sentinelsat -u ** -p ** -g map.geojson --sentinel 2 -s 20200331 -e 20200415 --cloud 50 -d`<br />

sentinelsat只能下载哥白尼未归档的在线数据，离线数据可以从https://scihub.copernicus.eu/userguide/LongTermArchive请求<br />


https://sen2mosaic.readthedocs.io/en/latest/setup.html#installing-sen2cor


channels:
  - https://mirrors.ustc.edu.cn/anaconda/pkgs/main/
  - https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
  - https://repo.continuum.io/pkgs/main
  - defaults
show_channel_urls: true
————————————————
版权声明：本文为CSDN博主「漠北尘-Gavin」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/xrinosvip/article/details/89738521