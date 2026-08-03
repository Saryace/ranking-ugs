# data/processed/OCUC-MINVU

Salidas generadas por [`scripts/04_ocuc_vs_minvu_comparacion.R`](../../../scripts/04_ocuc_vs_minvu_comparacion.R),
que compara dos fuentes independientes de áreas verdes públicas (plazas y parques)
de la Región Metropolitana:

- **OCUC**: categoría `Públicas` de [`data/raw/OCUC-MINVU/`](../../raw/OCUC-MINVU/README.md) (2017)
- **MINVU**: todos los polígonos (`PLAZA` + `PARQUE`) de `CALIDAD_pzpq_2019_G1G2.shp`
  en la Región Metropolitana, de [`data/raw/SHP/`](../../raw/SHP/README.md) (2019)

Ambas fuentes se reproyectan a **EPSG:32719** (WGS 84 / UTM 19S — el mismo CRS de
los rasters de `stgo-hot`) para calcular áreas y superposición de forma correcta.
Esta carpeta no se versiona (ver `.gitignore`), salvo este `README.md`.

## `comparacion_comunas.csv`

Una fila por comuna de la Región Metropolitana (43 comunas: las 43 de MINVU; OCUC
solo tiene polígonos `Públicas` en 34 de ellas).

| Variable | Descripción |
|---|---|
| `comuna` | Nombre de comuna, normalizado (mayúsculas, sin tildes) |
| `n_ocuc_publicas` | N° de polígonos `Públicas` de OCUC en la comuna |
| `n_minvu_pzpq` | N° de polígonos plaza/parque de MINVU en la comuna (con y sin encuesta de calidad) |
| `area_ocuc_ha` | Superficie total OCUC `Públicas`, en hectáreas |
| `area_minvu_ha` | Superficie total MINVU plazas+parques, en hectáreas |
| `area_interseccion_ha` | Superficie donde ambas fuentes coinciden espacialmente |
| `area_solo_ocuc_ha` | Superficie cubierta solo por OCUC (`area_ocuc_ha - area_interseccion_ha`) |
| `area_solo_minvu_ha` | Superficie cubierta solo por MINVU (`area_minvu_ha - area_interseccion_ha`) |
| `pct_ocuc_solapado` | % de la superficie de OCUC que coincide con MINVU |
| `pct_minvu_solapado` | % de la superficie de MINVU que coincide con OCUC |

### Resultados generales

| | OCUC "Públicas" | MINVU plazas+parques |
|---|---|---|
| Superficie total en la RM | 2.027,6 ha | 3.735,1 ha |
| Superficie en intersección | 1.718,5 ha (**84,8%** del total OCUC) | 1.718,5 ha (**46,0%** del total MINVU) |

**MINVU cubre casi el doble de superficie que OCUC** en la Región Metropolitana.
Esto es esperable: MINVU catastra específicamente plazas y parques (incluye
polígonos "sin información"/no encuestados, pero igual mapeados
cartográficamente), mientras que la capa de OCUC es una tipología más amplia de
áreas verdes (2017) cuya categoría "Públicas" no necesariamente equivale 1:1 al
universo de plazas/parques de MINVU (2019).

Las 5 comunas con mayor superficie MINVU (Recoleta, Maipú, Puente Alto,
Providencia, Santiago) muestran solapamientos muy dispares: Recoleta y
Providencia superan 75% de solapamiento respecto a MINVU, mientras que Maipú y
Puente Alto están bajo 30% — sugiere diferencias de cobertura/actualización
concentradas en comunas periféricas de alto crecimiento.

9 comunas no tienen ningún polígono `Públicas` en OCUC (`area_ocuc_ha = 0`,
`pct_ocuc_solapado = NA`): son comunas periféricas/rurales de la RM (ver
[`data/raw/OCUC-MINVU/README.md`](../../raw/OCUC-MINVU/README.md)).

## `comparacion_poligonos.gpkg`

GeoPackage con 2 capas (EPSG:32719) para inspección visual en un SIG:

- `ocuc_publicas_rm`: polígonos individuales OCUC `Públicas` (3.936), con `comuna_norm`, `TIPO`, `AREA_m2`, `AREA_ha`
- `minvu_pzpq_rm`: polígonos individuales MINVU plaza/parque en la RM (10.243), con `comuna_norm`, `TIPO_EP`, `NOMBRE_EP`, `SUP_TOTAL_`, `CALIDAD`, `RANGO_CALI`
