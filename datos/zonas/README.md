# `datos/zonas/` — Estructura multi-zona SIG Vial PBAᵝ

**Introducida en v8.59 · 3 agosto 2026.**

Esta carpeta contiene la data **específica de cada zona vial DVBA** (partidos, red secundaria, CARACT_VIALES). Los **bundles de RPs** viven en `datos/rutas/` porque son compartidos entre zonas (una RP puede atravesar varias zonas).

## Estructura estándar por zona

```
datos/zonas/zona_XX/
├── manifest.json                          ← metadata: partidos, RPs que atraviesan, assets, stats
├── partidos_zonaXX.geojson               ← Polígonos partidos (MultiPolygon, WGS84)
├── red_secundaria_zonaXX_final.geojson   ← Caminos secundarios calibrados
├── red_secundaria_zonaXX_final.gpkg      ← Idem en formato QGIS
├── red_secundaria_zonaXX_longitudes.csv  ← Longitudes por tramo (validación)
├── red_secundaria_zonaXX_resumen.csv     ← Resumen por camino
├── CARACT_VIALES_zonaXX.csv              ← Data oficial DVBA tramos por RP
├── caracteristicas_viales_zonaXX.js      ← Bundle JS derivado del CSV
└── red_vial_zonaXX.js                    ← Módulo unificado (fetch red_secundaria + RP_LIST)
```

## Zonas y su estado

| Código | Nombre               | Cabecera             | Estado       | # Partidos | Assets cargados |
|--------|----------------------|----------------------|--------------|------------|-----------------|
| I      | Arrecifes            | Arrecifes            | 🕐 Pendiente | 11         | -               |
| II     | Morón                | Morón                | 🕐 Pendiente | 17         | -               |
| III    | Ensenada             | Ensenada             | 🕐 Pendiente | 31         | -               |
| **IV** | **Junín**            | **Junín**            | 🟡 Piloto v8.61 | **9** | 9 partidos + 67 tramos RP (10 RPs, 1 calibrada RP46 compartida con VI) |
| **V**  | **Chivilcoy**        | **Chivilcoy**        | 🟡 Piloto v8.61 | **6** | 6 partidos + 77 tramos RP (10 RPs, 4 calibradas RP30/46/51/61 compartidas con VI) |
| **VI** | **Saladillo**        | **Saladillo**        | ✅ **Producción** | **8** | **8 partidos + 100 caminos + 15 RPs (8 calibradas) + 632 partes históricos** |
| VII    | Dolores              | Dolores              | 🕐 Pendiente | 11         | -               |
| VIII   | Pehuajó              | Pehuajó              | 🕐 Pendiente | 12         | -               |
| IX     | Azul                 | Azul                 | 🕐 Pendiente | 6          | -               |
| X      | General Pueyrredón   | Mar del Plata        | 🕐 Pendiente | 6          | -               |
| XI     | Bahía Blanca         | Bahía Blanca         | 🕐 Pendiente | 11         | -               |
| XII    | Necochea             | Necochea             | 🕐 Pendiente | 6          | -               |
|        | **Total**            |                      |              | **134**    |                 |

Ver `CABECERAS.md` para el detalle de los partidos que integran cada zona.

## Alta de zona nueva (checklist)

Cuando el user Luciano pase los shp de una zona nueva:

**1. Preparar carpeta**
```bash
mkdir -p datos/zonas/zona_XX
```

**2. Convertir shapefiles a GeoJSON** (QGIS o script Python con GDAL)
- Reproyectar a WGS84 (EPSG:4326)
- Exportar `partidos_zonaXX.geojson` (MultiPolygon con `properties.partido`)
- Recortar `caminos_secundarios_PBA.geojson` (master en root) por partido → `red_secundaria_zonaXX_raw.geojson`
- Marcar como calibrado o crudo en el manifest

**3. Escribir manifest.json** siguiendo el esquema de `zona_VI/manifest.json`. Campos obligatorios:
- `codigo` (romano, ej "IV"), `nombre` (Junín), `cabecera` (partido con asterisco)
- `partidos[]` con `esCabecera: true` en el que corresponda
- `rps[]` con `calibrado: true|false` y `bundle` si existe
- `assets` con paths absolutos desde raíz del repo

**4. Reutilizar RPs calibradas por VI que atraviesen la zona**
Si por ej. la RP51 (ya calibrada) pasa por la nueva zona, agregar al `rps[]` del manifest con `bundle: "datos/rutas/rutas_rp51.js"`. Ningún archivo nuevo.

**5. Cuando llegue el momento de la Fase B (loader dinámico)**:
El HTML principal ya no cargará `<script src>` hardcoded — leerá `manifest.json` de la zona del user y cargará solo lo que necesita.

## Partidos cabecera por zona (referencia DVBA)

*El partido cabecera se marca con asterisco (*). Es donde está la Sede de la Zona.*

Ver `datos/zonas/CABECERAS.md` para la lista completa una vez que Luciano termine de pasar las 12 zonas.

## Convención de naming

- Carpetas: `zona_VI`, `zona_IV`, etc. (romano en **mayúscula**, prefijo `zona_`)
- Archivos: sufijo `_zonaVI` sin guion bajo antes del romano (`partidos_zonaVI.geojson`, no `partidos_zona_VI.geojson`)
- Bundles RP en `datos/rutas/`: `rutas_rpXX.js` (sin sufijo de zona, son compartidos)
