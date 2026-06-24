# DVBA Zona VI Saladillo · Sistema de Relevamiento y Gestión Vial

Sistema web de relevamiento, cartografía y gestión de la red vial provincial a cargo de la **Zona Departamental VI** de la Dirección de Vialidad de la Provincia de Buenos Aires (DVBA), con sede en Saladillo.

**Cobertura:** 8 partidos (Saladillo, Gral. Alvear, Gral. Las Heras, Lobos, Roque Pérez, Las Flores, Navarro, 25 de Mayo) · 15 rutas provinciales pavimentadas, tierra y mixtas + red de caminos secundarios.

**Hosting:** GitHub Pages — https://lemeit.github.io/DVBA/

---

## Apps publicadas

| URL | Archivo | Versión | Descripción |
|---|---|---|---|
| https://lemeit.github.io/DVBA/ | `index.html` | **v7.7** | App de escritorio: mapa Leaflet, progresivas, sidebar de registros, reportes PDF/CSV, sello v2 editable en fotos |
| https://lemeit.github.io/DVBA/dvba_campo.html | `dvba_campo.html` | **v9.15** | App móvil PWA instalable: relevamiento GPS de campo (MSV 2017), sello v2 editable + Plus Code offline |
| https://lemeit.github.io/DVBA/caminos_secundarios.html | `caminos_secundarios.html` | **v1.1** | Visor interactivo de red secundaria con filtros, hover tolerante, exportación CSV/reporte |
| https://lemeit.github.io/DVBA/docs/bitacora.html | bitácora unificada | v4.1 | Bitácora con tabs por temática (Resumen, Rutas/QGIS, Apps, Infraestructura, Decisiones, Pendientes, Changelog) |
| https://lemeit.github.io/DVBA/docs/guia_dvba_campo.html | guía de usuario | — | Manual de la app de campo |

## Sello DVBA en fotos (v2 — desde junio 2026)

Toda foto cargada en cualquiera de las dos apps (escritorio y móvil) se estampa con un sello institucional al estilo **GPS Map Camera**, pero offline-first y con datos **editables** vía modal antes de aplicar.

### Funcionamiento
Al subir/sacar una foto se abre un modal **"Editar datos del sello"** con los campos pre-cargados desde el GPS, el formulario y la fecha/hora actual. El operador puede ajustar cualquier valor antes de estampar:

| Campo | Origen automático | Editable |
|---|---|---|
| Localidad | Partido + Provincia + País | ✓ |
| Dirección | Ruta + km del form | ✓ |
| Lat / Lng | GPS (móvil) o form (escritorio) | ✓ |
| Fecha / Hora | Sistema | ✓ |
| Altura | GPS (`gpsAlt`) — solo móvil | ✓ |
| Plus Code | Calculado vanilla JS desde lat/lng | ✓ |
| Ruta / Km / Tipo | Form | ✓ |

Botones: **"Aplicar y guardar"** estampa con los valores confirmados; **"Sin sello"** sube la foto original.

### Diseño visual
- Banda inferior con gradient negro + línea dorada superior
- **Izquierda**: 5 líneas de información (localidad dorada, ruta+km blanca, lat/long+alt verde mono, plus code azul mono, fecha+hora+tipo) + firma institucional separada en italic dorado tenue
- **Derecha**: logo institucional DVBA centrado verticalmente

Sin mini-mapa ni clima — las apps deben funcionar sin datos en campo, solo con GPS.

### Plus Code (Open Location Code)
Implementación vanilla JavaScript, 10 caracteres, válido a nivel mundial sin dependencias externas ni conexión. Se auto-recalcula al editar lat/lng en el modal.

### Política de versionado del sello
- **Tweak cosmético** (fuente, color, posición): solo se bumpea `sw.js` con sufijo letra (`v9.15a` → `v9.15b`...). El span del footer queda igual.
- **Cambio publicable**: se bumpean los 3 (`APP_VERSION` en `index.html`, `<span id='app-ver'>` en `dvba_campo.html`, `CACHE_NAME` en `sw.js`).

## Estructura del repositorio

