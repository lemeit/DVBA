# Capturas para el Informe · Concurso Vial 2026

Esta carpeta contiene las **capturas de pantalla y mockups** que se insertan como figuras en el informe del concurso `CONCURSO_VIAL_2026.md`.

## Cómo tomar capturas en Windows

Combinación de teclas: **`Windows + Shift + S`** → seleccionar región → la captura queda en el portapapeles → pegarla en Paint o guardarla directo con la app *"Recorte y anotación"* (que abre automáticamente).

Guardar cada archivo en esta misma carpeta con el nombre exacto listado abajo (ej. `fig-01-portal-panoramica-pba.png`).

---

## Lista de capturas necesarias

Numeradas en el orden de aparición en el informe. Cada captura tiene:
- **Nombre de archivo** — usar exactamente ese nombre al guardar.
- **Sección del informe** — dónde va insertada.
- **Cómo tomarla** — pasos concretos.
- **Encuadre sugerido** — qué debe quedar visible.

### `fig-01-punto-de-partida.png` · Ilustración conceptual antes/después

**Sección**: `## 1. Punto de partida` (después del primer bloque de bullets, antes de "Ninguna de estas herramientas...")

**Origen**: Diagrama conceptual que **hay que armar aparte** — no es captura del sistema. Sugerencia: en Canva, LibreOffice Draw o PowerPoint dibujar:

- Lado izquierdo: **Fragmentación** — carpeta física con papeles + logo de Google Forms + logo de Excel + fotos sueltas en un teléfono + una computadora aislada con "QGIS local". Los elementos conectados por líneas discontinuas (fragmentación).
- Flecha central: **SIG Vial PBA**.
- Lado derecho: **Sistema unificado** — un mapa web + app móvil + base de datos central en la nube. Los elementos conectados por líneas sólidas (integración).

Alternativa más simple: dejar esta captura para el final o directamente omitirla.

---

### `fig-02-qgis-metodologia.png` · Screenshot de QGIS con capas del sistema

**Sección**: `## 2. Base cartográfica en QGIS` — al principio, como imagen introductoria de la Parte 2.

**Cómo tomarla**: Abrir tu QGIS con el proyecto de la Zona VI Saladillo cargado (rutas + mojones + partidos + red secundaria). Encuadrar la Zona VI completa con las capas visibles. Zoom moderado (no tan cerca que no se vea nada, no tan lejos que se pierda el detalle).

**Encuadre sugerido**: La Zona VI completa con las 8 partidos delineados, las rutas RP en color de traza, los mojones como puntos, y el panel lateral de capas de QGIS visible a la izquierda (para que se identifique como QGIS).

---

### `fig-03-portal-panoramica-pba.png` · Portal público en vista panorámica PBA con 12 zonas

**Sección**: `## 2.5 Asignación geográfica de partidos` (dentro de Parte 2) — o alternativamente en Parte 3.1 "Del piloto zonal a la visión panorámica provincial".

**Cómo tomarla**:
1. Abrir en Chrome: `https://lemeit.github.io/DVBA/`
2. Esperar que cargue el mapa.
3. **Sin loguearte**. La vista pública muestra las 12 zonas coloreadas.
4. Si el mapa arranca en zoom mundial: click en el `+` de zoom hasta ver toda la Provincia de Buenos Aires bien encuadrada.
5. Captura con `Windows + Shift + S`: seleccionar toda la ventana del navegador (o solo el mapa + sidebar).

**Encuadre sugerido**: PBA completa con las 12 zonas coloreadas. Sidebar izquierda visible con listado de partidos. Header y footer también visibles para mostrar la interfaz completa.

---

### `fig-04-portal-vista-zonal-detallada.png` · Portal público en vista zonal detallada (Zona VI Saladillo)

**Sección**: `## 4.3 Portal web de escritorio` — como imagen principal del módulo.

**Cómo tomarla**:
1. Abrir en Chrome: `https://lemeit.github.io/DVBA/?zona=VI` (URL con parámetro directo a la zona).
2. Esperar que cargue.
3. Captura de la ventana entera.

**Encuadre sugerido**: Los 8 partidos de Zona VI delineados, las 15 rutas RP calibradas (en color rojo/marrón), los caminos secundarios (100 tramos), la sidebar de la izquierda con los partidos y rutas listados, el panel de basemap a la derecha.

