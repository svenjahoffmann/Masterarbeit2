
# load rasters
library(raster)
library(tiff)
library(sf)# update sf package
library(rgdal)
library(stars)
library(raster)

Sys.setenv(lang = "en_US")

################################################################################
# load data ####################################################################
################################################################################

# DSM
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

# DEM
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




# merge all Raster to one
merge(myrasters[[1]], myrasters[[10]])
# ras_DSMa

library(raster)
library(sf)
st_crs(ras_DSMa[[1]])

# merge rasters in the list
merged_DSM <- do.call(merge, ras_DSMa)
class(merged_DSM)
# export and check filesize
writeRaster(merged_DSM, paste0("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/DGM_DOM/DOM_tif/", "Jena_DSM.tif"), verbose = TRUE)
# plit in 5
length(merged_DSM) # Number of Pixels 221.000.000

## same for DEM

# merge rasters in the list
merged_DEM <- do.call(merge, ras_DEMa)

# export and check filesize
writeRaster(merged_DEM, paste0("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/DGM_DOM/DGM_tif/", "Jena_DGM.tif"), verbose = TRUE)
# plit in 5
length(merged_DEM) # Number of Pixels 221.000.000


########
# Merge Orthophotos
# read all orthophotos
setwd("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/Luftbilder/tifs")
tifs_ortho = list.files(getwd())
length(tifs_ortho)
# convert xyz to raster (tif)
# brauche ich eigentlich gar nicht oder? kann genauso gut auch mit xyz arbeiten
tifs_ortho_list <- list()
for (i in 1:length(tifs_ortho)) {
  print(i)
  print(length(tifs_ortho))
  
  tifs_ortho_list[[i]] = raster(tifs_ortho[i], header=F, dec=".")
  #print(head(xyz_file))
}
merged_ortho <- do.call(merge, tifs_ortho_list)
# kann man irgendwann noch zuschneiden auf den Jena exttent, aber braucht man erstmal nicht
writeRaster(merged_ortho, paste0("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Luftbilder/", "Jena_ortho.tif"), verbose = TRUE,
            compress="lzw", overwrite = TRUE)
