> [← Portal Plan Operativo (Jefe de Zona)](05b-Portal-Plan-Operativo.md) · [Índice](00-Indice.md) · [App móvil · Modo Básico →](07-App-Movil-Modo-Basico.md)

# Panel de Administración

Módulo exclusivo para el rol **Admin**. Se accede desde el menú principal (visible en los 5 portales solo si tu rol es admin). Contiene tres secciones principales: gestión de usuarios, cola de solicitudes pendientes y auditoría de registros archivados.

---

## Gestión de usuarios

### Métricas globales

En la parte superior aparecen tarjetas con el conteo por rol y estado: total de usuarios, cuántos son admin, gerencia, técnicos, jefes de las distintas divisiones, capataces, cuántos están sin perfil (falta asignar rol) y cuántos inactivos.

### Tabla de usuarios

Lista todos los usuarios registrados en el sistema con: email, rol, zona asignada, nombre, fecha de último acceso y estado activo/inactivo.

**Filtros disponibles**: por rol, por zona, por estado (activo/inactivo/sin perfil), y búsqueda libre por email o nombre.

**Acciones por usuario**:

- **Editar**: modificar rol y zona, activar/desactivar la cuenta.
- **Reset**: enviar link de recuperación de contraseña al email del usuario.
- **Desactivar**: baja lógica (queda en la base pero no puede iniciar sesión).

⚠ Los cambios de rol/zona impactan inmediatamente en el sistema. Un técnico movido de zona VI a IV deja de ver los registros de VI (aunque los haya cargado él mismo históricamente).

### Registro de nuevos usuarios

Para dar de alta a alguien nuevo:

1. Botón **+ Invitar user** en la parte superior derecha.
2. Ingresar email institucional (formato `@vialidad.gba.gov.ar`) o correo personal si corresponde.
3. Asignar rol (los 10 roles del organigrama disponibles) y zona (I a XII, o ninguna para roles transversales como admin y gerencia).
4. El usuario recibe un email con un link para definir su contraseña.
5. Al primer login, la app le muestra su rol y zona en el header (ej. `👑 Jefe de Zona · Zona VI`).

---

## Solicitudes pendientes

Cola de acciones que otros roles (gerencia o jefes de zona) le pidieron al admin. Los tipos habituales:

- **Mover zona**: un registro fue cargado en una zona y alguien detectó que en realidad corresponde a otra (por ejemplo, un límite ambiguo entre partidos).
- **Eliminar**: un usuario pidió que un registro se elimine definitivamente, con motivo declarado.

Cada solicitud muestra fecha, autor de la solicitud, tipo, registro afectado, destino sugerido y mensaje. El admin puede **ejecutar** la acción (con confirmación) o **descartar** (con motivo opcional).

---

## Auditoría de registros archivados

Sección dedicada a los registros que un jefe de zona archivó (soft-delete) con motivo declarado. **No están eliminados físicamente**; el admin los ve acá y decide qué hacer.

Cada fila muestra:

- **Archivado**: fecha y hora del archivado.
- **Tabla**: si es un relevamiento o un parte diario.
- **Zona**: la zona donde estaba el registro.
- **Registro**: id + tipo + ruta + progresiva + partido.
- **Autor original**: nombre + rol + zona de quien había cargado el registro cuando lo creó. Si es "sin autor registrado" es un registro histórico anterior a la trazabilidad de autor.
- **Archivado por**: nombre del jefe de zona que lo archivó.
- **Motivo**: la justificación que dejó el jefe (hover para ver completo si es largo).
- **Acciones**:
    - **↺ Restaurar** — abre un modal con un motivo **opcional** (podés aclarar por qué lo restaurás; se le muestra al jefe). Al confirmar, el registro vuelve a ser visible para todos los roles y **el jefe de zona recibe un aviso** al ingresar al portal con toda la información del ciclo (su motivo original + tu motivo de restauración + fecha).
    - **✕ Definitivo** — elimina físicamente el registro para siempre (doble confirmación; irreversible).

Este panel es la contrapartida del formulario de archivado que ve el jefe de zona en el mapa. Garantiza que ninguna eliminación es unilateral: siempre hay un rastro, un motivo declarado, una revisión posible por parte del administrador del sistema, y un aviso claro al jefe cuando su decisión de archivado es revertida.

!!! note "📷 Screenshots sugeridos"
    - Panel Admin con las 3 secciones visibles (métricas + tabla usuarios + solicitudes + auditoría borrados).
    - Modal de edición de usuario abierto.
    - Fila de auditoría de borrado con tooltip del motivo completo.
