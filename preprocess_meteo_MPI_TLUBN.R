#  Meteorologische Daten verarbeiten von Zeiträumen:
# 07.08.2022 - 18.08.2022
# 17.07.2022 - 26.07.2022
# erstmal nur für einen Tag, den heißesten: 20.07.2022

# load packages
library(dplyr)

################################################################################
## read and prepare data MPI ###################################################
################################################################################

# read data
wetter_all <- read.csv("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/Wetter_Jena_2022/mpi_saale/mpi_saale.csv")
colnames(wetter_all)
# I need: 
# Zeit: Date.Time -> Zeit und Datum
#- Globalstrahlung: 
#- Windstärke: wv (m/s) -> eigentlich Geschwi, nochmal nachschauen was für SOLWEIG benötigt wird
#- Windrichtung: wd (deg)
#- relative Luftfeuchte: rh (%)
#- Luftdruck p (mbar)
#- Lufttemperatur: T (degC)
#- Niederschlag: rain (mm)

# seperate date (Year, Day, Month ) and time (hour and minute)
day <- substr(wetter_all$Date.Time, 1, 2)
month <- substr(wetter_all$Date.Time, 4, 5)
year <- substr(wetter_all$Date.Time, 7, 10)
minute <- substr(wetter_all$Date.Time, 15, 16)
hour <- substr(wetter_all$Date.Time, 12, 13)

# add to dataframe
wetter_all$day <- day
wetter_all$month <- month
wetter_all$year <- year
wetter_all$minute <- minute
wetter_all$hour <- hour

# only keep important columns
keep <- c("day", "month", "year", "minute", "hour", 
         "T..degC.", "rh....", "p..mbar.", "rain..mm.","wd..deg.", "wv..m.s.", "SWDR..W.m..2.")
wetter_important <- wetter_all[,(names(wetter_all) %in% keep)] # only keep important columns

# convert air pressure from mbar to kPa 
wetter_important$p..mbar.<- wetter_important$p..mbar. /10
names(wetter_important)[names(wetter_important)=="p..mbar."]<- "p.kPa"
sapply(wetter_important, class)

#convert character to integer
wetter_important[, c("year","month", "day", "minute", "hour")] <- sapply(wetter_important[, c("year","month", "day", "minute", "hour")], as.numeric)

# only keep 20.07.2022
hot20 <- wetter_important[wetter_important$day==20,]
hot_20_7 <- hot20[hot20$month==07,]
hot_20_07_2022 <- hot_20_7[hot_20_7$year==2022,]

# export
# write.csv(hot_20_07_2022, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Wetter/hot20_07_num.csv", row.names=TRUE)

# calculate mean each 30 minutes for minute 0, 10, 20
mean_0_10_20 <- hot_20_07_2022 %>%
  group_by(day, month, year, hour) %>%
  filter(minute %in% c(0, 10, 20)) %>%
  summarize(p.kPa_mean = round(mean(p.kPa), 3),
            T..degC._mean = round(mean(T..degC.), 2),
            minute_mean = round(mean(minute), 2),
            rh...._mean = round(mean(rh....), 2),
            wv..m.s._mean = round(mean(wv..m.s.), 2),
            wd..deg._mean = round(mean(wd..deg.), 2),
            rain..mm._mean = round(mean(rain..mm.), 2),
            SWDR..W.m..2._mean= round(mean(SWDR..W.m..2.), 2))

# calculate mean each 30 minutes for minute 30, 40, 50
mean_30_40_50 <- hot_20_07_2022 %>%
  group_by(day, month, year, hour) %>%
  filter(minute %in% c(30, 40, 50)) %>%
  summarize(p.kPa_mean = round(mean(p.kPa), 3),
            T..degC._mean = round(mean(T..degC.), 2),
            minute_mean = round(mean(minute), 2),
            rh...._mean = round(mean(rh....), 2),
            wv..m.s._mean = round(mean(wv..m.s.), 2),
            wd..deg._mean = round(mean(wd..deg.), 2),
            rain..mm._mean = round(mean(rain..mm.), 2),
            SWDR..W.m..2._mean= round(mean(SWDR..W.m..2.), 2))

# join mean_30_40_40 and mean_0_10_20
mpi_halb <-rbind(mean_0_10_20, mean_30_40_50)


