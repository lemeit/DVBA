# DVBA Zona VI Saladillo · Sistema de Relevamiento y Gestión Vial

Sistema web de relevamiento, cartografía y gestión de la red vial provincial a cargo del **Departamento Zona VI** de la Dirección de Vialidad de la Provincia de Buenos Aires (DVBA), con sede en Saladillo.

**Cobertura:** 8 partidos (Saladillo, Gral. Alvear, Gral. Las Heras, Lobos, Roque Pérez, Las Flores, Navarro, 25 de Mayo) · 15 rutas provinciales pavimentadas, tierra y mixtas + red de caminos secundarios.

**Hosting:** GitHub Pages — https://lemeit.github.io/DVBA/

---

## Apps publicadas

| URL | Archivo | Versión | Descripción |
|---|---|---|---|
| https://lemeit.github.io/DVBA/ | `index.html` | **v8.52** | Portal principal: mapa Leaflet + **sidebar drawer colapsable** (Ctrl+B). Pins arrastrables con auto-detección de partido/ruta/progresiva. **Botón `🎯 Ubicar`** (flujo inverso ruta+km → posición). **Sistema de reportes mixto** (Red Vial Provincial Primaria + Secundaria) con selección manual por click en mapa, halo dorado, PDF unificado con logo DVBA institucional. **Sello v4 overlay** semitransparente sobre la foto con QR + logo DVBA. **EXIF metadata** completo (GPS, Make, Model, DateTime) inyectado en cada foto. Paleta minimalista PBA (Anexo III). |
| https://lemeit.github.io/DVBA/partes_diarios.html | `partes_diarios.html` | **v8.52** | App "Plan de Seguridad en la Circulación" alineada al Google Form oficial DVBA. Carga de partes diarios con detección automática de partido, autocomplete de caminos con recorrido encadenado, dropdown único primaria/secundaria con typeahead. Comparte el módulo `sello_v4.js` con el portal. |
| https://lemeit.github.io/DVBA/reportes.html | `reportes.html` | **v8.52** | Módulo Reportes: 4 charts institucionales + tabla filtrable + export CSV. Genera PDF con jsPDF + autotable. Cotejado contra la paleta oficial DVBA del Informe Mensual Gerencia. |
| https://lemeit.github.io/DVBA/app.html | `app.html` → router | **v9.90** | **App móvil PWA (URL canónica)** — bootstrap que decide entre Modo Básico y Modo Avanzado según preferencia. Instalado en el celu queda como `SIG Vial PBA` (un solo ícono). URL legacy `campo.html` sigue como redirect. |
| ↳ `dvba_campo_lite.html` (interno) | Modo Básico | v9.90 | UI minimalista: foto + GPS + envío directo. Compresión 1200px/q=0.75 con `createImageBitmap` (low-memory). Inyección EXIF con GPS + fecha aunque la foto vaya cruda. Diseñado para operarios sin fluidez tecnológica. |
| ↳ `dvba_campo.html` (interno) | Modo Avanzado | v9.90 | Wizard completo con selección de tipo/estado/subatributos, autocomplete de rutas y caminos, edición fina + sello v4 aplicado en móvil. |
| https://lemeit.github.io/DVBA/caminos_secundarios.html | `caminos_secundarios.html` | **v1.1** | Visor interactivo de red secundaria con filtros, hover tolerante, exportación CSV/reporte (subruta legacy — el portal principal ya cubre este flujo) |
| https://lemeit.github.io/DVBA/docs/bitacora.html | bitácora unificada | v4.5 | Bitácora con tabs por temática (Resumen, Rutas/QGIS, Apps, Infraestructura, Decisiones, Pendientes, Changelog) |
| https://lemeit.github.io/DVBA/docs/guia_sig_vial_pba.html | guía textual | v1.1 | Manual completo de las apps móviles |
| https://lemeit.github.io/DVBA/docs/guia_visual_sig_vial_pba.html | guía visual | v1.1 | 10 láminas navegables (mockups smartphone) · imprimible como PDF |
| https://lemeit.github.io/DVBA/docs/MODELO_TIPOS_ESTADOS.md | doc técnica | v1.0 | Referencia del modelo Tipo↔Estado con árbol, matriz y guía de extensibilidad |

## Funcionalidades destacadas (v8.44-v8.52 · agosto 2026)

