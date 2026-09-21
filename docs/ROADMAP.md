# DVBA Zona VI · Roadmap consolidado

**Estado al 18 de agosto de 2026** · Familia escritorio en **v8.78** (index, partes_diarios, reportes, admin_usuarios), familia móvil PWA en **v9.95.14** (avanzado + básico + SW). Snapshot anterior: v8.58 / v9.91 (2 agosto). Ver §Actualización 18-ago al final para el detalle del sprint más reciente.

## ⏭ Próximas prioridades (mañana en adelante)

1. **Escalado multi-zona · empezar por 2 zonas piloto** (IV Junín, V 9 de Julio). Ver `docs/PLAN_ESCALADO_MULTIZONA.md`. Los assets QGIS (rutas, polígonos de partidos, mojones) ya están; falta el pipeline de carga estandarizado y calibración de bundles.
2. **Documento institucional interno** (deadline mediados septiembre 2026). Preparar informe con capturas actuales del portal, capturas del móvil en campo, screenshots de reportes, comparativa antes/después. *(Se gestiona fuera del repo público.)*
3. **Capturas y evidencia visual** del proyecto: sacar screenshots de cada portal, del flujo de campo, del panel admin, del sello v4 sobre foto, del reporte PDF, etc. Guardar en `docs/capturas/` para el informe.
4. **Evaluación de infraestructura futura** (Q4 2026):
   - **Supabase**: monitorear consumo real cuando lleguen las zonas nuevas (storage fotos, egress, requests). Umbrales Free/Pro/Team documentados en `docs/PLAN_STORAGE.md`. Evaluar si el plan Pro alcanza o hay que migrar.
   - **Alternativas para escalar**: self-hosted PostgREST + PostGIS + MinIO en VPS, Firebase/Firestore, AWS Amplify, Cloudflare D1/R2. Comparar costo/complejidad frente a Supabase Pro.
   - **Dominio propio**: hoy `lemeit.github.io/DVBA/`. Evaluar registrar `sigvial.gba.gob.ar` o `sigvial.dvba.gob.ar` cuando la app deje de ser piloto y pase a oficial. Requiere gestión institucional y certificados.

Este documento es la referencia única de qué está listo, qué queda pendiente, y en qué orden abordarlo. Complementa a:
- [`docs/PLAN_ROLES_MULTIZONA.md`](docs/PLAN_ROLES_MULTIZONA.md) — visión de 4 niveles + roadmap de 5 fases.
- [`docs/PLAN_STORAGE.md`](docs/PLAN_STORAGE.md) — análisis de consumo Supabase + estrategias de escala.
- [`docs/ANALISIS_INFORME_GERENCIAL_DVBA.md`](docs/ANALISIS_INFORME_GERENCIAL_DVBA.md) — layout oficial del PDF Gerencia (para Fase 5).
- [`docs/bitacora.html`](docs/bitacora.html) — historial detallado.

---

## 🟢 Terminado y estable

Todo lo del bloque original más lo agregado entre v7.62 y v7.83:

