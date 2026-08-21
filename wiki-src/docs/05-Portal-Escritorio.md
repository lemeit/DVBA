> [← Roles y accesos](04-Roles-y-Accesos.md) · [Índice](00-Indice.md) · [Portal Plan Operativo (Jefe de Zona) →](05b-Portal-Plan-Operativo.md)

# Portal web (escritorio)

El portal es el punto de entrada principal para todos los roles logueados: técnicos, capataces (para consultar), jefes de división, jefes de zona, gerencia y administradores. Se accede desde cualquier navegador moderno en [lemeit.github.io/DVBA/](https://lemeit.github.io/DVBA/).

### Vista general

!!! note "📷 Screenshot sugerido:"
    Vista general del portal con mapa + sidebar + capa 📋 Tareas activa + header consolidado con selector de zona.

### Header consolidado

El header es común a los cinco portales del sistema (Portal principal, Plan Operativo, Plan de Seguridad, Informes, Panel de Administración) y siempre incluye:

- **Logo institucional DVBA** + título **SIG Vial PBAᵝ** con subtítulo del portal actual (por ejemplo *Portal principal*).
- **Selector de zona** en amarillo institucional al lado del título, con formato `ZONA VI · [Saladillo] ▾`. Permite explorar cualquiera de las 12 zonas + una vista panorámica **PBA · Todas las zonas**. Cualquier usuario logueado puede navegar entre zonas; la RLS del backend limita la escritura a la zona propia.
- **Badge 🔔 X pendientes** — visible únicamente para roles con autoridad de revisión (Admin, Gerencia, Jefe de Zona, Jefe de la División Técnica, Jefe de la División Operativa). El número muestra los registros crudos esperando aprobación en la zona activa. Para Gerencia aparece marcado como *solo ver*, ya que gerencia consulta pero no aprueba.
- **Botón único de usuario** `☰ Nombre ▾` que abre el menú principal con: información del usuario (nombre + rol + zona), panel de impersonación (solo Admin y Gerencia), links a los demás portales agrupados por sección (Plan Operativo, Análisis, Ayuda), y opción **🚪 Cerrar sesión**.
- Si no hay sesión activa, en lugar del menú de usuario aparece un solo botón **🔐 Iniciar sesión ▾** con el mismo dropdown que expone las secciones públicas y el modal de login.

### Elementos de la interfaz

Sidebar izquierdo

Pills agrupadas de rutas provinciales y caminos secundarios. Filtros por partido. Selector de capa (RP / Camino / Tareas). Modal SIG Vial estilo DNV. Cuando la zona activa tiene muchos partidos (más de 20), las pills pasan a un desplegable compacto con búsqueda incorporada para no saturar la pantalla.

Mapa central

Mapa interactivo con partidos, rutas provinciales y caminos secundarios de la zona activa. Cursor flotante muestra progresiva al pasar sobre trazas. Click en un punto → pin con detalle. Al elegir otra zona con el selector del header, el mapa se re-centra y se recarga con las trazas y partidos correspondientes.

Panel-footer

Fijo abajo del sidebar. Resumen de la zona activa (partidos / rutas / caminos / registros).

### Capa 📋 Tareas

Al activar esta capa, cada tarea diaria aparece dibujada sobre la traza real de la ruta o camino, con color según la antigüedad:

- **Rojo**: últimos 7 días.

- **Dorado**: últimos 30 días.

- **Violeta**: últimos 90 días.

- **Gris**: histórico anterior.

Los pines abren un popup con los detalles de la tarea (fecha, tipo, ruta, progresiva inicial/final, equipos, fotos vinculadas).

!!! note "📷 Screenshot sugerido:"
    Capa Tareas activa mostrando polylines de colores sobre RP30 con popup abierto.

### Cola de aprobación de registros

El botón **🔔 N pendientes** del header abre la cola de registros crudos que llegaron desde el campo y esperan revisión. Cada registro se muestra con:

- Foto miniatura.
- Ruta + progresiva + partido.
- Tipo del problema.
- Sugerencias automáticas de armonización (si el GPS no coincide del todo con los datos cargados).

Botones disponibles según el rol:

- **✅ Aprobar** (Jefe de Zona / Jefe de División Técnica / Jefe de División Operativa / Admin) — aplica el sello institucional a la foto y marca el registro como oficial.
- **✏ Editar** — corrige datos antes de aprobar.
- **✕ Rechazar** — descarta el registro con motivo.

Gerencia también ve la cola pero solo con opción de consulta.

### Modal SIG Vial (ficha de ruta)

Al hacer clic sobre cualquier RP en el mapa se abre una ficha estilo DNV con los datos oficiales de la ruta: número, denominación, longitud, tipo de pavimento, ancho de calzada y banquinas, partidos que atraviesa. El header del modal toma el color de la ruta seleccionada para identificarla visualmente.
