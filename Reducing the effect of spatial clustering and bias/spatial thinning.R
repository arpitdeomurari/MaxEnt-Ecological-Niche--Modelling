library(raster)
library(rgbif)
library(spThin)
library(rgdal)
setwd("")
# ====================================================================== #
#### spatial thinning of species occurrences using the spThin package ####
# ====================================================================== #

# to thin the occurrences, we will use the "thin" function from the package "spThin"

# you need to make a decision on the following specifications:
# thin.par = the distance in kilometers that you want the records to be separated by 
# (most people usually use the length of each grid cell of the environmental predictors, or half the length of each grid cell if you want to keep more records...)
# reps = the number of times to repeat the thinning process / number of iterations

# you can also read / try out the worked example here: 
browseURL("https://cran.r-project.org/web/packages/spThin/vignettes/spThin_vignette.html")


dir.out <- "" # fill in the path to the folder that you want the results of the thinning to go into, i.e., the output directory

ca.occs.new <- shapefile(".shp") # read in the modified shapefile layer after you have checked the occurrences in QGIS and removed any dubious ones

start_time <- Sys.time()
ca.thin <- thin(loc.data = ca.occs.new, 
                lat.col = "lat",
                long.col = "long", 
                spec.col = "species", 
                thin.par = 5, 
                reps = 20, 
                locs.thinned.list.return = T, 
                write.files = T, 
                out.dir = dir.out, 
                out.base = "Coffea arabica", 
                write.log.file = T, 
                log.file = paste0(dir.out, "/Coffea arabica log.txt"),
                verbose = T)
end_time <- Sys.time()
end_time - start_time

# to visually assess whether the number of reps is sufficient to obtain the optimal number of occurrences
plotThin(ca.thin)
# the 1st of the 3 plots is probably the most important... check that the plot begins to plateau out, and the point of the plateau will determine the number of reps needed to achieve the optimal number of occurrences
plotThin(ca.thin, which = 1)

# a certain number of .csv files all containing different permutations of the maximum optimal number of records will be generated in your output directory

# now you can plot out the thinned occurrences to see how they compare


# choose any one of the thinned set of occurrences and turn it into a SpatialPoints object for plotting
# first read in the .csv file
ca.thin.occs <- read.csv(paste0(dir.out, ".csv")) ; head(ca.thin.occs)
nrow(ca.thin.occs) # you can check that the number of thinned occurrences (which should be the same as the "Maximum number of records after thinning" printed in the spatial thinning message.)

ca.thin.occs2 <- SpatialPoints(cbind(ca.thin.occs$long, ca.thin.occs$lat), proj4string = crs(bio01))

# plot the occurrences before and after thinning
# and visually check that the spread of points after thinning is roughly the same as before thinning
par(mfrow = c(2, 1), mar = c(0, 0, 0, 0)) # "mfrow" splits the plot area into a specified number of rows and columns ; "mar" specifies the margins of the plot and in this case I want to remove as much white space as possible so I set all margins to 0
plot(bio01) ; plot(ca.occs.new, pch = 20, cex = 0.7, add = T)
plot(bio01) ; plot(ca.thin.occs2, pch = 20, cex = 0.7, add = T)

# clear the plot settings
dev.off()

# save the thinned occs as shapefiles so you can also examine them in more detail in QGIS
writeOGR(ca.thin.occs2, dsn = getwd(), layer="Coffea arabica_thinned", driver="ESRI Shapefile") # change the output folder path ("dsn =") and layer name accordingly

# ####
