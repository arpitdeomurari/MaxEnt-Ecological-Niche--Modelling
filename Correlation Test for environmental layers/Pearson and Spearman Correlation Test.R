library(dismo)
library(Hmisc)
library(rgdal)
library(raster)
library(usdm)
#This code is to be used to determine the correlation in the current climate Bio19 environmental layers

#setting the working directory
setwd()

#Open all the environmental layers chosen for the modelling and stack them 
preds<-list.files(path=paste0(getwd(), ""), pattern=".tif", full.names=T)
preds.stack<-stack(preds)
names(preds.stack)

#Run vifcor, this identify the pearson correlation between the environmental layers
#It also provide the Variance inflation factor (VIF) of eaach environmental layers
#VIF can help to identify which environmental layers in the pearson correlated pair to remove, remove the layer with the higher VIF
v1<-vifcor(preds.stack,th=0.7)
v1
write.csv(v1, paste0(getwd(), "/vifcor.csv")) 
# you can open this in Excel and use "Conditional formatting" (in the "Home" tab) to see which pairs of variables have more than 0.7 correlation, and then consider each pair one by one.

#Pearson Correlation Test

#This folder should just contain the environmental layers that are not pearson correlated significantly
preds<-list.files(path=paste0(getwd(), ""), pattern=".tif", full.names=T)

# create a raster stack of your predictors
preds.stack<-stack(preds)
names(preds.stack) # check that the right files were read in

# create 10,000 random points over the extent of your predictor layers
# this might take a few minutes to run
randpts<-randomPoints(preds.stack[[1]], 10000) # just use the 1st predictor layer as the "mask"
plot(preds.stack[[1]])
points(randpts) # check that the coverage of the points looks generally ok

# extract the predictor values that fall under each of the random points
predvals<-extract(preds.stack, randpts) 
head(predvals)
summary(predvals) 
# check if there are any NA values


# we should remove the NAs before running the correlation test
predvals.df<-as.data.frame(predvals) # first change the object containing the predictor values from a matrix into a data frame
summary(predvals.df)


# now, using the "rcorr" function from the package "Hmisc", we can generate a table showing all pairwise correlation coefficients
# but first we need to turn the object back into a matrix

class(predvals) # check that the object's class is indeed "matrix"
summary(predvals) # check that it's clear of NAs

cor<-rcorr(predvals, type="spearman")
write.csv(cor$r, paste0(getwd(), "/corrmatrix_spearman_r.csv"))

#Decide for yourself which environmental layers in the correlated pair to remove


