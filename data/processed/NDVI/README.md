# data/processed/NDVI

Generado por [`scripts/07_ndvi_repair.R`](../../../scripts/07_ndvi_repair.R) a
partir de [`data/raw/NDVI/`](../../raw/NDVI/README.md). Esta carpeta no se
versiona (ver `.gitignore`), salvo este `README.md`.

## `NDVI_Santiago_Jan2024_30m_repaired.tif`

Copia del raster crudo con la georreferenciación **reparada**: mismos valores
de píxel, mismo tamaño y resolución (30 × 30 m), pero con el CRS correcto y la
extensión desplazada al sistema de coordenadas real.

| | Crudo (`data/raw/NDVI`) | Reparado |
|---|---|---|
| CRS | `EPSG:32619` (UTM 19**N**, incorrecto) | `EPSG:32719` (UTM 19**S**, correcto) |
| Extensión Y | -3.724.905 a -3.685.455 | 6.275.095 a 6.314.545 |
| Extensión X | 327.735 a 365.565 (sin cambios) | 327.735 a 365.565 |

La reparación consiste en sumar el falso norte de 10.000.000 m a la
coordenada Y y reasignar el CRS a `EPSG:32719` — ver el detalle del
diagnóstico en [`data/raw/NDVI/README.md`](../../raw/NDVI/README.md).

**Verificación:** se extrajo el NDVI medio dentro de polígonos reales de
parques de `data/raw/SHP` (Región Metropolitana). Los parques de Santiago caen
dentro de la extensión reparada y devuelven valores plausibles de vegetación
sana (Parque O'Higgins: 0,40; Quinta Normal: 0,41; Parque Metropolitano:
0,28–0,44 según sector); parques homónimos de otras regiones (Rancagua,
Temuco, Talca, Concepción — que no debieran estar cubiertos por este raster de
Santiago) devuelven correctamente `NA` por quedar fuera de la extensión. Esto
confirma que la reparación alinea el raster con su ubicación geográfica real.

Con el CRS reparado, este archivo ya se puede combinar en un SIG con
`data/raw/stgo-hot` (mismo EPSG:32719) y, tras reproyectar, con los polígonos
de `data/raw/SHP` (SIRGAS 2000) u `data/raw/OCUC-MINVU` (WGS84).
