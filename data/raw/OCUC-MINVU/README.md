# data/raw/OCUC-MINVU — Tipología de áreas verdes RM 2017 (IDE OCUC)

**Fuente:** IDE OCUC (Observatorio de Ciudades UC), Centro de Datos — dataset
["Tipología de Áreas Verdes de la Región Metropolitana de Santiago 2017"](https://ideocuc-ocuc.hub.arcgis.com/datasets/572960ce04ae489b82346c22c6cd032a_0/about).
Datos originalmente proporcionados por el **Ministerio de Vivienda y Urbanismo
(MINVU)**, publicados por OCUC el 24 de agosto de 2019. Licencia **CC BY-NC 4.0**.

> Nota: el archivo se descargó con el nombre que le asigna el hub de ArcGIS
> (`xn--Tipologa_de_reas_verdes_2017,_rea_metropolitana_de_Santiago-khd74qdva..geojson`,
> una codificación punycode de "Tipología_de_Áreas_verdes_2017,_área_metropolitana_de_Santiago")
> y se dejó tal cual para trazabilidad del origen.

## Qué es

Cobertura de polígonos de áreas verdes de la Región Metropolitana de Santiago para
2017, clasificados por tipología, a nivel de comuna. **86.318 features**, polígono
simple, CRS `CRS84` (WGS84 lon/lat, EPSG:4326).

## Diccionario de campos

| Campo | Significado |
|---|---|
| `FID` | Identificador interno del feature |
| `TIPO` | Tipología del área verde (ver categorías abajo) |
| `COMUNA` | Nombre de la comuna (en mayúsculas, sin tildes) |
| `AREA_m2` | Superficie del polígono, en m² |
| `AREA_ha` | Superficie del polígono, en hectáreas |
| `Shape__Area` / `Shape__Length` | Área/perímetro calculados automáticamente por ArcGIS (en las unidades del CRS de almacenamiento en el servicio origen — no usar directamente, recalcular tras proyectar) |

### Categorías de `TIPO`

| Categoría | N° polígonos | Significado |
|---|---|---|
| `Privadas` | 45.049 | Áreas verdes de propiedad/uso privado |
| `Arborización` | 36.249 | Arborización urbana (no necesariamente parcelas de área verde discretas) |
| `Públicas` | 3.936 | Áreas verdes de uso público — la categoría comparable a plazas/parques de MINVU |
| `Potenciales` | 1.084 | Sitios identificados como potenciales futuras áreas verdes (no existentes aún) |

Para comparar contra el catastro de plazas y parques de MINVU (ver
[`data/raw/SHP/README.md`](../SHP/README.md)), la categoría relevante es
**`Públicas`** — ver [`scripts/04_ocuc_vs_minvu_comparacion.R`](../../../scripts/04_ocuc_vs_minvu_comparacion.R).

## Problema de datos detectado

El campo `COMUNA` usa el valor abreviado **`"PAC"`** para **Pedro Aguirre Cerda**
(397 polígonos), en vez del nombre completo usado en el resto de la capa y en los
datos de MINVU. El script de comparación corrige este caso manualmente.

Cobertura: la capa trae 42 comunas distintas en el campo `COMUNA`, pero solo 34
tienen al menos un polígono `Públicas` (el resto — comunas periféricas/rurales como
Melipilla, Talagante, Buin, Colina, Lampa, Padre Hurtado, Pirque, San José de Maipo —
no registra ninguna).
