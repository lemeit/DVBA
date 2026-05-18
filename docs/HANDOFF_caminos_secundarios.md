# Handoff: Capa de Caminos Secundarios — DVBA Zona VI
**Para integrar en:** Mapa interactivo DVBA Zona VI (proyecto en Cowork/GitHub)
**Fecha:** Mayo 2026

---

## 1. Contexto

Se procesó la red secundaria provincial de la Zona Departamental VI Saladillo
para obtener longitudes geodésicas confiables e integrarlas al mapa interactivo
que ya tiene las rutas provinciales.

---

## 2. Fuentes de datos

| Archivo | Descripción | Estado |
|---|---|---|
| `Caminos_Secundarios_Provincia_de_Buenos_Aires.geojson` | GeoJSON oficial completo PBA (1681 features, toda la provincia) | **FUENTE CANÓNICA** |
| `red_secundaria_zonavia.gpkg` | GeoPackage Zona VI exportado del KMZ provincial | Descartado como fuente (errores de geometría en 5 segmentos) |
| `partidos_pba.json` | Listado oficial de partidos PBA (fuente: ARBA) | Referencia cruzada del proyecto |

---

## 3. Problemas detectados y resueltos

### 3.1 Columna LONGITUD corrupta en datos oficiales
Los datos provinciales tienen corrupción en la columna `LONGITUD` por
separador de miles mal exportado:
```
'17.670.000.000.000.000'  →  valor real: 17.670 km
```
**Fix:** tomar solo los dos primeros grupos separados por punto.

### 3.2 Errores de nomenclatura de partidos en datos KMZ/GeoJSON provincial
Los datos oficiales tienen errores en los nombres (verificado contra ARBA):
```
Partido 041 → General Las Heras   (el archivo decía "General Paz", que es el 043)
Partido 075 → Navarro             (el archivo decía "Monte", que es el 073)
Partido 109 → Veinticinco de Mayo (el archivo decía "Tapalqué", que es el 104)
```
**Fix:** usar `partidos_pba.json` como referencia cruzada en runtime.

### 3.3 QGIS con elipsoide incorrecto
El proyecto QGIS tenía **Ellipsoid = "None / Planimetric"**, lo que hace que
`$length` calcule distancias en unidades de grado (incorrecto).
**Fix:** todo el cálculo se hace por Python con `pyproj` + elipsoide WGS84.
No se usa QGIS para medición.

---

## 4. Resultado: Red Secundaria Zona VI

**128 segmentos** (MultiLineString, EPSG:4326) distribuidos en 8 partidos:

| Partido | Nombre | Segmentos | km WGS84 |
|---|---|---|---|
| 034 | General Alvear | 10 | 192.52 |
| 041 | General Las Heras | 9 | 69.64 |
| 058 | Las Flores | 14 | 228.42 |
| 062 | Lobos | 13 | 142.79 |
| 075 | Navarro | 9 | 131.31 |
| 091 | Roque Pérez | 16 | 166.24 |
| 093 | Saladillo | 28 | 326.28 |
| 109 | Veinticinco de Mayo | 29 | 485.73 |
| **TOTAL** | **Zona VI** | **128** | **1.742.91** |

**Estado de revisión por partido (mayo 2026):**
- **093 Saladillo: REVISADO en QGIS.** Las geometrías se corrigieron a mano contra imagen
  satelital y se reprocesaron con el script. Los 4 segmentos que quedaron con
  `ALERTA = REVISAR` (`093-02`, `093-03`, `093-04`, `093-05`) fueron inspeccionados
  visualmente y las longitudes geodésicas se aceptan como correctas — la diferencia
  con `LONGITUD_KM_ORIG` se debe a error del dato provincial, no de la geometría.
  Archivo final: `geojson_procesados/red_secundaria/caminos_secundarios_093_corregidos_final.geojson`
  (28 features · 338.32 km WGS84).
