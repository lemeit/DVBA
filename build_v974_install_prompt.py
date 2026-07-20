#!/usr/bin/env python3
"""v9.74 · Modal de instalación PWA prominente en lite y full."""
import os, subprocess

REPO = '/sessions/eager-tender-faraday/mnt/GitHub--DVBA'

def read(name):
    with open(os.path.join(REPO, name), 'r', encoding='utf-8') as f:
        return f.read()

def process(name, patches, expected_tail):
    print(f'=== {name} ===')
    html = read(name)
    orig = len(html)
    for i,(label,old,new) in enumerate(patches,1):
        if old not in html:
            raise SystemExit(f'  X patch {i} ({label}): NO encontrado')
        html = html.replace(old, new, 1)
        print(f'  OK patch {i}: {label}')
    if not html.rstrip().endswith(expected_tail):
        raise SystemExit(f'  X tail invalido: [{html[-40:]!r}]')
    tmp = '/tmp/' + name.replace('/','_')
    open(tmp,'w',encoding='utf-8',newline='\n').write(html)
    subprocess.run(['cp', tmp, os.path.join(REPO,name)], check=True)
    print(f'  -> {orig} -> {len(html)} chars | cp OK')

# CSS del modal · se inserta ANTES de </style>
CSS_INSTALL = '''
/* v9.74 · Modal de instalación PWA · prominente para forzar la decisión */
.install-ov{position:fixed;inset:0;background:rgba(0,20,30,.85);z-index:9999;display:none;align-items:center;justify-content:center;padding:20px;backdrop-filter:blur(4px);animation:fadeIn .3s ease-out}
.install-ov.on{display:flex}
@keyframes fadeIn{from{opacity:0}to{opacity:1}}
@keyframes slideUp{from{transform:translateY(40px);opacity:0}to{transform:translateY(0);opacity:1}}
.install-box{background:#fff;border-radius:18px;padding:28px 24px 22px;max-width:360px;width:100%;box-shadow:0 20px 60px rgba(0,0,0,.55);text-align:center;animation:slideUp .4s ease-out}
.install-box .install-icon{width:88px;height:88px;margin:0 auto 14px;border-radius:50%;background:linear-gradient(135deg,#009aae,#007d90);display:flex;align-items:center;justify-content:center;box-shadow:0 6px 18px rgba(0,154,174,.4)}
.install-box .install-icon img{width:66px;height:66px;object-fit:contain;border-radius:50%}
.install-box h2{margin:0 0 10px;font-size:22px;font-weight:900;color:#003366;letter-spacing:.3px}
.install-box .install-sub{margin:0 0 18px;font-size:14px;color:#555;line-height:1.5}
.install-box .install-sub b{color:#009aae}
.install-box .install-benefits{list-style:none;padding:14px 16px;margin:0 0 22px;text-align:left;background:#f0fbfc;border-radius:10px}
.install-box .install-benefits li{font-size:13px;color:#1a4a5a;padding:5px 0;font-weight:600;line-height:1.35}
.install-box .install-benefits li b{color:#003366}
.install-box .btn-install-yes{width:100%;padding:16px;background:linear-gradient(135deg,#1a8a4a,#146638);color:#fff;border:0;border-radius:12px;font-family:inherit;font-size:15px;font-weight:900;letter-spacing:.5px;text-transform:uppercase;cursor:pointer;box-shadow:0 6px 16px rgba(26,138,74,.35);transition:transform .12s}
.install-box .btn-install-yes:active{transform:scale(.96)}
.install-box .btn-install-no{width:100%;padding:12px;background:transparent;color:#6a6a6a;border:0;font-family:inherit;font-size:12px;font-weight:600;margin-top:8px;cursor:pointer;text-decoration:underline}
.install-box .install-hint-ios{margin-top:14px;padding:10px;background:#fff4e0;border:1px solid #f0d090;border-radius:8px;font-size:11px;color:#7a5000;line-height:1.5;display:none}
.install-box.ios .install-hint-ios{display:block}
'''

# HTML del modal · se inserta antes del <script> principal
HTML_INSTALL = '''<!-- v9.74 · Modal de instalación PWA (aparece si el user abrió desde navegador) -->
<div id="modalInstall" class="install-ov">
  <div class="install-box" id="modalInstallBox">
    <div class="install-icon"><img src="datos/img/logo_dvba_clean.png" alt="SIG Vial PBA"></div>
    <h2>Instalá SIG Vial PBA</h2>
    <p class="install-sub">Guardala en tu celular como una app y <b>usala en cualquier lugar</b> — incluso <b>sin WiFi ni datos móviles</b>.</p>
    <ul class="install-benefits">
      <li>✓ Funciona <b>sin internet</b> (solo GPS)</li>
      <li>✓ Se abre <b>con un toque</b> desde el ícono</li>
      <li>✓ Las fotos <b>se sincronizan solas</b> al volver la señal</li>
      <li>✓ Ocupa muy poco espacio</li>
    </ul>
    <button class="btn-install-yes" onclick="lInstalarPWA()">📲 Instalar en el celular</button>
    <button class="btn-install-no" onclick="lPostponerInstall()">Ahora no, seguir en el navegador</button>
    <div class="install-hint-ios">
      <b>En iPhone/iPad:</b> tocá el botón <b>Compartir</b> ↥ del navegador y elegí <b>"Agregar a pantalla de inicio"</b>.
    </div>
  </div>
</div>

'''

