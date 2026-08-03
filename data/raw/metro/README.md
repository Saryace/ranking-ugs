# data/raw/metro — Estaciones de Metro de Santiago (actuales y proyectadas)

**Fuente:** IDE OCUC (Observatorio de Ciudades UC), Centro de Datos — dataset
["Estaciones actuales y proyectadas del Metro de Santiago"](https://ideocuc-ocuc.hub.arcgis.com/datasets/cc2e1d8419e64c7cb9502c58c00ba33b_0/about).
Datos originales de **Metro de Santiago** (2017), con proyección de estaciones
futuras hacia 2026. Publicado por OCUC, actualizado el 22 de marzo de 2024.
Licencia **CC BY-NC 4.0**, acceso público.

Descargado directamente vía la API REST del servicio ArcGIS (sin necesidad de
exportación manual desde el Hub):

```
https://services9.arcgis.com/kKJR3Qt68ohAWuet/arcgis/rest/services/Estaciones_actuales_y_proyectadas_de_Metro_de_Santiago/FeatureServer/0/query?where=1=1&outFields=*&outSR=4326&f=geojson
```

## Archivo

`estaciones_metro_santiago.geojson` — **117 puntos**, CRS `EPSG:4326` (se pidió
`outSR=4326` en la consulta; el servicio original está en Web Mercator,
`EPSG:102100`/`3857`).

Las 117 coordenadas y los 117 nombres (`nombre`) son todos distintos — no hay
puntos duplicados por estación de intercambio entre líneas.

## Diccionario de campos

| Campo | Significado | Valores observados |
|---|---|---|
| `nombre` | Nombre de la estación | 117 valores únicos |
| `linea` | Línea de Metro | `Linea 1` (27), `Linea 2` (20), `Linea 3` (13), `Linea 4` (20), `Linea 4A` (4), `Linea 5` (27), `Linea 6` (6) |
| `estacion` | Estado de la estación | `EXISTENTE` (96), `PROYECTADO` (19), `CONSTRUCCION` (1), `EXSTENTE` (1, **typo de "EXISTENTE"**) |
| `especial` | Estado + característica especial | `EXISTENTE` (88), `PROYECTADO` (19), `CONSTRUCCION INTERMODAL` (6), `EXISTENTE INTERMODAL` (3), `EXSTENTE` (1, typo) |
| `temporal` | Marca de estación intermodal | `""` vacío (107), `INTERMODAL` (10) — parece redundante con la parte "INTERMODAL" de `especial` |
| `tipo` | Tipo de infraestructura | `ESTACION METRO` (117, sin variación) |
| `id` / `objectid` / `FID` / `f1` | Identificadores internos del servicio ArcGIS | — |

**Problema de datos:** el valor `"EXSTENTE"` (1 registro, en `estacion` y en
`especial`) es un typo de `"EXISTENTE"` — normalizar antes de filtrar por
estado.

## Uso previsto

Base para el buffer de "5 minutos caminando" alrededor de cada estación (ver
[`scripts/09_metro_buffer_5min.R`](../../../scripts/09_metro_buffer_5min.R) y
[`data/processed/metro/README.md`](../../processed/metro/README.md)), como
insumo para priorizar áreas verdes cercanas al Metro en el ranking final (ver
README raíz del repositorio).
