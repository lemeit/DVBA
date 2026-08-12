# Informe · XLI Concurso sobre Temas Viales — DVBA 2026

> **Título del trabajo (para portada):**
>
> ## SIG Vial PBA
>
> ### Plataforma web integral para el relevamiento y gestión de la red vial provincial
>
> *Caso piloto: Departamento Zona VI Saladillo · 2026*
>
> ---
>
> Lema del concurso: *"90 años construyendo caminos. Más de 80 años construyendo conocimiento"*
>
> **Deadline:** 16 de septiembre de 2026 · **Entrega:** División Publicaciones y Biblioteca (1 original + 2 copias impresas + PDF).
> **Seudónimo tentativo:** `lemeit` (a confirmar antes de la entrega).
> **Autor real (sobre cerrado aparte):** Ing. Luciano Lamaita · División Técnica DVBA · Zona VI Saladillo.
> **Estado del sistema al armar este documento:** apps de escritorio en **v8.68**, familia móvil en **v9.94**, sello institucional en **v4** (overlay semitransparente + EXIF metadata + QR con logo DVBA + 3 presets de altura Normal/Mediano/Mínimo), portal público multi-zona en producción con las 12 zonas viales y los 135 partidos de la Provincia, sistema de comentarios cross-zona operativo (SQL_13), panel administrativo con cola de solicitudes, guía de usuario publicada en `lemeit.github.io/DVBA/wiki/` (MkDocs Material con CI GitHub Actions), primera prueba de concepto de IA generativa aplicada (clasificador de fotos con Gemini · ver sección 8.4).
> **Fecha de esta versión del informe:** 12 de agosto de 2026.
> **Versión vigente al momento de la lectura:** dado que el sistema es de desarrollo activo, las versiones citadas en este documento son las del snapshot indicado. El historial completo y las versiones más recientes están disponibles en la **bitácora del proyecto**, accesible en [github.com/lemeit/DVBA](https://github.com/lemeit/DVBA) → directorio `wiki-src/04-Desarrollo-y-Estado-Actual/bitacora.md`, o alternativamente en el archivo `sw.js` del repositorio (constante `CACHE_NAME`) para la versión activa del service worker móvil, y en las constantes `APP_VERSION` de los HTML del portal escritorio.

---

## Nota terminológica

En este documento se distingue entre:

- **DVBA** → **Dirección de Vialidad de la Provincia de Buenos Aires**. Ente ejecutor del sistema, organizador del concurso, empleador del autor.
- **SIG Vial PBA** → **Nombre del sistema** que se presenta al concurso. Es el producto tecnológico desarrollado para la DVBA.
- **Zona VI Saladillo** → Ámbito operativo del piloto. La DVBA está organizada en 12 zonas viales; Zona VI es la sede del autor y el ámbito de validación del sistema.

---

## 1. Resumen ejecutivo

**SIG Vial PBA** es una plataforma web integral para el relevamiento, gestión y reporte de la red vial provincial de la DVBA. Cubre el flujo completo: desde la captura en campo con GPS (una PWA móvil con dos modos internos — **Modo Básico** minimalista para operarios y **Modo Avanzado** con wizard completo para técnicos) hasta la generación de reportes PDF institucionales, pasando por el registro estandarizado de tareas diarias, la visualización cartográfica interactiva y un modelo de roles multi-zona diseñado para escalar a las 12 zonas de la Provincia.

El sistema se desarrolló íntegramente en el Departamento Zona VI Saladillo como caso piloto, con la ambición explícita de ser adoptado como herramienta unificada para toda la DVBA.

**Alcance actual (piloto Zona VI):**

- 8 partidos + 15 rutas provinciales (8 con traza calibrada y detección automática de partido) + ~100 caminos secundarios integrados desde geoprocesamiento QGIS.
- 632 partes diarios históricos migrados por bulk desde CSV + registro continuo de nuevas tareas.
- 49 vehículos institucionales catalogados con 1.203 vinculaciones a tareas.
- Sistema de sello digital **v4** con QR a Google Maps + altitud GPS + trazabilidad de versión + anti-sobresello.
- Módulo de reportes con 4 charts institucionales + tabla filtrable + export CSV/PDF.
- Modelo de **4 roles** (público / técnico de zona / gerencia / admin) con RLS zonal preparado.

**Diferenciales técnicos** que la Provincia no tiene hoy en ningún otro sistema equivalente:

1. **Detección automática de partido** a partir de progresiva + ruta (interpolación sobre `CHAIN_RPxx` + point-in-polygon contra `partidos_zona_vi.geojson`).
2. **Interpolación de progresiva → coordenadas** en RPs y caminos secundarios: si la foto no trae GPS en su EXIF, la app pide la progresiva y la ubica automáticamente sobre la traza (bundle CHAIN+ANCHORS para RPs, geojson recorrido con Haversine para caminos).
3. **Autocomplete inteligente de caminos** con recorrido encadenado (ej. "Saladillo — La Barrancosa — Micheo") calculado desde las denominaciones de tramos del geojson.
4. **Sistema anti-sobresello**: al re-editar una foto ya estampada, el sistema detecta el banner viejo, lo corta y aplica el nuevo con la misma métrica (imperceptible al ojo).
5. **Workflow campo → oficina**: la foto se captura cruda en el móvil (sin sello) y se sella al aprobar en oficina con los datos ya armonizados. Permite corregir GPS/ruta/prog antes del sellado definitivo. Nuevas columnas `estado_workflow` + `validado_geo` + `sello_version` en `relevamientos`.
6. **Dos apps móviles complementarias**:
   - **Modo Avanzado** (`dvba_campo.html`) con wizard + selector de tipos/estados + edición fina.
   - **Modo Básico** (`dvba_campo_lite.html`) minimalista: solo botón "Sacar foto" + GPS. Se completa todo en oficina. Diseñada para operarios sin fluidez tecnológica.
   - Ambos modos conviven bajo la **misma PWA** (`app.html` como bootstrap único). El usuario alterna con un toggle interno; la instalación en el celular queda como un solo ícono "SIG Vial PBA".
7. **Modelo Tipo↔Estado** con árbol de 10 categorías + sub-atributos condicionales (superficie, modalidad) y **sub-atributos implícitos** deducidos por regex del nombre del tipo (v9.18a).
8. **Reportes PDF institucionales** generados en el browser (jsPDF + autotable, sin backend), con la paleta oficial DVBA de 8 colores cotejada contra el Informe Mensual Gerencia Ejecutiva.
9. **Roles multi-zona** con perfil por usuario (`usuarios_perfil`), zona en cada registro y UI zone-aware: técnicos ven solo su zona, gerencia consolida todas, público consulta solo el mapa base.
10. **Anti-FOUC en la UI de roles**: los elementos "solo gerencia" arrancan ocultos por CSS y se revelan por JS únicamente si el rol lo autoriza — sin flash visible de contenido no autorizado al cargar.
11. **Sello v4 overlay semitransparente** (agosto 2026): el banner del sello NO se agrega debajo de la foto (que le cambiaría el ratio y la haría verse achatada) sino que se dibuja ENCIMA de los últimos 180-270px con fondo gradient `rgba(0,0,0,0.55→0.75)`. La foto conserva 100% su ratio original. QR con logo DVBA al centro (error correction H permite tapar 30% sin romper escaneo).
12. **Metadatos EXIF completos** en cada foto (v8.12+): GPS (lat/lng/altitud/timestamp), Make=`DVBA`, Model=`SIG Vial PBA · Modo Básico/Avanzado`, Software con versión y sello, ImageDescription con ruta+km+tipo, UserComment con JSON completo del registro. Google Photos / Windows Fotos / iPhone muestran la ubicación en mini-mapa. Trazabilidad forense: cualquiera con exiftool ve todo el registro adentro del archivo.
13. **Arquitectura de sello unificado** (v8.11+): un solo módulo `datos/sello_v4.js` como fuente de verdad — importado por portal, partes_diarios y móvil. Antes había 3 copias embebidas que se desincronizaban con cada fix. Cambio arquitectónico crítico para mantenibilidad.
14. **4 flujos coordinados de creación/edición de registros** (v8.66e): (a) desde móvil con GPS auto-ubicado + auto-completado con armonizador, (b) desde el mapa con `📍 Nuevo Pin` + arrastre, (c) por progresiva con `🎯 Ubicar` (inverso RP+km → lat/lng con CHAIN+ANCHORS), (d) edición fluida arrastrando pins que recalcula todo al vuelo.
15. **Sidebar drawer colapsable** (Ctrl+B) que libera 100% del mapa para navegación GIS sin renunciar al form de edición.
16. **Sistema de reportes unificado Red Vial Provincial** (v8.29-v8.42 · agosto 2026): un único panel genera reportes homogéneos de Red Vial Provincial Primaria (RPs) y Secundaria (Caminos), con selección manual por click en el mapa (halo dorado #ffb800), chip contador mixto `🛣 N rutas · 🚜 M tramos`, lista expandible para deseleccionar item por item, y PDF combinado con 2 secciones consecutivas cuando hay ambos tipos. Header institucional con logo DVBA + banner sello "📋 Datos oficiales · Fuente: DVBA - PBA". Tabla homogénea entre tipos (Partido / Nomencl / Tramo / Denominación / Clase-chip / Sentido / Km GIS / Km Oficial) aprovechando `CARACT_VIALES.tramos[]` del CSV oficial SALADILLO_RED (96 tramos, 15 RPs).
17. **Mapa SVG generado en el browser** para incluir en el PDF: dibuja contornos de partidos (con nombres itálica), ciudades de referencia, trazas coloreadas por CLASE, mojones (opcional) y registros (opcional) dentro del bbox del reporte — sin necesidad de tiles OSM. Alternativa "Captura real" con `leaflet-image` para incluir el basemap OSM completo. Ambos opcionales según checkbox.
18. **Nomenclatura oficial DVBA aplicada** en toda documentación institucional: Red Vial Provincial Primaria = RPs, Secundaria = Caminos, Terciaria = Caminos municipales (roadmap). Consistencia entre PDFs, títulos y sellos.
19. **Paleta minimalista PBA (Anexo III)** aplicada en todo el portal: sacados fondos oscuros tipo IDE del panel de edición, migrado a fondos claros con paleta institucional (turquesa #00aec3, verde #22a954, rojo #BE1717, ámbar #c47a00, gris #838383). Tipografía Encode Sans + Roboto (Google Fonts).

---

## 2. Arquitectura

- **Frontend**: HTML5 + CSS3 + JavaScript vanilla (sin frameworks). Portable, sin dependencias de build, deployable en GitHub Pages sin CI/CD.
- **Cartografía**: Leaflet 1.9.4 + OpenStreetMap base + capa satelital opcional.
- **Backend**: Supabase (PostgreSQL 15 + Auth JWT + Storage + Row Level Security).
- **PWA**: Service Worker con estrategia network-first + cache offline + fallback a HTML cacheado + Background Sync para cola de registros pendientes.
- **Charts**: Chart.js 4.4 (CDN).
- **PDF**: jsPDF 2.5 + jsPDF-autotable 3.8 (client-side, sin backend).
- **EXIF**: exifr (CDN) para lectura de GPS de la foto durante la subida directa desde escritorio.
- **QR**: qrcode-generator (embebido, sin dependencia online) para el QR de Google Maps en el sello.
- **Datos geográficos**: geojsons procesados desde QGIS 3.42 con PyQGIS, scripts Python propios (`gen_ruta_bundle.py`, `recortar_zonavi.py`, `calcular_longitudes_red_vial.py`).
- **Hosting**: GitHub Pages (`https://lemeit.github.io/DVBA/`).
- **Repositorio**: [`lemeit/DVBA`](https://github.com/lemeit/DVBA) — código abierto para consulta y aportes.

Al instalarse en el celular, la app se identifica como **SIG Vial PBA** (nombre y short_name en `manifest.json`) con la descripción *"Sistema web integrado para la gestión de la red vial provincial · Piloto Zona VI Saladillo"*.

---

## 3. Estado al momento de la presentación

SIG Vial PBA está en **producción efectiva** para el uso diario de la División Técnica Zona VI. Las versiones de código correspondientes al snapshot de este informe son:

- **Familia escritorio** (portal `index.html`, módulo Plan de Seguridad `partes_diarios.html`, módulo Reportes `reportes.html`, panel Admin `admin_usuarios.html`) → **v8.68**
- **Familia móvil** (PWA unificada `app.html` — Modo Básico `dvba_campo_lite.html` + Modo Avanzado `dvba_campo.html` + service worker `sw.js`) → **v9.94** (cache `dvba-campo-v9.94`)
- **Módulo sello institucional** (`datos/sello_v4.js`) → **v4** con 3 presets de altura (Normal/Mediano/Mínimo · agosto 2026)
- **Guía de usuario online** (MkDocs Material, publicada por GitHub Actions en cada push que toque `wiki-src/**`) → `lemeit.github.io/DVBA/wiki/`

> **Nota sobre las versiones citadas:** el sistema es de desarrollo activo. Todas las referencias a versiones específicas en este documento corresponden al snapshot arriba indicado. Las versiones más recientes en producción se pueden verificar en:
>
> - La constante `CACHE_NAME` del archivo `sw.js` para la versión activa del service worker móvil.
> - La constante `APP_VERSION` en el bloque `<script>` de cada HTML del portal escritorio.
> - El footer institucional visible en las apps (sincronizado dinámicamente con la constante desde v8.68).
> - La **bitácora del proyecto** con el historial completo de versiones desde v9.0 hasta la actualidad, disponible en el repositorio en `wiki-src/04-Desarrollo-y-Estado-Actual/bitacora.md`.

**Cambios más significativos incorporados entre el diseño inicial del informe (28 julio) y esta versión (12 agosto):**

- **Portal público multi-zona** — el sistema pasó de piloto Zona VI a herramienta panorámica PBA con las 12 zonas viales completas, 135 partidos con clipping automático de rutas contra polígonos zonales, y paleta institucional de 12 tonos armónicos por zona.
- **Comentarios cross-zona** (`comentarios_zona` · SQL_13) — modelo colaborativo: técnicos editan su zona, Gerencia comenta transversal, Admin ejecuta cambios cross-zona desde un panel único con cola de solicitudes.
- **PDF Informe Gerencial** — implementación del layout oficial DVBA de 8 tareas + equipos por categoría + grid fotográfico + watermark BORRADOR + rango multi-mes (v8.65 series).
- **Sello v4 con presets** — reemplazo del slider fijo por 3 botones (Normal 100% / Mediano 75% / Mínimo 50%) al aprobar cada foto, con detección de sobreescritura y advertencia para registros sin backup original.
- **Fix RP61 duplicada en vista PBA** — clipping inverso contra partidos VI evita duplicación de trazas calibradas en la vista panorámica.
- **Wiki publicada** — migración de vault Obsidian a MkDocs Material, con CI que rebuildea automáticamente en cada push. Footer institucional + paleta DVBA + logo unificado.
- **Fase A de IA implementada** (piloto) — clasificador automático de fotos usando Google Gemini 2.5 Flash Vision (ver sección 8.4).

**Documentación técnica de referencia (en el repositorio):**

- **[`README.md`](../README.md)** — presentación general del sistema.
- **[`ROADMAP.md`](../ROADMAP.md)** — hoja de ruta consolidada, pendientes priorizados.
- **Guía de usuario online** — [lemeit.github.io/DVBA/wiki/](https://lemeit.github.io/DVBA/wiki/) con 15 capítulos + mockups de la UI + FAQ. Publicada automáticamente por GitHub Actions.
- **[`docs/PLAN_ROLES_MULTIZONA.md`](PLAN_ROLES_MULTIZONA.md)** — visión de escalado a las 12 zonas provinciales + roadmap de 5 fases.
- **[`docs/PLAN_STORAGE.md`](PLAN_STORAGE.md)** — análisis de consumo Supabase y proyección de costos.
- **[`docs/ANALISIS_INFORME_GERENCIAL_DVBA.md`](ANALISIS_INFORME_GERENCIAL_DVBA.md)** — cotejo con el formato oficial del Informe Mensual Gerencia Ejecutiva.
- **[`docs/MODELO_TIPOS_ESTADOS.md`](MODELO_TIPOS_ESTADOS.md)** — referencia única del modelo Tipo↔Estado con árbol, sub-atributos condicionales e implícitos.
- **[`docs/REFERENCIA_NOMENCLADOR_1989.md`](REFERENCIA_NOMENCLADOR_1989.md)** — fuente autoritativa del nomenclador vial DVBA 1989 (Ing. Bertoni), citable en el informe.
- **`wiki-src/04-Desarrollo-y-Estado-Actual/bitacora.md`** — timeline técnico completo desde v9.0 hasta la versión actual, con reconstrucción del gap mayo-junio 2026 y todas las series de versiones (v8.66f, v8.67, v8.68, v9.93, v9.94) documentadas.
- **[`docs/SETUP_AUTH.md`](SETUP_AUTH.md)** — procedimiento de configuración de Supabase Auth + RLS.

---

## 4. Módulos implementados (para desarrollar en el informe)

### 4.1 Modo Avanzado (`dvba_campo.html` v9.78)

PWA instalable con wizard completo de captura: elegir categoría → tipo → estado → ruta/camino/prog → foto → GPS. Cola offline con sincronización en background al recuperar conexión. Sesión persistente por JWT cacheado en `localStorage` (funciona sin red si el usuario ya se logueó al menos una vez). Modo alto contraste ("modo SOL") para uso al aire libre.

### 4.2 Modo Básico (`dvba_campo_lite.html` v9.78)

App minimalista de captura rápida. UI reducida a lo esencial: botón central grande "Sacar foto", banner GPS al pie del header, footer con contador de pendientes / cerrar sesión / info. Todos los demás datos (tarea, ruta, tipo) los completa alguien en oficina. Es el `start_url` del `manifest.json`, es decir, la app que abre por default al instalar la PWA — pensada para operarios de campo sin fluidez con formularios largos. Guarda cola offline igual que la completa. Auth offline via JWT parseado desde `localStorage` (sin llamar a `getUser()` que requiere red).

### 4.3 Portal escritorio (`index.html` v8.66e)

Mapa Leaflet con 8 partidos, 15 RPs y 100 caminos secundarios. Sidebar con pills agrupadas de rutas y caminos, panel de capas toggleable (RP / Camino / Tareas), modal SIG Vial estilo DNV, cursor flotante con progresiva al hover, layer 📋 **Tareas** que dibuja cada parte sobre la traza real con color por antigüedad (rojo últimos 7 días, dorado 30, violeta 90, gris histórico). Cola de pendientes con sellado + rotación en oficina. Picker de zona en el header preparado para el escalado multi-zona. Panel-footer institucional fijo con resumen de la zona activa.

### 4.4 Plan de Seguridad en la Circulación (`partes_diarios.html` v8.66e)

Módulo de carga de tareas diarias alineado al Google Form oficial de Gerencia Ejecutiva DVBA. Cambia el nombre del formulario oficial ("Parte") a la jerga local ("Tarea") en toda la UI visible. Detección automática de partido, autocomplete custom de caminos con recorrido encadenado, dropdown único primaria+secundaria con typeahead nativo (`<datalist>`), progresivas con coma decimal en formato oficial DVBA, filtros de partido en toolbar, columna indicadora de fotos por tarea, flujo ±5 días hábiles para asociar relevamientos.

**Subida directa de foto con sello (v7.89-91)** — botón "📷 Subir foto" en cada sección (previa/posterior) que abre un modal con:

- Input file → preview.
- Lectura del GPS del EXIF con `exifr` (si la foto trae ubicación guardada).
- **Fallback por progresiva**: si no hay EXIF, el usuario tipea la progresiva y se interpola sobre el bundle de la RP (`CHAIN_RPxx` + `ANCHORS_RPxx` con Haversine) o sobre el geojson del camino secundario (recorrido de vértices con Haversine, km 0 = extremo del geojson).
- Sellado con el **módulo compartido `datos/sello_v4.js`** (mismo sello v4 institucional que la app móvil, marcado como origen "oficina").
- Upload a Storage + INSERT en `relevamientos` con estado `aprobado` + vinculación al parte vía `parte_fotos`.

Como resultado, cualquier operativo puede completar un parte 100% desde la oficina si viene con fotos crudas del campo — no depende de que se hayan cargado antes desde la app móvil.

### 4.5 Módulo Reportes (`reportes.html` v8.66e)

Reportes institucionales con:

- **KPIs**: total km, tareas ejecutadas, partidos activos, categorías intervenidas.
- **4 charts**: km por tarea (paleta oficial DVBA de 8 colores), timeline mensual (5 meses hacia atrás con línea de tendencia mimic del reporte oficial), uso de vehículos, acciones por vía.
- **Filtros en vivo** con debounce: rango de fechas, zona (habilitado con Fase 3 activa), partido, RP/camino, tarea.
- **Tabla filtrable** con fecha, tarea, vía, partido, km, equipos, foto ✓/✗.
- **Export CSV** con headers oficiales.
- **Export PDF institucional** con jsPDF + autotable: portada + página de charts + tabla completa. Layout cotejado contra el Informe Mensual Gerencia Ejecutiva.

### 4.6 Multi-zona y roles (Fase 1 + 2 implementadas)

Modelo de 4 niveles:

| Rol | Alcance | Ve panel Visualización | Ve Reportes | Picker zonas |
|---|---|---|---|---|
| **Público** (sin login) | Mapa + info rutas/caminos | ✗ | ✗ | ✓ (explora) |
| **Técnico de zona** | CRUD de su zona | ✗ | ✗ | ✗ (zona fija) |
| **Gerencia / Auditoría** | Todas las zonas | ✗ | ✓ | ✓ (elige) |
| **Admin / Desarrollador** | Todo + gestión de usuarios | ✓ | ✓ | ✓ (elige) |

Implementación técnica:

- Tabla `usuarios_perfil` (`user_id`, `nombre`, `rol`, `zona`) con CHECK constraint que exige zona si el rol es técnico.
- Columna `zona` en `partes_diarios` y `relevamientos`, con backfill a `'VI'` para lo histórico.
- Funciones helper SQL `current_user_zona()` y `current_user_rol()` con `SECURITY DEFINER STABLE` para uso eficiente en RLS.
- Módulo compartido `datos/perfil.js` que carga el perfil al login, lo cachea en `localStorage['dvba_perfil']` y expone `DVBA_PERFIL.zonaActual()` como fallback para INSERTs.
- Fill automático de `zona` en INSERTs de las 4 apps.
- UI zone-aware: header muestra `nombre` del usuario con tooltip `rol · Zona X`, elementos marcados `data-solo-gerencia="1"` ocultos por CSS al arranque (anti-FOUC) y revelados por JS solo si el rol lo autoriza, picker de zonas oculto a técnicos con su zona forzada al perfil.

Pendiente (documentado en `PLAN_ROLES_MULTIZONA.md`):

- **Fase 3** · SQL 9 con las RLS zonales reales para que un técnico no pueda leer datos de otras zonas ni siquiera por API directa.
- **Fase 4** · Panel `admin_usuarios.html` para dar de alta / cambiar rol / cambiar zona sin tocar SQL.
- **Fase 5** · Reporte PDF oficial de Gerencia con el layout completo (portada + 2 hojas por zona + luminarias LED).

---

## 5. Metodología QGIS y geoprocesamiento

Cada RP se procesa siguiendo un flujo estandarizado documentado en la bitácora:

1. En QGIS: filtrar → corregir geometrías → multiparte a monoparte → disolver → exportar GeoJSON unificado en EPSG:4326.
2. Digitalizar gaps (cruces de río sin puente, zonas urbanas) sobre imagen satelital con snap activado. Marcar con `es_gap=1` en la tabla de atributos.
3. Preparar capa de mojones ajustados con campos `Name` = "0KM", "50KM", etc. y `sentido_prog` = 'N'|'S'|'E'|'O'.
4. Ejecutar `python scripts/gen_ruta_bundle.py rpXX` → produce `datos/rutas_rpXX.js` con `CHAIN_RPxx` (traza como array de `[lon,lat]`) + `ANCHORS_RPxx` (tabla km ↔ acc para interpolar progresiva).
5. Registrar el bundle en `index.html`, `partes_diarios.html` y `dvba_campo.html`; bumpear la versión unificada.

Para caminos secundarios: script `calcular_longitudes_red_vial.py` que procesa el GeoPackage por partido, calcula longitudes con Haversine WGS84, deduce sentido cardinal offline con `direccionCardinal(latI, lonI, latF, lonF)` y exporta a `caminos_secundarios_NNN_final.geojson`.

**Precisión** documentada:

- Progresiva por Haversine 2D en terreno llano → error < 0.1%.
- Interpolación progresiva → coordenadas sobre RPs con bundle CHAIN+ANCHORS → ±100 m.
- Ídem sobre caminos secundarios (km 0 = extremo del geojson) → ±500 m; se documenta la limitación de posible inversión de sentido si el geojson quedó con orientación opuesta al catastro.

---

## 6. Modelo Tipo ↔ Estado

Ver documento técnico completo en `docs/MODELO_TIPOS_ESTADOS.md` (v1.1, actualizado el 18 de julio de 2026).

El sistema separa el registro vial en **3 dimensiones**:

| Dimensión | Definición | Ejemplo |
|---|---|---|
| **Elemento** | Qué objeto físico se releva | Calzada, señal, puente, banquina, luminaria |
| **Condición** | Cómo está ese elemento | Bueno / Regular / Malo / Crítico |
| **Acción** | Qué tarea se hizo o hay que hacer | Reconformado, desmalezado, bacheo |

Árbol de **10 categorías** con estados coherentes por categoría, **estados universales de seguimiento** (`pendiente`, `en_obra`, `reparado`) y **sub-atributos condicionales** (superficie: asfalto/hormigón/tierra/…; modalidad: manual/mecánico/mixto).

**Innovación v9.18a — sub-atributos implícitos**: cuando el nombre del tipo ya incluye la modalidad ("Desmalezado mecánico") o la superficie ("Mejoramiento con dolomita"), la UI **oculta** el selector correspondiente pero **guarda automáticamente** el valor implícito, evitando redundancia y posibles contradicciones. Detectado con regex documentado en la sección 4.1 del modelo.

---

## 7. Impacto esperado y medible

**En el corto plazo (Zona VI · 2026):**

- Reducción del tiempo de armado del parte mensual de Gerencia desde ~8 horas a ~30 minutos (estimado, a validar con datos reales al momento de la entrega).
- Trazabilidad completa de cada tarea: foto + GPS + progresiva + sello institucional con QR de Google Maps + firma digital vía JWT del usuario que cargó.
- Consulta cartográfica del histórico de intervenciones al alcance de un click.
- Detección automática de partido en el 100% de los casos con ruta + progresiva (sin trabajo manual del operativo).

**En el mediano plazo (multi-zona · 2027):**

- Cada zona vial administra sus datos con la misma herramienta.
- Gerencia Central consolida las 12 zonas en un dashboard único con exports PDF oficiales.
- Auditoría automática de discrepancias entre datos declarados y datos capturados.

**En el largo plazo (asistente AI + análisis predictivo · 2027+):**

- Toma de decisiones basada en datos con soporte de IA (ver sección 8.4).
- Priorización automática de intervenciones según deterioro y presupuesto.
- Sistema modelo para replicar en otras provincias argentinas.

---

## 8. Visión de futuro (secciones para desarrollar en el informe)

### 8.1 Escalado multi-zona a las 12 zonas viales de PBA

SIG Vial PBA fue diseñado desde el inicio pensando en las 12 zonas. Sistema de 4 niveles con RLS por zona ya diseñado y con Fase 1+2 implementadas. Faltan Fases 3-5 (RLS real, panel admin, PDF gerencia) — todo documentado en `PLAN_ROLES_MULTIZONA.md` con estimación de ~10 sesiones de desarrollo. Cada zona técnica podrá cargar y consultar sus datos operativos, mientras Gerencia Central consolida las 12 zonas en el mismo dashboard.

### 8.2 Reportes PDF oficiales replicando el formato DVBA existente

Fase 5 del plan de roles: PDF completo con portada institucional, 2 hojas por zona (administrativa + GIS), tabla luminarias LED, anexo fotográfico, paleta de 8 colores oficial por categoría de tarea. El análisis del layout oficial ya está documentado en `ANALISIS_INFORME_GERENCIAL_DVBA.md`. El stack (jsPDF + autotable + Chart.js server-side rendering) ya se probó en `reportes.html`.

### 8.3 Mapa dinámico embebido en los reportes

Reemplazo de exports manuales de QGIS por captura automática del mapa Leaflet ya renderizado del portal, con los filtros del reporte aplicados (fecha, partido, tarea). Reduce el flujo de trabajo de horas a segundos.

### 8.4 ⭐ Inteligencia Artificial aplicada a la gestión vial

**Diferencial destacado del sistema.** SIG Vial PBA es la primera plataforma técnica de la Dirección de Vialidad de la Provincia de Buenos Aires que integra un **modelo de lenguaje multimodal** para asistir el trabajo cotidiano de campo, oficina y gerencia.

La propuesta se estructura en **cuatro fases** con horizonte creciente de complejidad y ambición. La Fase A se implementa como demostrador funcional al momento de la entrega del informe; B, C y D se documentan como roadmap con estimación realista de recursos, plazos y costos.

#### Selección de modelo

Antes de comprometer la arquitectura, se realizó un análisis comparativo de las alternativas disponibles al mes de agosto de 2026. Se contemplaron proveedores tradicionales, opciones open source y modelos de fabricantes no-occidentales para asegurar independencia estratégica.

| Modelo | Free tier | Costo prod. | Visión | Español | Latencia | Observaciones |
|---|---|---|---|---|---|---|
| **Google Gemini 2.5 Flash** ⭐ | **500 req/día** | US$ 0.075/M in | ✓ nativa | Excelente | 1-2 s | Multimodal, contexto 1M tokens |
| DeepSeek V3.1 | US$ 5 iniciales | US$ 0.14/M in | ✓ (VL) | Bueno | 1-2 s | 10× más barato en producción |
| OpenAI GPT-4o mini | No | US$ 0.15/M in | ✓ | Excelente | 1-2 s | Referencia de mercado |
| Anthropic Claude Haiku | No | US$ 0.25/M in | ✓ | Excelente | 1-2 s | Mejor razonamiento largo |
| Kimi K2 (Moonshot) | US$ 5 iniciales | US$ 0.30/M in | Limitada | Aceptable | 2-3 s | Fuerte en documentos largos |
| Ollama + Qwen 2.5-VL | **Gratis total** | Solo hardware | ✓ | Aceptable | 2-5 s CPU | Ejecución local, cero datos externos |

**Modelo primario elegido: Google Gemini 2.5 Flash.** Fundamentos:

- **Tier gratuito genuino** (500 requests/día = ~15.000/mes) suficiente para cubrir el piloto Zona VI completo y las primeras zonas adicionales sin costo alguno.
- **Multimodalidad nativa** — texto y visión con la misma API key, sin componer proveedores.
- **Baja latencia** (~1-2 seg por request), aceptable para uso interactivo desde la app móvil.
- **Calidad en español** al nivel de GPT-4o mini y Claude Haiku.
- **Integración simple** con Supabase Edge Functions vía REST estándar.

**Plan B — DeepSeek V3.1** para el escalado a las 12 zonas. Aproximadamente 10 veces más económico que GPT-4o mini, API compatible con OpenAI. La arquitectura permite el cambio de proveedor sin rediseño.

**Plan C — Ollama con Qwen 2.5-VL local** si el área legal o institucional exige que **ningún dato salga de la red DVBA**. Requiere infraestructura propia (una GPU dedicada o Mac con Apple Silicon), pero elimina cualquier dependencia de proveedores externos.

#### Fase A · Clasificador automático de fotos con visión (piloto Zona VI · 2026)

**Estado al momento del informe: implementada como demostrador funcional.**

Al aprobar una tarea en el portal de escritorio o al capturar una foto desde la app móvil, un botón **"🤖 Sugerir clasificación"** analiza la imagen y devuelve automáticamente el tipo de intervención, estado y nivel de confianza asociado. El operador confirma con un toque o corrige si difiere del criterio del modelo. Cada corrección se registra como feedback para futuras iteraciones.

- **Ejemplo de salida:** para una foto de un bache profundo con desprendimiento de asfalto, el modelo devuelve `{tipo: "Bache", estado: "Crítico", superficie: "Asfalto", confianza: 0.87}` con una descripción textual del deterioro observado.
- **Stack:** Supabase Edge Function (Deno) → Gemini 2.5 Flash con capacidad de visión → JSON estructurado consumido por el frontend.
- **Métricas de seguimiento:** tasa de confirmación sin cambios (proxy de precisión), tiempo promedio de aprobación con vs. sin asistencia, tipos de tarea con mayor tasa de acierto.
- **Beneficio directo:** normalización de categorías (evita que un mismo defecto se cargue de tres maneras distintas por tres técnicos), velocidad de captura en campo, base de datos etiquetada que sirve como insumo para fases posteriores.

#### Fase B · Resumen ejecutivo semanal automatizado (roadmap · Q4 2026)

Cada lunes a las 8:00 de la mañana, una tarea programada compila y envía por correo institucional un informe ejecutivo de una página para la Gerencia de Zona VI (y posteriormente Central).

**Ejemplo de contenido generado:**

> Zona VI · Semana del 8 al 14 de agosto de 2026 · 47 relevamientos nuevos, 12 clasificados como críticos. Concentración detectada en 3 tramos: RP61 km 15-18 (5 baches), RP46 km 8-12 (4 baches) y Cno. 305-04 (3 alcantarillas con obstrucción). 8 tareas ejecutadas por cuadrillas propias. Tramo con mayor deterioro relativo respecto al mes anterior: RP47 km 20-25.

**Valor institucional:** la Gerencia no necesita entrar al sistema, recibe la información filtrada y contextualizada en su bandeja de entrada. Reduce la barrera técnica al mínimo posible.

#### Fase C · Detección de duplicados y búsqueda semántica (roadmap · Q1 2027)

**Detección de duplicados:** al cargar un pin nuevo desde el móvil, el sistema compara la posición GPS y el embedding visual de la foto contra los relevamientos existentes en un radio de 100 metros y los últimos 30 días. Si detecta similitud alta, muestra un aviso: *"Esta tarea podría ser la misma que #427 registrada el 22 de julio. ¿Continuar o vincular?"*. Permite trackear la evolución de un mismo defecto en el tiempo y evita duplicar trabajo.

**Búsqueda semántica en lenguaje natural:** la barra de búsqueda del módulo Reportes acepta consultas como *"mostrame baches críticos en RP61 sin reparar del último mes"* y el modelo las traduce a filtros SQL parametrizados, ejecuta la consulta y renderiza el resultado con mapa y tabla. Elimina la necesidad de conocer el esquema de la base o navegar múltiples dropdowns.

**Tecnología:** Supabase pgvector para embeddings + Gemini para el parsing de la consulta en lenguaje natural.

#### Fase D · Priorización asistida y optimización de recorridos (roadmap · Q2-Q3 2027)

**Priorización asistida.** Dado un conjunto de tareas pendientes en un partido, el modelo las ordena según criticidad ponderando: tipo × estado × antigüedad × TPDA (tránsito promedio diario) estimado × cercanía a escuela, hospital o centro urbano. Presenta a la Gerencia una lista sugerida para asignar cuadrillas. Combina reglas explícitas del pliego DVBA con inferencia del modelo sobre casos ambiguos.

**Optimización de recorrido diario.** Dado un conjunto de N tareas a ejecutar en la jornada, sugiere el orden óptimo de visita minimizando kilómetros recorridos y horas hombre, respetando restricciones (rutas transitables, tipo de cuadrilla adecuado para cada tarea, ventanas horarias). Se apoya en Google OR-Tools (solver open source) combinado con el criterio experto del modelo.

**Impacto medible:** ahorro real de kilómetros y horas hombre. Es la materialización operativa del concepto de *optimización de recursos* que se persigue con el sistema.

#### Presupuesto realista y comparativa

Todos los costos están expresados en dólares estadounidenses al valor de agosto de 2026.

| Horizonte | Volumen mensual | Costo con Gemini | Costo con DeepSeek | Costo Ollama local |
|---|---|---|---|---|
| Fase A · piloto Zona VI | ~1.500 req | **US$ 0** (free tier) | US$ 0,20 | US$ 0 |
| Fase A+B · 3 zonas | ~5.000 req | **US$ 0** (free tier) | US$ 1 | US$ 0 |
| Fase A-C · 12 zonas | ~20.000 req | ~US$ 3 | US$ 0,50 | US$ 0 |
| Fase A-D completa | ~50.000 req | ~US$ 10 | US$ 2 | US$ 0 |

**Comparación con software vial comercial:** licencias tradicionales como ESRI Roads, Bentley OpenRoads Designer o soluciones PMS del mercado tienen costos que oscilan entre USD 500 y USD 2.000 por mes y por licencia. **La solución de IA propuesta para toda la Provincia cuesta menos que un almuerzo por mes**.

Este contraste no busca minimizar el valor de las herramientas comerciales, sino mostrar que la barrera de entrada a la IA aplicada ya no es económica sino de conocimiento y decisión institucional.

#### Recursos necesarios

**Recursos humanos.** El plan se sostiene con el modelo actual de desarrollo unipersonal (División Técnica, Zona VI). Ninguna de las fases A a C requiere sumar equipo. La Fase D podría beneficiarse de la incorporación part-time de un analista de datos, o alternativamente de consultoría puntual.

**Recursos técnicos.**

- Cuenta Google Cloud (gratuita, sin necesidad de tarjeta para el free tier).
- Supabase actual — las Edge Functions y pgvector ya están disponibles en el plan Free contratado.
- Cuenta de correo institucional configurada para envío automatizado (opciones evaluadas: Postmark, Resend, o SMTP institucional).

**Recursos institucionales (fuera del código).**

- Aprobación del área legal para procesar fotografías institucionales en API de un proveedor externo (Gemini). Alternativa: cláusula específica en el contrato Google Cloud, o pasar a Plan C con Ollama local.
- Definición del criterio oficial DVBA para tipo y estado — el modelo debe aprender de una fuente autoritativa consensuada, no de decisiones ad-hoc de cada técnico.

#### Riesgos y mitigación

| Riesgo | Mitigación |
|---|---|
| Privacidad de datos institucionales | Plan C (Ollama local) elimina la exposición externa |
| Dependencia de un solo proveedor | Arquitectura de proxy permite cambio de modelo sin rediseño |
| Costo creciente al escalar | Free tier cubre volumen inicial · migración a DeepSeek reduce 10× |
| Errores del modelo (alucinaciones) | Toda sugerencia es siempre confirmable por el operador humano |
| Cambios de precio del proveedor | Comparador multi-modelo integrado desde el diseño |

#### Estado del arte y ventaja institucional

Al momento de la entrega del presente informe, ningún organismo vial provincial argentino tiene documentada una integración productiva de IA generativa para su gestión operativa. La DVBA tiene la oportunidad de posicionarse como **caso pionero a nivel nacional**, con una implementación probada, económica y escalable, desarrollada íntegramente desde una zona técnica del interior.

### 8.5 Otras líneas de investigación aplicada

- **Piloto TMD** (Tránsito Medio Diario) con cámara de video en rutas seleccionadas.
- **Integración con acelerómetro / IRI-lite** para medir condición de pavimento en tiempo real (Rural IT u opciones similares).
- **Medición V85** (velocidad percentil 85) con LIDAR o radar acoplado a móvil de la zona.
- **Modelo de deterioro por tipo de superficie** con series temporales para predecir intervenciones.
- **QR de sello ↔ traza en tiempo real**: fiscalizador escanea foto sellada y aparece en el mapa completo con la posición y el histórico del tramo.

---

## 9. Reconocimiento y equipo

- **Desarrollo**: Ing. Luciano Lamaita — División Técnica DVBA Zona VI Saladillo.
- **Institución destinataria**: Dirección de Vialidad de la Provincia de Buenos Aires (DVBA), con el Departamento Zona VI Saladillo como ámbito de validación del piloto.
- **Datos oficiales cotejados contra**:
  - *Nomenclador de Rutas DVBA 1989* (Ing. Luis F. Bertoni, Jefe Interino División Técnica) — fuente autoritativa de progresivas y sentido de RPs.
  - Ministerio de Infraestructura y Servicios Públicos PBA — datos catastrales.
  - ARBA — límites de partidos.
  - IGN (Instituto Geográfico Nacional) — cartografía base.
  - Manual de Señalización Vertical MSV 2017 — vocabulario de categorías de tipos.
- **Infraestructura**: hosting gratuito GitHub Pages + backend Supabase (plan Free en piloto). Costo institucional a la fecha: **$0**.
- **Sin costo institucional** hasta la fecha para el desarrollo del piloto — el proyecto se autofinancia con el trabajo del desarrollador y las herramientas open source / con plan free.

---

## 10. Anexos previstos para el informe final

- **Screenshots** del sistema en producción con datos reales (8-12 capturas: portal con capa Tareas, modal SIG Vial, panel roles, app móvil completa, app móvil lite, sello v4 sobre foto real, modal Subir foto con EXIF, reportes con charts, PDF export).
- **PDF de ejemplo** generado por el módulo Reportes (mes representativo, ej. mayo o junio 2026) como demostración funcional.
- **Manual de usuario** de la app móvil ([`docs/guia_dvba_campo.html`](guia_dvba_campo.html)).
- **Referencia del Nomenclador 1989** ([`docs/REFERENCIA_NOMENCLADOR_1989.md`](REFERENCIA_NOMENCLADOR_1989.md)).
- **Análisis del Informe Oficial DVBA** para cotejo ([`docs/ANALISIS_INFORME_GERENCIAL_DVBA.md`](ANALISIS_INFORME_GERENCIAL_DVBA.md)).
- **Diagrama de arquitectura** en alto nivel (a preparar antes de la entrega).
- **Bibliografía formal** con referencias completas (a compilar antes de la entrega).

---

## 11. Check-list de entrega (bases del concurso)

- [ ] Formato: A4, Arial o Calibri 12, interlineado 1.5, extensión libre.
- [ ] **Anonimato**: seudónimo en la portada. Ningún dato personal en el cuerpo del trabajo.
- [ ] Sobre cerrado aparte con seudónimo en el frente y datos del autor adentro.
- [ ] 1 original impreso + 2 copias impresas + PDF digital.
- [ ] Entregar en la División Publicaciones y Biblioteca hasta el **16 de septiembre de 2026** inclusive.
- [ ] Dirigido al Sr. Administrador General.
- [ ] Bibliografía completa citada (fuentes, imágenes, estadísticas). Sin plagio.
- [ ] Preparar exposición para la Semana Vial.

---

_Última actualización: 28 de julio de 2026 · SIG Vial PBA en v8.66e (escritorio) / v9.93.1 (móvil)._
_Seudónimo tentativo: `lemeit` — a confirmar antes de la entrega._
