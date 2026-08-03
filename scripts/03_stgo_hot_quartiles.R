# Objetivo: categorizar cada píxel de los rasters de temperatura de Santiago
# (data/raw/stgo-hot/) en cuartiles (Q1 = más frío, Q4 = más caliente),
# calculados por separado para cada período del día (am/af/pm), ya que sus
# rangos de temperatura no son comparables entre sí.
# Ver data/raw/stgo-hot/README.md (fuente) y data/processed/stgo-hot/README.md
# (diccionario de salida).
#
# Salidas (data/processed/stgo-hot/):
#   - santiago-chile_{periodo}_temp_c_quartil.tif : raster categórico 1-4 por píxel
#   - quartiles_cortes.csv                        : puntos de corte usados por raster

library(terra)

dir_raw <- file.path("data", "raw", "stgo-hot")
dir_out <- file.path("data", "processed", "stgo-hot")
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)

archivos <- list.files(dir_raw, pattern = "_temp_c[.]tif$", full.names = TRUE)

cortes <- list()

for (f in archivos) {
  r <- rast(f)
  q <- quantile(values(r), probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)

  # matriz de reclasificación: intervalos (from, to] -> categoría 1:4
  rcl <- matrix(
    c(
      -Inf,   q[2], 1,
      q[2],   q[3], 2,
      q[3],   q[4], 3,
      q[4],    Inf, 4
    ),
    ncol = 3, byrow = TRUE
  )

  r_q <- classify(r, rcl, include.lowest = TRUE)
  names(r_q) <- "cuartil_temp"

  nombre_base <- tools::file_path_sans_ext(basename(f))
  writeRaster(r_q, file.path(dir_out, paste0(nombre_base, "_quartil.tif")),
    datatype = "INT1U", overwrite = TRUE)

  cortes[[nombre_base]] <- data.frame(
    raster = nombre_base,
    min_c = q[1], q25_c = q[2], mediana_c = q[3], q75_c = q[4], max_c = q[5]
  )

  cat(nombre_base, ": cortes (°C) =", round(q, 2), "\n")
}

write.csv(do.call(rbind, cortes), file.path(dir_out, "quartiles_cortes.csv"),
  row.names = FALSE)
