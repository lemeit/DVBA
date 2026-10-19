# Panel de administración v8.86v

El portal guarda su sesión en `dvba_session` mediante `datos/auth.js`. El panel de administración buscaba únicamente la sesión persistida independiente del SDK; después de corregir el portal podía mostrar «Sesión no iniciada» aunque el usuario hubiera ingresado correctamente.

La corrección usa la sesión compartida, valida el resultado de `setSession` y consulta el perfil de la misma cuenta en la base. Solo abre con `rol=admin` y `activo=true`. Un error de consulta, un perfil ausente o una caché local de admin no conceden acceso. Usa el SDK local ya incluido, evitando depender de jsDelivr para cargarlo.

Verificación: diez pruebas del panel y ocho de restauración del portal, aprobadas localmente. Incluyen errores de sesión/perfil, perfil ajeno, inactivo y técnico. La prueba con la cuenta real del administrador queda por confirmar en el sitio publicado.

Esta corrección no modifica cuentas ni reglas de la base. El nuevo acceso de Ambiente requiere todavía integrar captura, fotos privadas y permisos del servidor; no se cambia el rol de la cuenta antes de esa integración. El aviso de un `content-script.js` con `UNSUPPORTED_OS` no prueba un fallo de permisos de la aplicación.
