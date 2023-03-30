################################################################################
## merge 154 downloaded rectangles of DSM and DEM from geoporthal Thüringen ####
## DSM - DEM to only get the meters above elevation of ground ##################
## create building dsm with building shapefile as mask #########################
## create vegetation dsm with landcover shapefile without vegetation as mask ###
################################################################################
# ppush
# load rasters
library(raster)
library(tiff)
library(sf)
library(rgdal)
library(stars)
library(terra)

Sys.setenv(lang = "en_US")

################################################################################
# load data ####################################################################
################################################################################

## DSM
setwd("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/DGM_DOM/DOM_xyz")
xyz_files_DSMa = list.files(getwd())

# convert xyz to raster (tif)
ras_DSMa <- list()
for (i in 1:length(xyz_files_DSMa)) {
  print(i)
  print(length(xyz_files_DSMa))
  xyz_file_DSMa = read.table(xyz_files_DSMa[i], header=F, dec=".")
  #print(head(xyz_file))
  print("loaded...")
  ras_DSMa[[i]] = rasterFromXYZ(xyz_file_DSMa, res=c(1,1), crs=25832, digits=5)
} #154

## DEM
# find a better solution instead of setwd() again
setwd("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/DGM_DOM/DGM_xyz")
xyz_files_DEMa = list.files(getwd())

# convert xyz to raster (tif)
ras_DEMa <- list()
for (i in 1:length(xyz_files_DEMa)) {
  print(i)
  print(length(xyz_files_DEMa))
  xyz_file_DEMa = read.table(xyz_files_DEMa[i], header=F, dec=".")
  print("loaded...")
  ras_DEMa[[i]] = rasterFromXYZ(xyz_file_DEMa, res=c(1,1), crs=25832, digits=5)
}

# check crs
st_crs(ras_DSMa[[1]])

# merge all raster in the list
merged_DSM <- do.call(merge, ras_DSMa)
merged_DEM <- do.call(merge, ras_DEMa)

# export 
writeRaster(merged_DSM, paste0("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/DGM_DOM/DOM_tif/", "Jena_DSM.tif"), verbose = TRUE)
writeRaster(merged_DEM, paste0("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/DGM_DOM/DGM_tif/", "Jena_DGM.tif"), verbose = TRUE)

## Merge Orthophotos
# load and read orthophotos
setwd("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/Luftbilder/tifs")
tifs_ortho = list.files(getwd())

tifs_ortho_list <- list()
length(tifs_ortho)
for (i in 1:length(tifs_ortho)) {
  print(i)
  print(length(tifs_ortho))
  
  tifs_ortho_list[[i]] = raster(tifs_ortho[i], header=F, dec=".")
}

merged_ortho <- do.call(merge, tifs_ortho_list)
writeRaster(merged_ortho, paste0("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Luftbilder/", "Jena_ortho.tif"), verbose = TRUE,
            compress="lzw", overwrite = TRUE)

################################################################################
## Create building DSM #########################################################
################################################################################

# -> DGM-DOM -> if a pixel has negative values or values smaller 1 -> 0 
###############################################################################

# set wd to save output files
setwd("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Preprocess_out_merged")

# DSM - DEM -> only heights of buildings, trees,... no natural elevation
build_vegea_merg <- merged_DSM-merged_DEM

# export build_vegea_merg to check in qgis
# writeRaster(build_vegea_merg, "build_vegea_merg.tif")

# some values smaller 0, because of inaccuracies in data
# set values smaller 0 to 0
build_vegea_merg[build_vegea_merg <0 ]<- 0

# import buildings shapefile
buildshape_4647 <- st_read("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/buildings/gebaeude-th.shp")
st_crs(buildshape_4647)
# transform to 25832

buildshape <- st_transform(buildshape_4647, crs = 25832)
st_crs(buildshape)
#buildshape <- sf::st_read("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/buildings/gebaeude_25832.shp")

## building shape auf Raster extent zuscheniden
# erst Raster zu Polygon wegen Ausdehnung
# set all pixels to value 1
na_values <- is.na(build_vegea_merg)
jena_1<- build_vegea_merg
jena_1[!na_values] <- 1
plot(jena_1)# raster with extent of Jena with all pixel values to 1

# convert to raster class
jena_1_rast <- rast(jena_1)

# convert to polygon
jena_poly <- as.polygons(jena_1_rast)

# convert to sf
jena_poly<-st_as_sf(jena_poly)

# Clip buildshape to the polygon of jena_poly
clipped_shape <- st_intersection(buildshape, jena_poly)

# mask build_vegea_merg with buildings in Jena
dsm_build_merg <- mask(x = build_vegea_merg, mask = clipped_shape)

# plot(dsm_builda_merg)

# dsm_builda_merg: Raster with heigth of the buildings as pixel values
# fill NA's with 0
dsm_build_merg[is.na(dsm_build_merg[])] <- 0 

