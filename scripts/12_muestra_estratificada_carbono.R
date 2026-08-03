# Objetivo: muestra aleatoria estratificada de ~120-150 plazas/parques de la
# Región Metropolitana para terreno (medición de carbono en suelo), a partir
# del ranking de 11_ranking_final_rm.R. Tamaño subido de 112 a 144 para dejar
# sitios de respaldo por si hay problemas de acceso/muestreo en terreno. Ver
# README raíz ("Objetivo final") y data/processed/indicadores/README.md.
#
# Diseño (inspirado en Vasenev et al. 2014, Geoderma 226-227:103-115, que
# usa muestreo aleatorizado estratificado por factores de suelo/uso urbano,
# y excluye explícitamente "sealed soils" del muestreo porque no se puede
# tomar una muestra de suelo donde no hay superficie abierta):
#
#   1) Marco muestral: solo polígonos con encuesta de calidad Y con algo de
#      superficie abierta/vegetada (woody_medio + grass_medio > 0.05) —
#      condición mínima para poder tomar una muestra de suelo en terreno.
#   2) Estratos — diseño de "grupos extremos": TIPO_EP (PLAZA/PARQUE) x
#      calidad_q (solo Q1 y Q4) x temp_af_q (solo Q1 y Q4) = 8 celdas. Se
#      toman los extremos (no los 4 cuartiles) de calidad y temperatura a
#      propósito, para maximizar el contraste/rango de ambas variables y así
#      el poder para detectar asociaciones con carbono en una muestra de
#      tamaño moderado (n~110) — es un diseño de "differences marcadas", no
#      uno representativo de la distribución completa.
#   3) Asignación: igual por celda como objetivo (N_OBJETIVO / 8), pero
#      capada por la disponibilidad real de cada celda. PARQUE de alta
#      calidad (Q4) casi no coincide con temperaturas altas (Q4) — apenas 5
#      polígonos en toda la RM — así que esas celdas chicas se muestrean
#      completas (censo) y el resto del objetivo se redistribuye a las
#      celdas con más disponibilidad (ver `asignar_con_redistribucion()`).
#   4) Dentro de cada celda, prioridad a estar a 5 min de Metro: se llena
#      hasta PROP_PRIORIDAD_METRO de la cuota de la celda con candidatos
#      cerca de Metro (si hay suficientes) antes de completar al azar con el
#      resto.
#
# Salidas (data/processed/indicadores/):
#   - muestra_carbono_rm.gpkg   : los sitios seleccionados
#   - muestra_asignacion.csv    : cuota objetivo vs. lograda por celda, y %
#                                  cerca de Metro logrado

library(sf)
library(dplyr)

SEMILLA <- 2024
N_OBJETIVO <- 144 # subido de 112 a 144 (rango 120-150) para tener respaldo por si hay problemas de muestreo en terreno
PROP_PRIORIDAD_METRO <- 0.7

set.seed(SEMILLA)

dir_out <- file.path("data", "processed", "indicadores")

ranking <- st_read(file.path(dir_out, "ranking_final_rm.gpkg"), quiet = TRUE)

# --- 1. Marco muestral: calidad y temperatura extremas, con vegetación -----
marco <- ranking %>%
  mutate(veg_total_medio = woody_medio + grass_medio) %>%
  filter(
    veg_total_medio > 0.05,
    calidad_q %in% c("Q1", "Q4"),
    temp_af_q %in% c("Q1", "Q4")
  )

n_celdas_df <- marco %>% st_drop_geometry() %>%
  count(TIPO_EP, calidad_q, temp_af_q, name = "n_disponible")
n_celdas <- nrow(n_celdas_df)