---

### `fig-05-modal-informativo-ruta.png` · Modal informativo estilo DVBA de una ruta provincial

**Sección**: `## 4.3 Portal web de escritorio` — como segunda figura del módulo (después de la vista general).

**Cómo tomarla**:
1. En la vista zonal detallada (fig-04), hacer doble click sobre una ruta calibrada (ejemplo: RP91).
2. Se abre el modal informativo con toda la ficha técnica.
3. Captura solo del modal (o modal + parte del mapa detrás).

**Encuadre sugerido**: El modal completo con Nombre de RP, Zona, Progresiva en punto, Ubicación, Longitud oficial DVBA, Longitud GIS, Diferencia, Características viales (Tipo pavimento, Clase, Ancho de calzada, etc.), botones Agregar al reporte / Cerrar.

---

### `fig-05b-modal-camino-alias.png` · Modal informativo de un camino secundario con edición colaborativa de alias

**Sección**: `## 4.3 Portal web de escritorio` — como tercera figura del módulo (después de fig-05), ilustrando la funcionalidad colaborativa de nombres populares implementada en la red secundaria (sprint v8.72).

**Cómo tomarla**:
1. En la vista zonal detallada, hacer doble click sobre un camino secundario que tenga alias registrados.
2. Se abre el modal con la ficha técnica del camino + chips de alias locales editables.
3. Captura del modal.

**Encuadre sugerido**: Modal completo con nomenclatura oficial, denominación, partido, chips con los alias populares registrados, botón "Editar alias" (para usuarios logueados), y trazabilidad del último cambio.

---

### `fig-06-app-movil-modo-avanzado-wizard.png` · App móvil Modo Avanzado · paso del wizard

**Sección**: `## 4.1 Aplicación móvil de campo · Modo Avanzado` — imagen principal.

**Cómo tomarla**: Necesito capturas **reales del móvil**:
1. Abrir la PWA instalada en el celular.
2. Loguearte con un usuario técnico.
3. Iniciar el wizard: paso "Elegir categoría" (grid con Calzada / Drenaje / Estructura / Señalización / etc.).
4. Captura de pantalla del celular (botón Volumen abajo + Encendido, según modelo).
5. Transferir la imagen al PC (WhatsApp Web, Google Drive, cable USB, etc.).

**Encuadre sugerido**: pantalla completa del celular con el paso del wizard bien visible.

---

### `fig-07-app-movil-modo-basico.png` · App móvil Modo Básico · pantalla principal

**Sección**: `## 4.2 Aplicación móvil de campo · Modo Básico` — imagen principal.

**Cómo tomarla**:
1. Abrir la PWA en el celular.
2. En vez de Modo Avanzado, tocar el toggle a Modo Básico.
3. Captura de la pantalla principal con el botón grande "Sacar foto" y el banner de GPS al pie del encabezado.

**Encuadre sugerido**: interfaz mínima con botón central grande y contador de pendientes en el footer.

---

### `fig-08-sello-institucional.png` · Sello institucional aplicado sobre una foto

**Sección**: `## 3.4 Del sello embebido triplicado al módulo unificado` — como imagen que ilustra el sello final.

**Cómo tomarla**:
1. Bajar del portal una foto ya sellada de alguna zona piloto (Zona VI). Evitar que la imagen tenga información identificatoria (usuarios personales, etc.).
2. Alternativa: aplicar el sello a una foto de prueba con datos ficticios.
3. Guardar la imagen tal cual (no recortar el sello).

**Encuadre sugerido**: la foto sellada completa, con el banner del sello institucional al pie visible (localidad + ruta + km + coordenadas + fecha + QR).

---

### `fig-09-reportes-dashboard.png` · Módulo Informes con los 4 gráficos

**Sección**: `## 4.5 Módulo Informes institucionales` — imagen principal.

**Cómo tomarla**:
1. Loguearte en el portal como un rol con acceso a Informes (jefe de zona, gerencia, o admin).
2. Ir al módulo Informes.
3. Seleccionar un rango de fechas con actividad (ej. últimos 3 meses).
4. Esperar que carguen los 4 gráficos y la tabla.
5. Captura de la ventana entera con los 4 charts visibles.

