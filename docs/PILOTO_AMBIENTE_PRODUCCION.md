# Piloto Ambiente compatible

El usuario autorizó usar GIS-Z6 en producción para la prueba. El proyecto “previa” queda fuera de alcance.

## Cambio específico

Se aplica únicamente `supabase/migrations/20261019194627_piloto_ambiente_compatible.sql`. La candidata integral se movió a `supabase/candidatas/`: NO ejecutarla encima del piloto. Las policies y flujos zonales anteriores se conservan, añadiendo restricciones que aíslan Ambiente. Este piloto no representa la corrección completa de todos los permisos zonales históricos.

La cuenta elegida conserva su identidad de Auth. Su configuración objetivo es técnico, área/contexto Ambiente, consulta propia, captura provincial y sin zona de adscripción. No se deduce del correo durante el uso normal: los clientes consultan el perfil del servidor.

Las fotos nuevas van a `ambiente_privado`, privado y con límite de 10 MB. El autor puede compartir expresamente con jefes de una zona y revocar. Ubicar una captura en una zona no la comparte. Los registros de Ambiente no aparecen en la operativa de las zonas ni en gerencia.

## Verificación y aplicación

- 49 pruebas JavaScript, 78 de la candidata integral y 19 específicas del piloto compatible.
- Las 19 del piloto comprueban también que los técnicos y capataces mantienen los flujos zonales heredados. No certifican que esos flujos históricos ya tengan el endurecimiento integral pendiente.
- Definiciones anteriores y conteos guardados localmente antes de aplicar. Sin copia de credenciales ni exportación de filas operativas.
- El conector falló con estado de solicitud vencido; se aplicó mediante SQL Editor. Un intento con contenido duplicado se revirtió sin cambios. Después se verificó ausencia de toda estructura piloto, se incorporó preflight obligatorio y límites de espera, y la única ejecución corregida finalizó correctamente.
- La prueba transaccional en producción cambió temporalmente el perfil, comprobó aislamiento, captura en IV, autoría, reserva privada idempotente, rechazo de subida al bucket público, compartir/revocar y conteos. Se revirtió por completo. No dejó registros de prueba.
- Conteos confirmados después: 326 relevamientos, 634 partes, 12 perfiles. La cuenta elegida no tenía relevamientos históricos con autoría atribuida a su identidad.

La prueba SQL real usa el rol `authenticated` y claims de la cuenta dentro de una transacción. No equivale a comprobar login, carga/descarga HTTP ni IndexedDB en un teléfono real. Esa aceptación corresponde a la prueba con la sesión de Ambiente desde la pantalla publicada.

## Activación y soporte

Publicar clientes primero y comprobar el despliegue. Cambiar después únicamente el perfil seleccionado, con los seis atributos en una misma transacción y verificando que queda otro administrador activo. No cambiar contraseña ni eliminar la cuenta. Portal y ambos modos móviles derivan al espacio Ambiente al verificar el perfil.

Después de activar, cerrar/abrir la sesión de Ambiente y confirmar una captura con foto. Si se usan datos de prueba, identificarlos antes de retirarlos; no borrar registros u objetos ajenos por prefijos generales.

## Recuperación sin exponer fotos

Ante fallo de interfaz, mantener el bucket privado y los registros nuevos. Deshabilitar temporalmente la cuenta piloto (`activo=false`) para cortar operaciones y corregir la pantalla. No devolverle admin como salida automática. El preflight impide ejecutar otra vez la migración sobre la estructura ya existente. No quitar las restricciones de privacidad ni borrar columnas/tablas para revertir una pantalla.

Las fotos históricas de los buckets públicos siguen públicas. El inicio de Ambiente requiere conexión; una pantalla ya abierta conserva pendientes al cortarse la red. La prueba de recuperación del almacenamiento local tras cerrar completamente el navegador sigue pendiente.
