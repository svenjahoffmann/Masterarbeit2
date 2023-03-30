## cut all SOLWEIG input files in 4 parts
library(sf)
library(sp)
#
library(raster)

# read the four clipping extents
shape1 <- st_read("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Gitter/1.shp")
shape2 <- st_read("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Gitter/2.shp")
shape3 <- st_read("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Gitter/3.shp")
shape4 <- st_read("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Gitter/4.shp")
st_crs(shape1) # 25832
# read in all Input data which needs to be cropped
setwd("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Input_SOLWEIG")
aspect <- raster("aspect_jena_extent.tif")
height <- raster("height_jena_extent.tif")
dsm_build <- raster("dsm_build_jena.tif")
dsm_vege <- raster("vege_jena_poly.tif")
dgm_jena <- raster("Jena_DGM_mask.tif")
landcover <- raster("landcover_jena_reclass.tif")
landcover_2 <- raster("landcover_all.tif")

st_crs(aspect) # 9001
shapes_jena <- list(shape1, shape2, shape3, shape4)

extent(shapes_jena[[1]])
st_crs(shapes_jena[[1]]) #25832
st_crs(aspect)
st_crs(landcover_2) # 9001

ext <- list()
aspect_list <- list()
height_list <- list()
dsm_build_list <- list()
dsm_vege_list <- list()
dgm_jena_list <- list()
landcover_list <- list()
landcover_2_list <- list()

for (i in 1:length(shapes_jena)){
  ext[[i]] <- extent(shapes_jena[[i]])
  aspect_list[[i]] <- crop(aspect, ext[[i]])
  height_list[[i]] <- crop(height, ext[[i]])
  dsm_build_list[[i]] <- crop(dsm_build, ext[[i]])
  dsm_vege_list[[i]] <- crop(dsm_vege, ext[[i]])
  dgm_jena_list[[i]] <- crop(dgm_jena, ext[[i]])
  landcover_list[[i]] <- crop(landcover, ext[[i]])
  writeRaster(aspect_list[[i]], paste0("aspect",i, ".tif"))
  writeRaster(height_list[[i]], paste0("height",i, ".tif"))
  writeRaster(dsm_build_list[[i]], paste0("dsm_build",i, ".tif"))
  writeRaster(dsm_vege_list[[i]], paste0("dsm_vege",i, ".tif"))
  writeRaster(dgm_jena_list[[i]], paste0("dgm_jena",i, ".tif"))
  writeRaster(landcover_list[[i]], paste0("landcover",i, ".tif"))
}
st_crs(landcover_2_list[[1]]) # 9001
extent(ext[[1]])


for (i in 1:length(shapes_jena)){
  ext[[i]] <- extent(shapes_jena[[i]])
  aspect_list[[i]] <- crop(aspect, ext[[i]])
}

for (i in 1:length(shapes_jena)){
  ext[[i]] <- extent(shapes_jena[[i]])
  dgm_jena_list[[i]] <- crop(dgm_jena, ext[[i]])
}


# haben sie unterschiedliche Pixelsize?


extent(dgm_jena_list[[1]])
extent(shapes_jena[[1]])
extent(aspect_list[[2]])
extent(aspect)
extent(landcover_2_list[[2]])
extent(shapes_jena[[2]])




for (i in 1:length(shapes_jena)){
  ext[[i]] <- extent(shapes_jena[[i]])
  landcover_2_list[[i]] <- crop(landcover_2, ext[[i]])
  writeRaster(landcover_2_list[[i]], paste0("landcover_2_",i, ".tif"), overwrite = TRUE)
}
Sys.setenv(lang = "en_US")
# same for svf

# get list of svf tifs
setwd("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/SVF_test3")
all_svf <- list.files(pattern = "*.tif")
all_svf
svf <- raster("svf.tif")
svfaveg <- raster("svfaveg.tif")
svfE <- raster("svfE.tif")
svfEaveg <- raster("svfEaveg.tif")
svfEveg <- raster("svfEveg.tif")
svfN <- raster("svfN.tif")
svfNveg <- raster("svfNveg.tif")
svfS <- raster("svfS.tif")
svfSaveg <- raster("svfSaveg.tif")
svfSveg <- raster("svfSveg.tif")
svfveg <- raster("svfveg.tif")
svfW <- raster("svfW.tif")
svfWaveg <- raster("svfWaveg.tif")
svfWveg <- raster("svfWveg.tif")



svf_list <- list()
svfaveg_list <- list()
svfE_list <- list()
svfEaveg_list <- list()
svfEveg_list <- list()
svfN_list <- list()
svfNveg_list <- list()
svfS_list <- list()
svfSaveg_list <- list()
svfSveg_list <- list()
svfveg_list <- list()
svfW_list <- list()
svfWaveg_list <- list()
svfWveg_list <- list()

# alle in svf vierteln
for (i in 1:length(shapes_jena)){
  ext[[i]] <- extent(shapes_jena[[i]])
  svf_list[[i]] <- crop(svf, ext[[i]])
  svfaveg_list[[i]] <- crop(svfaveg, ext[[i]])
  svfE_list[[i]] <- crop(svfE, ext[[i]])
  svfEaveg_list[[i]] <- crop(svfEaveg, ext[[i]])
  svfEveg_list[[i]] <- crop(svfEveg, ext[[i]])
  svfN_list[[i]] <- crop(svfN, ext[[i]])
  svfNveg_list[[i]] <- crop(svfNveg, ext[[i]])
  svfS_list[[i]] <- crop(svfS, ext[[i]])
  svfSaveg_list[[i]] <- crop(svfSaveg, ext[[i]])
  svfSveg_list[[i]] <- crop(svfSveg, ext[[i]])
  svfveg_list[[i]] <- crop(svfveg, ext[[i]])
  svfW_list[[i]] <- crop(svfW, ext[[i]])
  svfWaveg_list[[i]] <- crop(svfWaveg, ext[[i]])
  svfWveg_list[[i]] <- crop(svfWveg, ext[[i]])
  
  
  writeRaster(svf_list[[i]], paste0("svf",i, ".tif"))
  writeRaster(svfaveg_list[[i]], paste0("svfaveg",i, ".tif"))
  writeRaster(svfE_list[[i]], paste0("svfE",i, ".tif"))
  writeRaster(svfEaveg_list[[i]], paste0("svfEaveg",i, ".tif"))
  writeRaster(svfEveg_list[[i]], paste0("svfEveg",i, ".tif"))
  writeRaster(svfN_list[[i]], paste0("svfN",i, ".tif"))
  writeRaster(svfNveg_list[[i]], paste0("svfNveg",i, ".tif"))
  writeRaster(svfS_list[[i]], paste0("svfS",i, ".tif"))
  writeRaster(svfSaveg_list[[i]], paste0("svfSaveg",i, ".tif"))
  writeRaster(svfSveg_list[[i]], paste0("svfSveg",i, ".tif"))
  writeRaster(svfveg_list[[i]], paste0("svfveg",i, ".tif"))
  writeRaster(svfW_list[[i]], paste0("svfW",i, ".tif"))
  writeRaster(svfWaveg_list[[i]], paste0("svfWaveg",i, ".tif"))
  writeRaster(svfWveg_list[[i]], paste0("svfWveg",i, ".tif"))
}
  
  


