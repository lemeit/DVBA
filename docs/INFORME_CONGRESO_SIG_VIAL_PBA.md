# SIG Vial PBA · una herramienta simple para registrar el trabajo diario

**Borrador para el Congreso de Vialidad · versión de trabajo**

Autor: Ing. Luciano Lamaita · División Técnica · DVBA Zona VI Saladillo

Fecha del borrador: agosto 2026

---

## Resumen

Este trabajo describe **SIG Vial PBA**, un sistema web y móvil que empecé a desarrollar en 2024 para resolver un problema concreto de mi sector: dejar registro georreferenciado del trabajo diario de la Zona VI Saladillo (DVBA). No es un proyecto de I+D institucional ni un producto de una empresa de software: es una herramienta hecha por un ingeniero sin formación previa en programación, apoyado en asistentes de inteligencia artificial. Lo comparto porque creo que el enfoque puede resultarle útil a otras zonas viales o municipios que enfrenten necesidades parecidas y no cuenten con presupuesto ni equipos de desarrollo.

---

## 1. Punto de partida

La División Técnica de una zona vial acumula todos los días información valiosa: dónde se ejecutó una tarea, con qué equipo, qué se relevó, qué obras están pendientes. Tradicionalmente esa información viaja en planillas de papel, cuadernos personales, fotos sueltas en celulares, y planillas de cálculo dispersas. Consecuencias conocidas:

- La información existe pero **no se puede consultar** de forma ágil.
- No hay un mapa que muestre en un solo lugar qué se hizo y qué falta.
- Los relevamientos de campo tardan días en llegar a la oficina y semanas en convertirse en un reporte.
- Cada persona guarda su propio archivo, y el conocimiento se pierde cuando alguien cambia de sector.

Este diagnóstico no es original; lo comparten muchos organismos viales de la región, y sistemas más grandes (a nivel nacional o internacional) lo abordaron con inversiones significativas. Lo que sigue es una **respuesta a escala local**, pensada para una única zona vial provincial.

---

## 2. Enfoque general

La idea de arranque fue mínima: **poder marcar un punto en el mapa, adjuntar una foto y dejar registrado quién, cuándo, dónde y qué**. A partir de ahí, el sistema fue creciendo por iteraciones, en función de lo que la operación diaria pedía. No hubo un plan maestro inicial. Cada nueva pantalla nació de un problema real observado en la División Técnica.

Decisiones de base que se mantuvieron desde el principio:

- **Todo por navegador web** (nada que instalar en la oficina) y una **PWA** (aplicación web progresiva) instalable en el celular para el trabajo en campo.
- **Software libre** y servicios gratuitos o de bajo costo. Sin licencias.
- **Datos abiertos institucionales** para el fondo del mapa: OpenStreetMap y capas oficiales de la Provincia.
- **Ir de lo simple a lo complejo**. Primero la Zona VI Saladillo (piloto). Después ampliar.

---

## 3. Qué hace hoy el sistema

### 3.1 Portal web para oficina

Un mapa de la Provincia de Buenos Aires con las capas viales, filtrable por zona, ruta o partido. Sobre ese mapa se dibujan las tareas ejecutadas y los relevamientos de campo. Cada elemento tiene su ficha con datos oficiales y trazabilidad.

### 3.2 Aplicación móvil de campo

Diseñada para dos perfiles de operario:

- **Modo Básico**: un solo botón grande para sacar foto con GPS y enviar. Pensado para personal que no tiene fluidez con celulares.
- **Modo Avanzado**: un formulario guiado por pasos con categorías, tipos y estados, para quien puede clasificar en el momento.

Funciona sin conexión: si el operario está en un tramo sin señal, las capturas quedan en cola en el celular y se sincronizan solas al recuperar conexión.

### 3.3 Sello institucional en la foto

Cada foto queda con un overlay institucional al pie: fecha, coordenadas, ruta y progresiva. La foto sirve como registro oficial de la tarea sin necesidad de generar un parte aparte.

