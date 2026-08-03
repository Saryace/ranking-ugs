# data/processed/indicadores

Generado por [`scripts/10_indicadores_combinados_rm.R`](../../../scripts/10_indicadores_combinados_rm.R),
el primer paso de integración hacia el "Objetivo final" del ranking (ver
README raíz): junta, **a nivel de plaza/parque individual** en la Región
Metropolitana, calidad (+ su cuartil), NDVI, temperatura de tarde, cobertura
woody/grass y área. No incluye todavía el criterio de cercanía a Metro (eso
es un cruce espacial aparte, ver [`data/processed/metro/README.md`](../metro/README.md)).
Esta carpeta no se versiona (ver `.gitignore`), salvo este `README.md`.

## `areas_verdes_rm_indicadores.gpkg`

Mismos 10.243 polígonos y campos de
[`areas_verdes_rm.gpkg`](../SHP/README.md), más:

| Variable | Descripción |
|---|---|
| `calidad_q` | Cuartil de `CALIDAD` — `"Q1"` (más baja) a `"Q4"` (más alta), calculado sobre los polígonos con encuesta (`CALIDAD` no `NA`). Cortes: Q1 ≤ 60,9 · Q2 ≤ 71,0 · Q3 ≤ 78,5 · Q4 ≤ 97,3. `NA` si el polígono no fue encuestado. |
| `ndvi_medio` | NDVI promedio dentro del polígono (raster reparado, enero 2024) |
| `temp_af_medio_c` | Temperatura de tarde (AF, 4-5pm) promedio dentro del polígono, en °C (raster continuo, no el categorizado en cuartiles) |
| `temp_af_q` | Cuartil de `temp_af_medio_c` — `"Q1"` (más frío) a `"Q4"` (más caliente), calculado sobre todos los polígonos con valor de temperatura. Cortes: Q1 ≤ 31,12°C · Q2 ≤ 31,50°C · Q3 ≤ 31,99°C · Q4 ≤ 33,70°C. |
| `woody_medio` | Probabilidad `woody` (Dynamic World) promedio dentro del polígono |
| `grass_medio` | Probabilidad `grass` (Dynamic World) promedio dentro del polígono |

**Método:** promedio de los píxeles del raster dentro de cada polígono
(`terra::extract(..., fun = mean)`). Los polígonos más chicos que un píxel
(común en plazas pequeñas) no capturan ningún píxel por este método y quedan
`NA` — para esos casos se usa como respaldo el valor del raster en el
**centroide** del polígono. Esto afectó a 818 de 10.243 polígonos en el
raster de temperatura (10m); menos en NDVI/woody/grass (30m).

## `resumen_tipo_ep.csv` — descriptivos por PLAZA/PARQUE

| TIPO_EP | n | área media (m²) | calidad media | NDVI medio | temp. AF media (°C) | woody medio | grass medio |
|---|---|---|---|---|---|---|---|
| PARQUE | 866 | 22.761 | 62,1 | 0,336 | 31,6 | 0,092 | 0,033 |
| PLAZA | 9.377 | 1.881 | 69,0 | 0,285 | 31,5 | 0,072 | 0,029 |

Los parques son ~12x más grandes en promedio que las plazas y tienen algo más
de vegetación (NDVI y woody más altos), pero **puntaje de calidad más bajo**
en promedio (62,1 vs. 69,0) — ver el cruce con cuartil de calidad abajo para
más detalle. La temperatura de tarde promedio es casi idéntica entre ambos
tipos (31,5-31,6°C).

## `conteo_calidad_quartil.csv` — cruce PLAZA/PARQUE x cuartil de calidad

| TIPO_EP | Q1 | Q2 | Q3 | Q4 | Sin encuesta (`NA`) |
|---|---|---|---|---|---|
| PARQUE | 278 | 160 | 116 | 56 | 256 |
| PLAZA | 1.679 | 1.773 | 1.829 | 1.888 | 2.208 |

Los parques están fuertemente concentrados en el cuartil más bajo de calidad
(278 en Q1 vs. solo 56 en Q4), mientras que las plazas se reparten de forma
mucho más pareja entre los 4 cuartiles — esto explica el promedio de calidad
más bajo de los parques pese a tener más vegetación.

## `ranking_final_rm.gpkg`

Generado por [`scripts/11_ranking_final_rm.R`](../../../scripts/11_ranking_final_rm.R).
**7.307** de los 10.243 polígonos (los que tienen los 5 indicadores completos
— calidad, NDVI, temp. AF, woody, grass; se excluyen los 2.936 sin encuesta
de calidad o fuera de la cobertura de algún raster), con dos columnas nuevas:

| Variable | Descripción |
|---|---|
| `veg_total_medio` | `woody_medio + grass_medio` |
| `cerca_metro_5min` | `TRUE` si el polígono intersecta el buffer de 5 min de Metro ([`data/processed/metro`](../metro/README.md)) — informativo, **no** entra en `ranking_score` |
| `ranking_score` | Puntaje compuesto 0-1: promedio simple (igual ponderación) de `CALIDAD`, `temp_af_medio_c` (invertida — más frío = mejor), `ndvi_medio`, `veg_total_medio` y `area_m2`, cada uno normalizado min-max a [0,1]. Metodología simple y transparente, no validada por literatura — ver el encabezado del script para ajustar pesos. |
| `ranking_pos` | Posición en el ranking (1 = mejor puntaje) |

El top 5 nacional está dominado por fragmentos del Parque Metropolitano de
Santiago (aparece varias veces porque MINVU lo digitalizó como polígonos
separados por comuna — Vitacura, Providencia, Recoleta, Huechuraba).

