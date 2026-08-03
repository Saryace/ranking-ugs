# Objetivo: un solo objeto espacial con las plazas y parques de la Región
# Metropolitana de Santiago, con sus indicadores de vegetación y calidad.
# Ver data/processed/SHP/README.md para el diccionario de las variables de salida.
#
# Salida: data/processed/SHP/areas_verdes_rm.gpkg

library(sf)
library(dplyr)
library(stringi)

dir_shp <- file.path("data", "raw", "SHP")
dir_out <- file.path("data", "processed", "SHP")
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)

pzpq <- st_read(file.path(dir_shp, "CALIDAD_pzpq_2019_G1G2.shp"), quiet = TRUE)

areas_verdes_rm <- pzpq %>%
  filter(REGION == "METROPOLITANA DE SANTIAGO") %>%
  # -1 marca polígonos sin encuesta de calidad (ver data/SHP/README.md); se
  # recodifica a NA para no sesgar el indicador
  mutate(across(c(VG, CALIDAD), ~ na_if(.x, -1))) %>%
  mutate(
    id = paste(TIPO_EP, coalesce(NOMBRE_EP, "sin_nombre")) %>%
      stri_trans_general("Latin-ASCII") %>%
      tolower() %>%
      gsub("[^a-z0-9]+", "_", .) %>%
      gsub("^_|_$", "", .),
    ID_MINVU_Calidad = ID_TEXT,
    area_m2 = SUP_TOTAL_
  ) %>%
  select(id, ID_MINVU_Calidad, TIPO_EP, area_m2, Estratos_v, Estado_veg,
    VG, CALIDAD, RANGO_CALI, geometry)

st_write(areas_verdes_rm, file.path(dir_out, "areas_verdes_rm.gpkg"),
  delete_dsn = TRUE, quiet = TRUE)

cat("Polígonos Región Metropolitana:", nrow(areas_verdes_rm), "\n",
  "Salida:", file.path(dir_out, "areas_verdes_rm.gpkg"), "\n")
