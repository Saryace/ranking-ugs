# ── 06_ndvi_mapa.R ────────────────────────────────────────────────────────
# Objetivo: generar un mapa estático de NDVI (vigor de la vegetación) de
# Santiago, a partir del raster ya reparado por 07_ndvi_repair.R (el crudo
# en data/raw/NDVI/ trae un CRS mal etiquetado — ver data/raw/NDVI/README.md).
#
# Fuente del raster: el NDVI de Santiago se descargó desde GEE usando la
# colección Landsat (LANDSAT/LC08/C02/T1_L2), enero 2024. Este script NO
# descarga el raster (a diferencia de 05_dynamic_world_backup.R) — requiere
# haber corrido antes 07_ndvi_repair.R.
#
# Salida: plots/map_ndvi_santiago.png
#
# Requiere el paquete tidyterra (no instalado en este entorno — no se pudo
# ejecutar ni verificar este script aquí).
# ─────────────────────────────────────────────────────────────────────────

library(terra)
library(ggplot2)
library(tidyterra)

# Cargar raster NDVI (reparado por 07_ndvi_repair.R) --------------------------
ndvi_rast <- rast(file.path("data", "processed", "NDVI", "NDVI_Santiago_Jan2024_30m_repaired.tif"))

# Paleta de colores (la misma del script de GEE) ------------------------------
gee_palette <- c('#ece7f2', '#a6bddb', '#2ca25f', '#006d2c')

# Generar el mapa --------------------------------------------------------------
ndvi_map <- ggplot() +
  geom_spatraster(data = ndvi_rast) +
  scale_fill_gradientn(
    colors = gee_palette,
    name = "NDVI",
    limits = c(0, 0.8),
    na.value = "transparent"
  ) +
  coord_sf(expand = FALSE) +
  theme_minimal() +
  labs(
    title = "Vigor de la vegetación (NDVI) - Santiago urbano",
    subtitle = "Enero 2024 | Landsat 8 & 9 (30m)",
    caption = "Proyecto: ranking-ugs / stgo-hot"
  )

# Guardar en plots/ -------------------------------------------------------------
if (!dir.exists("plots")) dir.create("plots")
ggsave("plots/map_ndvi_santiago.png", ndvi_map, width = 10, height = 8, dpi = 600)
