# Matriz vigente de accesos y borrado

Actualizada el 20/10/2026. Entorno de pruebas con datos reales. Versiones: portal, partes y administración **8.87a**; modos móviles y Service Worker **9.95.29**. Reportes y planificación conservan **8.86s**.

## Accesos principales

La cartografía pública no concede lectura de los registros de una zona. Los permisos se comprueban en Supabase; ocultar un botón o conocer la clave publicable no otorga autorización.

| Perfil | Lectura de registros | Captura | Borrar o archivar | Solicitar borrado | Gestionar usuarios |
|---|---|---|---|---|---|
| Sin sesión / público | Solo cartografía; sin operativa | No | No | No | No |
| Sin perfil o desactivado | Sin operativa | No | No | No | No |
| Unidad Ambiental | Propios, en toda la provincia | Provincial, privada | No | No sobre operativa zonal | No |
| Técnico vial | Zonal, según perfil | Zonal; alcance provincial configurable¹ | No | No | No |
| Capataz | Zonal heredada¹; flujo previsto de tareas asignadas | Cierre de tareas¹ | No | No | No |
| Jefe de Zona | Su zona | Su zona | No | Sí, en su zona | No |
| Jefe de División Técnica | Su zona | Su zona | No | Sí, en su zona | No |
| Jefe de División Operativa | Su zona | Su zona | No | Sí, en su zona | No |
| Jefe de División Administrativa | Su zona, consulta | No | No | Sí, en su zona | No |
| Jefe de División Automotores | Su zona, consulta | No | No | Sí, en su zona | No |
| Gerencia | Operativa vial provincial; no originales privados de Ambiente | No | No | Sí | No |
| Administrador | Provincial, incluyendo Ambiente | Provincial | Sí | Ejecuta o descarta solicitudes | Sí |

¹ Los alcances configurados no reemplazan por sí solos todas las policies heredadas. La captura provincial opcional del técnico vial, el aislamiento fino del capataz y la edición por campos/estados requieren completar su integración y endurecimiento antes de considerarlos certificados. Esta tabla no certifica todas las operaciones del sistema.

## Unidad Ambiental

No es un administrador. Se configura como `tecnico` con `area_codigo=ambiente`, `contexto_captura=ambiente`, `alcance_lectura=propios`, `alcance_captura=provincial` y sin zona de adscripción. La interfaz muestra **Unidad Ambiental · Todas las Zonas Viales**.

Usa los mismos modos Básico y Avanzado, sin mapa móvil. El mapa se abre en el portal de escritorio. La captura en una zona no comparte automáticamente el registro con esa zona. Los archivos se guardan en `ambiente_privado`; la lectura exige sesión y autorización. Admin puede consultarlos. La compartición explícita autorizada con jefes destinatarios es revocable y no habilita a Gerencia ni a otros técnicos. La integración de todas las acciones del portal para Ambiente sigue pendiente.

## Borrado y notificación

Los cinco roles de jefatura y Gerencia pueden enviar una solicitud con **al menos 10 caracteres de justificación**, sobre un relevamiento o parte de su alcance. La solicitud conserva el registro visible y llega a **Administración → Solicitudes**. No se envían correos externos.

Solo admin puede ejecutar el borrado o el archivo y resolver la solicitud. No hay autorización delegada de borrado a jefes. Se comprueban identidad, zona y destino en el servidor, incluyendo las RPC y los cambios directos de campos de archivo. La solicitud conserva autor, motivo, respuesta, responsable y fecha de resolución. El archivo histórico puede restaurarse; el borrado definitivo es irreversible. No se afirma auditoría integral de todos los borrados directos antiguos.

## Fotos y credenciales

- No se admite subida anónima. La prueba HTTP remota fue rechazada por RLS.
- Gerencia y perfiles de consulta no pueden subir, reemplazar ni borrar fotos. En el bucket zonal, un operativo puede actualizar sus archivos propios; jefes operativos pueden actualizar fotos vinculadas a registros de su zona. Solo admin elimina archivos zonales.
- El bucket zonal conserva lectura pública y ahora limita archivos a 10 MB y JPEG/PNG/WebP. Las fotos nuevas de Ambiente permanecen privadas.
- La contraseña inicial compartida fue retirada del SQL y de tres copias en la wiki/buscador. No se cambió ninguna contraseña ni se desactivaron cuentas de prueba. **El usuario decidió posponer su rotación/revocación**; las versiones históricas de Git pueden conservar el valor publicado.

## Estado técnico y verificación

Aplicadas: `20261019194627_piloto_ambiente_compatible.sql` y `20261020103210_cerrar_storage_publico_y_solicitudes.sql`. La candidata integral de `supabase/candidatas/` no está aplicada y no debe ejecutarse automáticamente. El piloto se aplicó manualmente; hay que reconciliar la línea base del historial antes de usar `db push`.

Pruebas PostgreSQL locales: 78 de la candidata no desplegada, 19 del piloto compatible y 39 del cierre de seguridad. Sus resultados deben distinguirse. Además, se verificó por HTTP el rechazo de una subida anónima, sin crear un archivo. Los tests no son una certificación integral de Auth, Storage HTTP, XSS o dependencias.

Referencias: [cierre de seguridad](CIERRE_SEGURIDAD_2026-10-20.md), [piloto y recuperación](PILOTO_AMBIENTE_PRODUCCION.md), [pruebas](../tests/database/README.md), [evidencia del cierre](../diagnostico/2026-10-20/verificacion_cierre_storage.json).
