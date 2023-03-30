# create Point Shapefile with points instead of Rasterpixel 
library(sf)
library(sp)
library(raster)
library(terra)
# load raster with right extent and pixel size
ras <- raster("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/DGM_DOM/DOM_tif/Jena_DSM.tif",
              crs = "+init=epsg:25832")
gitter <- st_read("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/gemeinde_gitter/gitter_jena_4.shp")
plot(gitter)
# split into single polygons 
# get the names of the attribute table
names(gitter)

# select the column of the attribute table that will determine the split of the shp
unique <- unique(gitter$id)
library(rgdal)
setwd("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Gitter")
# create new polygons based on the determined column
for (i in 1:length(unique)) {
  tmp <- gitter[gitter$id == unique[i], ]
  st_write(tmp, dsn=getwd(), unique[i], driver="ESRI Shapefile", overwrite_layer=TRUE)
}

# load single Shapefiles as list

shape1 <- st_read("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Gitter/1.shp")
shape2 <- st_read("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Gitter/2.shp")
shape3 <- st_read("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Gitter/3.shp")
shape4 <- st_read("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Gitter/4.shp")
plot(shape)
shapes_jena <- list(shape1, shape2, shape3, shape4)
class(shapes_jena[[i]])

ext <- list()
rasterpoints <- list()
for (i in 1:length(shapes_jena)){
  ext[[i]] <- extent(shapes_jena[[i]])
  rasterpoints[[i]] <- crop(ras, ext[[i]])
}
class(rasterpoints[[i]])

POIs <- list()
POIs_sf <- list()
for (i in 1:length(rasterpoints)){
  POIs[[i]] <- rasterToPoints(rasterpoints[[i]], spatial = TRUE)
  POIs_sf[[i]] <- st_as_sf(POIs[[i]])
  st_write(POIs_sf[[i]], overwrite = TRUE, )
  POIs[[i]] <- rasterToPoints(rasterpoints[[i]],paste0("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Input_SOLWEIG/","POI", i, ".shp"), spatial = TRUE)
}

POIs_sf <- st_as_sf(POIs)
class(POIs_sf)
class(POIs)
summary(POIs)

library(rgdal)
st_write(POIs, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Input_SOLWEIG/POis.shp", overwrite =TRUE)
ogrDrivers
class(POIs)
