# Referencia · Sistema SIG Vial anterior (predecesor de SIG Vial PBA)

> Documento de referencia histórica. Registra la existencia y características observables del sistema SIG Vial anterior que sirvió como **inspiración parcial** para el desarrollo de SIG Vial PBA (2026).
>
> **Fuente:** capturas de pantalla y el CSV oficial `SALADILLO_RED` heredado de ese sistema (base del catálogo actual de Caminos Secundarios).

## Contexto

El sistema anterior (**Sistema SIG Vial 2008**) era una aplicación web utilizada históricamente por la Dirección de Vialidad de la Provincia de Buenos Aires para consulta cartográfica de la red vial. No está actualmente en funcionamiento operativo, pero **partes de su contenido (nomenclatura, catálogo de tramos, denominaciones)** sobrevivieron como referencia autoritativa y fueron incorporados al desarrollo actual.

## Artefactos disponibles

- **`Sistema SIG Vial 2008.pdf`** — documento oficial del sistema original de referencia. Incluye especificaciones y el manual/presentación institucional del sistema.
- **Captura de pantalla de referencia** de una instancia del sistema. Muestra:
  - Vista cartográfica centrada en la región Zona VI Saladillo (coordenadas −35.85, −59.34).
  - Traza visible de RP 5, RP 51, RP 40, RP 65, RP 205 y RP 91 con la nomenclatura oficial de escuditos DVBA.
  - Panel lateral **"Configuración de capas"** con dos capas activas: *Red Vial Nacional* y *Límites Político-administrativos (IGN)*.
  - Controles UI clásicos: opacidad, color, ancho de línea, estilo (continua/punteada) — patrón que persiste en el diseño del portal actual.
  - Escala 10 km · barra de coordenadas al pie · botones de herramienta a la izquierda (zoom, filtros, exportación, compartir, impresión).

## Elementos heredados en SIG Vial PBA (piloto 2026)

### Contenido (data)

- **CSV oficial `SALADILLO_RED`** — catálogo de 96 tramos × 15 RPs con nomenclatura (`051-110-03A`, etc.), denominación, clase, longitud oficial y partido. Es el insumo autoritativo para la sección "Red Vial Provincial Primaria" del módulo Reportes y para las funcionalidades de auto-detección de partido por progresiva.
- **Nomenclatura oficial DVBA de 1989** (Ing. Bertoni) — documentada aparte en `docs/REFERENCIA_NOMENCLADOR_1989.md`, es el corpus normativo con el que se cotejan todas las denominaciones de vías.
- **Convención de escuditos de rutas** (formato numérico dentro de un pentágono para RP, óvalo para RN) — replicado en la simbología del mapa actual y en los sellos institucionales.

### Diseño (UI)

- **Panel de configuración de capas** con opacidad, color, ancho — presente en el portal actual (`index.html`) dentro del sidebar de "Vías".
- **Herramientas laterales** (zoom, filtros, ubicación) — evolucionadas en el toolbar del portal actual.
- **Marca institucional DVBA** consistente en color turquesa/azul.

## Diferencias arquitectónicas con SIG Vial PBA

| Aspecto | SIG Vial anterior (referencia) | SIG Vial PBA (2026) |
|---|---|---|
| Stack | Aplicación web tradicional | HTML5 + JS vanilla + Supabase, sin backend propio |
| Escala | Vista Provincia | Portal público multi-zona (12 zonas · 135 partidos) |
| Móvil | No documentado | PWA unificada con 2 modos (Básico + Avanzado) |
| Captura en campo | No aplicable | Foto con GPS + sello institucional v4 + workflow campo→oficina |
| Modelo de roles | No documentado | 4 niveles (público / técnico zona / gerencia / admin) con RLS zonal |
| Reportes | Consulta cartográfica | PDF institucional con paleta oficial 8 colores + dashboard gerencial + charts |
| IA | No | Fase A implementada (clasificador de fotos con Gemini) + roadmap 4 fases |
| Hosting | Servidor institucional | GitHub Pages (frontend) + Supabase (backend/BD/storage) |

## Cita y uso institucional

Aunque el sistema anterior ya no está en producción, su existencia respalda el argumento de que **SIG Vial PBA es un desarrollo evolutivo** que retoma esfuerzos institucionales previos, no un producto foráneo. En el documento del concurso (`docs/CONCURSO_VIAL_2026.md`) se puede citar como antecedente en las secciones de contexto institucional y arquitectura.

---

**Preparado por:** Ing. Luciano Lamaita · División Técnica DVBA · Zona VI Saladillo
**Fecha:** 12 de agosto de 2026
**Estado del documento:** referencia histórica · consultable