### 3.4 Flujo de trabajo por roles

El sistema modela los roles reales del organigrama zonal: técnicos que relevan en campo, capataces que ejecutan las tareas, jefes que asignan y revisan, gerencia que consulta. Cada rol ve solo lo que le corresponde de su zona, sin que se mezclen datos entre áreas.

La matriz de permisos aplicada:

| Rol | Alcance | Ver | Cargar | Editar | Borrar | Aprobar | Sugerir | Asignar |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| Público (sin login) | Solo mapa institucional | mapa | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Técnico | Su zona | ✓ zona | ✓ | ✓ propios | ✗ | ✗ | ✗ | ✗ |
| Capataz | Su zona | ✓ zona | ✓ cierre | ✗ | ✗ | ✗ | ✗ | ✗ |
| Jefe División Técnica | Su zona | ✓ zona | ✓ | ✓ | ✗ | ✓ relev. | ✗ | ✗ |
| Jefe División Operativa | Su zona | ✓ zona | ✓ | ✓ | ✗ | ✓ tareas | ✗ | ✓ |
| Jefe División Administrativa | Su zona | ✓ zona | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Jefe División Automotores | Su zona | ✓ zona | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Jefe de Zona | Su zona | ✓ zona | ✓ | ✓ | ✓ con motivo | ✓ | ✗ | ✓ |
| Gerencia | Todas las zonas | ✓ todas | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ |
| Admin | Todo el sistema | ✓ todo | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

Cuatro principios ordenan la matriz:

- **Descentralización zonal**: cada zona gestiona su propia operativa; la gerencia consulta y sugiere pero no ejecuta.
- **Jerarquía real de la DVBA**: los jefes de división administrativa y de automotores no cargan trabajo de campo (gestionan otras cosas), pero sí consultan datos de su zona.
- **Mínimo privilegio con trazabilidad**: nadie borra registros oficiales sin dejar rastro. Solo el admin borra de forma definitiva; el jefe de zona puede borrar en su zona pero debe completar un motivo obligatorio y queda registrado en auditoría. Cada registro además guarda automáticamente quién lo cargó (nombre + rol + zona en ese momento), para que el aprobador en oficina sepa el origen antes de tomar decisiones.
- **Trazabilidad geográfica**: cada foto o relevamiento cae automáticamente en la zona del partido donde ocurrió, sin importar qué usuario lo cargó.

### 3.5 Seguridad de la base de datos

El backend usa Row-Level Security de PostgreSQL con políticas específicas para cada rol y zona, funciones de auditoría y separación estricta entre usuarios anónimos y autenticados. Después de una auditoría de seguridad se cerraron todos los hallazgos del linter automático: 0 errores y los pocos warnings restantes son las funciones helpers necesarias para que las políticas evalúen, con validación de rol dentro de cada función. Los borrados de registros son en dos niveles: el jefe de zona hace un archivado con motivo obligatorio (recuperable por admin), y el admin es el único que puede eliminar físicamente. Toda esta capa vive en la base de datos, no en el frontend — es imposible saltearla desde el navegador o desde la app móvil.

### 3.5 Reportes mensuales

Filtros por fecha, ruta, partido, tipo de tarea, con exportación a PDF y a Excel. Alineados con el formato oficial del Informe Mensual de Gerencia de DVBA.

---

## 4. Cómo se construyó

El desarrollo se hizo con la asistencia de modelos de lenguaje (IA generativa) como copilotos de programación. Yo describía en lenguaje natural el problema y la solución deseada; la IA proponía código; yo lo revisaba, probaba y ajustaba. Este flujo permitió:

- Aprender programación web básica sin cursos formales.
- Iterar rápido sobre las necesidades reales del sector.
- Documentar cada cambio en una bitácora que hoy sirve tanto para pasar el conocimiento como para justificar decisiones técnicas.