# JS del install prompt
JS_INSTALL = '''
// v9.74 · Prompt de instalación PWA · aparece si el usuario abrió desde el navegador
let _installPromptDeferred = null;
window.addEventListener('beforeinstallprompt', function(e){
  e.preventDefault();
  _installPromptDeferred = e;
  setTimeout(function(){
    try {
      const postponed = localStorage.getItem('dvba_install_postponed_at');
      if (postponed && (Date.now() - Number(postponed)) < 24 * 3600 * 1000) return;
      if (window.matchMedia && window.matchMedia('(display-mode: standalone)').matches) return;
      const m = document.getElementById('modalInstall');
      if (m) m.classList.add('on');
    } catch(e){}
  }, 1500);
});
window.addEventListener('appinstalled', function(){
  console.log('[install] PWA instalada');
  _installPromptDeferred = null;
  const m = document.getElementById('modalInstall');
  if (m) m.classList.remove('on');
  try { localStorage.removeItem('dvba_install_postponed_at'); } catch(e){}
});
function lInstalarPWA(){
  if (!_installPromptDeferred){
    alert('Tu navegador no permite instalar la app en este momento. Probá desde el menú ⋮ del navegador → Instalar aplicación.');
    return;
  }
  _installPromptDeferred.prompt();
  _installPromptDeferred.userChoice.then(function(r){
    if (r.outcome !== 'accepted') lPostponerInstall();
    _installPromptDeferred = null;
  });
}
function lPostponerInstall(){
  try { localStorage.setItem('dvba_install_postponed_at', String(Date.now())); } catch(e){}
  const m = document.getElementById('modalInstall');
  if (m) m.classList.remove('on');
}
// iOS no dispara beforeinstallprompt · mostramos instrucciones manuales
(function(){
  const isIOS = /iphone|ipad|ipod/i.test(navigator.userAgent);
  const inStandalone = (window.matchMedia && window.matchMedia('(display-mode: standalone)').matches) || window.navigator.standalone;
  if (isIOS && !inStandalone){
    setTimeout(function(){
      try {
        const postponed = localStorage.getItem('dvba_install_postponed_at');
        if (postponed && (Date.now() - Number(postponed)) < 24 * 3600 * 1000) return;
        const box = document.getElementById('modalInstallBox');
        const m = document.getElementById('modalInstall');
        if (box && m){ box.classList.add('ios'); m.classList.add('on'); }
      } catch(e){}
    }, 1500);
  }
})();
'''

# ═══════════════════════════════════════════════════════════════════
# dvba_campo_lite.html
# ═══════════════════════════════════════════════════════════════════
# CSS · insertar antes del cierre del <style> principal (que está antes de </head>)
# HTML · insertar antes del comentario del modal Info existente o después del <body>
# JS · insertar antes del cierre del <script> principal

# Verifico marcadores únicos primero
lite = read('dvba_campo_lite.html')
# Encontrar el último </style> antes de </head>
head_close = lite.find('</head>')
last_style_close = lite.rfind('</style>', 0, head_close)
print(f'lite: <style> cierra en posición {last_style_close}, </head> en {head_close}')

# Marcador para CSS: uso una línea distintiva del CSS actual + agrego el CSS_INSTALL antes de </style>
process('dvba_campo_lite.html', [
    # 1) CSS: agregar antes del </style>
    ('CSS install antes de </style>',
     '</style>\n</head>',
     CSS_INSTALL + '</style>\n</head>'),
    # 2) HTML: agregar después del <body>
    ('HTML install después de <body>',
     '<body>\n\n<!-- v9.67 · Banner de nueva versión',
     '<body>\n\n' + HTML_INSTALL + '<!-- v9.67 · Banner de nueva versión'),
    # 3) JS: agregar antes del cierre del script principal
    ('JS install antes de DOMContentLoaded',
     "document.addEventListener('DOMContentLoaded', inicializar);",
     JS_INSTALL + "\ndocument.addEventListener('DOMContentLoaded', inicializar);"),
    # bump APP_VER
    ('bump APP_VER v9.73 -> v9.74',
     "const APP_VER = 'v9.73';",
     "const APP_VER = 'v9.74';"),
], '</html>')

# ═══════════════════════════════════════════════════════════════════
# dvba_campo.html (full) · mismo modal
# ═══════════════════════════════════════════════════════════════════
full = read('dvba_campo.html')
# CSS: buscar donde termina el bloque <style> · usar un marcador único
process('dvba_campo.html', [
    # 1) CSS
    ('CSS install antes de </style>',
     '</style>\n</head>',
     CSS_INSTALL + '</style>\n</head>'),
    # 2) HTML
    ('HTML install después de <body>',
     '<body>\n<script>',
     '<body>\n' + HTML_INSTALL + '<script>'),
    # 3) JS
    ('JS install antes de cierre script principal',
     "document.addEventListener('DOMContentLoaded', () => { tipoInit(); }, { once: true });",
     JS_INSTALL + "\ndocument.addEventListener('DOMContentLoaded', () => { tipoInit(); }, { once: true });"),
    # bump
    ('bump span app-ver v9.73 -> v9.74',
     "<span id='app-ver'>v9.73</span>",
     "<span id='app-ver'>v9.74</span>"),
], '</html>')

# ═══════════════════════════════════════════════════════════════════
# sw.js · bump cache + changelog
# ═══════════════════════════════════════════════════════════════════
process('sw.js', [
    ('bump CACHE_NAME',
     "const CACHE_NAME = 'dvba-campo-v9.73';",
     "const CACHE_NAME = 'dvba-campo-v9.74';"),
    ('changelog',
     "   v3.11: bump versión (v9.73) · fixes lite: link app completa, quitar nombre autor del modal Info, brand unificado.",
     "   v3.12: bump versión (v9.74) · modal de instalación PWA prominente en lite y full.\n   v3.11: bump versión (v9.73) · fixes lite: link app completa, quitar nombre autor del modal Info, brand unificado."),
], '}')

print('\nOK v9.74 aplicado.')
