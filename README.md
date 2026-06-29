# DVBA Zona VI Saladillo · Sistema de Relevamiento y Gestión Vial

Sistema web de relevamiento, cartografía y gestión de la red vial provincial a cargo de la **Zona Departamental VI** de la Dirección de Vialidad de la Provincia de Buenos Aires (DVBA), con sede en Saladillo.

**Cobertura:** 8 partidos (Saladillo, Gral. Alvear, Gral. Las Heras, Lobos, Roque Pérez, Las Flores, Navarro, 25 de Mayo) · 15 rutas provinciales pavimentadas, tierra y mixtas + red de caminos secundarios.

**Hosting:** GitHub Pages — https://lemeit.github.io/DVBA/

---

## Apps publicadas

| URL | Archivo | Versión | Descripción |
|---|---|---|---|
| https://lemeit.github.io/DVBA/ | `index.html` | **v7.14** | App de escritorio: mapa, sidebar de registros + **cola de pendientes + sellado al aprobar** |
| https://lemeit.github.io/DVBA/dvba_campo.html | `dvba_campo.html` | **v9.19** | App móvil PWA: relevamiento GPS de campo, **captura cruda + pre-fill GPS automático**, sincronización offline |
| https://lemeit.github.io/DVBA/caminos_secundarios.html | `caminos_secundarios.html` | **v1.1** | Visor interactivo de red secundaria con filtros, hover tolerante, exportación CSV/reporte |
| https://lemeit.github.io/DVBA/docs/bitacora.html | bitácora unificada | v4.3 | Bitácora con tabs por temática (Resumen, Rutas/QGIS, Apps, Infraestructura, Decisiones, Pendientes, Changelog) |
| https://lemeit.github.io/DVBA/docs/guia_dvba_campo.html | guía de usuario | — | Manual de la app de campo |
| https://lemeit.github.io/DVBA/docs/MODELO_TIPOS_ESTADOS.md | doc técnica | v1.0 | Referencia del modelo Tipo↔Estado con árbol, matriz y guía de extensibilidad |

## Modelo Tipo ↔ Estado (desde v9.18 / v7.10 — junio 2026)

El sistema separa el registro vial en **3 dimensiones independientes** que se combinan según contexto:

| Dimensión | Definición | Ejemplo |
|---|---|---|
| **Elemento** | Qué objeto físico se está relevando | Calzada, señal, puente, banquina, luminaria |
| **Condición** | Cómo está ese elemento | Bueno · Regular · Malo · Crítico (varía por categoría) |
| **Acción** | Qué tarea se hizo o hay que hacer | Reconformado, desmalezado, bacheo |

El **árbol tiene 10 categorías** (8 de relevamiento + 1 de mantenimiento/tarea + 1 catch-all). Cada categoría tiene su **propio set de estados coherentes** + **estados universales de seguimiento** (`Pendiente`, `En obra`, `Reparado`).

### Sub-atributos condicionales
Aparecen automáticamente según la categoría:

- **Tipo de superficie** (Calzada, Mantenimiento): Asfalto · Hormigón · Tierra · Estabilizado · Mejorado con dolomita · Mejorado con suelo cal
- **Modalidad de tarea** (Mantenimiento): Manual · Mecánico · Mixto

### Cómo se implementa
- `dvba_tipos.js` — árbol de categorías + helper `categoriaDe(tipoStr)`
- `datos/dvba_estados.js` — modelo de estados por categoría + sub-atributos
- Función `onTipoChange(tipoStr)` en ambas apps que repuebla el `<select>` de estado y muestra/oculta los condicionales

Para el detalle completo (matriz Tipo→Estados, guía de extensibilidad, flujo en cada app), ver **[`docs/MODELO_TIPOS_ESTADOS.md`](docs/MODELO_TIPOS_ESTADOS.md)**.

---

## Sello DVBA en fotos (v3 — desde junio 2026)

Toda foto cargada en cualquiera de las dos apps se estampa con un sello institucional estilo **GPS Map Camera**, offline-first y con datos editables antes de aplicar.

### Layout v3 (3 columnas, banner DEBAJO de la foto)

```
┌────────────────────────────────────────────────────┐
│              [FOTO ORIGINAL INTACTA]               │
├────────────────────────────────────────────────────┤
│ ┌────┐  Localidad                          ▣▣▣ ▣  │
│ │LOGO│  Ruta · Km                          ▣ ▣ ▣  │
│ │DVBA│  Tipo de incidencia                 ▣ ▣▣  │
│ └────┘  Lat / Long / Alt                   ▣▣ ▣   │
│         Fecha · Hora                       ▣▣▣ ▣  │
└────────────────────────────────────────────────────┘
   logo    texto blanco grande               QR Google Maps
```

- La foto **queda 100% intacta** — el banner es un footer agregado debajo (no la tapa).
- Logo institucional DVBA a la izquierda, centrado vertical.
- Texto blanco en el centro con sombra sutil para nitidez.
- **QR a la derecha** apuntando a `https://www.google.com/maps/search/?api=1&query=LAT,LNG` — escaneable desde cualquier app de cámara, abre Google Maps con un pin **exacto** en la coordenada.

### Modal editable

Antes de estampar, se abre un modal con los datos pre-poblados:

