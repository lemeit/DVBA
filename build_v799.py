#!/usr/bin/env python3
"""v7.99 · Fix FOUC — ocultar por CSS los items solo-gerencia y mostrarlos si corresponde."""
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

# CSS que ocultar por default los items solo-gerencia.
# Se agrega temprano en <head>, dentro de un <style> propio para no meter
# ruido en el CSS principal. Los items empiezan ocultos y solo se muestran
# si aplicarVisibilidadRol() les remueve la clase.
CSS_FIX = '''<style>
/* v7.99 · Fix FOUC · items marcados data-solo-gerencia arrancan ocultos
   por CSS; aplicarVisibilidadRol() los revela solo a gerencia+admin. */
[data-solo-gerencia="1"].role-oculto{display:none !important}
</style>
</head>'''

# ═══════════════════════════════════════════════════════════════
# index.html
# ═══════════════════════════════════════════════════════════════
patches_index = [
    # Inyectar CSS del FOUC antes de </head>
    ('v7.99 CSS FOUC antes de </head>', '</head>', CSS_FIX),

    # Marcar el link con la clase role-oculto (default oculto)
    ('v7.99 add role-oculto al link Reportes',
     '<a class="nav-app rep" data-solo-gerencia="1" href="reportes.html"',
     '<a class="nav-app rep role-oculto" data-solo-gerencia="1" href="reportes.html"'),

    # Cambiar la lógica JS: remover role-oculto para gerencia+admin,
    # agregarla para el resto (por si estaba visible y cambió el rol)
    ('v7.99 toggle role-oculto en JS',
     '''  // v7.98 · Items marcados data-solo-gerencia="1" solo se muestran a gerencia+admin
  // (por ahora aplica al link "Reportes" del header — los técnicos no lo ven).
  const esGerenciaOAdmin = perfil && (perfil.rol === 'admin' || perfil.rol === 'gerencia');
  document.querySelectorAll('[data-solo-gerencia="1"]').forEach(el => {
    el.style.display = esGerenciaOAdmin ? '' : 'none';
  });''',
     '''  // v7.98/v7.99 · Items marcados data-solo-gerencia="1" solo se muestran a
  // gerencia+admin. Toggle de clase .role-oculto (default oculto por CSS,
  // evita flash de contenido no autorizado al cargar la página).
  const esGerenciaOAdmin = perfil && (perfil.rol === 'admin' || perfil.rol === 'gerencia');
  document.querySelectorAll('[data-solo-gerencia="1"]').forEach(el => {
    el.classList.toggle('role-oculto', !esGerenciaOAdmin);
  });'''),

    # Bumps
    ('bump APP_VERSION', "const APP_VERSION = 'v7.98';", "const APP_VERSION = 'v7.99';"),
    ('bump span footer', '<span id="app-ver-footer">v7.98</span>', '<span id="app-ver-footer">v7.99</span>'),
    ('bump span login',  '<span id="login-app-ver">v7.98</span>',  '<span id="login-app-ver">v7.99</span>'),
]
process('index.html', patches_index, '</html>')

# ═══════════════════════════════════════════════════════════════
# partes_diarios.html
# ═══════════════════════════════════════════════════════════════
patches_pd = [
    ('v7.99 CSS FOUC antes de </head>', '</head>', CSS_FIX),

    ('v7.99 add role-oculto al link Reportes',
     '<a class="nav-app rep" data-solo-gerencia="1" href="reportes.html"',
     '<a class="nav-app rep role-oculto" data-solo-gerencia="1" href="reportes.html"'),

    ('v7.99 toggle role-oculto en JS',
     '''      // v7.98 · Items solo-gerencia (link Reportes en el header)
      const esGerenciaOAdmin = perfil.rol === 'admin' || perfil.rol === 'gerencia';
      document.querySelectorAll('[data-solo-gerencia="1"]').forEach(el => {
        el.style.display = esGerenciaOAdmin ? '' : 'none';
      });''',
     '''      // v7.98/v7.99 · Items solo-gerencia (link Reportes en el header) ·
      // toggle role-oculto para evitar el flash al cargar la página.
      const esGerenciaOAdmin = perfil.rol === 'admin' || perfil.rol === 'gerencia';
      document.querySelectorAll('[data-solo-gerencia="1"]').forEach(el => {
        el.classList.toggle('role-oculto', !esGerenciaOAdmin);
      });'''),

    ('bump footer', '<span id="app-ver-footer">v7.98</span>', '<span id="app-ver-footer">v7.99</span>'),
]
process('partes_diarios.html', patches_pd, '</html>')

# ═══════════════════════════════════════════════════════════════
# reportes.html · solo bump
# ═══════════════════════════════════════════════════════════════
patches_rep = [
    ('bump APP_VERSION', "const APP_VERSION = 'v7.98';", "const APP_VERSION = 'v7.99';"),
    ('bump span',        '<span id="app-ver">v7.98</span>', '<span id="app-ver">v7.99</span>'),
]
process('reportes.html', patches_rep, '</html>')

print('\nOK v7.99 aplicado.')