- **Mapa portal** con 8 partidos + 15 RPs + 100 caminos, cursor flotante, panel Capas, modo detallado, modal SIG Vial, leyenda actualizada con paleta institucional (v7.80).
- **App móvil PWA** con captura offline, cola sincronizada, pre-fill GPS por armonizador, workflow campo→oficina.
- **Sello v4 institucional** (v7.82+): 3 columnas (logo + texto + QR Google Maps), altitud GPS, versión del sistema estampada, sistema anti-sobresello (modo `esResellado` que corta banner viejo). Banner compacto ~30% más chico.
- **Logo institucional nuevo** (`logo_dvba_clean.png`) en portales, favicon, iconos PWA y sello móvil (base64 embebido, -53% peso).
- **Módulo Plan de Seguridad en la Circulación** (`partes_diarios.html`, v7.62+): CRUD de partes diarios alineado al Google Form oficial DVBA. Detección automática de partido, autocomplete de caminos con recorrido encadenado, dropdown único primaria+secundaria con typeahead, filtros por partido/ruta/vía, columna indicadora de fotos por parte (v7.83).
- **Capa 📋 Tareas en el mapa** (v7.76+): partes dibujados sobre traza real (RP y caminos) con colores por antigüedad (últimos 7d rojo, 30d dorado, 90d violeta, histórico gris). Popup con detalles.
- **632 partes históricos + 49 vehículos + 1203 vinculaciones** cargados por bulk desde CSVs.
- **RLS flexibilizada** para uso interno DVBA (SQL 5) + columna `partido` en `partes_diarios` (SQL 6).
- **Sidebar-footer institucional** fijo con resumen zona + info autor + versión.
- **Picker de zona en header** de ambos portales, con las 12 zonas DVBA.
- **Versionado unificado** de la familia escritorio (v7.X) y móvil (v9.X) — se bumpean juntos.
- **Documentación**: bitácora al día, plan de roles, plan de storage, análisis PDF gerencial, nomenclador 1989 como referencia.

---

## 🟠 Prioridad ALTA (próximas 1-3 sesiones)

### 1. Módulo Reportes básico (Bloque 3 · Sesión 3)

Es el killer feature institucional que falta. Reusa toda la infraestructura de v7.62-v7.83.

**Alcance mínimo aceptable:**
- Nueva tab **📊 Reportes** en el portal escritorio.
- Filtros: rango de fechas, zona (habilitado cuando llegue Fase 3 del Plan de Roles), partido, RP/camino, tarea, cuadrilla.
- Vista tabla con: fecha · tarea · vía · partido · km · equipos · foto ✓/✗.
- Bar chart por categoría de tarea (usando la paleta oficial de 8 colores del análisis gerencial).
- Contador de partes por mes (5 meses hacia atrás con línea de tendencia — mimic del reporte oficial).
- Export CSV.
- Vinculación con la capa 📋 Tareas del mapa (click en fila → zoom al partido/tramo).

**Alcance ampliado (Fase 5 · más adelante):**
- Export PDF con layout oficial DVBA (portada + 2 hojas por zona + luminarias LED).
- Requiere librería PDF (jsPDF + jsPDF-autotable, o Edge Function con pdf-lib).

### 2. Etapa 2 partes_diarios — subida directa de fotos con sello

Hoy en `partes_diarios.html` sólo se pueden **asociar** relevamientos ya cargados desde el móvil (rango ±5 días). Si no hay, el parte se guarda sin fotos. En v7.83 mejoré el mensaje pero la carga directa sigue pendiente.

**Alcance:**
- Botón "📸 Subir foto ahora" en el modal de nuevo/editar parte.
- Al subir: aplica sello v4 con datos del parte (fecha, ruta, prog, tarea, GPS del user si acepta permisos), sube a Storage como `_sello.jpg`.
- **Crea automáticamente un `relevamiento`** vinculado al parte (`parte_fotos.relevamiento_id`) para que la foto también aparezca en el mapa de relevamientos.
- Sin necesidad de pasar por la app móvil.

### 3-bis. Auditar sentido de traza de las 8 RPs + regenerar (nuevo, alta prioridad)

Detectado en RP51: los mojones sintéticos aparecen con sentido invertido. Ejemplo: km 220 en lat -36.12 (Alvear/Tapalqué, sur-oeste) cuando debería estar en el norte (25 de Mayo/Chivilcoy). RP30 mencionada también con posible orientación mal.

**Auditar cada una de las 8 RPs** contra la geografía real:
- RP 6, 30, 40, 41, 51, 61 → vienen de afuera de Zona VI, arrancan con `prog_ini > 0` (heredada del tramo previo). Verificar sentido.
- RP 42, 43, 44, 46, 47, 48, 91 → nacen dentro de Zona VI, arrancan en 0. Verificar sentido.

