# merge to one svf zip folder

# set the directory where the output folders are located
setwd("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/SVF_test3")

# get a list of all the output folders
output_folders <- list.files(pattern = "^output_.*$")
output_folders

# create an empty list to store the raster objects
raster_list <- list()

# loop through each output folder
for (folder in output_folders) {
  # unzip the svf.zip folder
  unzip(paste0(folder, "/svfs.zip"), exdir = paste0(folder, "/svfs"))
  
  # get a list of all the tif files in the svf folder
  tif_files <- list.files(paste0(folder, "/svfs"), pattern = ".tif$", full.names = TRUE)
  
  # loop through each tif file and read it as a raster object
  for (tif_file in tif_files) {
    # get the filename without the path or extension
    filename <- tools::file_path_sans_ext(basename(tif_file))
    filename
    # add the raster object to the list, using the filename as the key
    raster_list[[filename]][[folder]] <- raster::raster(tif_file)
  }
}

# loop through each unique filename in the raster list
for (filename in unique(names(raster_list))) {
  # get the list of raster objects with this filename
  filename_rasters <- unname(raster_list[[filename]])
  
  # merge the raster objects with the same name
  merged_svf <- do.call(merge, filename_rasters)
  
  # write the merged raster to a file
  raster::writeRaster(merged_svf, filename = paste0(filename, ".tif"), format = "GTiff")
}
# es kommt noch ein Error, aber alles wurde erstellt 
# In der Kachel wo gar keine Geäude sind teilweise NA tifs -> vllt ist das das Problem
# weíeder zu zip machen?