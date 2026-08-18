/* ══════════════════════════════════════════════════
   DVBA Campo · Service Worker v3.4
   Network-first + offline fallback + auto-purge de 404

   v3.23: bump versión (v9.85 · portal v8.4) · 2 fixes críticos · (1) Carga SINCRÓNICA de piexif con <script src> (antes era dinámico → race condition: sello_v4 corría antes que piexif cargara, foto quedaba sin EXIF aunque piexif estuviera después disponible). (2) Auto-fit del texto de versión en el sello (v8.4·portal · sello v4) — antes fillText directo sin achicar si excedía maxW.
   v3.22: bump versión (v9.84) · fixes finales · (1) Sello v4 en foto vertical: cap colSide al 15% + apagar QR si W<500 (usa 2 columnas para dejar más ancho al texto → deja de pisarse con QR). (2) Nombre archivo sin progresiva: SIGVialPBA_ID_RP.jpg. (3) Botón 🔍 EXIF en sidebar de edición muestra diagnóstico completo (piexif cargado, GPS, Make, Model, DateTime, UserComment) — permite ver si los metadatos llegaron a la foto.
   v3.21: bump versión (v9.83) · fixes críticos post v9.82 · (1) Modo Básico GPS: flow simplificado, sin getCurrentPosition sync bloqueante → sacar foto responde inmediato si badge verde. (2) Modo Avanzado: cache defensivo _ultimaRutaCargada + restauración en guardarRegistro para prevenir "camino perdido al enviar". (3) Download foto en portal usa fetch→blob→objectURL (Chrome ignora <a download> cross-origin de Supabase). (4) QR: tamaño mínimo garantizado + logo DVBA al centro (error correction H). (5) Versión unificada v9.83 en ambos móviles + sw.
   v3.20: bump versión (v9.82) · 3 fixes UX · (1) Anti-sobresello v4 con detección real del banner viejo por escaneo de píxeles (línea dorada / fila oscura homogénea) → resuelve foto angosta + texto pisándose con QR al re-sellar sobre foto ya sellada. (2) Nombre de foto al descargar desde portal = 'SIGVialPBA_ID_ruta_Km274+394.jpg' via <a download>. (3) Path storage lite = 'fotos/YYYYMMDD_HHMMSS_ZVI.jpg' (más legible que timestamp ms). Fallback múltiple para piexif (local .min.js → local .js → CDN jsdelivr).
   v3.19: bump versión (v9.81) · FIX RAÍZ · Modo Básico ahora hace getCurrentPosition SYNC al tocar 'Sacar foto' antes de abrir la cámara. Antes dependía del watchPosition (que podía estar suspendido / con lectura vieja / esperando prompt del sistema), y el user tenía que tocar el badge GPS primero para forzar una lectura fresca. Ahora ese paso 'adivinar' se eliminó — el sistema garantiza GPS fresco automáticamente.
   v3.18: bump versión (v9.80) · EXIF metadata en fotos · piexifjs inyecta GPS lat/lng/alt/timestamp + Make/Model DVBA + ImageDescription (ruta+prog+tipo) + UserComment con JSON del registro completo. Aplica en sello_v4 (portal), Modo Avanzado (dvba_campo) y Modo Básico (foto cruda con GPS+fecha). Fotos ahora se ven ubicadas en Google Photos / Windows Fotos / iPhone. Header Modo Avanzado unificado con Modo Básico.
   v3.17: bump versión (v9.79) · rename bootstrap campo.html → app.html (URL canónica pública más corta). campo.html queda como redirect para no romper PWAs ya instaladas. Actualización de links en manifest + docs.
   v3.16: bump versión (v9.78) · UNIFICACIÓN de apps móviles en una sola PWA con Modo Básico / Modo Avanzado + toggle interno + bootstrap campo.html. Fix low-memory con createImageBitmap (decodifica al tamaño target, no la full) + 900px/q=0.70. Rename total: Captura Rápida → Modo Básico, App completa → Modo Avanzado.
   v3.15: bump versión (v9.77) · lite low-memory · compresión con URL.createObjectURL (evita duplicar archivo en base64 en RAM) + 1000px/q=0.72 + liberación explícita de canvas. Fix crashes 'memoria insuficiente' al volver de la cámara nativa en celulares low-RAM.
   v3.14: bump versión (v9.76) · fixes lite/full · GPS auto-prompt (getCurrentPosition en arranque) + botón cámara circular con aspect-ratio + install prompt con fallback manual (aparece aunque Chrome no dispare beforeinstallprompt).
   v3.13: bump versión (v9.75) · fix RP30 progresivas — recalibrado bundle con mojones oficiales corregidos (progIni 262.60, progFin 435.12) + gap real RN205 incorporado.
   v3.12: bump versión (v9.74) · modal de instalación PWA prominente en lite y full.
   v3.11: bump versión (v9.73) · fixes lite: link app completa, quitar nombre autor del modal Info, brand unificado.
   v3.10: bump versión (v9.72) · ajuste naming DVBA → PBA (SIG Vial PBA).
   v3.9: bump versión (v9.71) · renombrado institucional PWA a 'SIG Vial DVBA'.
   v3.8: bump versión (v9.70) + limpiar dvba_perfil al logout.
   v3.7: bump versión (v9.69) + cachear datos/perfil.js (Fase 2 Roles).
   v3.6: bump versión (lite v9.68 · cerrar sesión desde Info).
   v3.5: bump versión (lite v9.67 banner update + gestión pendientes).
   v3.4: cachea URL principal con y sin .html, fallback offline al HTML.
   v3.3: reconstruido completo tras truncado previo.
   v3.2: CACHE_URLS relativas para /DVBA/ subpath en GitHub Pages.
   ══════════════════════════════════════════════════ */

