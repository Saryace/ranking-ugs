# Objetivo: generar el buffer de "5 minutos caminando" alrededor de cada
# estación de Metro de Santiago (data/raw/metro/), como insumo para
# priorizar áreas verdes cercanas al Metro en el ranking final (ver README
# raíz). Primera aproximación: buffer euclidiano recto, NO una isócrona real
# de red peatonal (calles/veredas) — más simple, pero sobreestima el área
# realmente alcanzable a pie en una cuadrícula urbana. Se puede refinar más
# adelante con un cálculo de isócronas sobre la red vial.
#
# Supuesto de conversión tiempo -> distancia: velocidad de caminata de
# referencia ~4,8 km/h (80 m/min) — el estándar usado en planificación
# urbana para "5 minutos caminando" ~ 400 m de radio (p. ej. el cuarto de
# milla usado por agencias de transporte para paradas de bus).
#
# Salida: data/processed/metro/metro_buffer_5min.gpkg
#   - capa "estaciones"          : los 117 puntos de estación, reproyectados
#   - capa "buffer_individual"   : un círculo de 400m por estación (117), con
#                                   los atributos originales (nombre, linea,
#                                   estado, etc.)
#   - capa "buffer_disuelto"     : unión de todos los círculos en una sola
#                                   geometría de cobertura "a 5 min de algún
#                                   metro" (multipolígono)

library(sf)
library(dplyr)

dir_raw <- file.path("data", "raw", "metro")
dir_out <- file.path("data", "processed", "metro")
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)

crs_metrico <- 32719 # WGS 84 / UTM 19S — mismo CRS usado en el resto del repo
radio_5min_m <- 400  # 5 min * 80 m/min (velocidad de caminata de referencia)

estaciones <- st_read(file.path(dir_raw, "estaciones_metro_santiago.geojson"), quiet = TRUE) %>%
  mutate(
    estacion = ifelse(estacion == "EXSTENTE", "EXISTENTE", estacion),
    especial = ifelse(especial == "EXSTENTE", "EXISTENTE", especial)
  ) %>%
  st_transform(crs_metrico)

buffer_individual <- estaciones %>%
  st_buffer(dist = radio_5min_m)

buffer_disuelto <- buffer_individual %>%
  st_union() %>%
  st_sf(geometry = ., radio_m = radio_5min_m)

archivo_gpkg <- file.path(dir_out, "metro_buffer_5min.gpkg")
st_write(estaciones, archivo_gpkg, layer = "estaciones", delete_dsn = TRUE, quiet = TRUE)
st_write(buffer_individual, archivo_gpkg, layer = "buffer_individual", delete_dsn = FALSE, quiet = TRUE)
st_write(buffer_disuelto, archivo_gpkg, layer = "buffer_disuelto", delete_dsn = FALSE, quiet = TRUE)

cat(
  "Estaciones:", nrow(estaciones), "\n",
  "Radio de buffer (5 min caminando):", radio_5min_m, "m\n",
  "Área cubierta (buffer disuelto, km2):", round(as.numeric(st_area(buffer_disuelto)) / 1e6, 1), "\n",
  "Salida:", archivo_gpkg, "\n"
)
