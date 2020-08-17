library(raster)

#setting the working directory for environmental layer that you want to edit
setwd("")

#Reading of the raster layer that you want to edit,include the location in the ""
bio<-raster("")

#Reassign the values in Raster, this is needed if the NA value in your environmental raster is
#assigned a large negative number instead of NA, which can affect your raster value when you downscale your raster
#resolution or when you create a mean raster.
#In this example, the NA value of the original raster is -32768
values(bio)[values(bio)==-32768] = NA

#Get a summary of your reassigned raster to check if the value has been successfully changed
summary(bio)

#Write the reassigned raster as a new raster file for further usage 
writeRaster(bio,filename = ".tif")
 