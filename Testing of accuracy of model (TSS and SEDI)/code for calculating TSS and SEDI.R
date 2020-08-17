setwd("")

library(raster)
library(SDMTools)
library(ENMeval)
library(rJava)
library(ecospat)


# read in the rds file containing the overall model output from ENMeval
m1 <- readRDS(paste0(getwd(), "/Bste_m1.rds"))

m1 # check what m1 contains

m1@bg.pts # this gives the coordinates of your background points
nrow(m1@bg.pts) # check that the number of background points looks ok compared to what you remember it should be


# get the "best" model as chosen above, using its settings as an identifier ; you can save an rds file of this also if you like
bestmod <- m1@models[[which(m1@results$settings==best.or$settings)]]

bestres <- bestmod@results # get the full results of the "best" model

# get the maxSSS threshold of the "best" model
maxsss <- bestres[which(dimnames(bestres)[[1]]=="Maximum.training.sensitivity.plus.specificity.Cloglog.threshold")] # to get other threshold values simply change the threshold name

# read predictor environmental layers in
preds<-list.files( "", pattern=".tif", full.names=T) ; preds
preds.stack<-stack(preds)
names(preds.stack)

# get the cloglog raster
cloglog <- predict(bestmod, preds.stack, args=c("outputformat=cloglog"))
# save it out if you like
writeRaster(cloglog, paste0(getwd(), ".tif"), format="GTiff", overwrite=T)





# get a vector of predicted probabilities
x<-function(a, b) {
cloglog <- raster(paste0(a,"/",a,"_m1_cloglog raster.tif")) # read in the raster
pred.vals <- values(cloglog) # get all the values, including NAs, from the raster. "cloglog[]" is equivalent to "values(cloglog)"
predicted <- pred.vals[which(!is.na(pred.vals))] # get a vector of only the probabilities, without NAs
length(predicted) # check the length of this vector

# now get a vector of presence/absence (1s or 0s) of the species at the predicted cells
sp <- shapefile(paste0(a,"/shp/",a,".shp")) ; plot(sp) # read in the species occurrence shapefile
sp.rast <- rasterize(sp@coords, cloglog, fun="count", background=NA) ; plot(sp.rast) # rasterize the species occurrences using the cloglog raster as a "mask"
occ.vals <- values(sp.rast) # get the values out of the raster
summary(occ.vals) # check a summary of the values
occ.vals[!is.na(occ.vals)] <- 1 # set all non-NA values to 1
summary(occ.vals) # check the values now. you should have only 1s and NAs
occ.vals[is.na(occ.vals)] <- 0 # now set all NAs to 0
summary(occ.vals) # check: you should have only 1s and 0s
# the reason I didn't simply set "background=0" when I rasterized the shapefile is because NAs are easier to deal with, I don't know what is the "is.na" equivalent for 0s...

# now use the NAs from the cloglog raster to mask the occurrence raster
pred.mask <- pred.vals # create a new masking vector
pred.mask[which(!is.na(pred.mask))] <- 0 # set all non-NA values to 0

occ.vals2 <- pred.mask + occ.vals # mask away the extra 0s in the occurrence values
summary(occ.vals2) # this should have 0s, 1s and NAs

occ <- occ.vals2[which(!is.na(occ.vals2))] # final vector of species presence/absence at the model predicted cells
summary(occ) # now this only has 0s and 1s
length(occ) # check the length of this species occurrence vector. it should be the same as the length of the predicted values above


# now get a confusion matrix using the function "confusion.matrix" from the package "SDMTools"
# use maxsss as defined above as the threshold

cm <- confusion.matrix(obs = occ, pred = predicted, threshold = b) ; cm

# define true/false positive/negative of each cell of the confusion matrix
tn <- cm[1]
fp <- cm[2]
fn <- cm[3]
tp <- cm[4]

Sn <- tp / (tp + fn) # sensitivity
Sp <- tn /(tn + fp) # specificity
Fa<- (1-Sp)#1-specificity, measures the ratio of commission errors to the sum of commission errors and true absences
Prevalence<-(tp+fn)/(tp+fn+fp+tn)

TSS <- Sn + Sp - 1 ; TSS # True Skill Statistics

SEDI<-(log10(Fa)-log10(Sn)-log10(1-Fa)+log10(1-Sn))/(log10(Fa)+log10(Sn)+log10(1-Fa)+log10(1-Sn)); SEDI
return (paste("For",a,",","TSS is",TSS, "SEDI is", SEDI))} #(Wunderlich RF, Lin Y-P, Anthony J, Petway JR (2019) Two alternative evaluation metrics to replace the true skill statistic in the assessment of species distribution models. Nature Conservation 35: 97-116. https://doi.org/10.3897/natureconservation.35.33918)
