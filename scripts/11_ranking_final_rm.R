# Objetivo: ranking compuesto de todas las plazas/parques de la Región
# Metropolitana con encuesta de calidad, combinando calidad, temperatura de
# tarde (AF, invertida: más fría = mejor), NDVI, cobertura vegetal
# (woody+grass) y área. Ver README raíz ("Objetivo final") y
# data/processed/indicadores/README.md.
#
# Se excluyen del ranking los polígonos sin encuesta de calidad (2.464 de
# 10.243): no tiene sentido puntuarlos junto a los que sí tienen los 5
# indicadores completos. La cercanía a Metro (5 min) se deja como columna
# informativa, no se pondera en el puntaje — es un criterio de conveniencia
# para el muestreo (ver 12_muestra_estratificada_carbono.R), no un atributo
# de "calidad" del espacio público en sí.
#
# Metodología del puntaje: cada indicador se normaliza min-max a [0,1]
# (orientado para que 1 = mejor) y se promedian con igual ponderación. Es una
# elección simple y transparente, no una validada por literatura — ajustar
# los pesos en la sección "3. Puntaje compuesto" si se justifica lo
# contrario.
#
# Salida: data/processed/indicadores/ranking_final_rm.gpkg

library(sf)
library(dplyr)

dir_out <- file.path("data", "processed", "indicadores")
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)

areas <- st_read(file.path(dir_out, "areas_verdes_rm_indicadores.gpkg"), quiet = TRUE)
buffer_metro <- st_read(file.path("data", "processed", "metro", "metro_buffer_5min.gpkg"),
  layer = "buffer_disuelto", quiet = TRUE)

# --- 1. Restringir a polígonos con los 5 indicadores completos -------------
ranking <- areas %>%
  filter(!is.na(CALIDAD), !is.na(ndvi_medio), !is.na(temp_af_medio_c),
    !is.na(woody_medio), !is.na(grass_medio), !is.na(area_m2))

# --- 2. Cercanía a Metro (informativa) --------------------------------------
ranking_32719 <- st_transform(ranking, st_crs(buffer_metro))
ranking$cerca_metro_5min <- lengths(st_intersects(ranking_32719, buffer_metro)) > 0

# --- 3. Puntaje compuesto ----------------------------------------------------
normalizar01 <- function(x, invertir = FALSE) {
  r <- range(x, na.rm = TRUE)
  v <- (x - r[1]) / (r[2] - r[1])
  if (invertir) v <- 1 - v
  v
}

ranking <- ranking %>%
  mutate(
    veg_total_medio = woody_medio + grass_medio,
    n_calidad = normalizar01(CALIDAD),
    n_temp_af = normalizar01(temp_af_medio_c, invertir = TRUE), # más frío = mejor
    n_ndvi = normalizar01(ndvi_medio),
    n_veg = normalizar01(veg_total_medio),
    n_area = normalizar01(area_m2),
    ranking_score = (n_calidad + n_temp_af + n_ndvi + n_veg + n_area) / 5
  ) %>%
  arrange(desc(ranking_score)) %>%
  mutate(ranking_pos = row_number()) %>%
  select(-n_calidad, -n_temp_af, -n_ndvi, -n_veg, -n_area)

st_write(ranking, file.path(dir_out, "ranking_final_rm.gpkg"), delete_dsn = TRUE, quiet = TRUE)

cat(
  "Polígonos en el ranking (con los 5 indicadores completos):", nrow(ranking), "\n",
  "de", nrow(areas), "polígonos totales en la RM\n",
  "Cerca de Metro (5 min):", sum(ranking$cerca_metro_5min),
  sprintf("(%.1f%%)\n", 100 * mean(ranking$cerca_metro_5min)),
  "Top 5:\n"
)
print(ranking %>% st_drop_geometry() %>%
  select(ranking_pos, id, TIPO_EP, CALIDAD, temp_af_medio_c, ndvi_medio, ranking_score) %>%
  head(5))
