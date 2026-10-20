# Cierre de permisos de fotos y solicitudes de borrado

Aplicado el 20/10/2026 sobre GIS-Z6 (versión de pruebas con datos reales). No se eliminaron ni desactivaron cuentas, ni se cambiaron contraseñas. No se rediseñaron los modos móviles.

## Reglas efectivas

- Sin sesión no se pueden subir fotos. Las subidas zonales requieren cuenta activa de Vialidad con rol de captura y propietario coincidente; Ambiente conserva su reserva y subida privadas.
- Gerencia y perfiles de consulta no pueden subir, reemplazar ni borrar fotos. Los técnicos/capataces actualizan sus propios objetos; los jefes operativos conservan el sellado de fotos vinculadas a registros de su zona. Admin conserva gestión provincial.
- Solo admin puede eliminar archivos zonales, borrar registros o ejecutar las RPC de archivo. Se bloqueó también el cambio directo de los campos de archivo para roles ordinarios. Las fotos privadas no adquieren permisos generales de borrado.
- Gerencia y los cinco roles de jefatura pueden solicitar el borrado de un relevamiento o parte visible en su alcance, con justificación de al menos 10 caracteres. El servidor comprueba identidad, existencia y zona del destino; no basta con lo que diga el formulario.
- La solicitud no oculta ni elimina datos. Llega al panel del administrador, pestaña **Solicitudes**, donde puede ejecutarla o descartarla. No se envían correos ni mensajes externos. Solo admin resuelve; la ejecución conserva autor, motivo, respuesta, responsable y fecha en la solicitud.
- Los jefes no tienen borrado delegado ni archivo autónomo. Esa fue la regla elegida por el usuario.

## Contraseñas del código público

La contraseña inicial compartida fue retirada del SQL de alta y de tres copias en la wiki/buscador. El SQL histórico ya no tiene una clave predeterminada y falla antes de modificar cuentas si no se configura una clave privada. No se ejecutó ese archivo histórico.

Se agregó revisión automática de claves secretas, JWT privilegiados y contraseñas SQL literales en archivos versionados; los informes omiten los valores. No es una garantía de detección universal ni revisa todo el historial.

**Pendiente:** retirar el literal del código no cambia las claves de las cuentas existentes. El historial público puede conservarlo y no se verificó si las cuentas todavía lo aceptan. Decisión del usuario del 20/10: conservar las cuentas y posponer la rotación/revocación de sus contraseñas; para invalidar una contraseña expuesta hay que rotarla también en Supabase y revisar las sesiones. No se reescribió Git ni se declara resuelto este riesgo de credenciales.

## Verificación

- Migración: `20261020103210_cerrar_storage_publico_y_solicitudes.sql`, aplicada mediante el conector de Supabase. No se aplicó la candidata integral.
- 39 pruebas PostgreSQL locales adicionales: anónimo, sin perfil, inactivo, Gerencia, jefes, técnicos, capataz, admin y Ambiente. Incluyen subida privada, motivo, zona, autoría, ausencia de borrado del solicitante y llegada a la bandeja administrativa.
- Prueba HTTP real sin sesión: subida de imagen mínima rechazada (HTTP 400, error Storage 403 / `AccessDenied`, RLS). No se creó archivo de prueba.
- Verificación remota de policies, triggers, guards y límite de 10 MB/JPEG/PNG/WebP del bucket zonal. Conserva lectura pública de fotos zonales históricas; no cambia a público el bucket privado.
- Conteos después del cambio: 12 perfiles, 326 relevamientos y 634 partes. Ninguna fila operativa se borró durante esta corrección.
- Las pruebas heredadas siguen diferenciadas: 78 de la candidata no desplegada y 19 del piloto; no deben presentarse como validación integral del sistema actual.
- Advisor mantiene los avisos anteriores de funciones privilegiadas y contraseñas filtradas. La prueba HTTP comprueba rechazo anónimo; las subidas autenticadas y las solicitudes del teléfono/portal quedan además sujetas a aceptación con sesiones reales, sin usar contraseñas expuestas para probar.

El resto del endurecimiento de edición por campos, hijos de partes, XSS, secretos históricos y recuperación continúa pendiente. No se considera una certificación de seguridad completa.
