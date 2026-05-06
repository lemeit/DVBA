"""
DVBA Campo — Build Script
Genera dvba_campo.html desde cero.
Ejecutar: python build_campo.py
Requiere: Pillow (pip install pillow)
Archivos necesarios en la misma carpeta que este script:
  - favicon.png
  - icon-192.png
  - icon-512.png
  - logo_dvba.png
  - sw.js  (se copia sin modificar a la carpeta de salida)
Salida: carpeta output/ con dvba_campo.html y manifest.json
"""

import base64, json, os
from PIL import Image
import numpy as np, io

# ── CONFIGURACIÓN ─────────────────────────────────────────────
SUPA_URL = 'https://txjlfpffyzuhdqtfhlmc.supabase.co'
SUPA_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4amxmcGZmeXp1aGRxdGZobG1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI1NDY5ODQsImV4cCI6MjA4ODEyMjk4NH0.LEqkMHh_t4TUb-2rKOlGmZmKTAw9mRrfL63UxK7LGNc'
VERSION  = 'v6.1'
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_DIR    = os.path.join(SCRIPT_DIR, 'output')
os.makedirs(OUT_DIR, exist_ok=True)

def b64(filename):
    path = os.path.join(SCRIPT_DIR, filename)
    with open(path, 'rb') as f:
        return 'data:image/png;base64,' + base64.b64encode(f.read()).decode()

def logo_circular(filename):
    """Recorta el logo en círculo eliminando el fondo blanco del borde."""
    path = os.path.join(SCRIPT_DIR, filename)
    img  = Image.open(path).convert('RGBA')
    arr  = np.array(img)
    W, H = img.size
    cx, cy = W // 2, H // 2
    radio  = min(cx, cy) - 2
    Y, X   = np.ogrid[:H, :W]
    dist   = np.sqrt((X - cx)**2 + (Y - cy)**2)
    # Antialiasing en el borde del círculo
    alpha  = np.clip((radio - dist + 1.5) * 255, 0, 255).astype(np.uint8)
    # Eliminar píxeles blancos en la zona de borde (5px interior)
    borde_px  = 5
    en_borde  = dist > radio - borde_px
    r, g, b_  = arr[:,:,0].astype(int), arr[:,:,1].astype(int), arr[:,:,2].astype(int)
    es_blanco = (r > 200) & (g > 200) & (b_ > 200)
    result    = arr.copy()
    result[:,:,3] = alpha
    result[en_borde & es_blanco, 3] = 0
    out = Image.fromarray(result, 'RGBA')
    buf = io.BytesIO()
    out.save(buf, format='PNG')
    return 'data:image/png;base64,' + base64.b64encode(buf.getvalue()).decode()

print("Cargando assets...")
ICO32   = b64('favicon.png')
ICO192  = b64('icon-192.png')
ICO512  = b64('icon-512.png')
LOGO_HDR  = b64('logo_dvba.png')
LOGO_CIRC = logo_circular('logo_dvba.png')
print(f"  Logo circular: {len(LOGO_CIRC)} chars")

# ── MANIFEST ──────────────────────────────────────────────────
manifest = {
  "name": "DVBA Campo · Zona VI",
  "short_name": "DVBA Campo",
  "description": "Relevamiento vial de campo — Dirección de Vialidad PBA Zona VI",
  "start_url": "/dvba_campo.html",
  "scope": "/",
  "display": "standalone",
  "background_color": "#009aae",
  "theme_color": "#009aae",
  "orientation": "portrait-primary",
  "lang": "es",
  "icons": [
    {"src": ICO32,  "sizes": "32x32",   "type": "image/png", "purpose": "any"},
    {"src": ICO192, "sizes": "192x192", "type": "image/png", "purpose": "any maskable"},
    {"src": ICO512, "sizes": "512x512", "type": "image/png", "purpose": "any maskable"}
  ]
}
manifest_path = os.path.join(OUT_DIR, 'manifest.json')
with open(manifest_path, 'w', encoding='utf-8') as f:
    json.dump(manifest, f, ensure_ascii=False, indent=2)
print("manifest.json OK")

