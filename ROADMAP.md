# DVBA Zona VI · Roadmap

Estado al **6 de julio de 2026**. Portal desktop en **v7.39**, SW en **v9.42**, app móvil PWA sincronizada.

Este documento es la base para el **proyecto de congreso** — describe qué está funcionando hoy, qué hay por resolver, y las features que dan mayor valor institucional y técnico.

---

## 🟢 En producción y estable

- Mapa con 8 partidos + 15 RPs + 100 caminos secundarios integrados en el portal escritorio.
- Renderizado doble capa (HALO + BASE) para caminos, sin offset visual.
- Cursor flotante + tooltip permanente con progresiva sobre RP o camino.
- Panel único de Capas + Visualización con densidad de mojones y progresivas configurables.
- App móvil PWA con captura offline + cola sincronizada + pre-fill GPS desde armonizador.
- Cola de pendientes en escritorio con armonización geoespacial y aprobación batch para lo verificado automáticamente.
- Sello v3 con QR a Google Maps + logo institucional + datos editables antes de estampar.
- Detección automática al pin: elige RP o camino según cercanía real, ignora toggle para no forzar al usuario.

---

## 🔴 Bloqueadores / bugs de fondo (arreglar primero)

### 1. RP61 recortar a Zona VI (bug real)

La RP61 **nace en Gral Belgrano (Este) y termina en 9 de Julio (Oeste)** — ambos extremos FUERA de Zona VI. Crece **Este→Oeste**. Tiene un **gap grande donde comparte trazado con RN3/RP30** (la RP61 se apoya en esas rutas por varios km antes de continuar).

Al regenerar en v7.39 con el gap agregado, el mojón km 50 quedó snapped a `acc=459` porque cayó en el tramo compartido con RN3/RP30 que aporta cientos de km lineales al acumulado. El resto de anchors están normales (0 → 97 → 148 → 198 → 254).

**Acción (QGIS)**:
- Recortar `rp61_traza_zonavi.geojson` a **solo tramos dentro de Zona VI** (Este + Oeste con gaps entre ellos), sin incluir el gap RN3/RP30 completo.
- Mantener mojones oficiales solo los que caen dentro de Zona VI.
- `prog_ini` = km del primer mojón físico dentro de Zona VI.
- Regenerar bundle con `gen_ruta_bundle.py`.

Ver [`memory/reference_rp61_canonica.md`](internal) para detalles canónicos.

### 2. Sello mal generado en escritorio (task #174)

En la sesión previa apareció una foto con el sello cortado (falta parte de "Long"). Puede ser fallback silencioso del `catch` cuando algún dato no llegó. Ahora que el modal escritorio anda y el doble-sello está guardado, hay que verificar con una foto nueva.

**Acción**: reproducir con foto nueva; si sigue, revisar canvas del sello y validar cada campo antes de dibujar.

### 3. Detección RP91 vs camino en la práctica

Los logs muestran que la detección funciona bien pero en cierta zona de Saladillo la RP91 pasa tangencial a caminos secundarios (< 100 m) y el pin puede terminar eligiendo la RP aunque el operador estaba señalando el camino. El fix de umbral parcial ya está — falta calibración fina.

**Acción**: recolectar 5 casos donde el user esperaba camino y detectó RP; ajustar umbral en `UMBRAL_CAMINO_CERCA`.

---

## 🟠 Prioridad alta (esencial para el congreso)

### 4. Reportes desde el portal (task #125)

Sección **📊 Reportes** en tab dedicada del sidebar. Permitir:
- Seleccionar rango de fechas + partidos + tipos + estados.
- Filtro por RP y/o caminos.
- Exportar a **XLSX + PDF con las fotos selladas embebidas** (portable para expedientes).
- Reportes por elemento y por acción (usa el modelo Tipo↔Estado ya implementado).

Es la salida operativa que traduce datos de campo → informe firmable. Alta visibilidad institucional.

### 5. Progresiva → coord (feature nueva pedida)

Input "Ir a progresiva km X+YYY" que:
- Coloca el pin sobre la traza en ese km exacto.
- Autofilla lat/lng desde la traza.
- Útil cuando el operador **tiene planilla histórica con progresiva pero coord aproximada**.

Cierra el ciclo: hoy hacemos **coord → progresiva**, falta **progresiva → coord**. Ambas direcciones son necesarias en el flujo real.

### 6. Cola/report de tramos seleccionables (armar reportes ad-hoc)

Copiar la lógica del visor `caminos_secundarios.html` (selección multi-tramo por click) al portal, pero enriquecida:
- El operador va agregando tramos de RP y caminos al "carrito de reporte".
- Cada tramo con progresiva de inicio/fin editable.
- Genera un informe consolidado (obra, mantenimiento, patrullaje).

Encajaría perfecto con el modelo Tipo↔Estado. Ideal para presentar en congreso como "sistema de armado ágil de partes de obra".

### 7. Catálogo de caminos editable (task #126)

UI para editar nombres locales de caminos (`DENOMINACION`) sin tocar código. Tabla en Supabase + form en el portal.

Motivo: los caminos hoy solo tienen NOMEMCLATURA (`093-13`) pero los operarios los conocen por nombre popular ("El camino del cementerio"). Editable per-partido por usuarios autorizados.

---

## 🟡 Prioridad media (mejoras significativas)

### 8. RP91 con traza GPS de campo (task #139)

