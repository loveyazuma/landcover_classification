# This function downloads a .zip file from a url, saves it as file and unpacks the .zip 
# data. All tiff files are selected, and returned as a raster stack

downloadPrepare <- function(url, file, dir){
  
  # Download file from url and save as file argument
  download.file(url, file, method = 'auto')
  
  # Unpack the data in specified directory
  unzip(file, exdir = dir)
  
  # Create and return raster stacks from the tif files of the unpacked data
  tifs <- list.files(dir, pattern = glob2rx('*.tif'), full.names = TRUE)
  return(stack(tifs))
}