**Las que estén mal**: invertir el orden de puntos del `_traza_completa.geojson` en QGIS y regenerar bundle con `gen_ruta_bundle.py`.

Complementa v7.79 (que fixeó polylines de tareas invertidas, pero los mojones sintéticos siguen usando los datos crudos del bundle).

### 3. Regenerar RP30 y RP46 en QGIS (task histórica #195)

Bloqueadas hace tiempo por bug del `_traza_completa` (fids sin orden geográfico, mismo problema que RP61 en su momento). Sin bundle, no hay progresivas oficiales ni detección de partido para esas rutas.

**Acción**: renumerar fid en QGIS por orden geográfico (E→O u O→E), correr `recortar_zonavi.py` + `gen_ruta_bundle.py`. Documentado en la bitácora.

### 4. Fase 1 del Plan de Roles

Preparación backend antes de arrancar multi-zona. Bloquea las Fases 2-5.

- `SQL_7_usuarios_perfil.sql`: crear tabla + funciones helper `current_user_zona()` / `current_user_rol()`.
- `SQL_8_zona_en_tablas.sql`: `ALTER TABLE partes_diarios ADD COLUMN zona`. Backfill `'VI'` para los 632 partes históricos. Idem `relevamientos`.
- Insertar tu perfil como admin.

Ver detalle en `docs/PLAN_ROLES_MULTIZONA.md` sección "Fase 1".

---

## 🟡 Prioridad MEDIA (siguiente lote, 3-6 sesiones)

### 5. Fase 2 del Plan de Roles · Frontend zone-aware

Al login, cargar perfil del usuario y guardar en localStorage. Header + menú filtrados por rol.

### 6. Fase 3 del Plan de Roles · RLS zonal

`SQL_9_rls_zonal.sql`: reemplaza policies actuales por las nuevas. Técnicos ven sólo su zona, gerencia/admin ven todas. Rollback plan documentado.

### 7. Completar las 7 RPs restantes en QGIS

RP 6, 20, 24, 42, 43, 44, 48 — no procesadas. El badge de v7.75 ya advierte "ruta sin traza cargada" cuando el user las elige.

### 8. Detección de partido en app móvil

Replicar `pdDetectarPartido` + `pdInterpolarProgresiva` en `dvba_campo.html`. Requiere cargar `partidos_zona_vi.geojson` + bundles CHAIN_RPxx en la app móvil. Bump v9.59.

### 9. Backfill columna `partido` en 632 partes históricos

Script Python o SQL con extensión PostGIS (si está habilitada) que corre point-in-polygon offline sobre las progresivas medias. Complementa v7.70.

### 10. Ajustar compresión de fotos en móvil (`PLAN_STORAGE.md` acción 2)

Cambiar `comprimir(b64, 1600, 0.85)` → `(b64, 1200, 0.75)`. Reduce ~50% el tamaño típico de foto. Duplica el tiempo antes de llenar el bucket. Bump v9.59.

### 11. Contador "MB usados" en el sidebar del portal (`PLAN_STORAGE.md` acción 4)

Query semanal a `storage.objects` + fila en el panel-footer del sidebar tipo "📦 623 MB / 1 GB · 39% libre".

### 12. Purga programada de originales aprobados > 30 días

El botón manual "🧹 Mantenimiento Storage" ya existe (v7.50). Automatizarlo con `scheduled-tasks` semanal.

---

## 🔵 Prioridad BAJA / futuro

### 13. Fase 4 del Plan de Roles · Panel Admin usuarios

Página `admin_usuarios.html` con alta/baja/cambio de rol/zona.

### 14. Fase 5 del Plan de Roles · Reportes PDF oficiales Gerencia

Stack: `jsPDF + jsPDF-autotable` o Edge Function con `pdf-lib`. Layout definido en `docs/ANALISIS_INFORME_GERENCIAL_DVBA.md`.

### 15. Migración de storage a Cloudflare R2 o Supabase Pro

