# Informe · Congreso Vial 2026

> Documento base para la presentación del sistema DVBA Zona VI Saladillo al **Congreso Vial 2026**.
> Autor: Ing. Luciano Lamaita · División Técnica DVBA · Zona VI Saladillo
> Estado del sistema al momento: **v7.86** (16 de julio de 2026)

---

## 1. Resumen ejecutivo

El sistema **DVBA Zona VI** es una plataforma web integral para el relevamiento, gestión y reporte de la red vial provincial, desarrollada íntegramente en la Zona Departamental VI Saladillo. Cubre desde la captura en campo con GPS (app móvil PWA) hasta la generación de reportes PDF institucionales, pasando por el registro estandarizado de tareas diarias y la visualización cartográfica interactiva.

**Alcance actual (piloto Zona VI)**:
- 8 partidos + 15 rutas provinciales (8 con traza calibrada y detección automática de partido) + 100 caminos secundarios integrados.
- 632 partes diarios históricos migrados + registro continuo de nuevas tareas.
- 49 vehículos institucionales catalogados con 1.203 vinculaciones a tareas.
- Sistema de sello digital v4 con QR a Google Maps + altitud GPS + trazabilidad de versión.
- Módulo de reportes con 4 charts institucionales + tabla filtrable + export CSV/PDF.

**Diferenciales técnicos** que la Provincia no tiene hoy en ningún otro sistema equivalente:

1. **Detección automática de partido** a partir de progresiva y ruta (interpolación + point-in-polygon).
2. **Autocomplete inteligente** de caminos con recorrido encadenado ("Saladillo — La Barrancosa — Micheo").
3. **Sistema anti-sobresello**: al re-editar una foto ya estampada, el sistema corta el banner viejo y estampa el nuevo del mismo tamaño (imperceptible).
4. **Workflow campo → oficina**: la foto se captura cruda en el móvil y se sella al aprobar en oficina, permitiendo corrección de datos GPS antes del sellado definitivo.
5. **Modelo Tipo↔Estado** con árbol de 10 categorías + sub-atributos condicionales por tipo de elemento vial.
6. **Reportes PDF institucionales** generados en el browser (sin backend), con la paleta oficial DVBA cotejada contra el informe mensual Gerencia Ejecutiva.

---

## 2. Arquitectura

