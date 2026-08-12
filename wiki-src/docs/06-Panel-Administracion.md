> [← Portal web (escritorio)](05-Portal-Escritorio.md) · [Índice](00-Indice.md) · [App móvil · Modo Básico →](07-App-Movil-Modo-Basico.md)

# Panel de Administración de Usuarios

Módulo exclusivo para ADMIN. Se accede desde el botón `🛡 Admin` del header (visible en los 4 portales escritorio solo si tu rol es admin).

### Funcionalidades

- **Métricas globales**: total de usuarios, cuántos son admin/gerencia/técnico, cuántos están sin perfil (falta asignar rol), cuántos inactivos.

- **Tabla de usuarios**: email, rol, zona asignada, nombre, fecha de último acceso, estado activo/inactivo.

- **Filtros**: por rol, por zona, por estado.

- **Editar usuario**: modificar rol y zona, activar/desactivar, resetear contraseña.

- **Invitar usuario**: enviar link de invitación por email institucional.

⚠ Los cambios de rol/zona impactan inmediatamente en las políticas RLS de Supabase. Un técnico movido de zona VI a IV deja de ver registros de VI (aunque los haya cargado él mismo históricamente).

### Registro de nuevos usuarios

Para dar de alta a un técnico o supervisor de una zona nueva:

1. Desde el Panel Admin → botón `+ Invitar`.

2. Ingresar email institucional (formato `@vialidad.gba.gov.ar`).

3. Asignar rol (técnico / gerencia / admin) y zona (I a XII).

4. El usuario recibe un email con link para definir contraseña.

5. Al primer login, la app le muestra su rol y zona en el header (`👷 Técnico · Zona IV`).

!!! note "📷 Screenshot sugerido:"
    panel admin con métricas + tabla de usuarios + modal de edición abierto.