### Panel de Administración de usuarios (`admin_usuarios.html`)
Nuevo módulo web (solo admin) para gestionar todos los usuarios del sistema: listar con filtros por rol/zona/estado + editar rol/zona/nombre + activar/desactivar + reset password (mail vía Supabase) + invitar nuevos (link directo al Supabase Dashboard). Guard tolerante a token expirado con fallback a localStorage. Panel institucional con logo DVBA y footer con Acerca/Términos/Privacidad.

### Trigger de zona por rol (SQL_10)
Función server-side `forzar_zona_por_rol()` con trigger BEFORE INSERT/UPDATE en `relevamientos` y `partes_diarios` que **sobrescribe automáticamente** `NEW.zona = current_user_zona()` para técnicos. Un técnico IV nunca puede meter data en zona VI aunque el frontend mande valores mal. Admin y gerencia pueden reasignar zona manualmente. Defensa en profundidad sobre las policies RLS.

### Título unificado "SIG Vial PBAᵝ" (beta superíndice)
Nombre único del sistema en los 6 HTMLs (portal, reportes, partes_diarios, admin, dvba_campo, dvba_campo_lite) con letra beta griega como superíndice ámbar (estilo Eureka). Aclara estado de desarrollo sin ocupar espacio.

### Módulo legal compartido (`datos/legales.js`)
Contenido único de Acerca de + Términos + Privacidad + Permisos PWA para todos los sitios. Modal auto-inyectable con tabs. La sección Permisos explica claramente para qué usa cámara, ubicación, storage y conexión — tranquilidad para el usuario que instala la PWA.

### Progresiva inversa para caminos (`progresivaAPuntoCamino`)
La función `ubicarPorProgresiva` ahora funciona también para caminos secundarios (antes solo RPs). Algoritmo reusa `_offsetTramoCache` + `_haversineM` para calcular km→coord sobre la traza del camino, aprovechando la longitud oficial por tramo del CSV DVBA.

### Plan de escalado multi-zona
Documento `docs/PLAN_ESCALADO_MULTIZONA.md` con estructura de carpetas por zona, checklist paso a paso para habilitar nuevas zonas, presupuesto de esfuerzo estimado, prioridades y roadmap post-concurso 2026.

## Funcionalidades destacadas (v8.29-v8.42 · agosto 2026)

### Sistema de reportes unificado Red Vial Provincial (Primaria + Secundaria)
Un único panel de reportes en el sidebar del portal cubre RPs y Caminos Secundarios en un flujo simétrico. La selección se hace **por click en la vía del mapa → botón "+ Agregar al reporte"** (no depende de tildar chips ni filtros). Chip contador único muestra `✓ 🛣 N rutas · 🚜 M tramos` con lista expandible para deseleccionar item por item.

- **Selección con halo dorado** — cada RP o tramo seleccionado se resalta con halo `#ffb800` en el mapa
- **Modo mixto automático** — si tenés RPs + Caminos seleccionados, el PDF se genera con 2 secciones consecutivas (`🛣 Red Vial Provincial Primaria` + `🚜 Red Vial Provincial Secundaria`) en una sola pestaña con salto de página
- **Tabla homogénea entre tipos** — mismas 8 columnas para ambas redes: Partido, Nomenclatura, Tramo, Denominación, Clase (chip color), Sentido/Transitabilidad, Km GIS, Km Oficial. Aprovecha `CARACT_VIALES.tramos[]` del CSV oficial SALADILLO_RED
- **Opciones del mapa** — checkbox `rc-mapa` (incluir mapa SVG con partidos + ciudades + trazas + mojones + registros) y `rc-mapa-cap` (captura real del mapa Leaflet con `leaflet-image` para incluir basemap OSM)
- **Header institucional PDF** — logo DVBA + título + fecha, banner sello "📋 Datos oficiales · Fuente: DVBA - PBA"
- **Nomenclatura oficial DVBA** aplicada en títulos: Red Vial Provincial Primaria (RPs), Red Vial Provincial Secundaria (Caminos)

### Panel de edición del sidebar minimalista PBA
Botones sidebar (Rotar, Descargar, Re-sellar, EXIF, EXIF+, Backup) migrados de fondo oscuro `#0d2030` tipo IDE a **paleta clara PBA** (fondo blanco + borde `--light` + texto en color institucional). Modal grande de edición de registros también migrado a paleta clara con header banda turquesa PBA.

### Fase 3 · RLS zonal (SQL_9)
Row-Level Security zone-aware para las 4 tablas principales (`relevamientos`, `partes_diarios`, `parte_maquinarias`, `parte_fotos`) con 4 roles (público, técnico-zona, gerencia, admin). Aplicado en Supabase.

