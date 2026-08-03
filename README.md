# ranking-ugs

Proyecto en R para construir un **ranking de áreas verdes urbanas (UGS — Urban Green
Spaces)** en Chile, a partir de datos públicos de indicadores y polígonos de plazas,
parques, temperatura superficial, cobertura vegetal (Dynamic World) y NDVI.

## Objetivo final

Rankear todas las áreas verdes urbanas que cuenten con información de:

- **calidad** (encuesta MINVU — `data/raw/SHP`)
- **temperatura** (rasters `stgo-hot`, categorizados por cuartil)
- **tamaño** (área del polígono)
- **razón pasto/bosque** (`grass`/`woody`, Dynamic World)

Como criterio adicional, se busca **priorizar las áreas verdes a 5 minutos
caminando de una estación de metro de Santiago** — el buffer de 5 minutos ya
está disponible en [`data/processed/metro`](data/processed/metro/README.md)
(por ahora un buffer euclidiano de 400m, no una isócrona de red peatonal
real).

Cada objetivo de datos de la tabla de abajo corresponde a una de estas
variables. [`data/processed/indicadores`](data/processed/indicadores/README.md)
las junta a nivel de plaza/parque individual (calidad + su cuartil, NDVI,
temperatura AF + su cuartil, woody/grass, área), calcula un **ranking
compuesto** de las 7.307 plazas/parques con datos completos
(`ranking_final_rm.gpkg`), y saca de ahí una **muestra aleatoria
estratificada de 144 sitios** (`muestra_carbono_rm.gpkg`, con respaldo por si
hay problemas de muestreo en terreno) para una campaña de
terreno que asocie calidad, temperatura y tipo (plaza/parque) con carbono en
el suelo — estratificada por `TIPO_EP` × **extremos** (Q1 y Q4) de calidad y
de temperatura AF ("diseño de grupos extremos", para maximizar contraste),
priorizando cercanía a Metro — inspirada en
[Vasenev et al. (2014), *Geoderma*](https://doi.org/10.1016/j.geoderma.2014.03.007).

## Estructura del repositorio

```
ranking-ugs/
├── data/
│   ├── raw/                  # datos crudos (fuente original, sin modificar)
│   │   ├── SHP/               # INE — calidad y polígonos de plazas/parques (Chile)
│   │   ├── OCUC-MINVU/        # IDE OCUC — tipología de áreas verdes RM 2017
│   │   ├── stgo-hot/          # rasters de temperatura superficial, Santiago
│   │   ├── dw-wood-grass/     # GEE Dynamic World — probabilidad woody/grass (30m)
│   │   ├── NDVI/              # GEE Landsat — NDVI Santiago, enero 2024 (30m, CRS mal etiquetado)
│   │   └── metro/              # IDE OCUC — estaciones de Metro de Santiago (actuales/proyectadas)
│   └── processed/            # salidas generadas por scripts/ (no versionadas, salvo README.md)
│       ├── SHP/
│       ├── OCUC-MINVU/
│       ├── stgo-hot/
│       ├── NDVI/               # NDVI con CRS reparado
│       ├── dw-wood-grass/      # woody/grass empaquetados en un .gpkg
│       ├── metro/              # buffer de 5 min caminando por estación
│       └── indicadores/        # calidad+cuartil, NDVI, temp. AF, woody/grass, área — por polígono
├── scripts/                  # un script por objetivo de datos
├── plots/                    # imágenes generadas por scripts (no versionado)
├── mapa_ugs.qmd               # mapa interactivo (Quarto/leaflet) de todas las capas
├── docs/index.html            # copia publicada del mapa (GitHub Pages)
└── ranking-ugs.Rproj
```

Cada carpeta dentro de `data/raw/` es una **fuente de datos** distinta, con su
propio `README.md` documentando procedencia, licencia, CRS y diccionario de
campos. Cada script en `scripts/` procesa una o más fuentes crudas para un
objetivo específico y escribe su salida en la subcarpeta correspondiente de
`data/processed/`, también documentada con su propio `README.md`.

## Objetivos de datos

| Objetivo | Fuente(s) | README de salida | Script |
|---|---|---|---|
| Indicadores de calidad y polígonos de plazas/parques, Chile completo (INE, 2019) | [data/raw/SHP](data/raw/SHP/README.md) | [data/processed/SHP](data/processed/SHP/README.md) | [scripts/01_areas_verdes_shp.R](scripts/01_areas_verdes_shp.R) |
| Objeto de plazas/parques con indicadores de vegetación y calidad, Región Metropolitana | [data/raw/SHP](data/raw/SHP/README.md) | [data/processed/SHP](data/processed/SHP/README.md) | [scripts/02_areas_verdes_rm.R](scripts/02_areas_verdes_rm.R) |
| Categorización por cuartiles (Q1–Q4) de temperatura superficial, Santiago | [data/raw/stgo-hot](data/raw/stgo-hot/README.md) | [data/processed/stgo-hot](data/processed/stgo-hot/README.md) | [scripts/03_stgo_hot_quartiles.R](scripts/03_stgo_hot_quartiles.R) |
| Comparación de fuentes de plazas/parques: OCUC vs. MINVU Calidad, por comuna (RM) | [data/raw/OCUC-MINVU](data/raw/OCUC-MINVU/README.md), [data/raw/SHP](data/raw/SHP/README.md) | [data/processed/OCUC-MINVU](data/processed/OCUC-MINVU/README.md) | [scripts/04_ocuc_vs_minvu_comparacion.R](scripts/04_ocuc_vs_minvu_comparacion.R) |
| Respaldo/regeneración de cobertura woody + grass (Dynamic World, GEE), ciudad completa | [data/raw/dw-wood-grass](data/raw/dw-wood-grass/README.md) | *(descarga los .tif directamente en `data/raw/`, ver README)* | [scripts/05_dynamic_world_backup.R](scripts/05_dynamic_world_backup.R) |
| Mapa de NDVI de Santiago (Landsat, GEE) | [data/raw/NDVI](data/raw/NDVI/README.md) | `plots/map_ndvi_santiago.png` | [scripts/06_ndvi_mapa.R](scripts/06_ndvi_mapa.R) |
| Reparación del CRS mal etiquetado del raster NDVI crudo | [data/raw/NDVI](data/raw/NDVI/README.md) | [data/processed/NDVI](data/processed/NDVI/README.md) | [scripts/07_ndvi_repair.R](scripts/07_ndvi_repair.R) |
| Empaquetado de woody + grass como capas ráster de un mismo GeoPackage | [data/raw/dw-wood-grass](data/raw/dw-wood-grass/README.md) | [data/processed/dw-wood-grass](data/processed/dw-wood-grass/README.md) | [scripts/08_dw_wood_grass_gpkg.R](scripts/08_dw_wood_grass_gpkg.R) |
| Buffer de 5 min caminando (400m) alrededor de cada estación de Metro | [data/raw/metro](data/raw/metro/README.md) | [data/processed/metro](data/processed/metro/README.md) | [scripts/09_metro_buffer_5min.R](scripts/09_metro_buffer_5min.R) |
| Calidad (+ cuartil), NDVI, temp. AF, woody/grass y área combinados por plaza/parque (RM) | [data/raw/SHP](data/raw/SHP/README.md), [data/processed/NDVI](data/processed/NDVI/README.md), [data/raw/stgo-hot](data/raw/stgo-hot/README.md), [data/raw/dw-wood-grass](data/raw/dw-wood-grass/README.md) | [data/processed/indicadores](data/processed/indicadores/README.md) | [scripts/10_indicadores_combinados_rm.R](scripts/10_indicadores_combinados_rm.R) |
| Ranking compuesto de todas las plazas/parques con datos completos (RM) | [data/processed/indicadores](data/processed/indicadores/README.md) | [data/processed/indicadores](data/processed/indicadores/README.md) | [scripts/11_ranking_final_rm.R](scripts/11_ranking_final_rm.R) |
| Muestra aleatoria estratificada de 144 sitios para terreno (carbono), priorizando Metro | [data/processed/indicadores](data/processed/indicadores/README.md), [data/processed/metro](data/processed/metro/README.md) | [data/processed/indicadores](data/processed/indicadores/README.md) | [scripts/12_muestra_estratificada_carbono.R](scripts/12_muestra_estratificada_carbono.R) |

Los objetivos 05 y 06 dependen de Google Earth Engine (paquete `rgee`, cuenta y
autenticación propias) y no se pudieron ejecutar ni verificar en este entorno —
ver la nota de cada README y del encabezado de cada script. Los objetivos 07 a
12 sí se ejecutaron y verificaron.

## Requisitos

R (≥ 4.x) con los paquetes:

```r
# usados y verificados por los scripts 01-04, 07, 08
install.packages(c("sf", "dplyr", "stringi", "terra"))

# usados por 05_dynamic_world_backup.R y 06_ndvi_mapa.R (no verificados aquí)
install.packages(c("rgee", "tidyverse", "stars", "ggplot2", "tidyterra"))
```

`rgee` además requiere configuración de Google Earth Engine y Google Drive
(`rgee::ee_Install()` y `rgee::ee_Initialize()`), independiente de R.

## Cómo correr un script

Desde la raíz del proyecto (o abriendo `ranking-ugs.Rproj` en RStudio):

```bash
Rscript scripts/01_areas_verdes_shp.R
Rscript scripts/02_areas_verdes_rm.R
Rscript scripts/03_stgo_hot_quartiles.R
Rscript scripts/04_ocuc_vs_minvu_comparacion.R
Rscript scripts/05_dynamic_world_backup.R   # requiere cuenta GEE propia
Rscript scripts/07_ndvi_repair.R            # correr antes que 06
Rscript scripts/06_ndvi_mapa.R
Rscript scripts/08_dw_wood_grass_gpkg.R
Rscript scripts/09_metro_buffer_5min.R
Rscript scripts/10_indicadores_combinados_rm.R   # requiere 02 y 07 corridos antes
Rscript scripts/11_ranking_final_rm.R            # requiere 09 y 10 corridos antes
Rscript scripts/12_muestra_estratificada_carbono.R  # requiere 11 corrido antes
```

Las salidas quedan en `data/processed/<fuente>/`: GeoPackage (`.gpkg`) para capas
vectoriales o ráster, GeoTIFF (`.tif`) para rasters sueltos, `.csv` para tablas
sin geometría. Las imágenes de mapas quedan en `plots/`.

## Mapa interactivo

[`mapa_ugs.qmd`](mapa_ugs.qmd) genera un HTML autocontenido (Leaflet, vía
`leafem::addGeotiff` para los rasters) con un tab por capa temática —
comparación de fuentes, grass/wood, temperatura Q1-Q4, buffer de 5 min de
Metro, NDVI — cada uno con las áreas verdes (MINVU) como capa base, más
tabs de descriptivos por PLAZA/PARQUE, el ranking + mapa de la muestra
estratificada, y una tabla completa (ordenable/buscable) de los 144 sitios
de la muestra. Requiere correr antes los scripts 01, 02, 04, 07, 08, 09, 10,
11 y 12 (para que existan los `.gpkg`/`.tif`/`.csv` de `data/processed/`),
más los paquetes `leaflet`, `leafem`, `htmlwidgets`, `tidyr` y `DT`:

```r
install.packages(c("leaflet", "leafem", "htmlwidgets", "tidyr", "DT", "base64enc"))
```

```bash
quarto render mapa_ugs.qmd
```

El resultado (`mapa_ugs.html`, ~28MB, no versionado) queda listo para abrir
directamente en un navegador — no necesita servidor. Los rasters se
reducen de resolución solo para este mapa (no afecta `data/processed/`),
para que el HTML no pese cientos de MB. Si los caracteres acentuados salen
cortados (p. ej. "Áreas" → "reas"), correr `export LANG=en_US.UTF-8` antes de
`quarto render` — el proceso de R necesita un locale UTF-8.

### Publicado en GitHub Pages

**https://saryace.github.io/ranking-ugs/**

Así cualquiera puede abrir el mapa desde un link, sin clonar el repositorio
(que pesa ~283MB en Git LFS por los datos crudos — cada clone consume esa
cuota). Publicado desde `docs/index.html`, que **sí** está versionado (a
diferencia de `mapa_ugs.html` en la raíz). Después de cambiar
`mapa_ugs.qmd` y volver a renderizar, hay que copiar el resultado y subirlo:

```bash
quarto render mapa_ugs.qmd
cp mapa_ugs.html docs/index.html
git add docs/index.html
git commit -m "Actualiza mapa publicado"
git push
```

GitHub Pages se sirve desde la rama `main`, carpeta `/docs` (configurado en
Settings → Pages del repositorio).
