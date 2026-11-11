# EXPLORATORIO — regla de n por tramo de área (m²), compartida por
# puntos_por_ugs.R (144 sitios) y puntos_todas_ugs.R (todas las UGS de la RM).
# Es un supuesto: lo que debería fijar n es el CV de COS dentro del sitio.
TRAMOS <- data.frame(
  area_max = c(2000, 5000, 10000, 50000, Inf),
  n        = c(3,    4,    5,     8,     12),
  tramo    = c("≤ 0,2 ha", "0,2–0,5 ha", "0,5–1 ha", "1–5 ha", "> 5 ha")
)

asignar_tramo <- function(x) {
  idx <- findInterval(x$area_m2, c(0, TRAMOS$area_max), left.open = TRUE)
  x$n_puntos <- TRAMOS$n[idx]
  x$tramo    <- TRAMOS$tramo[idx]
  x
}
