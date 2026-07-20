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
> **Estado del sistema al armar el documento:** apps de escritorio en **v8.2**, familia móvil en **v9.72**, sello institucional en **v4**, base multi-zona activa (Fase 1 + 2 implementadas).
> **Fecha de esta versión del informe:** 19 de julio de 2026.

---

## Nota terminológica

En este documento se distingue entre:

- **DVBA** → **Dirección de Vialidad de la Provincia de Buenos Aires**. Ente ejecutor del sistema, organizador del concurso, empleador del autor.
- **SIG Vial PBA** → **Nombre del sistema** que se presenta al concurso. Es el producto tecnológico desarrollado para la DVBA.
- **Zona VI Saladillo** → Ámbito operativo del piloto. La DVBA está organizada en 12 zonas viales; Zona VI es la sede del autor y el ámbito de validación del sistema.

---

## 1. Resumen ejecutivo

**SIG Vial PBA** es una plataforma web integral para el relevamiento, gestión y reporte de la red vial provincial de la DVBA. Cubre el flujo completo: desde la captura en campo con GPS (dos apps móviles PWA — una completa, una minimalista de captura rápida) hasta la generación de reportes PDF institucionales, pasando por el registro estandarizado de tareas diarias, la visualización cartográfica interactiva y un modelo de roles multi-zona diseñado para escalar a las 12 zonas de la Provincia.

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
   - **App completa** (`dvba_campo.html`) con wizard + selector de tipos/estados + edición fina.
   - **App lite** (`dvba_campo_lite.html`) minimalista: solo botón "Sacar foto" + GPS. Se completa todo en oficina. Diseñada para operarios sin fluidez tecnológica.
7. **Modelo Tipo↔Estado** con árbol de 10 categorías + sub-atributos condicionales (superficie, modalidad) y **sub-atributos implícitos** deducidos por regex del nombre del tipo (v9.18a).
8. **Reportes PDF institucionales** generados en el browser (jsPDF + autotable, sin backend), con la paleta oficial DVBA de 8 colores cotejada contra el Informe Mensual Gerencia Ejecutiva.
9. **Roles multi-zona** con perfil por usuario (`usuarios_perfil`), zona en cada registro y UI zone-aware: técnicos ven solo su zona, gerencia consolida todas, público consulta solo el mapa base.
10. **Anti-FOUC en la UI de roles**: los elementos "solo gerencia" arrancan ocultos por CSS y se revelan por JS únicamente si el rol lo autoriza — sin flash visible de contenido no autorizado al cargar.

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

SIG Vial PBA está en **producción efectiva** para el uso diario de la División Técnica Zona VI. La versión de código al armar este informe es:

- Familia escritorio (portal, módulo Plan de Seguridad, módulo Reportes) → **v8.2**
- Familia móvil (app completa, app lite, service worker) → **v9.72**

Documentación técnica de referencia (en el repo):

- **[`README.md`](../README.md)** — presentación general del sistema.
- **[`ROADMAP.md`](../ROADMAP.md)** — hoja de ruta consolidada, pendientes priorizados.
- **[`docs/PLAN_ROLES_MULTIZONA.md`](PLAN_ROLES_MULTIZONA.md)** — visión de escalado a las 12 zonas provinciales + roadmap de 5 fases.
- **[`docs/PLAN_STORAGE.md`](PLAN_STORAGE.md)** — análisis de consumo Supabase y proyección de costos.
- **[`docs/ANALISIS_INFORME_GERENCIAL_DVBA.md`](ANALISIS_INFORME_GERENCIAL_DVBA.md)** — cotejo con el formato oficial del Informe Mensual Gerencia Ejecutiva.
- **[`docs/MODELO_TIPOS_ESTADOS.md`](MODELO_TIPOS_ESTADOS.md)** — referencia única del modelo Tipo↔Estado con árbol, sub-atributos condicionales e implícitos.
- **[`docs/REFERENCIA_NOMENCLADOR_1989.md`](REFERENCIA_NOMENCLADOR_1989.md)** — fuente autoritativa del nomenclador vial DVBA 1989 (Ing. Bertoni), citable en el informe.
- **[`docs/bitacora.html`](bitacora.html)** — timeline técnico completo desde v9.0 hasta hoy, con reconstrucción del gap mayo-junio 2026.
- **[`docs/SETUP_AUTH.md`](SETUP_AUTH.md)** — procedimiento de configuración de Supabase Auth + RLS.

---

## 4. Módulos implementados (para desarrollar en el informe)

### 4.1 App móvil completa (`dvba_campo.html` v9.72)

PWA instalable con wizard completo de captura: elegir categoría → tipo → estado → ruta/camino/prog → foto → GPS. Cola offline con sincronización en background al recuperar conexión. Sesión persistente por JWT cacheado en `localStorage` (funciona sin red si el usuario ya se logueó al menos una vez). Modo alto contraste ("modo SOL") para uso al aire libre.

### 4.2 App móvil lite (`dvba_campo_lite.html` v9.72)

App minimalista de captura rápida. UI reducida a lo esencial: botón central grande "Sacar foto", banner GPS al pie del header, footer con contador de pendientes / cerrar sesión / info. Todos los demás datos (tarea, ruta, tipo) los completa alguien en oficina. Es el `start_url` del `manifest.json`, es decir, la app que abre por default al instalar la PWA — pensada para operarios de campo sin fluidez con formularios largos. Guarda cola offline igual que la completa. Auth offline via JWT parseado desde `localStorage` (sin llamar a `getUser()` que requiere red).