################################################################################
## read and prepare data TLUBN #################################################
################################################################################

# read data TLUBN
wetter_TLUBN <- read.csv("C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Original/Wetter_Jena_2022/TLUBN_Messstation/Jena_TLUBN_formatiert.csv",
                   check.names = F, dec = ".", sep = ";")
iconv(names(wetter_TLUBN), to = "ASCII", sub = "")
colnames(wetter_TLUBN)
# I need
# Zeit: Date.Time -> Zeit und Datum
#- kurzwelliger direkter Strahlung: ?
#- kurzwelliger diffuser Strahlung: ?
#- Globalstrahlung: ?
#- Windstärke: wv (m/s) -> eigentlich Geschwi, nochmal nachschauen was für SOLWEIG benötigt wird
#- Windrichtung: wd (deg)
#- relative Luftfeuchte: rh (%)
#- Luftdruck p (mbar)
#- Lufttemperatur: T (degC)
#- Niederschlag: rain (mm)

# seperate date (Year, Day, Month ) and time (hour and minute)
day <- substr(wetter_TLUBN$Zeit, 1, 2)
month <- substr(wetter_TLUBN$Zeit, 4, 5)
year <- substr(wetter_TLUBN$Zeit, 7, 10)
minute <- substr(wetter_TLUBN$Zeit, 15, 16)
hour <- substr(wetter_TLUBN$Zeit, 12, 13)

# add date to dataframe
wetter_TLUBN$day <- day
wetter_TLUBN$month <- month
wetter_TLUBN$year <- year
wetter_TLUBN$minute <- minute
wetter_TLUBN$hour <- hour

sapply(wetter_TLUBN, class)

# convert to numeric
wetter_TLUBN[,] <- sapply(wetter_TLUBN[,], as.numeric)

# convert from hPa to kPa
wetter_TLUBN$Luftdruck_hPa<- wetter_TLUBN$Luftdruck_hPa /10
names(wetter_TLUBN)[names(wetter_TLUBN)=="Luftdruck_hPa"]<- "Luftdruck_kPa"

# rename column because of %
names(wetter_TLUBN)[names(wetter_TLUBN)=="Rel._Luftfeuchte_%"]<- "Rel._Luftfeuchte"

# only keep 20.07.2022 and 19.07.2022
#8 Uhr in der Tabelle enspricht 9 Uhr Ortszeit.

hot_tlubn20 <- wetter_TLUBN[wetter_TLUBN$day==20,]
hot_tlubn19 <- wetter_TLUBN[wetter_TLUBN$day==19,]

hot_tlubn_20_7 <- hot_tlubn20[hot_tlubn20$month==07,]
hot_tlubn_19_7 <- hot_tlubn19[hot_tlubn19$month==07,]

hot_tlubn_20_07_2022 <- hot_tlubn_20_7[hot_tlubn_20_7$year==2022,]
hot_tlubn_19_07_2022 <- hot_tlubn_19_7[hot_tlubn_19_7$year==2022,]

# delete NA rows
hot_tlubn_20_07_2022 <- filter(hot_tlubn_20_07_2022, rowSums(is.na(hot_tlubn_20_07_2022)) != ncol(hot_tlubn_20_07_2022))
hot_tlubn_19_07_2022 <- filter(hot_tlubn_19_07_2022, rowSums(is.na(hot_tlubn_19_07_2022)) != ncol(hot_tlubn_19_07_2022))

# correct time
hot_tlubn_20_07_2022$hour <- hot_tlubn_20_07_2022$hour + 1 # von 1 bis 24 statt 0-23
hot_tlubn_19_07_2022$hour <- hot_tlubn_19_07_2022$hour + 1

# delete rows with 24 because it's the next day
hot_tlubn_20_07_2022 <- hot_tlubn_20_07_2022[hot_tlubn_20_07_2022$hour != 24, ] # Reihen 1:23

# add rows from 19.07.2022 with hour = 24 as hour = 0
new_rows <- hot_tlubn_19_07_2022[hot_tlubn_19_07_2022$hour == 24, ]
new_rows$hour <- 0

# combine new rows with 0h values with 20.07.2022
hot_tlubn_20_07_2022 <- rbind(hot_tlubn_20_07_2022, new_rows)