Se activará cuando el consumo Free se acerque al límite. Sistema de storage híbrido documentado en `PLAN_STORAGE.md`.

### 16. Debounce del oninput en selectores de ruta

Mientras el user tipea "RP 91" genera warnings intermedios en console ("RP 9" no tiene bundle). Cosmético.

### 17. Ocultar del datalist RPs sin bundle procesado

O marcarlas visualmente como "no operativas" hasta que se completen las 7 pendientes.

### 18. Edición fotos post-captura en escritorio: reubicar + re-sellar

Task histórica #202. Arrastrar pin en el mapa + reaplicar sello con progresiva actualizada. Muchas piezas ya existen (rotación, re-sello, guard doble-sello).

### 19. Catálogo caminos editable

UI para editar nombres locales de caminos sin tocar código. Tabla en Supabase + form en el portal.

### 20. Sistema "carrito de tramos" para reportes ad-hoc

Copiado de la lógica del visor `caminos_secundarios.html`. Selección multi-tramo por click + generación de reporte consolidado. Encaja perfecto con el modelo Tipo↔Estado.

### 21. Renombrar CACHE_NAME del SW

`dvba-campo-vX.Y` → `dvba-web-vX.Y`. El SW cachea AMBAS apps, no solo campo. Confuso al debuggear.

### 22. Progresiva → coord (feature nueva)

Input "Ir a progresiva km X+YYY" que posiciona el pin sobre la traza en ese km exacto. Complementa `coord → progresiva` que ya funciona.

### 23. Notificaciones push cuando hay pendientes

Web Push API con VAPID. Notificación al revisor cuando hay > N pendientes.

### 24. Modo oscuro consistente

Sidebar oscuro persistente + modal de sello con tema alterno.

### 25. Auditoría / log de cambios

Tabla `audit_log` que registra quién editó qué y cuándo. Decisión pendiente (Plan de Roles sección 7 pregunta 4).

### 26. Digitalizar Nomenclador 1989

Escanear páginas del cuadernillo institucional 1989 y transcribir a CSV. Ver `docs/REFERENCIA_NOMENCLADOR_1989.md`.

### 27. Piloto TMD / RURAL IT / V85

Features de investigación aplicada. Requieren hardware específico + partnership.

### 28. Integración expedientes DVBA

Export firmable + enlace a expediente digital de vialidad. Cierra circuito administrativo.

### 29. QR de sello ↔ traza en tiempo real

Nueva versión del QR que apunta a `https://lemeit.github.io/DVBA/#reg=ID` en lugar de Google Maps. Cierra loop trazabilidad.

### 30. Export/import bidireccional a QGIS

GeoPackage listo para abrir en QGIS + importador inverso.

### 31. Mapa dinámico embebido en el PDF de reportes

Hoy el PDF incluye 4 charts. Falta lo más visual e institucional: **una imagen del mapa con los eventos/tareas del rango filtrado**. Es lo mismo que hoy hace la capa 📋 Tareas del portal, pero exportado.

**Enfoque**: agregar botón "📸 Incluir mapa" en `reportes.html`. Al clickearlo:
1. Abrir `index.html` en un `<iframe>` invisible o en una tab hidden.
2. Pasarle los filtros actuales (rango de fechas / partido / RP) por query string (`?tareas=1&desde=...&hasta=...`).
3. Esperar a que la capa 📋 Tareas termine de dibujar.
4. Usar `leaflet-image` (plugin oficial de Leaflet, ~10KB) o `html2canvas` para capturar el mapa como PNG.
5. Insertar la PNG como página adicional del PDF, entre los charts y la tabla.

**Ventajas**: el mapa tiene toda la info que Gerencia espera ver (puntos coloreados por antigüedad, polylines sobre traza, partidos), sin necesidad de re-generar nada en QGIS. Ya está calculado.

**Bloqueado hasta**: implementar Etapa 2 partes_diarios (para que haya más partes con foto y datos completos que valga la pena capturar).

### 32. Asistente AI para gestión vial ⭐ (propuesta para el congreso)

