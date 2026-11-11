# EXPLORATORIO — se puede borrar con toda la carpeta scripts/exploratorio_soilsampling/.
#
# Igual que puntos_por_ugs.R, pero para TODAS las áreas verdes de la RM
# (data/processed/SHP/areas_verdes_rm.gpkg, ~10.200 polígonos), no solo los
# 144 sitios de la muestra. Misma regla de n por tramo de área (tramos.R) y
# mismo método de ubicación (ss_coverage_equal_area()), pero sin estratos
# como polígonos (solo puntos) para que corra en tiempo razonable.
#
# Corre en paralelo (parallel::mclapply, fork — macOS/Linux). ~10-20 min.
#
# Salidas (data/processed/exploratorio_soilsampling/, no versionado):
#   - puntos_todas_ugs.gpkg, capa "ugs"    : todas las UGS con n asignado (clave `ugs`)
#   - puntos_todas_ugs.gpkg, capa "puntos" : puntos de muestreo (EPSG:32719)
#   - resumen_todas_ugs.csv                : n por UGS y chequeos

library(sf)
library(dplyr)
library(parallel)
library(soilsampling)

source("scripts/exploratorio_soilsampling/tramos.R")

dir_out <- "data/processed/exploratorio_soilsampling"
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)

ugs <- st_read("data/processed/SHP/areas_verdes_rm.gpkg", quiet = TRUE) |>
  st_transform(32719) |>
  st_make_valid() |>
  select(id, TIPO_EP, area_m2) |>
  mutate(ugs = row_number(), .before = 1) |>  # `id` no es único
  asignar_tramo()

puntos_ugs <- function(i) {
  poly <- ugs[i, ]
  n_cells <- max(300L, min(1000L, as.integer(poly$area_m2 / 10)))
  s <- try(ss_coverage_equal_area(poly["id"], n_strata = poly$n_puntos,
                                  n_try = 1L, n_cells = n_cells), silent = TRUE)
  if (inherits(s, "try-error")) return(NULL)
  pts <- ss_to_sf(s, "samples")
  pts$ugs <- poly$ugs
  # Centroides fuera del polígono (formas cóncavas) -> punto más cercano dentro
  fuera <- !as.vector(st_within(pts, poly, sparse = FALSE))
  pts$movido <- fuera
  for (k in which(fuera)) {
    pts$geometry[k] <- st_cast(st_nearest_points(pts$geometry[k], st_geometry(poly)), "POINT")[2]
  }
  pts
}

RNGkind("L'Ecuyer-CMRG")
set.seed(20261111)
t0 <- Sys.time()
res <- mclapply(seq_len(nrow(ugs)), puntos_ugs,
                mc.cores = max(1L, detectCores() - 1L), mc.set.seed = TRUE)
message("Tiempo: ", round(as.numeric(Sys.time() - t0, units = "mins"), 1), " min")

ok <- vapply(res, function(r) inherits(r, "sf"), logical(1))
puntos <- bind_rows(res[ok]) |>
  left_join(st_drop_geometry(ugs) |> select(ugs, id, TIPO_EP), by = "ugs")

st_write(ugs, file.path(dir_out, "puntos_todas_ugs.gpkg"), "ugs",
         delete_layer = TRUE, quiet = TRUE)
st_write(puntos, file.path(dir_out, "puntos_todas_ugs.gpkg"), "puntos",
         delete_layer = TRUE, quiet = TRUE)

resumen <- ugs |>
  st_drop_geometry() |>
  left_join(
    puntos |> st_drop_geometry() |>
      group_by(ugs) |> summarise(n_logrado = n(), n_movidos = sum(movido)),
    by = "ugs"
  )
write.csv(resumen, file.path(dir_out, "resumen_todas_ugs.csv"), row.names = FALSE)

cat("UGS:", nrow(ugs), "| sin puntos:", sum(!ok), "| puntos totales:", nrow(puntos),
    "| movidos al interior:", sum(puntos$movido), "\n")
