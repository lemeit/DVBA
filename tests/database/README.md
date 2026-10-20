# Pruebas de permisos PostgreSQL

Ejecutar desde esta carpeta:

```powershell
npm ci --ignore-scripts
npm test
```

Node 24 y PGlite 0.5.10 (versión fijada en package-lock.json). No se necesita Docker, cuenta Supabase ni credenciales. La instalación requiere acceso al registro npm; las pruebas no usan red ni producción. Cada ejecución crea y descarta una base en memoria.

La fixture genera las 13 tablas del esquema auditado usando schema-auditado.json y restaura las funciones, policies y triggers de diagnostico/2026-10-19/evidencia_supabase.json. Solo contiene metadatos y usuarios ficticios @example.invalid. No importa registros, fotos ni cuentas reales.

Cada suite parte de una base nueva y aplica una capa distinta. Las consultas de usuario usan SET LOCAL ROLE authenticated/anon y claims ficticios. El dueño solo prepara datos y verifica resultados.

## Suites al 20/10/2026

| Suite | Casos | Alcance | Estado del SQL |
|---|---:|---|---|
| `permissions.test.mjs` | 78 | Diseño integral candidato | **No aplicado** en GIS-Z6 |
| `piloto.test.mjs` | 19 | Aislamiento de Ambiente y compatibilidad zonal heredada | Piloto aplicado |
| `perimetro.test.mjs` | 39 | Piloto más cierre de Storage, archivo exclusivo de admin y solicitudes de borrado | Cierre aplicado |

`npm test` ejecuta las tres suites: **136 casos locales**. No deben sumarse para afirmar una auditoría integral del sistema remoto. El piloto conserva intencionalmente permisos heredados, que no deben interpretarse como un endurecimiento completo.

Los 39 casos del cierre comprueban rechazo de subida anónima, sin perfil, inactivo y roles de consulta; captura vial autorizada y privada de Ambiente; actualización por propietario o vínculo zonal; eliminación de archivos y archivo de registros solo por admin; solicitudes con motivo, identidad y zona válidos; conservación del registro y llegada a la bandeja administrativa.

Hay pruebas de interfaz en `tests/solicitud_borrado.test.cjs` y de sesión/caché y preservación de ambos modos móviles. `scripts/revisar_secretos_publicos.py` detecta patrones de credenciales de servidor y contraseñas SQL literales sin imprimir sus valores. No inspecciona todo el historial ni verifica vigencia.

Limitaciones: Auth y Storage HTTP se representan por sus contratos SQL, no se levantan esos servicios. No se prueba la emisión/expiración real de URLs firmadas, límites MIME/tamaño del servicio, ni PostgREST. No se afirma equivalencia exacta entre PGlite y el PostgreSQL 17 de producción. La fixture reconstruye columnas/PK/FK y checks de columna del inventario; no es un backup completo del esquema ni de extensiones, índices, grants por defecto, vistas o configuración de plataforma. Esas diferencias deben validarse en staging.

La suite falla al primer caso incorrecto. Un resultado positivo verifica los casos ejecutados; no certifica XSS, dependencias, cámara/IndexedDB de un teléfono ni todas las acciones del portal. La prueba HTTP remota de rechazo anónimo es independiente y está en [el cierre aplicado](../../docs/CIERRE_SEGURIDAD_2026-10-20.md). La [matriz vigente](../../docs/MATRIZ_PERMISOS.md) separa reglas y pendientes.

No ejecutar `db push` ni SQL históricos automáticamente sobre GIS-Z6: el piloto fue aplicado manualmente y hay que reconciliar la línea base del historial. No aplicar la candidata integral encima del piloto y el cierre actuales.
