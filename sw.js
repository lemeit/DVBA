/* ══════════════════════════════════════════════════
   DVBA Campo · Service Worker v3.4
   Network-first + offline fallback + auto-purge de 404

   v3.4: cachea URL principal con y sin .html, fallback offline al HTML.
   v3.3: reconstruido completo tras truncado previo.
   v3.2: CACHE_URLS relativas para /DVBA/ subpath en GitHub Pages.
   ══════════════════════════════════════════════════ */

const CACHE_NAME = 'dvba-campo-v9.28';
const SYNC_TAG   = 'dvba-sync-registros';
const SUPA_URL   = 'https://txjlfpffyzuhdqtfhlmc.supabase.co';
const SUPA_KEY   = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4amxmcGZmeXp1aGRxdGZobG1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI1NDY5ODQsImV4cCI6MjA4ODEyMjk4NH0.LEqkMHh_t4TUb-2rKOlGmZmKTAw9mRrfL63UxK7LGNc';
const BUCKET     = 'relevamientos';

// Rutas RELATIVAS al scope del SW (que en GitHub Pages incluye /DVBA/).
// Incluimos variantes de la URL principal porque el usuario puede acceder
// con o sin .html, y con o sin trailing slash.
const CACHE_URLS = [
  './',
  './dvba_campo',
  './dvba_campo.html',
  './manifest.json',
  './sw.js',
  './dvba_tipos.js',
  './datos/auth.js',
  './datos/qrcode.min.js',
  './datos/dvba_estados.js',
  './datos/armonizador.js',
  './datos/red_vial.js',
  './datos/partidos_zona_vi.geojson',
  './datos/zona_vi/red_secundaria_zonaVI_final.geojson',
  './datos/rutas_rp30.js',
  './datos/rutas_rp40.js',
  './datos/rutas_rp41.js',
  './datos/rutas_rp46.js',
  './datos/rutas_rp47.js',
  './datos/rutas_rp51.js',
  './datos/rutas_rp61.js',
  './datos/rutas_rp91.js'
];

self.addEventListener('install', e => {
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
      // Offline: cache exacto, sino variantes del HTML principal
      return caches.match(e.request).then(cached => {
        if (cached) return cached;
        const path = url.pathname;
        // Si la URL es la app principal sin .html o solo el directorio,
        // devolver el .html cacheado
        if (/\/dvba_campo\/?$/.test(path) ||
            path.endsWith('/DVBA/') || path.endsWith('/DVBA') ||
            path.endsWith('/')) {
          return caches.match('./dvba_campo.html')
            .then(c => c || caches.match('./'))
            .then(c => c || new Response('Sin caché del HTML principal.', {
              status: 503,
              headers: { 'Content-Type': 'text/plain; charset=utf-8' }
            }));
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
