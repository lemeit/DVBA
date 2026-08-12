> [← Índice de la guía](00-Indice.md) · [Índice](00-Indice.md) · [Primeros pasos →](02-Primeros-pasos.md)

# ¿Qué es SIG Vial PBA?

**SIG Vial PBA** es una plataforma web integral para el relevamiento, gestión y reporte de la red vial provincial de la Dirección de Vialidad de la Provincia de Buenos Aires (DVBA). Cubre el flujo completo:

1. El personal de campo saca fotos con GPS desde el celular.

2. Las fotos se sellan automáticamente con datos institucionales (ruta, progresiva, fecha, ubicación).

3. El personal de oficina revisa, aprueba y completa datos.

4. Las tareas ejecutadas se cargan al sistema alineadas al Plan de Seguridad en la Circulación.

5. El sistema genera reportes cartográficos y PDF listos para Gerencia.

El sistema se desarrolló como **caso piloto en el Departamento Zona VI Saladillo** con la ambición explícita de escalar a las 12 zonas viales de la Provincia.

### Componentes del sistema

- 🖥 **Portal escritorio** (`index.html`) — Mapa Leaflet con rutas, caminos, mojones, partidos y tareas.
- 📋 **Plan de Seguridad** (`partes_diarios.html`) — Carga de tareas diarias con detección automática de partido.
- 📊 **Reportes** (`reportes.html`) — Charts, filtros, export CSV/PDF y PDF Informe Gerencial oficial DVBA.
- 📱 **Modo Básico** (`dvba_campo_lite.html`) — App móvil minimalista: solo foto + GPS. Funciona offline.
- 📱 **Modo Avanzado** (`dvba_campo.html`) — App móvil completa con wizard de captura + formularios + auto-detección de RP/camino/progresiva.
- 🛣 **Caminos secundarios** (`caminos_secundarios.html`) — Visor especializado de la red no pavimentada.
- 🛡 **Panel Admin** (`admin_usuarios.html`) — Gestión de usuarios (rol + zona) + cola de solicitudes cross-zona pendientes.
