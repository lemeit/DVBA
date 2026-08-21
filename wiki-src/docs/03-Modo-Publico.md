> [← Primeros pasos](02-Primeros-pasos.md) · [Índice](00-Indice.md) · [Roles y accesos →](04-Roles-y-Accesos.md)

# Modo público (sin login)

El portal principal se abre en *modo público* por defecto. Cualquier persona con la URL puede ver el mapa de la red vial provincial sin necesidad de credenciales.

**Portal multi-zona:** el sistema cubre las **12 zonas viales** de la Dirección de Vialidad. Al abrir el portal público se ve toda la Provincia con los 135 partidos agrupados por su zona vial DVBA (paleta institucional de 12 tonos armónicos). Sobre cada agrupación aparece el número romano (I..XII) de la zona. Las trazas de las RPs se recortan a los límites de los partidos de la zona activa.

### Selector de zonas · disponible también sin login

En el header, al lado del título **SIG Vial PBAᵝ**, hay un selector amarillo con formato `ZONA VI · [Saladillo] ▾` que permite explorar cualquiera de las 12 zonas + una vista panorámica **PBA · Todas las zonas**.

- Al elegir una zona, el mapa se re-centra sobre ella y muestra los partidos, rutas y caminos correspondientes.
- Cualquier visitante (con o sin login) puede navegar libremente entre zonas — la información institucional del mapa es pública.
- Los usuarios logueados también usan este selector para consultar zonas distintas a la propia (por ejemplo, un jefe de Zona VI que quiera mirar el mapa de Zona IV para referencia). La escritura de registros sigue limitada a su zona.
- Un usuario técnico o de zona logueado se re-dirige automáticamente a su zona al entrar; después puede cambiar manualmente si lo necesita.

### ¿Qué se ve sin login?

- Mapa completo con **Rutas Provinciales (RPs)** con progresivas y mojones.

- **Caminos Secundarios (Red Vial Secundaria)** con partidos, clases y estado.

- **Límites de partidos** y localidades de referencia.

- Herramientas de exploración: filtrar RP/camino, buscar por progresiva, ver info de partido.

### ¿Qué NO se ve sin login?

- Registros/tareas ejecutadas cargadas en el sistema (info operativa interna).

- Plan de Seguridad en la Circulación.

- Módulo Informes gerenciales.

- Portal Plan Operativo (asignaciones de trabajo a cuadrillas).

- Panel de Administración de Usuarios.

### Banner y botón Iniciar sesión

Al entrar sin sesión aparece un **banner celeste** en la parte superior con el aviso "Vista pública · Mapa y guía disponibles sin sesión. Para acceder al sistema completo, iniciar sesión" y un vínculo directo.

También en el header, el único botón de acción visible es **🔐 Iniciar sesión ▾**, que al hacer clic abre un menú con:

- 🔐 Iniciar sesión (destacado en celeste)
- Portal principal
- Guía

!!! info "🔒 Seguridad"
    Aunque el mapa y la guía son de acceso público, la información operativa interna (relevamientos, tareas, partes diarios, fotos de campo, usuarios, roles) está protegida por reglas de seguridad del backend. **Sin sesión válida no se puede consultar ninguna información institucional interna** por más que se conozca la URL o se inspeccione la página.