## `muestra_carbono_rm.gpkg` — muestra estratificada para terreno

Generado por [`scripts/12_muestra_estratificada_carbono.R`](../../../scripts/12_muestra_estratificada_carbono.R).
**144 plazas/parques** (subido de 112 a 144, dentro del rango 120-150
pedido, para dejar sitios de respaldo por si hay problemas de acceso/muestreo
en terreno) para una campaña de terreno que asocie **calidad**, **temperatura
(AF)** y **tipo (plaza vs. parque)** con **carbono en el suelo** — diseño
inspirado en Vasenev et al. (2014, *Geoderma* 226-227:103-115), que usa
muestreo aleatorizado estratificado por factores de suelo/uso urbano y
excluye explícitamente suelos sellados del muestreo (no se puede tomar una
muestra de suelo donde no hay superficie abierta).

**Diseño — "grupos extremos" (Q1 vs. Q4), no los 4 cuartiles:**

1. **Marco muestral:** solo polígonos con encuesta de calidad, con algo de
   superficie abierta/vegetada (`woody_medio + grass_medio > 0,05` — condición
   mínima para poder tomar una muestra de suelo en terreno), **y** en el
   cuartil más bajo o más alto de calidad y de temperatura (1.774 candidatos).
2. **Estratos:** `TIPO_EP` (PLAZA/PARQUE) × `calidad_q` (solo Q1 y Q4) ×
   `temp_af_q` (solo Q1 y Q4) = 8 celdas. Se toman deliberadamente los
   **extremos** de calidad y temperatura, no los 4 cuartiles, para maximizar
   el contraste/rango de ambas variables y así el poder para detectar
   asociaciones con carbono en una muestra de tamaño moderado — es un diseño
   de "diferencias marcadas", no uno representativo de la distribución
   completa de la RM.
3. **Asignación:** objetivo igual por celda (`N_OBJETIVO / 8` ≈ 18), pero
   capada por la disponibilidad real. **Los parques de alta calidad (Q4)
   casi no coinciden con temperaturas altas (Q4): solo 5 polígonos en toda
   la RM** (y apenas 8 para Q4-calidad × Q1-temp) — un hallazgo en sí mismo
   (los parques mejor mantenidos tienden a ser más frescos). Esas celdas se
   muestrean completas (censo) y el faltante para llegar a `N_OBJETIVO` se
   redistribuye entre las celdas con más disponibilidad
   (`asignar_con_redistribucion()` en el script).
4. **Prioridad a Metro:** dentro de cada celda, hasta 70% de la cuota
   (`PROP_PRIORIDAD_METRO`) se llena primero con candidatos a 5 min de
   Metro; el resto se completa al azar con el resto de la celda.
5. **Reproducibilidad:** `set.seed(2024)` — volver a correr el script da
   exactamente la misma muestra.

**Resultado logrado** (ver `muestra_asignacion.csv`): 144 sitios (32 más que
el diseño anterior de 112, todos de respaldo repartidos en las celdas con
más disponibilidad — las dos celdas de parques ya iban al tope y no
crecieron).

| TIPO_EP | Calidad | Temp. AF | Disponibles | Objetivo | Logrado | % cerca Metro |
|---|---|---|---|---|---|---|
| PARQUE | Q1 (baja) | Q1 (fría) | 36 | 22 | 22 | 0,0% |
| PARQUE | Q1 (baja) | Q4 (cálida) | 114 | 22 | 22 | 54,5% |
| PARQUE | Q4 (alta) | Q1 (fría) | 8 | 8 | 8 | 12,5% |
| PARQUE | Q4 (alta) | Q4 (cálida) | 5 | 5 | 5 | 20,0% |
| PLAZA | Q1 (baja) | Q1 (fría) | 250 | 22 | 22 | 22,7% |
| PLAZA | Q1 (baja) | Q4 (cálida) | 575 | 22 | 22 | 72,7% |
| PLAZA | Q4 (alta) | Q1 (fría) | 457 | 22 | 22 | 40,9% |
| PLAZA | Q4 (alta) | Q4 (cálida) | 329 | 21 | 21 | 71,4% |

**59 de 144 (41,0%) quedaron a 5 min de Metro** — algo más bajo que con 112
sitios (46,4%), porque los 32 sitios extra se sacaron de celdas donde el
subconjunto cerca de Metro ya estaba parcialmente agotado (p. ej. PARQUE
Q1-calidad×Q4-temp bajó de 70,6% a 54,5% al pasar de 17 a 22 sitios en esa
celda). Al exigir *también* el extremo de temperatura, las celdas de PARQUE
quedan tan chicas (5-114 candidatos) que a veces casi no hay superposición
con cercanía a Metro — la celda PARQUE Q1-calidad×Q1-temp (parques fríos y de
baja calidad, probablemente periféricos) tiene **0** candidatos cerca de
Metro entre sus 36 disponibles, con o sin respaldo. Esto es una limitación
real del diseño de grupos extremos combinado con la prioridad a Metro, no un
error: hay un trade-off entre maximizar el contraste de calidad/temperatura,
el tamaño de muestra, y la cobertura de Metro.

**Para cambiar el diseño:** ajustar `N_OBJETIVO` (120-150), `PROP_PRIORIDAD_METRO`
(0-1) o `SEMILLA` al inicio del script y volver a correrlo. Para volver al
diseño de 4 cuartiles (más representativo, menos contraste), cambiar el
filtro del marco muestral para no restringir a `c("Q1","Q4")`.
