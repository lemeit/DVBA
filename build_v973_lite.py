#!/usr/bin/env python3
"""v9.73 · Fixes lite: link 'app completa' desde login, quitar nombre
autor del modal Info, unificar brand a 'SIG Vial PBA · Captura Rápida'."""
import subprocess, os

REPO = '/sessions/eager-tender-faraday/mnt/GitHub--DVBA'

def from_disk(name):
    with open(os.path.join(REPO, name), 'r', encoding='utf-8') as f:
        return f.read()

def process(name, patches, expected_tail):
    print(f'=== {name} ===')
    html = from_disk(name)
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

process('dvba_campo_lite.html', [
    # B) Link 'app completa' del login · setear preferencia para evitar el redirect loop
    ('v9.73 link app completa del login setea prefiere_full',
     '<p style="font-size:10.5px;color:var(--mut);margin-top:14px">O usá la <a href="dvba_campo.html" style="color:var(--p)">app completa</a>.</p>',
     '<p style="font-size:10.5px;color:var(--mut);margin-top:14px">O usá la <a href="dvba_campo.html" onclick="try{localStorage.setItem(\'dvba_prefiere_full\',\'1\')}catch(e){}" style="color:var(--p)">app completa</a>.</p>'),

    # Bonus) Brand del header · unificar a SIG Vial PBA
    ('v9.73 brand header',
     '      DVBA · Captura Rápida\n      <span class="sub">Zona VI Saladillo</span>',
     '      SIG Vial PBA · Captura Rápida\n      <span class="sub">Zona VI Saladillo</span>'),

    # Bonus) Título del modal Info
    ('v9.73 título modal Info',
     "'<b>DVBA · Captura Rápida</b><br>'",
     "'<b>SIG Vial PBA · Captura Rápida</b><br>'"),

    # C) Sacar línea del autor del modal Info · el nombre ya está en el user badge
    ('v9.73 quitar línea autor del modal Info',
     "'<span style=\"font-size:11px;color:#888\">Ing. Luciano Lamaita — División Técnica DVBA</span>' +",
     "''  +  // v9.73 · nombre del autor sacado — redundante con el user badge y el footer del portal"),

    # Bump APP_VER
    ('bump APP_VER v9.72 -> v9.73',
     "const APP_VER = 'v9.72';",
     "const APP_VER = 'v9.73';"),
], '</html>')

# SW · bump cache
process('sw.js', [
    ('bump CACHE_NAME',
     "const CACHE_NAME = 'dvba-campo-v9.72';",
     "const CACHE_NAME = 'dvba-campo-v9.73';"),
    ('changelog',
     "   v3.10: bump versión (v9.72) · ajuste naming DVBA → PBA (SIG Vial PBA).",
     "   v3.11: bump versión (v9.73) · fixes lite: link app completa, quitar nombre autor del modal Info, brand unificado.\n   v3.10: bump versión (v9.72) · ajuste naming DVBA → PBA (SIG Vial PBA).")
], '}')

# App completa: bumpear también por versionado unificado móvil
process('dvba_campo.html', [
    ('bump span app-ver v9.72 -> v9.73',
     "<span id='app-ver'>v9.72</span>",
     "<span id='app-ver'>v9.73</span>"),
], '</html>')

print('\nOK v9.73 aplicado.')
