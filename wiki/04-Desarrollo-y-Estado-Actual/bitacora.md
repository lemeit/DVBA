═══════ HEADER ═══════

# 📋 Bitácora del Proyecto · Sistema de Relevamiento y Gestión Vial

DVBA · Departamento Zona VI Saladillo

Última actualización: 12 de agosto de 2026

Versión bitácora: v5.1 — apps v9.94 / v8.67 · 12-ago-2026

Responsable: Ing. Luciano Lamaita

Repositorio: [github.com/lemeit/DVBA](https://github.com/lemeit/DVBA)

Estado general: 🟢 En desarrollo activo

═══════ TABS ═══════

═══════════════════════════════════════════════════════════════════

TAB 1 · RESUMEN

═══════════════════════════════════════════════════════════════════

## Descripción del Proyecto

Sistema web de relevamiento, cartografía y gestión de la red vial provincial a cargo de la **Departamento Zona VI** de la Dirección de Vialidad de la Provincia de Buenos Aires (DVBA), con sede en Saladillo. Cubre **8 partidos**, **15 rutas provinciales pavimentadas** y la red de caminos secundarios no pavimentados.

El sistema está compuesto por dos aplicaciones complementarias y una infraestructura QGIS + Python detrás:

🖥 App Escritorio ·

index.html

Mapa Leaflet interactivo, cálculo de progresivas, sidebar de registros con buscador y paginación, reportes PDF/CSV. Hosting en GitHub Pages.

📱 App Móvil PWA ·

dvba_campo.html

Toma de registros de campo con GPS, foto sellada y sincronización con Supabase. Cola offline en IndexedDB. Instalable en Android.

## Contexto Institucional

| Atributo | Detalle |

|---|---|

| Organismo | DVBA — Dirección de Vialidad de la Provincia de Buenos Aires |

| Zona | Departamento Zona VI — sede Saladillo |

| Partidos cubiertos | Saladillo, Gral. Alvear, Gral. Las Heras, Lobos, Roque Pérez, Las Flores, Navarro, 25 de Mayo |

| Red vial | 15 rutas provinciales pavimentadas + red de caminos secundarios |

| Nomenclatura oficial | Manual de Señalamiento Vertical MSV 2017 (DNV/AAC) — fuente primaria para tipos de registro |

| Denominación oficial | **"Departamento Zona VI Saladillo"** o "Zona VI Saladillo". Nunca "Delegación Saladillo". |

## Stack Técnico

| Herramienta | Versión | Rol |

|---|---|---|

| QGIS | 3.42.0 Münster | Edición, limpieza y análisis espacial de capas vectoriales |

| Leaflet.js | 1.9.4 | Mapa interactivo (escritorio + tests) |

| Python | 3.12 | Scripts de reconstrucción de cadenas y generación de bundles JS |

| Supabase | Free tier | Backend de registros de campo: PostgreSQL + Storage + REST. Keepalive vía GitHub Action. |

| GitHub Pages | — | Hosting estático del sistema (HTTPS gratuito) |

| Service Worker + IndexedDB | — | Cola offline + sync automático en la app de campo |

| Overpass Turbo / OSM | — | Descarga auxiliar de trazas para verificación |

| QuickMapServices | plugin QGIS | Fondo Google Hybrid para digitalización de gaps |

## Estado por Ruta

| Ruta | Cadena GeoJSON | Mojones | Bundle JS | Notas |

|---|---|---|---|---|

| **RP 40** | ✓ | 5 físicos + 37 sintéticos | rutas_rp40.js | Gaps Salado (×2) + 25 de Mayo (×2). Bundle más completo del sistema. |

| RP 30 | ✓ | ✓ | rutas_rp30.js | — |

| RP 41 | ✓ | ✓ | rutas_rp41.js | — |

| RP 46 | ✓ | ✓ | rutas_rp46.js | — |

| RP 51 | ✓ | ✓ | rutas_rp51.js | — |

| RP 91 | ✓ | ✓ | rutas_rp91.js | — |

| RP 6, 20, 24, 42, 43, 44, 48 | pendiente | pendiente | pendiente | 7 rutas restantes para completar las 15 de Zona VI (RP 47 y 61 completadas) |

═══════════════════════════════════════════════════════════════════

TAB 2 · RUTAS Y QGIS

═══════════════════════════════════════════════════════════════════

## Línea de Tiempo · Trabajo sobre RP 40

12 abril 2026 · Sesión 1

Inicio del proyecto · Tipos MSV y UI de registro

- Definición del alcance: mapa interactivo con progresivas + app de campo.

- Análisis del MSV 2017 (290 pp.) para extracción de nomenclatura oficial de señales viales.

- Rediseño del selector: de dropdown único a selector jerárquico `Familia → Tipo → Código MSV`.

- Armonización de `dvba_tipos.js` con las 3 familias MSV: Reglamentarias (R-), Preventivas (P-), Informativas (I-).

- Corrección de progresivas RP40: bug en `proj()` y `acumEnCadena()` — búsqueda sin restricción de rango causaba proyecciones incorrectas en la curva del Salado.

12–15 abril 2026 · Sesiones 2–3

Sidebar, paginación y análisis inicial RP40

- Fix sidebar: `regs.slice(0,30)` cortaba la lista — implementado buscador de texto + paginación 30 por página.

- Botón ✏ Editar agregado al popup del marcador en el mapa.

- Descarga de RP40 desde Overpass Turbo (query por bbox) como fuente auxiliar.

- Comparativa: SHP Oficial Provincia (957 pts, 179.4 km) vs Overpass/OSM (561 pts, 173 km).

- Análisis de gaps RP40: gap zona urbana 25 de Mayo (~16.3 km línea recta, ~22-24 km recorrido real).

- Flujo QGIS documentado: Filtrar → Corregir geometrías → Multiparte a monoparte → Disolver.

15–18 abril 2026 · Sesiones 4–6

Reconstrucción de cadena RP40 y generación de

rutas_rp40.js

- Identificación de features duplicadas en la capa original (14 features, 346 km — doble de lo esperado).

- Diagnóstico: cada partido había registrado los mismos tramos por separado — features de distintos municipios con geometría idéntica.

- Reordenamiento geográfico de 4 features (F3→F2→F1→F0, este→oeste).

- Generación de cadena Zona VI: **957 puntos, 183.027 km**, orientada este→oeste.

- **Anchors calibrados:** km50 acc=22.953, km100 acc=73.079, km150 acc=132.667, km200 acc=180.720.

- Error sistemático de ~-27 km en verificación: *correcto y esperado* — la cadena empieza en progresiva ~29.4 km.

- Generación del bundle `rutas_rp40.js` (cadena + anchors + mojones + gaps).

18–20 abril 2026 · Sesión 7

Arquitectura modular + mojones sintéticos + test de integración

- Análisis de `rp40_unificada_congaps.geojson` (1710 pts, traza completa) y `mojones_rp40_ajustados.geojson` (5 mojones ajustados a la traza).

- Clasificación de 3 gaps: `gap_salado` (acum 104.6→110.4 km, cruce Río Salado sin puente) + dos tramos en zona urbana de 25 de Mayo.

- Generación de **37 mojones sintéticos cada 5 km** interpolados sobre la traza real (km30 a km210).

- Arquitectura final: cada ruta = un bundle `datos/rutas_rpXX.js` independiente.

- Test de integración `tests/test_rp40.html`: capas toggle, clic→progresiva, selector de paso para mojones sintéticos.

21–30 abril 2026 · Sesiones 8–10

Procesamiento batch del resto de rutas Zona VI

- Generación de bundles para **RP 30, 41, 46, 51, 91** siguiendo el flujo estándar.

- Limpieza extrema de SHP RP44 con corrección unificada de coordenadas.

- Diagnóstico y corrección masiva de capas: campos, atributos, sincronización entre capas.

- Tests de integración para todas las rutas procesadas.

6 mayo 2026 · Reorganización monorepo

Reestructuración del repositorio

- Migración de `C:\DVBA\app\` (clon antiguo) a `C:\GitHub\DVBA\`.

- Adopción de estructura monorepo: `datos/ scripts/ docs/ tests/ archivo/ geojson_procesados/`.

- Renombrado `dvba_zona6.html → index.html` para que GitHub Pages lo sirva como home.

- Centralización de ~50 scripts Python QGIS en `scripts/`.

- Bitácora unificada reemplaza las dos versiones anteriores (con tabs por temática).

6 mayo 2026 · Fixes técnicos · v9.0

Tests, manifest PWA, Service Worker

- Tests `test_rpXX.html`: paths corregidos a `../datos/` tras el cambio a subcarpeta `tests/`.

- `manifest.json` mejorado: íconos `any` y `maskable` separados (4 entradas), `display_override`, `id`, `categories` — soluciona instalación PWA en Android.

- `sw.js v3.0`: filtra schemes no cacheables (`chrome-extension://`, `data:`, `blob:`, `file:`) que rompían `cache.put()`.

- Filtro de respuestas no-basic (opaque/redirects) en cache para evitar excepciones.

6 mayo 2026 · Versionado centralizado · v9.1

Script bump_version + sw.js network-first

- `scripts/bump_version.py`: nuevo script que sincroniza la versión en 5 ubicaciones (footer campo, var JS, comentario, header escritorio, CACHE_NAME del SW). Comando único: `python scripts/bump_version.py v9.X`.

- `dvba_campo.html` footer: reemplazado `v6.1` hardcoded por `<span id="app-ver">` dinámico.

- `dvba_campo.html` JS: `APP_VER='v...'` (placeholder bug) corregido a versión real (sello de fotos).

- `index.html`: `APP_VERSION` de `'v6.8.0'` a `'v9.1'`.

- `sw.js v3.1`: estrategia cambiada de cache-first a **network-first con offline fallback + auto-purge de 404**. Resuelve URLs fantasma cuando se eliminan archivos del repo.

7 mayo 2026 · UX y PWA · v9.2

Botón install, fix menú mobile, "Desarrollado por"

- Botón **flotante "📲 Instalar app"** en `dvba_campo.html` usando `beforeinstallprompt`. Detecta automáticamente si la app ya está instalada (display-mode standalone) y se oculta. En iOS muestra instrucciones manuales.

- **Fix bug menú hamburguesa mobile** en `index.html`: el JS agregaba la clase `mob-open` al overlay y `vis` al botón cerrar, pero el CSS esperaba `visible`. Resultado: el panel se abría pero no había forma de cerrarlo (overlay invisible, botón × oculto). Corregido el mismatch.

- Header escritorio: agregado "**Desarrollado por** Ing. Luciano Lamaita · vX.Y".

- Footer campo: agregado "**Desarrollado por** Ing. Luciano Lamaita · vX.Y" reemplazando el formato anterior.

- **Guía de uso de la app de campo** reescrita y actualizada (`docs/guia_dvba_campo.html`): incluye los 11 categorías × ~90 tipos MSV 2017, instrucciones de instalación Android/iOS/desktop, flujo del wizard de 4 pestañas, modo offline, problemas frecuentes. La versión vieja se archivó en `archivo/guias_historicas/`.

10-15 mayo 2026 · Procesamiento de rutas pciales con orden por fid

Refactor gen_ruta_bundle.py v2.6 y corrección de progresivas

- `scripts/gen_ruta_bundle.py` v2.6: nueva flag `--order-by {fid,mojones,proximity}` (default `fid`). El bucle ahora ordena estrictamente por columna `fid` ascendente — la traza nace en `fid=1` y crece según fid creciente, sin invertir segmentos.

- Atributo `es_gap` respetado en cada tramo; su distancia suma al acumulado total aunque sea un salto.

- **Fix prog_ini negativo**: cuando hay mojón km 0 anclado al inicio de la traza, `prog_ini` se fuerza a 0 (antes promediaba todos los anchors y eso arrastraba desfasajes espurios cuando había gaps largos).

- RP40 regenerada a mano en QGIS con 6 features fid 1→6, 2 gaps reales (25 de Mayo, Pedernales↔N. Riestra). **248,6 km, progIni=0**.

- RP91: estaba invertida por auto-flip del v2.5. Reprocesada: Saladillo (km 0, intersección RP51) → Las Flores (intersección RP61). 51,6 km, progIni=0.

- Tests: `_template.html` arreglado con `lyMF.eachLayer(l => l.bringToFront && l.bringToFront())` (antes `lyMF.bringToFront()` lanzaba TypeError porque LayerGroup no tiene ese método). El error rompía todos los handlers de mousemove/click → panel de progresivas no respondía.

17-19 mayo 2026 · Caminos Secundarios DVBA Zona VI

Nueva subruta caminos_secundarios.html + procesamiento red secundaria

- Nueva subruta `caminos_secundarios.html` (servida desde `/DVBA/`): mapa interactivo de los caminos secundarios provinciales de Zona VI con polígonos de partido como contexto.

- **Estructura de carpetas:**

`referencias/partidos_pba.json` — listado oficial ARBA
`scripts/calcular_longitudes_red_vial.py` — script Python que recalcula longitudes geodésicas WGS84 con `pyproj`
`datos/caminos_secundarios_PBA.geojson` — fuente canónica (1681 features de toda PBA)
`datos/partidos_zona_vi.geojson` — polígonos de los 8 partidos (extraídos de la constante `PARTIDOS_GEO` de `index.html` para compartir)
`geojson_procesados/red_secundaria/caminos_secundarios_NNN_final.geojson` — uno por partido, revisado a mano en QGIS

- Funcionalidad del mapa:
          
**Multi-select de partidos** con chips horizontales (toggle on/off + botones Todos/Ninguno)
**Filtros por CLASE** (Tierra / Pavimentado / Sin Abrir) con chips de color toggleables
**Toggle de límites de partidos** (capa de polígonos)
Click en tramo → popup Leaflet con info detallada + botón **Agregar/Quitar selección** (toggle)
Selección acumulada: agregar tramos con clicks sucesivos, ver totales por clase
Tabla lateral con agrupación por NOMENCLATURA, sub-filas por tramo, sincronización mapa↔tabla
Exportar a **CSV** (BOM UTF-8 para Excel) — selección o toda la vista filtrada
Botón **📊 Reporte** que abre ventana imprimible con resumen por partido + detalle por camino + firma DVBA
**Normalización defensiva en JS:** trata `NOMENCLATURA`/`NOMEMCLATURA` indistintamente, normaliza CLASE con typos comunes (`DE TIERRRA`, `TIERRA`, `PAV.`), fuerza `PARTIDO_NOMBRE` desde el código si viene como "Desconocido".

- **Partidos revisados a mano en QGIS:** 034 General Alvear, 058 Las Flores, 091 Roque Pérez, 093 Saladillo, 109 Veinticinco de Mayo. **Pendientes:** 041 General Las Heras, 062 Lobos, 075 Navarro (caen al fallback del dataset preliminar de PBA, marcados con ◌ en la UI).

- Documentación: `docs/HANDOFF_caminos_secundarios.md` con SQL de RLS, criterio de revisión, estructura, comandos.

19-20 mayo 2026 · Seguridad: login + RLS · v9.10 / v7.1

Supabase Auth con email/password + Row Level Security

- **Problema resuelto:** antes, cualquiera con el link a la app de campo o de escritorio podía crear, editar o borrar registros sin identificación. La `anon key` de Supabase estaba embebida en el JS público.

- **Nuevo módulo compartido `datos/auth.js`** con `login`, `logout`, `session` (auto-refresh), `token`, `user`, `fetchAuth` helper. Sesión en `localStorage['dvba_session']`.

- **App de campo (`dvba_campo.html` v9.10):** pantalla de login al abrir si no hay sesión. Badge usuario integrado en el header debajo del subtitle. Todos los fetches a Supabase (POST relevamiento, POST foto, sync de cola) usan `Bearer <access_token>` del usuario en vez de la anon key.

- **App de escritorio (`index.html` v7.1):** modal de login al iniciar. Después del login, `_supa.auth.setSession()` propaga el token al cliente Supabase SDK para que insert/update/delete/storage usen el token.

- **Sesión OFFLINE-tolerante:** el access_token de Supabase dura 1h pero el refresh_token dura típicamente 30 días o más. `session()` detecta cuando no hay red (`navigator.onLine === false`) y devuelve la sesión local aunque el access_token esté vencido. La app sigue funcionando logueada por días sin internet. Cuando vuelve la red, el próximo `session()` refresca transparente.

- SQL de políticas RLS y procedimiento documentados en `docs/SETUP_AUTH.md`:
          
`SELECT` público (anon + authenticated): la consulta del mapa sigue siendo libre.
`INSERT / UPDATE / DELETE` solo para usuarios `authenticated`.
Idem para `storage.objects` del bucket `relevamientos`.

- Usuarios se crean manualmente desde el dashboard de Supabase. Sign-up libre deshabilitado.

20 mayo 2026 · Fixes PWA offline · v9.10

Service Worker reconstruido + GPS offline + banner update

- **Fix sw.js truncado** (versión previa quedó cortada en `procesarCola`, lo que rompía "ServiceWorker script evaluation failed" y por ende todo el modo offline). Reconstruido a v3.4 con sintaxis validada por `node --check`.

- `CACHE_URLS` ahora son **relativas** (`./dvba_campo.html`) — antes eran absolutas (`/dvba_campo.html`) que en GitHub Pages bajo subpath `/DVBA/` daban 404 al instalar y dejaban el cache vacío.

- Cachea ambas variantes de URL principal: `./dvba_campo` y `./dvba_campo.html`. Fallback offline inteligente: si la URL es sin `.html` o solo `/DVBA/`, devuelve el `.html` cacheado.

- **Fix GPS bloqueado por reload del SW:** el listener `controllerchange` recargaba la app incluso en el primer install del SW. Si el GPS estaba arrancando, la app recargaba y el GPS reiniciaba desde 0 en loop. Ahora `controllerchange` ignora el primer install (cuando no había controller previo); solo recarga en updates reales.

- GPS tolerante a fix lento sin A-GPS: `maximumAge: 60s` (antes 3s), `timeout: 2 min` (antes 30s), `getCurrentPosition` inicial con `enableHighAccuracy:false` para fix rápido aproximado.

- **Banner de actualización funcional:** cuando hay SW nuevo en estado *waiting*, aparece banner verde "Hay una versión nueva" con botón Actualizar que dispara `postMessage('skipWaiting')` → `controllerchange` → reload automático.

21-22 mayo 2026 · Red secundaria — orden por tramo, sentido cardinal · v7.2

Reprocesamiento de caminos secundarios con orden real de tramos

- **Script `calcular_longitudes_red_vial.py`:** detecta los campos opcionales del GeoPackage (`temporal`, `long_inicial`, `lat_inicial`, `long_final`, `lat_final`) y los renombra a `TRAMO_NUM`, `LON_INI`, `LAT_INI`, `LON_FIN`, `LAT_FIN`. Los preserva en CSV, GPKG y GeoJSON output.

- Sort estable por `(PARTIDO, NOMEMCLATURA, TRAMO_NUM)`. Los partidos sin `temporal` cargado siguen funcionando con default 999.

- **Fix `PARTIDO_NOMBRE = 'Desconocido'`:** lookup de partidos ahora tolerante a int/string padded — antes `'041'` no matcheaba contra `numero = 41` y todos los features de ese partido salían "Desconocido". Ahora indexa por int, str y str padded a 3 dígitos.

- **Nueva función `direccionCardinal(latI, lonI, latF, lonF)`:** devuelve `'NO → SE'`, `'Oeste → Este'`, etc. según deltas de coordenadas. 100% offline, sin reverse geocoding.

- `caminos_secundarios.html`: popup ahora muestra sentido cardinal calculado en vez de coordenadas crudas. `Tramo n°` solo aparece si el camino tiene más de un tramo (antes se mostraba siempre).

- 041 (Gral. Las Heras) reprocesado con el orden correcto: tramo 1 PAVIMENTADO va antes que tramo 2 DE TIERRA.

- Bump cosmético `index.html v7.2` para forzar refresh de GitHub Pages y confirmar deploy del login opcional.

22 mayo – 3 junio 2026 · Datos · Reprocesamiento y expansión de caminos secundarios

Incorporación progresiva de caminos revisados por partido

- Camino **041-01** — tramos corregidos (Gral. Las Heras).

- Camino **075** incorporado completo.

- Camino **093-15** — cambios menores + fix de partición de tramos (Saladillo).

- Camino **062-10** — CAMBIO DE CLASE (registrado en el nomenclador local).

- Múltiples caminos reprocesados el 22 y 27 mayo con la nueva lógica de orden por `TRAMO_NUM`.

- Estado al cierre del período: se completó el ciclo de "levantar catastro de caminos por partido" para la mayoría de las localidades de Zona VI.

24 junio 2026 · Fixes puntuales del modelo Tipo↔Estado · sw v9.18a

normStr Unicode + modalidad/superficie implícitas

- **Fix `dvba_tipos.js → normStr()`:** el regex usaba caracteres Unicode literales (`̀-ͯ` = U+0300..U+036F) para limpiar tildes después de `.normalize('NFD')`. Esos caracteres no siempre se preservaban entre Windows/Linux/Mobile. Cambiado a `new RegExp('[\u0300-\u036f]', 'g')` que evita ambigüedad de codificación. También agregado `.replace(/\s+/g, ' ')` para colapsar espacios múltiples antes del trim.

- **Síntoma que curó:** `categoriaDe()` no encontraba match para tipos con acentos ("Desmalezado mecánico") → estado vacío en el dropdown móvil.

- **Nuevas funciones `modalidadImplicita()` y `superficieImplicita()` en `dvba_estados.js`:** detectan cuando el nombre del tipo ya incluye la modalidad/superficie:
          
`modalidadImplicita`: matches `\bmanual\b`, `\bmecánica?\b`, `\bmixt[oa]\b`
`superficieImplicita`: matches `\bdolomita\b`, `\bsuelo cal\b`, `\bcamino tierra\b` + reconformado, `\bhormigón\b`, `\basfáltic[oa]\b` + `riego asf`

- **Fix `onTipoChange()` en ambas apps:** si la categoría aplica superficie/modalidad Y está implícita en el nombre del tipo → oculta el selector pero *guarda el valor implícito* en el `<select>` (para que la metadata serializada lo capture igual).

- Bump: `sw.js CACHE_NAME 'dvba-campo-v9.18a'`. No se tocó `APP_VERSION` ni `<span id='app-ver'>` (es tweak, no release visible).

- Ver detalle actualizado en `docs/MODELO_TIPOS_ESTADOS.md` sección 4.1 "Sub-atributos implícitos".

julio 2026 · Consolidación · v9.19 – v9.70 / v7.10 – v8.0.1

Workflow oficina, subida directa de foto, roles multi-zona y app lite (resumen)

- **Workflow captura campo → aprobación oficina:** nuevas columnas `estado_workflow` (`'campo' | 'aprobado' | 'rechazado'`), `validado_geo`, `sello_version` en `relevamientos`. El sellado dejó de aplicarse en campo — la foto se sube cruda y se sella al aprobar en oficina. Módulo `datos/armonizador.js` hace pre-fill offline de ruta/prog/partido desde GPS con umbrales adaptativos según `gpsAcc`.

- **Integración caminos secundarios ↔ apps principales:** columna `tipo_via` (`'rp' | 'camino'`) en `relevamientos`. Nuevo módulo `datos/red_vial.js`. Toggle RP/Camino en móvil, tabs en escritorio, layers en el mapa. Interpolación progresiva→coords para caminos con `pdInterpolarCamino` (v7.91).

- **Módulo Reportes (`reportes.html`):** 4 charts (km por tarea, timeline, uso vehículos, acciones por vía), filtros en vivo, export CSV + PDF institucional con jsPDF + autotable.

- **Sello v4:** banner compacto, versión inline en el pie, 3 columnas (logo · texto · QR Google Maps), extraído a módulo compartido `datos/sello_v4.js` (v7.89) usado por app móvil y por la subida directa desde `partes_diarios.html`.

- **Subida directa de foto desde partes_diarios (v7.89-91):** input file → lee GPS del EXIF con `exifr` → sella con sello v4 → sube a Storage → INSERT en `relevamientos` como aprobado → vincula al parte vía `parte_fotos`. Fallback: si no hay EXIF, la progresiva tipeada se interpola sobre el bundle de la RP o el geojson del camino.

- **App móvil lite (`dvba_campo_lite.html` · v9.59-70):** UI minimalista solo con botón "Sacar foto" + GPS. Todo lo demás lo completa alguien en oficina. Es el `start_url` del `manifest.json` (default al instalar la PWA). Auth offline via JWT cacheado, gestión de pendientes, cierre de sesión desde Info.

- **Bloque Roles Multi-zona (Fase 1 + 2 · v7.92-8.0.1):**

SQL 7: tabla `usuarios_perfil` con CHECK `rol↔zona`, funciones helper `current_user_zona()` y `current_user_rol()` (SECURITY DEFINER STABLE).
SQL 8: columna `zona` en `partes_diarios` y `relevamientos`, backfill a `'VI'`, view `v_partes_diarios_export` con columna Zona.
Módulo compartido `datos/perfil.js`: loader de `usuarios_perfil` al login + helpers `zonaActual()`, `esGerenciaOAdmin()`, auto-descarte de cache huérfano.
Fill automático de `zona` en INSERTs de partes y relevamientos en las 4 apps.
UI zone-aware: header muestra nombre del usuario, tooltip con rol + zona, picker de zonas oculto a técnicos (solo ven su zona), link "Reportes" oculto a técnicos, panel Visualización solo admin. Anti-FOUC con `data-solo-gerencia` + CSS default oculto.
Pendiente: Fase 3 SQL 9 RLS zonal, Fase 4 Panel Admin usuarios, Fase 5 PDF oficial Gerencia.

- **Nomenclatura "tarea" (v7.87):** pase completo *parte → tarea* en toda la UI visible de las 3 apps escritorio + docs (tabla y funciones internas mantienen `partes_diarios`/`pd*` por compatibilidad de código).

24 junio 2026 · v9.18a · Fixes modelo Tipo↔Estado

normStr Unicode + modalidad/superficie implícitas

- **Normalizador Unicode:** `normStr()` ahora aplica `NFD → strip combining marks` para que "Riego" == "riego" == "riegò". Fix bugs de match en autocomplete y en armonizador.

- **Sub-atributos implícitos:** cuando el nombre del tipo ya incluye modalidad ("Desmalezado mecánico") o superficie ("Mejoramiento con dolomita"), la UI oculta el selector correspondiente pero guarda el valor implícito automáticamente. Regex documentado en la sección 4.1 de `MODELO_TIPOS_ESTADOS.md`.

agosto 2026 · v8.53 – v8.58 / v9.91 · Convergencia UI + público

Header/footer unificados, portal público, aviso híbrido

- **Header/footer unificados** en los 4 portales escritorio con logo real de DVBA en Admin y subtítulo "SIG Vial PBAᵝ" en todos. Módulo `datos/legales.js` con 4 tabs (Acerca / Términos / Privacidad / Permisos PWA) auto-inyectado en 6 HTMLs.

- **Portal público sin login (v8.56 · SQL_12):** función `anon_ver_publico()` devuelve KPIs mínimos sin exponer datos personales. Portal abre en modo público por default con banner dismissible + botón `ℹ Alcance` en header.

- **Móvil sin "Zona VI" hardcoded (v9.91/v8.54):** el header muestra rol + zona real desde el perfil del user. Footer avanzado unificado con modal `DVBA_LEGAL`. Fix reportes.html: cambio de picker de zona ahora refetchea correctamente.

agosto 2026 · v8.59 – v8.62 · Fase A + B multi-zona

Reorganización datos/ + loader dinámico multi-zona

- **Reorganización `datos/`:** estructura `zonas/zona_XX/` (per-zona) + `rutas/` (bundles RP compartidos) + `referencias/` (masters PBA). Script `generar_zona_desde_master.py` filtra masters por zona.

- **Loader dinámico multi-zona (`datos/loader_zona.js`):** detecta zona por URL (`?zona=X`) → perfil técnico → default público PBA. Carga bundles RP + assets zonales vía `document.write` sincrónico. API `window.DVBA_ZONA` para consulta/cambio. Auto-redirect técnico → `?zona=X`.

- **Manifests IV Junín + V Chivilcoy:** pilotos con rps calibradas compartidas con VI (RP46, RP40, RP30, RP51, RP61). Corregidos según CSV oficial `rutas_partidos.csv`.

- **Catálogo `partidos_pba.json v2.2`:** 135 partidos oficiales (fixes ARBA: Ituzaingó #112→#136, Zona IX partido #48→#40) + campo `rutas[]` por partido + `zonas_dvba{}` con las 12 zonas y sus partidos.

agosto 2026 · v8.63a-h · Portal multi-zona real (bugfix cascada)

PARTIDOS_GEO dinámico + sidebar adaptativo + fixes

- **Frente A:** `PARTIDOS_GEO` reasignable, PBA default público, fitBounds automático por zona.

- **Frente B:** sidebar adaptativo — chips para zona específica, dropdown multi-select para PBA con 135 partidos. Fix normalización UPPERCASE → Title Case (shp master tenía "ADOLFO ALSINA").

- **Fixes cascada:** rutas zonales respetan `selR`; capas VI se limpian al cambiar zona; `cargarRegs` filtra por zona activa; `selR` arranca con TODAS las rutas activas en cualquier zona; `partesCargar` filtra `.eq('zona', X)` + fix `select('lat, lng')` (era latitud/longitud inexistentes → 400 Bad Request); labels partidos ocultos en PBA.

- **Bug crítico v8.63h:** `_reemplazarPartidos` limpiaba `capasP` sin `.flat()` — Leaflet ignoraba los `removeLayer(array)` y los polígonos viejos de VI quedaban en el DOM al cambiar de zona. Sombreado persistente resuelto.

agosto 2026 · v8.64 – v8.64.2 · Frente D · Paleta 12 zonas + clipping

Sombreado por zona, labels romanos, recorte cliente-side

- **Paleta institucional 12 zonas:** función `_colorZona(cod)` con 12 tonos armónicos gama neutra-azulada (sin saturaciones tipo circo). `_partidoAZona{}` cargado async desde `partidos_pba.json`. En vista PBA cada partido pintado con el color de su zona vial DVBA.

- **Labels romanos por zona:** función `_dibujarLabelsZonasPBA()` calcula el centroide de cada agrupación de partidos y pone el nº romano (I..XII) grande con opacidad 42% coloreado con el tono de la zona. Reemplazó la watermark inferior anterior.

- **Filtro tareas por partido→zona (v8.64.1):** defensa cliente-side en `partesDibujar`. Aunque el `.eq('zona', X)` SQL falle (datos legacy con zona=NULL), se descarta cualquier tarea cuyo partido pertenezca a otra zona.

- **Clipping cliente-side (v8.64.2):** las trazas de RP30/46/51 sobrepasaban la zona activa porque el shp master asigna un partido único por LineString pero la geometría se extiende a vecinos. Fix con ray-casting: `_recortarFeatureRuta()` parte cada polilínea en sub-tramos donde puntos consecutivos caen dentro de algún polígono de `PARTIDOS_GEO`. Rendimiento: ~9M ops = milésimas de segundo en desktop.

## Flujo de Trabajo por Ruta

Proceso estándar para incorporar cada nueva ruta:

1. En QGIS: Filtrar → Corregir geometrías → Multiparte a monoparte → Disolver → Exportar GeoJSON unificado.

2. Digitalizar gaps (cruces de río sin puente, zonas urbanas) sobre imagen satelital con snap activado.

3. Preparar capa de mojones ajustados (campo `Name`: "0KM", "50KM", etc.; campo `description`: sentido).

4. Ejecutar `python scripts/gen_ruta_bundle.py rpXX` → produce `datos/rutas_rpXX.js`.

5. Agregar `<script src="datos/rutas_rpXX.js">` al `index.html` y registrar en `datos/rutas.js`.

## Sistema de Progresivas

| Parámetro | Valor / Decisión |

|---|---|

| Método de cálculo | Haversine 2D — terreno llano, error <0.1% |

| Convención | DVBA/DNVB — progresiva acumulada sobre traza oficial |

| Mojón 0 RP40 | Intersección RP40/RP7, calles Moreno y Libertad, partido de Merlo (FFCC) |

| Inicio Zona VI RP40 | ~29.4 km real — intersección con RP6, partido de General Las Heras |

| Gaps | Progresiva acumula por recorrido real del tramo (no por línea recta) |

| Mojones físicos | Datos internos DVBA — posición GPS desde escritorio, *no medidos con odómetro*. Requieren verificación de campo. |

| Mojones sintéticos | Generados cada 5 km por interpolación sobre la cadena. Flag `en_gap:true` = posición aproximada. |

## Notas Técnicas Importantes

⚠ Precaución al editar

dvba_campo.html

El archivo contiene ~133 KB de JavaScript. Hacer regex replacements cerca del bloque

LOGO_SELLO

(base64) puede truncar silenciosamente el código. Siempre partir del backup conocido-bueno:

archivo/versiones/dvba_campo_BKFUNCIONAL.html

.

⚠ Error sistemático en verificación de mojones

El error de ~-27 km en todos los mojones es correcto y esperado. La cadena RP40 inicia en la progresiva real 29.4 km. La función

calcProg()

interpola correctamente entre pares

(km_real, acc_local)

y devuelve la progresiva oficial.

═══════════════════════════════════════════════════════════════════

TAB 3 · APPS WEB

═══════════════════════════════════════════════════════════════════

## App Escritorio · `index.html`

**Propósito:** mapa interactivo Leaflet con cálculo de progresivas, sidebar de registros (con buscador + paginación 30/página), reportes descargables PDF/CSV. Carga datos modulares por ruta vía `<script src="datos/rutas_rpXX.js">`.

**URL pública:** [lemeit.github.io/DVBA/](https://lemeit.github.io/DVBA/)

### Algoritmos clave

- **Haversine 2D** para cálculo de distancias entre puntos en la cadena.

- **Proyección a la cadena:** dado un punto cliqueado, encuentra el punto más cercano de la cadena y devuelve el acumulado local.

- **Interpolación de progresiva:** interpola linealmente entre los anchors `(km_real, acc_local)` calibrados con mojones físicos.

- **Detección de gaps:** compara `acc_actual` contra rangos `acc_desde / acc_hasta` de cada gap → muestra advertencia "Posición en gap".

### Bugs resueltos · Escritorio

- ✅ **Sidebar truncado:** `regs.slice(0,30)` mostraba solo los primeros 30 registros — reemplazado por buscador + paginación.

- ✅ **Tema oscuro:** migrado a paleta clara igual a la app de campo (header teal #009aae, fondo claro, popups Leaflet en claro).

- ✅ **Logo oficial:** reemplazo del logo rediseñado por el PNG oficial DVBA en header y sello de fotos.

- ✅ **Progresivas RP40:** bug en `proj()` que producía proyecciones incorrectas en la curva del Salado — corregido con restricción de rango.

## App Móvil PWA · `dvba_campo.html`

**Propósito:** aplicación web instalable en Android para relevamiento de campo. Wizard de 4 pestañas (Ubicación → Tipo → Foto → Confirmar). GPS continuo con `watchPosition`. Cámara via `getUserMedia` sin pasar por archivo. Sello institucional sobre la foto: logo circular + datos de ruta + GPS + timestamp. Cola offline en IndexedDB. Sincronización automática a Supabase al recuperar red.

**URL pública:** [lemeit.github.io/DVBA/dvba_campo.html](https://lemeit.github.io/DVBA/dvba_campo.html)

### Características clave

📍 GPS continuo

`watchPosition` con botón ↓ Usar para fijar la posición actual al registro.

📷 Cámara sin crash

`getUserMedia` directo a canvas, evita el crash RAM de `<input type="file" capture>`.

🏷 Sello v2 editable (GPS Map Camera style)

Modal pre-poblado con form + GPS + Plus Code + fecha/hora antes de estampar. Layout 2 columnas (texto izq + logo der). Editable campo por campo. Implementado en ambas apps (v9.15 / v7.7).

📡 Cola offline + sync

Registros pendientes en `IndexedDB.cola`. Service Worker dispara `BackgroundSync` al recuperar red.

### Sello v2 — diseño detallado (24 jun 2026)

Antes de estampar la foto se abre un modal de edición con todos los campos pre-cargados (Localidad, Dirección, Lat/Lng, Fecha, Hora, Altura, Plus Code, Ruta, Km, Tipo). El operador confirma o ajusta y recién entonces se imprime la banda inferior. Botón *"Sin sello"* sube la foto original.

🧮 Plus Code (Open Location Code)

Implementación vanilla JavaScript ~40 líneas, sin dependencias externas. Genera código completo de 10 caracteres válido offline. Se auto-recalcula al editar lat/lng en el modal.

🎨 Layout estilo GPS Map Camera

Banda inferior con gradient negro y línea superior dorada. Izquierda: 5 líneas (localidad dorada, dirección, lat/long+alt verde mono, plus code azul mono, fecha+hora+tipo). Firma institucional separada en italic dorado tenue. Derecha: logo institucional DVBA centrado vertical.

📐 Tipografía proporcional al ancho

`baseFont = max(14, min(W*0.018, 32))`. Antes era proporcional al alto, pero en fotos panorámicas las letras se veían chicas — el ancho es mejor proxy del espacio disponible. Text shadow sutil + JPEG quality 0.95 + imageSmoothing 'high' para nitidez.

🚫 Sin clima ni mini-mapa

Decisión explícita: la app debe funcionar 100% offline en campo. Solo GPS. Nada de tiles OSM ni APIs de clima — todo lo que aparece en el sello sale del GPS, el form o el operador.

### Bugs resueltos · Campo

- ✅ **Banner de actualización v(X-1)→vX:** Service Worker queda en "waiting" hasta que el usuario haga click en el banner → dispara `skipWaiting`.

- ✅ **Cola offline persistente:** `IndexedDB.dvba_campo` v9 con stores `cola` y `hoy`.

- ✅ **SW filtra schemes no cacheables:** en `v3.0/v3.1` se ignoran `chrome-extension://`, `data:`, `blob:` que rompían `cache.put()`.

- ✅ **Compatibilidad escritorio:** registros del campo se leen en escritorio con clave `dvba_z6v6`.

### Checklist por release de la app de campo

1. Bumpear `APP_VER='vX'` en `dvba_campo.html`.

2. Bumpear `CACHE_NAME='dvba-campo-vX'` en `sw.js`.

3. `git push`.

4. El banner de actualización **v(X-1)→vX** aparece automáticamente en los dispositivos de campo cuando se reabre la app.

## Backend · Supabase

Las apps usan **Supabase free tier** como persistencia en la nube:

- **PostgreSQL:** tabla `relevamientos` con los registros de campo.

- **Storage:** bucket `relevamientos` con las fotos selladas (`fotos/{timestamp}_{ruta}.sello.jpg`).

- **API:** REST con `anon key` embebida en el cliente. Insert vía `POST /rest/v1/relevamientos`, upload vía `POST /storage/v1/object/{bucket}/{path}`.

- **Keepalive:** GitHub Action `.github/workflows/supabase_keepalive.yml` hace ping periódico para evitar el sleep automático del free tier por inactividad.

⚠ Seguridad:

la

anon key

está embebida en

sw.js

y

dvba_campo.html

. Es la clave pública anónima de Supabase (no la

service_role

) — está pensada para ser pública en clientes, pero

las políticas RLS de Supabase deben estar bien configuradas

para que solo permitan INSERT y no SELECT/UPDATE/DELETE de otros registros.

═══════════════════════════════════════════════════════════════════

TAB 4 · INFRAESTRUCTURA

═══════════════════════════════════════════════════════════════════

## Estructura del Repositorio

```
C:\GitHub\DVBA\                        ← repo lemeit/DVBA
├── index.html                         ← App Escritorio (= ex dvba_zona6.html)
├── dvba_campo.html                    ← App Móvil PWA
├── dvba_tipos.js                      ← Selector jerárquico tipos MSV 2017
├── manifest.json  sw.js               ← PWA + Service Worker
├── icon-192.png  icon-512.png
│
├── datos/                             ← Bundles JS por ruta
│   ├── rutas.js                       ← Índice maestro
│   ├── rutas_rp30.js  rp40  rp41  rp46  rp51  rp91
│   └── img/                           ← Logos institucionales
│
├── scripts/                           ← Python (QGIS + bundle generators)
│   ├── gen_ruta_bundle.py             ← Generador de datos/rutas_rpXX.js
│   ├── build_campo.py                 ← Build de la app de campo
│   ├── Armonizar_mojones.py
│   ├── 01_procesamiento_rutas/        ← Cálculo progresivas, validación
│   ├── 02_analisis_topologia/
│   ├── 03_utilidades/                 ← Exploración SHP, gen mojones
│   ├── 04_reportes/
│   └── requirements.txt
│
├── geojson_procesados/                ← GeoJSONs intermedios listos
│   └── rp30  rp40  rp41  rp46  rp51  rp91 (unificada + mojones)
│
├── docs/                              ← Documentación
│   ├── bitacora.html (este archivo)
│   ├── guia_dvba_campo.html
│   └── guia_dvba_campo.pdf
│
├── tests/                             ← Tests integración por ruta
│   └── test_rp30  rp40  rp41  rp46  rp51  rp91 .html
│
├── archivo/                           ← Legacy y referencias
│   ├── versiones/                     ← Backups históricos HTMLs
│   ├── bitacoras_historicas/          ← Versiones previas de la bitácora
│   ├── dvba_zona6_bk2.html  _bx.html
│   └── servidor_http.py               ← Server local antiguo
│
└── .github/workflows/
    └── supabase_keepalive.yml         ← Mantiene viva la BD del free tier
```

## Carpetas Locales (FUERA del repo)

```
C:\DVBA_fuentes\                       ← Fuentes pesadas, no versionadas
├── qgis/
│   ├── proyecto_redes_viales.qgz
│   ├── 02_BASES_VECTORES/             ← SHP fuente (305 MB)
│   ├── 03_CAPAS_GENERADAS/            ← Capas procesadas
│   ├── 04_BACKUPS/  05_TABLAS/  06_RESULTADOS/
│   └── venv_redes_viales/             ← Virtualenv (regenerable)
└── osm/
    ├── argentina-260405.osm.pbf       ← OSM PBF Argentina (413 MB)
    └── caminos_saladillo.osm
```

## URLs de Acceso

| Recurso | URL |

|---|---|

| App Escritorio (home) | [lemeit.github.io/DVBA/](https://lemeit.github.io/DVBA/) |

| App Móvil PWA | [lemeit.github.io/DVBA/dvba_campo.html](https://lemeit.github.io/DVBA/dvba_campo.html) |

| Bitácora (esta) | [lemeit.github.io/DVBA/docs/bitacora.html](https://lemeit.github.io/DVBA/docs/bitacora.html) |

| Guía app de campo (textual) | [lemeit.github.io/DVBA/docs/guia_dvba_campo.html](https://lemeit.github.io/DVBA/docs/guia_dvba_campo.html) |

| Guía visual (mockups) | [lemeit.github.io/DVBA/docs/guia_visual_dvba_campo.html](https://lemeit.github.io/DVBA/docs/guia_visual_dvba_campo.html) |

| Guía app de campo (PDF) | [lemeit.github.io/DVBA/docs/guia_dvba_campo.pdf](https://lemeit.github.io/DVBA/docs/guia_dvba_campo.pdf) |

| Tests por ruta | […/tests/test_rp40.html](https://lemeit.github.io/DVBA/tests/test_rp40.html) (rp30, rp41, rp46, rp51, rp91 idem) |

| Repositorio | [github.com/lemeit/DVBA](https://github.com/lemeit/DVBA) |

## Flujo de Releases

Para actualizar la app de escritorio:

```
# Editar index.html, datos/rutas_rpXX.js, scripts/, etc.
git add .
git commit -m "Descripción del cambio"
git push origin main
# GitHub Pages publica en ~1-2 minutos
```

Para actualizar la app de campo (PWA):

```
# 1. Bumpear versión en dvba_campo.html (APP_VER='vX')
# 2. Bumpear versión en sw.js (CACHE_NAME='dvba-campo-vX')
# 3. git add dvba_campo.html sw.js manifest.json
# 4. git commit -m "v8 → v9: descripción"
# 5. git push origin main
# 6. Los celulares ven el banner v8→v9 al reabrir la app
```

## Histórico · Migración a GitHub Pages

Originalmente las apps corrían sobre **ngrok** (servidor local en la PC de la oficina + túnel HTTPS gratuito), iniciado con `servidor.bat`. Esto requería que la PC de la oficina estuviera siempre encendida y conectada.

En abril 2026 se migró a **GitHub Pages** para tener disponibilidad 24/7 con HTTPS gratuito y sin dependencia de hardware local. Los archivos legacy (`servidor_http.py`, `servidor.bat`, `ngrok.exe`, `ngrok-dvba.yml`) están conservados en `archivo/` por trazabilidad.

═══════════════════════════════════════════════════════════════════

TAB 5 · DECISIONES

═══════════════════════════════════════════════════════════════════

## Decisiones Técnicas Clave

### 1. Arquitectura modular por ruta DECISIÓN

Cada ruta = un archivo `datos/rutas_rpXX.js` independiente con su bundle (cadena + anchors + mojones + gaps). Permite editar una ruta sin tocar el HTML. GitHub Pages sirve todos los archivos estáticos. El HTML solo carga `<script>` tags.

### 2. Fuente de datos adoptada para RP40 DECISIÓN

SHP Oficial Provincia de Buenos Aires (a través de DVP / IGN), campo `fuente_geometria: "oficial_provincia"`. La fuente Overpass/OSM fue descartada para progresivas por peor alineación en km100 (error 3.4 km vs 0.07 km del oficial).

### 3. Representación de gaps DECISIÓN

Los gaps (cruce Salado, zona urbana 25 de Mayo) se digitalizan sobre imagen satelital y se incluyen en la cadena como tramos reales. La progresiva acumula por el recorrido real del gap (no por línea recta). Los tramos de gap se muestran en rojo punteado en el mapa.

### 4. Mojones · físicos vs sintéticos DECISIÓN

Los mojones físicos del organismo no fueron medidos con odómetro calibrado y algunos están fuera de la traza. Se mantienen como referencia interna pero requieren verificación de campo. Los **mojones sintéticos** (interpolados cada 5 km) son los que se usan para el cálculo de progresivas en la app. La generación de sintéticos reemplaza la fase de "Interpolate point on line" en QGIS.

### 5. Denominación institucional DECISIÓN

En todos los documentos y aplicaciones: **"Departamento Zona VI Saladillo"** o abreviado **"Zona VI Saladillo"**. Nunca "Delegación Saladillo" ni ninguna forma de "Delegación".

### 6. Estructura monorepo DECISIÓN · 6 may 2026

Un único repositorio `lemeit/DVBA` con subcarpetas `datos/ scripts/ docs/ tests/ archivo/ geojson_procesados/`. Las fuentes pesadas (proyecto QGIS, SHP fuente, OSM PBF, virtualenv) viven en una carpeta hermana `C:\DVBA_fuentes\` fuera del repo. Esta separación mantiene el repo liviano (~2.4 MB) y facilita el sync con GitHub.

### 7. Renombrado de `dvba_zona6.html → index.html` DECISIÓN · 6 may 2026

La app de escritorio quedó como `index.html` en la raíz, lo que la convierte en la home automática de GitHub Pages: `lemeit.github.io/DVBA/` abre directo la app. La URL antigua `…/dvba_zona6.html` deja de funcionar.

### 8. Paths sin caracteres especiales DECISIÓN OPERATIVA

El usuario tiene su carpeta de Windows como `C:\Users\Of. Técnica Z6\` — espacio + tilde + punto rompen scripts Python y herramientas. Por eso el repo vive en `C:\GitHub\DVBA\` y las fuentes pesadas en `C:\DVBA_fuentes\`, ambos en la raíz de C: con nombres limpios.

### 9. Service Worker network-first DECISIÓN · 6 may 2026

La estrategia original del SW era *cache-first*, que servía contenido viejo aún después dal del SW era *cache-first*, que servía contenido viejo aún después de eliminar archivos del repo (URLs fantasma como `/dvba_zona6`). Se cambió a **network-first con offline fallback + auto-purge de 404**: siempre se intenta la red primero; si responde 404 se borra la entrada del caché; si la red falla se sirve el caché o un mensaje 503 amigable. La PWA sigue funcionando offline porque el caché se sigue manteniendo, solo cambia la prioridad de lectura.

### 10. Versionado independiente por artefacto DECISIÓN · 7 may 2026

Cada artefacto del proyecto (app campo, app escritorio, guía, bitácora) tiene su propia versión y su propio ciclo de vida. La consistencia entre versiones **no se fuerza**. El script `scripts/bump_version.py` permite bumpear cada artefacto por separado: `python scripts/bump_version.py campo v9.3`. Para casos puntuales hay `todos vX.Y` que sincroniza todo.

═══════════════════════════════════════════════════════════════════

TAB 6 · PENDIENTES

═══════════════════════════════════════════════════════════════════

✅ Actualizado a v7.75 · 13 julio 2026.

El grueso de los pendientes históricos ya está resuelto (sello v3, caminos integrados, mudanza C:\DVBA, RLS Supabase). Los nuevos ejes son

reportes PDF oficiales

,

capa de partes en el mapa

,

escalado multi-zona

, y

completar las RPs faltantes en QGIS

.

## 🔴 Alta Prioridad

- **Módulo Reportes (Bloque 3 · Sesión 3)**: dashboard con métricas + reporte oficial DVBA en PDF con layout institucional (portada, resumen ejecutivo, tabla de tareas por partido, gráficos de barras, tabla luminarias LED, anexo fotográfico). Pendiente confirmar layout con adjunto del user. Es lo que faltaría para "presentación Gerencia".

- **Capa de partes en el mapa del portal (v7.76 planeado)**: nueva capa toggleable en `index.html` sobre panel Capas. Cada parte se dibuja como polyline del tramo `prog_ini↔prog_fin` sobre la traza RP + pin en el punto medio. Partes con foto usan el punto del relevamiento asociado. Sin foto: polyline gruesa + pin gris (necesita agregar columnas `lat`/`lon` o computar on-the-fly).

- **[SQL] Correr `SQL_5_rls_partes_flexible.sql` y `SQL_6_partido_en_partes.sql`** en Supabase antes del próximo test end-to-end del portal Plan de Seguridad. El primero fixea el 403 al guardar; el segundo agrega columna `partido` y actualiza la view de export.

- **Regenerar RP30 y RP46** con calma en QGIS (task #195): el `_traza_completa` original tenía zigzag / mala longitud. Requiere revisar el orden geográfico de fids uno a uno antes de re-correr `gen_ruta_bundle.py`.

- **Documentar bitácora entradas v7.62 → v7.75**: sprint de módulo Partes Diarios (renombrado a "Plan de Seguridad en la Circulación"), detección automática de partido, dropdown único + typeahead nativo, sidebar-footer institucional, plan de roles multi-zona. Ver commits del 13/7.

## 🔵 Media Prioridad

- **Completar las 7 RPs restantes en QGIS**: RP 6, 20, 24, 42, 43, 44, 48 (de las 15 de Zona VI). Sin bundle procesado no hay detección de partido ni progresivas oficiales para estas rutas — el badge de v7.75 ya avisa "(ruta sin traza cargada — pendiente de procesar en QGIS)".

- **Detección de partido en app móvil** (`dvba_campo.html`): replicar `pdDetectarPartido` + `pdInterpolarProgresiva` del portal Plan de Seguridad usando el mismo `datos/partidos_zona_vi.geojson` y los bundles CHAIN. Reutilizar helpers `_pdGetChainRP` (patrón `typeof`, no `window`).

- **Backfill columna `partido`** en los 632 partes históricos migrados. Un script Python + Supabase que corre point-in-polygon offline sobre las progresivas medias. O SQL con extensión PostGIS si está habilitada.

- **Fase 1 del Plan de Roles** (ver `docs/PLAN_ROLES_MULTIZONA.md`): crear tabla `usuarios_perfil`, columna `zona` en tablas operativas, funciones helper `current_user_zona()` / `current_user_rol()`. Preparación para Fase 3 (RLS zonal).

- **Verificación de campo** de mojones físicos con GPS calibrado (los actuales son datos internos no medidos con odómetro). Pendiente crónico — buena candidata para piloto colaborativo con Zona VII cuando arranquemos multi-zona.

- **Completar historial v9.10 → v9.15 / v7.1 → v7.7** en el changelog. Reconstruir desde `git log`.

- **Renombrar CACHE_NAME del SW** (task #153): actualmente `dvba-campo-vX.Y` aunque cachea AMBAS apps (móvil + escritorio). Confuso.

## ⚪ Baja Prioridad / Futuro

- **Debounce del `oninput`** del selector de ruta y progresivas: mientras el user tipea "RP 91" pasa por estados intermedios ("RP 9", "RP") que generan warnings en consola. Inofensivo pero se puede pulir.

- **Ocultar del datalist las RPs sin bundle procesado** (o marcarlas visualmente como "no operativas") hasta que se resuelvan en QGIS.

- **Panel Admin de usuarios** (Fase 4 del Plan de Roles): página `admin_usuarios.html` con alta/baja/cambio de rol.

- **Reportes PDF oficiales DVBA** (Fase 5 del Plan de Roles): stack probable `jsPDF + jsPDF-autotable` client-side o Edge Function con `pdf-lib`. Bloqueado hasta que el user comparta el adjunto de referencia.

- **Catálogo caminos editable** (task #126): UI de escritorio + tabla Supabase para editar nombres locales sin tocar código.

- **Reportes de caminos secundarios en tab Reportes** (task #125): F5.

- **Edición fotos post-captura en escritorio**: reubicar el pin + re-sellar (task #202).

- **Piloto TMD** (Tránsito Medio Diario) con cámara de video en rutas seleccionadas.

- Integración con **acelerómetro RURAL IT** para condición de pavimento.

- Medición **V85** (velocidad percentil 85) con LIDAR del colega.

- Integración con sistema de despacho de cuadrillas.

## ✅ Resueltos recientemente (referencia)

- Sello v3 con QR Google Maps → *completado v7.8+*.

- Integrar caminos secundarios al portal → *completado v7.15–v7.45*.

- Mudanza `C:\DVBA\` + `C:\GitHub\DVBA` → *hecho, ver memoria feedback_paths*.

- Módulo Partes Diarios / Plan de Seguridad en la Circulación → *desarrollado v7.62–v7.75*.

- Detección automática de partido en carga → *v7.70 (SQL_6) + v7.75 (fix bundles)*.

- RLS Supabase documentada + flexibilizada para uso interno → *v7.69 (SQL_5)*.

- Doc `PLAN_ROLES_MULTIZONA.md` con 4 niveles y roadmap 5 fases → *v7.73*.

- Convención versionado unificado escritorio (index + partes juntos) → *v7.71 en adelante*.

## 📋 Changelog · Apps

| Artefacto | Versión | Archivo(s) | Bumpear con |

|---|---|---|---|

| **📱 App Campo (PWA unificada)** | v9.88 | `app.html` (router) + `dvba_campo_lite.html` (Modo Básico) + `dvba_campo.html` (Modo Avanzado) + `sw.js` | Manual: `APP_VER` en HTMLs + `CACHE_NAME` en `sw.js` |

| **🖥 Familia escritorio** | v8.52 | `index.html`, `partes_diarios.html`, `reportes.html` + módulos `datos/` | Manual en `const APP_VERSION` + spans footer en los 3 |

| **🎨 Módulo sello v4** | unificado | `datos/sello_v4.js` + `datos/exif_writer.js` + `datos/piexif.min.js` | Auto: cualquier fix impacta portal + partes + móvil sin re-bumpear |

| **🛣 Caminos Secundarios** | v1.1 | `caminos_secundarios.html` | — |

### v8.67 / v9.94 · 12 agosto 2026 — Presets tamaño sello + fix doble sello + versión reubicada

Cierre de la serie **v8.66f (7 hotfixes iterativos)** sobre `datos/sello_v4.js` + portal + móvil. Origen: fotos donde el banner del sello tapa detalles críticos (puentes, defectos en el pie de la foto). Resuelto sin romper el diseño base para el resto de las fotos.

**Presets de tamaño** — el modal "🖋 Editar datos del sello" (aprobación) y el sidebar de edición ahora tienen 3 botones **🖋 Normal (100%) / 🖋 Mediano (75%) / 🖋 Mínimo (50%)**. Reemplazan al slider intermedio de v8.66f-f.2 que confundía al user (quedaba pegado en el último valor entre fotos). El preset se resetea a Normal al abrir cada foto.

**Fix doble sello real** — al re-sellar con escala < 100% sobre foto sellada sin backup limpio, quedaban 2 banners superpuestos porque `sello_v4` no cortaba el banner viejo si no detectaba la línea dorada (compresión JPEG, rotación, o sello del móvil). Nuevo fallback ASUMIDO: si no aparece la línea, recorta la altura por defecto del banner al 100% (`max(160, min(W*0.16, 270))`) — ciego pero determinístico.

**Versión reubicada** — el string `vX.X·origen · sello v4` (dorado transparente) pasó de la columna central (donde se pisaba con el texto principal en fotos con localidad larga) a **centrado debajo del QR en la columna derecha**. QR reducido a 0.72·bH y anclado al top del banner para dejar ~22% de altura libre debajo.

**Fix crítico fecha recortada en Mínimo** — bug histórico de v8.66f: `_baseF` (usado para el alto del banner) se escalaba con el preset pero `baseFont` (usado para dibujar el texto) NO. Resultado: Mediano/Mínimo achicaban el banner pero dibujaban texto tamaño completo → la última línea (fecha/hora) se cortaba fuera. Ahora ambos escalan proporcionalmente y el texto entra siempre.

**Advertencia legacy** — botón "🖋 Mediano/Mínimo" sobre foto legacy (sin backup del original) dispara `confirm()` explicando que puede quedar el sello anterior visible por atrás, y sugiere usar Normal. Banner rojo dismissible bajo la barra de herramientas.

Archivos tocados: `datos/sello_v4.js`, `index.html`, `admin_usuarios.html`, `reportes.html`, `partes_diarios.html`, `dvba_campo.html`, `dvba_campo_lite.html`, `sw.js` (cache `dvba-campo-v9.94`).

### v8.44 – v8.52 · 31 julio – 1 agosto 2026 — Fase 4 completa (Panel Admin) + escalado multi-zona listo + branding SIG Vial PBAᵝ

Cierre de la infraestructura para escalar a las 12 zonas viales de la DVBA. Con esta ronda queda operativo: RLS zonal blindado con trigger server-side, panel administrativo completo para gestionar usuarios de todas las zonas, título institucional unificado con marca "beta" superíndice, y módulo legal compartido (Acerca + Términos + Privacidad + Permisos PWA) en los 6 HTMLs del ecosistema.

#### 🛡 Fase 4 · Panel de Administración (v8.45)

- Nuevo `admin_usuarios.html` accesible solo con rol admin

- Función SQL `admin_listar_usuarios()` SECURITY DEFINER con guard interno

- Métricas: total users, admins, gerencia, técnicos, sin perfil, inactivos

- Filtros por rol, zona, estado + buscador email/nombre

- Editar rol/zona/nombre inline, activar/desactivar, reset password via `supabase.auth.resetPasswordForEmail`

- Invitar users vía Supabase Dashboard (link directo) con mensaje pre-armado para copiar

- Guard tolerante a token expirado con fallback a localStorage (v8.49)

#### 🔒 Trigger de zona por rol · SQL_10 (v8.44)

- Función `forzar_zona_por_rol()` SECURITY DEFINER con BEFORE INSERT/UPDATE en `relevamientos` y `partes_diarios`

- Sobrescribe `NEW.zona = current_user_zona()` para técnicos automáticamente

- Admin y gerencia respetan el valor enviado (para reasignar)

- Defensa en profundidad sobre las policies RLS: aunque el frontend mande zona equivocada, la BD la corrige

- SQL_9 con bloque defensivo `DO $$` que elimina policies legacy con nombres alternativos

#### 🎨 Branding "SIG Vial PBAᵝ" (v8.50 – v8.52)

- Título único con beta superíndice ámbar en 6 HTMLs (portal, reportes, partes_diarios, admin, dvba_campo, dvba_campo_lite)

- Footer minimalista sin autor visible (movido a modal Acerca)

- Módulo `datos/legales.js` compartido con contenido único de Acerca / Términos / Privacidad / Permisos PWA

- Modal auto-inyectable con tabs, mismo look en todos los sitios

- Sección Permisos PWA explica claramente cámara, ubicación, storage, conexión — tranquilidad para el usuario móvil

- Contactos: `lulamaita@vialidad.gba.gov.ar` (institucional) + `lucianolamaita@gmail.com` (personal)

#### 🗺 Progresiva inversa para caminos (v8.47)

- `progresivaAPuntoCamino(nomenclatura, kmTarget)` análoga a la de RPs

- Reusa `_offsetTramoCache` + `_haversineM` con aplanado de coords

- Se dispatchea desde `ubicarPorProgresiva()` según `tipoVia`

- Ahora funciona para RPs y caminos secundarios por igual

#### 🔐 Logout robusto (v8.46)

- Fix del `POST /auth/v1/logout 403 Forbidden` que dejaba sesión colgada

- `signOut({scope:'local'})` evita el POST problemático

- Limpieza manual de `localStorage.sb-*` + `location.reload()` para estado limpio

- Reload post-login que también evita race conditions de datos con token viejo (v8.49)

#### 👤 Login general + user-info Rol+Zona (v8.48)

- Modal login con texto general multi-zona (sin mencionar Zona VI)

- Header muestra siempre **🛡 Admin** | **📊 Gerencia** | **👷 Técnico · Zona X**

- Nunca se muestra el mail (que puede ser largo). Nombre real va al tooltip.

#### 🌎 Plan de escalado multi-zona

Nuevo documento `docs/PLAN_ESCALADO_MULTIZONA.md` con:

- Estructura de carpetas por zona (`datos/zona_I/`, `zona_II/`, etc.)

- Assets requeridos por zona (partidos, RPs, caminos, mojones, CARACT_VIALES)

- Checklist paso a paso para habilitar zona nueva (4 etapas: preparación QGIS → calibración → subida → habilitación institucional)

- Presupuesto estimado (~50 h por zona · ~550 h para las 11 restantes)

- Prioridades: IV Junín + V 9 de Julio primero (limítrofes con VI, más fáciles)

- Roadmap post-concurso 2026 por trimestres

### v8.29 – v8.42 · 29–31 julio 2026 — Sistema de reportes unificado Red Vial Provincial + paleta minimalista PBA

Refactor completo del tab Reportes del portal, integrando Rutas Provinciales (Red Vial Provincial Primaria) y Caminos Secundarios (Red Vial Provincial Secundaria) en un único flujo simétrico basado en selección manual por click en el mapa. PDF unificado con logo DVBA, SVG con partidos + ciudades + trazas + mojones + registros, y toda la nomenclatura oficial DVBA aplicada.

#### 🎯 Selección homogénea Rutas ↔ Caminos (v8.29 – v8.31 · v8.36 · v8.39)

- **Sin dropdown** — el sistema detecta automáticamente qué tipos hay seleccionados (RPs, Caminos o ambos) y genera el reporte correspondiente

- **Selección solo manual** por click en la vía → botón "+ Agregar al reporte" del modal SIG Vial. Los chips del panel Mapa quedaron solo para visualización, no entran al reporte (evita el bug de "se reportan las 15 RPs si tildo todas")

- **Halo dorado #ffb800** en el mapa para cada RP o tramo seleccionado (paralelo entre ambos tipos)

- **Chip contador único** `✓ 🛣 N rutas · 🚜 M tramos` siempre visible, con lista expandible por tipo y × por cada item para deseleccionar

- Tabla RUTAS reescrita a formato **1 fila por tramo** homogéneo con Caminos aprovechando `CARACT_VIALES[rid].tramos[]` del CSV oficial SALADILLO_RED (96 tramos, 15 RPs)

#### 📄 PDF mixto unificado (v8.38 · v8.40)

- Reporte mixto abre **1 sola pestaña de PDF** con las 2 secciones consecutivas (evita popup blocker que descartaba el 2do tab)

- Ambos PDFs con **header institucional idéntico**: logo DVBA + título + fecha + línea turquesa PBA

- **Banner sello institucional**: "📋 Datos oficiales de la Red Vial Provincial (Primaria + Secundaria) de Zona VI Saladillo · Fuente: DVBA - PBA" — se muestra para cualquier rol, sirve cuando el PDF circula por email/WhatsApp/impreso

- Nomenclatura oficial en títulos: "Reporte de Red Vial Provincial Primaria" y "Reporte de Red Vial Provincial Secundaria (Caminos)"

#### 🗺 Mapa SVG enriquecido para Caminos (v8.37 · v8.41)

- Nueva función `generarMapaSVGCaminos()` análoga a la de rutas, dibuja contornos de partidos, ciudades de referencia, trazas coloreadas por CLASE, mojones (si `rc-moj`) y registros (si `rc-regs`) dentro del bbox

- Grilla dashed sutil, norte y escala; orden Z: grilla → partidos (fondo) → ciudades → trazas → mojones → registros → escala/norte

- Único elemento que sigue requiriendo captura real (`rc-mapa-cap` con leaflet-image): el basemap OSM de tiles

- Fix crítico `leaflet-image`: los divIcons custom (pin, mojones) rompían la captura con "Cannot read 'match'". Ahora se ocultan temporalmente los `L.Marker` antes de la captura y se restauran al terminar

- Captura contextual: al generar PDF de rutas se ocultan capas de caminos (y viceversa), y los mojones se muestran según el checkbox

#### 🎨 Paleta minimalista PBA (v8.26 – v8.34)

- Sacados todos los fondos oscuros tipo IDE (`#0d2030`, `#1a0d0d`, `#0a1620`, `#1a2a35`) del panel edición del sidebar

- Botones sidebar variantes .side-neutral y .side-danger: fondo blanco con borde `--light`, texto en color institucional

- Modal grande de edición de registros: fondo blanco con header banda turquesa PBA, botón Cerrar blanco con borde suave

- Fila fecha/hora, filtro por tipo, panel Mantenimiento Storage, todos migrados a paleta clara

- Footer `reportes.html` pasa de `#1f2732` a `--bg` claro con texto `--mut`

#### 📚 Nomenclatura oficial DVBA (v8.42)

Aplicada en títulos formales de PDFs y headers de secciones. Nueva memoria de referencia (`reference_nomenclatura_red_vial.md`):

- **Red Vial Provincial Primaria** = Rutas Provinciales (RPs)

- **Red Vial Provincial Secundaria** = Caminos secundarios

- **Red Vial Terciaria** = Caminos municipales (aún no implementado)

#### 🐛 Bugs críticos resueltos

- v8.32: `leaflet-image` rompía la captura con "Cannot read 'match'" por divIcons custom (fix: ocultar markers)

- v8.33: SVG del mapa sin trazas cuando `_selRutas` vacía + captura apaisada (fix: forzar String(rid) + `object-fit:contain`)

- v8.34: Botón "Nuevo Pin" verde flotante eliminado (redundante con "Pin mapa" y se solapaba con la rosa del Norte)

- v8.35 (patch v8.34): "Limpiar todos" del chip solo limpiaba caminos aunque hubiera RPs (fix: limpia ambos)

- v8.37: PDF caminos mostraba lista GLOBAL de partidos/clases del mapa aunque el reporte fuera de 1 solo camino (fix: derivar del `_repCaminosData`)

- v8.38: PDF mixto solo generaba el 1er tab por popup blocker (fix: combinar en 1 solo PDF con salto de página)

### v8.11 – v8.21 / v9.79 – v9.88 · 21–28 julio 2026 — Refactor sello + EXIF metadata + rediseño arquitectura edición

**Sprint intensivo de 8 días con 25+ versiones incrementales que refactorizó completamente el sistema de sellado y el flujo de edición de registros.** Cambio arquitectónico crítico + varios diferenciales técnicos nuevos.

#### 🎨 Refactor sello v4 (v8.11)

- **Eliminada la duplicación**: 3 copias embebidas del sello (portal + partes + móvil) → 1 solo módulo `datos/sello_v4.js` que todos importan. Cada fix se propaga instantáneamente sin desincronizarse.

- **Wrapper del portal**: mantiene la lógica de rotación EXIF+manual específica del portal como pre-procesamiento; delega el sellado real al módulo.

- **Compresión foto PC pre-sello**: fotos subidas desde `<input file>` del portal se comprimen a max 1600px/q=0.85 con `createImageBitmap` ANTES del sello. Elimina anomalías de cálculo por dimensiones extremas.

#### 🌐 Sello overlay semitransparente (v8.15 – v8.17)

- El banner ya NO se agrega DEBAJO de la foto (que la afinaba), sino que se dibuja ENCIMA con fondo `rgba(0,0,0,0.55→0.75)`. Foto conserva 100% su ratio original.

- **Layout adaptativo**: `bH` dinámico según cuántas líneas de texto haya + interlineado 1.35 → texto nunca se pisa.

- **QR con logo DVBA al centro** (18% del área, error correction H = tolera hasta 30% de oclusión). Cap `colSide` a 20% del ancho para foto vertical.

- **Auto-fit de la línea de versión**: ancla al fondo del banner + baja fontsize si no entra.

- **Detector de banner viejo** por escaneo estricto de línea dorada `#d4a820` (no fila oscura, que confundía sombras con banner y cortaba parte de foto real).

#### 📸 Metadatos EXIF completos (v8.12 – v8.13)

- Nuevo módulo `datos/exif_writer.js` con wrapper `DVBA_EXIF.inyectar()`.

- **Fix crítico Latin1**: `piexif.insert` usa `btoa` que solo acepta Latin1. Función `_asciiSafe(s)` mapea ñ/tildes/·/etc. → ASCII. `_asciiNuclear` con `encodeURIComponent` para `UserComment`. Sin esto la inyección fallaba silenciosamente con caracteres UTF-8 comunes.

- **Carga SINCRÓNICA** de `piexif.min.js` con `<script src>` (era dinámico → race condition: sello corría antes que piexif se cargara).

- Import del `sello_v4.js` en `index.html` (faltaba tras el refactor v8.11).

- **Botón `🔧 EXIF+`**: re-inyecta metadatos sobre foto existente (útil para registros anteriores a v8.12 que quedaron sin EXIF).

- Diagnóstico `🔍 EXIF` muestra qué campos están en el archivo real de Storage.

#### 🗂 Rediseño arquitectura edición (v8.19 – v8.21)

- **Sidebar drawer colapsable**: botón `◀` en el borde derecho + atajo `Ctrl+B`. Colapsa a 32px liberando el mapa. Persiste en `localStorage`. Leaflet recalcula tiles con `invalidateSize()`.

- **4 flujos de creación/edición coordinados**:
        
Foto móvil (Modo Básico): auto-ubicada + auto-completado (partido/ruta/prog) con ARMONIZADOR.
Desde mapa: `📍 Nuevo Pin` centra pin arrastrable en el viewport.
Por progresiva: elegir RP + km + `🎯 Ubicar` → sistema calcula lat/lng con `progresivaAPunto()` (interpolación lineal Haversine sobre CHAIN+ANCHORS).
Edición: arrastrar pin recalcula ruta/prog al vuelo.

- Descartado modal grande centrado (bloqueaba mapa) tras iteración de UX.

- **Descarga con nombre custom**: `fetch → blob → objectURL` forzando `SIGVialPBA_ID_RP.jpg` (Chrome ignora `<a download>` cross-origin de Supabase).

- Cache defensivo `_ultimaRutaCargada` para no perder el camino al enviar el wizard.

- Sincronización `_rotacionPreview` (sidebar) ↔ `_rotacionManualSello` (sello) en aprobación post-edición.

#### 📱 PWA móvil unificada + low-memory (v9.79 – v9.88)

- **Bootstrap `app.html`**: router de 10 líneas que decide entre Modo Básico y Modo Avanzado según `localStorage.dvba_modo_preferido`. Una sola PWA, un solo ícono en el launcher.

- `campo.html` queda como redirect legacy para instalaciones previas.

- **Fix GPS de raíz** (v9.81 → v9.83): flow simplificado, si badge verde y GPS conocido, snap directo del watch — sin re-pedir GPS ni bloquear con promises que colgaban.

- **Compresión low-memory** con `createImageBitmap` + `resizeWidth`: decodifica directo al tamaño target sin cargar la foto full en RAM. Elimina crashes "memoria insuficiente" en celulares 2-3GB al volver de la cámara nativa.

- Foto móvil a 1200px (era 900px) → menos sensación de "afinada" contra el banner del sello.

- Fix instalación PWA: modal grande con fallback manual si `beforeinstallprompt` no dispara.

- Íconos PWA con fondo negro `#0a0a0a` (era transparente → Android rellenaba con blanco).

#### 🗺 Fix bundle RP30 (v9.75)

- Reetiquetado de mojones oficiales en QGIS: "300"→100, "100"→250, "250"→300 (etiquetas cruzadas históricamente).

- Recalibrado del bundle con anchors km 300/350/400 (offset consistente 262.60): `progIni` 262.60 (era 245.96, +16.6 km), `progFin` 435.12.

- Gap real RN205 incorporado (acc 117.75 → 123.51, ~km 380-386 sobre RN205).

### v9.50 · 7 julio 2026 — Fix instalación PWA (WebAPK id / start_url)

**Fix operativo:** el `manifest.json` tenía un desajuste menor entre `"id"` y `"start_url"` que hacía que Android considerara el WebAPK como inseguro (app "fantasma" en algunos celulares — se instalaba pero no reconocía como válida). Unificados ambas rutas → Chrome instala la PWA sin interrupciones.

#### Efecto secundario detectado (task #201, pendiente)

Al reinstalar el WebAPK con el nuevo `id`, se perdió el **diálogo del sistema para activar GPS cuando está apagado**. Antes: tocar "sin señal" abría el prompt nativo de Android. Ahora: solo muestra "GPS denegado, ir a ajustes".

**Causa probable:** el WebAPK con nuevo `id` se considera "app nueva" → perdió el nivel de confianza que Chrome le daba antes para pasar la solicitud a Play Services (que sí muestra el diálogo). Cae en la Geolocation API estándar que *no puede activar el GPS del sistema por diseño*.

Solución en el ROADMAP: implementar botón "🔧 Abrir ajustes de ubicación" con intent Android `android.settings.LOCATION_SOURCE_SETTINGS` + reintentar automáticamente al volver del ajuste vía `visibilitychange`.

### v9.50–v9.53 / v7.46–v7.57 · 7–13 julio 2026 — Sprint SIG Vial + gestión de fotos originales + UX del portal

**Sprint enfocado en 4 ejes:** (1) preservar originales y sistema de re-sello editable, (2) rediseño UI del portal con paleta cálida y agrupación inteligente, (3) **modal SIG Vial tipo DNV** para RPs y caminos secundarios con datos oficiales, (4) hotfixes de bugs críticos que rompieron dos veces la app.

#### 📸 Sistema de fotos originales preservadas + re-sellado (v7.47 → v7.50)

- **Convención de paths (Opción A):** el archivo `{path}.jpg` es el **original** y NUNCA se sobreescribe. El sellado se guarda como `{path}_sello.jpg`. Helpers `getOriginalUrl()`, `getSelloPathFromOriginal()`, `esRegistroLegacy()`.

- **Aprobar registro pendiente** ahora abre el modal SIG para editar datos + rotar la foto (EXIF + manual con botones ↺ ↻ Reset) antes de sellar. Preserva `fechaISO` original del registro.

- **Sidebar de edición con botones rotación + re-sellar**: al hacer ✏ Editar sobre un registro, aparece bajo el preview de foto un bloque con `↺ 90°` `↻ 90°` `Reset` `🖋 Re-sellar`. Rotación visual instantánea con CSS transform + re-sello contra el original.

- **Registros legacy** (sellados con sistema viejo que sobreescribió el original): botón re-sellar deshabilitado con tooltip explicativo. No se puede re-sellar sin acumular banners.

- **Sello incluye estado** además de tipo: la Línea 3 combina `tipo · estado` (ej: "Encrucijada en T · faltante") desde `aprobarRegistro` y `reSellarFotoEditada`.

- **Gestión de backups:** botón "🗑 Backup de esta foto" en edición individual + sección "🧹 Mantenimiento Storage" en tab Reportes para limpieza masiva de originales de registros aprobados hace más de N días. Nunca borra el archivo `_sello.jpg`.

#### 🎨 Rediseño UI del portal (v7.53)

- **Pills de registros agrupadas** por Partido / Ruta / Mes / Tipo, con grupos colapsables y contadores `activos/total`. Botones +/− por grupo para activar/desactivar sin abrir. Escala con 1000+ registros sin llenar visualmente el sidebar.

- **Paleta cálida por RP**: 15 colores dentro de la gama terracota/rojizo/anaranjado oxidado (`RP_COLORES_CALIDOS`). Cada RP con su propio tono. Reemplaza el rojizo único (v7.31) que quedaba monótono.

- **Ancho de trazas armonizado**: todas las RPs a `weight: 4` uniforme.

- **Mojones colapsados** en sidebar (`<details>` nativo) — antes llenaba el panel al seleccionar RP.

#### 🏛 Modal SIG Vial tipo DNV (v7.54 → v7.57)

- **Nuevo bundle `datos/caracteristicas_viales.js`** generado desde `SALADILLO_RED.csv`. 15 RPs con longitud oficial (agregada por tramos), clases (PAVIMENTADO/CONSOLIDADO/TIERRA), partidos por los que pasa, doble vía (solo RP6), 96 tramos oficiales con sección_vial, denominación, longitud, clase, partido. Placeholders `null` para ancho calzada, banquinas (D e I), TMDA, pavimento específico, estado — completables vía sistema colaborativo (Fase futura).

- **Modal centrado tipo SIG Vial DNV al hacer click en una RP**: header con color de la RP + progresiva en el punto clickeado + ubicación + longitud oficial vs GIS con diferencia coloreada + características viales + tabla colapsable de tramos oficiales con nowrap y tooltip para textos largos. Reemplaza el popup viejo que listaba mojones + últimos 2 registros.

- **Modal también para caminos secundarios (v7.57)**: header violeta, mismos campos + Denominación (Gral Alvear - Mamaguita) + Transitabilidad (PERMANENTE / TEMPORARIO) + Datos GIS colapsables (puntos inicio/fin, N° líneas, N° vértices) + banner ⚠ si `ALERTA:REVISAR`. Info tomada del geojson de red secundaria.

- **Bugfix mapeo partidos (v7.55)**: los códigos DVBA sin cero (34, 41, 93) estaban mapeados mal — 034=General Alvear (no Cañuelas), reforzados con `PARTIDOS_TABLA` real del index.html.

- **Botón "Editar datos viales"** como placeholder para futura UI colaborativa (tabla Supabase `caract_viales`).

#### 🐛 Hotfixes críticos

- **v7.51 progresiva --- al mover pin**: en edición, `#fruta.value` tenía prefijo "RP N" que `calcProg("RP N")` no encontraba. Reemplazado por `autoDetectarCampos(pos.lat, pos.lng, { forzarAuto: true })`.

- **v7.53a TDZ**: `RP_COLORES_CALIDOS` se accedía en for-loop de `META_DATA` antes de declararse → JS entero no ejecutaba, mapa en blanco. Declaración movida arriba.

- **v7.53a armonizador.js truncado**: fragmentos duplicados tras `module.exports` rompían syntax. Cortado al cierre real.

- **v7.54a modal SIG Vial mal ubicado**: Python `.replace('</body>')` tomó el primer match, que era una string dentro del template literal de `exportReporteHTML`. Modal insertado *dentro* del script, rompiendo todo. Rescatado con `rfind('</body>')`.

#### 📱 App móvil (v9.50 → v9.53)

- **v9.50 fix manifest PWA fantasma**: `id` y `start_url` unificados. Instalación en celulares que la rechazaban antes.

- **v9.53 sin rotación de fotos en móvil**: se hace en escritorio al aprobar/re-sellar. Móvil captura la foto tal cual la sacó el celular.

- **Sin botón intent GPS en móvil**: v9.52 lo probó pero se removió — solo el mensaje de error clásico.

### v9.45–v9.49 / v7.28–v7.45 · 1–6 julio 2026 — Sprint integración caminos + rediseño UI + scripts v2.11

**Sprint intenso** con 3 ejes: integrar completamente la red de caminos secundarios al portal principal, rediseñar la visualización del mapa, y mejorar el pipeline de generación de bundles con recorte exacto de límite de partido.

#### 🛣 Integración de red vial completa

- **Caminos secundarios integrados**: los 100 caminos (129 tramos) de los 8 partidos aparecen en el mapa principal junto con las RPs. Filtros por partido, clase (pavimentado / mixto / tierra / sin abrir) y chips individuales.

- **Renderizado doble capa (HALO + BASE)** portado desde `caminos_secundarios.html` — trazas nítidas sin offset visual sobre OSM/Oscura/Satélite.

- **Detección de caminos en app móvil (v9.32+)**: `datos/armonizador.js` extendido con `caminoMasCercano()` y `viaMasCercana()`. El wizard móvil ahora sugiere *"★ Vía sugerida: Cno. 093-13 · km 4.5"* si el GPS cae sobre camino secundario.

#### 🎯 Cursor + progresivas al hover

- **Cursor naranja flotante** que se posiciona sobre la cadena real al pasar el mouse.

- **Tooltip permanente**: `RP 91 · 15+041 (15.04 km)` o `Cno. 093-13 · km 4.87`.

- **Círculos de progresiva cada N km** (1 / 5 / 10) activables con *🎯 Progresivas al hover*.

- **Densidad de mojones configurable**: 5 / 10 / 20 / 50 km / Ninguno. Default 50 (modo minimalista).

- **Modo detallado**: atajo que pone mojones cada 10 km + progresivas ON con paso 5.

#### 🎨 Unificación visual

- **RPs color único** `#c25a2a` (rojizo ladrillo). Diferencia por label, no por color arcoíris.

- **Partidos color único** `#3a5a7a` con opacidad baja — fondo administrativo.

- **Caminos por clase**: azul pavimentado / violeta mixto / gris sin abrir / marrón tierra.

- **Panel "🗺 Capas" plegable** reemplaza los botones sueltos: Fondo + Capas + Visualización + Leyenda.

#### 🔧 Workflow del sellado saneado (v7.34 → v7.38)

- **Fix crítico modal escritorio**: `modal-sello-ov` de `index.html` estaba incompleto desde task #76 (v7.4) — le faltaban 10 inputs + botones + cierres. Reconstruido.

- **Guard anti-doble-sello**: si la foto ya contiene `_sello.` en la URL o tiene `sello_version='v3'`, no se re-sella. Aplica a `guardar()` post-edición y a `aprobarRegistro()` desde la cola.

- **Modo pin no muestra círculo naranja**: al activar modo pin, el cursor se oculta para no confundir con la cruz.

- **Auto-detección inteligente al hacer pin**: click sobre camino → toggle → 'camino' + `Cno. XX-YY`. Click sobre RP → 'rp' + progresiva. En hover normal se respeta el toggle actual.

#### ⚙ Scripts `gen_ruta_bundle.py v2.11` + `recortar_zonavi.py v1.1`

- **v2.9 — Descarte anchors en gap**: si el mojón físico snap cae dentro de un tramo `es_gap=1`, no se usa como anchor. Corrige el "estiramiento" que producía rectas visuales en RP61 v7.39.

- **v2.10 — Cruce exacto en el borde del partido**: `recortar_zonavi.py` ahora calcula el punto exacto de intersección segment-polygon. `gen_ruta_bundle.py` INSERTA ese punto como vertex real. RP47 ganó +2.9km al borde Navarro/Mercedes, RP51 +1.2km en Alvear/Tapalqué, RP61 +141m.

- **v2.11 — Mojones sintéticos interpolados con anchors**: antes usaban `acc = km - prog_ini` (lineal); ahora km→acc via anchors (inverso de `calcProg`). Los mojones km 250, 300, etc. caen sobre las progresivas oficiales sin desplazamiento acumulado.

- **Filtro anchors no-monotónicos**: si un anchor rompe la monotonicidad (RP51 tenía km 300 con acc menor que km 250), se descarta con warning en consola.

#### 🗺 RP61 canónica

Recorrido real verificado (E→O): Gral Belgrano → Las Flores urbana → **Gap RN3/RP30 hasta RP91** → camino de tierra → Gral Alvear → **Gap RN205 (~280m)** → tierra → 9 de Julio. Renumerar fids en QGIS en orden geográfico eliminó el zigzag inicial.

#### 🐛 Deuda técnica pendiente

- **RP30 y RP46**: al regenerar con `_traza_completa` dieron resultados inaceptables (zigzag y mala longitud). Se revirtieron al bundle previo (v7.40). Requieren revisión en QGIS del orden geográfico de fids del `_traza_completa.geojson` antes de regenerar.

- Task #195 marca este pendiente para próxima sesión con abordaje uno a uno.

### v9.19 / v7.14 · 30 junio 2026 — Workflow "campo → oficina" + armonización geoespacial 🎯

**Cambio mayor de paradigma:** la foto se captura cruda en campo y se sella SOLO al aprobar en oficina, con armonización automática contra GPS. Cierra el ciclo de calidad de datos del sistema.

#### BD — 5 columnas nuevas en `relevamientos`

- `estado_workflow`: `'campo'` (recién cargado) | `'aprobado'` | `'rechazado'`

- `validado_geo`: `'pendiente'` | `'auto_ok'` | `'auto_corregido'` | `'usuario_priorizado'` | `'gps_sospechoso'` | `'sin_coords'`

- `sello_version`: `NULL` (sin sello) | `'v2'` (histórico) | `'v3'` (re-sellable)

- `prioridad`: `'normal'` | `'urgente'`

- `motivo_rechazo`: `TEXT` opcional

Backfill aplicado: 82 registros con foto → estado `aprobado` + sello v2 (histórico). 19 registros sin foto → quedan en `campo` (revisión manual).

#### Nuevo módulo `datos/armonizador.js` (~410 líneas, 100% offline)

- `detectarPartido(lat, lng)`: point-in-polygon contra `partidos_zona_vi.geojson`

- `rutaMasCercana(lat, lng, radioM)`: barrido sobre las 15 RPs con CHAINS_DATA

- `progresivaEnRuta(lat, lng, rutaKey)`: proyección perpendicular + interpolación con ANCHORS_DATA (calibrados con mojones físicos)

- `mojonMasCercano(lat, lng, rutaKey)`: referencia visual desde MOJONES_DATA

- `armonizar(form)`: función principal, devuelve `{cambios, consistentes, sugerencias, severidad}`

- **Umbrales adaptativos** según precisión GPS: `max(50, gpsAcc*2)` para ruta, `max(80, gpsAcc*3)` para progresiva. Evita falsos positivos en zonas de mala señal.

#### App móvil (v9.19)

- **Captura SIN sellar**: nueva función `procesarFotoCampo(b64)` reemplaza a `agregarSelloInteractivo`. Foto se sube cruda a Storage, registro insertado con `estado_workflow='campo'` y `sello_version=NULL`.

- El modal "Editar datos del sello" sigue mostrándose para que el operador confirme/edite datos antes de sincronizar — pero NO genera sello.

- `validado_geo` se pre-calcula en cliente con `ARMONIZADOR.armonizar()` al insertar (auto_ok / pendiente / gps_sospechoso / sin_coords).

- **Pre-fill GPS al tocar "↓ Usar"**: en 2 niveles de radio
        
500m: `★ Ruta sugerida: RPXX · km YYY` (preciso)
2km: `⚠ Ruta más cercana: RPXX a NNNm — ¿es esta?`
>2km: `ℹ No hay RP cercana — cargá manualmente`

- Mensaje en pestaña Confirmar: "Foto lista (sello al aprobar)" reemplaza "Con sello DVBA".

#### App escritorio (v7.14) — Cola de pendientes

- **Badge "🔔 X pendientes"** en header con animación pulse + gradient naranja. Rojo si hay urgentes. Visible solo logueado. Auto-actualiza con MutationObserver sobre user-info.

- **`ensureColaBadge()`**: crea el botón dinámicamente si el HTML cacheado no lo tenía (fallback PWA).

- **Modal cola de pendientes**: por cada registro foto thumb + datos + recuadro de armonización en tiempo real + 3 botones (Aprobar/Editar/Rechazar). Indicador de color según validado_geo (verde auto_ok, amarillo con sugerencias, rojo gps_sospechoso).

- **Aprobar**: auto-acepta sugerencias del armonizador, genera sello v3 con `aplicarSelloDVBA`, sube al mismo path con `storage.update()`, UPDATE estado='aprobado' + sello_version='v3'.

- **Rechazar**: prompt para motivo opcional, UPDATE estado='rechazado' + motivo_rechazo.

- **Botón "Aprobar los verificados"** (batch): aprueba en lote los `validado_geo='auto_ok'`.

- **Auto-sellar al editar pendientes**: si el revisor edita un registro en `'campo'` desde el sidebar normal, al guardar se sella v3 + aprueba automáticamente.

- **Badges en sidebar de registros**: cada item muestra estado del workflow:
        
⏳ EN REVISIÓN (naranja) — `estado='campo'`
✓ APROBADO (verde) — `estado='aprobado'` + sello v3
📜 HISTÓRICO (gris) — `estado='aprobado'` + sello v2
✕ RECHAZADO (rojo, tooltip con motivo)

#### Infraestructura

- SQL: 5 ALTER TABLE en Supabase aplicados con CHECK constraints + backfill.

- Policy RLS de Storage: `auth_update_relevamientos` ya existía OK, pero `upload({upsert:true})` chocaba con policies de INSERT. Cambio a `storage.update(path, blob)` que es UPDATE puro → respeta solo la policy de UPDATE existente.

- `sw.js` CACHE_URLS incluye armonizador.js + partidos_zona_vi.geojson + dvba_estados.js + qrcode.min.js.

#### Sub-versiones intermedias durante el desarrollo

- **v9.18a (sw)**: fix tildes en `modalidadImplicita` / `superficieImplicita` usando `.normalize('NFD').replace(̀-ͯ)` antes del regex (JavaScript `\b` no es Unicode-aware).

- **v9.19a (sw)**: texto pestaña Confirmar móvil + pre-fill GPS en 2 niveles.

- **v9.19b (sw)**: fix tildes confirmado en escritorio también.

- **v9.19c (sw)**: `ensureColaBadge` fallback dinámico + no duplicar "RP " si reg.ruta ya lo incluye.

- **v9.19d (sw / v7.13)**: auto-sellar v3 + aprobar al editar registros en 'campo'.

- **v9.19e (sw)**: badges de workflow en sidebar + texto botón "Aprobar los verificados".

- **v9.19f (sw)**: auto-seleccionar tipo cuando la categoría tiene un solo ítem (caso "Otro" — antes el operador creía que ya estaba seleccionado al tocar la categoría).

- **v9.19g (sw / v7.14)**: fix storage.update() vs upsert para evitar conflicto RLS.

### v9.18 · 24 junio 2026 — Modelo Tipo↔Estado rediseñado + sub-atributos

- **Nuevo módulo `datos/dvba_estados.js`**: estados específicos por categoría (Calzada: Bueno/Regular/Malo/Crítico · Señales: OK/Dañada/Ilegible/Falta · Iluminación: Funciona/No funciona/Parcial · Entorno: Activo/Bajo monitoreo/En limpieza · Mantenimiento: Programado/En ejecución/Finalizado · etc.) más 3 estados universales de seguimiento (Pendiente · En obra · Reparado) que aparecen en casi todas las categorías.

- **Reescritura de `dvba_tipos.js`** con 10 categorías separando RELEVAMIENTO (estado físico) de TAREA (acción). Categorías nuevas: *Demarcación horizontal*, *Mantenimiento / Tarea*. Eliminadas referencias viejas a "Tratamiento bituminoso". Agregados ítems específicos para caminos de tierra: Huellas, Anegamiento por mala conformación, Erosión de calzada. Seguridad vial ahora incluye Cámaras de control / fotomultas y Radares de velocidad.

- **Sub-atributos condicionales**: Tipo de superficie (Asfalto · Hormigón · Tierra · Estabilizado · Mejorado con dolomita · Mejorado con suelo cal) y Modalidad de tarea (Manual · Mecánico · Mixto). Aparecen automáticamente solo cuando la categoría del tipo elegido los soporta (Calzada y Mantenimiento para superficie; solo Mantenimiento para modalidad).

- **Hook `onTipoChange(tipoStr)`** en ambas apps: al elegir un tipo, infiere su categoría con `DVBA_TIPOS.categoriaDe()`, repuebla el `<select>` de estado con los estados válidos, y muestra/oculta los selects de superficie y modalidad según corresponda.

- **Decisión: NO migrar Supabase (Opción B)**. Los registros viejos con strings legacy ("Bueno", "Malo", "Crítico", "En obra") se siguen mostrando tal cual en listas. Al editar uno viejo, el dropdown se inicializa vacío y al guardar adopta el nuevo modelo. Cero downtime, cero riesgo de corrupción.

- **Serialización de sub-atributos en `observaciones`**: como no hay columnas dedicadas en BD, superficie y modalidad se concatenan al final del campo observaciones con formato `[superficie:asfalto · modalidad:mecanico]`. Parseable con regex para reportes futuros. Migrable a columnas dedicadas cuando se quieran cruces.

- **Antes**: ambas apps usaban estados distintos (escritorio: Crítico/Grave/Regular/Leve/Resuelto · móvil: Bueno/Regular/Malo/En obra) sin sentido lógico cuando se aplicaban a tipos como "Mojón kilométrico" o "Siniestro vial".

- Documentado en nuevo [docs/MODELO_TIPOS_ESTADOS.md](MODELO_TIPOS_ESTADOS.md) con árbol completo, matriz de estados, flujo en cada app y guía de extensibilidad.

### v9.16 · 24 junio 2026 — Sello v3 inicial con QR + fix bug RS_BLOCK_TABLE

- **Primera implementación del sello v3** con layout 3 columnas (logo izq + texto centro + QR der). Reemplaza el sello v2 (banda 5 líneas con localidad/dirección/lat-long/plus code/fecha-hora-tipo + firma institucional).

- **Lib QR vanilla JS embebida** en `datos/qrcode.min.js`. Implementación basada en qrcode-generator de Kazuhiko Arase (MIT License), soporta hasta version 10 con error correction level M. Sin dependencias externas, ~14 KB.

- **Fix de bug crítico** en `getRSBlocks()`: los valores de las constantes ECL están en orden L=1, M=0, Q=3, H=2 (usados así en el QR format info), pero la tabla `RS_BLOCK_TABLE` está ordenada L→M→Q→H. Mi primera versión mapeaba `idx = (typeNumber-1)*4 + errorCorrectionLevel` que daba resultados invertidos (L recibía la tabla de M, M la de L, etc.). El QR se "veía" pero al escanearlo no decodificaba. Reescrito con un switch que mapea la constante ECL al offset correcto.

- **Modal del sello simplificado**: se sacan campos Dirección y Plus Code (reemplazados por el QR). Se reordena con Ruta+Km arriba y Tipo de incidencia más prominente. Pasa de 11 campos a 8.

- **Tipo de incidencia destacado** como feature diferencial: GPS Map Camera no lo tiene (solo coordenada + fecha), mientras que el sistema DVBA permite categorizar el motivo del relevamiento desde el modal.

- Bump: `dvba_campo` v9.15 → v9.16, `index` v7.7 → v7.8, sw v9.15b → v9.16.

### v9.17 · 24 junio 2026 — Banner del sello como footer (no tapa la foto) + URL QR oficial

- **Layout 3 columnas** estilo GPS Map Camera: logo institucional DVBA centrado vertical a la izquierda · texto blanco grande con sombra (Localidad / Ruta+Km / Tipo / Lat-Lng / Fecha-Hora) en el centro · QR Code apuntando a `https://www.google.com/maps/search/?api=1&query=LAT,LNG` a la derecha. URL oficial de Google Maps API que pone un pin EXACTO en la coordenada (no la interpreta como búsqueda de texto).

- **Lib QR vanilla JS embebida** (`datos/qrcode.min.js`, ~14 KB, sin dependencias externas). Basada en qrcode-generator de Kazuhiko Arase. Soporta hasta version 10 con error correction level M. 100% offline. Fix de bug en `getRSBlocks`: el mapeo de ECL constants (L=1, M=0, Q=3, H=2 para format info) no coincidía con el índice de la tabla RS_BLOCK_TABLE (orden L/M/Q/H).

- **Banner como footer agregado debajo de la foto** (no la tapa). El canvas se crea más alto que la imagen (H + bH) y el banner se dibuja en el espacio agregado con fondo negro sólido. La foto queda 100% intacta, sin transparencia que comprometa legibilidad de datos. Banda con altura adaptativa: `max(200, min(W*0.22), 340)`.

- **Modal simplificado**: se sacan campos Dirección y Plus Code (reemplazados por el QR), se reordenan con Ruta+Km arriba y Tipo de incidencia más prominente.

- Fix: footer del modal de login de `index.html` lee `APP_VERSION` dinámico (estaba hardcoded en v7.3 desde hace varios commits).

### v9.15 · 24 junio 2026 — App de campo (Sello v2 + Modal editable)

- **Modal "Editar datos del sello"** antes de estampar la foto: campos Localidad, Dirección, Lat, Lng, Fecha, Hora, Altura, Plus Code, Ruta, Km, Tipo. Botones *"Sin sello"* y *"Aplicar y guardar"*.

- **Sello v2 estilo GPS Map Camera**: banda inferior con gradient negro + línea dorada, 2 columnas (texto izq + logo der), 5 líneas de datos + firma institucional separada en italic dorado tenue.

- **Plus Code (Open Location Code)** implementado en vanilla JavaScript (~40 líneas, 10 chars, offline). Se auto-recalcula al editar lat/lng.

- Nuevas funciones: `generarPlusCode`, `recolectarDatosSello`, `mostrarModalSello`, `agregarSelloInteractivo`, `editarSello`. Variable global `ultimoSelloDatos` permite a `regenerarSello` reusar valores sin abrir el modal.

- Banda dinámica con cap: `bH = max(120, min(H*0.20, W*0.16), 240)` para no comer fotos panorámicas ni desproporcionarse en imágenes enormes.

- Tipografía proporcional al **ancho** (no al alto): `baseFont = max(14, min(W*0.018, 32))`. Text shadow sutil + JPEG quality 0.95 + imageSmoothing 'high' para nitidez.

- Sub-bumps de tweaks cosméticos vía sufijo letra en sw.js: v9.15 → v9.15a → v9.15b (mantiene el `<span>` del footer en v9.15).

### v7.7 · 24 junio 2026 — App de escritorio (Sello v2 + Modal editable)

- Mismo modal + sello v2 + Plus Code que la app de campo, replicado en `index.html` con función `aplicarSelloDVBAInteractivo(b64, datosBase)` que envuelve a `aplicarSelloDVBA` v2.

- Intercepta el flujo de `procesarYGuardar`: el modal aparece con los datos pre-calculados desde el form + GPS antes de estampar y subir a Supabase Storage.

- CSS del modal centrado en pantalla (no bottom-sheet como móvil), con backdrop oscuro y animación fade-in.

- Iterativo desde v7.3 → v7.4 → v7.5 → v7.6 → v7.7 a lo largo del día con ajustes solicitados: banda más alta, logo solo (sin texto debajo), firma institucional separada al pie, fuentes más grandes.

### v1.1 · 24 junio 2026 — Caminos Secundarios (hover tolerante)

- **Halo de hit detection más ancho**: weight 11 → 18, opacity 0.22 → 0.16. La zona "caliente" para detectar hover crece ~65% sin que visualmente se note más.

- **Delay de salida 300 ms**: `mouseout` dispara `setTimeout(ocultar, 300)` en lugar de ocultar inmediatamente. `mouseover` y `mousemove` cancelan el timer al re-entrar.

- En intersecciones de dos caminos, el `mouseover` del segundo cancela el timer pendiente del primero → se muestra correctamente la progresiva del último al que entró el cursor (no se mezclan datos).

### v9.10 · 20 mayo 2026 — App de campo

- **Login Supabase Auth** con email/password. Modal al iniciar si no hay sesión. Badge usuario en header. Sesión persiste 30+ días, tolerante offline.

- Helper `authHeaders()` que devuelve Bearer token del usuario en lugar de la anon key.

- SW v3.4: `CACHE_URLS` relativas, cachea variantes con/sin `.html`, fallback inteligente offline.

- Fix crítico: `controllerchange` ya no recarga la app en primer install (rompía el GPS).

- GPS tolerante a fix lento (maximumAge 60s, timeout 2 min, getCurrentPosition inicial sin alta precisión).

- Banner de actualización funcional con botón **Actualizar** que dispara skipWaiting + reload automático.

- Toast más claro cuando se guarda offline: "Sin conexión — guardado localmente, se sincroniza al volver".

### v7.1 · 20 mayo 2026 — App de escritorio

- Login Supabase Auth con el mismo módulo `datos/auth.js` compartido con la app de campo.

- `_supa.auth.setSession()` propaga el token al cliente Supabase SDK → todas las queries (insert/update/delete/storage) usan el token del usuario.

- **Login opcional**: el mapa carga sin login con la anon key (lectura libre). Botón "🔐 Iniciar sesión" en el header. El modal aparece solo al intentar crear/editar/borrar registros (helper `requireAuth()`).

### v1.0 · 17-19 mayo 2026 — Caminos Secundarios

- Nueva subruta `caminos_secundarios.html` con mapa interactivo de los caminos secundarios provinciales de Zona VI.

- Script `scripts/calcular_longitudes_red_vial.py` que recalcula longitudes WGS84 con pyproj. Acepta GeoPackage original del KMZ o output propio re-procesado.

- Filtros multi-select por partido + por CLASE. Toggle de polígonos. Selección acumulativa con popups. Export CSV + reporte HTML imprimible.

- 5/8 partidos revisados en QGIS: 034, 058, 091, 093, 109. Pendientes: 041, 062, 075.

- Polígonos de partidos extraídos a `datos/partidos_zona_vi.geojson` para compartir entre apps.

### v9.2 · 7 mayo 2026

- Botón flotante "📲 Instalar app" en dvba_campo.

- Fix menú hamburguesa mobile en escritorio.

- Footer "Desarrollado por Ing. Luciano Lamaita · vX.Y".

### v9.1 · 6 mayo 2026

- Centralización de versionado con `bump_version.py`.

### v6.1 → v9.0 · histórico (abril 2026)

- Migración de C:\DVBA\app\ a C:\GitHub\DVBA\ (monorepo).

- Bundles JS por ruta, panel de progresivas, modo accesible, etc.

## 🔧 Changelog · Service Worker

### v9.15 / v9.15a / v9.15b · 24 junio 2026

- Política de bumps clarificada: cambio cosmético (tweak de fuente, color, posición) → bump **solo** de `CACHE_NAME` con sufijo letra (`v9.15a`, `v9.15b`...) sin tocar el `<span id='app-ver'>` del footer. Cambio publicable (feature, fix funcional) → bump de los 3: `APP_VERSION` escritorio, `<span>` móvil, y `CACHE_NAME`.

- Esto permite iterar tweaks sin saturar la lista de versiones visibles al usuario.

### v3.4 · 20 mayo 2026

- CACHE_URLS relativas (compatibles con subpath /DVBA/ de GitHub Pages).

- Cachea variantes con/sin `.html`. Fallback offline inteligente al HTML.

- Reconstruido completo tras truncado previo que rompía la registración.

### v3.1 · 6 mayo 2026

- Estrategia network-first con offline fallback + auto-purge de 404.

## 📦 Changelog · Infraestructura

### 20 mayo 2026 — Seguridad: Supabase Auth + RLS

- Nuevo módulo `datos/auth.js` compartido entre apps.

- SQL de políticas RLS documentado en `docs/SETUP_AUTH.md`.

- Usuarios creados manualmente desde dashboard Supabase. Signup libre deshabilitado.

### 17-19 mayo 2026 — Caminos Secundarios

- Nueva carpeta `referencias/` con `partidos_pba.json` (ARBA).

- Script `calcular_longitudes_red_vial.py` con pyproj.

- Estructura `geojson_procesados/red_secundaria/caminos_secundarios_NNN_final.geojson` por partido.

### 7 mayo 2026 — Versionado por artefacto

- `bump_version.py`: cada artefacto bumpea independiente.

Bitácora unificada — Sistema de Relevamiento y Gestión Vial DVBA Departamento Zona VI Saladillo

Ing. Luciano Lamaita · División Técnica · Última actualización: 30 de junio de 2026 · v4.3 (apps v9.19 / v7.14)