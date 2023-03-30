library(readr)
library(dplyr)
library(stringr)



# Liste aller Dateinamen erstellen
filenames <- list.files(path = "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Solweig_out/Model_num/POI", pattern = "*.txt", full.names = TRUE)


# Leere Liste erstellen, um die eingelesenen Datensätze zu speichern
all_data <- list()

# Schleife durch alle Dateien
for (i in 1:length(filenames)) {
  # Datensatz einlesen
  data <- read.table(filenames[i], header = TRUE)
  
  # POI_number Spalte hinzufügen
  data$POI_number <- as.numeric(gsub("[^[:digit:]]", "",basename(filenames[i])))
  
  # Datensatz der Liste hinzufügen
  all_data[[i]] <- data
}

# Alle Datensätze zusammenführen
all_data <- do.call(rbind, all_data)

# Gruppieren nach dectime und teilen in mehrere Datensätze
split_data <- split(all_data, all_data$dectime)
head(split_data)
# View(split_data[1])


class(split_data[1])


for (i in 1:length(split_data)) {
  # Aktuellen Datensatz exportieren
  write.csv(split_data[[i]], file = paste0("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Solweig_out/Model_num/POI/Datensatz_",i,".csv"), row.names = FALSE)
}


# aus allen einzelnen timestep Dateien in split_data einzelne rasterfiles erstellen mit den 
# Koordinaten des Punktshapefiles

# eigentlich Koordinaten der Punkte mit anhängen, basierend auf POI_number
 library(sf)
POI <- read_sf("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/POI.shp")
plot(POI)
head(POI) #id fängt bei 0 an
head(split_data[1]) # fängt auch bei 0 an 

# geometry oder xcoord, ycoord von POI anhängen aufgrund von POI$ID und split_data$POI_number
class(split_data)


# Liste mit CSV-Daten
POI$xcoord
class(POI$id)
class(split_data[[1]]$POI_number)
POI$id
head(sort(split_data[[1]]$POI_number))



#create empty columns in split_data
for (i in 1:length(split_data)) {
  split_data[[i]]$x <-NA
  split_data[[i]]$y <-NA
}


length(split_data)
nrow(POI)
head(split_data)
#iterate over all datasets in split_data

# Iterate over the split_data list
for (i in 1:length(split_data)) {
  
  # Get the corresponding row index from POI that matches POI_number
  match_index <- match(split_data[[i]]$POI_number, POI$id)
  
  # Assign the xcoord from POI to x in split_data
  split_data[[i]]$x <- POI$xcoord[match_index]
  
  # Assign the ycoord from POI to y in split_data
  split_data[[i]]$y <- POI$ycoord[match_index]
}

head(split_data)

# convert split_data zu spatial data
# Iterate over the split_data list
for (i in 1:length(split_data)) {
  
  # Convert the dataframe to a simple feature
  split_data[[i]] <- st_as_sf(split_data[[i]], coords = c("x", "y"), crs = 25832)
}
class(split_data[[i]])



# folgender Schritt muss nur erfolgen, wenn man alle Zeitschritte als Shapefile abspeichern möchte
# Schleife über die Sf-Objekte und Erstellung von Shapefiles
for(i in 1:length(split_data)) {
  # Erstellen des Shapefiles
  st_write(split_data[[i]], "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/POI/", paste0("shapefile_", i), driver = "ESRI Shapefile")
}

# klappt
# split_data[[i]] sind 144 Shapefiles mit jeweils 400 Punkten, die Attribute über PET, UTCI usw. enthalten
# split_data zu Raster umschreiben

class(split_data[[i]])
class(split_data)
class(split_data[i])
# outputfiles sind viele Punktshapefiles mit den PET und UTCI values angehängt
# plotten um zu sehen ob es geklappt hat

# diese Punktshapefiles umwandeln in Raster
# leeren Raster erstellen


POI_points <- split_data
# Convert points to sp (assumes that the sf object is called example_points)
for (i in 1:length(POI_points)){
  POI_points[[i]] <- as(POI_points[[i]], "Spatial")
  
}

class(POI_points[[i]])
length(POI_points)
Sys.setenv(lang = "en_US")

# Generate empty raster layer and rasterize points
raster_leer <- raster(xmn=680999.5, xmx=681999.5, ymn=5644000, ymx=5645000, resolution=c(50,50))
crs(raster_leer) <- CRS('+init=EPSG:25832')
st_crs(raster_leer) # empty

# use rasterize to create desired raster
# first create single band raster for each colum I want to keep
# for PET
names(POI_points[[i]])

POI_points_PET <- POI_points
POI_points_UTCI <- POI_points
POI_points_dectime <- POI_points
# erstmal bis hier mit den drei Variablen testen

POI_points_altitude <- POI_points
POI_points_azimuth <- POI_points
POI_points_Ta <- POI_points
POI_points_Tg <- POI_points
POI_points_RH <- POI_points
POI_points_Esky <- POI_points
POI_points_Tmrt <- POI_points
POI_points_Shadow <- POI_points
 # maybe keep even more
ncol(POI_points[[i]]) # 36
length(POI_points)
# Schleife auch für colnames schreiben
# create empty 

# will: ein multiband raster
# dafür: einzelne Raster erstellen, wo jedes Pixel nur Info über eine Spalte hat
# weil es nicht geht, das Raster auf einmal mit allen Attributen pro Pixel zu erstellen

library(raster)
st_crs(POI_points[[i]]) 
View(POI_points[[1]])
head(POI_points)


library(raster)

# Leere Liste erstellen
multiband_rasters <- list()



# hat bei allen geklappt
ncol(POI_points[[i]])
# create 144 multiband raster, one for each timestep including all the columns as bands
# Schleife über jedes SpatialPointsDataFrame
for (i in 1:length(POI_points)) {
  # Leere Liste für multiband Raster erstellen
  rasters <- list()
  # Schleife über jede Spalte
  for (j in 1:ncol(POI_points[[i]])) { 
    # Raster erstellen und zu Liste hinzufügen
    rasters[[j]] <- rasterFromXYZ(POI_points[[i]][,c(j,3:4)], crs='+init=EPSG:25832')
    # Spaltennamen beibehalten
    colnames <- names(POI_points[[i]])[j]
    # Spaltennamen dem neuen Raster zuweisen
    names(rasters[[j]]) <- colnames
  }
  # Zusammenführen der Raster in ein multiband Raster
  multiband_rasters[[i]] <- stack(rasters, layerNames = colnames)
  # Exportieren des multiband Rasters als TIFF-Datei
  writeRaster(multiband_rasters[[i]], filename = paste0("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/POI/PET_UTCI_",i,".tif"), layerNames = colnames, overwrite = TRUE, format = "GTiff")
  }
# klappt noch nicht ganz mit den Spaltennamen
head(colnames[2])
names(multiband_rasters[[i]])

# hier sind die Layernnamen noch richtig,
# beim Öffnen der exportierten Dateien heißen sie aber nur noch layer1, layer2 usw...
# noch hinbekommen oder nochmal versuchen

# vielleicht können einige Bänder auch weggelassen werden, aber erstmal alles behalten, falls ich mit den 
# Raster Analysen mache, aber eigentlich kann ich die auch mit Dataframes machen
# Rasterdatensätze nehmen, um Sensitivitätsanalyse zu machen?

#### DEM preprocess file noch umschreiben und für viele DEMS machen

#### landcover file noch besser erstellen

