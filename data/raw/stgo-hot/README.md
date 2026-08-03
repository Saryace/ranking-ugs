# data/raw/stgo-hot — Superficies de temperatura, Santiago

Modelos de superficie de temperatura (rasters) de Santiago a 10 m de resolución
horizontal. Ver también [`ReadMe_FileNotation.txt`](ReadMe_FileNotation.txt) (nota
original de convención de nombres de archivo).

## Archivos presentes

| Archivo | Período | Variable | Unidad |
|---|---|---|---|
| `santiago-chile_am_temp_c.tif` | Mañana (7–8 AM) | Temperatura | °C |
| `santiago-chile_af_temp_c.tif` | Tarde (4–5 PM) | Temperatura | °C |
| `santiago-chile_pm_temp_c.tif` | Noche (7–8 PM) | Temperatura | °C |

El nombre real de los 3 archivos es `santiago-chile_{periodo}_temp_c.tif`. La nota
de convención de nombres describe un patrón más general
(`{periodo}_{variable}_{unidad}.tif`, con `t`=temperatura, `f`/`c`=Fahrenheit/Celsius,
y un ejemplo `pm_hi_f.tif` para un índice de calor/"heat index" en Fahrenheit) que
cubriría variables o unidades adicionales (p. ej. `hi` = heat index, o versiones en
Fahrenheit) — **ninguno de esos otros archivos está presente en este repositorio
actualmente**; si se agregan más adelante deberían seguir ese mismo patrón de
nombre.

## Características técnicas (verificadas de los archivos)

- **Resolución:** 10 × 10 m
- **CRS:** `EPSG:32719` — WGS 84 / UTM zone 19S (proyectado, no geográfico)
- **Extensión:** xmin 320370, xmax 368310, ymin 6271690, ymax 6321850 (idéntica en
  los 3 rasters — 5.016 filas × 4.794 columnas)
- **1 banda** por archivo, nombre de banda `temp_c`

| Archivo | Rango de temperatura observado |
|---|---|
| `santiago-chile_am_temp_c.tif` | 13,7 °C – 22,7 °C |
| `santiago-chile_af_temp_c.tif` | 28,8 °C – 34,1 °C |
| `santiago-chile_pm_temp_c.tif` | 26,5 °C – 31,7 °C |

## Procesamiento

[`scripts/03_stgo_hot_quartiles.R`](../../../scripts/03_stgo_hot_quartiles.R)
categoriza cada píxel de cada raster en cuartiles (Q1–Q4) de temperatura, calculados
de forma independiente por período del día (los rangos de valor son muy distintos
entre mañana/tarde/noche). Salida y diccionario en
[`data/processed/stgo-hot/README.md`](../../processed/stgo-hot/README.md).
