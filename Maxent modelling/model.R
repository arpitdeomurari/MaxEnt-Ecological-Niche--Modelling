library(dismo)
library(rJava)
library(ENMeval)
library(sp)
library(stringr)
library(rgdal)
library(viridis)
library(raster)

rm(list=ls())
setwd("")
#Listing the environmental layers for current climate
current1<-list.files("", pattern=".tif", full.names=T)
names(current1)
current<-stack(current1)

#Reading the species presence records
shp<-read.csv(".csv")
#name of the target species modelled for later use
n<-""
#Turning x and y coordinates in the presence records into shapefile to plot on environmental layer
occs<-SpatialPoints(cbind(shp$decimalLon, shp$decimalLat), proj4string=crs(current[[1]]))

#background points for MaxEnt Modelling
bg<-randomPoints(mask=current[[1]], n=10000, p=occs, excludep=T)

#Run the Maxent Modelling through the ENMeval package
#Spatial Partitioning Method is block because it is suitable for global distribution modelling, change the settings to suit your scenarios. RMvalues list the multiplier value to use and fc are the types of transformations allowed by the MaxEnt algorithm 
system.time(m1<-ENMevaluate(occ=occs, bg.coords=bg,
                            env=current,
                            method="block",
                            RMvalues=c(1, 2, 3, 4, 5),
                            fc=c("L", "H", "LH", "Q", "LQ", "HQ", "LQH"),
                            rasterPreds=T, algorithm="maxent.jar",
                            parallel=T, numCores = 7, progbar=T, updateProgress=T))
saveRDS(m1, paste0(getwd(), "/", n, "_m1.rds"))
m1@models
m1@results
m1@predictions

# The top model is rank baseed on delta AICc
m1@results[order(m1@results$delta.AICc),]
all.res<-m1@results[order(m1@results$delta.AICc),]
write.csv(all.res, paste0(getwd(), "/", n, "_m1_allresults.csv"))
m1@models[[which(m1@results$delta.AICc==0)]]
bestmod<-m1@models[[which(m1@results$delta.AICc==0)[[1]]]]
saveRDS(bestmod, paste0(getwd(), "/", n,"_m1_bestmod.rds"))
res.full<-as.data.frame(t(bestmod@results))
write.csv(res.full, paste0(getwd(), "/", n, "_m1_bestmod_fullresults.csv"))
lambdas<-bestmod@lambdas
saveRDS(lambdas, paste0(getwd(), "/", n, "_m1_bestmod_lambdas.rds"))
m1.vi<-var.importance(bestmod)
m1.vi.o<-m1.vi[order(-m1.vi$permutation.importance),]
write.csv(m1.vi.o, paste0(getwd(), "/", n, "_m1_bestmod_varimpt.csv"))
tiff(file = paste(n, "Permutation importance.tiff", sep = "_"), width=10, height= 10,units="in",res=300)
par=c(0,0,0,0)
oma=c(0,0,0,0)
barplot(m1.vi$permutation.importance, names.arg=m1.vi$variable, las=2, ylab="Permutation importance")
dev.off()
tiff(file = paste(n, "responsecurves.tiff", sep = "_"), width=14, height=12, units="in", res=300)
par=c(0,0,0,0)
oma=c(0,0,0,0)
response(bestmod)
dev.off()
best<-m1@predictions[[which(m1@results$delta.AICc==0)]][[1]]
writeRaster(best, paste0(getwd(), "/", n, "_m1_raw raster"), format="GTiff", overwrite=T)

tiff(file = paste(n, "ptsandmap.tiff", sep = "_"),width=14, height=12, units="in", res=300)
par=c(0,0,0,0)
oma=c(0,0,0,0)
plot(best, col=viridis(99))
points(occs, pch=1)
dev.off()
cloglog.m1<-predict(bestmod, current, args=c("outputformat=cloglog"))
writeRaster(cloglog.m1, paste0(getwd(), "/", n, "_m1_cloglog raster"), format="GTiff", overwrite=T)

rast<-raster(paste0(getwd(), "/", n, "_m1_cloglog raster.tif"))
maxsss.th<-res.full$Maximum.training.sensitivity.plus.specificity.Cloglog.threshold
maxsss.rc<-reclassify(rast, c(-Inf, maxsss.th, 0, maxsss.th, Inf, 1))
writeRaster(maxsss.rc, paste0(getwd(), "/", n, "_m1_maxsss"), format="GTiff", overwrite=T)

x10pt.th<-res.full$X10.percentile.training.presence.Cloglog.threshold
x10pt.rc<-reclassify(rast, c(-Inf, x10pt.th, 0, x10pt.th, Inf, 1))
writeRaster(x10pt.rc, paste0(getwd(), "/", n, "_m1_x10pt"), format="GTiff", overwrite=T)

#RCP2.6
RCP261<-list.files("", pattern=".tif", full.names=T)
names(RCP261)
RCP26<-stack(RCP261)

system.time(future1<-predict(bestmod, RCP26, args="outputformat=raw"))
writeRaster(future1, paste0(getwd(), "/", n, "_RCP26_raw raster"), format="GTiff", overwrite=T)
system.time(future2<-predict(bestmod, RCP26, args=c("outputformat=cloglog")))
writeRaster(future2, paste0(getwd(), "/", n, "_RCP26_cloglog raster"), format="GTiff", overwrite=T)

