#!/usr/bin/env python3
"""v7.90 · Si la foto NO tiene EXIF, usar la progresiva tipeada para interpolar
coords sobre el bundle de la ruta. Devolver el resultado al mismo lugar donde
se muestra el GPS."""
SRC = '/sessions/eager-tender-faraday/mnt/GitHub--DVBA/partes_diarios.html'
DST = '/tmp/pd_v790.html'

with open(SRC, 'r', encoding='utf-8') as f:
    html = f.read()

# ─── 1) Enganchar oninput/onblur al campo subProg + botón "Ubicar en el mapa"
# Reemplazar el HTML del campo progresiva por uno con handler
old = ('        <div class="fld">\n'
       '          <label>Progresiva (opcional)</label>\n'
       '          <input type="text" id="subProg" placeholder="Ej: 12+500">\n'
       '        </div>')
new = ('        <div class="fld">\n'
       '          <label>Progresiva (para ubicar en el mapa si no hay EXIF)</label>\n'
       '          <input type="text" id="subProg" placeholder="Ej: 12+500 · 12,5 · 12.5"\n'
       '                 oninput="pdSubIntentarUbicar()">\n'
       '        </div>')
assert old in html, 'patch 1: prog input'
html = html.replace(old, new, 1)

# ─── 2) Reemplazar el bloque de EXIF por versión que sale con estado "sin GPS"
# manejable, y agregar función pdSubIntentarUbicar
old_marker = 'async function pdSubOnFile(e){'
i = html.index(old_marker)
end_marker = 'async function pdConfirmarSubir(){'
j = html.index(end_marker, i)
old_bloque = html[i:j]

