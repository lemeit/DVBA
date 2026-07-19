#!/usr/bin/env python3
"""v8.0.1 · reportes.html · cargar perfil y mostrar nombre en vez de email."""
import subprocess, os

REPO = '/sessions/eager-tender-faraday/mnt/GitHub--DVBA'

def from_head(name):
    r = subprocess.run(['git','-C',REPO,'show',f'HEAD:{name}'],capture_output=True,text=True)
    if r.returncode: raise SystemExit(f'git show HEAD:{name}: {r.stderr}')
    return r.stdout

def process(name, patches, expected_tail):
    print(f'=== {name} ===')
    html = from_head(name)
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

# reportes.html
patches_rep = [
    # Cargar perfil.js en el head
    ('v8.0.1 cargar perfil.js en head',
     '<script src="datos/auth.js"></script>',
     '<script src="datos/auth.js"></script>\n<script src="datos/perfil.js" defer></script>'),

    # Después del getUser, cargar perfil y mostrar nombre + tooltip
    ('v8.0.1 mostrar nombre en vez de email',
     '''  console.log('[rep] sesión activa:', user.email);
  document.getElementById('email').textContent = user.email;''',
     '''  console.log('[rep] sesión activa:', user.email);
  // v8.0.1 · cargar perfil (rol + zona) y mostrar nombre + tooltip
  try {
    if (typeof DVBA_PERFIL !== 'undefined') await DVBA_PERFIL.cargar(_supa);
  } catch(e){ console.warn('[rep perfil]', e); }
  const perfil = (typeof DVBA_PERFIL !== 'undefined') ? DVBA_PERFIL.get() : null;
  const emailEl = document.getElementById('email');
  if (perfil){
    const corto = ((perfil.nombre || user.email || '?') + '').split('@')[0];
    const rolLbl = perfil.rol === 'admin' ? 'Admin'
                 : perfil.rol === 'gerencia' ? 'Gerencia' : 'Técnico';
    emailEl.textContent = corto;
    emailEl.title = rolLbl + (perfil.zona ? ' · Zona ' + perfil.zona : ' · ve todas las zonas');
  } else {
    emailEl.textContent = user.email;
  }'''),

    # bumps 8.0 -> 8.0.1
    ('bump APP_VERSION', "const APP_VERSION = 'v8.0';", "const APP_VERSION = 'v8.0.1';"),
    ('bump span',        '<span id="app-ver">v8.0</span>', '<span id="app-ver">v8.0.1</span>'),
]
process('reportes.html', patches_rep, '</html>')

# index.html · solo bump
process('index.html', [
    ('bump APP_VERSION', "const APP_VERSION = 'v8.0';", "const APP_VERSION = 'v8.0.1';"),
    ('bump span footer', '<span id="app-ver-footer">v8.0</span>', '<span id="app-ver-footer">v8.0.1</span>'),
    ('bump span login',  '<span id="login-app-ver">v8.0</span>',  '<span id="login-app-ver">v8.0.1</span>'),
], '</html>')

# partes_diarios.html · solo bump
process('partes_diarios.html', [
    ('bump footer', '<span id="app-ver-footer">v8.0</span>', '<span id="app-ver-footer">v8.0.1</span>'),
], '</html>')

print('\nOK v8.0.1 aplicado.')
