################################################################################
## landcover preprocess ########################################################
################################################################################

library(sf)
library(raster)
# convert Polygon to Raster
# delete tree, because only landcover on the ground is counting in SOLWEIG
# fill empty tree pixels with surrounding values
# use raster as Input for SOLWEIG landcover scheme

# set wd
setwd("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover")

# load landcover 
# landcover_klein <- read_sf("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_klein.shp")
ec2u_landcover <- read_sf(dsn="C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/ec2u_land_dissolve.shp")
st_crs(ec2u_landcover) #25832
extent(ec2u_landcover)
# names(landcover_klein)
# delete "Baum"
land_notree_shp <- subset(ec2u_landcover, Klasse_aa != "Baum")
st_crs(land_notree_shp)
# convert class "Andere" to "versiegelter Boden" (paved) -> Bahngleise usw -> versiegelt
land_notree_shp$Klasse_aa[land_notree_shp$Klasse_aa=="Anderes"] <- "versiegelter Boden"
# View(land_notree_shp)
## convert to raster
# define extent
#ext <- extent(ec2u_landcover)
merged_DSM <- raster("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/DGM_DOM/DOM_tif/Jena_DSM.tif")

st_crs(merged_DSM)
extent(merged_DSM)
extent(land_notree_shp)
crs(merged_DSM) <- crs(land_notree_shp)
st_crs(merged_DSM)


# vorher alles zu 9001, weil das scheinbar das präferierte crs von r ist 
# 9001 , warum?
#extent(ec2u_landcover)
extent(ext)
#plot(land_notree_shp)
#create empty raster with right extent and resolution



# convert to raster
# takes long
# ohn fun= Argument, sonst kommt grade ein Fehler
st_crs(land_notree_shp) #25832
crs <- 9001
### alles mit 9001 versuchen
## alles auf 9001 setzen mit:
st_crs(land_notree_shp)<- crs
st_crs(land_notree_shp)
crs(merged_DSM) <- crs
st_crs(merged_DSM)

ext <- extent(merged_DSM) # writeRaster(merged_DSM, paste0("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/DGM_DOM/DOM_tif/", "Jena_DSM.tif"), verbose = TRUE)

land_raster <- raster(ext, res=1, crs = crs(merged_DSM)) # res: 1*1 -> an welchem Punkt ändert sich das? weil bei landcover ist dasnn nicht mehr 1+*1 sondern 1,0607*1,1517
st_crs(land_raster)
res(land_raster)
extent(land_raster)
st_crs(land_raster)
res(land_raster) # 1*1, wieso ändert sich das?
extent(land_raster)
st_crs(land_raster)
# class as factor 
land_notree_shp$Klasse_aa <- as.factor(land_notree_shp$Klasse_aa)
st_crs(land_notree_shp)

land_notree_ras_9001 <- rasterize(land_notree_shp, land_raster, field = "Klasse_aa", fun = "min", overwrite = TRUE)

res(land_notree_ras)
st_crs(land_notree_ras)
# von 9001 in 25832
crs_25832 <- 25832
crs(crs_25832)
?st_transform
land_notree_ras_25832 <- projectRaster(land_notree_ras,
                                       crs = crs_25832)
st_crs(land_notree_ras_25832)
extent(land_notree_ras_25832)
extent(land_notree_ras)

res(land_notree_ras_25832)
res(land_notree_ras)
# convert back to 25832 oder alle anderen in 9001 konverteiren
land_notree_ras_res <- rasterize(land_notree_shp, land_raster, res = 1, field = "Klasse_aa", fun = "min", overwrite = TRUE)

# st_transform wieder von 9001 zu 25832 ändern und schauen, ob 
# RSAGA: Shapefile to Grid
# terra::rasterize


# oder sonst land_notree_ras zu 25832 konvertieren und cellsize abchecken
y
res(land_notree_ras)
extent(land_notree_ras)
res(land_notree_ras)
st_crs(land_notree_ras)
plot(land_notree_ras)
extent(land_notree_ras) <- extent(land_raster)
extent(land_notree_ras)

