## Land cover prediction
Identification of land cover establishes the baseline information for activities like thematic mapping and change detection analysis. In this project the Gewata region in Ethopia was chosen to predict the distribution of landcover classes. This region contains three main landcover types: wetland, cropland and forest. A landcover class is expected to be assigned to each pixel in the region.

It would be too much work to manually annotate the entire region, so instead a Random Forest (RF) prediction model was employed. Several polygons of each landcover class were used as reference data. To predict the classes in the area, a Landsat 7 scene, containing several bands with surface reflectance values and a land use/land cover map (lulc) were utilized. 

The RF model was creasted using the classified training polygons. The model was then used to predict the landcover of the entire Gewata region. The LULC reference raster was used to assess the accuracy of the classification. The expected output of the analysis is a landcover prediction map and raster, and the overall classification accuracy of the prediction. 

### Details
- GADM Gewata region boundaries were used to delineate the study area


### Processes
- The data would be downloaded into the script.

- A function was defined for downloading and preparing the data and placed in the `R` folder

- The prediction raster was saved as `Gewata_LC_prediction.tif` in the `output` folder

- The comparisons of reference and prediction maps were saved as `Gewata_prediction.png` in the `output` folder

- The overall prediction accuracy of the final prediction was assigned to a variable called `prediction_accuracy`, and printed in the script

### Bonus

A confusion matrix was made for the predicition raster and saved as `confusion_matrix.csv` in the `output` folder. It was ensured that the matrix had correct class labels, not class numbers.
