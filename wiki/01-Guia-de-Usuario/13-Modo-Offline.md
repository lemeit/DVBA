> [[12-Sello-Institucional|← Sello institucional v4]] · [[00-Indice|Índice]] · [[14-FAQ|Preguntas frecuentes →]]

# Modo offline y sincronización

Las 2 apps móviles (lite y completa) están diseñadas para funcionar **sin internet**.

### Qué funciona offline

- Login persistente (una vez que el usuario ingresó al menos una vez con internet).

- Captura de fotos con GPS.

- Cola local con IndexedDB / localStorage.

- Cartografía cacheada: bundles de RPs, geojson de partidos, red secundaria.

- Todas las capas visuales del mapa (excepto los tiles satelitales, que sí requieren internet).

### Qué requiere internet

- Sync de la cola a Supabase.

- Cargar fotos ya subidas (Storage).

- Refresh del token JWT (aunque el sistema lo tolera hasta 30 días).

### Sincronización automática

Cuando la app detecta que volvió la conexión, procesa la cola en background. Aparece un toast informando cuántas fotos se enviaron.

### Gestión de pendientes (lite)

Botón **📤 Sin enviar** del footer abre una lista con las fotos en cola. Podés reintentar el envío o borrar las que fallen (ej. una foto sin GPS que quedó huérfana).

💡 Tip · Cache del Service Worker

Al haber una versión nueva del sistema, aparece un banner verde arriba:

"Hay una versión más nueva"

. Tocá

Actualizar

para bajar los últimos cambios. Sin esto, la app puede quedar con una versión vieja cacheada.

════════════════════════════════════════════════════════════