# calculate mean each 30 minutes for minute 10, 20, 30
mean_tlubn_0_10_20 <- hot_tlubn_20_07_2022 %>%
  group_by(day, month, year, hour) %>%
  filter(minute %in% c(0, 10, 20)) %>%
  summarize(Luftdruck_kPa_mean = round(mean(Luftdruck_kPa), 3),
            Lufttemperatur_C_mean = round(mean(Lufttemperatur_C), 2),
            minute_mean = round(mean(minute), 2),
            Rel._Luftfeuchte_mean = round(mean(Rel._Luftfeuchte), 2),
            Tagessumme_Niederschlag_mm_mean = round(mean(Tagessumme_Niederschlag_mm), 2),
            Diffuse_Strahlung_Wqm_mean = round(mean(Diffuse_Strahlung_Wqm), 2),
            Globalstr_CM11_Wqm_mean = round(mean(Globalstr_CM11_Wqm), 2),
            Niederschlagshoehe_mm_mean= round(mean(Niederschlagshoehe_mm), 2),
            Globalstr_SDE_Wqm._mean= round(mean(Globalstr_SDE_Wqm), 2),
            Direkte_Strahlung_Wqm_mean= round(mean(Direkte_Strahlung_Wqm), 2))

# calculate mean each 30 minutes for minute 30, 40, 50
names(hot_tlubn_20_07_2022)
mean_tlubn_30_40_50 <- hot_tlubn_20_07_2022 %>%
  group_by(day, month, year, hour) %>%
  filter(minute %in% c(30, 40, 50)) %>%
  summarize(Luftdruck_kPa_mean = round(mean(Luftdruck_kPa), 3),
            Lufttemperatur_C_mean = round(mean(Lufttemperatur_C), 2),
            minute_mean = round(mean(minute), 2),
            Rel._Luftfeuchte_mean = round(mean(Rel._Luftfeuchte), 2),
            Tagessumme_Niederschlag_mm_mean = round(mean(Tagessumme_Niederschlag_mm), 2),
            Diffuse_Strahlung_Wqm_mean = round(mean(Diffuse_Strahlung_Wqm), 2),
            Globalstr_CM11_Wqm_mean = round(mean(Globalstr_CM11_Wqm), 2),
            Niederschlagshoehe_mm_mean= round(mean(Niederschlagshoehe_mm), 2),
            Globalstr_SDE_Wqm._mean= round(mean(Globalstr_SDE_Wqm), 2),
            Direkte_Strahlung_Wqm_mean= round(mean(Direkte_Strahlung_Wqm), 2))

# combine the two dataframes with its means
tlubn_halb <-rbind(mean_tlubn_0_10_20, mean_tlubn_30_40_50)

# delete negative values in diffuse radiation
# "Die nächtlichen Messwerte (diffuse Strahlung im negativen Bereich) sind 
# wahrscheinlich auf die städtische Beleuchtung zurückzuführen und können 
# vernachlässigt werden." Tobias Neumann Email TLUBN
tlubn_halb$Diffuse_Strahlung_Wqm_mean <- ifelse(tlubn_halb$Diffuse_Strahlung_Wqm_mean < 0, 0, tlubn_halb$Diffuse_Strahlung_Wqm_mean)

################################################################################
## add radiation columns from TLUBN to MPI #####################################
################################################################################
mpi_tlubn_strahlung <- merge(mpi_halb, tlubn_halb[, c('month', 'year', 'hour', 'minute_mean', 'Diffuse_Strahlung_Wqm_mean', 'Globalstr_CM11_Wqm_mean', 'Globalstr_SDE_Wqm._mean', 'Direkte_Strahlung_Wqm_mean')], by = c('month', 'year', 'hour', 'minute_mean'), all.x = TRUE)

# sort by hour
mpi_tlubn_strahlung <- mpi_tlubn_strahlung[order(mpi_tlubn_strahlung$hour),]
mpi_tlubn_strahlung
# export
write.csv(mpi_tlubn_strahlung, "C:/Users/svenj/Documents/Geoinformatik/Masterarbeit/Daten/Bearbeitet/Wetter/mpi_tlubn_strahlung.csv", row.names=TRUE)
