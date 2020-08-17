library(raster)
library(rgbif)
library(spThin)
library(rgdal)

#setting of the working directory
setwd()

#checking the count of the target species (eg. Anthriscus cerefolium)
occ_search(scientificName = "Anthriscus cerefolium", hasCoordinate = T, return = "meta")$count

#getting the record information of the target species, if the record number exceed 200000
# can download the records in multiple parts smaller than 200000 by restricting the time period 
ca <- occ_search(scientificName = "Anthriscus cerefolium", return = "data", hasCoordinate = T, limit = 1000000)

#writing out the record information as csv file
write.csv(ca, paste0(getwd(), "/Anthriscus cerefolium.csv"))

