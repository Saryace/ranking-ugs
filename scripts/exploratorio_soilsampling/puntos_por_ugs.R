# EXPLORATORIO — se puede borrar entera la carpeta scripts/exploratorio_soilsampling/
# (y la línea {{< include >}} en mapa_ugs.qmd) sin afectar el resto del proyecto.
#
# Objetivo: probar el paquete soilsampling (https://github.com/ccarbajal16/soilsampling)
# para ubicar puntos de muestreo de suelo DENTRO de cada uno de los 144 sitios
# de la muestra de carbono (data/processed/indicadores/muestra_carbono_rm.gpkg).
#
# Por qué no se usa ss_kl_size() (n óptimo por divergencia KL): la mediana de
# los sitios es ~2.900 m², o sea 1-5 píxeles de 30 m de NDVI/Dynamic World/LST.
# No hay distribución de covariables dentro de una plaza que "cubrir", y KL
# mide cobertura del espacio de covariables, no precisión del carbono.
#
# Entonces:
#   1) n por sitio = regla por tramo de área (supuesto, ajustable abajo en
#      TRAMOS). Lo que realmente debería fijar n es la variabilidad de COS
#      dentro del sitio (n = (t·CV/E)²) — ver tabla en el tab de Quarto.
#   2) Ubicación: ss_coverage_equal_area() — k-means con estratos de igual
#      área (algoritmo swop, como spcosa) y punto en el centroide de cada
#      estrato. Sirve igual para muestras individuales o para un compuesto
#      por sitio (una submuestra por estrato, igual peso por igual área).
#
# Requiere: remotes::install_github("ccarbajal16/soilsampling")
#
# Salidas (data/processed/exploratorio_soilsampling/, no versionado):
#   - puntos_soilsampling.gpkg, capa "sitios"  : los 144 sitios con n asignado (clave `sitio`)
#   - puntos_soilsampling.gpkg, capa "puntos"  : puntos de muestreo (EPSG:32719)
#   - puntos_soilsampling.gpkg, capa "estratos": estratos de igual área por sitio
#   - resumen_por_sitio.csv                    : n por sitio y chequeos

library(sf)
library(dplyr)
library(soilsampling)

set.seed(20261111)

dir_out <- "data/processed/exploratorio_soilsampling"
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)

# ---- Regla de n por tramo de área (m²) -------------------------------------
TRAMOS <- data.frame(
  area_max = c(2000, 5000, 10000, 50000, Inf),
  n        = c(3,    4,    5,     8,     12),
  tramo    = c("≤ 0,2 ha", "0,2–0,5 ha", "0,5–1 ha", "1–5 ha", "> 5 ha")
)

muestra <- st_read("data/processed/indicadores/muestra_carbono_rm.gpkg", quiet = TRUE) |>
  st_transform(32719) |>
  st_make_valid() |>  # p. ej. parque_la_aguada trae un anillo inválido
  select(id, TIPO_EP, area_m2, calidad_q, temp_af_q) |>
  mutate(sitio = row_number(), .before = 1)  # `id` NO es único (47 repetidos, p. ej. plaza_sin_nombre)

idx <- findInterval(muestra$area_m2, c(0, TRAMOS$area_max), left.open = TRUE)
muestra$n_puntos <- TRAMOS$n[idx]
muestra$tramo    <- TRAMOS$tramo[idx]

# ---- Puntos + estratos por sitio --------------------------------------------
puntos_sitio <- function(poly) {
  # Grilla más densa en sitios chicos para que los estratos no queden de 1-2 celdas
  n_cells <- max(300L, min(1000L, as.integer(poly$area_m2 / 10)))
  s <- ss_coverage_equal_area(poly["id"], n_strata = poly$n_puntos,
                              n_try = 1L, n_cells = n_cells)

  pts <- ss_to_sf(s, "samples") |>
    mutate(sitio = poly$sitio, id = poly$id, dentro = as.vector(st_within(geometry, st_geometry(poly), sparse = FALSE)))

  # Estratos como polígonos: Voronoi de las celdas, disuelto por estrato y
  # recortado al sitio (solo para visualizar).
  celdas <- ss_to_sf(s, "cells")
  vor <- st_voronoi(st_union(celdas), envelope = st_geometry(poly)) |>
    st_collection_extract("POLYGON") |>
    st_sf(geometry = _, crs = st_crs(poly))
  vor$stratum_id <- celdas$stratum_id[unlist(st_intersects(vor, celdas) |> lapply(`[`, 1))]
  estr <- vor |>
    st_intersection(st_geometry(poly)) |>
    st_make_valid() |>
    st_set_precision(100) |>  # snap a 1 cm: evita TopologyException al disolver
    group_by(stratum_id) |>
    summarise(.groups = "drop") |>
    mutate(sitio = poly$sitio, id = poly$id)

  list(puntos = pts, estratos = estr)
}

res <- lapply(seq_len(nrow(muestra)), function(i) {
  t0 <- Sys.time()
  out <- try(puntos_sitio(muestra[i, ]), silent = TRUE)
  message(i, " ", muestra$id[i], " ", round(as.numeric(Sys.time() - t0, units = "secs"), 1), "s")
  if (inherits(out, "try-error")) {
    message("Falló sitio ", muestra$id[i], ": ", conditionMessage(attr(out, "condition")))
    return(NULL)
  }
  out
})

puntos   <- bind_rows(lapply(res, `[[`, "puntos"))
estratos <- bind_rows(lapply(res, `[[`, "estratos"))

# Los centroides de estrato pueden caer fuera en polígonos muy cóncavos:
# en ese caso se mueven al punto más cercano dentro del sitio.
fuera <- which(!puntos$dentro)
if (length(fuera)) {
  for (k in fuera) {
    poly <- st_geometry(muestra[muestra$sitio == puntos$sitio[k], ])
    puntos$geometry[k] <- st_cast(st_nearest_points(puntos$geometry[k], poly), "POINT")[2]
  }
}

st_write(muestra, file.path(dir_out, "puntos_soilsampling.gpkg"), "sitios",
         delete_layer = TRUE, quiet = TRUE)
st_write(puntos, file.path(dir_out, "puntos_soilsampling.gpkg"), "puntos",
         delete_layer = TRUE, quiet = TRUE)
st_write(estratos, file.path(dir_out, "puntos_soilsampling.gpkg"), "estratos",
         delete_layer = TRUE, quiet = TRUE)

resumen <- muestra |>
  st_drop_geometry() |>
  left_join(
    puntos |> st_drop_geometry() |> count(sitio, name = "n_logrado"),
    by = "sitio"
  ) |>
  left_join(
    puntos |> st_drop_geometry() |> group_by(sitio) |> summarise(n_movidos = sum(!dentro)),
    by = "sitio"
  )
write.csv(resumen, file.path(dir_out, "resumen_por_sitio.csv"), row.names = FALSE)

cat("Sitios:", nrow(muestra), "| sin puntos:", sum(is.na(resumen$n_logrado)),
    "| puntos totales:", nrow(puntos), "| movidos al interior:", length(fuera), "\n")