- **034 General Alvear, 109 25 de Mayo:** GPKG en carpeta, pendiente regenerar `_final.geojson`.
- **041, 058, 062, 075, 091:** pendientes de revisión en QGIS.

> Mientras los partidos pendientes no tengan su `caminos_secundarios_XXX_*final.geojson`,
> el mapa `caminos_secundarios.html` los carga desde el dataset preliminar
> `datos/zona_vi/red_secundaria_zonaVI_final.geojson` con el indicador "◌ preliminar".

---

## 5. Archivos generados (outputs/)

```
Caminos_Secundarios_Provincia_de_Buenos_Aires_longitudes.csv   ← detalle por segmento
Caminos_Secundarios_Provincia_de_Buenos_Aires_resumen.csv      ← totales por partido
Caminos_Secundarios_Provincia_de_Buenos_Aires_final.gpkg       ← para QGIS
Caminos_Secundarios_Provincia_de_Buenos_Aires_final.geojson    ← para la app web
partidos_pba.json                                              ← referencia ARBA
calcular_longitudes_red_vial.py                                ← script reutilizable
```

### Columnas en los archivos de salida:
| Columna | Descripción |
|---|---|
| `NOMEMCLATURA` | Código del camino (ej: `093-02`) |
| `PARTIDO` | Número de partido ARBA |
| `PARTIDO_NOMBRE` | Nombre oficial del partido |
| `DENOMINACION` | Nombre descriptivo del tramo |
| `CLASE` | `DE TIERRA` / `PAVIMENTADO` |
| `TRANSITABIlIDAD` | `TEMPORARIO` / `PERMANENTE` |
| `TIPO` | `CAMINO` |
| `LONGITUD_KM_ORIG` | Valor original decodificado del dato provincial |
| `LONGITUD_KM_WGS84` | **Longitud geodésica calculada — usar este** |
| `N_VERTICES` | Cantidad de vértices de la geometría |
| `N_LINEAS` | Cantidad de linestrings en la MultiLineString |
| `DIFF_PCT` | Diferencia % entre ORIG y WGS84 |
| `ALERTA` | `REVISAR` si diff > 10% |

---

## 6. Script reutilizable

`calcular_longitudes_red_vial.py` procesa cualquier zona a futuro:

```bash
# Desde el GeoJSON completo PBA (recomendado):
python calcular_longitudes_red_vial.py \
  --input Caminos_Secundarios_Provincia_de_Buenos_Aires.geojson \
  --output resultados/ \
  --zona VI \
  --ref referencias/partidos_pba.json

# Para otra zona (agregar zona en partidos_pba.json → zonas_dvba primero):
python calcular_longitudes_red_vial.py \
  --input Caminos_Secundarios_Provincia_de_Buenos_Aires.geojson \
  --output resultados/ \
  --zona VII \
  --ref referencias/partidos_pba.json
```

**Dependencias:** `pip install geopandas fiona pyproj pandas shapely`

### Variantes de input aceptadas (script actualizado mayo 2026)

`cargar_gpkg` detecta automáticamente el tipo de input:

- **Tiene columna `LONGITUD`** → es el GPKG original del KMZ provincial, flujo de siempre
  (decodifica la `LONGITUD` corrupta como `LONGITUD_KM_ORIG`).
- **Tiene `LONGITUD_KM_ORIG` pero no `LONGITUD`** → es un `_final.gpkg` propio (output
  previo del script). Conserva la columna `LONGITUD_KM_ORIG` tal cual, no la recalcula
  desde la `LONGITUD` corrupta. **Caso típico: re-procesar un GPKG con geometrías
  corregidas a mano en QGIS.**
- **No tiene ninguna** → avisa y deja `LONGITUD_KM_ORIG` vacía (no rompe).

`LONGITUD_KM_WGS84` **siempre** se recalcula desde la geometría, así que la geometría
corregida en QGIS es la fuente de verdad y el script vuelve a medir.

