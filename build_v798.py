#!/usr/bin/env python3
"""v7.98 · ocultar Reportes a técnicos + footer fijo."""
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

# ═══════════════════════════════════════════════════════════════
# index.html · v7.98
# ═══════════════════════════════════════════════════════════════
patches_index = [
    # Marcar el link Reportes con clase distintiva para ocultarlo
    ('marcar link Reportes con data-role',
     '<a class="nav-app rep" href="reportes.html" title="Reportes de tareas ejecutadas">',
     '<a class="nav-app rep" data-solo-gerencia="1" href="reportes.html" title="Reportes de tareas ejecutadas · solo Gerencia y Admin">'),

    # Ampliar aplicarVisibilidadRol para ocultar los elementos con data-solo-gerencia
    ('v7.98 ocultar Reportes a no-gerencia',
     '''  // User-info: extender con rol+zona
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
}''',
     '''  // User-info: extender con rol+zona
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
  // v7.98 · Items marcados data-solo-gerencia="1" solo se muestran a gerencia+admin
  // (por ahora aplica al link "Reportes" del header — los técnicos no lo ven).
  const esGerenciaOAdmin = perfil && (perfil.rol === 'admin' || perfil.rol === 'gerencia');
  document.querySelectorAll('[data-solo-gerencia="1"]').forEach(el => {
    el.style.display = esGerenciaOAdmin ? '' : 'none';
  });
}'''),

    # Bumps
    ('bump APP_VERSION', "const APP_VERSION = 'v7.97';", "const APP_VERSION = 'v7.98';"),
    ('bump span footer', '<span id="app-ver-footer">v7.97</span>', '<span id="app-ver-footer">v7.98</span>'),
    ('bump span login',  '<span id="login-app-ver">v7.97</span>',  '<span id="login-app-ver">v7.98</span>'),
]
process('index.html', patches_index, '</html>')

# ═══════════════════════════════════════════════════════════════
# partes_diarios.html · v7.98
# ═══════════════════════════════════════════════════════════════
patches_pd = [
    # Marcar link Reportes con data-solo-gerencia
    ('marcar link Reportes',
     '<a class="nav-app rep" href="reportes.html" title="Reportes de tareas ejecutadas">📊 Reportes</a>',
     '<a class="nav-app rep" data-solo-gerencia="1" href="reportes.html" title="Reportes · solo Gerencia y Admin">📊 Reportes</a>'),

    # Ocultar el link a técnicos dentro del bloque "email + rol + zona"
    ('v7.98 ocultar Reportes en partes',
     '''      // Tecnico: forzar su zona activa y ocultar el selector si existe
      if (perfil.rol === 'tecnico' && perfil.zona){
        try { pdSetZona(perfil.zona); } catch(e){}
        const zonaSel = document.getElementById('hSelZona');
        const zonaPicker = document.querySelector('.zona-picker');
        if (zonaPicker) zonaPicker.style.display = 'none';
        else if (zonaSel) zonaSel.style.display = 'none';
      }''',
     '''      // Tecnico: forzar su zona activa y ocultar el selector si existe
      if (perfil.rol === 'tecnico' && perfil.zona){
        try { pdSetZona(perfil.zona); } catch(e){}
        const zonaSel = document.getElementById('hSelZona');
        const zonaPicker = document.querySelector('.zona-picker');
        if (zonaPicker) zonaPicker.style.display = 'none';
        else if (zonaSel) zonaSel.style.display = 'none';
      }
      // v7.98 · Items solo-gerencia (link Reportes en el header)
      const esGerenciaOAdmin = perfil.rol === 'admin' || perfil.rol === 'gerencia';
      document.querySelectorAll('[data-solo-gerencia="1"]').forEach(el => {
        el.style.display = esGerenciaOAdmin ? '' : 'none';
      });'''),

    # Footer fijo · agregar position:fixed al footer inline
    ('v7.98 footer fixed en partes',
     '<footer id="footerInst" style="background:#1f2732;color:rgba(255,255,255,.7);padding:7px 16px;font-size:10px;line-height:1.4;display:none;flex-wrap:wrap;gap:10px;align-items:center;justify-content:space-between;border-top:1px solid var(--pd)">',
     '<footer id="footerInst" style="background:#1f2732;color:rgba(255,255,255,.7);padding:7px 16px;font-size:10px;line-height:1.4;display:none;flex-wrap:wrap;gap:10px;align-items:center;justify-content:space-between;border-top:1px solid var(--pd);position:fixed;bottom:0;left:0;right:0;z-index:80">'),

    # Padding-bottom al body para que el contenido no quede tapado por el footer fijo
    ('v7.98 padding-bottom body',
     "body{display:flex;flex-direction:column}",
     "body{display:flex;flex-direction:column;padding-bottom:36px} /* v7.98 · reserva espacio para footer fijo */"),

    ('bump footer', '<span id="app-ver-footer">v7.97</span>', '<span id="app-ver-footer">v7.98</span>'),
]
process('partes_diarios.html', patches_pd, '</html>')

# ═══════════════════════════════════════════════════════════════
# reportes.html · v7.98 · footer fijo + bump
# ═══════════════════════════════════════════════════════════════
patches_rep = [
    ('v7.98 footer fixed en reportes CSS',
     'footer{background:#1f2732;color:rgba(255,255,255,.7);padding:7px 16px;font-size:10px;line-height:1.4;display:none;flex-wrap:wrap;gap:10px;align-items:center;justify-content:space-between;border-top:1px solid var(--pd)}',
     'footer{background:#1f2732;color:rgba(255,255,255,.7);padding:7px 16px;font-size:10px;line-height:1.4;display:none;flex-wrap:wrap;gap:10px;align-items:center;justify-content:space-between;border-top:1px solid var(--pd);position:fixed;bottom:0;left:0;right:0;z-index:80} /* v7.98 · footer fijo al fondo del viewport */'),

    ('v7.98 padding-bottom body reportes',
     "body{display:flex;flex-direction:column}",
     "body{display:flex;flex-direction:column;padding-bottom:36px} /* v7.98 · reserva espacio para footer fijo */"),

    ('bump APP_VERSION', "const APP_VERSION = 'v7.97';", "const APP_VERSION = 'v7.98';"),
    ('bump span',        '<span id="app-ver">v7.97</span>', '<span id="app-ver">v7.98</span>'),
]
process('reportes.html', patches_rep, '</html>')

print('\nOK v7.98 aplicado.')
