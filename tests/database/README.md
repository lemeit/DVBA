# Pruebas de permisos PostgreSQL

Ejecutar desde esta carpeta:

```powershell
npm ci --ignore-scripts
npm test
```

Node 24 y PGlite 0.5.10 (versión fijada en package-lock.json). No se necesita Docker, cuenta Supabase ni credenciales. La instalación requiere acceso al registro npm; las pruebas no usan red ni producción. Cada ejecución crea y descarta una base en memoria.

La fixture genera las 13 tablas del esquema auditado usando schema-auditado.json y restaura las funciones, policies y triggers de diagnostico/2026-10-19/evidencia_supabase.json. Solo contiene metadatos y usuarios ficticios @example.invalid. No importa registros, fotos ni cuentas reales.

Después aplica la migración candidata y ejecuta las consultas con SET LOCAL ROLE authenticated/anon y claims ficticios. El dueño de la base se usa para preparar datos y verificar auditoría; las operaciones de usuario se ejecutan con los roles restringidos.

Limitaciones: Auth y Storage HTTP se representan por sus contratos SQL, no se levantan esos servicios. No se prueba la emisión/expiración real de URLs firmadas, límites MIME/tamaño del servicio, ni PostgREST. No se afirma equivalencia exacta entre PGlite y el PostgreSQL 17 de producción. La fixture reconstruye columnas/PK/FK y checks de columna del inventario; no es un backup completo del esquema ni de extensiones, índices, grants por defecto, vistas o configuración de plataforma. Esas diferencias deben validarse en staging.

La suite falla al primer caso incorrecto. Un resultado positivo verifica los casos ejecutados, no todos los escenarios del CSV de diseño. Los escenarios pendientes están identificados en docs/IMPLEMENTACION_PERMISOS_ETAPA_1.md.