**Encuadre sugerido**: los 4 gráficos institucionales en grilla + KPIs arriba + filtros en el header. La tabla puede quedar cortada abajo (es suficiente que se vean los headers).

---

### `fig-10-plan-operativo-kanban.png` · Portal Plan Operativo · tablero kanban

**Sección**: `## 4.6 Portal de Plan Operativo del Jefe de Zona` — imagen principal.

**Cómo tomarla**:
1. Loguearte como jefe de zona.
2. Ir al Portal Plan Operativo.
3. Ver el tablero kanban semanal con las columnas (programado / en ejecución / finalizado).
4. Captura de la vista.

**Encuadre sugerido**: kanban con las 3 columnas y ejemplos de tareas visibles.

---

### `fig-11-panel-administrativo.png` · Panel administrativo con las 4 tabs

**Sección**: `## 4.7 Panel administrativo` — imagen principal.

**Cómo tomarla**:
1. Loguearte como admin.
2. Abrir el panel administrativo.
3. Captura con las 4 tabs visibles (Usuarios / Solicitudes / Auditoría / Sistema). Preferentemente en la tab "Sistema" que muestra los cards de estado del sistema.

**Encuadre sugerido**: las 4 tabs pill turquesa arriba + contenido de una tab (Sistema con métricas de BD/Storage/Auth/Roles).

---

### `fig-12-pdf-institucional.png` · Miniatura del PDF exportado

**Sección**: `## 4.5 Módulo Informes institucionales` — como segunda imagen del módulo (después del dashboard).

**Cómo tomarla**:
1. Desde el módulo Informes, exportar un PDF de ejemplo.
2. Abrir el PDF y capturar la primera página (portada institucional) o hacer un montaje con miniaturas de las 2-3 páginas más representativas.

**Encuadre sugerido**: primera página del PDF con portada institucional DVBA + tabla o gráficos visibles.

---

### `fig-13-arquitectura.png` · Diagrama de arquitectura del sistema

**Sección**: `## 4. Qué hace hoy el sistema` (inicio de la Parte 4, antes del 4.1).

**Origen**: Diagrama **que hay que armar aparte**. Sugerencia en Canva o LibreOffice Draw:

- Cuatro rectángulos en la parte de arriba, apuntando cada uno con una flecha a un rectángulo central:
  - Aplicación móvil de campo (con icono de teléfono)
  - Portal de escritorio (con icono de PC)
  - Portal Plan Operativo (con icono de kanban)
  - Panel administrativo (con icono de engranajes)
- Rectángulo central grande: **Base de datos + Storage**. Icono de servidor + carpeta.
- Debajo: **Supabase (PostgreSQL + Auth + Storage + RLS)**.

Todas las flechas van hacia el centro. Puede ser simple, blanco y negro, o con la paleta institucional DVBA (turquesa #009aae + ámbar #c47a00).

---

## Capturas OPCIONALES (agregar si hay tiempo)

- `fig-14-cola-aprobacion.png` — cola de aprobación de relevamientos crudos en el portal escritorio (después del login).
- `fig-15-mapa-tareas-por-antiguedad.png` — mapa con la capa de tareas activada, mostrando pins de color por antigüedad (rojo últimos 7 días, dorado 30, violeta 90).
- `fig-16-detalles-registro.png` — modal de detalle de un registro con foto sellada + datos + trazabilidad.

---

## Insertar las capturas en el informe

Una vez tomadas, en el archivo `CONCURSO_VIAL_2026.md` se insertan con sintaxis Markdown estándar:

```markdown
![Descripción para el pie de la figura](capturas/fig-XX-nombre.png)
*Figura XX. Pie explicativo de la figura.*
```

Ejemplo concreto:

```markdown
![Vista zonal detallada del portal escritorio](capturas/fig-04-portal-vista-zonal-detallada.png)
*Figura 4. Portal web de escritorio en vista zonal detallada de la Zona VI Saladillo, con los 8 partidos delineados, las 15 rutas provinciales calibradas y los 100 caminos secundarios integrados desde geoprocesamiento QGIS.*
```

Yo puedo insertar los placeholders con el markdown correcto una vez que confirmes los nombres de archivo definitivos. Avisame cuando tengas al menos las 3-4 capturas más importantes (fig-03, fig-04, fig-05, fig-06) y las incorporo.
