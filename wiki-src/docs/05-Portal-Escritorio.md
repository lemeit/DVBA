> [← Roles y accesos](04-Roles-y-Accesos.md) · [Índice](00-Indice.md) · [Panel de Administración de Usuarios →](06-Panel-Administracion.md)

# Portal web (escritorio)

El portal es el punto de entrada principal para técnicos, gerencia y administradores. Se accede desde cualquier navegador moderno en [lemeit.github.io/DVBA/](https://lemeit.github.io/DVBA/).

### Vista general

📷

Screenshot sugerido:

vista general del portal con mapa + sidebar + capa 📋 Tareas activa.

### Elementos de la interfaz

Header

Logo institucional · nombre de la zona activa · badge del usuario (con tooltip rol+zona) · links a Plan de Seguridad y Reportes · botón salir.

Sidebar izquierdo

Pills agrupadas de rutas provinciales y caminos secundarios. Filtros por partido. Selector de capa (RP / Camino / Tareas). Modal SIG Vial estilo DNV.

Mapa central

Leaflet con 8 partidos + 15 RPs + 100 caminos secundarios. Cursor flotante muestra progresiva al pasar sobre trazas. Click en un punto → pin con detalle.

Panel-footer

Fijo abajo del sidebar. Resumen de la zona activa (partidos / rutas / caminos / registros) y línea con desarrollador + versión.

### Capa 📋 Tareas

Al activar esta capa, cada tarea diaria aparece dibujada sobre la traza real de la ruta o camino, con color según la antigüedad:

- **Rojo**: últimos 7 días.

- **Dorado**: últimos 30 días.

- **Violeta**: últimos 90 días.

- **Gris**: histórico anterior.

Los pines abren un popup con los detalles de la tarea (fecha, tipo, ruta, prog inicial/final, equipos, fotos vinculadas).

📷

Screenshot sugerido:

capa Tareas activa mostrando polylines de colores sobre RP30 con popup abierto.

### Cola de aprobación de registros

El botón **🔔 N pendientes** del header abre la cola de registros con estado `estado_workflow = 'campo'`. Cada registro tiene botones para aprobar / rechazar / editar / rotar la foto. Al aprobar se aplica el sello institucional v4 con los datos definitivos.
