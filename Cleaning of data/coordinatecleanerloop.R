library(dplyr)
library(ggplot2)
library(rgbif)
library(sp)
library(countrycode)
library(CoordinateCleaner)

#setting the working directory
setwd("")

#getting ready the all the species presence data csv for coordinate cleaning
a <- list.files(path="", pattern="*.csv", full.names=TRUE, recursive=FALSE)

#Creating the loop for cleaning the coordinates of the presence records
lapply(a, function(x) {
  dat<-read.csv(x)
  dat <- dat %>%
#piped to get the needed data from the gbif data for analysis
    dplyr::select(species, decimalLongitude, decimalLatitude, countryCode, individualCount,occurrenceRemarks,
                  gbifID, family, taxonRank, coordinateUncertaintyInMeters, year,
                  basisOfRecord, institutionCode, datasetName, scientificName, issues, acceptedScientificName, geodeticDatum, name, samplingProtocol)
  
#filter data without coordinates  
  dat <- dat%>%
    filter(!is.na(decimalLongitude))%>%
    filter(!is.na(decimalLatitude))
  wm <- borders("world", colour="gray50", fill="gray50")
  ggplot()+ coord_fixed()+ wm +
    geom_point(data = dat, aes(x = decimalLongitude, y = decimalLatitude),
               colour = "darkred", size = 0.5)+
    theme_bw()
#filtering based on countrycode
  dat$countryCode <-  countrycode(dat$countryCode, origin =  'iso2c', destination = 'iso3c')
  dat <- data.frame(dat)
  flags <- clean_coordinates(x = dat, lon = "decimalLongitude", lat = "decimalLatitude",
                             countries = "countryCode", 
                             species = "species",
                             tests = c("capitals", "centroids", "equal","gbif", "institutions",
                                       "zeros", "countries")) # most test are on by default
  summary(flags)
  plot(flags, lon = "decimalLongitude", lat = "decimalLatitude")
  dat_cl <- dat[flags$.summary,]
  dat_fl <- dat[!flags$.summary,]
  
#writing out records with clean coordinates
  write.csv(dat_cl, file=paste(x, "_clean.csv"))
#writing out records with flagged coordinates
  write.csv(dat_fl, file=paste(x, "_flag.csv"))
  
})