| Campo | Origen automático | Editable |
|---|---|---|
| Localidad | Partido + Provincia + País | ✓ |
| Ruta / Camino · Km / Progresiva | Form | ✓ |
| Tipo de incidencia / relevamiento | Form | ✓ |
| Lat / Lng | GPS o form | ✓ |
| Fecha / Hora | Sistema | ✓ |
| Altura | GPS (`gpsAlt`) | ✓ |

Botones: **"Aplicar y guardar"** o **"Sin sello"** (sube la foto original).

### QR Code offline

Implementación vanilla JavaScript en `datos/qrcode.min.js` (~14 KB, sin dependencias externas, basada en qrcode-generator de Kazuhiko Arase). Genera el QR como matriz de píxeles y se pinta en el canvas — funciona 100% sin conexión.

### Política de versionado del sello

- **Tweak cosmético** (fuente, color, posición): solo bump de `sw.js` con sufijo letra (`v9.18` → `v9.18a` → `v9.18b`...). El span del footer queda igual.
- **Cambio publicable** (feature, fix funcional): bump de los 3 — `APP_VERSION` en `index.html`, `<span id='app-ver'>` en `dvba_campo.html`, `CACHE_NAME` en `sw.js`.

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
├── datos/                  ← Bundles JS por ruta + módulos compartidos
│   ├── rutas.js            ← Índice maestro
│   ├── rutas_rp40.js       ← RP40 — completa (cadena + anchors + 5 mojones físicos + 37 sintéticos + 3 gaps)
│   ├── rutas_rp30.js  rutas_rp41.js  rutas_rp46.js  rutas_rp51.js  rutas_rp91.js  …
│   ├── auth.js             ← Módulo Supabase Auth compartido entre apps
│   ├── dvba_estados.js     ← Modelo de estados por categoría + superficies + modalidades (v9.18)
│   ├── qrcode.min.js       ← Librería QR vanilla JS para el sello (sin dependencias, ~14 KB)
│   └── img/                ← Logos e íconos institucionales (logo_dvba_circular.png ← usado en sello)
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
│   ├── MODELO_TIPOS_ESTADOS.md         ← Referencia del modelo Tipo↔Estado (v9.18)
│   ├── HANDOFF_caminos_secundarios.md
│   ├── SETUP_AUTH.md                   ← Guía de configuración Supabase Auth
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

## Workflow campo → oficina (desde v9.19 / v7.14)

Cambio de paradigma en el flujo de captura+sellado de fotos:

```
   📱 CAMPO                         🏢 OFICINA
   (móvil PWA)                       (escritorio)
   ─────────                         ─────────
   Operador toma foto                Revisor logueado ve:
   GPS pre-llena ruta/km/partido     🔔 X pendientes en header
   Datos cargados al form
   ↓
   Foto cruda + datos →  Supabase →  Modal cola con:
   estado_workflow='campo'           - Foto thumb
   sello_version=NULL                - Datos cargados
                                     - Armonización en tiempo real:
                                       sugerencias del sistema
                                       basadas en GPS vs cartografía
                                     ↓
                                     [✅ Aprobar] / [✏ Editar] / [✕ Rechazar]
                                     ↓
                                     Al aprobar:
                                     1. Acepta sugerencias del armonizador
                                     2. Genera sello v3 con datos finales
                                     3. storage.update() reemplaza foto cruda
                                     4. estado='aprobado' · sello_version='v3'
```

### Armonización geoespacial (`datos/armonizador.js`)

100% offline (sin red). Usa los GeoJSON de partidos + bundles de RPs cacheados localmente para:

- **Point-in-polygon**: detecta el partido correcto desde lat/lng
- **Proyección + haversine**: encuentra la RP más cercana y calcula la progresiva real interpolada con anchors de mojones físicos
- **Umbrales adaptativos**: tolerancia se ajusta automáticamente según precisión del GPS (`gpsAcc`). GPS preciso → umbral estricto; GPS impreciso → umbral laxo

Resultado por registro:

| `validado_geo` | Significado |
|---|---|
| `auto_ok` | Datos coinciden con GPS — aprobable en batch |
| `auto_corregido` | El revisor aceptó las sugerencias del sistema |
| `usuario_priorizado` | El revisor mantuvo lo cargado a pesar de las sugerencias |
| `gps_sospechoso` | Coordenadas fuera de Zona VI — requiere revisión manual |
| `pendiente` | Hay sugerencias por revisar |
| `sin_coords` | Sin lat/lng |

### Badges visuales en sidebar de registros (escritorio)

Cada item muestra de un vistazo su estado en el workflow:

- ⏳ **EN REVISIÓN** (naranja) — en cola, pendiente del revisor
- ✓ **APROBADO** (verde) — sellado v3 aplicado
- 📜 **HISTÓRICO** (gris) — registros viejos con sello v2 (no re-sellables)
- ✕ **RECHAZADO** (rojo, tooltip con motivo)

Para detalles técnicos completos (5 columnas BD agregadas, lógica de umbrales, fases de implementación), ver la **[bitácora — Tab Changelog](docs/bitacora.html)**.

---

## Convención institucional

Denominación oficial en todos los documentos y apps: **"Zona Departamental VI Saladillo"** o abreviado **"Zona VI Saladillo"**. NUNCA "Delegación Saladillo".

---

**Responsable:** Ing. Luciano Lamaita — División Técnica DVBA Zona VI