El usuario tiene test_rp91.html con traza GPS validada. Reemplazar traza oficial por la GPS que refleja mejor la realidad. Aplicable después a las demás RPs si el resultado es bueno.

### 9. Revisar y actualizar RPs restantes en `geojson_procesados/`

RP6, RP20, RP24, RP42, RP43, RP44, RP48 no fueron revisadas en Zona VI. Menos relevantes que las 8 principales pero conviene tenerlas para completitud.

### 10. Reorganizar UI sidebar de rutas + caminos

Hoy la lista de chips de caminos + RPs es larga y saturada. Rediseño propuesto:
- Filtros arriba (partido + clase + tipo_via).
- Selector jerárquico Partido → Caminos.
- **Modo "armar reporte"**: al activar, cada chip se comporta como "agregar al reporte" (relacionado con feature 6).

### 11. Renombrar CACHE_NAME del SW (task #153)

`dvba-campo-vX.Y` es confuso porque el SW cachea AMBAS apps (portal + móvil). Renombrar a `dvba-web-vX.Y`. Cambio menor pero elimina confusión de nombres al debuggear.

### 12. Bitácora auto-generada desde git log

La bitácora actual es HTML editado a mano. Migrar a generación automática desde commits + memory files.

---

## 🔵 Prioridad baja (nice-to-have)

### 13. Modo oscuro en toda la UI

Hoy el mapa Vista Oscura + panel Leyenda están adaptados. Falta:
- Sidebar oscuro persistente
- Modal de sello con tema alterno

### 14. Multi-usuario con roles

Hoy Supabase Auth tiene un solo tier (autenticado). Agregar roles: **operador de campo** (solo carga) vs **revisor/administrador** (aprueba, edita, exporta). RLS diferenciada.

### 15. Notificaciones push cuando hay pendientes

Web Push API con VAPID → cuando hay > N pendientes se notifica al revisor.

### 16. Dashboard estadístico

Panel "📈 Estado de la red" con:
- Cantidad de registros por partido/RP/mes.
- Distribución de tipos (bache, señal, banquina...).
- Heatmap de intervenciones.
- KPIs comparativos año-a-año.

### 17. Integración expedientes DVBA

Exportar registros como PDF firmable + enlace a expediente digital de vialidad. Cierra el circuito administrativo.

---

## 🎯 Features nuevas propuestas (mirando al congreso)

Estos 4 items dan mayor **valor conceptual y técnico** para una presentación académica. Están ordenados por impacto expositivo.

### A. Sistema de "carrito de tramos" para informes

Ya listado como task 6 más arriba. Es el killer feature del portal — pasa de visualizador a **herramienta operativa** para armar partes de obra en 5 minutos, con las fotos y progresivas ya cargadas. Historia clara para el congreso: "de la cartografía estática al parte de obra digital".

### B. Auditoría geoespacial de fotos históricas

El armonizador ya detecta desalineaciones. Extender a un **proceso batch**: correr sobre todos los registros históricos y flaggear los sospechosos. Se puede mostrar como "detección de errores de carga automática" con métricas concretas (X registros corregidos por el sistema en Y meses).

### C. Modelo de deterioro por tipo de superficie

Agregar campo `severidad` (0-100) al modelo. Con series temporales por punto GPS se puede:
- Estimar velocidad de deterioro por tipo de superficie (asfalto vs mejorado con dolomita).
- Predecir intervenciones necesarias en próximos 6 meses.

Es ciencia de datos aplicada. Ideal para paper.

### D. QR de sello ↔ traza en tiempo real

Hoy el QR del sello apunta a Google Maps. Nueva versión: el QR apunta a una URL propia `https://lemeit.github.io/DVBA/#reg=ID` que:
- Abre el portal.
- Zoom a la coord.
- Highlight del registro.
- Muestra los registros vecinos.

Cierra el loop: un fiscalizador de campo puede escanear el sello impreso y aparecer en el mapa completo. Historia contable "trazabilidad total del expediente".

### E. Export QGIS bidireccional

Endpoint que exporta los registros como GeoPackage listo para abrir en QGIS. Y importador inverso (edité en QGIS → subo a Supabase). Cierra el puente QGIS ↔ Portal ↔ Móvil como sistema completo.

---

## 🧹 Housekeeping pendiente

- [ ] **[Manual]** Borrar `scripts/__pycache__` (task #144)
- [ ] **[Manual]** Borrar `datos/zona_vi/red_secundaria_zonaVI_final.geojson.viejo_bak` (task #162)
- [ ] Diff caminos_secundarios.html vs subruta en portal → si el portal ya cubre todo, marcar la subruta como deprecated
- [ ] Migrar bitácora HTML a Markdown generado desde memory files

---

## 📅 Sugerencia de sprint pre-congreso

Para tener una demo sólida:

**Semana 1**: Reportes (task 4) + Progresiva→coord (task 5). Es el 80% del "wow" institucional.
**Semana 2**: Carrito de tramos (task 6) + RP61 anchor + sello checks. Pulido del flujo principal.
**Semana 3**: Feature auditiva (B) + slide deck del congreso. Materialización del impacto.

Semanas 4+ quedan para RP91 GPS + catálogo caminos + otras mejoras según feedback.

---

**Última revisión**: 6 de julio de 2026 · v7.39 desplegada.
**Responsable**: Ing. Luciano Lamaita — División Técnica DVBA Zona VI Saladillo.
