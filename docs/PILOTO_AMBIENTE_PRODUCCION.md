# Piloto Ambiente compatible

Actualización del 20/10/2026: el usuario aclara que GIS-Z6 es un entorno de pruebas con datos reales, todavía sin uso extendido. El estado vigente y las vulnerabilidades pendientes están en [la matriz revisada](MATRIZ_PERMISOS.md). Los conteos y resultados siguientes describen momentos anteriores de la implementación, no el inventario actual.

El usuario autorizó usar GIS-Z6 en producción para la prueba. El proyecto “previa” queda fuera de alcance.

## Cambio específico

Se aplica únicamente `supabase/migrations/20261019194627_piloto_ambiente_compatible.sql`. La candidata integral se movió a `supabase/candidatas/`: NO ejecutarla encima del piloto. Las policies y flujos zonales anteriores se conservan, añadiendo restricciones que aíslan Ambiente. Este piloto no representa la corrección completa de todos los permisos zonales históricos.

La cuenta elegida conserva su identidad de Auth. Su configuración objetivo es técnico, área/contexto Ambiente, consulta propia, captura provincial y sin zona de adscripción. No se deduce del correo durante el uso normal: los clientes consultan el perfil del servidor.

Las fotos nuevas van a `ambiente_privado`, privado y con límite de 10 MB. El autor puede compartir expresamente con jefes de una zona y revocar. Ubicar una captura en una zona no la comparte. Los registros de Ambiente no aparecen en la operativa de las zonas ni en gerencia.

## Verificación y aplicación

- 50 pruebas JavaScript, 78 de la candidata integral y 19 específicas del piloto compatible.
- Las 19 del piloto comprueban también que los técnicos y capataces mantienen los flujos zonales heredados. No certifican que esos flujos históricos ya tengan el endurecimiento integral pendiente.
- Definiciones anteriores y conteos guardados localmente antes de aplicar. Sin copia de credenciales ni exportación de filas operativas.
- El conector falló con estado de solicitud vencido; se aplicó mediante SQL Editor. Un intento con contenido duplicado se revirtió sin cambios. Después se verificó ausencia de toda estructura piloto, se incorporó preflight obligatorio y límites de espera, y la única ejecución corregida finalizó correctamente.
- La prueba transaccional en producción cambió temporalmente el perfil, comprobó aislamiento, captura en IV, autoría, reserva privada idempotente, rechazo de subida al bucket público, compartir/revocar y conteos. Se revirtió por completo. No dejó registros de prueba.
- Conteos confirmados después: 326 relevamientos, 634 partes, 12 perfiles. La cuenta elegida no tenía relevamientos históricos con autoría atribuida a su identidad.

La prueba SQL real usa el rol `authenticated` y claims de la cuenta dentro de una transacción. No equivale a comprobar login, carga/descarga HTTP ni IndexedDB en un teléfono real. Esa aceptación corresponde a la prueba con la sesión de Ambiente desde la pantalla publicada.

Activación realizada: la cuenta seleccionada pasó de admin a técnico Ambiente, activa, consulta propia y captura provincial. La cuenta personal del administrador conserva admin activo. La comprobación posterior mantiene 326 relevamientos y 634 partes, sin registros de prueba persistentes. Se confirmó por HTTP rechazo 401 a creación anónima y rechazo a acceso público a una ruta del bucket privado.

La aplicación fue manual mediante SQL Editor y aún requiere establecer una línea base antes de gestionar esta base con `db push`. No ejecutar automáticamente los SQL históricos ni la candidata integral. La protección de cuenta también comprueba la sesión compartida para impedir que una pestaña con un SDK anterior envíe pendientes después de un cambio de usuario.

## Activación y soporte

Publicar clientes primero y comprobar el despliegue. Cambiar después únicamente el perfil seleccionado, con los seis atributos en una misma transacción y verificando que queda otro administrador activo. No cambiar contraseña ni eliminar la cuenta. La pantalla independiente de Ambiente se retiró: se conservan los modos Básico y Avanzado originales, sin mapa móvil; el mapa sigue en el portal de escritorio. El enlace antiguo de Ambiente vuelve a la app original. El área determina permisos y destino privado de fotos, no otra aplicación.

Después de activar, cerrar/abrir la sesión de Ambiente y confirmar una captura con foto. Si se usan datos de prueba, identificarlos antes de retirarlos; no borrar registros u objetos ajenos por prefijos generales.

## Recuperación sin exponer fotos

Ante fallo de interfaz, mantener el bucket privado y los registros nuevos. Deshabilitar temporalmente la cuenta piloto (`activo=false`) para cortar operaciones y corregir la pantalla. No devolverle admin como salida automática. El preflight impide ejecutar otra vez la migración sobre la estructura ya existente. No quitar las restricciones de privacidad ni borrar columnas/tablas para revertir una pantalla.

Las fotos históricas de los buckets públicos siguen públicas. El inicio de Ambiente requiere conexión; una pantalla ya abierta conserva pendientes al cortarse la red. La prueba de recuperación del almacenamiento local tras cerrar completamente el navegador sigue pendiente.
