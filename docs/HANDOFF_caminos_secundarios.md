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

**1 segmento pendiente de verificación:**
- `093-02 "RN 205 - Cazón"`: LONGITUD declarada 4.678 km vs geodésica 5.636 km (+20.5%).
  El atributo LONGITUD probablemente no contempla algún tramo de la traza oficial.

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

## 8. Estructura de carpetas sugerida en el repo

```
DVBA/
├── referencias/
│   └── partidos_pba.json              ← no editar manualmente
├── scripts/
│   └── calcular_longitudes_red_vial.py
├── datos/
│   ├── Caminos_Secundarios_PBA.geojson   ← fuente canónica (toda PBA)
│   └── zona_vi/
│       ├── red_secundaria_zonaVI_final.geojson
│       ├── red_secundaria_zonaVI_final.gpkg
│       ├── red_secundaria_zonaVI_longitudes.csv
│       └── red_secundaria_zonaVI_resumen.csv
└── app/
    └── (código del mapa interactivo existente)
```