## Funcionalidades destacadas (v8.11-v8.21 · v9.79-v9.88 · julio-agosto 2026)

### Arquitectura del sello v4 unificado
Un único módulo `datos/sello_v4.js` es la fuente de verdad para el sellado — importado por portal, partes_diarios y móvil. Antes había 3 copias embebidas descoordinadas.

### Sello v4 con overlay semitransparente
El banner ya no se agrega ABAJO de la foto (que la "afinaba"), sino que se dibuja **encima** de los últimos ~180-270px de la propia foto, con fondo `rgba(0,0,0,0.55→0.75)`. La foto conserva 100 % su ratio original. Texto blanco con sombra negra + QR con fondo blanco sólido + logo DVBA (18 %) al centro del QR.

### Metadatos EXIF completos en cada foto
Vía `datos/exif_writer.js` (wrapper sobre `piexifjs`), cada foto sellada lleva adentro:
- `GPS` lat/lng/altitud/timestamp
- `Make` = `DVBA` · `Model` = `SIG Vial PBA · Modo Básico/Avanzado/Portal`
- `Software` = `SIG Vial PBA v8.21 · sello v4`
- `ImageDescription` = `ruta · km · tipo`
- `Copyright` = `DVBA - Departamento Zona VI`
- `DateTimeOriginal` + `UserComment` (JSON completo del registro)

Windows Explorer, Google Photos, iPhone Fotos y cualquier visor con soporte EXIF muestran la ubicación en un mini-mapa automáticamente.

### 4 flujos de creación/edición coordinados

1. **Móvil (Modo Básico)** → llega crudo con GPS → auto-ubicar en mapa + auto-completar partido/ruta/prog con `ARMONIZADOR`
2. **Desde el mapa** → `📍 Nuevo Pin` en el centro del viewport → arrastrar + completar datos
3. **Por progresiva** → elegir RP + escribir km + `🎯 Ubicar` → sistema calcula lat/lng con CHAIN+ANCHORS
4. **Edición** → arrastrar pin recalcula todo al vuelo

### Sidebar drawer colapsable
Toggle `Ctrl+B` (o clic en `◀` del borde derecho) para maximizar el mapa. Persiste en `localStorage`. Leaflet recalcula tiles automático.

### Nombre archivo al descargar
Botón `⬇ Descargar` en modal/sidebar → `fetch → blob → objectURL` para forzar nombre `SIGVialPBA_ID_RP.jpg` (Chrome ignora `<a download>` cross-origin de Supabase).

### PWA móvil unificada
Una sola PWA (`app.html`) con dos modos internos. El user toggle entre Básico y Avanzado sin desinstalar. Un solo ícono en el launcher.

---

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

## Novedades v7.62 → v7.79 (13 julio 2026)

Sesión larga de 3 bloques que consolidó **el módulo "Plan de Seguridad en la Circulación"** (partes diarios oficiales), **la detección automática de partido**, y **la visualización de partes en el mapa del portal**. Detalle completo en la [bitácora tab Changelog](docs/bitacora.html).

### Módulo Plan de Seguridad en la Circulación (`partes_diarios.html`)

Nueva app alineada al Google Form oficial de Gerencia Ejecutiva DVBA. Reemplaza al workflow anterior de "partes por email":

- **Detección automática de partido** al cargar un parte. Caminos: código único NNN-NN → partido directo. RPs: interpola el punto medio del tramo `prog_ini↔prog_fin` sobre `CHAIN_RPxx` y hace point-in-polygon vs `partidos_zona_vi.geojson`. Nueva columna `partido` en `partes_diarios` (SQL 6).
- **Badge en vivo** "Partido detectado: X ✓" mientras se completa el form. Verde si detecta, ámbar con motivo si no ("ruta sin traza cargada", "cargá al menos una progresiva").
- **Autocomplete custom de caminos** con recorrido encadenado ("Saladillo — La Barrancosa — Micheo" construido a partir de las denominaciones de tramos del geojson). Matching preciso: tipear "093" NO trae "091-XX".
- **Dropdown único primaria + secundaria** con etiqueta `[P]`/`[S]` y typeahead nativo via `<datalist>`. Toggle 🛣/🚜 opcional.
- **Progresivas con coma decimal** (formato oficial DVBA `100,01`) + labels "menor" / "mayor".
- **Filtros de partido en la toolbar** + nueva columna Partido en la tabla.
- **RLS relajado** a "authenticated-CRUD" para uso interno DVBA (SQL 5), con `responsable_id` llenado automáticamente al INSERT para auditoría.
- **632 partes históricos** + 49 vehículos + 1203 vinculaciones cargados por bulk desde CSVs.

