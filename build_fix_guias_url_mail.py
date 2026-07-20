#!/usr/bin/env python3
"""Fix guías: URL correcta para móvil (dvba_campo_lite.html) + email admin correcto."""
import os

REPO = '/sessions/eager-tender-faraday/mnt/GitHub--DVBA'

# ═══════════════════════════════════════════════════════════════════
# docs/guia_visual_sig_vial_pba.html
# ═══════════════════════════════════════════════════════════════════
path = os.path.join(REPO, 'docs/guia_visual_sig_vial_pba.html')
with open(path, 'r', encoding='utf-8') as f:
    html = f.read()

# 1) Sección "Cómo se accede" — aclarar que URL base es escritorio + agregar URL móvil
old1 = '''<div class="card">
<p>La URL de acceso es única para todo el sistema:</p>
<p style="text-align:center;font-size:1.1rem"><a href="https://lemeit.github.io/DVBA/" style="color:var(--teal);font-weight:700">https://lemeit.github.io/DVBA/</a></p>

<div class="grid2">
  <div class="box">
    <strong>Desde el celular</strong><br>
    Abrir esa URL en <strong>Chrome</strong> (Android) o <strong>Safari</strong> (iOS). Se abre la app móvil.
  </div>
  <div class="box">
    <strong>Desde una computadora</strong><br>
    Abrir esa URL en cualquier navegador moderno. Se abre el portal escritorio con el mapa y las herramientas de oficina.
  </div>
</div>

<div class="box tip">
<strong>💡</strong> No hace falta bajar nada de una tienda de aplicaciones. Todo funciona con el navegador del celular o de la compu.
</div>
</div>'''

new1 = '''<div class="card">
<p>El sistema tiene <strong>dos URLs</strong> según lo que quieras usar:</p>

<div class="grid2">
  <div class="box">
    <strong>🖥 Portal escritorio</strong><br>
    <p style="font-size:.95rem"><a href="https://lemeit.github.io/DVBA/" style="color:var(--teal);font-weight:700">lemeit.github.io/DVBA/</a></p>
    Se abre el mapa + herramientas de oficina + Plan de Seguridad + Reportes. Pensado para computadora.
  </div>
  <div class="box">
    <strong>📱 App móvil (Captura Rápida)</strong><br>
    <p style="font-size:.95rem"><a href="https://lemeit.github.io/DVBA/dvba_campo_lite.html" style="color:var(--teal);font-weight:700">lemeit.github.io/DVBA/dvba_campo_lite.html</a></p>
    Se abre la app para instalar en el celular. Este es el link que hay que abrir en Chrome del teléfono.
  </div>
</div>

<div class="box tip">
<strong>💡</strong> No hace falta bajar nada de una tienda de aplicaciones. Todo funciona con el navegador del celular o de la compu. Si abrís la URL base (<code>/DVBA/</code>) en un celular vas a caer en el portal — para instalar la app tenés que ir directo a <code>/dvba_campo_lite.html</code>.
</div>
</div>'''
if old1 not in html: raise SystemExit('X patch 1 (guía visual URLs) NO encontrado')
html = html.replace(old1, new1, 1)
print('OK guía visual · sección "Cómo se accede" corregida (URL móvil separada)')

# 2) Sección Instalar · corregir el "Ir a lemeit.github.io/DVBA/"
old2 = '<li>Ir a <code>lemeit.github.io/DVBA/</code>.</li>'
new2 = '<li>Ir a <code>lemeit.github.io/DVBA/dvba_campo_lite.html</code> (importante: el <code>/dvba_campo_lite.html</code> al final, sino se abre el portal escritorio).</li>'
if old2 not in html: raise SystemExit('X patch 2 (guía visual instalar URL) NO encontrado')
html = html.replace(old2, new2, 1)
print('OK guía visual · paso "Ir a URL" con URL correcta')

# 3) Email correcto
html = html.replace('tecnica.dvba.z6@gmail.com', 'lucianolamaita@gmail.com')
print('OK guía visual · email admin actualizado')

with open(path, 'w', encoding='utf-8') as f:
    f.write(html)


# ═══════════════════════════════════════════════════════════════════
# docs/guia_sig_vial_pba.html (manual textual)
# ═══════════════════════════════════════════════════════════════════
path = os.path.join(REPO, 'docs/guia_sig_vial_pba.html')
with open(path, 'r', encoding='utf-8') as f:
    html = f.read()

# 1) Paso "Ir a URL en Chrome" · corregir URL
old1 = '<p>Ir a <a href="https://lemeit.github.io/DVBA/">lemeit.github.io/DVBA/</a> desde Chrome (Android) o Safari (iOS).</p>'
new1 = '<p>Ir a <a href="https://lemeit.github.io/DVBA/dvba_campo_lite.html">lemeit.github.io/DVBA/dvba_campo_lite.html</a> desde Chrome (Android) o Safari (iOS). ⚠ Si ponés solo <code>/DVBA/</code> se abre el portal escritorio; para instalar la app hay que ir directo al link con <code>/dvba_campo_lite.html</code>.</p>'
if old1 not in html: raise SystemExit('X patch textual 1 (URL móvil) NO encontrado')
html = html.replace(old1, new1, 1)
print('OK guía textual · paso instalar con URL correcta')

# 2) FAQ "puedo instalar en la notebook" · aclarar
old2 = '<p>Sí. Chrome/Edge muestran un botón "Instalar" en la barra de direcciones cuando abrís <a href="https://lemeit.github.io/DVBA/">lemeit.github.io/DVBA/</a>. La PWA queda como app nativa del sistema.</p>'
new2 = '<p>Sí. Chrome/Edge muestran un botón "Instalar" en la barra de direcciones cuando abrís <a href="https://lemeit.github.io/DVBA/dvba_campo_lite.html">lemeit.github.io/DVBA/dvba_campo_lite.html</a> (o la variante <code>dvba_campo.html</code>). La PWA queda como app nativa del sistema.</p>'
if old2 not in html: raise SystemExit('X patch textual 2 (FAQ notebook) NO encontrado')
html = html.replace(old2, new2, 1)
print('OK guía textual · FAQ notebook con URL correcta')

# 3) Email correcto
html = html.replace('tecnica.dvba.z6@gmail.com', 'lucianolamaita@gmail.com')
print('OK guía textual · email admin actualizado')

with open(path, 'w', encoding='utf-8') as f:
    f.write(html)

print('\nOK docs actualizados.')
