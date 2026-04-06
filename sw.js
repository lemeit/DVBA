/* ══════════════════════════════════════════════════
   DVBA Campo · Service Worker v3.0
   Offline cache + Background Sync
   Credenciales embebidas del proyecto DVBA Zona VI
   ══════════════════════════════════════════════════ */

const CACHE_NAME = 'dvba-campo-v7';   /* ← bump aquí cada vez que actualices */
const SYNC_TAG   = 'dvba-sync-registros';
const SUPA_URL   = 'https://txjlfpffyzuhdqtfhlmc.supabase.co';
const SUPA_KEY   = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4amxmcGZmeXp1aGRxdGZobG1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI1NDY5ODQsImV4cCI6MjA4ODEyMjk4NH0.LEqkMHh_t4TUb-2rKOlGmZmKTAw9mRrfL63UxK7LGNc';
const BUCKET     = 'relevamientos';

const CACHE_URLS = [
  '/dvba_campo.html',
  '/manifest.json',
  '/sw.js'
];

// ── INSTALL: cachea archivos, NO hace skipWaiting automático ──
// El skipWaiting lo dispara el usuario desde el banner de actualización
self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE_NAME)
      .then(c => c.addAll(CACHE_URLS).catch(() => {}))
    // sin self.skipWaiting() aquí → el SW queda en "waiting"
    // y la app muestra el banner "Nueva versión disponible"
  );
});

// ── ACTIVATE: limpia cachés viejos ──
self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(
        keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))
      ))
      .then(() => self.clients.claim())
  );
});

// ── FETCH: servir desde caché (solo archivos propios, no Supabase) ──
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  if (e.request.url.includes('supabase.co')) return;
  if (e.request.url.includes('fonts.googleapis')) return;
  if (e.request.url.includes('fonts.gstatic')) return;
  if (e.request.url.includes('nominatim.openstreetmap')) return;

  e.respondWith(
    caches.match(e.request).then(cached => {
      const network = fetch(e.request).then(resp => {
        if (resp && resp.status === 200) {
          const clone = resp.clone();
          caches.open(CACHE_NAME).then(c => c.put(e.request, clone));
        }
        return resp;
      }).catch(() => cached);
      return cached || network;
    })
  );
});

// ── MENSAJE desde la app ──
// La app envía 'skipWaiting' para activar la nueva versión
self.addEventListener('message', e => {
  if (e.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  // La app pide la versión de este SW para mostrarla en el banner
  if (e.data && e.data.tipo === 'GET_VERSION') {
    const ver = CACHE_NAME.replace('dvba-campo-v', 'v');
    e.ports[0].postMessage({ version: ver });
    return;
  }
  if (e.data === 'SYNC_NOW') {
    procesarCola().then(() => {
      notificarClientes({ tipo: 'SYNC_COMPLETO' });
    });
  }
});

// ── BACKGROUND SYNC ──
self.addEventListener('sync', e => {
  if (e.tag === SYNC_TAG) e.waitUntil(procesarCola());
});

// ── Procesar cola offline ──
async function procesarCola() {
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
        const resp = await fetch(`${SUPA_URL}/rest/v1/relevamientos`, {
          method:  'POST',
          headers: {
            'apikey':        SUPA_KEY,
            'Authorization': `Bearer ${SUPA_KEY}`,
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

// ── Subir foto ──
async function subirFoto(ruta, base64) {
  try {
    const [header, data] = base64.split(',');
    const mime  = header.match(/:(.*?);/)[1];
    const bytes = atob(data);
    const arr   = new Uint8Array(bytes.length);
    for (let i = 0; i < bytes.length; i++) arr[i] = bytes.charCodeAt(i);
    const blob  = new Blob([arr], { type: mime });
    const ext   = mime.includes('jpeg') ? 'jpg' : (mime.split('/')[1] || 'jpg');
    const path  = `fotos/${Date.now()}_${ruta.replace(/\s/g,'')}.sello.${ext}`;

    const resp = await fetch(`${SUPA_URL}/storage/v1/object/${BUCKET}/${path}`, {
      method:  'POST',
      headers: {
        'apikey':        SUPA_KEY,
        'Authorization': `Bearer ${SUPA_KEY}`,
        'Content-Type':  mime,
        'x-upsert':      'true'
      },
      body: blob
    });
    if (resp.ok) return `${SUPA_URL}/storage/v1/object/public/${BUCKET}/${path}`;
  } catch(e) { console.warn('[SW foto]', e.message); }
  return null;
}

function notificarClientes(msg) {
  self.clients.matchAll().then(cs => cs.forEach(c => c.postMessage(msg)));
}

// ── IndexedDB helpers ──
function abrirDB() {
  return new Promise((res, rej) => {
    const req = indexedDB.open('dvba_campo', 9);
    req.onupgradeneeded = e => {
      const d = e.target.result;
      if (!d.objectStoreNames.contains('cola')) d.createObjectStore('cola', {keyPath:'id',autoIncrement:true});
      if (!d.objectStoreNames.contains('hoy'))  d.createObjectStore('hoy',  {keyPath:'id',autoIncrement:true});
    };
    req.onsuccess = e => res(e.target.result);
    req.onerror   = e => rej(e.target.error);
  });
}
function getAll(db, store) {
  return new Promise((res,rej) => {
    const r = db.transaction(store,'readonly').objectStore(store).getAll();
    r.onsuccess = e => res(e.target.result || []);
    r.onerror   = e => rej(e.target.error);
  });
}
function del(db, store, key) {
  return new Promise((res,rej) => {
    const r = db.transaction(store,'readwrite').objectStore(store).delete(key);
    r.onsuccess = () => res();
    r.onerror   = e => rej(e.target.error);
  });
}