# ── CSS ───────────────────────────────────────────────────────
CSS = """:root{--p:#009aae;--pd:#007d90;--pl:#00b3c7;--vd:#1a8a4a;--ro:#b20900;--am:#c47a00;--txt:#404040;--mut:#808080;--light:#e0e0e0;--bg:#f0f0f0;--w:#fff;--r:10px;--st:env(safe-area-inset-top,0px);--sb:env(safe-area-inset-bottom,0px)}
*{box-sizing:border-box;margin:0;padding:0;-webkit-tap-highlight-color:transparent;touch-action:manipulation}
html,body{height:100%;overflow:hidden;background:var(--bg);font-family:'Encode Sans',sans-serif;font-size:14px;color:var(--txt)}
body{display:flex;flex-direction:column}
.hdr{display:flex;align-items:center;gap:10px;padding:8px 14px;padding-top:calc(8px + var(--st));background:var(--p);color:#fff;flex-shrink:0}
.hdr-logo{width:38px;height:38px;border-radius:50%;object-fit:cover;border:2px solid rgba(255,255,255,.35);flex-shrink:0}
.hdr-t{flex:1;min-width:0}
.hdr-t h1{font-size:13px;font-weight:800;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.hdr-t p{font-size:9px;opacity:.8}
.hdr-r{display:flex;flex-direction:column;align-items:flex-end;gap:4px;flex-shrink:0}
.net{font-size:9px;font-weight:700;padding:3px 9px;border-radius:20px;border:1.5px solid;white-space:nowrap}
.net-on{color:#80ffd8;border-color:#80ffd8}.net-off{color:#ffd080;border-color:#ffd080}
.gps-hdr{display:flex;align-items:center;gap:5px;background:rgba(0,0,0,.22);padding:4px 10px;border-radius:20px;cursor:pointer;border:none}
.led{width:9px;height:9px;border-radius:50%;flex-shrink:0}
.led.s{background:var(--am);animation:blink 1s infinite}.led.ok{background:var(--vd)}.led.err{background:var(--ro)}
.gps-hdr-txt{font-size:9px;color:rgba(255,255,255,.9);white-space:nowrap;font-weight:700}
.gps-bar{display:flex;align-items:center;gap:8px;padding:8px 14px;background:var(--w);border-bottom:2px solid var(--pl);flex-shrink:0}
.gps-info{flex:1}
.gps-coords{font-size:12px;font-weight:700;font-variant-numeric:tabular-nums;color:var(--txt)}
.gps-coords.buscando{color:var(--mut);font-style:italic}
.gps-acc{font-size:10px;color:var(--mut);margin-top:1px}
.btn-usar{padding:8px 18px;background:var(--p);color:#fff;border:none;border-radius:20px;font-size:13px;font-weight:700;cursor:pointer;white-space:nowrap}
.btn-usar:disabled{background:var(--light);color:var(--mut);cursor:default}
.tabs{display:flex;background:var(--w);border-bottom:1px solid var(--light);flex-shrink:0}
.tab{flex:1;padding:8px 4px 6px;text-align:center;font-size:9px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:var(--mut);border-bottom:3px solid transparent;cursor:pointer;display:flex;flex-direction:column;align-items:center;gap:2px}
.tab .ico{font-size:18px}
.tab.active{color:var(--p);border-bottom-color:var(--p)}.tab.done{color:var(--vd);border-bottom-color:var(--vd)}
.panels{flex:1;overflow:hidden;position:relative}
.panel{position:absolute;inset:0;overflow-y:auto;padding:12px 14px;padding-bottom:calc(112px + var(--sb));display:none;flex-direction:column;gap:12px;background:var(--bg)}
.panel.active{display:flex}
.card{background:var(--w);border-radius:var(--r);border:1px solid var(--light);overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,.06)}
.card-head{padding:9px 14px;background:#f4f7fa;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.7px;color:var(--mut);border-bottom:1px solid var(--light)}
.card-body{padding:14px;display:flex;flex-direction:column;gap:12px}
.field{display:flex;flex-direction:column;gap:5px}
.flbl{font-size:11px;font-weight:700;color:var(--mut);text-transform:uppercase;letter-spacing:.4px}
select,input[type=text],textarea{width:100%;background:#f4f7fa;border:1.5px solid var(--light);border-radius:8px;color:var(--txt);font-size:15px;padding:12px 13px;appearance:none;-webkit-appearance:none;font-family:'Encode Sans',sans-serif}
select{background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8'%3E%3Cpath d='M0 0l6 8 6-8z' fill='%23808080'/%3E%3C/svg%3E");background-repeat:no-repeat;background-position:right 13px center;padding-right:34px;background-color:#f4f7fa}
select:focus,input:focus,textarea:focus{outline:none;border-color:var(--p);background:var(--w)}
textarea{resize:none;min-height:80px}
.row2{display:grid;grid-template-columns:1fr 1fr;gap:10px}
.gps-box{background:#e8f7f9;border:1.5px solid var(--pl);border-radius:8px;padding:11px 13px;display:flex;align-items:center;gap:8px}
.gps-box-ico{font-size:20px;flex-shrink:0}
.gps-v{flex:1}
.gps-v .coords{font-size:14px;font-weight:800;color:var(--p)}
.gps-v .acc{font-size:10px;color:var(--mut);margin-top:2px}
.gps-v .empty{font-size:12px;color:var(--mut)}
.geo-r{background:#e8f7ee;border:1.5px solid #80c8a0;border-radius:8px;padding:8px 12px;font-size:12px;color:var(--vd);font-weight:600;display:none}
.foto-prev{width:100%;max-height:200px;object-fit:cover;border-radius:8px;border:1.5px solid var(--light);display:none}
.foto-ok{background:#e8f7ee;border:1.5px solid #80c8a0;border-radius:8px;padding:10px 13px;font-size:13px;font-weight:700;color:var(--vd);display:none}
.foto-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}
.btn-foto-op{height:72px;background:#f4f7fa;border:1.5px dashed var(--light);border-radius:8px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:6px;cursor:pointer;font-family:'Encode Sans',sans-serif}
.btn-foto-op .ei{font-size:24px;pointer-events:none}
.btn-foto-op span{font-size:11px;font-weight:700;color:var(--txt);pointer-events:none}
.btn-foto-op small{font-size:9px;color:var(--mut);pointer-events:none}
.btn-foto-op.done{background:#e8f7ee;border-color:#80c8a0;border-style:solid}
#inp-galeria{display:none}
.res-row{display:flex;padding:10px 0;border-bottom:1px solid var(--light);gap:10px;align-items:flex-start}
.res-row:last-child{border-bottom:none}
.res-k{font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.4px;color:var(--mut);width:85px;flex-shrink:0;padding-top:2px}
.res-v{font-size:14px;font-weight:600;flex:1;word-break:break-word}
.pend{display:none;align-items:center;gap:10px;background:#fff8e0;border:1.5px solid var(--am);border-radius:var(--r);padding:10px 14px}
.pend.on{display:flex}
.pend-i{flex:1;cursor:pointer}
.pend-i strong{font-size:13px;color:#704000;display:block}
.pend-i small{font-size:10px;color:#906020}
.btn-sync{padding:8px 16px;background:var(--am);color:#fff;border:none;border-radius:20px;font-size:12px;font-weight:800;cursor:pointer;white-space:nowrap}
.pwa-bar{display:none;align-items:center;gap:10px;background:#e8f7f9;border:1.5px solid var(--pl);border-radius:var(--r);padding:10px 13px}
.pwa-bar.show{display:flex}
.pwa-bar .pi{font-size:18px}.pwa-bar .pt{flex:1}
.pwa-bar .pt b{font-size:11px;color:var(--p);display:block}
.pwa-bar .pt small{font-size:9px;color:var(--mut)}
.bot-nav{position:fixed;bottom:0;left:0;right:0;z-index:20;display:flex;gap:10px;padding:8px 14px;padding-bottom:calc(26px + var(--sb));background:var(--bg);border-top:1px solid var(--light)}
.btn-n{flex:1;padding:14px;font-size:14px;font-weight:800;border:none;border-radius:var(--r);cursor:pointer;font-family:'Encode Sans',sans-serif}
.btn-n:active{opacity:.85}
.btn-prev{background:var(--w);color:var(--p);border:1.5px solid var(--p)}
.btn-next{background:var(--p);color:#fff}
.btn-save{background:var(--vd);color:#fff;box-shadow:0 4px 14px rgba(26,138,74,.25)}
.btn-save:disabled{background:var(--mut);box-shadow:none;cursor:default}
.toast{position:fixed;top:calc(10px + var(--st));left:50%;transform:translateX(-50%) translateY(-80px);background:var(--w);border-radius:var(--r);padding:11px 18px;font-size:13px;font-weight:700;z-index:100;white-space:nowrap;box-shadow:0 4px 20px rgba(0,0,0,.15);transition:transform .3s cubic-bezier(.34,1.56,.64,1);display:flex;align-items:center;gap:8px}
.toast.show{transform:translateX(-50%) translateY(0)}
.toast.ok{border-left:4px solid var(--vd);color:var(--vd)}.toast.err{border-left:4px solid var(--ro);color:var(--ro)}.toast.warn{border-left:4px solid var(--am);color:#704000}
.mov{position:fixed;inset:0;background:rgba(0,0,0,.4);z-index:50;display:flex;align-items:flex-end;opacity:0;pointer-events:none;transition:opacity .25s}
.mov.on{opacity:1;pointer-events:all}
.modal{width:100%;background:var(--w);border-radius:16px 16px 0 0;padding:0 0 var(--sb);transform:translateY(100%);transition:transform .3s cubic-bezier(.4,0,.2,1);max-height:75vh;display:flex;flex-direction:column}
.mov.on .modal{transform:translateY(0)}
.mhandle{width:40px;height:4px;background:var(--light);border-radius:2px;margin:12px auto 0}
.mhead{padding:12px 16px;font-size:14px;font-weight:800;border-bottom:1px solid var(--light);display:flex;justify-content:space-between;align-items:center}
.mbody{flex:1;overflow-y:auto}.mfoot{padding:12px 16px;border-top:1px solid var(--light);display:flex;gap:8px}
.pitem{padding:11px 16px;border-bottom:1px solid var(--light);display:flex;align-items:flex-start;gap:10px}
.pdot{width:8px;height:8px;border-radius:50%;background:var(--am);flex-shrink:0;margin-top:5px}
.pinfo{flex:1}.ptit{font-size:13px;font-weight:700}.psub{font-size:10px;color:var(--mut);margin-top:2px;line-height:1.4}
.btn-m{flex:1;padding:13px;border-radius:var(--r);font-size:13px;font-weight:800;border:none;cursor:pointer;font-family:'Encode Sans',sans-serif}
.btn-ms{background:var(--vd);color:#fff}.btn-mc{background:var(--bg);color:var(--mut);border:1.5px solid var(--light)!important}
#camara-modal{display:none;position:fixed;inset:0;z-index:500;background:#000;flex-direction:column}
#camara-modal.show{display:flex}
#video-stream{width:100%;flex:1;object-fit:cover;background:#000}
.cam-ctrl{background:#000;padding:16px 20px 28px;display:flex;align-items:center;justify-content:space-between;gap:12px;flex-shrink:0}
#btn-capturar{width:70px;height:70px;border-radius:50%;background:#fff;border:4px solid #009aae;cursor:pointer;flex-shrink:0;transition:transform .1s}
#btn-capturar:active{transform:scale(.88)}
.btn-cam-sec{padding:10px 16px;background:transparent;border:1.5px solid rgba(255,255,255,.3);border-radius:6px;color:rgba(255,255,255,.9);font-family:'Encode Sans',sans-serif;font-size:14px;font-weight:700;cursor:pointer}
#canvas-oculto{display:none}
#ov{display:none;position:fixed;inset:0;z-index:200;background:rgba(255,255,255,.88);align-items:center;justify-content:center;flex-direction:column;gap:14px}
#ov.show{display:flex}
.spinner{width:38px;height:38px;border:3px solid #e0e0e0;border-top-color:#009aae;border-radius:50%;animation:spin .7s linear infinite}
@keyframes spin{to{transform:rotate(360deg)}}
#ov-txt{font-size:13px;color:#808080;font-weight:700;text-align:center;max-width:80vw}
@keyframes blink{0%,100%{opacity:1}50%{opacity:.25}}"""