const CACHE_NAME = 'dvba-campo-v9.95.11';  // v9.95.11 · Fix offline: fallback ampliado a app.html + dvba_campo_lite.html + caches.match tolerante a query params
const SYNC_TAG   = 'dvba-sync-registros';
const SUPA_URL   = 'https://txjlfpffyzuhdqtfhlmc.supabase.co';
const SUPA_KEY   = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4amxmcGZmeXp1aGRxdGZobG1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI1NDY5ODQsImV4cCI6MjA4ODEyMjk4NH0.LEqkMHh_t4TUb-2rKOlGmZmKTAw9mRrfL63UxK7LGNc';
const BUCKET     = 'relevamientos';

// Rutas RELATIVAS al scope del SW (que en GitHub Pages incluye /DVBA/).
// Incluimos variantes de la URL principal porque el usuario puede acceder
// con o sin .html, y con o sin trailing slash.
const CACHE_URLS = [
  './',
  './app.html',                // v9.79 · bootstrap unificado (elige modo) — link canónico
  './campo.html',              // v9.78 · redirect a app.html (compat con PWAs instaladas antes del rename)
  './dvba_campo',
  './dvba_campo.html',
  './dvba_campo_lite.html',   // v9.59 · UI móvil minimalista (foto + GPS)
  './manifest.json',
  './sw.js',
  './dvba_tipos.js',
  './datos/auth.js',
  './datos/perfil.js',
  './datos/qrcode.min.js',
  './datos/supabase-js.min.js',   // v9.92a · Supabase JS local (fix modo básico offline)
  './datos/exif_writer.js',       // v9.80 · wrapper de piexif con datos DVBA
  './datos/piexif.min.js',        // v9.80 · librería EXIF (fallback CDN unpkg si no está)
  './datos/dvba_estados.js',
  './datos/armonizador.js',
  './datos/loader_zona.js',       // v8.62 · loader multi-zona
  './datos/zonas/zona_VI/red_vial_zonaVI.js',
  './datos/zonas/zona_VI/partidos_zonaVI.geojson',
  './datos/zonas/zona_VI/red_secundaria_zonaVI_final.geojson',
  './datos/rutas/rutas_rp30.js',
  './datos/rutas/rutas_rp40.js',
  './datos/rutas/rutas_rp41.js',
  './datos/rutas/rutas_rp46.js',
  './datos/rutas/rutas_rp47.js',
  './datos/rutas/rutas_rp51.js',
  './datos/rutas/rutas_rp61.js',
  './datos/rutas/rutas_rp91.js',
  './datos/zonas/zona_VI/caracteristicas_viales_zonaVI.js'
];

