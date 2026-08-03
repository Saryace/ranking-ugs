# data/raw/NDVI — NDVI Santiago, enero 2024 (30m)

**Fuente:** Google Earth Engine, colección Landsat `LANDSAT/LC08/C02/T1_L2`
(Landsat 8/9, Collection 2 Level 2), enero de 2024. Descargado directamente desde
GEE (Code Editor / script externo) — **el paso de descarga/cálculo del NDVI no
está incluido en este repositorio**, solo el raster ya calculado y su
visualización ([`scripts/06_ndvi_mapa.R`](../../../scripts/06_ndvi_mapa.R)).

## Archivo

| Archivo | Contenido | Rango de valores | Media (sin `NA`) |
|---|---|---|---|
| `NDVI_Santiago_Jan2024_30m.tif` | Índice de vegetación NDVI | -0,971 – 0,966 | 0,296 |

- **Resolución:** 30 × 30 m
- **1 banda**, nombre `NDVI`
- **52.527 de 1.658.215 píxeles en `NA`** (3,2%) — típicamente nubes/sombras de
  nube enmascaradas en el compuesto Landsat, o zonas fuera de la escena.

## ⚠️ CRS con etiqueta incorrecta

El archivo trae **`EPSG:32619` (WGS 84 / UTM zone 19**N**)** en sus metadatos,
pero Santiago está en el hemisferio sur — debería ser **zona 19S**
(`EPSG:32719`, la misma que usan los rasters de
[`data/raw/stgo-hot`](../stgo-hot/README.md)).

Se verificó que esto es un problema de **etiqueta/convención, no de la
geometría en sí**: el `northing` del archivo es negativo (`ymin` -3.724.905,
`ymax` -3.685.455), consistente con que Earth Engine exportó las coordenadas
UTM-sur *sin* aplicar el falso norte de 10.000.000 m que usa la convención
EPSG estándar para el hemisferio sur. Sumando ese offset:

```
ymin: -3.724.905 + 10.000.000 = 6.275.095
ymax: -3.685.455 + 10.000.000 = 6.314.545
```

...que cae exactamente en el rango de extensión de `data/raw/stgo-hot`
(6.271.690 a 6.321.850) — confirma que es la misma zona geográfica real
(Santiago, UTM 19S), solo con la coordenada Y desplazada en 10.000.000 m y el
CRS mal etiquetado como zona norte.

**Implicancia práctica:** el mapa que genera `06_ndvi_mapa.R` se ve bien porque
solo grafica esta capa sola (la forma y las posiciones relativas de los
píxeles son correctas). Pero **no se puede superponer directamente** con
`data/raw/stgo-hot` ni con las capas de `data/raw/SHP` (SIRGAS 2000) sin antes
corregir el CRS: hay que reasignar `EPSG:32719` **y** sumar 10.000.000 a la
coordenada Y (no basta con solo reasignar el CRS, hay que corregir también el
valor de la coordenada).

**Ya reparado:** [`scripts/07_ndvi_repair.R`](../../../scripts/07_ndvi_repair.R)
aplica exactamente esa corrección y escribe el resultado en
[`data/processed/NDVI/`](../../processed/NDVI/README.md), verificado contra
polígonos reales de parques de la Región Metropolitana. Usar ese archivo
reparado (no este crudo) para cualquier análisis que cruce NDVI con otras
capas.
