#Import libraries
library(raster)
library(sf)
library(rgdal)
library(randomForest)

# Source functions
source('R/downloadPrepare.R')

# Create 'data' and 'output' folders if they don't already exist
if(!dir.exists(path = 'data')) {
  dir.create(path = 'data')
}

if(!dir.exists(path = 'output')) {
  dir.create(path = 'output')
}

## Use function to download and prepare the data
Gewata <- downloadPrepare('https://raw.githubusercontent.com/GeoScripting-WUR/AdvancedRasterAnalysis/gh-pages/data/Gewata.zip', 'data/Gewata.zip', 'data')

# Get Gewata region borders
eth <- getData('GADM', country = 'ETH', level = 3, path = 'data')
gwt <- eth[eth$NAME_3 == "Getawa",]
gwt <- spTransform(gwt, CRSobj = crs(Gewata))

# Mask raster data by Gewata region
Gewata <- mask(x = Gewata, mask = Gewata$lulcGewata)
plot(Gewata$lulcGewata)

# Read the GeoJSON with polygons
polys <- readOGR(list.files('data', pattern = glob2rx('*.geojson'), full.names = TRUE))

# Ensure both datasets have the same CRS
polys <- spTransform(polys, crs(proj4string(Gewata)))
plot(polys, add=T)

# Encode the thematic variable for classification with a new 'class' feature
polys$Code <- as.numeric(polys$Class)

# Save lulc map as ground truth
reference_raster <- Gewata$lulcGewata

# Remove ground truth from the training raster
covs <- dropLayer(Gewata, 7)

# Assign 'Code' values to raster cells. where they overlap with the training polygons
trainRaster <- rasterize(polys, covs, field = 'Code')

# Set name of raster to class
names(trainRaster) <- "class"

# Mask the coovariates raster by the train raster, to only contain the polygons
covmasked <- mask(covs, trainRaster)

# Add the train raster to the masked covariate stack
trainStack <- addLayer(covmasked, trainRaster)

# Transform the stack into a matrix, and change the class type from integer to factor
trainMatrix <- as.data.frame(na.omit(getValues(trainStack)))
trainMatrix$class <- factor(trainMatrix$class, levels = c(1:3))

# Create an RF model with covariates as x variable, and class and y variable
set.seed(500)
modelRF <- randomForest(class ~ ., data = trainMatrix, classification = TRUE)

# Ensure that the names between covariates and training matrix correspond exactly
names(covs)
names(trainMatrix)

# Now predict the entire area using the covariates
prediction <- predict(covs, modelRF, na.rm = TRUE)

# Save the prediction raster as GeoTIFF
writeRaster(prediction, "output/Gewata_LC_prediction.tif", overwrite= TRUE)

# Visualize the prediction raster
png("output/Gewata_prediction.png")
par(mfrow = c(1,2))

cols <- c("orange", "dark green", "light blue")
plot(reference_raster, col = cols, legend = FALSE, main = "Actual landcover Gewata")
legend("topright", 
       legend = c("cropland", "forest", "wetland"), 
       fill = cols, bg = "white")
plot(prediction, col = cols, legend = FALSE, main = "Predicted landcover Gewata")
legend("topright", 
       legend = c("cropland", "forest", "wetland"), 
       fill = cols, bg = "white")
dev.off()

# Obtain reference raster and predicition raster as matrices and omitting NAs for comparison
lulcMatrix <- as.matrix(na.omit(getValues(reference_raster)))
predMatrix <- as.matrix(na.omit(getValues(prediction)))

# Create confusion matrix and assign row and col names
cm_test = table(predMatrix, lulcMatrix)
rownames(cm_test) <- c("cropland", "forest", "wetland")
colnames(cm_test) <- c("cropland", "forest", "wetland")

# Write confusion matrix to file
write.csv(cm_test, file= "output/confusion_matrix.csv")

# Compute overall accuracy
prediction_accuracy = sum(diag(cm_test)) / sum(cm_test) * 100
print(paste0("The overall prediction accuracy is ", round(prediction_accuracy),"%"))
