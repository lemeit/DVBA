> [← Primeros pasos](02-Primeros-pasos.md) · [Índice](00-Indice.md) · [Roles y accesos →](04-Roles-y-Accesos.md)

# Modo público (sin login)

El portal principal se abre en *modo público* por defecto. Cualquier persona con la URL puede ver el mapa de la red vial provincial sin necesidad de credenciales.

**Portal multi-zona:** el sistema cubre las **12 zonas viales** de la Dirección de Vialidad. Al abrir el portal público se ve toda la Provincia con los 135 partidos agrupados por su zona vial DVBA (paleta institucional de 12 tonos armónicos). Un técnico logueado se redirige automáticamente a su zona. Admin/Gerencia pueden cambiar de zona con el picker del header. Las trazas de las RPs se recortan automáticamente a los límites de los partidos de la zona activa. Sobre cada agrupación aparece el número romano (I..XII) de la zona.

### ¿Qué se ve sin login?

- Mapa completo con **Rutas Provinciales (RPs)** con progresivas y mojones.

- **Caminos Secundarios (Red Vial Secundaria)** con partidos, clases y estado.

- **Límites de partidos** y localidades de referencia.

- Herramientas de exploración: filtrar RP/camino, buscar por progresiva, ver info de partido.

### ¿Qué NO se ve sin login?

- Registros/tareas ejecutadas cargadas en el sistema (info operativa interna).

- Plan de Seguridad en la Circulación.

- Módulo Reportes gerenciales.

- Panel de Administración de Usuarios.

### Aviso institucional y botón Iniciar sesión

Al entrar por primera vez sin sesión aparece un **banner informativo** en la parte inferior explicando el alcance del modo público, con un botón directo `🔐 Iniciar sesión`. El botón `Entendido ✕` lo oculta y no vuelve a aparecer en el mismo dispositivo (queda registrado en `localStorage`).

Para volver a leer el mensaje, tocar el botón `ℹ Alcance` del header (a la derecha del botón de login), disponible únicamente en modo público.

!!! info "🔒 Seguridad"
    La RLS (Row Level Security) de Supabase (`SQL_12`) bloquea al rol `anon` de acceder por API a tareas, partes, fotos o perfiles de usuarios. Aunque alguien tenga la anon-key pública (visible en el HTML), **no puede consultar información institucional interna**.
