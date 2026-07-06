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

### 1. RP61: parcialmente resuelto, falta renumerar fid en QGIS

**Recorrido real verificado (E→O)**:
1. Gral Belgrano (nace, fuera Zona VI) → Las Flores urbana
2. **Gap Las Flores**: RN3 → RP30 hasta encontrar RP91 (~18 km recta / 25 km real)
3. Post-RP91: camino de tierra hasta Gral Alvear
4. **Gap Alvear**: usa ~280 m de RN205
5. Camino de tierra hasta 9 de Julio (fin, fuera Zona VI)

**✅ Fix anchors (v7.40)**: `gen_ruta_bundle.py v2.9` descarta anchors cuyo snap cae en gap. El mojón km 50 (que caía en el Gap Las Flores con acc=459 espurio) ya no distorsiona la interpolación. Anchors resultantes monotónicos: `0 → 97.5 → 148.6 → 198.9 → 254.3 → 567.7`.

**❌ Pendiente (task #186)**: los tramos gap en el geojson tienen `fid=5` y `fid=6` (mayor que los normales), quedan **al final** de la cadena por el orden por fid → genera rectas gigantes de 177 km y 102 km al saltar de vuelta al Este/centro. Renumerar manualmente en QGIS:

| fid actual | Nuevo fid | Tramo |
|---|---|---|
| 1 | 1 | Belgrano → Las Flores |
| 5 (gap) | **2** | Gap RN3+RP30 |
| 2 | 3 | Post-Las Flores → 25M |
| 3 | 4 | 25M → Alvear |
| 6 (gap) | **5** | Gap RN205 |
| 4 | 6 | Alvear → 9 Julio |

Después regenerar bundle. Ver [`memory/reference_rp61_canonica.md`](internal).

**Nueva regla operativa**: al digitalizar en QGIS, los `fid` deben reflejar el **orden geográfico real** (E→O u O→E según sentido de crecimiento), incluidos los gaps intercalados. Nunca dejarlos al final por orden de digitalización.

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