# ── HTML ──────────────────────────────────────────────────────
HTML_HEAD = """<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="DVBA Campo">
<meta name="theme-color" content="#009aae">
<title>DVBA Campo · Zona VI</title>
<link rel="manifest" href="manifest.json">
<link rel="icon" type="image/png" href="__FAV__">
<link rel="apple-touch-icon" href="__ICO192__">
<link href="https://fonts.googleapis.com/css2?family=Encode+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>__CSS__</style>
</head>
<body>"""
HTML_HEAD = HTML_HEAD.replace('__FAV__',   ICO32)
HTML_HEAD = HTML_HEAD.replace('__ICO192__', ICO192)
HTML_HEAD = HTML_HEAD.replace('__CSS__', CSS)

HTML_BODY = """
<div class="toast" id="toast"></div>
<div class="hdr">
  <img class="hdr-logo" src="__LOGO_HDR__" alt="DVBA">
  <div class="hdr-t">
    <h1>Relevamiento de Campo · Zona VI</h1>
    <p>Dirección de Vialidad de la Prov. de Buenos Aires</p>
  </div>
  <div class="hdr-r">
    <div class="net net-on" id="net-badge">● ONLINE</div>
    <button class="gps-hdr" id="btn-gps-hdr" onclick="toggleGPS()">
      <div class="led s" id="gps-led"></div>
      <span class="gps-hdr-txt" id="gps-hdr-txt">GPS buscando…</span>
    </button>
  </div>
</div>
<div class="gps-bar">
  <div class="gps-info">
    <div class="gps-coords buscando" id="gps-coords-bar">Buscando señal GPS…</div>
    <div class="gps-acc" id="gps-acc-bar"></div>
  </div>
  <button class="btn-usar" id="btn-usar" disabled onclick="usarCoordenadas()">↓ Usar</button>
</div>
<div class="tabs">
  <div class="tab active" id="tab-0" onclick="irPaso(0)"><span class="ico">📍</span>Ubicación</div>
  <div class="tab"        id="tab-1" onclick="irPaso(1)"><span class="ico">🔍</span>Tipo</div>
  <div class="tab"        id="tab-2" onclick="irPaso(2)"><span class="ico">📷</span>Foto</div>
  <div class="tab"        id="tab-3" onclick="irPaso(3)"><span class="ico">✅</span>Confirmar</div>
</div>
<div class="panels">
<div class="panel active" id="panel-0">
  <div class="pend" id="pend-bar">
    <div style="font-size:20px;cursor:pointer" onclick="abrirModal()">📋</div>
    <div class="pend-i" onclick="abrirModal()">
      <strong id="pend-count">0 pendientes</strong>
      <small id="pend-sub">Tocá para ver · Sync para subir</small>
    </div>
    <button class="btn-sync" id="btn-sync-bar" onclick="syncManual()">↑ Sync</button>
  </div>
  <div class="pwa-bar" id="pwa-bar">
    <div class="pi">📲</div>
    <div class="pt"><b>Instalar para uso sin internet</b><small id="pwa-status">Tocá para instalar</small></div>
    <button onclick="instalarPWA()" style="padding:6px 12px;background:var(--p);color:#fff;border:none;border-radius:20px;font-size:11px;font-weight:800;cursor:pointer">Instalar</button>
    <button onclick="ocultarPWABar()" style="background:none;border:none;font-size:18px;cursor:pointer;color:var(--p);padding:0 4px">✕</button>
  </div>
  <div class="card">
    <div class="card-head">📍 Ubicación en ruta</div>
    <div class="card-body">
      <div class="geo-r" id="geo-r"></div>
      <div class="row2">
        <div class="field"><div class="flbl">Ruta Provincial</div>
          <select id="f-ruta">
            <option value="">— Ruta —</option>
            <option>RP 6</option><option>RP 20</option><option>RP 24</option>
            <option>RP 30</option><option>RP 40</option><option>RP 41</option>
            <option>RP 42</option><option>RP 43</option><option>RP 44</option>
            <option>RP 46</option><option>RP 47</option><option>RP 48</option>
            <option>RP 51</option><option>RP 61</option><option>RP 91</option>
          </select>
        </div>
        <div class="field"><div class="flbl">Partido</div>
          <select id="f-partido">
            <option value="">— Partido —</option>
            <option>General Alvear</option><option>General Las Heras</option>
            <option>Las Flores</option><option>Lobos</option><option>Navarro</option>
            <option>Roque Pérez</option><option>Saladillo</option><option>Veinticinco de Mayo</option>
          </select>
        </div>
      </div>
      <div class="field"><div class="flbl">Progresiva</div>
        <input type="text" id="f-prog" placeholder="ej: 45+500" autocomplete="off" autocorrect="off" spellcheck="false" inputmode="text">
      </div>
      <div class="field"><div class="flbl">Coordenadas GPS</div>
        <div class="gps-box" id="coord-box">
          <div class="gps-box-ico">📡</div>
          <div class="gps-v" id="coord-display"><div class="empty">Presioná ↓ Usar cuando el GPS tenga señal</div></div>
        </div>
        <input type="hidden" id="f-lat"><input type="hidden" id="f-lng">
      </div>
    </div>
  </div>
</div>
<div class="panel" id="panel-1">
  <div class="card">
    <div class="card-head">🔍 Tipo de registro</div>
    <div class="card-body">
      <div class="field"><div class="flbl">Tipo</div>
        <select id="f-tipo">
          <option value="">— Seleccioná el tipo —</option>
          <optgroup label="── Calzada ──">
            <option>Bache</option><option>Bache crítico</option><option>Calzada dañada</option>
            <option>Pavimento fisurado</option><option>Pavimento ondulado</option>
            <option>Calzada de tierra deteriorada</option>
          </optgroup>
          <optgroup label="── Banquinas y drenaje ──">
            <option>Banquina deteriorada</option><option>Cuneta obstruida</option>
            <option>Alcantarilla tapada</option><option>Alcantarilla dañada</option><option>Erosión</option>
          </optgroup>
          <optgroup label="── Señalización ──">
            <option>Señal faltante</option><option>Señal dañada</option><option>Demarcación borrada</option>
          </optgroup>
          <optgroup label="── Estructura ──">
            <option>Puente / viaducto</option><option>Alcantarilla / drenaje</option><option>Banquina</option>
          </optgroup>
          <optgroup label="── Entorno ──">
            <option>Vegetación / desmalezado</option><option>Inundación / anegamiento</option>
          </optgroup>
          <optgroup label="── Seguridad vial ──">
            <option>Siniestro vial</option><option>Punto negro</option>
            <option>Obra en ejecución</option><option>Obra terminada</option><option>Emergencia vial</option>
          </optgroup>
          <optgroup label="── Otro ──"><option>Otro</option></optgroup>
        </select>
      </div>
      <div class="field"><div class="flbl">Estado</div>
        <select id="f-estado">
          <option value="">— Estado —</option>
          <option>Crítico</option><option>Grave</option><option>Regular</option>
          <option>Leve</option><option>Resuelto</option>
        </select>
      </div>
      <div class="field"><div class="flbl">Observaciones</div>
        <textarea id="f-obs" placeholder="Descripción del suceso o condición vial…"></textarea>
      </div>
    </div>
  </div>
</div>
<div class="panel" id="panel-2">
  <div class="card">
    <div class="card-head">📷 Fotografía</div>
    <div class="card-body">
      <img class="foto-prev" id="foto-prev" alt="">
      <div class="foto-ok" id="foto-ok"></div>
      <div class="foto-grid">
        <button class="btn-foto-op" id="btn-cam" onclick="abrirCamara()">
          <div class="ei">📷</div><span>Cámara</span><small>Tomar foto nueva</small>
        </button>
        <button class="btn-foto-op" id="btn-gal" onclick="document.getElementById('inp-galeria').click()">
          <div class="ei">🖼</div><span>Galería</span><small>Elegir foto existente</small>
        </button>
      </div>
      <input type="file" id="inp-galeria" accept="image/*" onchange="onGaleriaChange(this)">
    </div>
  </div>
</div>
<div class="panel" id="panel-3">
  <div class="card">
    <div class="card-head">✅ Confirmar registro</div>
    <div class="card-body" id="resumen" style="max-height:52vh;overflow-y:auto;-webkit-overflow-scrolling:touch"></div>
  </div>
  <p style="font-size:11px;color:var(--mut);text-align:center;padding:4px 0">Revisá los datos · deslizá para ver todo</p>
</div>
</div>
<div class="bot-nav">
  <button class="btn-n btn-prev" id="btn-prev" onclick="irPaso(pasoActual-1)" style="display:none">← Atrás</button>
  <button class="btn-n btn-next" id="btn-next" onclick="irPaso(pasoActual+1)">Siguiente →</button>
  <button class="btn-n btn-save" id="btn-save" onclick="guardarRegistro()" style="display:none">💾 Guardar</button>
</div>
<div style="position:fixed;bottom:0;left:0;right:0;z-index:19;text-align:center;font-size:9px;color:#aaa;background:var(--bg);padding:2px 8px calc(3px + env(safe-area-inset-bottom,0px));line-height:1.6;pointer-events:none">
  Sistema de Relevamiento Vial | DVBA | Zona VI | __VER__ | Ing. Luciano Lamaita
</div>
<div class="mov" id="modal-ov" onclick="cerrarModal(event)">
  <div class="modal">
    <div class="mhandle"></div>
    <div class="mhead"><span>Registros pendientes</span><span id="modal-count" style="font-size:11px;color:var(--mut)"></span></div>
    <div class="mbody" id="modal-list"></div>
    <div class="mfoot">
      <button class="btn-m btn-mc" onclick="cerrarModal()">Cerrar</button>
      <button class="btn-m btn-ms" id="btn-sync-modal" onclick="syncManual()">↑ Sincronizar todo</button>
    </div>
  </div>
</div>
<div id="camara-modal">
  <video id="video-stream" autoplay playsinline muted></video>
  <div class="cam-ctrl">
    <button class="btn-cam-sec" onclick="cerrarCamara()">✕ Cancelar</button>
    <button id="btn-capturar" onclick="capturarFrame()" title="Capturar"></button>
    <button class="btn-cam-sec" onclick="flipCamara()">🔄 Girar</button>
  </div>
</div>
<canvas id="canvas-oculto"></canvas>
<div id="ov"><div class="spinner"></div><div id="ov-txt">Procesando…</div></div>"""