self.addEventListener('install', e => {
  // v9.95.2 · skipWaiting() automático: el nuevo SW toma control inmediatamente
  // sin esperar a que todas las tabs se cierren. Combinado con clients.claim()
  // del activate handler, garantiza que un bump de versión sea efectivo
  // en el próximo reload del user, no requiere re-instalación de la PWA.
  self.skipWaiting();
  e.waitUntil(
    caches.open(CACHE_NAME).then(c =>
      Promise.all(CACHE_URLS.map(url =>
        c.add(url).catch(err => console.warn('[SW install]', url, err.message))
      ))
    )
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(
        keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  let url;
  try { url = new URL(e.request.url); } catch { return; }
  if (url.protocol !== 'http:' && url.protocol !== 'https:') return;

  // Dominios externos: no interceptamos
  if (e.request.url.includes('supabase.co')) return;
  if (e.request.url.includes('fonts.googleapis')) return;
  if (e.request.url.includes('fonts.gstatic')) return;
  if (e.request.url.includes('nominatim.openstreetmap')) return;
  if (e.request.url.includes('unpkg.com')) return;
  if (e.request.url.includes('tile.openstreetmap')) return;

  e.respondWith(
    fetch(e.request).then(resp => {
      if (resp && resp.status === 200 && resp.type === 'basic') {
        const clone = resp.clone();
        caches.open(CACHE_NAME)
          .then(c => c.put(e.request, clone))
          .catch(err => console.warn('[SW cache.put]', err.message));
        return resp;
      }
      if (resp && resp.status === 404) {
        caches.open(CACHE_NAME)
          .then(c => c.delete(e.request))
          .catch(() => {});
        return resp;
      }
      return resp;
    }).catch(() => {
      // v9.95.11 · Offline · Match tolerante a query params (?v=X.Y.Z de cache-busters
      // + params PWA que Android puede agregar como ?utm_source=pwa, etc.)
      return caches.match(e.request, { ignoreSearch: true, ignoreVary: true }).then(cached => {
        if (cached) return cached;
        const path = url.pathname;
        // v9.95.11 · Fallback ampliado · cubre TODAS las entradas del PWA
        // (root, /DVBA/, /app.html, /dvba_campo_lite.html, /dvba_campo.html, /campo.html)
        // Antes solo cubría /dvba_campo → si el user abría desde el icono PWA
        // (start_url=app.html) y modo avión, caía al 503 genérico.
        const esEntradaPWA =
          /\/(app|campo|dvba_campo|dvba_campo_lite)(\.html)?\/?$/.test(path) ||
          path.endsWith('/DVBA/') || path.endsWith('/DVBA') ||
          path.endsWith('/');
        if (esEntradaPWA) {
          // Prioridad: app.html (bootstrap) → dvba_campo_lite.html (Modo Básico default)
          //           → dvba_campo.html (Modo Avanzado) → root
          return caches.match('./app.html', { ignoreSearch: true })
            .then(c => c || caches.match('./dvba_campo_lite.html', { ignoreSearch: true }))
            .then(c => c || caches.match('./dvba_campo.html', { ignoreSearch: true }))
            .then(c => c || caches.match('./', { ignoreSearch: true }))
            .then(c => c || new Response(
              'Sin caché del HTML principal. Abrí la app con internet al menos una vez.',
              { status: 503, headers: { 'Content-Type': 'text/plain; charset=utf-8' } }
            ));
        }
        return new Response(
          'Sin conexión y sin caché disponible para este recurso.',
          { status: 503, statusText: 'Offline',
            headers: { 'Content-Type': 'text/plain; charset=utf-8' } }
        );
      });
    })
  );
});

self.addEventListener('message', e => {
  if (e.data === 'skipWaiting') { self.skipWaiting(); return; }
  if (e.data === 'SYNC_NOW') {
    procesarCola().then(() => notificarClientes({ tipo: 'SYNC_COMPLETO' }));
  }
});

self.addEventListener('sync', e => {
  if (e.tag === SYNC_TAG) e.waitUntil(procesarCola());
});

async function procesarCola(){
  let db;
  try {
    db = await abrirDB();
    const pendientes = await getAll(db, 'cola');
    if (!pendientes.length) return;
    let ok = 0;
    for (const item of pendientes) {
      try {
        let foto_url = item.reg.foto_url || null;
        if (!foto_url && item.fotoBase64) {
          foto_url = await subirFoto(item.reg.ruta || 'campo', item.fotoBase64);
        }
        const resp = await fetch(SUPA_URL + '/rest/v1/relevamientos', {
          method:  'POST',
          headers: {
            'apikey':        SUPA_KEY,
            'Authorization': 'Bearer ' + SUPA_KEY,
            'Content-Type':  'application/json',
            'Prefer':        'return=minimal'
          },
          body: JSON.stringify({ ...item.reg, foto_url })
        });
        if (resp.ok) { await del(db, 'cola', item.id); ok++; }
      } catch(e) { console.warn('[SW cola item]', e.message); }
    }
    if (ok > 0) notificarClientes({ tipo: 'SYNC_COMPLETO', count: ok });
  } catch(e) { console.error('[SW cola]', e); }
}

async function subirFoto(ruta, base64){
  try {
    const [header, data] = base64.split(',');
    const mime  = header.match(/:(.*?);/)[1];
    const ext   = mime.includes('jpeg') ? 'jpg' : (mime.split('/')[1] || 'jpg');
    const bytes = atob(data), arr = new Uint8Array(bytes.length);
    for (let i = 0; i < bytes.length; i++) arr[i] = bytes.charCodeAt(i);
    const blob = new Blob([arr], { type: mime });
    const path = 'fotos/' + Date.now() + '_' + ruta.replace(/\s/g, '') + '.sello.' + ext;
    const r = await fetch(SUPA_URL + '/storage/v1/object/' + BUCKET + '/' + path, {
      method: 'POST',
      headers: {
        'apikey':        SUPA_KEY,
        'Authorization': 'Bearer ' + SUPA_KEY,
        'Content-Type':  mime,
        'x-upsert':      'true'
      },
      body: blob
    });
    if (r.ok) return SUPA_URL + '/storage/v1/object/public/' + BUCKET + '/' + path;
  } catch(e) { console.warn('[SW subirFoto]', e.message); }
  return null;
}

function abrirDB(){
  return new Promise((res, rej) => {
    const req = indexedDB.open('dvba_campo', 9);
    req.onerror   = () => rej(req.error);
    req.onsuccess = () => res(req.result);
    req.onupgradeneeded = () => {
      const db = req.result;
      if (!db.objectStoreNames.contains('cola')) db.createObjectStore('cola', { keyPath: 'id' });
      if (!db.objectStoreNames.contains('hoy'))  db.createObjectStore('hoy',  { keyPath: 'id' });
    };
  });
}

function getAll(db, store){
  return new Promise((res, rej) => {
    const req = db.transaction(store, 'readonly').objectStore(store).getAll();
    req.onsuccess = () => res(req.result || []);
    req.onerror   = () => rej(req.error);
  });
}

function del(db, store, key){
  return new Promise((res, rej) => {
    const req = db.transaction(store, 'readwrite').objectStore(store).delete(key);
    req.onsuccess = () => res();
    req.onerror   = () => rej(req.error);
  });
}

function notificarClientes(msg){
  self.clients.matchAll({ includeUncontrolled: true })
    .then(cs => cs.forEach(c => c.postMessage(msg)));
}
