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

- **Editar**: modificar rol, área y zona, activar/desactivar el perfil. Unidad Ambiental se configura como técnico del área Ambiente, con captura provincial y lectura propia.
- **Reset**: enviar link de recuperación de contraseña al email del usuario.
- **Desactivar**: baja lógica del perfil: corta sus permisos operativos. No equivale a borrar la identidad de Auth ni a revocar todos sus tokens.

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

Cola de acciones que otros roles (Gerencia o cualquiera de los cinco roles de jefatura) le pidieron al admin. Los tipos habituales:

- **Mover zona**: un registro fue cargado en una zona y alguien detectó que en realidad corresponde a otra (por ejemplo, un límite ambiguo entre partidos).
- **Eliminar**: un usuario pidió que un registro se elimine definitivamente, con justificación de al menos 10 caracteres.

Solicitar no elimina ni oculta el registro. Cada solicitud muestra fecha, autor de la solicitud, tipo, registro afectado, destino sugerido y mensaje. Solo admin ejecuta o descarta; se conserva la respuesta, responsable y fecha de resolución. El admin puede **ejecutar** la acción (con confirmación) o **descartar** (con motivo opcional).

---

## Auditoría de registros archivados

Sección de registros archivados, incluyendo el historial anterior de archivos realizados por jefes. Desde el 20/10/2026 solo admin puede archivar; los jefes únicamente solicitan. **No están eliminados físicamente**; el admin los ve acá y decide qué hacer.

Cada fila muestra:

- **Archivado**: fecha y hora del archivado.
- **Tabla**: si es un relevamiento o un parte diario.
- **Zona**: la zona donde estaba el registro.
- **Registro**: id + tipo + ruta + progresiva + partido.
- **Autor original**: nombre + rol + zona de quien había cargado el registro cuando lo creó. Si es "sin autor registrado" es un registro histórico anterior a la trazabilidad de autor.
- **Archivado por**: responsable que lo archivó; los registros antiguos pueden identificar a un jefe.
- **Motivo**: la justificación conservada en el registro (hover para ver completo si es largo).
- **Acciones**:
    - **↺ Restaurar** — abre un modal con un motivo **opcional** (podés aclarar por qué lo restaurás; se le muestra al jefe). Al confirmar, el registro vuelve a ser visible para todos los roles y **el jefe de zona recibe un aviso** al ingresar al portal con toda la información del ciclo (su motivo original + tu motivo de restauración + fecha).
    - **✕ Definitivo** — elimina físicamente el registro para siempre (doble confirmación; irreversible).

La bandeja **Solicitudes** es el circuito actual de pedidos de borrado. La pestaña **Auditoría** conserva los archivos y restauraciones disponibles; no representa una auditoría integral de todas las eliminaciones definitivas antiguas.

!!! note "📷 Screenshots sugeridos"
    - Panel Admin con las 3 secciones visibles (métricas + tabla usuarios + solicitudes + auditoría borrados).
    - Modal de edición de usuario abierto.
    - Fila de auditoría de borrado con tooltip del motivo completo.

## Cuentas de prueba y seguridad

Se conservan las cuentas de prueba. La contraseña inicial compartida fue retirada del SQL, la wiki y su buscador; no se cambiaron las contraseñas de las cuentas. Su rotación/revocación queda pospuesta por decisión del usuario. Borrar el texto no invalida una contraseña ni elimina el historial de Git.
