# Objetivo: obtener los indicadores de calidad y los polígonos de áreas verdes
# urbanas (plazas y parques) a partir de data/raw/SHP/, ver
# data/raw/SHP/README.md para el diccionario de campos y la fuente (INE, 2019).
#
# Salidas (data/processed/SHP/):
#   - areas_verdes_poligonos.gpkg      : todos los polígonos individuales de
#                                         plazas/parques de los 559 centros urbanos,
#                                         con y sin encuesta de calidad
#   - areas_verdes_centros_urbanos.gpkg: indicadores + polígono agregado por
#                                         centro urbano (559 registros)
#   - areas_verdes_indicadores.csv     : mismos indicadores de calidad a nivel de
#                                         plaza/parque individual, sin geometría

library(sf)
library(dplyr)

dir_shp <- file.path("data", "raw", "SHP")
dir_out <- file.path("data", "processed", "SHP")
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)

# --- 1. Lectura ---------------------------------------------------------

pzpq_sin_encuesta <- st_read(file.path(dir_shp, "PZPQ_2018_G3G4.shp"), quiet = TRUE)
pzpq_con_encuesta <- st_read(file.path(dir_shp, "CALIDAD_pzpq_2019_G1G2.shp"), quiet = TRUE)
centros_urbanos <- st_read(file.path(dir_shp, "CALIDAD_LUC_PzPq.shp"), quiet = TRUE)

# --- 2. Limpieza de indicadores de calidad ------------------------------
# En CALIDAD_pzpq_2019_G1G2, los polígonos sin encuesta quedan codificados con
# -1 en MG/VG/AU/SG/DE/CALIDAD (en vez de NA). Se recodifican para que los
# promedios y resúmenes no queden sesgados por ese sentinel.
campos_calidad <- c("MG", "VG", "AU", "SG", "DE", "CALIDAD")

pzpq_con_encuesta <- pzpq_con_encuesta %>%
  mutate(across(all_of(campos_calidad), ~ na_if(.x, -1)))

# --- 3. Polígonos nacionales de plazas/parques individuales -------------
# Se unen los 559 centros urbanos: los 88 con encuesta de calidad
# (CALIDAD_pzpq_2019_G1G2) y el resto, que solo tiene la capa cartográfica
# (PZPQ_2018_G3G4). Se agrega un flag de cobertura y se completan con NA los
# campos de calidad ausentes en pzpq_sin_encuesta para poder unir ambas capas.

pzpq_sin_encuesta <- pzpq_sin_encuesta %>%
  mutate(
    en_88_centros_urbanos = FALSE,
    !!!setNames(rep(list(NA_real_), length(campos_calidad)), campos_calidad),
    RANGO_CALI = NA_character_
  )

pzpq_con_encuesta <- pzpq_con_encuesta %>%
  mutate(en_88_centros_urbanos = TRUE) %>%
  select(-TARGET_FID)

campos_comunes <- intersect(names(pzpq_sin_encuesta), names(pzpq_con_encuesta))

poligonos_av <- bind_rows(
  pzpq_sin_encuesta %>% select(all_of(campos_comunes)),
  pzpq_con_encuesta %>% select(all_of(campos_comunes))
) %>%
  # tiene_encuesta_calidad distingue el polígono realmente encuestado
  # (CALIDAD no nula) de los que solo pertenecen a los 88 centros urbanos
  # seleccionados pero quedaron "SIN INFORMACIÓN"
  mutate(tiene_encuesta_calidad = !is.na(CALIDAD))

# --- 4. Guardar salidas ---------------------------------------------------

st_write(poligonos_av, file.path(dir_out, "areas_verdes_poligonos.gpkg"),
  delete_dsn = TRUE, quiet = TRUE)

st_write(centros_urbanos, file.path(dir_out, "areas_verdes_centros_urbanos.gpkg"),
  delete_dsn = TRUE, quiet = TRUE)

poligonos_av %>%
  st_drop_geometry() %>%
  filter(tiene_encuesta_calidad) %>%
  select(CUT, REGION, COMUNA, COD_URBANO, URBANO_CEN, TIPO_EP, NOMBRE_EP,
    all_of(campos_calidad), RANGO_CALI) %>%
  write.csv(file.path(dir_out, "areas_verdes_indicadores.csv"), row.names = FALSE)

cat(
  "Polígonos totales:", nrow(poligonos_av), "\n",
  "En los 88 centros urbanos seleccionados:", sum(poligonos_av$en_88_centros_urbanos), "\n",
  "Efectivamente encuestados (CALIDAD no nula):", sum(poligonos_av$tiene_encuesta_calidad), "\n",
  "Centros urbanos:", nrow(centros_urbanos), "\n",
  "Salidas escritas en:", dir_out, "\n"
)
