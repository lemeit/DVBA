#!/usr/bin/env python3
"""v9.69 · Aplica patches a las apps moviles (dvba_campo.html + lite)."""
import os

REPO = '/sessions/eager-tender-faraday/mnt/GitHub--DVBA'

def process(name, patches):
    with open(os.path.join(REPO, name), 'r', encoding='utf-8') as f:
        html = f.read()
    orig_len = len(html)
    for pnum, (label, old, new) in enumerate(patches, 1):
        if old not in html:
            raise SystemExit(f'  X {name} patch {pnum} ({label}): patron no encontrado')
        html = html.replace(old, new, 1)
        print(f'  OK patch {pnum}: {label}')
    dst = '/tmp/' + name
    with open(dst, 'w', encoding='utf-8') as f:
        f.write(html)
    print(f'  -> {dst}  {orig_len} -> {len(html)} chars')
    return dst

# dvba_campo.html
patches_full = [
    ('cargar perfil.js en head',
     '<script src="datos/auth.js"></script>',
     '<script src="datos/auth.js"></script>\n<script src="datos/perfil.js" defer></script>'),
    ('zona en reg antes del INSERT',
     "    prioridad:       'normal',\n    tipo_via:        tipoVia      // ← v9.20 RP o camino secundario\n  };",
     "    prioridad:       'normal',\n    tipo_via:        tipoVia,     // ← v9.20 RP o camino secundario\n    zona:            (typeof DVBA_PERFIL !== 'undefined') ? DVBA_PERFIL.zonaActual() : 'VI'   // v9.69 Fase 2\n  };"),
]
print('=== dvba_campo.html ===')
dst_full = process('dvba_campo.html', patches_full)

# dvba_campo_lite.html
patches_lite = [
    ('cargar perfil.js en head',
     '<script src="datos/auth.js"></script>',
     '<script src="datos/auth.js"></script>\n<script src="datos/perfil.js" defer></script>'),
    ('cargar perfil tras login',
     "console.log('[auth] sesión validada online:', user.email); }",
     "console.log('[auth] sesión validada online:', user.email); }\n      try { if (typeof DVBA_PERFIL !== 'undefined') await DVBA_PERFIL.cargar(_supa); } catch(e){ console.warn('[auth perfil]', e); }"),
    ('zona en INSERT relevamientos',
     "    prioridad: 'normal',\n    tipo_via: 'rp'\n  };",
     "    prioridad: 'normal',\n    tipo_via: 'rp',\n    zona: (typeof DVBA_PERFIL !== 'undefined') ? DVBA_PERFIL.zonaActual() : 'VI'\n  };"),
]
print('\n=== dvba_campo_lite.html ===')
dst_lite = process('dvba_campo_lite.html', patches_lite)

print('\nOK. Copiar:')
print(f'  cp {dst_full}  {REPO}/dvba_campo.html')
print(f'  cp {dst_lite}  {REPO}/dvba_campo_lite.html')
