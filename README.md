# DVBA Zona VI Saladillo · Sistema de Relevamiento y Gestión Vial

Sistema web de relevamiento, cartografía y gestión de la red vial provincial a cargo del **Departamento Zona VI** de la Dirección de Vialidad de la Provincia de Buenos Aires (DVBA), con sede en Saladillo.

**Cobertura:** 8 partidos (Saladillo, Gral. Alvear, Gral. Las Heras, Lobos, Roque Pérez, Las Flores, Navarro, 25 de Mayo) · 15 rutas provinciales pavimentadas, tierra y mixtas + red de caminos secundarios.

**Hosting:** GitHub Pages — https://lemeit.github.io/DVBA/

---

## Apps publicadas

| URL | Archivo | Versión | Descripción |
|---|---|---|---|
| https://lemeit.github.io/DVBA/ | `index.html` | **v8.86q** | Portal principal: mapa Leaflet + **sidebar drawer colapsable** (Ctrl+B). Pins arrastrables con auto-detección de partido/ruta/progresiva. **Botón `🎯 Ubicar`** (flujo inverso ruta+km → posición). **Sistema de reportes mixto** (Red Vial Provincial Primaria + Secundaria) con selección manual por click en mapa, halo dorado, PDF unificado con logo DVBA institucional. **Sello v4 overlay** semitransparente sobre la foto con QR + logo DVBA. **EXIF metadata** completo (GPS, Make, Model, DateTime) inyectado en cada foto. Paleta minimalista PBA (Anexo III). Basemaps: OSM + Satélite Esri (Vista Oscura CARTO temporalmente desactivada, pendiente proxy para no exponer API key). |
| https://lemeit.github.io/DVBA/partes_diarios.html | `partes_diarios.html` | **v8.86q** | App "Plan de Seguridad en la Circulación" alineada al Google Form oficial DVBA. Carga de partes diarios con detección automática de partido, autocomplete de caminos con recorrido encadenado, dropdown único primaria/secundaria con typeahead. Comparte el módulo `sello_v4.js` con el portal. |
| https://lemeit.github.io/DVBA/reportes.html | `reportes.html` | **v8.86q** | Módulo Reportes: 4 charts institucionales + tabla filtrable + export CSV. Genera PDF con jsPDF + autotable. Cotejado contra la paleta oficial DVBA del Informe Mensual Gerencia. |
| https://lemeit.github.io/DVBA/app.html | `app.html` → router | **v9.95.18** | **App móvil PWA (URL canónica)** — bootstrap que decide entre Modo Básico y Modo Avanzado según preferencia. Instalado en el celu queda como `SIG Vial PBA` (un solo ícono). URL legacy `campo.html` sigue como redirect. |
| ↳ `dvba_campo_lite.html` (interno) | Modo Básico | v9.91 | UI minimalista: foto + GPS + envío directo. Compresión 1200px/q=0.75 con `createImageBitmap` (low-memory). Inyección EXIF con GPS + fecha aunque la foto vaya cruda. Diseñado para operarios sin fluidez tecnológica. |
| ↳ `dvba_campo.html` (interno) | Modo Avanzado | v9.91 | Wizard completo con selección de tipo/estado/subatributos, autocomplete de rutas y caminos, edición fina + sello v4 aplicado en móvil. |
| https://lemeit.github.io/DVBA/caminos_secundarios.html | `caminos_secundarios.html` | **v1.1** | Visor interactivo de red secundaria con filtros, hover tolerante, exportación CSV/reporte (subruta legacy — el portal principal ya cubre este flujo) |
| https://lemeit.github.io/DVBA/wiki/99-Bitacora/ | bitácora unificada | v4.5 | Bitácora con tabs por temática (Resumen, Rutas/QGIS, Apps, Infraestructura, Decisiones, Pendientes, Changelog) |
| https://lemeit.github.io/DVBA/docs/guia_sig_vial_pba.html | guía textual | v1.1 | Manual completo de las apps móviles |
| https://lemeit.github.io/DVBA/docs/guia_visual_sig_vial_pba.html | guía visual | v1.1 | 10 láminas navegables (mockups smartphone) · imprimible como PDF |
| https://github.com/lemeit/DVBA/blob/main/docs/MODELO_TIPOS_ESTADOS.md | doc técnica | v1.0 | Referencia del modelo Tipo↔Estado con árbol, matriz y guía de extensibilidad |

## Funcionalidades destacadas (v8.72-v8.86q · v9.95.5-v9.95.18 · 1-septiembre-2026)

### Robustez móvil con señal débil + apagado temporal Vista Oscura CARTO (v9.95.18 + v8.86q · 1-sep-2026)

