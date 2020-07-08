// 影像归一化
var minMax = newImage.reduceRegion({
    reducer: ee.Reducer.minMax(),
    geometry: geometry2,
    scale: 1000,
    maxPixels: 10e9,
  }); 
  // use unit scale to normalize the pixel values
  var unitScaleImg = ee.ImageCollection.fromImages(
    newImage.bandNames().map(function(name){
      name = ee.String(name);
      var band = newImage.select(name);
      return band.unitScale(ee.Number(minMax.get(name.cat('_min'))), ee.Number(minMax.get(name.cat('_max'))))
                  // eventually multiply by 100 to get range 0-100
                  //.multiply(100);
  })).toBands().rename(newImage.bandNames());
  Map.addLayer(unitScaleImg)

// 同一区域的Image进行波段合并
var dataStart = ee.Date('2002-07-01')
var dataStop = ee.Date('2002-12-30')
var monthNum = dataStop.difference(dataStart,'month')
print(monthNum)
for (var i=0;i<monthNum.getInfo();i++)
{
    var dateRange = dataStart.getRange('month')
    var cld = imageCollection
        .filterDate(dateRange).select('NDVI')
    print(cld)
    var bandname = dataStart.format("yyyy-MM-dd").getInfo()
    var imgcld = cld.max().clip(roi).rename(bandname)
    var dataStart = dataStart.advance(1,'month')
    if (i === 0) {
        var Img = imgcld
    }else{
        var Img = Img.addBands(imgcld)
    }
}
print(Img)
  
// 影像导出
Export.image.toDrive({
image: PostModeImg,
description: 'UrbanImage_lanzhou',
scale: 10,
region: Urbanshp,
maxPixels:1e13,
crs: 'EPSG:4326'
});

// 多个区域的数据导出
var ExportImage = function(RESIImg,id,name){
    var FishnetS = Fishnet.filter(ee.Filter.eq('Id',id)).geometry()
    // var FishnetS = geometry
  Export.image.toDrive({
    image: RESIImg.clip(FishnetS),
    description: name,
    scale: 100,
    region: FishnetS,
    maxPixels:1e13,
    crs: 'EPSG:4326'
  });
  }
  
  ExportImage(RESIImg,1,'H1RESIImage1')

// 将ImageCollection循环显示加载
var Imgs = Sentinel2A.filterBounds(bounds_xian)
.filterDate('2019-06-01','2019-10-01')
.filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE',5))
print(Imgs)
var ImgList = Imgs.toList(Imgs.size())

for (var i = 0; i < Imgs.size().getInfo(); i++) {
  var image = ee.Image(ImgList.get(i))
  var imageID = image.get('PRODUCT_ID').getInfo()
  var visParams = {bands: 'B4,B3,B2', min: 97.36329499846, max: 2562.3, gamma: 1.5}
  Map.addLayer(image, visParams,imageID)
}