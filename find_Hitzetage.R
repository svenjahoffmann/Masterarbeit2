#

wetter1 <- read.csv("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Wetter_Jena_2022/mpi_saale/mpi_saale.csv")
head(wetter1)
colnames(wetter1)

# delete Time, keep date
date <- substr(wetter1$Date.Time, 1, 10)
head(date)

# add date to dataframe
wetter1$date <- date
View(wetter1)

imp <- c("date", 
         "T..degC.")
temp1 <- wetter1[,(names(wetter1) %in% imp)] # only keep important columns

head(temp1)


# gruppieren nach Tag, nur max bei T..degC behalten 
library(data.table)
maxtemp_tag <- setDT(temp1)[, .SD[which.max(T..degC.)], by = date]
maxtemp_tag

# only keep days over 25 degrees
sommertage1 <- subset(maxtemp_tag, T..degC.>24.999)
head(sommertage1)
View(sommertage1)

# Same for 01.01. till 01.07.
wetter2 <- read.csv("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Wetter_Jena_2022/mpi_saale_2022a/mpi_saale_2022a.csv")
head(wetter2)

# delete Time, keep date
date2 <- substr(wetter2$Date.Time, 1, 10)

# add date to dataframe
wetter2$date <- date2
head(wetter2)

imp <- c("date", 
         "T..degC.")
temp2 <- wetter2[,(names(wetter2) %in% imp)] # only keep important columns

head(temp2)


# gruppieren nach Tag, nur max bei T..degC behalten 
library(data.table)
maxtemp_tag2 <- setDT(temp2)[, .SD[which.max(T..degC.)], by = date]
maxtemp_tag2

# only keep days over 25 degrees
sommertage2 <- subset(maxtemp_tag2, T..degC.>24.999)
head(sommertage2)
View(sommertage2)

# merge sommertage1 and sommertage2
sommertage <- rbind(sommertage2, sommertage1)
sommertage

#export as csv
write.csv2(sommertage, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Wetter_Jena_2022/sommertage.csv", row.names=TRUE)


