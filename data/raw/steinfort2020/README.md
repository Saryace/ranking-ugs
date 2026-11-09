# data/raw/steinfort2020 — Propiedades de suelo en plazas y parques (Steinfort et al. 2020)

**Fuente:** Steinfort, U., Contreras, A., Albornoz, F., Reyes-Paecke, S. &
Guilleminot, P. (2020). *Vegetation survival and condition in public green
spaces after their establishment: Evidence from a semi-arid metropolis.*
International Journal of Agriculture and Natural Resources, 47(2).
[doi:10.7764/ijanr.v47i2.2045](http://dx.doi.org/10.7764/ijanr.v47i2.2045) —
[SciELO](https://www.scielo.cl/article_plus.php?pid=S2452-57312020000200090&tlng=en&lng=es).

Tabla de propiedades químicas de suelo por sitio de estudio (tabla del paper
"Soil pH, electrical conductivity (EC), organic matter (OM), nitrogen (N),
phosphorous (P) and potassium (K) content at the study sites"), con
coordenadas de cada plaza/parque agregadas a mano.

## Archivo

`steinfort2020.csv` — **33 sitios** (plazas y parques de la Región
Metropolitana), coordenadas en `EPSG:4326` (lat/lon decimales).

## Diccionario de campos

| Campo | Significado | Unidad |
|---|---|---|
| `nombre_plaza` | Nombre de la plaza/parque | — |
| `lat`, `lon` | Latitud / longitud | grados decimales (WGS84) |
| `pH` | pH del suelo | — |
| `EC` | Conductividad eléctrica | mS cm⁻¹ |
| `OM` | Materia orgánica | % |
| `N` | Nitrógeno | mg kg⁻¹ |
| `P` | Fósforo | mg kg⁻¹ |
| `K` | Potasio | mg kg⁻¹ |

Unidades tomadas del encabezado de la tabla del paper. Ver el paper para la
metodología de muestreo y análisis.
