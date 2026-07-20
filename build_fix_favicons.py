#!/usr/bin/env python3
"""Fix favicon del portal + apple-touch-icon del campo + logo real en guía visual."""
import os, re

REPO = '/sessions/eager-tender-faraday/mnt/GitHub--DVBA'

# ═══════════════════════════════════════════════════════════════
# 1) index.html · reemplazar el favicon base64 gigante por link limpio
# ═══════════════════════════════════════════════════════════════
path = os.path.join(REPO, 'index.html')
with open(path, 'r', encoding='utf-8') as f:
    html = f.read()

# El favicon está en la línea 5 con base64 largo. Uso regex para pescar toda la línea.
old_favicon = re.search(r'  <link rel="icon" type="image/png" href="data:image/png;base64,[^"]+">', html)
if not old_favicon:
    raise SystemExit('X favicon base64 no encontrado en index.html')
html_new = html.replace(old_favicon.group(0), '  <link rel="icon" href="datos/img/favicon.png">')
with open(path, 'w', encoding='utf-8') as f:
    f.write(html_new)
print(f'OK index.html · favicon reemplazado ({len(html) - len(html_new)} chars ahorrados)')

# ═══════════════════════════════════════════════════════════════
# 2) dvba_campo.html · reemplazar icon y apple-touch-icon base64
# ═══════════════════════════════════════════════════════════════
path = os.path.join(REPO, 'dvba_campo.html')
with open(path, 'r', encoding='utf-8') as f:
    html = f.read()
orig = len(html)

# icon base64
m1 = re.search(r'<link rel="icon" type="image/png" href="data:image/png;base64,[^"]+">', html)
if not m1: raise SystemExit('X icon base64 no encontrado en dvba_campo.html')
html = html.replace(m1.group(0), '<link rel="icon" href="datos/img/favicon.png">')

# apple-touch-icon base64
m2 = re.search(r'<link rel="apple-touch-icon" href="data:image/png;base64,[^"]+">', html)
if not m2: raise SystemExit('X apple-touch-icon base64 no encontrado en dvba_campo.html')
html = html.replace(m2.group(0), '<link rel="apple-touch-icon" href="datos/img/icon-192.png">')

with open(path, 'w', encoding='utf-8') as f:
    f.write(html)
print(f'OK dvba_campo.html · icon + apple-touch-icon reemplazados ({orig - len(html)} chars ahorrados)')

# ═══════════════════════════════════════════════════════════════
# 3) docs/guia_visual_sig_vial_pba.html · usar logo real en mockups
# ═══════════════════════════════════════════════════════════════
path = os.path.join(REPO, 'docs/guia_visual_sig_vial_pba.html')
with open(path, 'r', encoding='utf-8') as f:
    html = f.read()

# 3a) CSS del .logo · quitar background dorado y texto, dejar container para <img>
old_css = '.lite-hdr .logo{width:28px;height:28px;background:#ffd700;border-radius:50%;flex-shrink:0;display:flex;align-items:center;justify-content:center;font-size:9px;font-weight:900;color:#003366}'
new_css = '.lite-hdr .logo{width:28px;height:28px;flex-shrink:0;border-radius:50%;overflow:hidden;display:flex;align-items:center;justify-content:center}\n.lite-hdr .logo img{width:100%;height:100%;object-fit:contain}'
if old_css not in html:
    raise SystemExit('X CSS .lite-hdr .logo no encontrado')
html = html.replace(old_css, new_css)
print('OK guía visual · CSS .logo actualizado para soportar <img>')

# 3b) Reemplazar todas las ocurrencias del placeholder por <img>
old_logo = '<div class="logo">DVBA</div>'
new_logo = '<div class="logo"><img src="../datos/img/logo_dvba_clean.png" alt="DVBA"></div>'
n = html.count(old_logo)
if n == 0: raise SystemExit('X placeholder <div class="logo">DVBA</div> no encontrado')
html = html.replace(old_logo, new_logo)
print(f'OK guía visual · {n} logos reemplazados por <img>')

with open(path, 'w', encoding='utf-8') as f:
    f.write(html)

# ═══════════════════════════════════════════════════════════════
# 4) Verificación
# ═══════════════════════════════════════════════════════════════
print('\n=== Verificación post-fix ===')
for f in ['index.html', 'dvba_campo.html', 'docs/guia_visual_sig_vial_pba.html']:
    with open(os.path.join(REPO, f), 'r', encoding='utf-8') as fh:
        lines = fh.readlines()
    print(f'  {f}: {len(lines)} líneas · fin: {lines[-1].strip()!r}')