rast1<-raster(paste0(getwd(), "/", n, "_RCP26_cloglog raster.tif"))
maxsss.th<-res.full$Maximum.training.sensitivity.plus.specificity.Cloglog.threshold
maxsss.rc<-reclassify(rast1, c(-Inf, maxsss.th, 0, maxsss.th, Inf, 1))
writeRaster(maxsss.rc, paste0(getwd(), "/", n, "_RCP26_m1_maxsss"), format="GTiff", overwrite=T)

x10pt.th<-res.full$X10.percentile.training.presence.Cloglog.threshold
x10pt.rc<-reclassify(rast1, c(-Inf, x10pt.th, 0, x10pt.th, Inf, 1))
writeRaster(x10pt.rc, paste0(getwd(), "/", n, "_RCP26_m1_x10pt"), format="GTiff", overwrite=T)

#RCP4.5
RCP451<-list.files("", pattern=".tif", full.names=T)
names(RCP451)
RCP45<-stack(RCP451)

system.time(future3<-predict(bestmod, RCP45, args="outputformat=raw"))
writeRaster(future3, paste0(getwd(), "/", n, "_RCP45_raw raster"), format="GTiff", overwrite=T)
system.time(future4<-predict(bestmod, RCP45, args=c("outputformat=cloglog")))
writeRaster(future4, paste0(getwd(), "/", n, "_RCP45_cloglog raster"), format="GTiff", overwrite=T)

rast2<-raster(paste0(getwd(), "/", n, "_RCP45_cloglog raster.tif"))
maxsss.th<-res.full$Maximum.training.sensitivity.plus.specificity.Cloglog.threshold
maxsss.rc<-reclassify(rast2, c(-Inf, maxsss.th, 0, maxsss.th, Inf, 1))
writeRaster(maxsss.rc, paste0(getwd(), "/", n, "_RCP45_m1_maxsss"), format="GTiff", overwrite=T)

x10pt.th<-res.full$X10.percentile.training.presence.Cloglog.threshold
x10pt.rc<-reclassify(rast2, c(-Inf, x10pt.th, 0, x10pt.th, Inf, 1))
writeRaster(x10pt.rc, paste0(getwd(), "/", n, "_RCP45_m1_x10pt"), format="GTiff", overwrite=T)

#RCP60
RCP601<-list.files("", pattern=".tif", full.names=T)
names(RCP601)
RCP60<-stack(RCP601)

system.time(future5<-predict(bestmod, RCP60, args="outputformat=raw"))
writeRaster(future5, paste0(getwd(), "/", n, "_RCP60_raw raster"), format="GTiff", overwrite=T)
system.time(future6<-predict(bestmod, RCP60, args=c("outputformat=cloglog")))
writeRaster(future6, paste0(getwd(), "/", n, "_RCP60_cloglog raster"), format="GTiff", overwrite=T)

rast3<-raster(paste0(getwd(), "/", n, "_RCP60_cloglog raster.tif"))
maxsss.th<-res.full$Maximum.training.sensitivity.plus.specificity.Cloglog.threshold
maxsss.rc<-reclassify(rast3, c(-Inf, maxsss.th, 0, maxsss.th, Inf, 1))
writeRaster(maxsss.rc, paste0(getwd(), "/", n, "_RCP60_m1_maxsss"), format="GTiff", overwrite=T)

x10pt.th<-res.full$X10.percentile.training.presence.Cloglog.threshold
x10pt.rc<-reclassify(rast3, c(-Inf, x10pt.th, 0, x10pt.th, Inf, 1))
writeRaster(x10pt.rc, paste0(getwd(), "/", n, "_RCP60_m1_x10pt"), format="GTiff", overwrite=T)

#RCP8.5
RCP851<-list.files("", pattern=".tif", full.names=T)
names(RCP851)
RCP85<-stack(RCP851)

system.time(future7<-predict(bestmod, RCP85, args="outputformat=raw"))
writeRaster(future7, paste0(getwd(), "/", n, "_RCP85_raw raster"), format="GTiff", overwrite=T)
system.time(future8<-predict(bestmod, RCP85, args=c("outputformat=cloglog")))
writeRaster(future8, paste0(getwd(), "/", n, "_RCP85_cloglog raster"), format="GTiff", overwrite=T)

rast4<-raster(paste0(getwd(), "/", n, "_RCP85_cloglog raster.tif"))
maxsss.th<-res.full$Maximum.training.sensitivity.plus.specificity.Cloglog.threshold
maxsss.rc<-reclassify(rast4, c(-Inf, maxsss.th, 0, maxsss.th, Inf, 1))
writeRaster(maxsss.rc, paste0(getwd(), "/", n, "_RCP85_m1_maxsss"), format="GTiff", overwrite=T)

x10pt.th<-res.full$X10.percentile.training.presence.Cloglog.threshold
x10pt.rc<-reclassify(rast4, c(-Inf, x10pt.th, 0, x10pt.th, Inf, 1))
writeRaster(x10pt.rc, paste0(getwd(), "/", n, "_RCP85_m1_x10pt"), format="GTiff", overwrite=T)

