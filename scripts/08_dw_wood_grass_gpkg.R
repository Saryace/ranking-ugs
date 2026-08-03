# Objetivo: guardar los rasters de Dynamic World (woody, grass) como capas
# ráster dentro de un único GeoPackage, igual que otros productos del
# repositorio que agrupan varias capas en un solo .gpkg (p. ej.
# data/processed/OCUC-MINVU/comparacion_poligonos.gpkg). GeoPackage soporta
# capas ráster ("raster tables") además de vectoriales: cada banda queda
# como una tabla nombrada dentro del mismo archivo.
#
# Salida: data/processed/dw-wood-grass/dw_wood_grass.gpkg
#   - capa "woody": probabilidad trees + shrub_and_scrub
#   - capa "grass": probabilidad grass
#
# Para leer una capa: terra::rast("GPKG:ruta/dw_wood_grass.gpkg:woody")

library(terra)
library(sf)

dir_raw <- file.path("data", "raw", "dw-wood-grass")
dir_out <- file.path("data", "processed", "dw-wood-grass")
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)

archivo_gpkg <- file.path(dir_out, "dw_wood_grass.gpkg")
unlink(archivo_gpkg)

woody <- rast(file.path(dir_raw, "dw_woody_stgo_30m.tif"))
grass <- rast(file.path(dir_raw, "dw_grass_stgo_30m.tif"))

# terra::writeRaster no permite agregar una segunda tabla a un GeoPackage ya
# existente (exige overwrite=TRUE, que borraría la primera capa), así que se
# escribe cada raster a un GeoTIFF temporal y se usa gdal_translate
# (vía sf::gdal_utils) con APPEND_SUBDATASET=YES para sumar la segunda capa
# al mismo archivo .gpkg.
tmp_woody <- tempfile(fileext = ".tif")
tmp_grass <- tempfile(fileext = ".tif")
writeRaster(woody, tmp_woody, datatype = "FLT4S", overwrite = TRUE)
writeRaster(grass, tmp_grass, datatype = "FLT4S", overwrite = TRUE)

sf::gdal_utils("translate", source = tmp_woody, destination = archivo_gpkg,
  options = c("-of", "GPKG", "-co", "RASTER_TABLE=woody"))
sf::gdal_utils("translate", source = tmp_grass, destination = archivo_gpkg,
  options = c("-of", "GPKG", "-co", "RASTER_TABLE=grass", "-co", "APPEND_SUBDATASET=YES"))

unlink(c(tmp_woody, tmp_grass))

cat("Escrito:", archivo_gpkg, "\n")
cat("Capas: woody, grass — leer con terra::rast(\"GPKG:", archivo_gpkg, ":woody\")\n", sep = "")
print(rast(paste0("GPKG:", archivo_gpkg, ":woody")))
print(rast(paste0("GPKG:", archivo_gpkg, ":grass")))