### 4.3 Portal escritorio (`index.html` v8.2)

Mapa Leaflet con 8 partidos, 15 RPs y 100 caminos secundarios. Sidebar con pills agrupadas de rutas y caminos, panel de capas toggleable (RP / Camino / Tareas), modal SIG Vial estilo DNV, cursor flotante con progresiva al hover, layer 📋 **Tareas** que dibuja cada parte sobre la traza real con color por antigüedad (rojo últimos 7 días, dorado 30, violeta 90, gris histórico). Cola de pendientes con sellado + rotación en oficina. Picker de zona en el header preparado para el escalado multi-zona. Panel-footer institucional fijo con resumen de la zona activa.

### 4.4 Plan de Seguridad en la Circulación (`partes_diarios.html` v8.2)

Módulo de carga de tareas diarias alineado al Google Form oficial de Gerencia Ejecutiva DVBA. Cambia el nombre del formulario oficial ("Parte") a la jerga local ("Tarea") en toda la UI visible. Detección automática de partido, autocomplete custom de caminos con recorrido encadenado, dropdown único primaria+secundaria con typeahead nativo (`<datalist>`), progresivas con coma decimal en formato oficial DVBA, filtros de partido en toolbar, columna indicadora de fotos por tarea, flujo ±5 días hábiles para asociar relevamientos.

**Subida directa de foto con sello (v7.89-91)** — botón "📷 Subir foto" en cada sección (previa/posterior) que abre un modal con:

- Input file → preview.
- Lectura del GPS del EXIF con `exifr` (si la foto trae ubicación guardada).
- **Fallback por progresiva**: si no hay EXIF, el usuario tipea la progresiva y se interpola sobre el bundle de la RP (`CHAIN_RPxx` + `ANCHORS_RPxx` con Haversine) o sobre el geojson del camino secundario (recorrido de vértices con Haversine, km 0 = extremo del geojson).
- Sellado con el **módulo compartido `datos/sello_v4.js`** (mismo sello v4 institucional que la app móvil, marcado como origen "oficina").
- Upload a Storage + INSERT en `relevamientos` con estado `aprobado` + vinculación al parte vía `parte_fotos`.

Como resultado, cualquier operativo puede completar un parte 100% desde la oficina si viene con fotos crudas del campo — no depende de que se hayan cargado antes desde la app móvil.

### 4.5 Módulo Reportes (`reportes.html` v8.2)

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

### 8.4 ⭐ Asistente AI para gestión vial

**Propuesta destacada** — es el diferencial que ningún sistema vial de la PBA tiene hoy.

Integración de un chat prompt con **modelo de lenguaje grande** (GPT-4o-mini, Claude Haiku o Claude Sonnet) que asista al personal técnico y jerárquico en la gestión diaria:

**Casos de uso propuestos:**

| Rol | Consulta ejemplo | Respuesta esperada |
|---|---|---|
| Técnico | *"¿Cuántas tareas de bacheo hicimos en Saladillo en junio?"* | Filtra automáticamente + devuelve cantidad + link al reporte |
| Técnico | *"¿Qué maquinaria usé más este mes?"* | Ranking con equipos + km de uso + tareas asociadas |
| Gerencia | *"Comparame la ejecución de Zona VI vs Zona VII este trimestre"* | Tabla comparativa + análisis narrativo |
| Gerencia | *"¿Qué tramos requieren atención próxima?"* | Detección de hot-spots por recurrencia de tareas + antigüedad |
| Admin | *"Resumime el mes en 3 párrafos para reunión"* | Informe ejecutivo generado automáticamente |
| Cualquiera | *"¿Qué se ve en esta foto?"* (con Vision API) | Descripción del deterioro/elemento vial + sugerencia de tipo de tarea |

**Beneficios institucionales:**

- Reduce la barrera técnica para consultar el sistema — cualquier persona con lenguaje natural puede obtener información.
- Detecta patrones que un humano no vería a simple vista (correlaciones entre tipo de superficie / recurrencia / partido).
- Agiliza la elaboración de informes mensuales de Gerencia (hoy consumen horas de trabajo administrativo).
- Base para modelos predictivos de deterioro y planificación de intervenciones.

**Stack técnico propuesto:**

- **Backend**: Edge Function de Supabase (Deno) que actúa como proxy — la API key del modelo NO se expone al frontend.
- **Modelo**: OpenAI GPT-4o-mini (~US$ 0.15/M tokens input, ~0.60/M tokens output) o Anthropic Claude Haiku (similar). Opcionalmente Claude Sonnet para consultas complejas.
- **Function calling**: el modelo puede llamar funciones SQL parametrizadas del sistema (ej. `getTareasByFilters(zona, tarea, mes)`) para obtener datos frescos.
- **Vision**: OpenAI GPT-4o Vision o Claude 3.5 Sonnet Vision para interpretar fotos de relevamiento.
- **UI**: modal chat en el portal, discreto pero accesible desde todas las apps del sistema.
- **Costo estimado**: US$ 5-20/mes con uso moderado (1.000-5.000 consultas). Escalable a US$ 100+/mes si se abre a las 12 zonas.

**Estado**: pendiente de decisión institucional y presupuestaria. Se documenta como **desarrollo futuro** en el informe del concurso, no como implementado.

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

_Última actualización: 19 de julio de 2026 · SIG Vial PBA en v8.2 (escritorio) / v9.72 (móvil)._
_Seudónimo tentativo: `lemeit` — a confirmar antes de la entrega._