No es un proceso mágico ni automático. Cada iteración requiere entender qué se quiere lograr, verificar que lo que devuelve la IA tenga sentido, y probar en producción con datos reales. La IA acelera el proceso, no lo reemplaza.

---

## 5. Estado actual (agosto 2026)

- **Zona piloto en producción**: Zona VI Saladillo (8 partidos, 15 rutas provinciales, 100 caminos secundarios registrados).
- **Zonas en preparación**: IV Junín y V Chivilcoy (rutas compartidas con VI, ya calibradas).
- **Registros cargados**: relevamientos, tareas ejecutadas con foto, partes diarios.
- **Estructura preparada para las 12 zonas viales** de la Provincia y los 135 partidos, con filtrado geográfico automático (cada registro se asigna a la zona del partido donde ocurrió, independientemente del operario que lo cargó).
- **Guía de usuario pública** disponible en línea con el detalle de cada portal.

---

## 6. Aporte al trabajo diario

Lo que cambió efectivamente en el día a día de la División Técnica desde que el sistema está en uso:

- El registro de una tarea de campo dejó de ser una anotación en papel y pasó a ser una foto con datos georreferenciados en menos de un minuto.
- Los relevamientos llegan a la oficina en tiempo real, sin traspaso manual.
- El armado del reporte mensual pasó de ser una tarea de varios días a un proceso de minutos con filtros y descarga automática.
- Todo el histórico queda buscable en un mapa, algo que antes era físicamente imposible.

Nada de esto es revolucionario a nivel técnico. Es un conjunto de piezas conocidas (mapa web, formularios, base de datos, PWA) ensambladas para un uso concreto. La novedad, si la hay, está en que se hizo desde adentro del sector técnico, sin proveedor externo y sin desviarse del trabajo diario.

---

## 7. Limitaciones y próximos pasos

**Limitaciones actuales**:

- El sistema no publica todavía servicios estándar de datos geográficos que permitan integrarse con otras infraestructuras provinciales o nacionales.
- El índice de estado de la infraestructura vial es cualitativo, no cuantitativo. No reemplaza a los métodos de auscultación técnica.
- El escalado a las 12 zonas requiere validación en más de un piloto antes de estabilizarse.

**Próximos pasos**:

- Ampliar la calibración de rutas provinciales para incluir todas las zonas.
- Estandarizar los datos geográficos para que puedan ser consumidos por otras dependencias provinciales.
- Documentar en detalle el proceso para que otras zonas puedan replicar o adaptar el sistema.

---

## 8. Reflexión final

Este sistema no se propone competir con las plataformas institucionales de mayor escala. Su valor está en que **existe** y **se usa**, cuando lo esperable era que un sector chico no pudiera darse el lujo de desarrollar herramientas propias.

Si algo puede aportar este trabajo a la comunidad vial, es la evidencia de que hoy, con las herramientas disponibles y el uso responsable de la IA, un profesional del sector puede construir soluciones adaptadas a su realidad sin depender de presupuestos, licencias ni tercerizaciones. No es la única manera de resolver el problema, pero es una posible.

---

## Datos de contacto

- Correo institucional DVBA Zona VI: admin.zonavi@vialidad.gba.gov.ar
- Portal público (modo consulta): [lemeit.github.io/DVBA](https://lemeit.github.io/DVBA/)
- Guía de usuario: [lemeit.github.io/DVBA/wiki](https://lemeit.github.io/DVBA/wiki/)

---

## Notas para redacción final

- Ajustar cifras concretas antes del envío (número de relevamientos cargados, tiempos operativos medidos, cantidad de usuarios activos por rol).
- Sumar 4-6 capturas de pantalla como material visual (portal, app móvil, modal de una ruta, reporte generado).
- Definir extensión final según el formato que pida el congreso (paper corto, resumen extendido, presentación).
- Revisar el tono de cada sección para que no suene declarativo ni promocional.
- Si es paper académico, agregar referencias a antecedentes (SIG Vial 2008, ponencia DNV 2012, IDERA, estándares OGC) para posicionamiento.