Sprint de robustez cerrado con un fix crítico del Service Worker. Trío de bugs correlacionados aparecían cuando el celu tenía señal débil (no offline duro): Modo Básico "no arrancaba" y terminaba abriendo el portal escritorio (redirect loop en el fallback offline que servía `app.html` en vez de `dvba_campo_lite.html`), Modo Avanzado abría pero no calculaba la progresiva (los bundles `rutas_rpXX.js` quedaban colgados esperando la red y `ARMONIZADOR` arrancaba sin `CHAINS_DATA`), y la app "buscando señal" no arrancaba nunca (solo modo avión funcionaba porque `fetch()` falla al toque). Causa raíz común: SW era **network-first sin timeout** para TODO. Fix: **cache-first** para todo lo cacheado (HTML/JS/geojsons se sirven al instante + refresco en background) + **network-first con timeout 3s** para lo no cacheado + fallback offline que matchea PRIMERO el HTML pedido. Bump `CACHE_NAME` v9.95.18.

En paralelo, apagado temporal del basemap "Vista Oscura" en `index.html` porque CARTO ahora exige API key para servir `dark_all` y el proxy que va a manejar la key sin exponerla en el HTML público todavía no está listo. El botón queda comentado en el selector de capas y `tDark` queda como alias defensivo de `tOSM`. Los basemaps OSM y Satélite Esri siguen funcionando normal. El plan es replicar el patrón de proxy con Cloudflare Worker + secret que ya funciona en tres proyectos internos (Ema Saladillo · PurpleAir · Agua).

### Guard de rol en móvil + panel admin en 4 tabs + batch usuarios prueba (v9.95.17 + v8.86p · SQL_34)

Cierre del sprint de coherencia de permisos. Los tres roles solo-lectura (**gerencia**, **jefe_administrativa**, **jefe_automotores**) ahora ven un banner amarillo persistente en la app móvil ("Tu rol no está autorizado para cargar registros") y el botón de captura de foto queda deshabilitado — aplica en Modo Básico y Modo Avanzado. La seguridad real ya estaba en las policies RLS (SQL_27), esto es UX para no dejar al usuario descubrir el rechazo después de sacar la foto. Panel admin `admin_usuarios.html` reestructurado en 4 pestañas pill turquesa con hash-routing y lazy-load (Usuarios / Solicitudes / Auditoría / Sistema); tab Sistema llama a la RPC `admin_metricas_sistema` (SQL_33) con snapshot de BD + storage + auth + top tablas. Batch SQL_34: 15 usuarios `@dvba.test` completando los 7 roles operativos en las 3 zonas piloto (IV/V/VI), `lulamaita@vialidad.gba.gov.ar` promovido a admin (backup), alias `+z4/+z5` eliminados. Trazabilidad de autor en la cola pendiente del portal escritorio: etiqueta "👤 rol · Zona X" con el snapshot del autor (nombre + rol + zona en el momento de la carga).

### Hardening de seguridad + trazabilidad multi-usuario (v8.86j – v8.86k · SQL_26 → SQL_30)

Después de una auditoría con el linter de Supabase se cerraron todos los hallazgos de seguridad y se agregó trazabilidad completa por autor:

- **SQL_26** — hardening de vistas y bucket: `security_invoker` en las vistas de reportes, drop de la tabla legacy `registros` con policy pública peligrosa, reemplazo de `v_solicitudes_admin` (que cruzaba `auth.users`) por función RPC `get_solicitudes_admin()`, policy de lectura pública en `partidos_zona`.
- **SQL_27** — matriz de permisos consolidada (fuente única de verdad): rollback de derivas (gerencia vuelve a solo lectura + sugerir, jefes admin/automotores a solo lectura zonal, técnico pierde DELETE) + soft-delete para jefe_zona con motivo obligatorio (mínimo 10 caracteres). Nueva vista `v_borrados_auditoria` para restaurar/eliminar desde el panel admin.
- **SQL_28** — hardening masivo de funciones DEFINER: `SET search_path = public` en las 15 funciones + `REVOKE EXECUTE` de `anon` y `PUBLIC` en las 17 RPCs + drop de policy de bucket que permitía listing.
- **SQL_29** — revoke de authenticated en triggers puros (`forzar_zona_por_rol`, `set_caminos_alias_updated_at`, `zona_por_partido`) que no deben ser RPCs.
- **SQL_30** — columna `autor_id UUID` + `autor_rol` + `autor_zona` en `relevamientos` y `partes_diarios`, con trigger auto-populate y snapshot del rol/zona al momento de la carga. Policy UPDATE de técnico restringida a `autor_id = auth.uid()`. Vista `v_borrados_auditoria` extendida con autor original.