HTML_BODY = HTML_BODY.replace('__LOGO_HDR__', LOGO_HDR)
HTML_BODY = HTML_BODY.replace('__VER__', VERSION)

# ── JAVASCRIPT (raw string — NUNCA f-string) ──────────────────
JS = r"""
<script>
/* DVBA Campo __VER__ */
const SUPA_URL='__SURL__',SUPA_KEY='__SKEY__',BUCKET='relevamientos';
const LS_KEY='dvba_z6v6',OFFLINE_KEY='dvba_campo_pendientes';
const LOGO_SELLO='__LOGO__',APP_VER='__VER__';
let gpsWatchId=null,gpsActivo=false,gpsLat=null,gpsLng=null,gpsAcc=null,gpsAlt=null;
let fotoOriginal=null,fotoFinal=null,db=null,deferredInstall=null;
let streamActivo=null,camaraFrontal=false,logoImg=null,pasoActual=0;

document.addEventListener('DOMContentLoaded',async()=>{
  await initDB();actualizarRed();actualizarBadge();monitorRed();
  initPWA();precargarLogo();iniciarGPS();irPaso(0);
  if('serviceWorker' in navigator){
    try{
      const reg=await navigator.serviceWorker.register('sw.js');
      navigator.serviceWorker.addEventListener('message',onSWMsg);
      reg.addEventListener('updatefound',()=>{
        const sw=reg.installing;
        sw.addEventListener('statechange',()=>{
          if(sw.state==='installed'&&navigator.serviceWorker.controller)
            toast('Nueva versión disponible — recargá','warn');
        });
      });
    }catch(e){console.warn('[SW]',e.message);}
  }
});

function precargarLogo(){
  logoImg=new Image();
  logoImg.onload=()=>console.log('[Logo]',logoImg.width+'x'+logoImg.height);
  logoImg.onerror=e=>console.warn('[Logo]',e);
  logoImg.src=LOGO_SELLO;
}

function estaInstalada(){
  return navigator.standalone===true||
    window.matchMedia('(display-mode:standalone)').matches||
    localStorage.getItem('dvba_pwa_ok')==='1';
}
function initPWA(){
  if(estaInstalada()){document.getElementById('pwa-bar').classList.remove('show');return;}
  window.addEventListener('beforeinstallprompt',e=>{
    e.preventDefault();deferredInstall=e;
    document.getElementById('pwa-bar').classList.add('show');
  });
  window.addEventListener('appinstalled',()=>{
    localStorage.setItem('dvba_pwa_ok','1');
    document.getElementById('pwa-bar').classList.remove('show');
    deferredInstall=null;toast('✓ App instalada','ok');
  });
  if(/iphone|ipad|ipod/i.test(navigator.userAgent)&&!navigator.standalone){
    document.getElementById('pwa-bar').classList.add('show');
    document.getElementById('pwa-status').textContent='Safari: compartir ⎙ → Añadir a pantalla';
  }
}
async function instalarPWA(){
  if(!deferredInstall){toast('Usá el menú ⋮ → Instalar app','warn');return;}
  deferredInstall.prompt();await deferredInstall.userChoice;deferredInstall=null;
}
function ocultarPWABar(){
  document.getElementById('pwa-bar').classList.remove('show');
  localStorage.setItem('dvba_pwa_ok','1');
}

function initDB(){
  return new Promise(res=>{
    const req=indexedDB.open('dvba_campo',9);
    req.onupgradeneeded=e=>{const d=e.target.result;if(!d.objectStoreNames.contains('hoy'))d.createObjectStore('hoy',{keyPath:'id',autoIncrement:true});};
    req.onsuccess=e=>{db=e.target.result;res();};req.onerror=()=>res();
  });
}
const idb=(s,m,fn)=>new Promise((res,rej)=>{if(!db){rej(new Error('DB'));return;}const r=fn(db.transaction(s,m).objectStore(s));r.onsuccess=e=>res(e.target.result);r.onerror=e=>rej(e.target.error);});
const dbPut=(s,v)=>idb(s,'readwrite',st=>st.put(v));
const dbAll=s=>idb(s,'readonly',st=>st.getAll());

async function estaOnline(){
  if(!navigator.onLine)return false;
  try{const r=await fetch(SUPA_URL+'/rest/v1/',{method:'HEAD',headers:{'apikey':SUPA_KEY},signal:AbortSignal.timeout(5000)});return r.status<500;}catch(e){return false;}
}

function iniciarGPS(){
  if(!('geolocation' in navigator)){setGpsUI('err','GPS no disponible');document.getElementById('gps-coords-bar').textContent='GPS no disponible';return;}
  gpsActivo=true;setGpsUI('s','GPS buscando…');
  document.getElementById('gps-coords-bar').textContent='Buscando señal GPS…';
  document.getElementById('gps-coords-bar').className='gps-coords buscando';
  if(gpsWatchId!==null){navigator.geolocation.clearWatch(gpsWatchId);gpsWatchId=null;}
  gpsWatchId=navigator.geolocation.watchPosition(onGPSok,onGPSerr,{enableHighAccuracy:true,timeout:30000,maximumAge:3000});
}
function toggleGPS(){
  if(gpsActivo){
    if(gpsWatchId!==null){navigator.geolocation.clearWatch(gpsWatchId);gpsWatchId=null;}
    gpsActivo=false;gpsLat=null;gpsLng=null;gpsAcc=null;gpsAlt=null;
    setGpsUI('err','GPS apagado');
    document.getElementById('gps-coords-bar').textContent='GPS inactivo — tocá para activar';
    document.getElementById('gps-coords-bar').className='gps-coords buscando';
    document.getElementById('gps-acc-bar').textContent='';document.getElementById('btn-usar').disabled=true;
    toast('GPS desactivado','warn');
  }else{iniciarGPS();toast('GPS activado','ok');}
}
function onGPSok(pos){
  gpsLat=pos.coords.latitude;gpsLng=pos.coords.longitude;
  gpsAcc=Math.round(pos.coords.accuracy);
  gpsAlt=pos.coords.altitude?Math.round(pos.coords.altitude):null;
  const age=Math.round((Date.now()-pos.timestamp)/1000);
  const el=document.getElementById('gps-coords-bar');
  el.textContent=gpsLat.toFixed(6)+', '+gpsLng.toFixed(6);el.className='gps-coords';
  document.getElementById('gps-acc-bar').textContent='±'+gpsAcc+' m'+(gpsAlt!==null?'  ·  Alt '+gpsAlt+' m':'')+' · '+(age<=3?'en vivo':age+'s');
  document.getElementById('btn-usar').disabled=false;setGpsUI('ok','±'+gpsAcc+' m');
  if(navigator.onLine)geocodificar(gpsLat,gpsLng);
  if(fotoOriginal)regenerarSello();
}
function onGPSerr(err){
  const msgs={1:'GPS denegado — Ajustes › Chrome › Permisos › Ubicación',2:'Sin señal GPS — salí al exterior',3:'GPS demorado'};
  setGpsUI('err','sin señal');
  document.getElementById('gps-coords-bar').textContent=msgs[err.code]||('Error GPS '+err.code);
  document.getElementById('gps-coords-bar').className='gps-coords buscando';
  if(err.code===1){toast(msgs[1],'err');gpsActivo=false;if(gpsWatchId!==null){navigator.geolocation.clearWatch(gpsWatchId);gpsWatchId=null;}}
}
function setGpsUI(e,t){document.getElementById('gps-led').className='led '+e;document.getElementById('gps-hdr-txt').textContent=t;}
function usarCoordenadas(){
  if(!gpsLat){toast('Esperando señal GPS…','warn');return;}
  document.getElementById('f-lat').value=gpsLat.toFixed(6);document.getElementById('f-lng').value=gpsLng.toFixed(6);
  document.getElementById('coord-display').innerHTML='<div class="coords">'+gpsLat.toFixed(6)+', '+gpsLng.toFixed(6)+'</div><div class="acc" style="color:var(--vd)">✓ Guardado · ±'+gpsAcc+' m</div>';
  const box=document.getElementById('coord-box');box.style.background='rgba(26,138,74,.08)';box.style.borderColor='rgba(26,138,74,.4)';
  toast('✓ Coords guardadas ±'+gpsAcc+' m','ok');if(fotoOriginal)regenerarSello();
}
async function geocodificar(lat,lng){
  try{const r=await fetch('https://nominatim.openstreetmap.org/reverse?lat='+lat+'&lon='+lng+'&format=json&accept-language=es');if(!r.ok)return;const d=await r.json();const road=d.address&&(d.address.road||d.address.highway)||'';const county=d.address&&(d.address.county||d.address.state_district)||'';const el=document.getElementById('geo-r');if(el&&(road||county)){el.textContent='📍 '+[road,county].filter(Boolean).join(' · ');el.style.display='block';}}catch(e){}
}

function irPaso(n){
  pasoActual=Math.max(0,Math.min(3,n));
  for(let i=0;i<4;i++){document.getElementById('panel-'+i).classList.toggle('active',i===pasoActual);const t=document.getElementById('tab-'+i);t.className='tab'+(i<pasoActual?' done':i===pasoActual?' active':'');}
  document.getElementById('btn-prev').style.display=pasoActual>0?'block':'none';
  document.getElementById('btn-next').style.display=pasoActual<3?'block':'none';
  document.getElementById('btn-save').style.display=pasoActual===3?'block':'none';
  if(pasoActual===3)generarResumen();document.getElementById('panel-'+pasoActual).scrollTop=0;
}
function generarResumen(){
  const lat=document.getElementById('f-lat').value,lng=document.getElementById('f-lng').value;
  const filas=[['Ruta',document.getElementById('f-ruta').value||'—'],['Partido',document.getElementById('f-partido').value||'—'],['Progres.',document.getElementById('f-prog').value||'—'],['GPS',lat?lat+', '+lng:'⚠ Sin coordenadas'],['Tipo',document.getElementById('f-tipo').value||'—'],['Estado',document.getElementById('f-estado').value||'—'],['Observ.',document.getElementById('f-obs').value||'—'],['Foto',fotoFinal?'✅ Con sello DVBA':'⚠ Sin foto']];
  document.getElementById('resumen').innerHTML=filas.map(([k,v])=>'<div class="res-row"><div class="res-k">'+k+'</div><div class="res-v">'+v+'</div></div>').join('');
}

async function abrirCamara(){
  try{streamActivo=await navigator.mediaDevices.getUserMedia({video:{facingMode:camaraFrontal?'user':'environment',width:{ideal:1600,max:1920},height:{ideal:1200,max:1440}},audio:false});const v=document.getElementById('video-stream');v.srcObject=streamActivo;await v.play();document.getElementById('camara-modal').classList.add('show');}
  catch(e){if(e.name==='NotAllowedError')toast('Permiso cámara denegado','err');else if(e.name==='NotFoundError')toast('No se encontró cámara','err');else toast('No se pudo abrir la cámara — usá Galería','err');}
}
async function flipCamara(){camaraFrontal=!camaraFrontal;cerrarStream();await abrirCamara();}
function cerrarStream(){if(streamActivo){streamActivo.getTracks().forEach(t=>t.stop());streamActivo=null;}document.getElementById('video-stream').srcObject=null;}
function cerrarCamara(){cerrarStream();document.getElementById('camara-modal').classList.remove('show');}
function capturarFrame(){
  const v=document.getElementById('video-stream');if(!v.videoWidth){toast('Stream no listo','warn');return;}
  const c=document.getElementById('canvas-oculto');c.width=v.videoWidth;c.height=v.videoHeight;c.getContext('2d').drawImage(v,0,0);
  cerrarCamara();fotoOriginal=c.toDataURL('image/jpeg',0.85);showOv('Aplicando sello DVBA…');
  agregarSello(fotoOriginal).then(r=>{fotoFinal=r;mostrarFotoPreview(fotoFinal);irPaso(3);}).catch(e=>{console.warn('Sello:',e);fotoFinal=fotoOriginal;mostrarFotoPreview(fotoFinal);irPaso(3);}).finally(()=>hideOv());
}
function onGaleriaChange(input){
  const file=input.files[0];if(!file)return;
  if(!file.type.startsWith('image/')){toast('No es una imagen','err');input.value='';return;}
  showOv('Procesando foto…');const reader=new FileReader();
  reader.onload=async e=>{try{fotoOriginal=await comprimir(e.target.result,1600,0.85);fotoFinal=await agregarSello(fotoOriginal);mostrarFotoPreview(fotoFinal);irPaso(3);}catch(err){if(fotoOriginal){fotoFinal=fotoOriginal;mostrarFotoPreview(fotoFinal);irPaso(3);}else toast('Error al procesar foto','err');}finally{hideOv();input.value='';}};
  reader.onerror=()=>{hideOv();toast('Error al leer imagen','err');input.value='';};reader.readAsDataURL(file);
}
function mostrarFotoPreview(b64){const p=document.getElementById('foto-prev');p.src=b64;p.style.display='block';const ok=document.getElementById('foto-ok');ok.textContent='✅ Foto con sello DVBA lista';ok.style.display='block';['btn-cam','btn-gal'].forEach(id=>document.getElementById(id).classList.add('done'));}
async function regenerarSello(){if(!fotoOriginal)return;try{fotoFinal=await agregarSello(fotoOriginal);const p=document.getElementById('foto-prev');if(p.style.display!=='none')p.src=fotoFinal;}catch(e){}}

function agregarSello(base64){
  return new Promise((res,rej)=>{
    const img=new Image();
    img.onload=()=>{
      try{
        const W=img.width,H=img.height,C=document.createElement('canvas');C.width=W;C.height=H;
        const ctx=C.getContext('2d');ctx.drawImage(img,0,0);
        const bH=Math.max(72,Math.round(H*0.10)),y0=H-bH;
        const grad=ctx.createLinearGradient(0,y0,0,H);grad.addColorStop(0,'rgba(0,0,0,0.45)');grad.addColorStop(0.3,'rgba(0,0,0,0.78)');grad.addColorStop(1,'rgba(0,0,0,0.88)');ctx.fillStyle=grad;ctx.fillRect(0,y0,W,bH);
        ctx.strokeStyle='#d4a820';ctx.lineWidth=Math.max(1,Math.round(H*0.002));ctx.beginPath();ctx.moveTo(0,y0);ctx.lineTo(W,y0);ctx.stroke();
        const ls=Math.round(bH*0.78),lx=Math.round(bH*0.12),ly=y0+Math.round((bH-ls)/2);
        if(logoImg&&logoImg.complete&&logoImg.naturalWidth>0){ctx.save();ctx.beginPath();ctx.arc(lx+ls/2,ly+ls/2,ls/2,0,Math.PI*2);ctx.clip();ctx.drawImage(logoImg,lx,ly,ls,ls);ctx.restore();}
        else{const cx=lx+ls/2,cy=ly+ls/2;ctx.fillStyle='#111';ctx.beginPath();ctx.arc(cx,cy,ls/2,0,Math.PI*2);ctx.fill();ctx.strokeStyle='#d4a820';ctx.lineWidth=Math.max(2,ls*0.06);ctx.beginPath();ctx.arc(cx,cy,ls/2-ctx.lineWidth/2,0,Math.PI*2);ctx.stroke();const fs2=Math.max(8,Math.round(ls*0.27));ctx.font='900 '+fs2+'px Arial';ctx.fillStyle='#d4a820';ctx.textAlign='center';ctx.textBaseline='middle';ctx.fillText('D',cx-ls*0.23,cy-ls*0.23);ctx.fillText('V',cx+ls*0.23,cy-ls*0.23);ctx.fillText('B',cx-ls*0.23,cy+ls*0.24);ctx.fillText('A',cx+ls*0.23,cy+ls*0.24);ctx.textAlign='left';}
        const sepX=lx+ls+Math.round(bH*0.10);ctx.strokeStyle='rgba(212,168,32,0.35)';ctx.lineWidth=1;ctx.beginPath();ctx.moveTo(sepX,y0+bH*0.08);ctx.lineTo(sepX,H-bH*0.08);ctx.stroke();
        const tx=sepX+Math.round(bH*0.08),maxW=W-tx-Math.round(bH*0.06);
        const fT=Math.max(9,Math.round(H*0.016)),fD=Math.max(8,Math.round(H*0.013)),lh=fT*1.42;
        const ruta=document.getElementById('f-ruta').value||'—',prog=document.getElementById('f-prog').value||'—';
        const partido=document.getElementById('f-partido').value||'—',tipo=document.getElementById('f-tipo').value||'—';
        const latV=gpsLat?gpsLat.toFixed(6):(document.getElementById('f-lat').value||'—');
        const lngV=gpsLng?gpsLng.toFixed(6):(document.getElementById('f-lng').value||'—');
        const accV=gpsAcc?'±'+gpsAcc+' m':'—',altV=gpsAlt!==null?'  Alt: '+gpsAlt+' m':'';
        const now=new Date();
        const fecha=now.toLocaleDateString('es-AR',{day:'2-digit',month:'2-digit',year:'numeric'});
        const hora=now.toLocaleTimeString('es-AR',{hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:false});
        function txtFit(txt,x,y,mxW,fs,color,bold){let sz=fs;ctx.font=(bold?'700':'400')+' '+sz+'px Arial';while(ctx.measureText(txt).width>mxW&&sz>6){sz--;ctx.font=(bold?'700':'400')+' '+sz+'px Arial';}ctx.fillStyle=color;ctx.textBaseline='top';ctx.fillText(txt,x,y);}
        const yB=y0+Math.round(bH*0.09);
        txtFit(ruta+'  ·  '+partido+'  ·  Km '+prog,tx,yB,maxW,fT,'#d4a820',true);
        txtFit(tipo,tx,yB+lh,maxW,fT,'#ffffff',false);
        const coordTxt=latV+', '+lngV+'  '+accV+altV;
        let sz2=fD;ctx.font='400 '+sz2+"px 'Courier New',monospace";
        while(ctx.measureText(coordTxt).width>maxW&&sz2>6){sz2--;ctx.font='400 '+sz2+"px 'Courier New',monospace";}
        ctx.fillStyle='#6ecba0';ctx.textBaseline='top';ctx.fillText(coordTxt,tx,yB+lh*2);
        txtFit(fecha+'  '+hora+' hs  ·  Sist.Relevamiento Vial Móvil '+APP_VER,tx,yB+lh*2.9,maxW,fD,'#8aaec0',false);
        res(C.toDataURL('image/jpeg',0.90));
      }catch(e){rej(e);}
    };
    img.onerror=()=>rej(new Error('Error foto'));img.src=base64;
  });
}
function comprimir(b64,maxPx,q){return new Promise((res,rej)=>{const img=new Image();img.onload=()=>{let w=img.width,h=img.height;if(w>maxPx||h>maxPx){if(w>h){h=Math.round(h*maxPx/w);w=maxPx;}else{w=Math.round(w*maxPx/h);h=maxPx;}}const c=document.createElement('canvas');c.width=w;c.height=h;c.getContext('2d').drawImage(img,0,0,w,h);res(c.toDataURL('image/jpeg',q));};img.onerror=rej;img.src=b64;});}

async function guardarRegistro(){
  const ruta=document.getElementById('f-ruta').value.trim(),tipo=document.getElementById('f-tipo').value.trim();
  const estado=document.getElementById('f-estado').value.trim(),prog=document.getElementById('f-prog').value.trim();
  const obs=document.getElementById('f-obs').value.trim(),partido=document.getElementById('f-partido').value.trim();
  const lat=parseFloat(document.getElementById('f-lat').value)||null,lng=parseFloat(document.getElementById('f-lng').value)||null;
  if(!ruta){toast('Seleccioná la ruta','err');return;}if(!tipo){toast('Seleccioná el tipo de suceso','err');return;}if(!lat||!lng){toast('Aplicá las coordenadas GPS con ↓ Usar','err');return;}
  const fecha=new Date().toISOString(),tempId=Date.now();
  const reg={ruta,partido:partido||null,progresiva:prog||null,tipo,estado:estado||null,observaciones:obs||null,foto_url:null,lat,lng,fecha};
  showOv('Verificando conexión…');const online=await estaOnline();let cloud=false,fotoUrl=null;
  if(online){try{if(fotoFinal){showOv('Subiendo foto…');fotoUrl=await subirFoto(fotoFinal,ruta);reg.foto_url=fotoUrl;}showOv('Guardando en la nube…');const resp=await fetch(SUPA_URL+'/rest/v1/relevamientos',{method:'POST',headers:{'apikey':SUPA_KEY,'Authorization':'Bearer '+SUPA_KEY,'Content-Type':'application/json','Prefer':'return=representation'},body:JSON.stringify(reg),signal:AbortSignal.timeout(12000)});if(resp.ok){const rows=await resp.json();reg.id=(rows[0]&&rows[0].id)||tempId;cloud=true;}else{const t=await resp.text();console.warn('[SUPA]',resp.status,t);showOv('Error '+resp.status);await new Promise(r=>setTimeout(r,1800));}}catch(e){console.warn('[SUPA]',e.message);}}
  try{const prev=JSON.parse(localStorage.getItem(LS_KEY)||'[]');prev.unshift({id:reg.id||tempId,ruta,partido,prog:reg.progresiva,tipo,estado,obs:reg.observaciones||'',foto:fotoUrl||null,fecha:new Date(fecha).toLocaleString('es-AR'),fechaISO:fecha,lat,lng});if(prev.length>200)prev.splice(200);localStorage.setItem(LS_KEY,JSON.stringify(prev));}catch(e){}
  if(!cloud){const pend=getPendientes();pend.push({id:'local_'+tempId,...reg,fotoBase64:fotoFinal||null,ts:tempId});try{localStorage.setItem(OFFLINE_KEY,JSON.stringify(pend));}catch(e){pend[pend.length-1].fotoBase64=null;try{localStorage.setItem(OFFLINE_KEY,JSON.stringify(pend));}catch(e2){}}actualizarBadge();if('serviceWorker' in navigator&&'SyncManager' in window){try{const sw=await navigator.serviceWorker.ready;await sw.sync.register('dvba-sync-registros');}catch(e){}}}
  const thumb=fotoFinal?await hacerThumb(fotoFinal):null;if(db)await dbPut('hoy',{id:reg.id||tempId,...reg,fotoThumb:thumb,synced:cloud}).catch(()=>{});
  hideOv();if(cloud)toast('✓ Guardado en la nube','ok');else toast('⚠ Sin conexión — guardado localmente','warn');limpiarForm();
}

async function subirFoto(b64,ruta){
  try{const [hdr,data]=b64.split(','),mime=hdr.match(/:(.*?);/)[1];const bytes=atob(data),arr=new Uint8Array(bytes.length);for(let i=0;i<bytes.length;i++)arr[i]=bytes.charCodeAt(i);const blob=new Blob([arr],{type:mime});const ext=mime.includes('jpeg')?'jpg':(mime.split('/')[1]||'jpg');const path='fotos/'+Date.now()+'_'+ruta.replace(/\s/g,'')+'.sello.'+ext;const resp=await fetch(SUPA_URL+'/storage/v1/object/'+BUCKET+'/'+path,{method:'POST',headers:{'apikey':SUPA_KEY,'Authorization':'Bearer '+SUPA_KEY,'Content-Type':mime,'x-upsert':'true'},body:blob,signal:AbortSignal.timeout(30000)});if(resp.ok)return SUPA_URL+'/storage/v1/object/public/'+BUCKET+'/'+path;console.warn('[FOTO]',resp.status,await resp.text());}catch(e){console.warn('[FOTO]',e.message);}return null;
}

function getPendientes(){try{return JSON.parse(localStorage.getItem(OFFLINE_KEY)||'[]');}catch{return[];}}
function actualizarBadge(){const n=getPendientes().length,bar=document.getElementById('pend-bar');if(n>0){bar.classList.add('on');document.getElementById('pend-count').textContent=n+' registro'+(n>1?'s':'')+' pendiente'+(n>1?'s':'');document.getElementById('pend-sub').textContent=navigator.onLine?'Tenés señal — tocá Sync':'Sin red — sincronizá al volver';}else bar.classList.remove('on');}
function abrirModal(){renderModalList();document.getElementById('modal-count').textContent=getPendientes().length+' pendientes';document.getElementById('modal-ov').classList.add('on');}
function cerrarModal(e){if(e&&e.target!==document.getElementById('modal-ov'))return;document.getElementById('modal-ov').classList.remove('on');}
function renderModalList(){
  const list=document.getElementById('modal-list'),p=getPendientes();
  if(!p.length){list.innerHTML='<div style="padding:24px;text-align:center;color:var(--mut)">Sin registros pendientes</div>';return;}
  list.innerHTML=p.map(r=>'<div class="pitem"><div class="pdot"></div><div class="pinfo"><div class="ptit">'+(r.ruta||'—')+' · '+(r.tipo||'Sin tipo')+'</div><div class="psub">'+(r.partido||'—')+' · Km '+(r.progresiva||'—')+' · '+(r.estado||'—')+(r.fotoBase64?' · 📷':' · sin foto')+'<br>'+new Date(r.fecha).toLocaleString('es-AR',{dateStyle:'short',timeStyle:'short',hour12:false})+'</div></div><button onclick="borrarPendiente(\''+r.id+'\')" style="background:none;border:1px solid #c06060;color:#c06060;border-radius:6px;padding:4px 8px;font-size:10px;cursor:pointer;flex-shrink:0">✕</button></div>').join('');
}
function borrarPendiente(id){const p=getPendientes().filter(r=>r.id!==id);localStorage.setItem(OFFLINE_KEY,JSON.stringify(p));actualizarBadge();renderModalList();toast('Registro eliminado','warn');}

async function syncManual(){
  const b1=document.getElementById('btn-sync-bar'),b2=document.getElementById('btn-sync-modal');
  [b1,b2].forEach(b=>{if(b){b.textContent='Sincronizando…';b.disabled=true;}});
  const online=await estaOnline();if(!online){toast('Sin conexión al servidor','warn');[b1,b2].forEach(b=>{if(b){b.textContent=b===b1?'↑ Sync':'↑ Sincronizar todo';b.disabled=false;}});return;}
  const pend=getPendientes();if(!pend.length){toast('Sin pendientes','ok');[b1,b2].forEach(b=>{if(b){b.textContent=b===b1?'↑ Sync':'↑ Sincronizar todo';b.disabled=false;}});return;}
  let ok=0,fail=0;const restantes=[];
  for(const item of pend){try{const {id,fotoBase64:fb,ts,...reg}=item;let foto_url=reg.foto_url||null;if(!foto_url&&fb)foto_url=await subirFoto(fb,reg.ruta||'campo');const resp=await fetch(SUPA_URL+'/rest/v1/relevamientos',{method:'POST',headers:{'apikey':SUPA_KEY,'Authorization':'Bearer '+SUPA_KEY,'Content-Type':'application/json','Prefer':'return=minimal'},body:JSON.stringify({...reg,foto_url}),signal:AbortSignal.timeout(12000)});if(resp.ok)ok++;else{restantes.push(item);fail++;console.warn('[SYNC]',resp.status,await resp.text());}}catch(e){restantes.push(item);fail++;console.warn('[SYNC]',e.message);}}
  localStorage.setItem(OFFLINE_KEY,JSON.stringify(restantes));actualizarBadge();renderModalList();
  [b1,b2].forEach(b=>{if(b){b.textContent=b===b1?'↑ Sync':'↑ Sincronizar todo';b.disabled=false;}});
  if(ok>0&&fail===0){toast('✓ '+ok+' sincronizado'+(ok>1?'s':''),'ok');if(!restantes.length)cerrarModal();}else if(ok>0)toast('✓ '+ok+' ok · '+fail+' fallaron','warn');else toast('No se pudo sincronizar','err');
}

function limpiarForm(){
  ['f-ruta','f-prog','f-tipo','f-estado','f-partido','f-obs'].forEach(id=>document.getElementById(id).value='');
  document.getElementById('f-lat').value='';document.getElementById('f-lng').value='';
  fotoOriginal=null;fotoFinal=null;
  const p=document.getElementById('foto-prev');p.src='';p.style.display='none';
  const ok=document.getElementById('foto-ok');ok.style.display='none';ok.textContent='';
  ['btn-cam','btn-gal'].forEach(id=>document.getElementById(id).classList.remove('done'));
  document.getElementById('inp-galeria').value='';
  const box=document.getElementById('coord-box');box.style.background='';box.style.borderColor='';
  document.getElementById('coord-display').innerHTML='<div class="empty">Presioná ↓ Usar cuando el GPS tenga señal</div>';
  document.getElementById('geo-r').style.display='none';irPaso(0);
}

function monitorRed(){actualizarRed();window.addEventListener('online',()=>{actualizarRed();actualizarBadge();setTimeout(syncManual,2500);});window.addEventListener('offline',()=>{actualizarRed();actualizarBadge();toast('Sin red','warn');});}
function actualizarRed(){const b=document.getElementById('net-badge');if(navigator.onLine){b.textContent='● ONLINE';b.className='net net-on';}else{b.textContent='◌ SIN RED';b.className='net net-off';}}
function onSWMsg(e){if(e.data&&e.data.tipo==='SYNC_COMPLETO'){actualizarBadge();renderModalList();if(e.data.count>0)toast('✓ '+e.data.count+' sincronizado'+(e.data.count>1?'s':''),'ok');}}

let _tt=null;
function toast(msg,tipo){const el=document.getElementById('toast');el.textContent=msg;el.className='toast '+(tipo||'')+' show';clearTimeout(_tt);_tt=setTimeout(()=>el.classList.remove('show'),3500);}
function showOv(txt){document.getElementById('ov-txt').textContent=txt||'…';document.getElementById('ov').classList.add('show');}
function hideOv(){document.getElementById('ov').classList.remove('show');}
function hacerThumb(b64){return new Promise(res=>{const img=new Image();img.onload=()=>{const s=80,c=document.createElement('canvas');c.width=s;c.height=s;const ctx=c.getContext('2d'),mn=Math.min(img.width,img.height);ctx.drawImage(img,(img.width-mn)/2,(img.height-mn)/2,mn,mn,0,0,s,s);res(c.toDataURL('image/jpeg',0.5));};img.onerror=()=>res(null);img.src=b64;});}
</script>
</body>
</html>"""

# Inyectar valores — replace explícito, NUNCA f-string sobre JS
JS = JS.replace('__SURL__', SUPA_URL)
JS = JS.replace('__SKEY__', SUPA_KEY)
JS = JS.replace('__VER__',  VERSION)
JS = JS.replace('__LOGO__', LOGO_CIRC)

FULL = HTML_HEAD + HTML_BODY + JS

output_path = os.path.join(OUT_DIR, 'dvba_campo.html')
with open(output_path, 'w', encoding='utf-8') as f:
    f.write(FULL)

print(f"dvba_campo.html {VERSION}: {len(FULL)//1024} KB  →  {output_path}")
print(f"manifest.json              →  {manifest_path}")
print()
print("Copiá los archivos de output/ a C:\\DVBA\\app\\")
print("El sw.js copialo manualmente (no cambia con el build).")
