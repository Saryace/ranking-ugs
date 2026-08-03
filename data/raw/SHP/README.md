# data/raw/SHP — Plazas y parques urbanos (calidad y cobertura)

**Fuente:** Instituto Nacional de Estadísticas de Chile (INE), Unidad de Geografía y
Actualización Cartográfica — StoryMap ["Indicadores de Calidad de Plazas y Parques
Urbanos"](https://storymaps.arcgis.com/stories/391dac6ee0c3438fbf186aed3ea1cff1) (2019).

**Objetivo de estos datos dentro del proyecto:** obtener los **indicadores de calidad**
y los **polígonos** de áreas verdes urbanas (plazas y parques) de Chile, a nivel de
espacio público individual y a nivel de centro urbano, como insumo para construir un
ranking de áreas verdes urbanas.

> Nota de confiabilidad: los `.shp.xml` que acompañan estos shapefiles (metadata ESRI)
> no traen definiciones de atributos (`attrdef` vacíos). El diccionario de campos de
> abajo combina lo que confirma el texto de la StoryMap (marcado **[confirmado]**) con
> inferencias a partir de las convenciones de nombres MINVU/INE, los valores observados
> y, cuando fue posible, una verificación numérica directa (marcado **[inferido]** /
> **[inferido, verificado]**). Para la definición oficial y exhaustiva de cada campo de
> la encuesta de terreno, la propia StoryMap enlaza una "ficha de base de datos del
> producto" y una "ficha metodológica del producto" — no se pudo acceder a esos enlaces
> de descarga durante la documentación de este repo (la StoryMap es una SPA de scroll
> infinito); si se obtienen, deberían reemplazar las inferencias marcadas abajo.

## Contexto del estudio (resumen de la StoryMap)

El INE construyó, en dos etapas:

1. **Capa cartográfica nacional** de plazas y parques para los 559 centros urbanos
   del Censo 2017 (corte a diciembre 2018) → `PZPQ_2018_G3G4.shp` + la parte
   cartográfica de `CALIDAD_pzpq_2019_G1G2.shp`.
2. **Encuesta de calidad en terreno** (feb–ago 2019) aplicada solo en 88 centros
   urbanos principales (capitales regionales, sus conurbaciones y centros con
   50.000+ habitantes) → campos de calidad en `CALIDAD_pzpq_2019_G1G2.shp`.

El indicador de **calidad** (`CALIDAD`, escala 0–100) es un promedio ponderado de 5
componentes, cada uno también en escala 0–100, definidos y consensuados por una mesa
de trabajo interinstitucional (MINVU, Corporación Ciudad Accesible, Fundación Mi
Parque, CNDU, CEDEUS, Compañía Verde, Centro de Políticas Públicas UC, Observatorio de
Ciudades UC, INE):

| Código | Componente                    | Promedio nacional parques | Promedio nacional plazas |
|--------|--------------------------------|---------------------------|---------------------------|
| `MG`   | Mantención General             | 90,92                     | 84,93                     |
| `VG`   | Vegetación                     | 83,71                     | 71,73                     |
| `DE`   | Diversidad de Equipamientos    | 61,08                     | 64,39                     |
| `SG`   | Seguridad                      | 54,56                     | 87,74                     |
| `AU`   | Accesibilidad Universal        | 48,89                     | 49,70                     |

Cada polígono con encuesta se clasifica además en un `RANGO_CALI` (rango de calidad:
inferior / intermedio / superior), calculado a partir del promedio y desviación
estándar de calidad de los 16.144 polígonos de plazas y 1.294 de parques evaluados.

Cobertura lograda por la encuesta: 82,6% de la superficie de plazas y 85,8% de la
superficie de parques de los 88 centros urbanos. El resto queda marcado como
**"SIN DATO"** / **"SIN INFORMACIÓN"** (sentinel `-1` en los campos numéricos, ver
más abajo).

## Sistema de referencia

Los tres shapefiles están en **SIRGAS 2000 geográfico (EPSG:4674)**, lat/long, sin
proyectar.

## Archivos

| Shapefile | Geometría | N° features | Nivel | Cobertura |
|---|---|---|---|---|
| [`PZPQ_2018_G3G4.shp`](PZPQ_2018_G3G4.shp) | Polygon | 7.188 | Plaza / parque individual | Solo cartografía (sin encuesta de calidad) — centros urbanos **fuera** de los 88 seleccionados |
| [`CALIDAD_pzpq_2019_G1G2.shp`](CALIDAD_pzpq_2019_G1G2.shp) | Polygon | 22.090 | Plaza / parque individual | Cartografía + encuesta de calidad — los 88 centros urbanos seleccionados (17.438 con encuesta + 4.652 "sin información") |
| [`CALIDAD_LUC_PzPq.shp`](CALIDAD_LUC_PzPq.shp) | MultiPolygon | 559 | Centro urbano (agregado) | Resumen/agregación de indicadores por los 559 centros urbanos del Censo 2017 |

El sufijo **G1G2 / G3G4** refiere a los grupos de centros urbanos definidos por el
INE según tamaño/jerarquía: G1/G2 = los 88 centros urbanos seleccionados para la
encuesta de calidad; G3/G4 = el resto de los 559 centros urbanos, que solo cuentan
con la capa cartográfica.

`CALIDAD_pzpq_2019_G1G2.shp` + `PZPQ_2018_G3G4.shp` = universo cartográfico completo
de plazas y parques de los 559 centros urbanos (22.090 + 7.188 = 29.278 polígonos).
`CALIDAD_LUC_PzPq.shp` es la agregación de ambos a nivel de centro urbano.

---

## Diccionario de campos

### Campos cartográficos comunes — `PZPQ_2018_G3G4.shp` y `CALIDAD_pzpq_2019_G1G2.shp`

| Campo | Significado | Confianza |
|---|---|---|
| `CUT` | Código Único Territorial de la comuna | inferido (convención estándar Chile) |
| `REGION` | Nombre de la región | inferido |
| `PROVINCIA` | Nombre de la provincia | inferido |
| `COMUNA` | Nombre de la comuna | inferido |
| `COD_URBANO` | Código del centro urbano censal (Censo 2017) | inferido |
| `URBANO_CEN` | Nombre del centro urbano censal | inferido |
| `TIPO_EP` | Tipo de espacio público: `PLAZA` o `PARQUE` | **confirmado** (StoryMap) |
| `NOMBRE_EP` | Nombre propio de la plaza/parque (si existe) | inferido |
| `OBSERVACIO` | Observaciones de terreno/digitalización | inferido |
| `SUP_TOTAL_` | Superficie total del polígono (m²) | inferido |
| `USO` | Tenencia/uso: `PÚBLICO` o `PRIVADO` | inferido (valores observados) |
| `ID_TEXT` | Identificador de texto del polígono | inferido |
| `FUENTE` | Fuente de digitalización del polígono: `MINVU`, `MUNICIPALIDAD`, `RA O FI` (Restitución Aerofotogramétrica u Fotointerpretación) | inferido |
| `NOMBRE_MIN` | Nombre según catastro MINVU | inferido |
| `EXTENSION` | Escala/alcance del espacio público (p. ej. `COMUNAL`) | inferido |
| `Shape_Leng` / `Shape_Area` | Perímetro / área calculados automáticamente por ArcGIS (en grados, por estar en SIRGAS 2000 geográfico — no usar directamente como m², recalcular tras proyectar) | confirmado (campo estándar Esri) |

### Campos adicionales de la encuesta de calidad — solo `CALIDAD_pzpq_2019_G1G2.shp`

**Indicador de calidad (confirmado por la StoryMap):**

| Campo | Significado |
|---|---|
| `MG` | Puntaje del componente Mantención General (0–100) |
| `VG` | Puntaje del componente Vegetación (0–100) |
| `AU` | Puntaje del componente Accesibilidad Universal (0–100) |
| `SG` | Puntaje del componente Seguridad (0–100) |
| `DE` | Puntaje del componente Diversidad de Equipamientos (0–100) |
| `CALIDAD` | Puntaje de calidad final (0–100), promedio ponderado de `MG`, `VG`, `AU`, `SG`, `DE` según ponderaciones de la mesa de trabajo |
| `RANGO_CALI` | Rango de calidad del polígono: `RANGO INFERIOR`, `RANGO INTERMEDIO`, `RANGO SUPERIOR`, o `SIN INFORMACIÓN` (no encuestado) |

**Sentinel de dato faltante:** cuando el polígono no fue encuestado, `MG`, `VG`, `AU`,
`SG`, `DE` y `CALIDAD` quedan codificados como **`-1`** (no `NA`). Hay exactamente
4.652 filas con `RANGO_CALI == "SIN INFORMACIÓN"`, que coincide con los "4.137
polígonos de plazas y 515 de parques" mencionados en la StoryMap como no encuestados.
**Cualquier análisis debe convertir `-1` a `NA` antes de calcular promedios** — ver
[`scripts/01_areas_verdes_shp.R`](../../../scripts/01_areas_verdes_shp.R).

**Campos de la ficha de levantamiento en terreno (nombres truncados a 10 caracteres
por el formato DBF; significado inferido a partir de la abreviatura — sin
confirmación oficial, ver nota de confiabilidad arriba):**

| Campo | Significado inferido |
|---|---|
| `Fecha_encu` | Fecha de la encuesta de terreno |
| `Estratos_v` | Estratos de vegetación presentes |
| `Estado_veg` | Estado/condición de la vegetación |
| `Estado_mob` | Estado del mobiliario urbano |
| `Limpieza` | Nivel de limpieza del espacio |
| `Bancas_esc` | Presencia de bancas/escaños |
| `Pileta_fue` | Presencia de pileta/fuente de agua ornamental |
| `Bebedero_a` | Presencia de bebedero de agua potable |
| `Juegos_agu` | Presencia de juegos de agua |
| `Juegos_inf` | Presencia de juegos infantiles |
| `Escenario_` | Presencia de escenario/anfiteatro |
| `Maquinas_e` | Presencia de máquinas de ejercicio |
| `Mesa_juego` | Presencia de mesas de juego (ajedrez, ping-pong, etc.) |
| `Pergolas_t` | Presencia de pérgolas/estructuras de sombra |
| `Infraest_d` | Presencia de infraestructura deportiva |
| `Cancha_Ska` | Presencia de cancha de skate |
| `Basureros` | Presencia de basureros |
| `Banos` | Presencia de baños públicos |
| `Banos_acce` | Presencia de baños accesibles |
| `Luminarias` | Presencia/estado de luminarias |
| `Arenero` | Presencia de arenero (juegos infantiles) |
| `Rutas_peat` | Presencia de rutas peatonales |
| `RtaPeat_co`, `RtaPeat__1`, `RtaPeat__2`, `RtaPeat_su`, `RtaPeat_li`, `RtaPeat__3`, `RtaPeat_ac` | Atributos de la(s) ruta(s) peatonal(es) (p. ej. condición, continuidad, superficie, limpieza, accesibilidad) — campos truncados y repetidos por ArcGIS al superar 10 caracteres |
| `Zna_descan` | Presencia de zona de descanso |
| `Zona_juego` | Presencia de zona de juegos |
| `VentaConsu` | Presencia de venta/consumo de alimentos y bebidas |
| `Guardias` | Presencia de guardias/vigilancia |
| `Otros_mobi` | Otro mobiliario urbano no listado |
| `Cierres` | Tipo de cierre/deslinde del espacio |
| `Aplicabili` | Aplicabilidad de la ficha (posible marca de exclusión de algún módulo) |
| `Valor_pers` / `Valor_veh` | Presencia de control de acceso (peatonal / vehicular) |
| `TARGET_FID` | Identificador interno heredado de un proceso de geoprocesamiento ArcGIS (`Target Feature ID`) |

### Campos del resumen por centro urbano — solo `CALIDAD_LUC_PzPq.shp`

Un registro por cada uno de los 559 centros urbanos censales, con indicadores
agregados separados por prefijo `PZ_` (plazas) y `PQ_` (parques).

| Campo | Significado | Confianza |
|---|---|---|
| `REGION`, `NOMBRE_REG`, `NOMBRE_PRO`, `CUT`, `NOMBRE_COM`, `COD_URBANO`, `NOMBRE_URB` | Identificadores territoriales (región, provincia, comuna, centro urbano) | inferido |
| `PZ_NR_TOTA` / `PQ_NR_TOTA` | N° total de plazas / parques en el centro urbano | inferido |
| `PZ_NR_Habi` / `PQ_NR_Habi` | N° de plazas / parques **con** encuesta de calidad ("habilitados") | inferido, verificado* |
| `PZ_M2_TOTA` / `PQ_M2_TOTA` | Superficie total de plazas / parques (m²) | inferido |
| `PZ_M2_Habi` / `PQ_M2_Habi` | Superficie de plazas / parques **con** encuesta de calidad (m²) | inferido, verificado* |
| `PZ_PCM2_Ha` / `PQ_PCM2_Ha` | % de la superficie total que cuenta con encuesta de calidad | **inferido, verificado**: `PZ_PCM2_Ha == 100 * PZ_M2_Habi / PZ_M2_TOTA` (correlación = 1 sobre los 559 registros) |
| `PZ_PROM_CA` / `PQ_PROM_CA` | Promedio de `CALIDAD` de las plazas / parques encuestados del centro urbano | inferido |
| `PZ_PROM_MG`, `PZ_PROM_VG`, `PZ_PROM_AU`, `PZ_PROM_SG`, `PZ_PROM_DE` (ídem `PQ_PROM_*`) | Promedio de cada componente de calidad, por centro urbano | inferido |
| `M2_PZPQ_TO` | Superficie total combinada de plazas + parques del centro urbano (m²) | inferido |
| `Shape_Leng` / `Shape_Area` | Perímetro / área del polígono del centro urbano (grados) | confirmado (campo estándar Esri) |

\* El sufijo `_Ha` en `PZ_PCM2_Ha` / `PQ_PCM2_Ha` es "habilitado" (con encuesta), **no**
"hectárea" ni "habitante" — se confirmó numéricamente, ver tabla de arriba.

---

## Cómo se procesan estos datos

Ver [`scripts/01_areas_verdes_shp.R`](../../../scripts/01_areas_verdes_shp.R): lee los
tres shapefiles, limpia el sentinel `-1` → `NA` en los campos de calidad, une la
cobertura cartográfica nacional (plazas/parques individuales, con y sin encuesta) en
una sola capa de polígonos, y deja los indicadores por centro urbano listos para
análisis. Salidas en `data/processed/`.
