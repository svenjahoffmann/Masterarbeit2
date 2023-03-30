## cut height and aspect of right extent

# height and aspect are calculatet in QGIS-> UMEP -> ...
# cut it to right extent of Jena boundary

# load jena gemeinde
jena_gemeinde <- read_sf("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/Gebietsuebersichten_Thueringen/th-etrs89utm_gmd.shp", crs = 25832)
jena_gemeinde<-(jena_gemeinde$geometry[jena_gemeinde$GMD== "Jena"])

# load height
height <- raster("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/SVF_test3/aspect_height/height_jena_0.tif")

# load aspect
aspect <- raster("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/SVF_test3/aspect_height/aspect_jena_0.tif")

## cut them
# rasterize Jena -> set all Pixel to NA which are not within Jena
jena_gemeinde_sf <- st_as_sf(jena_gemeinde)
# load raster with right extnet and pixelsize
rasterextent <- raster("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/landcover/landcover_ras_jena_fill_all.tif")
            
jena_gemeinde_ras_2 <- rasterize(jena_gemeinde_sf, height)

height_jena <- mask(height, jena_gemeinde_ras_2)
# set pixel outside to NA
plot(height_jena)

# same for aspect
aspect_jena <- mask(aspect, jena_gemeinde_ras_2)

 
# write them
writeRaster(height_jena, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/SVF_test3/aspect_height/height_jena_extent.tif", overwrite = TRUE)
writeRaster(aspect_jena, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/SVF_test3/aspect_height/aspect_jena_extent.tif", overwrite = TRUE)
