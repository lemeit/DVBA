# Keepalive y migración de claves públicas

Actualización: 19/10/2026.

El workflow supabase_keepalive.yml consulta un identificador del catálogo público partidos_zona tres veces por día (04:17, 12:17 y 20:17 de Argentina). Usa la clave publicable del proyecto y no necesita SUPABASE_KEY ni SUPABASE_URL de GitHub Actions Secrets. No utiliza service_role, no consulta información operativa y no realiza escrituras.

Exige HTTP 200 y una respuesta válida del catálogo. Un error hace fallar la ejecución; las notificaciones dependen de las preferencias de GitHub Actions del propietario. La actividad ayuda a evitar la pausa del plan Free, pero no garantiza disponibilidad ni ejecución puntual del programador.

La aplicación, sus copias históricas publicadas y el generador móvil pasan a la misma clave publicable. La PWA se actualiza a v9.95.22 para renovar su caché. La clave publicable está diseñada para estar en el navegador: los permisos reales siguen dependiendo de Auth y RLS.

## Retirada pendiente de las claves legacy

La clave legacy service_role publicada en el historial fue aceptada por Supabase en una prueba de lectura. Debe retirarse. El botón de Supabase «Disable JWT-based API keys» desactiva conjuntamente las claves legacy anon y service_role; no pulsarlo suponiendo que afecta solo service_role.

Antes de hacerlo:

1. Publicar esta actualización y verificar el keepalive en GitHub Actions.
2. Abrir el portal y actualizar las PWA instaladas a v9.95.22, incluyendo Básico y Avanzado. Comprobar inicio de sesión y operaciones normales con cuentas legítimas. Los teléfonos que sigan offline pueden conservar la clave anterior.
3. Verificar otros consumidores externos: scripts privados, integraciones y secretos de otros repositorios. La búsqueda de este repositorio no demuestra que no existan dependencias fuera de él.
4. Con los consumidores migrados, el propietario debe completar la desactivación de las claves legacy en el panel de Supabase. No cambiar el secreto JWT ni las claves de firma como sustituto improvisado.
5. Repetir la prueba de la clave expuesta: debe ser rechazada. Confirmar que la clave publicable y el keepalive siguen funcionando.

Los secretos antiguos de GitHub Actions quedan sin uso por este workflow. Eliminar sus entradas no invalida la credencial en Supabase; la retirada debe hacerse en Supabase. No se reescribe el historial Git durante esta actualización.

El hardening de permisos y el módulo de Ambiente continúan como propuesta local separada. Esta actualización no despliega esas migraciones ni cambia cuentas o datos.