- **Frontend**: HTML5 + CSS3 + JavaScript vanilla (sin frameworks). Portable, sin dependencias de build, deployable en GitHub Pages.
- **Cartografía**: Leaflet 1.9.4 + OpenStreetMap + tiles satelital.
- **Backend**: Supabase (PostgreSQL + Auth JWT + Storage + RLS por rol).
- **PWA**: Service Worker con estrategia network-first + cache offline + Background Sync.
- **Charts**: Chart.js 4.4 (CDN).
- **PDF**: jsPDF 2.5 + autotable (client-side, sin backend).
- **Datos geográficos**: geojsons procesados desde QGIS 3.34 con PyQGIS.
- **Hosting**: GitHub Pages (`https://lemeit.github.io/DVBA/`).
- **Repo público**: [`lemeit/DVBA`](https://github.com/lemeit/DVBA).

---

## 3. Estado al momento de la presentación

Cubierto en detalle en:
- [`README.md`](../README.md) — presentación del sistema.
- [`ROADMAP.md`](../ROADMAP.md) — hoja de ruta consolidada.
- [`docs/PLAN_ROLES_MULTIZONA.md`](PLAN_ROLES_MULTIZONA.md) — visión de escalado a las 12 zonas provinciales.
- [`docs/PLAN_STORAGE.md`](PLAN_STORAGE.md) — análisis de consumo y proyección.
- [`docs/ANALISIS_INFORME_GERENCIAL_DVBA.md`](ANALISIS_INFORME_GERENCIAL_DVBA.md) — cotejo con el formato oficial de Gerencia Ejecutiva.
- [`docs/bitacora.html`](bitacora.html) — historial técnico completo.

---

## 4. Visión de futuro (secciones para el informe)

### 4.1 Escalado multi-zona a las 12 zonas viales de PBA

Sistema de 4 niveles de usuario (público / técnico zona / gerencia / admin) con RLS por zona ya diseñado (ver `PLAN_ROLES_MULTIZONA.md`, 5 fases, ~10 sesiones de desarrollo). Cada zona técnica podrá cargar y consultar sus datos operativos, mientras Gerencia Central consolida las 12 zonas en un mismo dashboard.

### 4.2 Reportes PDF oficiales replicando el formato DVBA existente

Fase 5 del plan de roles: PDF completo con portada institucional, 2 hojas por zona (administrativa + GIS), tabla luminarias LED, anexo fotográfico, paleta de 8 colores oficial por categoría de tarea. El análisis del layout oficial ya está documentado.

### 4.3 Mapa integrado en los reportes

Reemplazo de exports manuales de QGIS por captura automática del mapa Leaflet ya renderizado del portal, con filtros del reporte aplicados (fecha, partido, tarea). Reduce el flujo de trabajo de horas a segundos.

### 4.4 ⭐ Asistente AI para gestión vial

**Propuesta destacada para el informe del congreso** — es el diferencial que ningún sistema vial de la PBA tiene hoy.

Integración de un chat prompt con **modelo de lenguaje grande** (GPT-4o-mini o Claude Haiku) que asista al personal técnico y jerárquico en la gestión diaria:

**Casos de uso propuestos**:

| Rol | Consulta ejemplo | Respuesta esperada |
|---|---|---|
| Técnico | *"¿Cuántos partes de bacheo hicimos en Saladillo en junio?"* | Filtra automáticamente + devuelve cantidad + link al reporte |
| Técnico | *"¿Qué maquinaria usé más este mes?"* | Ranking con equipos + km de uso + partes asociados |
| Gerencia | *"Comparame la ejecución de Zona VI vs Zona VII este trimestre"* | Tabla comparativa + análisis narrativo |
| Gerencia | *"¿Qué tramos requieren atención próxima?"* | Detección de hot-spots por recurrencia de tareas + antigüedad |
| Admin | *"Resumime el mes en 3 párrafos para reunión"* | Informe ejecutivo generado automáticamente |
| Cualquiera | *"¿Qué se ve en esta foto?"* (con Vision API) | Descripción del deterioro/elemento vial + sugerencia de tipo de tarea |

**Beneficios institucionales**:
- Reduce la barrera técnica para consultar el sistema — cualquier persona con lenguaje natural puede obtener información.
- Detecta patrones que un humano no vería a simple vista (correlaciones entre tipo de superficie / recurrencia / partido).
- Agiliza la elaboración de informes mensuales de Gerencia (hoy consumen horas de trabajo administrativo).
- Base para modelos predictivos de deterioro y planificación de intervenciones.

**Stack técnico propuesto**:
- **Backend**: Edge Function de Supabase (Deno) que actúa como proxy — la API key del modelo NO se expone al frontend.
- **Modelo**: OpenAI GPT-4o-mini (US$ ~0.15/M tokens input, ~0.60/M tokens output) o Anthropic Claude Haiku (similar).
- **Function calling**: el modelo puede llamar funciones SQL parametrizadas del sistema (ej. `getPartesByFilters(zona, tarea, mes)`) para obtener datos frescos.
- **Vision**: OpenAI GPT-4o Vision o Claude 3.5 Sonnet Vision para interpretar fotos de relevamiento.
- **UI**: modal chat en el portal, discrepto pero accesible desde todas las apps del sistema.
- **Costo estimado**: US$ 5-20/mes con uso moderado (1.000-5.000 consultas). Escalable a US$ 100+/mes si se abre a las 12 zonas.

**Estado**: pendiente de decisión institucional y presupuestaria. Se documenta como **desarrollo futuro** en el informe del congreso, no como implementado.

### 4.5 Otras líneas de investigación aplicada

- **Piloto TMD** (Tránsito Medio Diario) con cámara de video en rutas seleccionadas.
- **Integración con acelerómetro RURAL IT** para medir condición de pavimento en tiempo real.
- **Medición V85** (velocidad percentil 85) con LIDAR.
- **Modelo de deterioro por tipo de superficie** con series temporales para predecir intervenciones.
- **QR de sello ↔ traza en tiempo real**: fiscalizador escanea foto sellada y aparece en el mapa completo.

---

## 5. Impacto esperado

**En el corto plazo (Zona VI, 2026)**:
- Reducción del tiempo de armado del parte mensual de Gerencia de ~8 horas a ~30 minutos.
- Trazabilidad completa de cada tarea con foto + GPS + progresiva + firma digital.
- Consulta cartográfica del histórico de intervenciones al alcance de un click.

**En el mediano plazo (multi-zona, 2027)**:
- Cada zona vial administra sus datos con la misma herramienta.
- Gerencia Central consolida las 12 zonas en un dashboard único.
- Auditoría automática de discrepancias entre datos declarados y datos capturados.

**En el largo plazo (asistente AI + análisis predictivo, 2027+)**:
- Toma de decisiones basada en datos con soporte de IA.
- Priorización automática de intervenciones según deterioro y presupuesto.
- Sistema modelo para replicar en otras provincias argentinas.

---

## 6. Reconocimiento y equipo

- **Desarrollo**: Ing. Luciano Lamaita — División Técnica DVBA Zona VI Saladillo.
- **Datos oficiales**: cotejados contra el *Nomenclador de Rutas DVBA 1989* (Ing. Luis F. Bertoni, Jefe Int. Div. Técnica), Ministerio de Infraestructura PBA, ARBA e IGN.
- **Infraestructura**: hosting gratuito GitHub Pages + backend Supabase (plan Free en piloto).
- **Sin costo institucional** hasta la fecha para el desarrollo del piloto.

---

## 7. Anexos

- Screenshots del sistema en producción (adjuntar).
- CSV/PDF de ejemplo de reporte mensual.
- Manual de usuario de la app móvil (`docs/guia_dvba_campo.html`).
- Análisis del informe oficial DVBA para cotejo (`docs/ANALISIS_INFORME_GERENCIAL_DVBA.md`).

---

_Última actualización: 16 de julio de 2026 · v7.86 desplegada._
