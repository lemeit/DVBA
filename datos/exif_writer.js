/* ══════════════════════════════════════════════════════════════════
   DVBA · Escritor de metadatos EXIF · v1.0 (v9.80)
   Wrapper sobre piexifjs para inyectar GPS + datos institucionales
   dentro del JPEG (no solo píxeles del sello v4).

   Uso:
     const jpegConExif = DVBA_EXIF.inyectar(jpegBase64, {
       lat:    -35.641234,
       lng:    -59.784567,
       alt:    82,             // metros (opcional)
       fecha:  '2026-07-20',   // YYYY-MM-DD
       hora:   '15:32:15',     // HH:mm:ss
       ruta:   'RP 30',
       prog:   '274+500',
       tipo:   'Bache crítico',
       partido:'Saladillo',
       zona:   'VI',
       origen: 'campo'         // 'campo' | 'oficina'
     });

   Si piexif no está cargado (por network o cache miss), retorna la
   foto SIN modificar (fallback silencioso). El sello visual v4 ya
   está aplicado en píxeles y sigue siendo la fuente principal.

   Requiere: piexif.min.js (local en datos/ o via CDN unpkg).
   ══════════════════════════════════════════════════════════════════ */
(function(global){
'use strict';

function _disponible(){
  return typeof piexif !== 'undefined' && piexif && piexif.dump;
}

function _degToDmsRational(deg){
  const abs = Math.abs(deg);
  const d = Math.floor(abs);
  const minF = (abs - d) * 60;
  const m = Math.floor(minF);
  const s = Math.round((minF - m) * 60 * 100) / 100;
  return [[d, 1], [m, 1], [Math.round(s * 100), 100]];
}

function _fechaExif(fechaISO, hora){
  // "2026-07-20" + "15:32:15" → "2026:07:20 15:32:15"
  if (!fechaISO) return '';
  const f = String(fechaISO).replace(/-/g, ':');
  const h = hora || '00:00:00';
  return f + ' ' + h;
}

function _pref(v){ return v == null ? '' : String(v); }

function inyectar(jpegBase64, datos){
  if (!_disponible()) {
    console.warn('[exif_writer] piexif no disponible — foto sin metadatos EXIF');
    return jpegBase64;
  }
  if (!jpegBase64 || !jpegBase64.startsWith('data:image/jpeg')) {
    console.warn('[exif_writer] input no es JPEG base64');
    return jpegBase64;
  }
  datos = datos || {};
  try {
    const APP_VER = (typeof window !== 'undefined' && typeof window.APP_VER === 'string')
      ? window.APP_VER : 'v?';

    // ── 0th IFD (metadata general) ──────────────────────────────
    const zeroth = {
      [piexif.ImageIFD.Make]:        'DVBA',
      [piexif.ImageIFD.Model]:       'SIG Vial PBA · ' + (datos.origen === 'campo' ? 'Modo Avanzado/Básico' : 'Portal oficina'),
      [piexif.ImageIFD.Software]:    'SIG Vial PBA ' + APP_VER + ' · sello v4',
      [piexif.ImageIFD.Copyright]:   'DVBA - Departamento Zona ' + _pref(datos.zona || 'VI'),
      [piexif.ImageIFD.ImageDescription]: [
        _pref(datos.ruta),
        datos.prog ? ('km ' + _pref(datos.prog)) : '',
        _pref(datos.tipo)
      ].filter(Boolean).join(' · '),
      [piexif.ImageIFD.Artist]:      'Sistema DVBA · SIG Vial PBA'
    };

    // ── Exif IFD (timestamp + user comment) ─────────────────────
    const fechaExifStr = _fechaExif(datos.fecha, datos.hora);
    const exif = {};
    if (fechaExifStr) {
      exif[piexif.ExifIFD.DateTimeOriginal] = fechaExifStr;
      exif[piexif.ExifIFD.DateTimeDigitized] = fechaExifStr;
    }
    // UserComment: JSON con todo el registro (trazabilidad completa)
    const meta = {
      sistema: 'SIG Vial PBA', version: APP_VER,
      ruta: datos.ruta || null, progresiva: datos.prog || null,
      tipo: datos.tipo || null, partido: datos.partido || null,
      zona: datos.zona || null, origen: datos.origen || null,
      lat: datos.lat, lng: datos.lng, alt: datos.alt || null,
      sello_version: 'v4'
    };
    // Prefix ASCII\0\0\0 requerido por EXIF spec para UserComment
    const commentPrefix = String.fromCharCode(65,83,67,73,73,0,0,0);
    exif[piexif.ExifIFD.UserComment] = commentPrefix + JSON.stringify(meta);

    // ── GPS IFD ─────────────────────────────────────────────────
    const gps = {};
    if (typeof datos.lat === 'number' && typeof datos.lng === 'number' &&
        isFinite(datos.lat) && isFinite(datos.lng)) {
      gps[piexif.GPSIFD.GPSVersionID] = [2, 3, 0, 0];
      gps[piexif.GPSIFD.GPSLatitudeRef] = datos.lat < 0 ? 'S' : 'N';
      gps[piexif.GPSIFD.GPSLatitude] = _degToDmsRational(datos.lat);
      gps[piexif.GPSIFD.GPSLongitudeRef] = datos.lng < 0 ? 'W' : 'E';
      gps[piexif.GPSIFD.GPSLongitude] = _degToDmsRational(datos.lng);
      if (typeof datos.alt === 'number' && isFinite(datos.alt)) {
        gps[piexif.GPSIFD.GPSAltitudeRef] = datos.alt < 0 ? 1 : 0;
        gps[piexif.GPSIFD.GPSAltitude] = [Math.round(Math.abs(datos.alt) * 100), 100];
      }
      if (datos.fecha) {
        // GPSDateStamp formato "YYYY:MM:DD"
        gps[piexif.GPSIFD.GPSDateStamp] = String(datos.fecha).replace(/-/g, ':');
      }
      if (datos.hora) {
        const hm = String(datos.hora).split(':');
        gps[piexif.GPSIFD.GPSTimeStamp] = [
          [parseInt(hm[0]||0, 10), 1],
          [parseInt(hm[1]||0, 10), 1],
          [parseInt(hm[2]||0, 10), 1]
        ];
      }
    }

    const exifObj = { '0th': zeroth, 'Exif': exif, 'GPS': gps };
    const exifBytes = piexif.dump(exifObj);
    return piexif.insert(exifBytes, jpegBase64);
  } catch(e) {
    console.warn('[exif_writer] error inyectando EXIF:', e);
    return jpegBase64;  // fallback: retornar sin EXIF
  }
}

// Utilidades adicionales
function leer(jpegBase64){
  if (!_disponible() || !jpegBase64) return null;
  try { return piexif.load(jpegBase64); } catch(e) { return null; }
}

function quitarTodo(jpegBase64){
  if (!_disponible() || !jpegBase64) return jpegBase64;
  try { return piexif.remove(jpegBase64); } catch(e) { return jpegBase64; }
}

function quitarGPS(jpegBase64){
  if (!_disponible() || !jpegBase64) return jpegBase64;
  try {
    const obj = piexif.load(jpegBase64);
    obj['GPS'] = {};
    const bytes = piexif.dump(obj);
    return piexif.insert(bytes, jpegBase64);
  } catch(e) { return jpegBase64; }
}

global.DVBA_EXIF = {
  inyectar: inyectar,
  leer: leer,
  quitarTodo: quitarTodo,
  quitarGPS: quitarGPS,
  disponible: _disponible
};
})(window);
