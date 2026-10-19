# Portal v8.86t — restauración de sesión

Fecha: 19/10/2026. El portal de escritorio y la PWA tienen numeraciones independientes: este arreglo cambia el portal de v8.86s a v8.86t.

El usuario confirmó que cerrar sesión y volver a ingresar recuperó los registros de Zona VI. La base conservaba 310 registros en esa zona. Los logs agregados de Auth mostraron session_not_found (403), y las consultas de relevamientos incluyeron rechazos 401. No se atribuye cada solicitud a una cuenta concreta.

El código tenía dos fallas reproducibles: cargarRegs no esperaba a que finalizara la restauración de sesión; y setSession podía devolver un error en su resultado que se ignoraba. El encabezado se construía desde datos locales antes de comprobar esa sesión.

La corrección:

- La consulta espera la restauración y comparte una única operación cuando hay llamadas concurrentes.
- El portal usa dvbaAuth como fuente de sesión. El cliente SDK no restaura por su cuenta otra sesión persistida ni renueva tokens en paralelo.
- Se comprueban error y sesión devueltos por setSession.
- Una sesión inválida pide volver a ingresar, limpia solo credenciales/perfil y conserva fotos y pendientes.
- Los errores de red conservan la sesión para reintentar.
- requireAuth deja de autorizar una operación cuando no se pudo restaurar la sesión.
- Una consulta rechazada no se sustituye por registros locales de otro contexto.
- La carga de partes del mapa también espera autenticación.

Se ejecutaron 7 pruebas locales sobre las funciones reales del portal, con sesiones/consultas simuladas. No se usaron contraseñas reales. La confirmación del usuario valida la recuperación mediante nuevo login en v8.86s; no sustituye una prueba del arreglo publicado ni de navegación prolongada, expiración entre pestañas o todos los módulos.

Esta corrección no modifica RLS, datos ni claves. Tras publicarse, recargar el portal y comprobar que muestra v8.86t. Si estaba bajo un Service Worker anterior, puede requerir recarga forzada o una segunda recarga después de actualizar la caché.
