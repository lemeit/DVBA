> [← Portal web (escritorio)](05-Portal-Escritorio.md) · [Índice](00-Indice.md) · [Panel de Administración →](06-Panel-Administracion.md)

# Portal Plan Operativo (Jefe de Zona)

El **Plan Operativo** es el portal donde el **Jefe de Zona** (o el Jefe de la División Operativa) gestiona el ciclo completo entre lo que la División Técnica relevó y lo que la cuadrilla ejecuta. Se accede desde el menú principal → *Plan Operativo → Planificación*.

URL: [lemeit.github.io/DVBA/plan_operativo.html](https://lemeit.github.io/DVBA/plan_operativo.html)

---

## Para qué sirve

Cuando la División Técnica sale a campo y deja un relevamiento crudo (foto + GPS + tipo de problema), alguien tiene que decidir qué se ejecuta primero, quién lo hace y cuándo. El Plan Operativo es el tablero donde el jefe organiza ese trabajo:

1. **Bandeja de entrada** — todos los relevamientos pendientes de asignar en la zona.
2. **Generar tarea** — se elige un capataz + fecha estimada + tipo de trabajo, y queda asignada.
3. **Plan semanal (kanban)** — 7 columnas de lunes a domingo con las tareas de la semana.
4. **Cerrar con foto** — cuando el capataz ejecuta y sube foto de campo, el jefe la vincula al relevamiento original y cierra el ciclo.

---

## Estructura del portal

### 🗂 Bandeja de entrada (relevamientos crudos)

Todos los registros crudos de la zona que aún no tienen tarea asignada. Cada fila muestra:

- Foto miniatura con sello
- Tipo del problema (ej. "Bacheo con material en frío")
- Ruta + progresiva + partido
- Fecha de captura
- Botón **Generar tarea →**

### 📅 Plan semanal (kanban)

7 columnas por día de la semana actual. Cada tarjeta representa una tarea asignada (en ejecución o pendiente de cierre), con:

- Capataz asignado
- Tarea a realizar
- Origen (relevamiento vinculado, si hay)
- Estado (color según situación)

Se puede filtrar por capataz para armar el plan de un equipo específico.

### 📋 Modal "Generar tarea"

Al hacer clic en un item de la bandeja se abre el modal:

- **Naturaleza** e **Ítem** (heredados del relevamiento si viene de uno, editables).
- **Capataz** — desplegable con los capataces disponibles de la zona.
- **Fecha estimada** de ejecución.
- **Prioridad** (normal / urgente).
- **Notas** libres.

Al guardar, la tarea aparece en el kanban del jefe y en la agenda del capataz elegido.

### 📸 Modal "Cerrar con foto"

Cuando el capataz ejecutó la tarea y subió foto (desde el móvil), aparece la foto cruda en una lista. El jefe:

1. Elige la foto de cierre.
2. Confirma que corresponde a la tarea asignada.
3. Completa datos faltantes (progresiva exacta, superficie, modalidad).
4. Al guardar, el sistema deja registrada la tarea como finalizada y la vincula con el relevamiento original.

De esa manera queda todo el ciclo trazable: se puede recorrer desde la foto del problema que dejó la División Técnica hasta la foto de la obra terminada por el capataz y aprobada en oficina.

---

## Quién puede acceder

Este portal es visible en el menú principal para:

- **Admin** — todas las zonas.
- **Gerencia** — todas las zonas, solo lectura (no puede asignar).
- **Jefe de Zona** — su zona.
- **Jefe de la División Operativa** — su zona (usuario principal del portal).
- **Jefe de la División Técnica** — su zona, vista consultiva.

El **capataz** no accede al plan operativo del jefe — su vista es la agenda diaria en la app móvil.

---

## Flujo típico (día del Jefe de Zona)

**Lunes 8:00 · Jefe llega a la oficina**

1. Abre el Portal Escritorio, mira el mapa con los pins nuevos del fin de semana.
2. Navega a **Plan Operativo**.
3. En la bandeja de entrada hay 12 relevamientos nuevos que dejó la División Técnica el viernes.
4. Los revisa uno por uno con la foto y las coordenadas.
5. Genera tareas: 4 baches urgentes → capataz A · 3 desmalezados → capataz B · 5 señalización → tema aparte.
6. El kanban semanal se llena. Los capataces ven su agenda al abrir el móvil.

**Martes-viernes**

7. A medida que los capataces ejecutan y suben fotos de cierre, el jefe va cerrando las tareas.

**Viernes 17:00**

8. Chequea los KPIs de la semana: tareas cerradas, tiempo promedio de ejecución, urgentes pendientes.

---

## Diferencia con otros portales

| Portal | Para qué sirve | Rol principal |
|---|---|---|
| **Portal Escritorio** | Explorar el mapa y cargar relevamientos crudos | Técnico, Capataz |
| **Plan Operativo** | Asignar tareas y cerrar el ciclo | **Jefe de Zona, Jefe Operativa** |
| Plan de Seguridad en la Circulación | Cargar partes diarios | Técnico, Jefe Operativa |
| Informes | Análisis mensual | Jefe de Zona en adelante, Gerencia |
| Panel de Administración | Gestionar usuarios y perfiles | Admin |

!!! note "📷 Screenshots sugeridos"
    - Vista general del portal con la bandeja y el kanban.
    - Modal "Generar tarea" abierto.
    - Modal "Cerrar con foto" mostrando la foto cruda y el formulario.