Integración de un **chat prompt con IA** que ayude en la toma de decisiones y análisis de eventos/registros para la gestión vial de la PBA. Funcionalidades propuestas:

- **Consultas naturales sobre los datos**: "¿Cuántos partes de bacheo hicimos en Saladillo en junio?" → la IA arma el filtro y devuelve el resultado con contexto.
- **Análisis de patrones**: "¿Qué tareas se repiten más en tramos concretos?" → detecta hot-spots de deterioro recurrente.
- **Sugerencias de priorización**: dado el histórico de intervenciones + edad + tipo de superficie, sugerir qué tramos necesitan atención en los próximos 3 meses.
- **Generación de informes narrativos**: pasar el CSV/JSON del reporte y obtener un resumen ejecutivo en lenguaje natural para reunión de Gerencia.
- **Interpretación de fotos**: describir automáticamente qué se ve en una foto de relevamiento (bache/señal caída/banquina en mal estado) — con Vision API.

**Stack posible**: OpenAI GPT-4o-mini o Claude Haiku (bajo costo, alta velocidad) vía Edge Function de Supabase (no exponer API key desde frontend). Prompt engineering con contexto del sistema DVBA + acceso a queries via function calling. UI: modal chat en el portal.

**Costo estimado**: ~US$ 5-20/mes con consumo moderado (1000-5000 queries).

**Valor institucional**: no hay hoy ningún sistema vial de la PBA con IA integrada. Diferencial fuerte para presentar en el congreso vial 2026 como "próxima frontera" del proyecto.

Este ítem es un **desarrollo futuro** — se menciona en el informe del congreso como visión, no como implementado.

---

## 🧹 Housekeeping pendiente (manual)