```
DVBA/
├── index.html              ← App de escritorio (= ex dvba_zona6.html)
├── dvba_campo.html         ← App móvil PWA
├── dvba_tipos.js           ← Selector jerárquico de tipos MSV 2017
├── manifest.json           ← Manifiesto PWA
├── sw.js                   ← Service Worker (cache + sync Supabase)
├── icon-192.png  icon-512.png
│
├── datos/                  ← Bundles JS por ruta cargados por las apps
│   ├── rutas.js            ← Índice maestro
│   ├── rutas_rp40.js       ← RP40 — completa (cadena + anchors + 5 mojones físicos + 37 sintéticos + 3 gaps)
│   ├── rutas_rp30.js
│   ├── rutas_rp41.js
│   ├── rutas_rp46.js
│   ├── rutas_rp51.js
│   ├── rutas_rp91.js
│   └── img/                ← Logos e íconos institucionales
│
├── scripts/                ← Scripts Python (procesamiento, generación de bundles)
│   ├── gen_ruta_bundle.py        ← Generador de bundles datos/rutas_rpXX.js
│   ├── build_campo.py            ← Build de la app de campo
│   ├── Armonizar_mojones.py
│   ├── 01_procesamiento_rutas/   ← Cálculo de progresivas, validación, corrección
│   ├── 02_analisis_topologia/
│   ├── 03_utilidades/            ← Exploración SHP, generación de mojones
│   ├── 04_reportes/
│   └── requirements.txt
│
├── geojson_procesados/     ← GeoJSONs intermedios listos para generar bundles
│   ├── rp40_unificada_congaps.geojson  + mojones_rp40_final.geojson
│   ├── rp30_…  rp41_…  rp46_…  rp51_…  rp91_…
│
├── docs/                   ← Documentación
│   ├── bitacora.html                   ← Bitácora unificada (tabs por temática)
│   ├── guia_dvba_campo.html
│   └── guia_dvba_campo.pdf
│
├── tests/                  ← Tests de integración por ruta
│   └── test_rp30.html  test_rp40.html  test_rp41.html  test_rp46.html  test_rp51.html  test_rp91.html
│
├── archivo/                ← Versiones legacy y referencias históricas
│   ├── versiones/                       ← Backups de los HTMLs (incluye dvba_campo_BKFUNCIONAL)
│   ├── dvba_zona6_bk2.html
│   ├── dvba_zona6_bx.html
│   └── servidor_http.py                 ← Server local antiguo (era pre-GitHub Pages)
│
└── .github/workflows/
    └── supabase_keepalive.yml           ← Keepalive del proyecto Supabase (free tier)
```

## Fuentes pesadas (FUERA del repo)

Las fuentes crudas se mantienen localmente y NO se versionan:

```
C:\DVBA_fuentes\
├── qgis/                   ← Proyecto QGIS completo
│   ├── proyecto_redes_viales.qgz
│   ├── 02_BASES_VECTORES/  ← SHP fuente (305 MB — mojones, partidos, red provincial)
│   ├── 03_CAPAS_GENERADAS/ ← Capas procesadas (17 MB)
│   ├── 04_BACKUPS/         ← Backups históricos (49 MB)
│   ├── 05_TABLAS/  06_RESULTADOS/  07_EXPORTS/
│   └── venv_redes_viales/  ← Virtualenv (regenerable con scripts/requirements.txt)
└── osm/                    ← OSM PBF Argentina + extractos (~430 MB)
```

## Flujo para incorporar una ruta nueva

1. **QGIS:** Filtrar la traza → Corregir geometrías → Multiparte a monoparte → Disolver → Exportar GeoJSON unificado.
2. **Digitalizar gaps** (cruces de río sin puente, zonas urbanas) sobre imagen satelital con snap activado.
3. **Preparar capa de mojones** (campo `Name`: "0KM", "50KM"…; campo `description`: sentido).
4. **Generar bundle:**
   ```bash
   python scripts/gen_ruta_bundle.py rpXX
   ```
   Esto produce `datos/rutas_rpXX.js`.
5. **Integrar en las apps:** agregar `<script src="datos/rutas_rpXX.js">` en `index.html` y registrarla en `datos/rutas.js`.

## Stack técnico

| Componente | Versión | Rol |
|---|---|---|
| QGIS | 3.42.0 Münster | Edición y limpieza de capas vectoriales |
| Leaflet.js | 1.9.4 | Mapa interactivo en `index.html` y `caminos_secundarios.html` |
| Python | 3.12 | Scripts de procesamiento y generación de bundles |
| Supabase | Free tier | Backend de registros de campo (PostgreSQL + Storage + Auth + RLS) |
| GitHub Pages | — | Hosting estático |
| Service Worker + IndexedDB | — | Cola offline + sync automático en la app de campo |
| Canvas API | — | Renderizado del sello v2 sobre las fotos (sin dependencias externas) |

## Convención institucional

Denominación oficial en todos los documentos y apps: **"Zona Departamental VI Saladillo"** o abreviado **"Zona VI Saladillo"**. NUNCA "Delegación Saladillo".

---

**Responsable:** Ing. Luciano Lamaita — División Técnica DVBA Zona VI
