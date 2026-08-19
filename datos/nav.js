/* ══════════════════════════════════════════════════════════════════
   DVBA · Módulo NAV compartido (v8.79)

   Header + menú contextual + dropdown de usuario, unificado en los 5
   portales del sistema (index, reportes, partes_diarios, admin_usuarios,
   plan_operativo). Filtra las opciones del menú según el rol del user.

   USO desde cualquier HTML del portal:

       <div id="dvba-nav-mount"></div>
       <script src="datos/nav.js"></script>
       <script>
         DVBA_NAV.montar({
           titulo:  'Plan Operativo',          // subtítulo del header
           seccion: 'plan_operativo',          // key para marcar activo
           onLogout: async () => {             // callback opcional
             await _supa.auth.signOut();
             location.href = 'index.html';
           }
         });
       </script>

   Perfil: se lee de localStorage['dvba_perfil'] (poblado por datos/perfil.js
   al login) o se puede pasar explícito con opts.perfil = {rol, zona, nombre}.
   ══════════════════════════════════════════════════════════════════ */
(function(global){
'use strict';

// ── Matriz de secciones por rol ────────────────────────────────────
// Cada sección declara qué roles pueden entrar. Las que el rol actual
// no tenga permitidas, no aparecen en el menú desplegable.
const SECCIONES = [
  {
    key: 'portal',
    label: '🗺 Portal (mapa)',
    href: 'index.html',
    title: 'Mapa principal + relevamientos',
    roles: ['tecnico','capataz','jefe_administrativa','jefe_automotores',
            'jefe_tecnica','jefe_operativa','jefe_zona','gerencia','admin']
  },
  {
    key: 'plan_seguridad',
    label: '🛡️ Plan de Seguridad',
    href: 'partes_diarios.html',
    title: 'Plan de Seguridad en la Circulación · cargar tareas',
    roles: ['tecnico','jefe_tecnica','jefe_operativa','jefe_zona','gerencia','admin']
  },
  {
    key: 'plan_operativo',
    label: '🚜 Plan Operativo',
    href: 'plan_operativo.html',
    title: 'Asignaciones de tareas para capataces',
    roles: ['capataz','jefe_administrativa','jefe_automotores',
            'jefe_tecnica','jefe_operativa','jefe_zona','gerencia','admin']
  },
  {
    key: 'reportes',
    label: '📊 Reportes',
    href: 'reportes.html',
    title: 'Reportes de tareas · dashboard + PDF',
    roles: ['tecnico','jefe_administrativa','jefe_automotores',
            'jefe_tecnica','jefe_operativa','jefe_zona','gerencia','admin']
  },
  {
    key: 'guia',
    label: '📖 Guía',
    href: 'https://lemeit.github.io/DVBA/wiki/',
    target: '_blank',
    title: 'Guía de usuario online (pestaña nueva)',
    roles: ['tecnico','capataz','jefe_administrativa','jefe_automotores',
            'jefe_tecnica','jefe_operativa','jefe_zona','gerencia','admin']
  },
  {
    key: 'admin',
    label: '🛡 Panel Admin',
    href: 'admin_usuarios.html',
    title: 'Gestión de usuarios · solo Admin',
    roles: ['admin'],
    separadorAntes: true
  }
];

// Labels amigables por rol (para mostrar en el dropdown de usuario)
const ROL_LABELS = {
  publico:              'Público',
  tecnico:              '👷 Técnico',
  capataz:              '🧑‍🔧 Capataz',
  jefe_administrativa:  '📋 Jefe Div. Administrativa',
  jefe_automotores:     '🚗 Jefe Div. Automotores',
  jefe_tecnica:         '📐 Jefe Div. Técnica',
  jefe_operativa:       '🚜 Jefe Div. Operativa',
  jefe_zona:            '🧭 Jefe de Zona',
  gerencia:             '🏢 Gerencia',
  admin:                '🛡 Admin'
};

// ── Utils ──────────────────────────────────────────────────────────
function _leerPerfil(perfilExplicito){
  if (perfilExplicito && perfilExplicito.rol) return perfilExplicito;
  try {
    const raw = localStorage.getItem('dvba_perfil');
    if (raw) return JSON.parse(raw);
  } catch(e) { console.warn('[nav] parse perfil', e); }
  return { rol: 'publico', zona: null, nombre: '' };
}

function _leerVersion(){
  if (typeof global.APP_VERSION === 'string' && global.APP_VERSION) return global.APP_VERSION;
  if (typeof global.APP_VER === 'string' && global.APP_VER) return global.APP_VER;
  return 'v?';
}

function esc(s){
  return String(s||'').replace(/[<>&"']/g, c =>
    ({'<':'&lt;','>':'&gt;','&':'&amp;','"':'&quot;',"'":'&#39;'}[c]));
}

// ── CSS inyectado una sola vez ─────────────────────────────────────
function _inyectarCSS(){
  if (document.getElementById('dvba-nav-css')) return;
  const s = document.createElement('style');
  s.id = 'dvba-nav-css';
  s.textContent = `
    #dvba-nav-mount, #dvba-nav-mount *{box-sizing:border-box}
    .dvba-nav-header{background:#00aec3;color:#fff;padding:10px 18px;display:flex;align-items:center;gap:14px;border-bottom:2px solid #007e8c;position:relative;z-index:100;font-family:'Encode Sans','Segoe UI',Arial,sans-serif}
    .dvba-nav-brand{display:flex;align-items:center;gap:10px;flex:1;min-width:0}
    .dvba-nav-brand .logo{width:32px;height:32px;background:#fff;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0}
    .dvba-nav-brand .logo img{width:26px;height:26px;object-fit:contain}
    .dvba-nav-brand .titulo{display:flex;flex-direction:column;line-height:1.15;min-width:0}
    .dvba-nav-brand .app{font-size:14px;font-weight:800;letter-spacing:.3px;color:#fff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .dvba-nav-brand .app sup{color:#ffd060;font-size:.65em;font-weight:700;margin-left:2px}
    .dvba-nav-brand .sub{font-size:11px;color:rgba(255,255,255,.85);font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .dvba-nav-zona{background:rgba(255,255,255,.16);border:1px solid rgba(255,255,255,.28);padding:5px 11px;border-radius:14px;font-size:11px;font-weight:700;color:#fff;letter-spacing:.4px;white-space:nowrap;flex-shrink:0}
    .dvba-nav-btn{background:rgba(255,255,255,.18);border:1px solid rgba(255,255,255,.32);color:#fff;padding:7px 13px;border-radius:6px;font-size:12px;font-weight:700;cursor:pointer;font-family:inherit;display:flex;align-items:center;gap:6px;transition:all .15s;flex-shrink:0}
    .dvba-nav-btn:hover{background:rgba(255,255,255,.3);border-color:rgba(255,255,255,.5)}
    .dvba-nav-btn.open{background:#fff;color:#007e8c;border-color:#fff}
    .dvba-nav-btn .caret{font-size:9px;opacity:.8}
    .dvba-nav-drop{position:absolute;top:calc(100% + 4px);background:#fff;border:1px solid #d0d4dc;border-radius:8px;box-shadow:0 8px 28px rgba(0,0,0,.18);min-width:250px;padding:6px 0;display:none;z-index:200;font-family:'Encode Sans',sans-serif}
    .dvba-nav-drop.on{display:block}
    .dvba-nav-drop.menu-drop{right:18px;left:auto}
    .dvba-nav-drop.user-drop{right:18px}
    .dvba-nav-drop.menu-drop.user-drop{right:18px;left:auto;max-height:calc(100vh - 80px);overflow-y:auto}
    .dvba-nav-drop .head{padding:7px 16px;font-size:10px;font-weight:800;color:#838383;text-transform:uppercase;letter-spacing:.6px;border-bottom:1px solid #e0e0e0;margin-bottom:4px}
    .dvba-nav-drop .item{display:flex;align-items:center;gap:8px;padding:9px 16px;font-size:12.5px;color:#1a2a3a;text-decoration:none;font-weight:600;cursor:pointer;font-family:inherit;background:none;border:0;width:100%;text-align:left;transition:background .12s}
    .dvba-nav-drop .item:hover{background:#e6f7f9;color:#007e8c}
    .dvba-nav-drop .item.active{background:#cae7ea;color:#007e8c;font-weight:800}
    .dvba-nav-drop .item.logout{color:#c25a2a}
    .dvba-nav-drop .item.logout:hover{background:#fdecdc}
    .dvba-nav-drop .sep{border-top:1px solid #e0e0e0;margin:5px 0}
    .dvba-nav-drop .user-info{padding:10px 16px;background:#f7fbfc;border-bottom:1px solid #e0e0e0;margin-bottom:4px}
    .dvba-nav-drop .user-info .nom{font-size:13px;font-weight:800;color:#1a2a3a}
    .dvba-nav-drop .user-info .meta{font-size:11px;color:#838383;font-weight:600;margin-top:2px}
    .dvba-nav-drop .footer-min{padding:6px 16px;font-size:10px;color:#a3b0be;border-top:1px solid #e0e0e0;margin-top:4px;text-align:center}
    @media (max-width: 700px){
      .dvba-nav-header{padding:8px 12px;gap:8px}
      .dvba-nav-brand .app{font-size:12px}
      .dvba-nav-brand .sub{font-size:10px}
      .dvba-nav-btn{padding:6px 9px;font-size:11px}
      .dvba-nav-drop{left:12px;right:12px;min-width:auto}
    }
  `;
  document.head.appendChild(s);
}

// ── Toggle dropdowns + close on outside click ──────────────────────
function _cerrarTodos(){
  document.querySelectorAll('.dvba-nav-drop').forEach(d => d.classList.remove('on'));
  document.querySelectorAll('.dvba-nav-btn').forEach(b => b.classList.remove('open'));
}
function _toggle(dropId, btnId){
  const d = document.getElementById(dropId);
  const b = document.getElementById(btnId);
  const yaAbierto = d.classList.contains('on');
  _cerrarTodos();
  if (!yaAbierto){ d.classList.add('on'); b.classList.add('open'); }
}
document.addEventListener('click', e => {
  if (!e.target.closest('#dvba-nav-mount')) _cerrarTodos();
});

// ── API pública ────────────────────────────────────────────────────
const DVBA_NAV = {
  montar(opts){
    opts = opts || {};
    const perfil = _leerPerfil(opts.perfil);
    const rol = perfil.rol || 'publico';
    // Los roles transversales (admin/gerencia) no tienen zona propia — se muestran
    // como "🌐 Todas" para dejar claro que ven la Provincia entera.
    const esTransversal = (rol === 'gerencia' || rol === 'admin');
    const zona = perfil.zona || (esTransversal ? 'Todas' : '');
    const zonaLabel = esTransversal ? '🌐 Todas las zonas' : ('Zona ' + zona);
    const nombre = perfil.nombre || perfil.email || (rol === 'publico' ? 'Usuario público' : 'Sin nombre');
    const titulo = opts.titulo || '';
    const seccionActiva = opts.seccion || '';
    const onLogout = opts.onLogout || (async () => { location.href = 'index.html'; });

    _inyectarCSS();

    // Filtrar secciones por rol
    const items = SECCIONES.filter(s => s.roles.includes(rol));

    const mount = document.getElementById('dvba-nav-mount');
    if (!mount){ console.warn('[DVBA_NAV] no se encontró <div id="dvba-nav-mount">'); return; }

    const menuHtml = items.map(s => {
      const isActive = s.key === seccionActiva ? ' active' : '';
      const isSep = s.separadorAntes ? '<div class="sep"></div>' : '';
      const target = s.target ? ` target="${s.target}" rel="noopener"` : '';
      return `${isSep}<a href="${esc(s.href)}"${target} title="${esc(s.title||'')}" class="item${isActive}">${s.label}</a>`;
    }).join('');

    // v8.79b · Un solo menú unificado (secciones + usuario + legales + logout)
    // en vez de dos dropdowns separados. Más compacto y sin duplicar legales.
    mount.innerHTML = `
      <header class="dvba-nav-header">
        <div class="dvba-nav-brand">
          <div class="logo"><img src="datos/img/logo_dvba_clean.png" alt="DVBA" onerror="this.style.display='none';this.parentElement.textContent='🛣'"></div>
          <div class="titulo">
            <span class="app">SIG Vial PBA<sup>β</sup></span>
            ${titulo ? `<span class="sub">${esc(titulo)}</span>` : ''}
          </div>
        </div>
        ${opts.zonaControlHtml ? `<span class="dvba-nav-zona" style="padding:0;background:transparent;border:0">${opts.zonaControlHtml}</span>` : (zona ? `<span class="dvba-nav-zona">${esc(zonaLabel)}</span>` : '')}
        ${rol !== 'publico' ? `
          <button id="dvba-nav-menu-btn" class="dvba-nav-btn" onclick="DVBA_NAV.toggleMenu()">☰ ${esc((nombre.split(' ')[0]||nombre).substring(0,14))} <span class="caret">▼</span></button>
        ` : `
          <a href="index.html" class="dvba-nav-btn" style="text-decoration:none">🔐 Iniciar sesión</a>
        `}
        <div id="dvba-nav-menu-drop" class="dvba-nav-drop menu-drop user-drop">
          <div class="user-info">
            <div class="nom">${esc(nombre)}</div>
            <div class="meta">${ROL_LABELS[rol]||rol}${zona?` · ${esc(zonaLabel)}`:''}</div>
          </div>
          <div class="head">Secciones</div>
          ${menuHtml}
          <div class="sep"></div>
          <div class="head">Ayuda e información</div>
          <a href="#" class="item" onclick="event.preventDefault();DVBA_LEGAL&&DVBA_LEGAL.abrir('acerca')">ℹ Acerca del sistema</a>
          <a href="#" class="item" onclick="event.preventDefault();DVBA_LEGAL&&DVBA_LEGAL.abrir('terminos')">📄 Términos de uso</a>
          <a href="#" class="item" onclick="event.preventDefault();DVBA_LEGAL&&DVBA_LEGAL.abrir('privacidad')">🔒 Privacidad</a>
          <div class="sep"></div>
          <button class="item logout" onclick="DVBA_NAV._logout()">🚪 Cerrar sesión</button>
          <div class="footer-min">${esc(_leerVersion())}</div>
        </div>
      </header>
    `;

    // Guardar callback logout
    DVBA_NAV._onLogout = onLogout;
  },
  toggleMenu(){ _toggle('dvba-nav-menu-drop','dvba-nav-menu-btn'); },
  // Alias legacy · si algo llamaba a toggleUser sigue funcionando (mismo menú unificado ahora)
  toggleUser(){ _toggle('dvba-nav-menu-drop','dvba-nav-menu-btn'); },
  async _logout(){
    _cerrarTodos();
    if (typeof DVBA_NAV._onLogout === 'function') await DVBA_NAV._onLogout();
  },
  // Helper para que la app pregunte si un rol tiene acceso a una acción
  puedeAsignarTareas(rol){
    return ['jefe_zona','jefe_operativa','gerencia','admin'].includes(rol);
  },
  puedeIntervenir(rol, zonaRegistro, zonaUser){
    // Gerencia y admin pueden intervenir cualquier zona.
    // Jefes intervienen dentro de su zona (no cross).
    if (rol === 'gerencia' || rol === 'admin') return true;
    return zonaRegistro === zonaUser && ['jefe_zona','jefe_operativa'].includes(rol);
  },
  esCapataz(rol){ return rol === 'capataz'; },
  esGerencia(rol){ return rol === 'gerencia'; },
  ROL_LABELS,
  SECCIONES
};

global.DVBA_NAV = DVBA_NAV;
})(typeof window !== 'undefined' ? window : this);
