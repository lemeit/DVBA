> [← App móvil · Modo Avanzado](08-App-Movil-Modo-Avanzado.md) · [Índice](00-Indice.md) · [Reportes de Red Vial Provincial →](10-Reportes-Red-Vial.md)

# Plan de Seguridad en la Circulación

Módulo escritorio (`partes_diarios.html`) para cargar las **tareas diarias ejecutadas**. Está alineado al Google Form oficial de Gerencia Ejecutiva DVBA. Reemplaza el workflow anterior "por email".

📷

Screenshot:

Modal "Nueva tarea" con detección automática de partido y autocomplete de caminos activo.

### Cargar una tarea nueva

1. **Botón "+ Nuevo registro"** — Abre el modal de carga.

2. **Fecha + tipo de tarea** — Dropdown con las tareas del catálogo (mantenimiento, señalización, etc).

3. **Ruta / camino** — Toggle 🛣 Primaria / 🚜 Secundaria. Autocomplete con recorrido encadenado para caminos. Detección automática de partido al completar la progresiva.

4. **Progresivas inicio/fin** — Formato oficial DVBA con coma decimal (ej. `100,01`). Se calcula el kilometraje automáticamente.

5. **Equipos utilizados** — Multi-select con los vehículos disponibles.

6. **Fotos vinculadas (2 opciones)** — **a) Asociar registro existente**: si ya hay relevamientos cargados desde el móvil en la misma ruta ±5 días hábiles, elegís de la lista.

**b) Subir foto directa**: elegís foto del disco → lee GPS del EXIF → si no hay EXIF, tipeás progresiva y se interpola → aplica sello v4 → sube a Storage → crea el relevamiento.

📷

Screenshot:

Modal "Subir foto" con foto cargada + banner verde "Ubicación detectada en la foto".

### Cambio de nombre "parte" → "tarea"

El formulario oficial se llama *"Parte diario"* pero en la jerga interna se dice *"tarea"*. Toda la UI visible dice **tarea/tareas** — sólo los nombres técnicos internos (tabla `partes_diarios`, funciones `pd*`) mantienen "parte" por compatibilidad de código.
