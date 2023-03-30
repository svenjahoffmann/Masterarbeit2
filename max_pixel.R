################################################################################
## find max pixel of the two heat waves in 2022 Jena ###########################
################################################################################

# load packages
library(raster)

# get all asci files 
setwd("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/Temperaturmodellierungen_Hitzewellen/5minRaster_Jena_Hitzewellen_2022_Jul_und_Aug/")
asci_heatwaves = list.files(getwd())

# convert them to a list of rasters
heat_raster <- list()
heat_ascii <- list()
for (i in 1:length(asci_heatwaves)){
  print(i)
  print(length(asci_heatwaves))
  heat_ascii[[i]] = read.asciigrid(asci_heatwaves[i])
  print("loaded")
  heat_raster[[i]] <-raster(heat_ascii[[i]])
}

# find max pixel
max_values <- sapply(heat_raster, function(x) max(x[], na.rm = TRUE))
max_value <- max(max_values)

# find raster which includes the max pixel
max_index <- which.max(max_values)
print(paste0("Maximum pixel value of ", max_value, " found in raster ", max_index))
print(max_value) #791
heat_raster[[791]] #20.07.2022  


# not necessary:

#find coordinates of max pixel
r <- heat_raster[[791]]

# Find Index of Pixels with max value
max_pixel <- which.max(r[])
max_pixel

# Find coordinates of max pixel
max_coords <- xyFromCell(r, max_pixel)
max_coords

cat("Index des Pixels mit dem maximalen Wert:", max_pixel, "\n")
cat("Koordinaten des Pixels mit dem maximalen Wert:", max_coords[1], max_coords[2], "\n")

# export r to have a look in QGIS
writeRaster(r, paste0("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/temperature/", "raster_maxtemp.tif"))




