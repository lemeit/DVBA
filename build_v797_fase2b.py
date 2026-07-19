#!/usr/bin/env python3
"""v7.97 · Fase 2b · header muestra rol+zona + picker zona oculto a técnicos."""
import subprocess, os

REPO = '/sessions/eager-tender-faraday/mnt/GitHub--DVBA'

def from_head(name):
    r = subprocess.run(['git','-C',REPO,'show',f'HEAD:{name}'],capture_output=True,text=True)
    if r.returncode: raise SystemExit(f'git show HEAD:{name} fallo: {r.stderr}')
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

# ═══════════════════════════════════════════════════════════════
# index.html · v7.97
# ═══════════════════════════════════════════════════════════════
patches_index = [
    # Extender aplicarVisibilidadRol para picker de zona + user-info con rol
    ('v7.97 aplicarVisibilidadRol extendido',
     '''// v7.95 · Ocultar panel Visualizacion (Progresivas + Mojones fijos + Modo detallado)
// para usuarios no-admin. En RP47/51/91 el "modo detallado" muestra mojones sinteticos
// en la posicion geografica correcta pero con km oficial equivocado (bug de anchors
// no-monotonicos). Hasta regenerar los bundles en QGIS, solo admin ve esas opciones.
function aplicarVisibilidadRol(){
  const perfil = (typeof DVBA_PERFIL !== 'undefined') ? DVBA_PERFIL.get() : null;
  const esAdmin = perfil && perfil.rol === 'admin';
  const chip  = document.getElementById('vis-chip');
  const panel = document.getElementById('vis-panel');
  if (chip)  chip.style.display  = esAdmin ? '' : 'none';
  if (panel) panel.style.display = esAdmin ? '' : 'none';
}''',
     '''// v7.95/v7.97 · Aplicar visibilidad UI segun rol del user cargado.
//  - Panel Visualizacion (Progresivas/Mojones fijos/Modo detallado):
//    solo admin. En RP47/51/91 el "modo detallado" muestra mojones sinteticos
//    con km oficial equivocado (anchors no-monotonicos). Hasta regenerar bundles
//    en QGIS solo admin ve esas opciones.
//  - Picker de zona en el header: los tecnicos NO cambian de zona (solo la suya).
//    Admin/gerencia/publico pueden explorar cualquier zona.
//  - User-info: mostrar "nombre · rol · Zona X" cuando hay perfil cargado.
function aplicarVisibilidadRol(){
  const perfil = (typeof DVBA_PERFIL !== 'undefined') ? DVBA_PERFIL.get() : null;
  const esAdmin   = perfil && perfil.rol === 'admin';
  const esTecnico = perfil && perfil.rol === 'tecnico';
  // Panel Visualizacion (solo admin)
  const chip  = document.getElementById('vis-chip');
  const panel = document.getElementById('vis-panel');
  if (chip)  chip.style.display  = esAdmin ? '' : 'none';
  if (panel) panel.style.display = esAdmin ? '' : 'none';
  // Picker de zona (tecnicos ocultos; forzamos su zona)
  const picker = document.querySelector('.zona-picker');
  if (picker) picker.style.display = esTecnico ? 'none' : '';
  if (esTecnico && perfil.zona){
    try { aplicarZonaPortal(perfil.zona); } catch(e){}
  }
  // User-info: extender con rol+zona
  if (perfil){
    const emailEl = document.getElementById('user-email');
    if (emailEl){
      const corto = ((perfil.nombre || perfil.user_id || '?') + '').split('@')[0];
      const rolLbl = perfil.rol === 'admin' ? 'Admin'
                   : perfil.rol === 'gerencia' ? 'Gerencia'
                   : 'Técnico';
      emailEl.textContent = corto + ' · ' + rolLbl + ' · Zona ' + (perfil.zona || '—');
      emailEl.title = 'Rol: ' + rolLbl + (perfil.zona ? ' · Zona ' + perfil.zona : '');
    }
  }
}'''),

    # Bumps
    ('bump APP_VERSION', "const APP_VERSION = 'v7.96';", "const APP_VERSION = 'v7.97';"),
    ('bump span footer', '<span id="app-ver-footer">v7.96</span>', '<span id="app-ver-footer">v7.97</span>'),
    ('bump span login',  '<span id="login-app-ver">v7.96</span>',  '<span id="login-app-ver">v7.97</span>'),
]
process('index.html', patches_index, '</html>')

# ═══════════════════════════════════════════════════════════════
# partes_diarios.html · v7.97
# ═══════════════════════════════════════════════════════════════
patches_pd = [
    # Extender el pdInit para mostrar rol+zona junto al email
    ('v7.97 email + rol + zona en header partes',
     '''    if (typeof DVBA_PERFIL !== 'undefined') await DVBA_PERFIL.cargar(_supa);
  } catch(e){ console.warn('[pd] DVBA_PERFIL.cargar falló', e); }
  document.getElementById('authGuard').style.display = 'none';  // v7.65 fix
  document.getElementById('email').textContent = user.email;''',
     '''    if (typeof DVBA_PERFIL !== 'undefined') await DVBA_PERFIL.cargar(_supa);
  } catch(e){ console.warn('[pd] DVBA_PERFIL.cargar falló', e); }
  document.getElementById('authGuard').style.display = 'none';  // v7.65 fix
  // v7.97 · Fase 2b · mostrar nombre + rol + zona en el header
  (function(){
    const perfil = (typeof DVBA_PERFIL !== 'undefined') ? DVBA_PERFIL.get() : null;
    const emailEl = document.getElementById('email');
    if (perfil){
      const corto = ((perfil.nombre || user.email || '?') + '').split('@')[0];
      const rolLbl = perfil.rol === 'admin' ? 'Admin'
                   : perfil.rol === 'gerencia' ? 'Gerencia' : 'Técnico';
      emailEl.textContent = corto + ' · ' + rolLbl + ' · Zona ' + (perfil.zona || '—');
      emailEl.title = 'Rol: ' + rolLbl + (perfil.zona ? ' · Zona ' + perfil.zona : '');
      // Tecnico: forzar su zona activa y ocultar el selector si existe
      if (perfil.rol === 'tecnico' && perfil.zona){
        try { pdSetZona(perfil.zona); } catch(e){}
        const zonaSel = document.getElementById('hSelZona');
        const zonaPicker = document.querySelector('.zona-picker');
        if (zonaPicker) zonaPicker.style.display = 'none';
        else if (zonaSel) zonaSel.style.display = 'none';
      }
    } else {
      emailEl.textContent = user.email;
    }
  })();'''),

    ('bump footer v7.97', '<span id="app-ver-footer">v7.96</span>', '<span id="app-ver-footer">v7.97</span>'),
]
process('partes_diarios.html', patches_pd, '</html>')

# ═══════════════════════════════════════════════════════════════
# reportes.html · v7.97 · solo bump
# ═══════════════════════════════════════════════════════════════
process('reportes.html', [
    ('bump APP_VERSION', "const APP_VERSION = 'v7.96';", "const APP_VERSION = 'v7.97';"),
    ('bump span',        '<span id="app-ver">v7.96</span>', '<span id="app-ver">v7.97</span>'),
], '</html>')

print('\nOK v7.97 aplicado a familia escritorio.')
