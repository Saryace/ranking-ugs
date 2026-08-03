# Objetivo: comparar dos fuentes de plazas/parques (áreas verdes públicas) de la
# Región Metropolitana: la tipología de áreas verdes de OCUC (categoría
# "Públicas") vs. el catastro de calidad de MINVU (CALIDAD_pzpq_2019_G1G2), por
# comuna: cobertura (n° de polígonos, superficie) y superposición espacial.
# Ver data/raw/OCUC-MINVU/README.md y data/raw/SHP/README.md (fuentes) y
# data/processed/OCUC-MINVU/README.md (diccionario de salida).
#
# Salidas (data/processed/OCUC-MINVU/):
#   - comparacion_comunas.csv    : tabla comuna x fuente con conteos, superficies
#                                   y % de superposición
#   - comparacion_poligonos.gpkg : polígonos individuales de ambas fuentes (RM),
#                                   reproyectados a EPSG:32719, en capas separadas

library(sf)
library(dplyr)
library(stringi)

dir_ocuc <- file.path("data", "raw", "OCUC-MINVU")
dir_shp <- file.path("data", "raw", "SHP")
dir_out <- file.path("data", "processed", "OCUC-MINVU")
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)

crs_metrico <- 32719 # WGS 84 / UTM 19S, mismo CRS de los rasters de stgo-hot

normalizar <- function(x) toupper(stri_trans_general(trimws(x), "Latin-ASCII"))

# --- 1. Lectura -----------------------------------------------------------

archivo_ocuc <- list.files(dir_ocuc, pattern = "[.]geojson$", full.names = TRUE)[1]
ocuc <- st_read(archivo_ocuc, quiet = TRUE) %>%
  mutate(comuna_norm = normalizar(COMUNA), tipo_norm = normalizar(TIPO))

# "PAC" es una abreviatura usada solo en esta capa para Pedro Aguirre Cerda
# (ver data/raw/OCUC-MINVU/README.md); se corrige para poder cruzar por comuna
ocuc$comuna_norm[ocuc$comuna_norm == "PAC"] <- "PEDRO AGUIRRE CERDA"

minvu <- st_read(file.path(dir_shp, "CALIDAD_pzpq_2019_G1G2.shp"), quiet = TRUE)
minvu_rm <- minvu %>%
  filter(REGION == "METROPOLITANA DE SANTIAGO") %>%
  mutate(comuna_norm = normalizar(COMUNA))

ocuc_pub <- ocuc %>%
  filter(tipo_norm == "PUBLICAS") %>%
  st_transform(crs_metrico) %>%
  st_make_valid()

minvu_rm <- minvu_rm %>%
  st_transform(crs_metrico) %>%
  st_make_valid()

# --- 2. Unión de geometrías por comuna, por fuente -------------------------

ocuc_por_comuna <- ocuc_pub %>%
  group_by(comuna_norm) %>%
  summarise(n_ocuc_publicas = n(), .groups = "drop") %>%
  st_make_valid()

minvu_por_comuna <- minvu_rm %>%
  group_by(comuna_norm) %>%
  summarise(n_minvu_pzpq = n(), .groups = "drop") %>%
  st_make_valid()

# --- 3. Comparación de área y superposición por comuna ---------------------

todas_comunas <- union(ocuc_por_comuna$comuna_norm, minvu_por_comuna$comuna_norm)

comparacion <- lapply(todas_comunas, function(cm) {
  go <- ocuc_por_comuna %>% filter(comuna_norm == cm)
  gm <- minvu_por_comuna %>% filter(comuna_norm == cm)

  area_ocuc <- if (nrow(go) > 0) as.numeric(st_area(go)) else 0
  area_minvu <- if (nrow(gm) > 0) as.numeric(st_area(gm)) else 0
  area_int <- 0
  if (nrow(go) > 0 && nrow(gm) > 0) {
    inter <- st_intersection(st_geometry(go), st_geometry(gm))
    if (length(inter) > 0) area_int <- as.numeric(st_area(inter))
  }

  data.frame(
    comuna = cm,
    n_ocuc_publicas = if (nrow(go) > 0) go$n_ocuc_publicas else 0L,
    n_minvu_pzpq = if (nrow(gm) > 0) gm$n_minvu_pzpq else 0L,
    area_ocuc_ha = area_ocuc / 1e4,
    area_minvu_ha = area_minvu / 1e4,
    area_interseccion_ha = area_int / 1e4
  )
}) %>%
  bind_rows() %>%
  mutate(
    area_solo_ocuc_ha = area_ocuc_ha - area_interseccion_ha,
    area_solo_minvu_ha = area_minvu_ha - area_interseccion_ha,
    pct_ocuc_solapado = ifelse(area_ocuc_ha > 0, round(100 * area_interseccion_ha / area_ocuc_ha, 1), NA),
    pct_minvu_solapado = ifelse(area_minvu_ha > 0, round(100 * area_interseccion_ha / area_minvu_ha, 1), NA)
  ) %>%
  arrange(desc(area_minvu_ha))

# --- 4. Guardar salidas -----------------------------------------------------

write.csv(comparacion, file.path(dir_out, "comparacion_comunas.csv"), row.names = FALSE)

st_write(ocuc_pub %>% select(comuna_norm, TIPO, AREA_m2, AREA_ha),
  file.path(dir_out, "comparacion_poligonos.gpkg"),
  layer = "ocuc_publicas_rm", delete_dsn = TRUE, quiet = TRUE)
st_write(minvu_rm %>% select(comuna_norm, TIPO_EP, NOMBRE_EP, SUP_TOTAL_, CALIDAD, RANGO_CALI),
  file.path(dir_out, "comparacion_poligonos.gpkg"),
  layer = "minvu_pzpq_rm", delete_dsn = FALSE, quiet = TRUE)

cat(
  "Comunas comparadas:", nrow(comparacion), "\n",
  "Área total OCUC 'Públicas' (ha):", round(sum(comparacion$area_ocuc_ha), 1), "\n",
  "Área total MINVU plazas+parques (ha):", round(sum(comparacion$area_minvu_ha), 1), "\n",
  "Área en intersección (ha):", round(sum(comparacion$area_interseccion_ha), 1), "\n",
  "Salidas escritas en:", dir_out, "\n"
)