# --- 2. Asignación por celda con redistribución del déficit -----------------
# Reparte N_OBJETIVO en partes iguales entre las celdas, pero cuando una
# celda no tiene suficientes candidatos, el faltante se reparte (1 a la vez)
# entre las celdas que todavía tienen margen, hasta agotar el objetivo o la
# disponibilidad total.
asignar_con_redistribucion <- function(disponible, objetivo_total) {
  n <- length(disponible)
  cuota <- rep(floor(objetivo_total / n), n)
  asignado <- pmin(cuota, disponible)
  faltante <- objetivo_total - sum(asignado)
  repeat {
    con_margen <- which(asignado < disponible)
    if (faltante <= 0 || length(con_margen) == 0) break
    tomar <- head(con_margen, faltante)
    asignado[tomar] <- asignado[tomar] + 1
    faltante <- objetivo_total - sum(asignado)
  }
  asignado
}

n_celdas_df$n_objetivo_celda <- asignar_con_redistribucion(n_celdas_df$n_disponible, N_OBJETIVO)

# --- 3. Selección dentro de cada celda, priorizando cercanía a Metro -------
seleccionar_celda <- function(candidatos, n_meta, prop_metro) {
  n_meta <- min(n_meta, nrow(candidatos))
  n_metro_meta <- ceiling(n_meta * prop_metro)

  cerca <- candidatos %>% filter(cerca_metro_5min)
  lejos <- candidatos %>% filter(!cerca_metro_5min)

  n_de_cerca <- min(n_metro_meta, nrow(cerca))
  sel_cerca <- cerca %>% slice_sample(n = n_de_cerca)

  n_de_lejos <- n_meta - n_de_cerca
  sel_lejos <- lejos %>% slice_sample(n = min(n_de_lejos, nrow(lejos)))

  bind_rows(sel_cerca, sel_lejos)
}

marco_df <- marco %>% st_drop_geometry() %>% mutate(.fila = row_number()) %>%
  left_join(n_celdas_df %>% select(TIPO_EP, calidad_q, temp_af_q, n_objetivo_celda),
    by = c("TIPO_EP", "calidad_q", "temp_af_q"))

muestra_filas <- marco_df %>%
  group_by(TIPO_EP, calidad_q, temp_af_q) %>%
  group_modify(~ seleccionar_celda(.x, .x$n_objetivo_celda[1], PROP_PRIORIDAD_METRO)) %>%
  ungroup()

muestra <- marco[muestra_filas$.fila, ]

st_write(muestra, file.path(dir_out, "muestra_carbono_rm.gpkg"), delete_dsn = TRUE, quiet = TRUE)

# --- 4. Resumen de asignación ------------------------------------------------
asignacion <- muestra %>%
  st_drop_geometry() %>%
  group_by(TIPO_EP, calidad_q, temp_af_q) %>%
  summarise(
    n_disponible = n_celdas_df$n_disponible[
      n_celdas_df$TIPO_EP == first(TIPO_EP) &
        n_celdas_df$calidad_q == first(calidad_q) &
        n_celdas_df$temp_af_q == first(temp_af_q)
    ],
    n_objetivo = n_celdas_df$n_objetivo_celda[
      n_celdas_df$TIPO_EP == first(TIPO_EP) &
        n_celdas_df$calidad_q == first(calidad_q) &
        n_celdas_df$temp_af_q == first(temp_af_q)
    ],
    n_logrado = n(),
    n_cerca_metro = sum(cerca_metro_5min),
    pct_cerca_metro = round(100 * mean(cerca_metro_5min), 1),
    .groups = "drop"
  )
write.csv(asignacion, file.path(dir_out, "muestra_asignacion.csv"), row.names = FALSE)

cat(
  "Semilla:", SEMILLA, "\n",
  "Marco muestral (calidad y temp. extremas, con vegetación):", nrow(marco), "\n",
  "Celdas:", n_celdas, "\n",
  "Muestra final:", nrow(muestra), "\n",
  "Cerca de Metro (5 min):", sum(muestra$cerca_metro_5min),
  sprintf("(%.1f%%)\n", 100 * mean(muestra$cerca_metro_5min))
)
print(as.data.frame(asignacion))
