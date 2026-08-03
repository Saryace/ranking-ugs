# data/processed/dw-wood-grass

Generado por [`scripts/08_dw_wood_grass_gpkg.R`](../../../scripts/08_dw_wood_grass_gpkg.R)
a partir de [`data/raw/dw-wood-grass/`](../../raw/dw-wood-grass/README.md). Esta
carpeta no se versiona (ver `.gitignore`), salvo este `README.md`.

## `dw_wood_grass.gpkg`

Los dos GeoTIFF crudos (`dw_woody_stgo_30m.tif`, `dw_grass_stgo_30m.tif`)
empaquetados como **capas ráster dentro de un mismo GeoPackage**, mismo formato
contenedor que ya se usa para las capas vectoriales del resto del repositorio
(p. ej. [`comparacion_poligonos.gpkg`](../OCUC-MINVU/README.md)). Mismos
valores, resolución (30 m) y CRS (EPSG:4326) que los archivos crudos — no se
modificó ni reproyectó nada, solo el contenedor de archivo.

| Capa (`RASTER_TABLE`) | Contenido |
|---|---|
| `woody` | Probabilidad `trees` + `shrub_and_scrub` |
| `grass` | Probabilidad `grass` |

### Cómo leer cada capa

GeoPackage almacena rásters como "subdatasets"; hay que indicar la capa en la
ruta:

```r
library(terra)
woody <- rast("GPKG:data/processed/dw-wood-grass/dw_wood_grass.gpkg:woody")
grass <- rast("GPKG:data/processed/dw-wood-grass/dw_wood_grass.gpkg:grass")
```

```python
import rasterio
woody = rasterio.open("GPKG:data/processed/dw-wood-grass/dw_wood_grass.gpkg:woody")
```

En QGIS: `Capa → Añadir capa → Añadir capa ráster`, elegir el `.gpkg` y
seleccionar la subcapa (`woody` o `grass`) en el diálogo de subconjuntos.

Nota menor: el nombre de banda queda como `"Height"` (default del driver GPKG
al convertir vía `gdal_translate`) en vez de `"woody"`/`"grass"` — el
identificador real de cada capa es el nombre de tabla (`RASTER_TABLE`), no el
nombre de banda.
