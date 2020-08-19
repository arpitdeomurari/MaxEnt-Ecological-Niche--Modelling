# MaxEnt-Ecological-Niche--Modelling
This repository contain code and information for creating a MaxEnt Ecological Niche Modelling using the R language
MaxEnt model is based on the machine learning technique named maximum entropy modeling
This repository is based on CMIP5 scenarios but can be edited to run CMIP6 scenarios and other scenarios.

The user has to download the environmental layers on his/her own
The user have to filter out the species records manually for occurrence remarks to decide which records to keep
The user have to also decide which column to decide the identity of the species on his/her own too for the species records

#How to use this repository.

#Preparing the species presence records
1) Once decided the target species, the user can download the presence records from the code in the "Downloading gbif records" folder
2) To remove dubious and possibly erroneous records using the code from "Cleaning of data" folder
3) To reduce the effect of spatial clustering which can lower the accuracy of the model, the model use spthin to ensure that all records used in the MaxEnt is at least 10km apart.
  To achieve this, the code from "Reducing the effect of spatial clustering and bias" folder

#Preparing the environmental predictor raster layers
1) The layers can be downloaded from CHELSA (https://chelsa-climate.org/) or worldclim (https://www.worldclim.org/)
2) The layers downloaded are the 19 bioclimatic layers
3) The layers downloaded may have a large numeric value to represent null values in the raster layer. To prevent these numeric value from corrupting the raster layers when the        layers are downscaled in resolution or other transformation, these values are best to change to NA. This can be done using the code in "Dealing with Raster Layers"
4) The layers are then tested for correlation to ensure that all the layers used are not highly related as highly correlated layers can affect the accuracy of the model, this can    be done using the code in "Correlation Test for environmental layers" folder

#Running of the model
1) The MaxEnt Model can be run using the code from "Maxent modelling" folder together with files from the previous two sections

#Evaluation of the model
1) On top of the Area Under The Receiver Operating Characteristic Curve (AUC) which provided by the results of the last step, True Skills Statistics (TSS)and Symmetric Extremal      Dependence Index (SEDI) from the code in the "Testing of accuracy of model (TSS and SEDI)" folder

#Sample of the results of the Model
-The sample results of Allium Cepa (Oninon) is being provided. This can be found in the "Sample of results from the Model" folder.
-The sample result consists of a map with the model predicted current distribution and the predicted distribution for 2061 for three climate scenarios of RCP 2.6, RCP 4.5 and     RCP 8.5. The map can be createdd using R, however the code is not provided in this repository
-The four HTML files in the folder consists of the predicted areas of suitability for four different environmental suitability for the current, RCP 2.6, RCP 4.5 and RCP 8.5 climate scenarios. In the HTML file, value 1 to 4 refer to the corresponding environmental suitability (Unsuitable,   Poorly Suitable, Moderately Suitable and Highly Suitable).

