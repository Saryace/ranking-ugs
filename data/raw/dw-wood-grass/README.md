# data/raw/dw-wood-grass — Dynamic World, cobertura woody/grass (30m)

**Fuente:** [Google Dynamic World V1](https://developers.google.com/earth-engine/datasets/catalog/GOOGLE_DYNAMICWORLD_V1)
(`GOOGLE/DYNAMICWORLD/V1`), vía Google Earth Engine. Descargado con
[`scripts/05_dynamic_world_backup.R`](../../../scripts/05_dynamic_world_backup.R).

Mediana de probabilidad de dos clases de cobertura de Dynamic World, sobre el
bounding box de Santiago `[-70.85, -33.65, -70.45, -33.30]`, para las imágenes
disponibles en la ventana **15–25 de enero de 2024** (±5 días de la fecha objetivo
2024-01-20).

## Archivos

| Archivo | Contenido | Rango de valores | Media |
|---|---|---|---|
| `dw_woody_stgo_30m.tif` | Probabilidad `trees` + `shrub_and_scrub` (suma de ambas bandas Dynamic World) | 0,032 – 0,834 | 0,225 |
| `dw_grass_stgo_30m.tif` | Probabilidad `grass` | 0,012 – 0,705 | 0,050 |

Son probabilidades (no clasificaciones binarias), por lo que no están acotadas a
`[0, 1]` de forma triv­ial en el caso de `woody` (es la suma de dos probabilidades
de clase, puede acercarse a 1 pero no superarlo en la práctica salvo error
numérico).

## Características técnicas

- **Resolución:** ~30 m (en grados: 0,0002694946° — equivalente a 30 m
  norte-sur en la latitud de Santiago; GEE no reproyecta a un CRS métrico salvo
  que se pida explícitamente)
- **CRS:** `EPSG:4326` (WGS 84 geográfico, lon/lat) — **distinto** del CRS
  proyectado (EPSG:32719) usado en `data/raw/stgo-hot/`; hay que reproyectar antes
  de combinar ambas fuentes.
- **Extensión:** xmin -70,850, xmax -70,450, ymin -33,650, ymax -33,300 (1.300 ×
  1.485 píxeles), sin celdas `NA` (cobertura completa del bounding box)
- **1 banda** por archivo

## Alcance y uso previsto

Estos rasters son **a nivel de ciudad completa**, pensados para visualización
agregada (p. ej. mapas de hexágonos), no para análisis por plaza/parque
individual. Un análisis a esa escala requeriría rasters Dynamic World a 10m
interceptados con los polígonos de [`data/raw/SHP`](../SHP/README.md); ese cruce
es un paso posterior, **no incluido en este repositorio todavía**.

## Nota sobre reproducibilidad

[`scripts/05_dynamic_world_backup.R`](../../../scripts/05_dynamic_world_backup.R)
es un script de "respaldo": documenta y permite regenerar estos archivos si
cambia la fecha objetivo o el área de interés. Requiere una cuenta de Google
Earth Engine ya autenticada con `rgee` y acceso a Google Drive (la descarga usa
`via = "drive"`). No se ejecutó ni se verificó en este repositorio — el paquete
`rgee` no está instalado en este entorno y requeriría credenciales propias del
usuario.
