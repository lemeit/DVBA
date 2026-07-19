#!/usr/bin/env python3
"""Reconstruye dvba_campo.html y sw.js desde HEAD y aplica los patches v9.69
sin dejar los archivos truncados. cp atomico al final."""
import subprocess, os

REPO = '/sessions/eager-tender-faraday/mnt/GitHub--DVBA'

def from_head(name):
    r = subprocess.run(['git', '-C', REPO, 'show', f'HEAD:{name}'],
                       capture_output=True, text=True)
    if r.returncode:
        raise SystemExit(f'git show HEAD:{name} fallo: {r.stderr}')
    return r.stdout

def process(name, patches, expected_tail):
    print(f'=== {name} ===')
    html = from_head(name)
    orig_len = len(html)
    for pnum, (label, old, new) in enumerate(patches, 1):
        if old not in html:
            raise SystemExit(f'  X patch {pnum} ({label}): patron no encontrado')
        html = html.replace(old, new, 1)
        print(f'  OK patch {pnum}: {label}')
    if not html.rstrip().endswith(expected_tail):
        raise SystemExit(f'  X tail invalido, se esperaba "{expected_tail}"')
    dst_tmp = '/tmp/' + name.replace('/', '_')
    with open(dst_tmp, 'w', encoding='utf-8', newline='\n') as f:
        f.write(html)
    dst_final = os.path.join(REPO, name)
    subprocess.run(['cp', dst_tmp, dst_final], check=True)
    print(f'  -> {orig_len} -> {len(html)} chars  |  cp OK')

# dvba_campo.html · agregar perfil.js + zona en INSERT + bumpear v9.69
process('dvba_campo.html', [
    ('cargar perfil.js en head',
     '<script src="datos/auth.js"></script>',
     '<script src="datos/auth.js"></script>\n<script src="datos/perfil.js" defer></script>'),
    ('zona en reg del INSERT',
     "    prioridad:       'normal',\n    tipo_via:        tipoVia      // ← v9.20 RP o camino secundario\n  };",
     "    prioridad:       'normal',\n    tipo_via:        tipoVia,     // ← v9.20 RP o camino secundario\n    zona:            (typeof DVBA_PERFIL !== 'undefined') ? DVBA_PERFIL.zonaActual() : 'VI'   // v9.69 Fase 2\n  };"),
    ('bump v9.68 -> v9.69',
     "<span id='app-ver'>v9.68</span>",
     "<span id='app-ver'>v9.69</span>"),
], expected_tail='</html>')

# sw.js · agregar perfil.js al cache + bumpear cache name
process('sw.js', [
    ('cache name v9.68 -> v9.69',
     "const CACHE_NAME = 'dvba-campo-v9.68';",
     "const CACHE_NAME = 'dvba-campo-v9.69';"),
    ('perfil.js al cache',
     "  './datos/auth.js',",
     "  './datos/auth.js',\n  './datos/perfil.js',"),
    ('changelog comment',
     "   v3.6: bump versión (lite v9.68 · cerrar sesión desde Info).",
     "   v3.7: bump versión (v9.69) + cachear datos/perfil.js (Fase 2 Roles).\n   v3.6: bump versión (lite v9.68 · cerrar sesión desde Info)."),
], expected_tail='}')

print('\nOK todos los archivos reconstruidos e integros.')
