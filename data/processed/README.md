# data/processed

Salidas generadas por los scripts en [`scripts/`](../../scripts), a partir de las
fuentes crudas en [`data/raw/`](../raw). Esta carpeta no se versiona (ver
`.gitignore`), salvo los `README.md` — se regenera corriendo los scripts.

Cada subcarpeta corresponde a una fuente/objetivo y documenta sus propias salidas:

| Subcarpeta | Contenido | Script |
|---|---|---|
| [`SHP/`](SHP/README.md) | Indicadores de calidad y polígonos de plazas/parques (Chile completo y Región Metropolitana) | [scripts/01_areas_verdes_shp.R](../../scripts/01_areas_verdes_shp.R), [scripts/02_areas_verdes_rm.R](../../scripts/02_areas_verdes_rm.R) |
| [`stgo-hot/`](stgo-hot/README.md) | Rasters de temperatura categorizados por cuartil (Q1–Q4) por píxel | [scripts/03_stgo_hot_quartiles.R](../../scripts/03_stgo_hot_quartiles.R) |
| [`OCUC-MINVU/`](OCUC-MINVU/README.md) | Comparación de áreas verdes públicas: OCUC vs. MINVU Calidad, por comuna | [scripts/04_ocuc_vs_minvu_comparacion.R](../../scripts/04_ocuc_vs_minvu_comparacion.R) |