new_bloque = '''async function pdSubOnFile(e){
  const f = e.target.files[0];
  if (!f) return;
  _subEstado.file = f;
  const statusEl = document.getElementById('subStatus');
  statusEl.className = 'status';
  statusEl.textContent = 'Leyendo foto…';
  const b64 = await new Promise(res => {
    const fr = new FileReader();
    fr.onload = () => res(fr.result);
    fr.readAsDataURL(f);
  });
  _subEstado.base64 = b64;
  const prev = document.getElementById('subPrev');
  prev.src = b64;
  prev.style.display = 'block';
  document.getElementById('subDropText').style.display = 'none';
  document.getElementById('subDrop').classList.add('has-file');
  // Leer EXIF GPS
  _subEstado.gps = null;
  _subEstado.gpsOrigen = null;   // 'exif' | 'progresiva' | null
  try {
    if (typeof exifr === 'undefined') throw new Error('librería exifr no cargó');
    const meta = await exifr.parse(f, { gps:true });
    if (meta && typeof meta.latitude === 'number' && typeof meta.longitude === 'number'){
      _subEstado.gps = {
        lat: meta.latitude,
        lng: meta.longitude,
        alt: (typeof meta.GPSAltitude === 'number') ? Math.round(meta.GPSAltitude) : null,
        fecha: meta.DateTimeOriginal || meta.CreateDate || null
      };
      _subEstado.gpsOrigen = 'exif';
    }
  } catch(e){
    console.warn('[EXIF]', e);
  }
  pdSubActualizarGpsBox();
  statusEl.textContent = '';
  document.getElementById('subBtnGuardar').disabled = false;
  // Si ya había progresiva tipeada, intentar interpolar
  pdSubIntentarUbicar();
}

// v7.90 · Si NO hay GPS del EXIF y el user tipea progresiva, interpolar
// sobre el bundle de la ruta para obtener lat/lng aproximado.
function pdSubIntentarUbicar(){
  // Nunca pisar GPS del EXIF (es más preciso)
  if (_subEstado.gpsOrigen === 'exif') { pdSubActualizarGpsBox(); return; }
  const progStr = document.getElementById('subProg').value.trim();
  if (!progStr){
    _subEstado.gps = null;
    _subEstado.gpsOrigen = null;
    pdSubActualizarGpsBox();
    return;
  }
  // Aceptar "12+500", "12,5", "12.5"
  let prog = null;
  const m = progStr.match(/^(-?\\d+)\\s*\\+\\s*(\\d{1,3})$/);
  if (m){
    prog = parseFloat(m[1]) + parseFloat(m[2]) / 1000;
  } else {
    prog = parseFloat(progStr.replace(',', '.'));
  }
  if (!isFinite(prog)){
    _subEstado.gps = null;
    _subEstado.gpsOrigen = null;
    pdSubActualizarGpsBox();
    return;
  }
  // Extraer número de RP del texto de la ruta ("RP 30", "30", "RP30", "Cno. 041-93")
  const rutaTxt = document.getElementById('subRuta').value.trim();
  const rmRP = rutaTxt.match(/^\\s*(?:RP\\s*)?(\\d{1,3})\\s*$/i);
  if (!rmRP){
    // No es una RP conocida (puede ser un camino secundario) — no interpolamos
    _subEstado.gps = null;
    _subEstado.gpsOrigen = null;
    pdSubActualizarGpsBox('El cálculo automático solo funciona para RPs. Para caminos, la foto se sube sin coords.');
    return;
  }
  const rutaNum = rmRP[1];
  if (typeof pdInterpolarProgresiva !== 'function'){
    console.warn('[sub interp] pdInterpolarProgresiva no disponible');
    return;
  }
  const r = pdInterpolarProgresiva(rutaNum, prog);
  if (r && isFinite(r.lat) && isFinite(r.lon)){
    _subEstado.gps = { lat: r.lat, lng: r.lon, alt: null, fecha: null };
    _subEstado.gpsOrigen = 'progresiva';
  } else {
    _subEstado.gps = null;
    _subEstado.gpsOrigen = null;
  }
  pdSubActualizarGpsBox();
}

// Refresca el cartel de estado GPS del modal según _subEstado
function pdSubActualizarGpsBox(mensajeExtra){
  const gpsBox = document.getElementById('subGpsInfo');
  const g = _subEstado.gps;
  const o = _subEstado.gpsOrigen;
  if (g && o === 'exif'){
    gpsBox.className = 'gps-info ok';
    gpsBox.innerHTML = '✓ <b>GPS detectado en la foto (EXIF)</b><br>' +
      'Lat ' + g.lat.toFixed(6) + ' · Lng ' + g.lng.toFixed(6) +
      (g.alt != null ? ' · Alt ' + g.alt + ' m' : '') +
      '<br><span style="font-size:10.5px;opacity:.75">Origen: metadatos de la foto (más preciso)</span>';
  } else if (g && o === 'progresiva'){
    gpsBox.className = 'gps-info ok';
    gpsBox.innerHTML = '📍 <b>Ubicado en el mapa por la progresiva</b><br>' +
      'Lat ' + g.lat.toFixed(6) + ' · Lng ' + g.lng.toFixed(6) +
      '<br><span style="font-size:10.5px;opacity:.75">Origen: interpolación sobre el bundle de la ruta (precisión ±100 m aprox)</span>';
  } else {
    gpsBox.className = 'gps-info warn';
    let msg = '⚠ <b>Sin ubicación por ahora</b><br>';
    if (_subEstado.file){
      msg += 'La foto no trae EXIF con GPS. ';
      msg += 'Tipeá la <b>progresiva</b> arriba (formato 12+500 o 12,5) para ubicarla automáticamente en la ruta del parte.';
    } else {
      msg += 'Elegí una foto primero.';
    }
    if (mensajeExtra) msg += '<br><span style="font-size:10.5px">' + mensajeExtra + '</span>';
    gpsBox.innerHTML = msg;
  }
  gpsBox.style.display = 'block';
}

'''

# Reemplazar el bloque completo
html = html[:i] + new_bloque + html[j:]

# ─── 3) En pdConfirmarSubir: marcar validado_geo según origen
old = "      validado_geo: g ? 'oficina' : 'sin_coords',"
new = "      validado_geo: g ? (_subEstado.gpsOrigen === 'exif' ? 'oficina_exif' : 'oficina_interp') : 'sin_coords',"
assert old in html, 'patch 3: validado_geo'
html = html.replace(old, new, 1)

# ─── 4) Reset gpsOrigen al abrir el modal
old = ('  _subEstado.gps     = null;\n'
       "  document.getElementById('subMomento')")
new = ('  _subEstado.gps     = null;\n'
       '  _subEstado.gpsOrigen = null;\n'
       "  document.getElementById('subMomento')")
assert old in html, 'patch 4: reset origen'
html = html.replace(old, new, 1)

# ─── 5) Bump versión footer
old = '<span id="app-ver-footer">v7.89</span>'
new = '<span id="app-ver-footer">v7.90</span>'
assert old in html, 'patch 5: footer'
html = html.replace(old, new, 1)

# ─── 6) Bump APP_VER interno
old = "const APP_VER = 'v7.89';"
new = "const APP_VER = 'v7.90';"
assert old in html, 'patch 6: APP_VER'
html = html.replace(old, new, 1)

with open(DST, 'w', encoding='utf-8') as f:
    f.write(html)
print(f'OK · {len(html)} chars · {html.count(chr(10))+1} lineas')
