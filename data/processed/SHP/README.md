# data/processed/SHP

Salidas generadas a partir de [`data/raw/SHP/`](../../raw/SHP/README.md) (ver ese
README para la fuente, el CRS y el diccionario completo de campos crudos). Esta
carpeta no se versiona (ver `.gitignore`), salvo este `README.md` — se regenera
corriendo los scripts.

## `areas_verdes_poligonos.gpkg` y `areas_verdes_centros_urbanos.gpkg` y `areas_verdes_indicadores.csv`

Generados por [`scripts/01_areas_verdes_shp.R`](../../../scripts/01_areas_verdes_shp.R),
a partir de los 559 centros urbanos del Censo 2017 (Chile completo).

- **`areas_verdes_poligonos.gpkg`** (29.278 features): unión de `PZPQ_2018_G3G4.shp`
  y `CALIDAD_pzpq_2019_G1G2.shp` en una sola capa nacional de polígonos individuales
  de plazas/parques, con los campos cartográficos originales más:
  - `en_88_centros_urbanos`: `TRUE` si el polígono pertenece a uno de los 88 centros
    urbanos donde se aplicó la encuesta de calidad (puede o no tener la encuesta
    respondida).
  - `tiene_encuesta_calidad`: `TRUE` solo si el polígono fue efectivamente
    encuestado (`CALIDAD` no nula tras recodificar el sentinel `-1` → `NA`).
- **`areas_verdes_centros_urbanos.gpkg`** (559 features): copia directa de
  `CALIDAD_LUC_PzPq.shp`, indicadores agregados por centro urbano.
- **`areas_verdes_indicadores.csv`** (17.438 filas, sin geometría): solo los
  polígonos efectivamente encuestados, con `CUT`, `REGION`, `COMUNA`, `COD_URBANO`,
  `URBANO_CEN`, `TIPO_EP`, `NOMBRE_EP` y los 5 componentes de calidad (`MG`, `VG`,
  `AU`, `SG`, `DE`, `CALIDAD`, `RANGO_CALI`).

## `areas_verdes_rm.gpkg`

Generado por [`scripts/02_areas_verdes_rm.R`](../../../scripts/02_areas_verdes_rm.R).

Un solo objeto espacial (10.243 features) con las plazas y parques de la **Región
Metropolitana de Santiago**, filtrado desde `CALIDAD_pzpq_2019_G1G2.shp`, con sus
indicadores de vegetación y calidad.

| Variable | Descripción |
|---|---|
| `id` | Identificador legible generado en este script: `TIPO_EP` + `NOMBRE_EP` en minúsculas, sin tildes y separado por `_` (p. ej. `plaza_las_tres_americas`). Usa `"sin_nombre"` cuando `NOMBRE_EP` es `NA`. **No es único**: hay 6.112 valores repetidos sobre 10.243 registros, porque existen plazas/parques con el mismo nombre en distintas comunas o dentro de la misma comuna. |
| `ID_MINVU_Calidad` | Renombrado desde `ID_TEXT` del shapefile fuente. Identificador de texto del polígono asignado en el catastro; tampoco es único (1.959 valores repetidos en la RM). |
| `TIPO_EP` | Tipo de espacio público: `PLAZA` o `PARQUE`. |
| `area_m2` | Renombrado desde `SUP_TOTAL_`. Superficie total del polígono, en m². |
| `Estratos_v` | Estratos de vegetación presentes en el espacio, como lista separada por comas de una o más categorías: `Estrato_bajo_20cm_aprox`, `Estrato_medio_arbusto_arboles_20cm_a_1_5`, `Estrato_medio_alto_Arbusto_alto_arbol_bajo_1_5m_a_5m`, `Estrato_alto_arbol_mas_5m`; o `Ninguno_anteriores` si no hay vegetación; o `SIN INFORMACIÓN` si el polígono no fue encuestado. |
| `Estado_veg` | Estado/condición general de la vegetación: `Bueno`, `Regular`, `Malo`, `No_aplica` (sin vegetación), o `SIN INFORMACIÓN` si no fue encuestado. |
| `VG` | Puntaje del componente de calidad "Vegetación" (0–100). `NA` si el polígono no fue encuestado (recodificado desde el sentinel `-1` del shapefile fuente). |
| `CALIDAD` | Puntaje de calidad final (0–100), promedio ponderado de los 5 componentes de calidad (ver [data/raw/SHP/README.md](../../raw/SHP/README.md)). `NA` si no fue encuestado. |
| `RANGO_CALI` | Rango de calidad del polígono: `RANGO INFERIOR`, `RANGO INTERMEDIO`, `RANGO SUPERIOR`, o `SIN INFORMACIÓN` si no fue encuestado. |
| `geom` | Geometría del polígono (SIRGAS 2000, EPSG:4674). |

De los 10.243 polígonos, 2.464 están `SIN INFORMACIÓN` (no fueron encuestados en
terreno): en esos casos `VG`, `CALIDAD` y `RANGO_CALI` quedan en `NA`/`SIN
INFORMACIÓN`, pero `id`, `ID_MINVU_Calidad`, `TIPO_EP` y `area_m2` sí están
disponibles porque provienen de la capa cartográfica, no de la encuesta.