`N_VERTICES` y `N_LINEAS` también se calculan correctamente para `MultiLineString`,
que es el caso típico de los `_final.gpkg` derivados del GeoJSON canónico.

Para agregar una zona nueva al JSON:
```json
"zonas_dvba": {
  "VI": {
    "nombre": "Zona Departamental VI Saladillo",
    "partidos": [34, 41, 58, 62, 75, 91, 93, 109]
  },
  "VII": {
    "nombre": "Zona Departamental VII ...",
    "partidos": [...]
  }
}
```

---

## 7. Integración en la app

### Qué hay que hacer en Cowork/GitHub:

1. **Agregar el GeoJSON filtrado** (`..._final.geojson`) como nueva capa en el mapa,
   análoga a la capa de rutas provinciales ya existente.

2. **Campos a mostrar en popup/tooltip:**
   - `NOMEMCLATURA` — identificador
   - `PARTIDO_NOMBRE` + `DENOMINACION` — descripción
   - `LONGITUD_KM_WGS84` — longitud en km (2 decimales)
   - `CLASE` + `TRANSITABIlIDAD` — tipo de camino

3. **Estilo sugerido:** distinguir visualmente `DE TIERRA / TEMPORARIO` vs
   `PAVIMENTADO / PERMANENTE` (la mayoría son tierra).

4. **Si se usa Supabase:** cargar la tabla desde el CSV de detalle,
   con la geometría como columna separada (PostGIS) desde el GeoPackage.

5. **Fuente canónica para reprocessing:**
   `Caminos_Secundarios_Provincia_de_Buenos_Aires.geojson` — guardar en el repo,
   es el único archivo de entrada que se necesita para regenerar todo.

---

## 8. Estructura de carpetas en el repo

```
DVBA/
├── referencias/
│   └── partidos_pba.json                              ← ref ARBA (no editar a mano)
├── scripts/
│   └── calcular_longitudes_red_vial.py                ← script reutilizable
├── datos/                                              ← fuentes brutas
│   ├── caminos_secundarios_PBA.geojson                ← fuente canónica PBA (1681 features)
│   └── zona_vi/                                        ← dataset Zona VI preliminar (pre-revisión)
│       ├── red_secundaria_zonaVI_final.geojson        ← usado como fallback en el mapa
│       ├── red_secundaria_zonaVI_final.gpkg
│       ├── red_secundaria_zonaVI_longitudes.csv
│       └── red_secundaria_zonaVI_resumen.csv
├── geojson_procesados/red_secundaria/                  ← datos por partido revisados a mano
│   ├── caminos_secundarios_093_corregidos_final.geojson   ← REVISADO (Saladillo)
│   ├── caminos_secundarios_093_corregidos.gpkg
│   ├── caminos_secundarios_093.gpkg
│   ├── caminos_secundarios_034.gpkg                    ← pendiente _final.geojson
│   ├── caminos_secundarios_109.gpkg                    ← pendiente _final.geojson
│   └── (resto pendiente)
├── caminos_secundarios.html                            ← mapa interactivo
└── docs/
    └── HANDOFF_caminos_secundarios.md                  ← este archivo
```

**Convenciones:**
- `datos/` solo guarda **fuentes canónicas / brutas** (geopackages PBA, geojson PBA completo,
  reportes CSV). El dataset preliminar de Zona VI `datos/zona_vi/` se usa como fallback
  hasta que cada partido tenga su versión revisada.
- `geojson_procesados/red_secundaria/` guarda los datos por partido **post-revisión QGIS**.
  Cada uno se nombra `caminos_secundarios_NNN_corregidos_final.geojson` (o variante similar).
- El mapa `caminos_secundarios.html` carga primero los archivos por partido y, si alguno
  no está, hace fallback al dataset preliminar de `datos/zona_vi/`, indicando en la UI
  con un círculo verde (revisado) o naranja (preliminar).
