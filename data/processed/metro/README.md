# data/processed/metro

Generado por [`scripts/09_metro_buffer_5min.R`](../../../scripts/09_metro_buffer_5min.R)
a partir de [`data/raw/metro/`](../../raw/metro/README.md). Esta carpeta no se
versiona (ver `.gitignore`), salvo este `README.md`.

## `metro_buffer_5min.gpkg`

Buffer de **"5 minutos caminando" (400 m de radio)** alrededor de cada una de
las 117 estaciones de Metro de Santiago, en `EPSG:32719` (WGS 84 / UTM 19S —
mismo CRS que `stgo-hot` y el NDVI reparado).

> **Es un buffer euclidiano recto (círculo), no una isócrona de red peatonal
> real.** No tiene en cuenta calles, veredas, cruces ni obstáculos — es una
> primera aproximación. Sobreestima el área realmente alcanzable a pie en 5
> minutos dentro de una cuadrícula urbana. El radio de 400 m viene de asumir
> una velocidad de caminata de referencia de ~4,8 km/h (80 m/min), el
> estándar habitual en planificación urbana para "5 minutos caminando".

| Capa | Geometría | Features | Contenido |
|---|---|---|---|
| `estaciones` | Punto | 117 | Estaciones de Metro reproyectadas, con todos los atributos originales (`nombre`, `linea`, `estacion`, `especial`, etc. — ver [data/raw/metro/README.md](../../raw/metro/README.md)). El typo `"EXSTENTE"` ya viene corregido a `"EXISTENTE"`. |
| `buffer_individual` | Polígono | 117 | Un círculo de 400 m por estación, con los mismos atributos — permite filtrar el buffer por línea o por estado (`EXISTENTE`/`PROYECTADO`/`CONSTRUCCION`) antes de cruzar con otras capas. |
| `buffer_disuelto` | Multipolígono | 1 | Unión de los 117 círculos en una sola geometría de cobertura: "área a 5 min caminando de **alguna** estación" (incluye estaciones existentes, proyectadas y en construcción — filtrar `buffer_individual` primero si se necesita solo lo ya operativo). Área total: **55,4 km²**. |

### Cómo usar esto para el ranking

Para marcar qué plazas/parques de `data/processed/SHP` quedan a 5 min de metro:

```r
library(sf)
av <- st_read("data/processed/SHP/areas_verdes_rm.gpkg") |> st_transform(32719)
buffer <- st_read("data/processed/metro/metro_buffer_5min.gpkg", layer = "buffer_disuelto")
av$cerca_metro_5min <- lengths(st_intersects(av, buffer)) > 0
```

Si se quiere restringir a estaciones ya operativas, filtrar primero
`buffer_individual` por `estacion == "EXISTENTE"` y disolver antes del cruce.
