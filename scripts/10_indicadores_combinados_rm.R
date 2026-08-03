# Objetivo: combinar, a nivel de plaza/parque individual (Región
# Metropolitana), los indicadores que alimentan el ranking final (ver README
# raíz — "Objetivo final"): calidad (+ su cuartil Q1-Q4), NDVI, temperatura
# de tarde (AF, + su cuartil Q1-Q4), cobertura woody/grass, y área — vía
# estadística zonal (promedio del raster dentro de cada polígono).
#
# Salidas (data/processed/indicadores/):
#   - areas_verdes_rm_indicadores.gpkg : un registro por plaza/parque, con
#                                         todos los indicadores + calidad_q
#                                         + temp_af_q
#   - resumen_tipo_ep.csv              : promedios agrupados por PLAZA/PARQUE
#   - conteo_calidad_quartil.csv       : conteo de plazas/parques por
#                                         cuartil de calidad

library(sf)
library(terra)
library(dplyr)

dir_out <- file.path("data", "processed", "indicadores")
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)

areas <- st_read(file.path("data", "processed", "SHP", "areas_verdes_rm.gpkg"), quiet = TRUE)

# --- 1. Cuartiles de calidad (Q1 = más baja, Q4 = más alta) -----------------
q_calidad <- quantile(areas$CALIDAD, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)
areas$calidad_q <- cut(areas$CALIDAD, breaks = q_calidad,
  labels = paste0("Q", 1:4), include.lowest = TRUE)

# --- 2. Estadística zonal (promedio del raster por polígono) ---------------
# Para polígonos más pequeños que un píxel (frecuente en plazas chicas), el
# promedio por área da NA; se completa con el valor en el centroide.
extraer_zonal_promedio <- function(raster, poligonos) {
  poligonos_t <- st_transform(poligonos, crs(raster))
  v <- terra::extract(raster, vect(poligonos_t), fun = mean, na.rm = TRUE, ID = FALSE)[[1]]
  faltantes <- is.na(v)
  if (any(faltantes)) {
    centroides <- st_centroid(poligonos_t[faltantes, ])
    v[faltantes] <- terra::extract(raster, vect(centroides), ID = FALSE)[[1]]
  }
  v
}

ndvi <- rast(file.path("data", "processed", "NDVI", "NDVI_Santiago_Jan2024_30m_repaired.tif"))
temp_af <- rast(file.path("data", "raw", "stgo-hot", "santiago-chile_af_temp_c.tif"))
woody <- rast(file.path("data", "raw", "dw-wood-grass", "dw_woody_stgo_30m.tif"))
grass <- rast(file.path("data", "raw", "dw-wood-grass", "dw_grass_stgo_30m.tif"))

areas$ndvi_medio <- extraer_zonal_promedio(ndvi, areas)
areas$temp_af_medio_c <- extraer_zonal_promedio(temp_af, areas)
areas$woody_medio <- extraer_zonal_promedio(woody, areas)
areas$grass_medio <- extraer_zonal_promedio(grass, areas)

# Cuartiles de temperatura de tarde (Q1 = más fría, Q4 = más caliente)
q_temp_af <- quantile(areas$temp_af_medio_c, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)
areas$temp_af_q <- cut(areas$temp_af_medio_c, breaks = q_temp_af,
  labels = paste0("Q", 1:4), include.lowest = TRUE)

st_write(areas, file.path(dir_out, "areas_verdes_rm_indicadores.gpkg"),
  delete_dsn = TRUE, quiet = TRUE)

# --- 3. Descriptivos agrupados por tipo de espacio público ------------------
resumen_tipo_ep <- areas %>%
  st_drop_geometry() %>%
  group_by(TIPO_EP) %>%
  summarise(
    n = n(),
    area_m2_prom = mean(area_m2, na.rm = TRUE),
    calidad_prom = mean(CALIDAD, na.rm = TRUE),
    ndvi_prom = mean(ndvi_medio, na.rm = TRUE),
    temp_af_prom_c = mean(temp_af_medio_c, na.rm = TRUE),
    woody_prom = mean(woody_medio, na.rm = TRUE),
    grass_prom = mean(grass_medio, na.rm = TRUE),
    .groups = "drop"
  )
write.csv(resumen_tipo_ep, file.path(dir_out, "resumen_tipo_ep.csv"), row.names = FALSE)

# --- 4. Conteo por tipo x cuartil de calidad ---------------------------------
conteo_calidad_q <- areas %>%
  st_drop_geometry() %>%
  count(TIPO_EP, calidad_q, name = "n")
write.csv(conteo_calidad_q, file.path(dir_out, "conteo_calidad_quartil.csv"), row.names = FALSE)

cat("Cortes de cuartil de CALIDAD:", round(q_calidad, 1), "\n")
cat("Cortes de cuartil de temp. AF (°C):", round(q_temp_af, 2), "\n")
print(resumen_tipo_ep)
cat("Salidas escritas en:", dir_out, "\n")