# auf Polygon Gemeinde zuscheniden
# ab hier alles zuschneiden auf Jena GMD extent
# weil ec2u landcover diesen extent hat
# jena gemeinde einladen
jena_gemeinde <- read_sf("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/Gebietsuebersichten_Thueringen/th-etrs89utm_gmd.shp", crs = 25832)
jena_gemeinde<-(jena_gemeinde$geometry[jena_gemeinde$GMD== "Jena"])
jena_gemeinde_sp <- as(jena_gemeinde, "Spatial")
build_vege_jena_poly <- mask(build_vegea_merg, jena_gemeinde_sp)

# mask to Jena Polygon
dsm_build_jena <- mask(dsm_build_merg, jena_gemeinde_sp)
dsm_build_jena <- raster("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Preprocess_out_merged/dsm_build_jena.tif")

# NA zu 0
dsm_build_jena_0 <- dsm_build_jena
dsm_build_jena_0 <- reclassify(dsm_build_jena_0, cbind(NA, 0))
# export, is neceessary for SOLWEIG
writeRaster(dsm_build_jena, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Preprocess_out_merged/dsm_build_jena.tif",
              format = "GTiff", overwrite = TRUE)
writeRaster(dsm_build_jena_0, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Preprocess_out_merged/dsm_build_jena_0.tif",
            format = "GTiff", overwrite = TRUE, crs = "25832")

################################################################################
## Create vegeation_dsm ########################################################
################################################################################

## create 2m buffer around buildings, to cut them out completely later
build_2_buffer <- st_buffer(clipped_shape, 2, joinStyle="MITRE",mitreLimit=3)

# set coordinate reference system 
jena_gemeinde <- st_set_crs(jena_gemeinde, st_crs(25832))

# cut the Buffer Shapefile back to the former extent
build_2_buffer_merg <- st_intersection(build_2_buffer, jena_gemeinde)

# build_2_buffer_merg ist Shapefile mit 2m gebufferten Gebäuden, um sie rauszuschneiden um nur Vegetation zu bekommen
# Gebäude rausschneiden aus build_vegea_merg

## cut out all landcover classes than tree
# dsm_build_jena_0: Raster mit Gebäuden
# build_vegea_merg: Raster mit Vegetation und Gebäuden und allen sonstigen Erhöhungen
# build_2_buffer_merg: Shapefile mit 2m gebufferten Gebäuden, zugeschnitten auf Jena Polygon


# load landcover
ec2u_landcover <- read_sf(dsn="C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/ec2u_land_dissolve.shp")
# dissolve, because of some strange geometries, in QGIS mit Vektorgeometrie -> auflösen gemacht

# keep all classes but "Baum" -> Tree
ec2u_landcover_filtereda <- ec2u_landcover[ec2u_landcover$Klasse_aa != "Baum",]

# dissolve classes 
ec2u_dissolved <- st_combine(ec2u_landcover_filtereda)
ec2u_dissolved <- st_cast(ec2u_dissolved, "POLYGON")

# convert to Sp
ec2u_dis_sp <- as(ec2u_dissolved, "Spatial")

# mask raster to vector polygon ec2u_dissolved
build_vege_ec2u <- mask(build_vege_jena_poly, ec2u_dis_sp) # build_vege_jena_poly: raster with heights of everything clipped to Jena Polygon

# NA to 0
build_vege_ec2u[is.na(build_vege_ec2u[])] <- 0 

# build_vege_ec2u is Raster without trees 
# substract build_vege_ec2u from build_vege_jena_poly
vege_ec2u <- build_vege_jena_poly - build_vege_ec2u
plot(vege_ec2u)
# export to have a closer look in QGIS
# for (i in 1:length(vege_ec2u)){
#   writeRaster(vege_ec2u[[i]], paste0("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/vegetation/", "vege_ec2u_",i, ".tif"),
#               format = "GTiff", overwrite = TRUE)
# }


# warum brauche ich das noch ?
##############################
###############################
###############################
## cut out buffered buildings to avoid remnants of buildings
# mask buffered building raster to Jena Polygon 
build_2_rastera <- mask(x = build_vege_jena_poly, mask = build_2_buffer_merg)

# NA to 0
build_2_rastera[is.na(build_2_rastera[])] <- 0 

# where build_2_rastera -> set vege_ec2u to 0 
vege_jena <- vege_ec2u
vege_jena[vege_jena > 0 & build_2_rastera > 0] <- 0

# NA to 0
vege_jena[is.na(vege_jena)] <- 0

# clip to Jena Polygon
vege_jena_poly <- mask(vege_jena, jena_gemeinde_sp)

# export
writeRaster(vege_jena_poly, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Preprocess_out_merged/vege_jena_poly.tif",
              format = "GTiff", overwrite = TRUE)