# export
writeRaster(land_notree_ras, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/land_notree_ras_jena_res.tif", overwrite = TRUE)
land_notree_ras <- raster("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/land_notree_ras_jena_5.tif")
res(land_notree_ras) # warum ist die resolution so blöd


#plot(land_notree_ras)
st_crs(land_notree_ras) #9001 -> warum -> vllt muss alles davor 9001 sein, damit die resolution sich nicht verzerrt
# rasteroze nimmt kein CRS Argument

## fill empty pixels shapefiles of landcover classes from Basis DLM
wald <- read_sf("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/landcover/veg02_f.shp")
wasser <- read_sf("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/landcover/gew01_f.shp")
landw <- read_sf("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/landcover/veg01_f.shp")
heide <- read_sf("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/landcover/veg03_f.shp")
vegemerkmal <- read_sf("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/landcover/veg04_f.shp")
st_crs(wald) #25832

# only keep
# LAND, MODELLART, OBJART, geometry
keep <- c("LAND","MODELLART", "OBJART", "geometry")
wald <- wald[keep]
st_crs(wald) #25832
wasser <- wasser[keep]
landw <- landw[keep]
heide <- heide[keep]
vegemerkmal <- vegemerkmal[keep]

# merge 
cut <- list(wald, landw, heide, vegemerkmal)
st_crs(cut[[1]]) #25832
cut_all <- do.call(rbind, cut)
st_crs(cut_all) # 25832

# wasser einzeln lassen, weil es nicht zu 2 wird sondern 1

# Landcover Daten von Urabn Atlas 2018 Copernicus mit einbeziehen um weitere NAs zu füllen:
urban_atlas <- read_sf("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_urban_atlas.shp")
# change crs from EPSG:3035 to 25832
st_crs(urban_atlas) #3035
st_crs(jena_gemeinde) #25832
class(jena_gemeinde)
urban_atlas <- st_transform(urban_atlas, crs = 25832) #25832

# merge all Gras classes into one
# select the gras classes
#urban_atlas

#unique(urban_atlas$class_2018)

# select all classes which should become grass
urban_atlas_gras <- urban_atlas[urban_atlas$class_2018 %in% c("Forests", "Sports and leisure facilities", "Green urban areas", "Discontinuous medium density urban fabric (S.L. : 30% - 50%)", "Discontinuous very low density urban fabric (S.L. : < 10%)", "Discontinuous low density urban fabric (S.L. : 10% - 30%)", "Pastures"), ]
#st_crs(urban_atlas_gras) #25832

# hat nicht geklappt das auszufüllen,
write_sf(urban_atlas_gras, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_urban_atlas_gras.shp")
#plot(urban_atlas_gras)

# select class to become bare soil
urban_atlas_bare <- (urban_atlas[urban_atlas$class_2018 == "Mineral extraction and dump sites",])
#st_crs(urban_atlas_bare) #25832
#plot(urban_atlas_bare)

# merge Basis DLM Data with gras
cut <- list(wald, landw, heide, vegemerkmal)
cut_all <- do.call(rbind, cut)


# Jena Gemeinde shapefile verwenden -> auch einalden
jena_gemeinde <- read_sf("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/Gebietsuebersichten_Thueringen/th-etrs89utm_gmd.shp", crs = 25832)
jena_gemeinde<- jena_gemeinde$geometry[jena_gemeinde$GMD== "Jena"]
#st_crs(jena_gemeinde)
jena_gemeinde_sp <- as(jena_gemeinde, "Spatial")

# Polygon zu raster und set extent
# Zuschneiden von "wald" auf den Extent von "land_notree_ras"

cut_all_sp <- as(cut_all, "Spatial")
#st_crs(cut_all_sp) #25832
#st_crs(jena_gemeinde_sp)
cut_all_clip <- crop(cut_all_sp, jena_gemeinde_sp)
#st_crs(cut_all_clip) #9001 -> warum, cut_all_sp und jena_gemeinde_sp haben beide 25832
class(cut_all_clip)
# assign crs 25832
crs(cut_all_clip) <- crs(cut_all_sp)

#######
#### hier weitermachen
#wald_sp <- as(wald, "Spatial")
#wald_clip <- crop(wald_sp, jena_gemeinde_sp)

wasser_sp <- as(wasser, "Spatial")
wasser_clip <- crop(wasser_sp, jena_gemeinde_sp)
#st_crs(wasser_clip) #9001 -> durch crop ändert sich crs, warum?
# assign crs
crs(wasser_clip) <- crs(cut_all_sp)

# clip to jena gemeinde extent
urban_atlas_gras_sp <- as(urban_atlas_gras, "Spatial")
urban_atlas_gras_clip <- crop(urban_atlas_gras_sp, jena_gemeinde_sp)
#st_crs(urban_atlas_gras_clip)
crs(urban_atlas_gras_clip) <- crs(cut_all_sp)


urban_atlas_bare_sp <- as(urban_atlas_bare, "Spatial")
urban_atlas_bare_clip <- crop(urban_atlas_bare_sp, jena_gemeinde_sp)
crs(urban_atlas_bare_clip) <- crs(cut_all_sp)

#landw_sp <- as(landw, "Spatial")
#landw_clip <- crop(landw_sp, jena_gemeinde_sp)

#heide_sp <- as(heide, "Spatial")
#heide_clip <- crop(heide_sp, jena_gemeinde_sp)

#vegemerkmal_sp <- as(vegemerkmal, "Spatial")
#vegemerkmal_clip <- crop(vegemerkmal_sp, jena_gemeinde_sp)

# dissolve classes 
cut_all_clip_sf <- st_as_sf(cut_all_clip)
#st_crs(cut_all_clip_sf)
cut_all_dissolved <- st_combine(cut_all_clip_sf)
#st_crs(cut_all_dissolved)
cut_all_dis_dis <- st_cast(cut_all_dissolved, "POLYGON")
#st_crs(cut_all_dis_dis)
cut_all_dis_dis <- st_as_sf(cut_all_dis_dis)



######################

wasser_clip_sf <- st_as_sf(wasser_clip)
wasser_dissolved <- st_combine(wasser_clip_sf)
wasser_dis_dis <- st_cast(wasser_dissolved, "POLYGON")
# Dissolvieren von "wald" nach einer Attributsvariable (z.B. "id")
wasser_dis_dis <- st_as_sf(wasser_dis_dis)
#st_crs(wasser_dis_dis)


urban_atlas_gras_clip_sf <- st_as_sf(urban_atlas_gras_clip)
urban_atlas_gras_dissolved <- st_combine(urban_atlas_gras_clip_sf)
urban_atlas_gras_dis_dis <- st_cast(urban_atlas_gras_dissolved, "POLYGON")
urban_atlas_gras_dis_dis <- st_as_sf(urban_atlas_gras_dis_dis)


urban_atlas_bare_clip_sf <- st_as_sf(urban_atlas_bare_clip)
urban_atlas_bare_dissolved <- st_combine(urban_atlas_bare_clip_sf)
urban_atlas_bare_dis_dis <- st_cast(urban_atlas_bare_dissolved, "POLYGON")
urban_atlas_bare_dis_dis <- st_as_sf(urban_atlas_bare_dis_dis)


# add column with value 2 for grass
#wald_dis_dis$value <- 2 #gras
wasser_dis_dis$value <- 5 # wasser
#landw_dis_dis$value <- 2 #gras
#heide_dis_dis$value <- 2 # gras
#vegemerkmal_dis_dis$value <- 2 # gras
cut_all_dis_dis$value <- 2
urban_atlas_bare_dis_dis$value <- 3
urban_atlas_gras_dis_dis$value <- 2
#st_crs(urban_atlas_gras_dis_dis)
##
## hier weitermachen
###
write_sf(cut_all_dis_dis, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/cut_all_dis.shp", overwrite = TRUE)
write_sf(wasser_dis_dis, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/wasser_dis.shp", overwrite = TRUE)

# Rasterisieren von "wald_dissolve"
summary(land_notree_ras) # 119944790
land_notree_ras
st_crs(land_notree_ras)
wasser_ras_jena <- rasterize(wasser_dis_dis, land_notree_ras, field = "value", update = TRUE, updateValue = 'NA')
summary(wasser_ras_jena)
extent(wasser_ras_jena)# 119384005 NAs
st_crs(wasser_ras_jena)
st_crs(wasser_dis_dis)
cut_all_ras_jena <- rasterize(cut_all_dis_dis, wasser_ras_jena, field = "value", update = TRUE, updateValue ='NA')
summary(cut_all_ras_jena) #13169415
urban_atlas_gras_jena<- rasterize(urban_atlas_gras_dis_dis, cut_all_ras_jena, field = "value", update = TRUE, updateValue ='NA')
summary(urban_atlas_gras_jena) #12438585
landcover_ras_jena_fill_all<- rasterize(urban_atlas_bare_dis_dis, urban_atlas_gras_jena, field = "value", update = TRUE, updateValue ='NA')
summary(landcover_ras_jena_fill_all) #12358990
writeRaster(landcover_ras_jena_fill_all, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_ras_jena_fill_all_extent.tif",
            overwrite = TRUE)
#landcover_ras_jena_fill_all_extent ist aktuelles

# außerhalb auf 99 setzen
jena_gemeinde_sf <- st_as_sf(jena_gemeinde)
#class(jena_gemeinde_sf)
jena_gemeinde_ras <- rasterize(jena_gemeinde_sf, landcover_ras_jena_fill_all)
landcover_ras_jena_fill_all_2<-landcover_ras_jena_fill_all
landcover_ras_jena_fill_all_2[is.na(jena_gemeinde_ras)] <- 99
#summary(landcover_ras_jena_fill_all_2) # 8341233

# check pixel count of the single values, to get sure that 99 is not getting more
# dauert irgendwie lang
#length(landcover_ras_jena_fill_all_2[landcover_ras_jena_fill_all_2$layer==1]) #5192611
#length(landcover_ras_jena_fill_all_2[landcover_ras_jena_fill_all_2$layer==2]) #
#length(landcover_ras_jena_fill_all_2[landcover_ras_jena_fill_all_2$layer==99]) #

writeRaster(landcover_ras_jena_fill_all_2, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_ras_jena_fill_all_2_extent.tif", overwrite = TRUE)
landcover_load <- raster("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_ras_jena_fill_all_2_extent.tif")
st_crs(landcover_load)
extent(landcover_load)

crs(landcover_load)<- crs(merged_DSM)
st_crs(landcover_load)
extent(landcover_load)
# fill NA
# aufpassen, dass die NA nicht mit 99 gefüllt werden

landcover_ras_jena_filled_7 <- focal(landcover_ras_jena_fill_all_2, w=matrix(1,7,7), fun=modal, na.rm=TRUE, pad=TRUE)
writeRaster(landcover_ras_jena_filled_7, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_ras_jena_filled_7_extent.tif",
            overwrite=TRUE)
#landcover_7_load<- raster("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_ras_jena_filled_7_extent.tif")
#extent(landcover_7_load)
##
##

summary(landcover_ras_jena_filled_7)
# nochmal durchführen:
landcover_ras_jena_filled_7_2 <- focal(landcover_ras_jena_filled_7, w=matrix(1,7,7), fun=modal, na.rm=TRUE, pad=TRUE)
summary(landcover_ras_jena_filled_7_2)
writeRaster(landcover_ras_jena_filled_7_2, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_ras_jena_filled_7_2_extent.tif",
            overwrite=TRUE)
summary(landcover_ras_jena_filled_7_2)
##

#
#
landcover_ras_jena_filled_7_3 <- focal(landcover_ras_jena_filled_7_2, w=matrix(1,7,7), fun=modal, na.rm=TRUE, pad=TRUE)
summary(landcover_ras_jena_filled_7_3)
writeRaster(landcover_ras_jena_filled_7_3, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_ras_jena_filled_7_3_extent.tif",
            overwrite=TRUE)
landcover_ras_jena_filled_7_4 <- focal(landcover_ras_jena_filled_7_3, w=matrix(1,7,7), fun=modal, na.rm=TRUE, pad=TRUE)
summary(landcover_ras_jena_filled_7_4)
writeRaster(landcover_ras_jena_filled_7_4, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_ras_jena_filled_7_4_extent.tif",
            overwrite=TRUE)



# 7_4 hat keine NAs mehr 
# 99 zu NA machen
landcover_ras_jena_filled_7_4_na <- landcover_ras_jena_filled_7_4
landcover_ras_jena_filled_7_4_na
landcover_ras_jena_filled_7_4_na[landcover_ras_jena_filled_7_4_na == 99] <- NA
writeRaster(landcover_ras_jena_filled_7_4_na, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_ras_jena_filled_7_4_na_extent.tif",
            overwrite=TRUE)
landcover_74_load <- raster("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_ras_jena_filled_7_4_na_extent.tif")
extent(landcover_74_load)
st_crs(landcover_74_load)
crs(landcover_74_load) <- crs(merged_DSM)
st_crs(landcover_74_load)
extent(landcover_74_load)
writeRaster(landcover_74_load, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_all.tif")
