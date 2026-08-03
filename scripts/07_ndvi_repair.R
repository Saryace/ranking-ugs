# Objetivo: reparar el CRS mal etiquetado del raster NDVI crudo (ver
# data/raw/NDVI/README.md): el archivo trae EPSG:32619 (UTM 19 NORTE), pero
# Santiago está en el hemisferio sur — es en realidad UTM 19 SUR (EPSG:32719),
# exportado desde GEE sin aplicar el falso norte de 10.000.000 m que usa la
# convención EPSG para el hemisferio sur (por eso el northing queda negativo).
# La reparación solo corrige la georreferenciación (extensión + CRS); no
# toca los valores de los píxeles.
#
# Salida: data/processed/NDVI/NDVI_Santiago_Jan2024_30m_repaired.tif

library(terra)

dir_raw <- file.path("data", "raw", "NDVI")
dir_out <- file.path("data", "processed", "NDVI")
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)

ndvi <- rast(file.path(dir_raw, "NDVI_Santiago_Jan2024_30m.tif"))

falso_norte <- 10000000
e <- ext(ndvi)
ext(ndvi) <- ext(e[1], e[2], e[3] + falso_norte, e[4] + falso_norte)
crs(ndvi) <- "EPSG:32719"

writeRaster(ndvi, file.path(dir_out, "NDVI_Santiago_Jan2024_30m_repaired.tif"),
  overwrite = TRUE)

cat(
  "CRS reparado:", crs(ndvi, describe = TRUE)$name, "\n",
  "Extensión reparada:", paste(round(as.vector(ext(ndvi))), collapse = ", "), "\n",
  "(comparar con data/raw/stgo-hot: 320370, 368310, 6271690, 6321850 — misma zona real)\n"
)
