# PLAN DE STORAGE — Supabase + estrategias de escala

> Documento de estrategia · v7.80 · 14 julio 2026
> Motivado por: apertura de la carga masiva de fotos diarias (módulo Plan de Seguridad en la Circulación + capa Tareas en el mapa).

---

## 1. Situación actual

### Plan Supabase Free (a julio 2026)

| Recurso | Límite | Notas |
|---|---|---|
| **Storage** | 1 GB | Fotos, PDFs, geojsons |
| Egress (bandwidth) | 5 GB/mes | Descargas de fotos a browsers |
| Database | 500 MB | Datos en tablas (partes, relevamientos, vehículos, etc.) |
| Requests API | ilimitado | Consultas SQL |
| Auth users | 50.000 MAUs | Sobra |
| Realtime | 200 conexiones concurrentes | Sobra |
| **Costo pass-through** al pasar límites | El proyecto se pausa hasta upgradear a Pro (US$ 25/mes con 100 GB storage y 250 GB egress) |

### Cómo se usa hoy (Zona VI Saladillo)

**Relevamientos** (fotos con GPS sellado, capturadas por móvil):
- Compresión al capturar: `1600px lado mayor + JPEG q=0.85` → ~200-400 KB por foto.
- El sellado en escritorio re-comprime a `q=0.95` (imagen más pesada) → ~500 KB-1 MB por foto sellada.
- Convención Opción A: guarda `{path}.jpg` (original) + `{path}_sello.jpg` (con sello). **Ambos ocupan espacio.**
- Bucket: `relevamientos`.
- Al día de hoy: N fotos históricas (chequear con el conteo real en Supabase Dashboard).

**Partes diarios (nuevo, v7.62+)**:
- Aún NO sube fotos propias (reutiliza los relevamientos vía `parte_fotos`). No suma storage.

**Otros** (SQL bulk, docs, geojsons): despreciable, < 5 MB.

### Proyección con carga masiva a las 12 zonas (hipótesis)

Escenario base — cada zona carga en promedio **20 relevamientos/día laboral**:
- 12 zonas × 20 fotos/día × 22 días hábiles × 2 (original + sello) = **~10.560 fotos/mes**
- A 700 KB promedio: **7.4 GB/mes**
- **El plan Free (1 GB total) se llena en menos de 4 días** con 12 zonas activas.

Escenario "solo Zona VI" (situación actual):
- 20 fotos/día × 22 = ~440 fotos/mes × 2 = 880 archivos × 700 KB = **~615 MB/mes**
- **Free tier dura ~1.5 meses**. Hoy ya estamos cerca del límite si mantenemos el ritmo.

**Conclusión:** el Free tier es viable para piloto Zona VI a corto plazo con estrategia agresiva de compresión + purga. Para multi-zona hay que planificar migración a Pro o storage externo antes.

---

## 2. Estrategias de corto plazo (implementar sin costo)

### 2.1 Comprimir más agresivo al capturar

Cambiar `comprimir(b64, 1600, 0.85)` en `dvba_campo.html` a `1200, 0.75`. Impacto:
- Tamaño típico foto original: **200-400 KB → 100-200 KB** (~50% menos).
- Calidad visual: aceptable para documentación de tareas, no para peritaje. Sigue siendo legible.
- El sellado escritorio también reducir de `q=0.95` a `q=0.82`.
- **Ganancia estimada:** duplica el tiempo antes de llenar el bucket.

### 2.2 Purgar originales de registros aprobados

Ya existe el botón "🧹 Mantenimiento Storage" en tab Reportes del portal (v7.50) que borra los `.jpg` originales de registros aprobados hace más de N días, manteniendo solo el `_sello.jpg`.

**Plan:** correr esta purga **semanalmente** para todo lo aprobado hace > 30 días. El sello queda como registro histórico, el original desaparece.

- **Ganancia estimada:** ~50% de reducción sobre el histórico (originales purgados).
- Los registros más recientes (últimos 30 días) mantienen ambos por si hay que re-sellar.

### 2.3 Bucket separado para sellos "definitivos"

Crear bucket `relevamientos_archivo` con menor prioridad y mover manualmente los sellos > 6 meses. Facilita:
- Estadísticas de uso (ver cuánto pesa lo reciente vs lo histórico).
- Migración futura solo del bucket archivo a otro proveedor.

**Bloqueado hasta:** discutirlo con Luciano — implica cambiar cómo se resuelve la URL del sello en el frontend.

### 2.4 Monitoreo activo

- **Alerta semanal:** query SQL que consulta `pg_stat_user_tables` y `storage.objects` para reportar el total.
- **Dashboard interno:** agregar al panel de Reportes un contador "GB usados / GB máximos" con barra de progreso.
- **Task en scheduled-tasks:** correr todos los lunes y avisar por email si > 800 MB.