Frontend (v8.86j–v8.86k): modal soft-delete jefe_zona con contador de caracteres + validación · panel admin con auditoría de borrados (restaurar / eliminar definitivo) · cola de pendientes muestra "👤 rol · Zona X" del autor original · migración `.from(v_solicitudes_admin)` → `.rpc(get_solicitudes_admin)`.

Estado final del linter Supabase: 0 errores + 13 warnings esperados (helpers RLS + RPCs con role validation interna) + 1 warning bloqueado por plan Free (leaked password protection).

### Fase 2 · Roles multi-zona (v8.79 – v8.86e) — **operativo end-to-end**

- **Organigrama completo como roles** en `usuarios_perfil`: gerencia, jefe_zona, jefe_operativa, jefe_tecnica, jefe_administrativa, jefe_automotores, capataz, tecnico, admin, publico.
- **Portal `plan_operativo.html`** para el jefe de zona: bandeja de entrada, kanban semanal, generar tarea, cerrar con foto (vincula relevamiento crudo con asignación).
- **Nav consolidado** compartido en los 5 portales (`datos/nav.js`) con dropdown único, impersonación admin/gerencia, zona-picker con las 12 zonas, badge cola de pendientes.
- **RLS zonal consolidada** (SQL_19/SQL_27): matriz definitiva de permisos por rol × acción · gerencia solo lee y sugiere · jefes administrativos/automotores solo lectura zonal · solo admin borra.
- **Trigger zona-por-partido-geográfico** (SQL_23): la zona del registro se deriva del partido (tabla `partidos_zona` con 135 partidos). Cualquier agente DVBA que recorra la PBA y cargue una foto queda automáticamente asignado al jefe de la zona correcta.
- **App móvil** (v9.95.15) acepta todos los roles operativos. Labels de rol completos.

### Matriz de permisos consolidada (fuente única de verdad · SQL_27)

| Rol | Alcance | SELECT | INSERT | UPDATE | DELETE | Aprobar | Intervenir | Asignar |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **admin** | Todo el sistema | ✓ all | ✓ | ✓ | ✓ hard | ✓ | ✓ | ✓ |
| **gerencia** | Todas las zonas | ✓ all | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ |
| **jefe_zona** | Su zona | ✓ zona | ✓ | ✓ | ✓ soft (con motivo) | ✓ | ✗ | ✓ |
| **jefe_operativa** | Su zona | ✓ zona | ✓ | ✓ | ✗ | ✓ (tareas cerradas) | ✗ | ✓ |
| **jefe_tecnica** | Su zona | ✓ zona | ✓ | ✓ | ✗ | ✓ (relevamientos) | ✗ | ✗ |
| **jefe_administrativa** | Su zona | ✓ zona | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **jefe_automotores** | Su zona | ✓ zona | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **capataz** | Su zona | ✓ zona | ✓ (cierre de tarea) | ✗ | ✗ | ✗ | ✗ | ✗ |
| **tecnico** | Su zona | ✓ zona | ✓ | ✓ (propios) | ✗ | ✗ | ✗ | ✗ |
| **publico** | Solo mapa institucional | mapa | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

**Convención DELETE**: `hard` elimina físicamente la fila (solo admin). `soft (con motivo)` marca el registro como borrado con un motivo obligatorio (mínimo 10 caracteres); queda oculto para roles no-admin pero recuperable por admin desde la vista de auditoría `v_borrados_auditoria` (jefe_zona, solo dentro de su zona).

Principios que guían la matriz: **descentralización zonal** (cada zona gestiona su operativa · gerencia consulta y sugiere pero no ejecuta), **jerarquía real DVBA** (los jefes de las divisiones administrativas y de automotores no cargan trabajo de campo vial), **mínimo privilegio con trazabilidad** (solo admin borra físico · jefe_zona borra lógico con justificación auditable · técnicos editan solo lo propio · capataces solo cierran su tarea asignada), y **trazabilidad geográfica** (cada registro cae en la zona de su partido, no en la del usuario que lo cargó).



**Migración #4 · sub-atributos a columnas dedicadas (v8.78 · v9.95.14 · SQL_16)** — Hasta v8.77, los sub-atributos `superficie` (asfalto/hormigón/tierra/…) y `modalidad` (manual/mecánico/mixto) se serializaban al final del campo `observaciones` con el formato `[superficie:X · modalidad:Y]`. Funcional pero impedía cruzar en reportes agregados. La migración crea columnas dedicadas, hace backfill automático con regex desde el texto existente + limpieza del sufijo. Frontend (móvil y escritorio) escribe en columnas propias; lectura con fallback al parseo para retrocompatibilidad. Ahora se puede consultar en SQL directo (ej. `SELECT superficie, COUNT(*) FROM relevamientos WHERE naturaleza='tarea' GROUP BY superficie`).