### Capa 📋 Partes en el mapa del portal (`index.html`)

Cierra el ciclo "cargo parte → aparece en el mapa":

- **Nueva capa Leaflet toggleable** en el panel de capas del portal.
- **Partes con foto**: pin sobre la posición GPS del relevamiento asociado (via `parte_fotos → relevamiento_id → lat/lon`).
- **Partes sin foto**: polyline sobre la **traza real** del chain (RP o camino) entre `prog_ini` y `prog_fin`, más pin al punto medio. La polyline sigue la curva real — no dibuja rectas.
- **Colores por antigüedad** (base para reportes): últimos 7 días → rojo, últimos 30 → dorado, últimos 90 → violeta, más viejo → gris. Aplica a pin, polyline y header del popup.
- Soporta las 8 RPs con bundle procesado + los 100 caminos secundarios de Zona VI. Requiere sesión (RLS).

### Portal + escritorio: UX refinada

- **Picker de zona en el header** de ambos portales: label bonito `ZONA VI [Saladillo]` + ícono `▾` que despliega select nativo con las 12 zonas. Persiste en `localStorage['dvba_zona']`. Preparado para el escalado multi-zona.
- **Panel-footer institucional fijo** en el sidebar del portal: bloque "Zona X · Resumen" (Partidos/Rutas/Caminos/Registros) siempre visible + info "© 2026 DVBA · Desarrollado por Ing. Luciano Lamaita · vX.YY". No scrollea con las tabs.
- **Header sin "Desarrollado por"** (ya vive en el footer). Menos redundancia.
- **Legales sin restricción "Zona VI Saladillo"**: los textos de Términos y Tecnologías reflejan que el sistema sirve a toda la DVBA (Zona VI como piloto).
- **Convención unificada de versionado**: un único contador `v7.X` para toda la familia escritorio (`index.html` + `partes_diarios.html`). Se bumpean juntos aunque uno no cambie en el bump.

### Fixes críticos

- **v7.75 · const RP no cuelga de window**: los bundles `datos/rutas_rpXX.js` declaran `const CHAIN_RPxx` que no se expone en `window`. Fix con `typeof CHAIN_RPxx !== 'undefined'`. Mismo bug que resolvió v7.24 en el portal.
- **v7.79 · RPs con progresivas invertidas**: RP51 y RP46 tienen `acc` decreciente cuando `km` crece. Sin swap de `accIni/accFin` la polyline se cortaba de una y dibujaba una recta. Fix con swap en `_partesTramoChain`.

### Doc de diseño

Nuevo **[`docs/PLAN_ROLES_MULTIZONA.md`](docs/PLAN_ROLES_MULTIZONA.md)** con la visión de 4 niveles (público / técnico zona / gerencia PDF oficial / admin) y roadmap de 5 fases para escalar el sistema a las 12 zonas provinciales. Se puede trabajar en paralelo al roadmap actual. El layout del PDF Gerencia (Fase 5) ya está analizado en **[`docs/ANALISIS_INFORME_GERENCIAL_DVBA.md`](docs/ANALISIS_INFORME_GERENCIAL_DVBA.md)**.

### Base SQL agregada

- `SQL_5_rls_partes_flexible.sql` · RLS flexibilizada para uso interno.
- `SQL_6_partido_en_partes.sql` · Columna `partido` en `partes_diarios` + view export.

---

## Novedades v7.46 → v7.57 · v9.50 → v9.53 (7–13 julio 2026)

**Sprint SIG Vial + gestión de fotos + rediseño UI**. Detalle completo en la [bitácora tab Changelog](docs/bitacora.html).