- **[Manual]** Borrar `scripts/__pycache__` (task histórica #144).
- **[Manual]** Borrar `datos/zona_vi/red_secundaria_zonaVI_final.geojson.viejo_bak` (task #162).
- Diff `caminos_secundarios.html` vs subruta del portal → si el portal ya cubre todo, marcar deprecated.
- Verificar que GitHub Pages esté sirviendo v7.83 en producción.
- Correr manualmente los SQL 5 y 6 en Supabase (si aún no lo hiciste).

---

## Decisiones abiertas (para conversar con Gerencia)

Del `PLAN_ROLES_MULTIZONA.md`:

1. ¿Cómo se dan de alta usuarios? Autoregistro con dominio institucional o alta manual por admin.
2. ¿Compartir datos entre zonas linderas? (Ej. Zona VI y VII en el borde RP61).
3. ¿Rol supervisor de zona entre técnico y gerencia?
4. ¿Auditoría / log de cambios? (Tabla que crece rápido).
5. ✅ Formato del PDF oficial ya analizado.
6. ¿Escalar a piloto con otra zona (VII u XI)?

Del `PLAN_STORAGE.md`:

7. Cuándo migrar a Supabase Pro (US$ 25/mes) o Cloudflare R2 (gratis 10GB).

---

## 📅 Sugerencia de sprint próximo

**Recomendado para las próximas 2-3 sesiones:**

- **Sesión N**: Módulo Reportes básico (ítem 1) — tabla + filtros + bar chart + CSV.
- **Sesión N+1**: Etapa 2 partes_diarios (ítem 2) — subida directa + sellado + creación de relevamiento vinculado.
- **Sesión N+2**: Fase 1 Plan de Roles (ítem 4) — backend prep sin tocar UI.

Cuando esto esté cerrado ya tenés todo el ciclo operativo funcionando: **cargar → detectar partido → subir foto sellada → ver en mapa → generar reporte → compartir con Gerencia**.

Regenerar RP30/RP46 y las 7 RPs restantes (ítems 3 y 7) se pueden hacer en paralelo por vos mismo cuando tengas tiempo en QGIS, sin bloquear nada.

---

_Última revisión (cuerpo del roadmap): 2 de agosto de 2026 · v8.58 / v9.91._
_Última actualización (bloque §Actualización 18-ago): 18 de agosto de 2026 · v8.78 / v9.95.14._
_Responsable: Ing. Luciano Lamaita — División Técnica DVBA Zona VI Saladillo._

---

## 📌 Actualización · 18 de agosto de 2026 (sprint 12-18 agosto)

Este bloque documenta el progreso desde el snapshot v8.58/v9.91 hasta la versión actual **v8.78/v9.95.14**. Consolida lo completado esta semana y reprioriza el roadmap original. No reemplaza al cuerpo de arriba — es un delta.

### ✅ Completado en este sprint

**Rediseño arquitectural del modelo de datos:**

- **Modelo Tipos v2** con eje NATURALEZA (Relevamiento vs Tarea) ortogonal a la categoría del elemento. Categoría plana `mantenimiento` eliminada; cada elemento tiene ahora dos listas (`items_relev` + `items_tarea`). Nueva columna `naturaleza` en Supabase (SQL_15). API legacy preservada.
- **Migración #4** — `superficie` y `modalidad` pasan de estar serializadas en `observaciones` a columnas dedicadas (SQL_16). Backfill automático desde el texto existente + limpieza del sufijo. Ahora se pueden cruzar en reportes agregados sin parseos.
- **`docs/MODELO_TIPOS_ESTADOS.md` v1.3** reescrito con el modelo v2 completo.

**Codificación visual del mapa (Opción C):**

- Refactor completo del renderer de pins con SVG inline. Tres dimensiones visuales ortogonales: **forma** = categoría, **color** = severidad, **borde** = naturaleza.
- Sección "📌 Registros del mapa" agregada a la leyenda del portal con las 3 sub-tablas de códigos.
- Leyenda scrolleable con `L.DomEvent.disableScrollPropagation` y scrollbar 12px "en pastilla" para navegación cómoda con mouse.

**UI y wizard:**

- Wizard móvil rediseñado con paso 0 obligatorio de naturaleza + filtrado automático de categorías/ítems.
- Wizard escritorio con tabs "Relevamiento / Tarea" arriba del selector.
- Nuevo filtro por naturaleza en Reportes (`reportes.html`).

**Fixes estructurales:**

- **Pin salta lejos** — eliminado el fallback random (`punto medio ruta + ruido ~1 km`) que hacía saltar el pin del registro cuando `flat/flng` eran inválidos. Ahora alerta explícita.
- **Modo Básico crash al abrir cámara** — portada la cámara in-app con `getUserMedia` desde el Modo Avanzado. `<input capture>` nativo queda como fallback. Elimina el ciclo PWA→background→Android-mata-proceso.
- **Modo Básico sin internet** — extendido el fallback offline del Service Worker para cubrir `/app.html` + `/dvba_campo_lite.html`; antes solo cubría `/dvba_campo/`. Con `caches.match` tolerante a query params.
- **Cache ruta perdida al enviar** — cache defensivo `_ultimaRutaCargada` con 3 capas (`change` + `input` + poll 2s) para capturar TODOS los sets programáticos, no solo los manuales.
- **Sello sin sufijo origen** — se sacó `·campo` / `·escritorio` del pie del sello. Solo versión + `sello v4`.
- **Sincronización de spans hardcodeados** de versión en el footer del móvil (regla ampliada de 3 capas por HTML documentada).

**Wiki e infraestructura:**

- Wiki reorganizada en 2 secciones temáticas (`navigation.sections`): Guía de uso + Historia y evolución.
- Nueva página Nomenclador 1989 con PDF descargable filtrado por sesión activa.
- Guía Visual actualizada con los 3 pasos del wizard v2 + tabla completa por naturaleza + sección "Codificación visual del mapa".
- Limpieza de emails privados en wiki + portales + docs públicos (reemplazados por institucional genérico).
- Bloques `<div markdown="1">` de la Guía Visual reescritos con HTML puro para evitar el bug de `md_in_html` con hijos anidados en Python-Markdown 3.10.

**Infraestructura de versionado:**

- Setup dual remote: `origin` (GitHub público) + `gitlab` (GitLab privado como backup completo).
- Rama `concurso-privado` en GitLab con el `.md` del concurso versionado sin exponerlo a GitHub. Reglas de anti-fuga documentadas.
- **Recuperación del archivo `docs/CONCURSO_VIAL_2026.md`** que se había borrado accidentalmente (recuperado desde el historial git del commit c758ff1).

### 🎯 Ítems del roadmap original que quedaron completados

Del listado 🟠 Prioridad ALTA / 🟡 MEDIA / 🔵 BAJA original, este sprint cerró:

- Módulo Reportes (ítem 1) — ya con panel Wizard + presets, filtros dinámicos, contador de caminos únicos, PDF Gerencia con layout oficial, filtro por naturaleza.
- Etapa 2 partes_diarios (ítem 2) — subida directa de fotos con sello desde `partes_diarios.html`.
- Fase 1 Plan de Roles (ítem 4) — SQL_7/SQL_8 aplicados hace tiempo.
- Fase 2 Plan de Roles (ítem 5) — frontend zone-aware con picker de zona en header.
- Detección de partido en app móvil (ítem 8) — implementada en `dvba_campo.html` con armonizador.
- Backfill columna `partido` (ítem 9) — ejecutado.
- Ajustar compresión de fotos (ítem 10) — aplicado en móvil (1200px/q=0.75 en v9.88 y siguientes).
- Catálogo caminos editable (ítem 19) — implementado (SQL_14 + SQL_14b alias por tramo).
- Progresiva → coord (ítem 22) — implementado como botón "🎯 Ubicar".

### 🔴 Máxima prioridad ahora (post-sprint)

1. **RPs con bundle faltante o roto** — 7 RPs nunca generadas (RP6/20/24/42/43/44/48) + RP47/51/91 con anchors no-monotónicos + RP40 con desvío >10 km después del km 100. Sin ellas la detección automática de partido/progresiva queda con huecos. Flujo estándar: QGIS → renumerar fid por orden geográfico → `gen_ruta_bundle.py` → registrar en 3 HTMLs + `datos/rutas.js`.
2. **Fase 3 · RLS zonal activo en Supabase** — hoy el sistema es funcional pero monolítico Zona VI (cualquier login authenticated hace todo). Es el paso que habilita otras zonas piloto sin que se pisen los datos.
3. **Emails restantes en `datos/legales.js`** — el modal Acerca de del portal aún expone emails personales. Cambio de 5 minutos.

### 🟡 Media prioridad (siguientes lotes)

4. **Fase 5 · PDF Gerencia con layout oficial completo** — hoy hay una versión funcional; falta portada institucional completa + luminarias LED + anexo fotográfico + índice.
5. **Otras zonas piloto** — habilitar IV Junín o V 9 de Julio como segundo piloto para validar la generalización multi-zona.
6. **Capturas reales en la Guía Visual** — reemplazar los mockups CSS por screenshots del móvil v9.95.14 en producción.
7. **Documentar gap changelog mayo-junio 2026** en la bitácora (5 iteraciones sin registrar en su momento).

### 🔵 Baja prioridad / roadmap más largo

- **IA Fase A** (clasificador de fotos con Gemini) — mencionado en el documento del concurso (sección 8.4).
- **Dashboards agregados** — "% Bueno vs Malo vs Crítico" por ruta y categoría; filtros de lista por categoría+estado.
- **Otras líneas de investigación aplicada** — TMD con cámara, IRI-lite con acelerómetro, V85 con LIDAR, modelo de deterioro con series temporales, QR de sello con verificador público (todo detallado en sección 8.5 del documento del concurso).

Todo lo demás del cuerpo del roadmap sigue vigente. Este bloque es solo el delta que introduce el sprint del 12-18 agosto.