**Cámara in-app en el Modo Básico (v9.95.13)** — El Modo Básico crasheaba al abrir la cámara nativa (`<input capture>`): Android manda la PWA a background y por policy puede matar el proceso por gestión de recursos, con lo cual la app "reinicia" al volver de la cámara. Solución: portado el flow del Modo Avanzado (`getUserMedia` + modal in-app con `<video>` + botones capturar/cancelar/flip). La cámara vive dentro de la PWA, nunca pasa a background. Fallback automático a `<input capture>` si `getUserMedia` falla (permiso denegado, sin cámara, browser sin soporte).

**Service Worker offline reparado (v9.95.11)** — El fallback offline del SW solo cubría `/dvba_campo`; no manejaba `/app.html` (start_url del PWA) ni `/dvba_campo_lite.html`. Al abrir desde el icono PWA en modo avión, caía al mensaje "sin caché". Extendido a todas las entradas del PWA (`/app.html`, `/campo.html`, `/dvba_campo.html`, `/dvba_campo_lite.html`, `/`, `/DVBA/`, `/DVBA`) con cadena de fallback en cascada. `caches.match` con `{ignoreSearch:true, ignoreVary:true}` para tolerar query params (cache-busters, params UTM que Android agrega al PWA).

**Cache defensivo de ruta al enviar (v9.95.12)** — Bug recurrente en Modo Avanzado: al enviar el registro salía "Seleccioná la ruta/camino" aunque el operador la había cargado en el paso 1. Causa: el cache `_ultimaRutaCargada` solo se actualizaba con el evento `change` (interacción manual del user); cuando el código seteaba `f-ruta.value` programáticamente (autodetección desde GPS, reconstrucción del select al cambiar partido, etc.), el evento no se disparaba y el cache quedaba vacío. Fix con 3 capas de captura: `change` + `input` + poll defensivo cada 2s + helper `window._setRutaCached()` para llamadas explícitas.

**Leyenda del mapa scrolleable + UX del scrollbar (v8.77)** — La sección "📌 Registros del mapa" (agregada por el modelo Opción C) hizo crecer la leyenda más allá del alto de pantalla. Fixes: `max-height: calc(100vh - 80px)` + `overflow-y:auto`, scrollbar rediseñado (global 4px→8px, específico para leyenda y sidebar 12px "en pastilla" con hover turquesa), `L.DomEvent.disableScrollPropagation` para que la rueda del mouse scrollee la leyenda en vez de zoomear el mapa Leaflet.

**Spans hardcodeados de versión sincronizados en móvil (v9.95.10)** — Regla ampliada: al bumpear versión hay que actualizar TRES capas por HTML — (1) constante JS (`APP_VER` / `APP_VERSION`), (2) spans literales hardcoded en el HTML (`<span id="loginVer">`, `<span id="app-ver">`), (3) cache-busters (`?v=X.Y.Z`) de scripts críticos. Documentado como regla interna para no volver a fallar.