- **Modal SIG Vial tipo DNV** al click sobre una RP o camino en el mapa: progresiva del punto, longitud oficial vs GIS con diferencia %, características viales (clase, transitabilidad, placeholders `s/d` para ancho calzada / banquinas / TMDA / pavimento / estado), tabla colapsable de tramos oficiales. Adaptado para caminos con Denominación + Transitabilidad + banner `⚠ ALERTA: REVISAR` si corresponde.
- **Bundle `datos/caracteristicas_viales.js`** generado desde `SALADILLO_RED.csv` — 15 RPs con 96 tramos oficiales. Los campos editables (ancho, TMDA, etc.) se completarán vía UI colaborativa contra Supabase en una próxima iteración.
- **Sistema de fotos originales preservadas**: el archivo `{path}.jpg` es el ORIGINAL y nunca se sobreescribe; el sellado se guarda como `{path}_sello.jpg`. Re-sellar N veces siempre parte del original limpio. Botón individual "🗑 Backup de esta foto" + sección "🧹 Mantenimiento Storage" para limpieza masiva.
- **Rotación + re-sellado en escritorio**: al aprobar un pendiente o editar un registro, botones ↺ ↻ Reset + "🖋 Re-sellar" en el sidebar. EXIF Orientation automático + manual. El móvil ya NO rota (v9.53).
- **Sello incluye estado** además de tipo (ej: `Encrucijada en T · faltante`).
- **UI portal renovado**: pills de registros agrupadas por Partido/Ruta/Mes/Tipo con contadores y +/− por grupo, paleta cálida con un color distinto por RP (`RP_COLORES_CALIDOS`), ancho de trazas armonizado (weight=4), mojones colapsados por defecto en sidebar.

## Novedades v7.28 → v7.39 (julio 2026)

Sprint de integración caminos secundarios + rediseño visual + saneamiento del flujo de sellado.

### Integración red vial completa

- **Red secundaria integrada al portal**: los 100 caminos únicos (129 tramos) de los 8 partidos aparecen en el mapa principal junto con las RPs. Filtros de partido, clase (pavimentado / mixto / tierra / sin abrir) y visibilidad por chip individual.
- **Renderizado doble capa (HALO + BASE)** portado desde `caminos_secundarios.html` — trazas nítidas sin offset visual sobre OSM/Oscura/Satélite.
- **Detección unificada por tipo_via**: al hacer click con el pin sobre un camino, el sistema autocompleta `Cno. NOMEMCLATURA` + progresiva calculada sobre la traza + partido, con la misma lógica que las RPs.

### Cursor + progresivas al hover

- **Cursor naranja flotante** que se posiciona sobre la cadena real de la traza (RP o camino) al pasar el mouse.
- **Tooltip permanente con la progresiva**: `RP 91 · 15+041 (15.04 km)` o `Cno. 093-13 · km 4.87`.
- **Círculos de progresiva cada N km** (1 / 5 / 10) — activables con `🎯 Progresivas al hover` en el panel Visualización.
- **Densidad de mojones configurable**: 5 / 10 / 20 / 50 km / Ninguno. Default 50 (modo minimalista).
- **Modo detallado**: atajo que pone mojones cada 10 km + progresivas ON con paso 5 km.

### Unificación visual

- **RPs con color único** `#c25a2a` (rojizo ladrillo) — antes cada una tenía su color (arcoíris). Diferenciación por label.
- **Partidos con color único** `#3a5a7a` (gris azulado neutro) con opacidad baja — fondo administrativo, sin competir con las trazas.
- **Caminos mantienen colores por clase** (semántica: PAVIMENTADO azul / MIXTO violeta / SIN ABRIR gris / DE TIERRA marrón).
- **Panel "🗺 Capas" plegable** en esquina del mapa con secciones Fondo / Capas / Visualización / Leyenda.

### Workflow de sellado saneado (v7.34 → v7.38)

- **Fix crítico modal escritorio**: el `modal-sello-ov` de `index.html` estaba incompleto desde la task #76 — le faltaban 10 inputs + botones + cierres de tags. Reconstruido.
- **Guard anti-doble-sello**: si la foto ya contiene sufijo `_sello.` en la URL o el registro tiene `sello_version === 'v3'`, no se re-sella. Aplica a los dos paths: `guardar()` post-edición y `aprobarRegistro()` desde la cola.
- **Modo pin no muestra círculo naranja**: al activar el modo pin, el cursor sobre traza se oculta para no confundir con la cruz del pin.
- **Auto-detección inteligente al hacer pin**: click sobre camino → toggle → 'camino' + `Cno. XX-YY`. Click sobre RP → toggle → 'rp' + progresiva. En modo hover normal, se respeta el toggle actual del form para no interferir entre capas.

### Datos actualizados

- **RP61**: regenerada con tramo de gap adicional agregado en QGIS (v7.39). longGis 225.836 → 567.677 km (incluye el gap añadido). Requiere revisión del anchor km 50 que quedó no-monotónico tras el cambio.

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

Denominación oficial en todos los documentos y apps: **"Departamento Zona VI Saladillo"** o abreviado **"Zona VI Saladillo"**. NUNCA "Delegación Saladillo".

---

**Responsable:** Ing. Luciano Lamaita — División Técnica DVBA Zona VI