---

## 3. Estrategias de medio plazo (~$0-5/mes)

### 3.1 Storage externo gratuito

| Proveedor | Free tier | Ventaja | Desventaja |
|---|---|---|---|
| **Cloudflare R2** | 10 GB storage + 10 GB egress/mes | Compatible con S3 API, CDN gratis, sin egress cost | Requiere cuenta CF + config DNS |
| **Backblaze B2** | 10 GB + 1 GB egress/día | Precio pass-through más barato después | Egress rate-limit puede molestar |
| **Google Drive** | 15 GB compartidos con Gmail | Familiar para el usuario | No es CDN, permisos manuales, URLs cambiantes |
| **AWS S3** | 5 GB primeros 12 meses, después paga | Estándar de industria | Complejo, hay que gestionar IAM |

**Recomendación:** **Cloudflare R2** cuando se llegue al límite Free de Supabase. Compatible con S3 SDK (misma librería que Supabase Storage usa por debajo). El frontend puede seguir apuntando al Storage Supabase para nuevas fotos, y usar R2 para el archivo histórico.

### 3.2 Migración híbrida

Modelo propuesto:
- **Supabase Storage** = fotos < 3 meses (activas, en workflow, editables).
- **Cloudflare R2** = fotos > 3 meses (archivo, solo lectura).

Script mensual (Python o Edge Function) que:
1. Lista `relevamientos` con `created_at < NOW() - INTERVAL '3 months'` y `foto_url LIKE '%supabase.co%'`.
2. Descarga foto de Supabase.
3. Sube a R2 en el mismo path.
4. Actualiza `foto_url` en Supabase apuntando al R2.
5. Borra la de Supabase.

El frontend NO necesita cambios — la `foto_url` sigue siendo una URL pública que sirve la imagen.

---

## 4. Estrategias de largo plazo (organismo pagando)

Cuando el sistema se institucionalice y sirva a las 12 zonas:

### Opción A · Supabase Pro (US$ 25/mes)
- 100 GB storage + 250 GB egress incluidos.
- Backups diarios automáticos.
- Sin pausas.
- Alcanza para ~10.000 fotos/mes durante ~1 año antes de tocar límites.

### Opción B · Self-hosted Supabase en servidor DVBA
- La DVBA / Ministerio ya tiene infraestructura propia.
- Supabase es open source, se puede correr en un VPS con Postgres + Storage propio.
- Costo hardware: negociable con Sistemas DVBA.
- Ventaja: **datos institucionales no en cloud externo** (buen argumento político/legal).

### Opción C · Google Cloud Storage con dominio institucional
- Si la DVBA ya tiene Workspace pago, GCS entra en el paquete.
- Buckets con permisos por dominio `@vialidad.gba.gob.ar`.
- Mayor costo de gestión pero total control organizacional.

**Bloqueado hasta:** conversación con Luciano + Gerencia sobre viabilidad presupuestaria.

---

## 5. Decisiones para HOY (v7.80)

**Sin costo, aplicables ya:**

1. ✅ Documentar este plan (este archivo).
2. ⏳ Ajustar compresión móvil: `1600→1200` y `q=0.85→0.75`. **Requiere bump v9.57** — próxima vez que toquemos móvil.
3. ⏳ Correr limpieza Storage manual (botón existente en portal) todo lo aprobado > 60 días.
4. ⏳ Agregar contador "MB usados / 1024 MB" en el sidebar del portal (nuevo micro-feature v7.81).
5. ⏳ Crear scheduled-task semanal que reporte GB usados por email.

**Requiere conversación:**

- Fecha límite estimada para migrar a Pro (o R2) → depende del ritmo real de carga.
- ¿La DVBA está dispuesta a pagar US$ 25/mes cuando sea necesario, o mejor R2 gratis?

---

## 6. Cálculos rápidos de referencia

| Escenario | Fotos/mes | GB/mes | Free dura |
|---|---|---|---|
| Zona VI actual, 20/día 22 días | 440 (×2 = 880) | ~0.6 GB | 1.5 meses |
| Zona VI con compresión 1200/0.75 | 440 (×2) | ~0.28 GB | 3.5 meses |
| Zona VI comp + purga a 30 días | 220 (solo sellos) | ~0.14 GB | 7 meses |
| **12 zonas todas, sin comp ni purga** | 5280 (×2) | ~7.4 GB | **4 días** ❌ |
| 12 zonas con comp + purga a 30d | 2640 (solo sellos) | ~1.7 GB | 18 días ❌ |

Con multi-zona → **inevitable pasar a R2 o Pro**.

---

_Última actualización: 2026-07-14 · v7.80 del sistema._