**Modelo Tipos v2 · naturaleza × elemento × ítem (v8.76 · v9.95.9 · SQL_15)** — Rediseño arquitectural del modelo de tipos. Se introduce el eje **naturaleza** ortogonal a la categoría del elemento: 🔍 **Relevamiento** (observación del estado) vs 🚜 **Tarea de mantenimiento** (acción ejecutada o programada). La categoría plana `mantenimiento` desaparece; cada elemento (calzada, drenaje, estructura, señalización, demarcación, iluminación, entorno, seguridad) tiene ahora dos listas: `items_relev` e `items_tarea`. Ejemplo: sobre Señalización se puede relevar cebras faltantes o registrar la colocación de cebras. Nueva columna `naturaleza` en Supabase (DEFAULT `'relevamiento'` retroactivo). API vieja intacta para no romper HTMLs viejos. Detalle completo en la [bitácora tab Changelog](https://lemeit.github.io/DVBA/wiki/99-Bitacora/) y en `docs/MODELO_TIPOS_ESTADOS.md` v1.3.

**Wizard de captura con paso 0 de naturaleza (v9.95.8 móvil · v8.76 escritorio)** — En el móvil, el wizard arranca con dos botones grandes de naturaleza (obligatorio). En el escritorio hay tabs "Relevamiento / Tarea de mantenimiento" sobre el sidebar. La grilla de categorías se filtra automáticamente (Seguridad vial solo aparece en relevamiento). Los ítems se filtran por `itemsPorNaturaleza(cat, nat)`. Los estados en el `<select>` se repueblan según `getEstadosPorNaturaleza`: si es tarea → programado/en_ejecución/finalizado/suspendido/cancelado; si es relevamiento → bueno/regular/malo/crítico (o los específicos de señalización, iluminación, etc.). Sub-atributos de superficie y modalidad respetan las reglas V2.

**Colores del mapa · Opción C (v8.76 · forma × color × borde)** — Refactor completo de `drawRegMarkers`. Cada pin es un SVG inline de 16×16 con tres dimensiones visuales ortogonales: **forma** codifica la categoría del elemento (círculo=calzada, rombo=drenaje, cuadrado=estructura, triángulo=señalización, pentágono=demarcación, cruz=iluminación, hexágono=entorno, estrella=seguridad); **color** codifica la severidad del estado (verde/amarillo/naranja/rojo/gris/azul/violeta leído directo de `DVBA_ESTADOS`, con heurística de fallback para registros legacy con estado en string libre); **borde** codifica la naturaleza (sólido = relevamiento, punteado = tarea). Nueva sección "📌 Registros del mapa" en la leyenda del portal con las 3 sub-tablas para consulta rápida sin abrir la guía.

**Filtro por naturaleza en Reportes (v8.76)** — Nuevo select en el header de filtros de `reportes.html`: Todas / 🔍 Solo relevamientos / 🚜 Solo tareas. Filtra a nivel BD la query de relevamientos huérfanos y excluye los partes reales (que son siempre tareas) cuando se elige "Solo relevamientos". Permite separar reportes de estado observado vs reportes de trabajo ejecutado.

**Fix pin salta lejos (v8.74)** — `guardar()` de `index.html` caía a un fallback silencioso ("punto medio de la ruta + ruido random ~1 km") cuando `flat/flng` eran `NaN`. Resultado: el pin se guardaba a varios kilómetros del lugar donde el operador había hecho click. Reemplazado por alerta explícita + log de diagnóstico. Ahora si por alguna razón las coordenadas no se cargan al guardar, el sistema avisa en vez de inventar una posición.

**Sello sin sufijo origen (v9.95.9)** — `datos/sello_v4.js` ya no agrega `·campo` / `·escritorio` al lado de la versión en el pie del sello. Solo versión + `sello v4`. Aplica a móvil y escritorio (comparten el módulo).

**Wiki reorganizada en 2 secciones + limpieza de detalles internos** — La wiki se dividió en dos secciones temáticas usando `navigation.sections` de MkDocs Material: **Guía de uso** (14 capítulos operativos + Guía Visual) y **Historia y evolución** (Antecedente SIG Vial 2008, Nomenclador 1989, Bitácora del proyecto, README técnico). Nueva página dedicada al Nomenclador 1989 con PDF descargable filtrado por sesión activa. Limpieza de detalles internos en el cuerpo de las páginas de guía: quitados los números de versión (`v8.72`, `v9.95.4`) que ensuciaban el copy, paths de repo, links a `github.com/lemeit/DVBA/blob/...`, pendientes internos, opiniones de dev.

## Funcionalidades destacadas (v8.68-v8.71 · v9.94-v9.95.4 · 13-agosto-2026)

**Catálogo colaborativo de alias de caminos (v8.71 · SQL_14)** — Nueva tabla `caminos_alias` en Supabase donde técnicos y personal DVBA registran los nombres populares con que se conoce cada camino secundario (ej. `093-08` → *"Camino a Los Molles"*, *"Del Molino Viejo"*). Modal de edición en el portal (`✏ Editar datos viales` sobre cualquier camino) con chips estilo tags, denominación local sugerida y observaciones libres. Los alias se muestran automáticamente en el modal SIG Vial del camino y son buscables desde el sidebar (`🔍 Buscar por código o alias`). RLS: lectura pública, escritura de técnicos por zona / gerencia / admin.

**Wizard de Reportes con presets (v8.71)** — Rediseño del panel Reportes de Vías con 4 presets tipo tarjeta: **Red vial completa** / **Por partido** / **Solo Rutas** / **Solo Caminos**. Ajustes avanzados (columnas, filtros de tipos, opciones PDF) en `<details>` colapsable. Sub-panel dinámico "Por partido" con dropdown + botones `+ Rutas` y `+ Caminos` del partido elegido. Tab del reporte generado con panel de filtros interactivo (partido, texto libre, clase) que oculta/muestra filas en tiempo real. Contador de caminos únicos además de tramos.

**Modales unificados con paleta institucional DVBA (v8.68-v8.71)** — Cola de pendientes, modal Sello y modal edición de alias ahora usan la paleta oficial turquesa `#00aec3` + amber `#c47a00`. Antes eran naranja/oscuro genéricos. Consistencia visual con el resto del portal.

**Wiki publicada con MkDocs Material (v8.68-v8.71)** — Guía de usuario navegable en `lemeit.github.io/DVBA/wiki/` con 17 capítulos + bitácora del proyecto + mockups de la UI móvil. GitHub Actions rebuildea automáticamente en cada push a `wiki-src/`. Botón "📖 Guía" en los 4 portales.

**Fix SW cache Modo Avanzado (v9.95.4)** — Bug histórico donde `dvba_campo.html` nunca declaraba `APP_VER` como variable JS (solo spans HTML) y el modal "Acerca de" caía a un fallback cacheado por el Service Worker. Fix: `window.APP_VER` seteado directo antes de los defer scripts + `sello_v4.js` lee `window.APP_VER` en runtime + SW con `skipWaiting()` automático.

**Reportes robustos con múltiples fixes (v8.71)** — 15 fixes puntuales del panel: botones "+ Todas rutas / caminos", filtros case-insensitive de partidos con normalización de tildes, propiedad `PARTIDO_NOMBRE` correcta, botón "Limpiar todos" que sí anda, halo dorado que se quita al limpiar, filtro por partido en tab del reporte que detecta filas TOTAL por `colspan` (no por texto), pin que no sobreescribe campos del formulario cuando se mueve el cursor, mapa del "Reporte con fotos" que ahora muestra las trazas y los pins de tareas (via `circleMarker` + `fitBounds`).

## Funcionalidades destacadas (v8.65-v8.66e · v9.92a-v9.93.1 · agosto 2026)

**PDF Reporte Gerencial con layout oficial DVBA (v8.65 - v8.65.9)** — Nuevo botón "📄 Gerencia" en `reportes.html` que genera PDF institucional formato Informe Mensual Gerencia Ejecutiva DVBA. Portada con logo + km totales, resumen por 8 categorías oficiales con paleta institucional (`COLORES_TAREAS_GERENCIA`), hoja administrativa con RPs/caminos intervenidos + equipos por categoría, grid 3×3 de fotos (selección por diversidad de actividades), marca de agua "BORRADOR · SIN VALIDEZ OFICIAL" en cada hoja, aviso en portada. Iteraciones: fix mes rango multi-mes, fetch directo a relevamientos, watermark, contain con marco gris estilo Pehuajó, gerencia/admin default PBA con skip filtro zona, reportes contempla relevamientos huérfanos (toggle opcional "Incluir registros del mapa").

**Modelo de permisos y comentarios cross-zona (v8.66a - v8.66e · SQL_13)** — Nueva tabla `comentarios_zona` con policies RLS por rol (técnico ve su zona / gerencia ve todo + comenta / admin ejecuta). Botón "💬 Comentar" (gerencia/admin) y "🚚 Mover" (técnico) en popup del pin con modal para dejar comentario o solicitar cambio de zona. Panel admin en `admin_usuarios.html` con cola `v_solicitudes_admin` — botones Ejecutar (UPDATE zona / DELETE) o Descartar. Flujo completo: gerencia detecta problema → deja comentario → técnico responde OR gerencia solicita mover → admin ejecuta.

**Fix RP61 duplicada en PBA (v8.66b/c)** — En vista PBA se veían dos trazas superpuestas de RPs calibradas VI (bundle + geojson maestro). Fix con clipping inverso: `_recortarFeatureRutaFueraVI` deja solo tramos FUERA de VI en el geojson maestro. Bug secundario con nombres cardinales (`Veinticinco de Mayo` vs `25 de Mayo`) resuelto con aliases numéricos en `_partidoAZona`.

**Fix crítico app móvil offline (v9.92a)** — Modo Básico (`dvba_campo_lite.html`) no funcionaba sin internet porque cargaba `supabase-js` desde CDN externo. Fix: descargado a `datos/supabase-js.min.js`, cambiado el `<script src>` a local con fallback CDN, agregado al `CACHE_URLS` del SW. Ahora captura foto + queda en cola offline correctamente.

**ARMONIZADOR multi-zona + bug histórico (v9.93 - v9.93.1)** — Extendido `datos/armonizador.js` con `setGeojsonZonal(features)` para técnicos de zonas no-VI (agrega trazas RP no-calibradas al detector). Y **bug crítico oculto resuelto**: `dvba_campo.html` NUNCA importaba los bundles `rutas_rpXX.js` con `<script src>`. Por eso `CHAINS_DATA` quedaba undefined y `ARMONIZADOR.rutaMasCercana` siempre devolvía null (toast "cargá manual" garantizado). Ahora al aplicar GPS estando cerca de una RP calibrada, el wizard sugiere `RP X · km Y.Z` automático.

## Funcionalidades destacadas (v8.59-v8.64 · v9.91 · agosto 2026)

**Portal multi-zona real (v8.59-v8.64)** — El sistema pasó de piloto Zona VI a herramienta panorámica PBA con las 12 zonas viales de la Dirección de Vialidad.

- **Reorganización `datos/`** (v8.59): estructura `zonas/zona_XX/` (per-zona) + `rutas/` (bundles RP compartidos) + `referencias/` (masters PBA). Script `generar_zona_desde_master.py` filtra masters por zona.
- **Loader dinámico multi-zona** (v8.62): `datos/loader_zona.js` detecta zona por URL (`?zona=X`) > perfil técnico > default público PBA. Carga bundles RP + assets zonales vía `document.write` sincrónico. API `window.DVBA_ZONA` para consulta/cambio de zona.
- **Portal público panorámico** (v8.63): al abrir sin login se muestra toda la PBA (135 partidos, 12 zonas). Sidebar adaptativo — chips en zona específica, dropdown multi-select en PBA. Contadores dinámicos (partidos, rutas, caminos) por zona activa.
- **Paleta institucional 12 zonas + marca de agua** (v8.64 · Frente D): función `_colorZona(cod)` con 12 tonos armónicos (gama neutra-azulada, sin saturaciones tipo circo). En vista PBA cada partido se pinta con el color de su zona vial DVBA. Marca de agua "PBA · 12 Zonas Departamentales" en la parte inferior del mapa.
- **Auto-redirect técnico → `?zona=X`** (v8.62): un técnico logueado sin `?zona` explícito se redirige a su zona automáticamente. Admin/gerencia mantienen el picker manual.
- **RLS zonal completa** (SQL_9-12): filtro por zona en `caminos`, `partes_diarios`, `usuarios_perfil`. Trigger `SQL_10` fuerza `zona` según rol del user. Admin functions `SQL_11`. Modo público anónimo `SQL_12`.

**Bugfixes ciclo v8.63a→h** (portal multi-zona)

- `_reemplazarPartidos`: `.flat()` faltante en cleanup de `capasP` (arrays de layers, no layers) → sombreado VI persistía al cambiar de zona.
- `partesCargar`: `select('lat, lng')` (era `latitud, longitud` inexistentes → 400 Bad Request) + filtro `.eq('zona', zonaAct)`.
- Nombres partidos normalizados UPPERCASE → Title Case con `_titleCase()` (shp master tenía "ADOLFO ALSINA").
- `selR` inicial = todas activas en cualquier zona (incluida PBA).
- Rutas de VI dejaban de dibujarse en IV/V (`drawRutas`/`drawMojones` con guard por zona).

## Funcionalidades destacadas (v8.53-v8.58 · v9.91 · 2 agosto 2026)

**Unificación de headers, footers, botones y logos (v8.53-v8.55)**

- **Título institucional único**: `SIG Vial PBAᵝ` con beta griega superíndice dorada en los 4 portales escritorio (index, plan_seguridad, reportes, admin_usuarios) y ambos móviles (avanzado, básico).
- **Botones de navegación monocromáticos** (v8.55): estilo unificado `rgba(255,255,255,.15)` con borde translúcido, radius 5px, font 11px. Se abandonaron los colores verde/naranja/turquesa que tenían Plan/Reportes/Portal. Mantiene rojo característico solo para `🛡 Admin` (semánticamente restringido).
- **Botón Admin en los 4 portales escritorio**: cuando el usuario logueado tiene rol admin, aparece en todos los headers con `data-solo-admin` + CSS que arranca oculto para evitar FOUC.
- **Logo DVBA unificado**: `datos/img/logo_dvba_clean.png` con `object-fit:contain` sin fondo blanco ni borde en los 4 portales. En el `index.html` se reemplazó el `<img>` base64 JPG de 35 KB por referencia al PNG limpio (**-35 KB en el HTML**).
- **Módulo legales.js compartido** (v8.52): 4 tabs (Acerca / Términos / Privacidad / Permisos PWA) auto-inyectados. Un solo lugar para editar contactos, autoría y políticas.

**Móvil genérico multi-zona (v9.91)**

- Sacado el "Zona VI Saladillo" hardcoded del header/footer del avanzado y básico. Ahora el sub del header se llena dinámicamente con Rol+Zona real del user logueado (`Técnico · Zona IV`, `Admin · Zona VI`, etc.), leyendo `localStorage.dvba_perfil`.
- Footer del avanzado ahora dice `SIG Vial PBAᵝ · v9.91 · Acerca` (link tocable al modal legal, mismo `DVBA_LEGAL` del desktop).
- Modal Info del básico agrega Rol+Zona destacado además del mail chico en gris.
- **Efecto**: la misma PWA se puede distribuir (eventualmente en Play Store) para técnicos de cualquiera de las 12 zonas sin cambios de código. El rol y zona vienen del trigger `forzar_zona_por_rol` server-side (SQL_10).

**Portal público sin login (v8.56 · SQL_12)**

- Backend `SQL_12_publico_anon.sql`: el rol `anon` queda bloqueado para SELECT en `relevamientos`, `partes_diarios`, `parte_maquinarias`, `parte_fotos` y `usuarios_perfil`. Bloque defensivo que elimina cualquier policy legacy que exponga anon. Rollback documentado.
- Frontend `index.html` con dos modos por CSS: `data-solo-publico="1"` (solo visible sin sesión) y `data-requiere-sesion="1"` (solo visible con sesión). Función `aplicarModoSesion()` toggle al arranque y post-login/logout.
- **Modo público** muestra solo el mapa con Red Vial Provincial (RPs + caminos + partidos + localidades). El header expone únicamente logo + título + botón `🔐 Iniciar sesión` + botón `ℹ Alcance`.
- **Modal login opcional** (no bloqueante como antes): se abre al tocar el botón, tiene un `← Volver al mapa público` para cerrar sin loguearse.
- **`cargarRegs()` con gate**: sin sesión → `regs=[]` y salida temprana, no intenta el fetch a Supabase (ni genera 401 en consola).
- **Aviso público híbrido (v8.58)**: banner dismissible estilo cookies en la parte inferior con mensaje de alcance + shortcut `🔐 Iniciar sesión` + botón `Entendido ✕`. Flag `localStorage.dvba_aviso_publico_visto` evita que reaparezca. Botón `ℹ Alcance` en el header lo reabre bajo demanda.

**Fixes puntuales**

- **v8.57**: `reportes.html` no refetcheaba al cambiar el picker de zona (comentario original: `filtros de zona: pendiente`). Ahora `rpCambiarZona()` llama `rpGenerar()` y la query de `partes_diarios` incluye `.eq('zona', zonaActiva)`. Admin/gerencia con VI seleccionada + zona IV vacía → tabla y KPIs correctamente vacíos.
- **v8.56 audit versiones**: agregado footer institucional a `admin_usuarios.html` (no lo tenía). Bumpeadas todas las apariciones visibles a v8.58 en los 4 portales escritorio y v9.91 en los móviles.

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
Documento `https://github.com/lemeit/DVBA/blob/main/docs/PLAN_ESCALADO_MULTIZONA.md` con estructura de carpetas por zona, checklist paso a paso para habilitar nuevas zonas, presupuesto de esfuerzo estimado, prioridades y roadmap 2026-2027.

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

Para el detalle completo (matriz Tipo→Estados, guía de extensibilidad, flujo en cada app), ver **[`https://github.com/lemeit/DVBA/blob/main/docs/MODELO_TIPOS_ESTADOS.md`](https://github.com/lemeit/DVBA/blob/main/docs/MODELO_TIPOS_ESTADOS.md)**.

---

## Novedades v7.62 → v7.79 (13 julio 2026)

Sesión larga de 3 bloques que consolidó **el módulo "Plan de Seguridad en la Circulación"** (partes diarios oficiales), **la detección automática de partido**, y **la visualización de partes en el mapa del portal**. Detalle completo en la [bitácora tab Changelog](https://lemeit.github.io/DVBA/wiki/99-Bitacora/).

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

Nuevo **[`https://github.com/lemeit/DVBA/blob/main/docs/PLAN_ROLES_MULTIZONA.md`](https://github.com/lemeit/DVBA/blob/main/docs/PLAN_ROLES_MULTIZONA.md)** con la visión de 4 niveles (público / técnico zona / gerencia PDF oficial / admin) y roadmap de 5 fases para escalar el sistema a las 12 zonas provinciales. Se puede trabajar en paralelo al roadmap actual. El layout del PDF Gerencia (Fase 5) ya está analizado en **[`https://github.com/lemeit/DVBA/blob/main/docs/ANALISIS_INFORME_GERENCIAL_DVBA.md`](https://github.com/lemeit/DVBA/blob/main/docs/ANALISIS_INFORME_GERENCIAL_DVBA.md)**.

### Base SQL agregada

- `SQL_5_rls_partes_flexible.sql` · RLS flexibilizada para uso interno.
- `SQL_6_partido_en_partes.sql` · Columna `partido` en `partes_diarios` + view export.

---

## Novedades v7.46 → v7.57 · v9.50 → v9.53 (7–13 julio 2026)

**Sprint SIG Vial + gestión de fotos + rediseño UI**. Detalle completo en la [bitácora tab Changelog](https://lemeit.github.io/DVBA/wiki/99-Bitacora/).

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

Para detalles técnicos completos (5 columnas BD agregadas, lógica de umbrales, fases de implementación), ver la **[bitácora — Tab Changelog](https://lemeit.github.io/DVBA/wiki/99-Bitacora/)**.

---

## Convención institucional

Denominación oficial en todos los documentos y apps: **"Departamento Zona VI Saladillo"** o abreviado **"Zona VI Saladillo"**. NUNCA "Delegación Saladillo".

---

**Responsable:** Ing. Luciano Lamaita — División Técnica DVBA Zona VI
