# ── 05_dynamic_world_backup.R ────────────────────────────────────────────
# Objetivo: descargar (o volver a descargar) los rasters de probabilidad de
# Google Dynamic World desde GEE, a 30m de resolución, sobre el bounding box
# de Santiago. Este es el script "backup": documenta y reproduce cómo se
# generaron los rasters que ya están en data/raw/dw-wood-grass/, por si hay
# que regenerarlos (otra fecha, otra área, otra versión de Dynamic World).
#
# Salidas (data/raw/dw-wood-grass/):
#   - dw_woody_stgo_30m.tif  : probabilidad de trees + shrub_and_scrub
#   - dw_grass_stgo_30m.tif  : probabilidad de grass
#
# Estos rasters son a 30m y de cobertura de toda la ciudad — pensados para
# visualización agregada (p. ej. mapas de hexágonos). El análisis a nivel de
# plaza/parque individual usaría rasters a 10m interceptados con los
# polígonos de data/raw/SHP; ese cruce es un paso posterior, no incluido en
# este repositorio todavía.
#
# Requiere: cuenta de Google Earth Engine ya registrada y rgee configurado
# (rgee::ee_Install() corrido una vez), más autenticación de Google Drive
# (el resultado se descarga vía Drive). No se pudo ejecutar ni verificar
# este script en este entorno por falta de esas credenciales y del paquete
# rgee (no instalado) — revisar con cuidado antes de correrlo.
# ─────────────────────────────────────────────────────────────────────────

# Librerías -----------------------------------------------------------------
library(rgee)
library(terra)
library(sf)
library(tidyverse)
library(stars)

# Autenticación GEE (una vez por sesión) -------------------------------------
rgee::ee_Initialize(drive = TRUE)

# ROI — bounding box de Santiago ---------------------------------------------
stgo_bbox <- c(-70.85, -33.65, -70.45, -33.30)
roi <- ee$Geometry$Rectangle(
  coords   = stgo_bbox,
  proj     = "EPSG:4326",
  geodesic = FALSE
)

# Fechas — ±5 días alrededor de la fecha objetivo ----------------------------
target_date <- as.Date("2024-01-20")
start_date  <- ee$Date(as.character(target_date - 5))
end_date    <- ee$Date(as.character(target_date + 5))

# Colección Dynamic World -----------------------------------------------------
dw_col <- ee$ImageCollection("GOOGLE/DYNAMICWORLD/V1")$
  filterBounds(roi)$
  filterDate(start_date, end_date)

n_imgs <- dw_col$size()$getInfo()
message("Imágenes Dynamic World encontradas: ", n_imgs)
if (n_imgs == 0) stop("No se encontraron imágenes — ampliar la ventana de fechas.")

# Woody: trees + shrub_and_scrub ---------------------------------------------
# Mediana entre las imágenes disponibles en la ventana de fechas
woody_ee <- dw_col$map(function(img) {
  img <- ee$Image(img)
  img$select("trees")$
    add(img$select("shrub_and_scrub"))$
    rename("woody")
})$median()$clip(roi)

# Grass ------------------------------------------------------------------------
grass_ee <- dw_col$select("grass")$median()$clip(roi)

# Descarga vía Drive -----------------------------------------------------------
dir_out <- file.path("data", "raw", "dw-wood-grass")
dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)

message("Descargando raster woody (30m)...")
woody_rast <- rast(ee_as_stars(
  image  = woody_ee,
  region = roi,
  scale  = 30,
  via    = "drive"
))
names(woody_rast) <- "woody"
terra::writeRaster(
  woody_rast,
  file.path(dir_out, "dw_woody_stgo_30m.tif"),
  overwrite = TRUE
)

message("Descargando raster grass (30m)...")
grass_rast <- rast(ee_as_stars(
  image  = grass_ee,
  region = roi,
  scale  = 30,
  via    = "drive"
))
names(grass_rast) <- "grass"
terra::writeRaster(
  grass_rast,
  file.path(dir_out, "dw_grass_stgo_30m.tif"),
  overwrite = TRUE
)

message("Listo.")
plot(woody_rast, main = "Probabilidad woody: trees + shrubs (30m)")
plot(grass_rast, main = "Probabilidad grass (30m)")
