# data/processed/stgo-hot

Salidas generadas por [`scripts/03_stgo_hot_quartiles.R`](../../../scripts/03_stgo_hot_quartiles.R)
a partir de [`data/raw/stgo-hot/`](../../raw/stgo-hot/README.md). Esta carpeta no se
versiona (ver `.gitignore`), salvo este `README.md` — se regenera corriendo el
script.

## `santiago-chile_{periodo}_temp_c_quartil.tif`

Un raster por período del día (`am`, `af`, `pm`), mismo tamaño/resolución/CRS que
el original (10 m, EPSG:32719), donde cada píxel queda categorizado en un cuartil
de temperatura **calculado de forma independiente para ese período** (no
comparable entre períodos: un `4` en `am` no representa la misma temperatura que
un `4` en `pm`).

| Valor | Significado |
|---|---|
| `1` | Cuartil más frío (25% de los píxeles con menor temperatura de ese período) |
| `2` | Segundo cuartil |
| `3` | Tercer cuartil |
| `4` | Cuartil más caliente (25% de los píxeles con mayor temperatura de ese período) |
| `NA` | Fuera del área cubierta por el raster original |

Los intervalos son `(corte_anterior, corte_actual]`, con el mínimo incluido en el
cuartil 1 (`include.lowest = TRUE`).

## `quartiles_cortes.csv`

Puntos de corte (en °C) usados para generar los rasters de arriba, por período:

| raster | min_c | q25_c | mediana_c | q75_c | max_c |
|---|---|---|---|---|---|
| santiago-chile_am_temp_c | 13,70 | 18,00 | 18,50 | 19,10 | 22,70 |
| santiago-chile_af_temp_c | 28,80 | 31,20 | 31,60 | 32,00 | 34,10 |
| santiago-chile_pm_temp_c | 26,50 | 28,50 | 29,00 | 29,70 | 31,70 |

`q25_c`/`mediana_c`/`q75_c` son los límites superiores de los cuartiles 1/2/3
respectivamente (el cuartil 4 va desde `q75_c` hasta `max_c`).
