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
// Cada sección declara qué roles pueden entrar y a qué grupo pertenece.
// El menú se renderea con headings por grupo. Las secciones que el rol
// actual no tenga permitidas, no aparecen.
const SECCIONES = [
  {
    key: 'portal',
    label: '🗺 Portal (mapa)',
    href: 'index.html',
    title: 'Mapa principal + relevamientos',
    grupo: '', // sin grupo · va arriba de todo
    roles: ['tecnico','capataz','jefe_administrativa','jefe_automotores',
            'jefe_tecnica','jefe_operativa','jefe_zona','gerencia','admin']
  },
  // Grupo PLAN OPERATIVO · dos caras del mismo ciclo (planificación → ejecución)
  {
    key: 'plan_operativo',
    label: '📅 Planificación',
    href: 'plan_operativo.html',
    title: 'Plan Operativo · Bandeja + asignación semanal (planificación)',
    grupo: 'Plan Operativo',
    roles: ['capataz','jefe_administrativa','jefe_automotores',
            'jefe_tecnica','jefe_operativa','jefe_zona','gerencia','admin']
  },
  {
    key: 'plan_seguridad',
    label: '✅ Ejecución',
    href: 'partes_diarios.html',
    title: 'Plan Operativo · Partes diarios de ejecución (Plan de Seguridad en la Circulación)',
    grupo: 'Plan Operativo',
    roles: ['tecnico','jefe_tecnica','jefe_operativa','jefe_zona','gerencia','admin']
  },
  // Grupo ANÁLISIS
  {
    key: 'reportes',
    label: '📊 Informes',
    href: 'reportes.html',
    title: 'Informes institucionales · dashboard + PDF de ejecución',
    grupo: 'Análisis',
    roles: ['tecnico','jefe_administrativa','jefe_automotores',
            'jefe_tecnica','jefe_operativa','jefe_zona','gerencia','admin']
  },
  // Grupo ADMINISTRACIÓN
  {
    key: 'admin',
    label: '🛡 Panel de Usuarios',
    href: 'admin_usuarios.html',
    title: 'Gestión de usuarios · solo Admin',
    grupo: 'Administración',
    roles: ['admin']
  },
  // Grupo AYUDA (al final)
  {
    key: 'guia',
    label: '📖 Guía online',
    href: 'https://lemeit.github.io/DVBA/wiki/',
    target: '_blank',
    title: 'Guía de usuario online (pestaña nueva)',
    grupo: 'Ayuda',
    roles: ['tecnico','capataz','jefe_administrativa','jefe_automotores',
            'jefe_tecnica','jefe_operativa','jefe_zona','gerencia','admin']
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
function _leerPerfilReal(perfilExplicito){
  // Perfil real del user autenticado · del localStorage o del arg explícito
  if (perfilExplicito && perfilExplicito.rol) return perfilExplicito;
  try {
    const raw = localStorage.getItem('dvba_perfil');
    if (raw) return JSON.parse(raw);
  } catch(e) { console.warn('[nav] parse perfil', e); }
  return { rol: 'publico', zona: null, nombre: '' };
}
function _leerPerfilImpersonado(){
  // Perfil que admin/gerencia eligió simular · solo afecta UI, no RLS de Supabase
  try {
    const raw = localStorage.getItem('dvba_perfil_impersonado');
    if (raw) return JSON.parse(raw);
  } catch(e) {}
  return null;
}
function _leerPerfil(perfilExplicito){
  // Perfil EFECTIVO · impersonado si existe, sino real
  const imp = _leerPerfilImpersonado();
  if (imp && imp.rol) return imp;
  return _leerPerfilReal(perfilExplicito);
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
    .dvba-nav-header{background:#00aec3;color:#fff;padding:10px 18px;display:flex;align-items:center;gap:14px;border-bottom:2px solid #007e8c;position:relative;z-index:8000;font-family:'Encode Sans','Segoe UI',Arial,sans-serif}
    .dvba-nav-brand{display:flex;align-items:center;gap:10px;flex:1;min-width:0}
    /* v8.86c · Logo igual al legacy: imagen 38x38 directa, sin contenedor blanco */
    .dvba-nav-brand .logo{width:38px;height:38px;display:flex;align-items:center;justify-content:center;font-size:22px;flex-shrink:0;background:transparent}
    .dvba-nav-brand .logo img{width:38px;height:38px;object-fit:contain}
    .dvba-nav-brand .titulo{display:flex;flex-direction:column;line-height:1.15;min-width:0}
    .dvba-nav-brand .app{font-size:14px;font-weight:800;letter-spacing:.3px;color:#fff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .dvba-nav-brand .app sup{color:#ffd060;font-size:.65em;font-weight:700;margin-left:2px}
    .dvba-nav-brand .sub{font-size:11px;color:rgba(255,255,255,.85);font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    /* v8.86b · Picker estilo LEGACY · "· ZONA VI [Saladillo] ▾" inline junto al título */
    .dvba-nav-brand .app-row{display:flex;align-items:center;gap:8px;flex-wrap:nowrap}
    .dvba-nav-zona-slot{display:inline-flex;align-items:center;gap:5px;flex-shrink:0;position:relative;cursor:pointer;padding:2px 4px}
    .dvba-nav-zona-slot:hover{background:rgba(255,255,255,.06);border-radius:6px}
    .dvba-nav-zona-slot .zona-sep{color:rgba(255,255,255,.55);font-size:13px;font-weight:400;margin-right:2px}
    .dvba-nav-zona-slot .zona-nombre{color:#fff;font-size:13px;font-weight:700;letter-spacing:.4px;white-space:nowrap}
    .dvba-nav-zona-slot .zona-cabecera{background:#ffd060;color:#4a3200;font-size:10px;font-weight:800;padding:2px 8px;border-radius:10px;letter-spacing:.3px;white-space:nowrap;border:1px solid #e6b636}
    .dvba-nav-zona-slot .zona-caret{background:rgba(255,255,255,.15);border:1px solid rgba(255,255,255,.3);color:#fff;font-size:10px;padding:1px 6px;border-radius:4px;font-weight:700;line-height:1.4}
    .dvba-nav-zona-slot select.zona-select-overlay{position:absolute;top:0;left:0;width:100%;height:100%;opacity:0;cursor:pointer;font-size:11px;border:0;padding:0;margin:0}
    .dvba-nav-zona-slot select.zona-select-overlay option{background:#fff;color:#333;font-weight:600;padding:4px}
    .dvba-nav-zona-slot select.zona-select-overlay:focus{outline:none}
    .dvba-nav-btn{background:rgba(255,255,255,.18);border:1px solid rgba(255,255,255,.32);color:#fff;padding:7px 13px;border-radius:6px;font-size:12px;font-weight:700;cursor:pointer;font-family:inherit;display:flex;align-items:center;gap:6px;transition:all .15s;flex-shrink:0}
    .dvba-nav-btn:hover{background:rgba(255,255,255,.3);border-color:rgba(255,255,255,.5)}
    .dvba-nav-btn.open{background:#fff;color:#007e8c;border-color:#fff}
    .dvba-nav-btn .caret{font-size:9px;opacity:.8}
    .dvba-nav-drop{position:absolute;top:calc(100% + 4px);background:#fff;border:1px solid #d0d4dc;border-radius:8px;box-shadow:0 8px 28px rgba(0,0,0,.18);min-width:250px;padding:6px 0;display:none;z-index:8500;font-family:'Encode Sans',sans-serif}
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
    /* v8.80 · Impersonación · admin/gerencia pueden "ver como" otro rol */
    .dvba-nav-imp{padding:8px 16px;background:#fff8dc;border-top:1px solid #f0d090;border-bottom:1px solid #f0d090}
    .dvba-nav-imp .head-imp{font-size:10px;font-weight:800;color:#a56600;text-transform:uppercase;letter-spacing:.5px;margin-bottom:6px}
    .dvba-nav-imp select{width:100%;padding:5px 8px;font-size:11.5px;border:1px solid #d0d4dc;border-radius:4px;background:#fff;font-family:inherit;margin-bottom:5px;color:#333}
    .dvba-nav-imp .imp-btns{display:flex;gap:5px;margin-top:4px}
    .dvba-nav-imp .imp-btns button{flex:1;padding:5px 8px;font-size:10.5px;font-weight:700;border-radius:4px;cursor:pointer;font-family:inherit;border:1px solid #a56600}
    .dvba-nav-imp .imp-btns .btn-apply{background:#a56600;color:#fff}
    .dvba-nav-imp .imp-btns .btn-apply:hover{background:#8a5500}
    .dvba-nav-imp .imp-btns .btn-clear{background:#fff;color:#a56600}
    .dvba-nav-imp .imp-btns .btn-clear:hover{background:#fdecdc}
    #dvba-imp-banner{position:sticky;top:0;background:#ffd060;color:#333;padding:7px 14px;text-align:center;font-size:12px;font-weight:700;z-index:8600;box-shadow:0 2px 4px rgba(0,0,0,.15);font-family:'Encode Sans',sans-serif}
    #dvba-imp-banner b{color:#7a3f00}
    #dvba-imp-banner button{margin-left:12px;padding:3px 11px;background:#333;color:#fff;border:0;border-radius:3px;cursor:pointer;font-weight:700;font-size:11px;font-family:inherit}
    #dvba-imp-banner button:hover{background:#000}
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

    // Filtrar secciones por rol. Para 'publico' mostramos solo Portal + Guía
    // (que sí puede ver sin login) para que el menú no quede vacío.
    let items;
    if (rol === 'publico'){
      items = SECCIONES.filter(s => s.key === 'portal' || s.key === 'guia');
    } else {
      items = SECCIONES.filter(s => s.roles.includes(rol));
    }

    const mount = document.getElementById('dvba-nav-mount');
    if (!mount){ console.warn('[DVBA_NAV] no se encontró <div id="dvba-nav-mount">'); return; }

    // v8.79b · Renderear secciones agrupadas · un heading por grupo.
    // Recorremos ordenadamente y agregamos un <div class="head"> cada vez
    // que cambia el grupo.
    let ultimoGrupo = null;
    const menuHtml = items.map(s => {
      const isActive = s.key === seccionActiva ? ' active' : '';
      const target = s.target ? ` target="${s.target}" rel="noopener"` : '';
      let headHtml = '';
      const grupoActual = s.grupo || '';
      if (grupoActual !== ultimoGrupo){
        if (ultimoGrupo !== null) headHtml += '<div class="sep"></div>';
        if (grupoActual) headHtml += `<div class="head">${esc(grupoActual)}</div>`;
        ultimoGrupo = grupoActual;
      }
      return `${headHtml}<a href="${esc(s.href)}"${target} title="${esc(s.title||'')}" class="item${isActive}">${s.label}</a>`;
    }).join('');

    // v8.79b · Un solo menú unificado (secciones + usuario + legales + logout)
    // en vez de dos dropdowns separados. Más compacto y sin duplicar legales.
    // v8.80 · Impersonación · si el usuario real es admin o gerencia, se le
    // muestra un panel en el menú para "ver como" otro rol/zona. Solo UI:
    // no cambia RLS. Se guarda en localStorage.dvba_perfil_impersonado.
    const perfilReal = _leerPerfilReal(opts.perfil);
    const rolReal = perfilReal.rol;
    const perfilImp = _leerPerfilImpersonado();
    const estaImpersonando = !!perfilImp;
    const puedeImpersonar = rolReal === 'admin' || rolReal === 'gerencia';

    const impersonarPanel = puedeImpersonar ? `
      <div class="dvba-nav-imp">
        <div class="head-imp">👁 Ver como (impersonar)</div>
        <select id="dvba-imp-rol">
          <option value="">— rol —</option>
          <option value="jefe_zona">🧭 Jefe de Zona</option>
          <option value="jefe_operativa">🚜 Jefe Div. Operativa</option>
          <option value="jefe_tecnica">📐 Jefe Div. Técnica</option>
          <option value="jefe_administrativa">📋 Jefe Div. Administrativa</option>
          <option value="jefe_automotores">🚗 Jefe Div. Automotores</option>
          <option value="capataz">🧑‍🔧 Capataz</option>
          <option value="tecnico">👷 Técnico</option>
          <option value="gerencia">🏢 Gerencia (transversal)</option>
        </select>
        <select id="dvba-imp-zona">
          <option value="">— zona —</option>
          <option value="I">I · Arrecifes</option>
          <option value="II">II · Morón</option>
          <option value="III">III · Ensenada</option>
          <option value="IV">IV · Junín</option>
          <option value="V">V · Chivilcoy</option>
          <option value="VI" selected>VI · Saladillo</option>
          <option value="VII">VII · Bragado</option>
          <option value="VIII">VIII · 9 de Julio</option>
          <option value="IX">IX · Olavarría</option>
          <option value="X">X · Azul</option>
          <option value="XI">XI · Necochea</option>
          <option value="XII">XII · Mar del Plata</option>
        </select>
        <div class="imp-btns">
          <button class="btn-apply" onclick="DVBA_NAV._aplicarImpersonacion()">👁 Aplicar</button>
          ${estaImpersonando ? '<button class="btn-clear" onclick="DVBA_NAV.volverAVistaReal()">✕ Volver</button>' : ''}
        </div>
      </div>
    ` : '';

    // v8.86h · Banner "zona ajena" para roles operativos zonales que están viendo
    // una zona distinta a la de su perfil. Solo consulta — la RLS no les permite
    // cargar registros ni ver colas de otras zonas.
    const _rolesZonalesSet = new Set(['tecnico','capataz','jefe_zona','jefe_tecnica','jefe_operativa','jefe_administrativa','jefe_automotores']);
    // Detectar zona activa: window.ZONA_ACTUAL (index) > URL ?zona=X (otros portales) > localStorage
    let _zonaActual = window.ZONA_ACTUAL || '';
    if (!_zonaActual){
      try { _zonaActual = new URLSearchParams(location.search).get('zona') || ''; } catch(_){}
    }
    if (!_zonaActual){
      try { _zonaActual = localStorage.getItem('dvba_zona') || ''; } catch(_){}
    }
    _zonaActual = _zonaActual.toUpperCase();
    const _zonaPerfil = (zona || '').toUpperCase();
    const _mostrarBannerZonaAjena = _rolesZonalesSet.has(rol) && _zonaPerfil && _zonaActual && _zonaActual !== _zonaPerfil && _zonaActual !== 'PBA';
    const bannerZonaAjenaHTML = _mostrarBannerZonaAjena
      ? `<div id="dvba-zonaajena-banner" style="background:#fff8e6;color:#5a3d00;padding:8px 16px;text-align:center;font-size:11.5px;font-weight:600;border-bottom:2px solid #c47a00;font-family:'Encode Sans',sans-serif">ℹ Estás consultando <b>Zona ${esc(_zonaActual)}</b> pero tu perfil es de <b>Zona ${esc(_zonaPerfil)}</b>. Podés navegar y consultar libremente, pero para cargar registros o ver la cola de pendientes, volvé a <b>Zona ${esc(_zonaPerfil)}</b> con el selector del header.</div>`
      : '';

    mount.innerHTML = `
      ${estaImpersonando ? `<div id="dvba-imp-banner">👁 Viendo el sistema como <b>${esc(ROL_LABELS[perfilImp.rol]||perfilImp.rol)}${perfilImp.zona?` · Zona ${esc(perfilImp.zona)}`:''}</b><button onclick="DVBA_NAV.volverAVistaReal()">✕ Volver a vista real</button></div>` : ''}
      ${rol === 'publico' ? `<div id="dvba-publico-banner" style="background:#e6f7f9;color:#00505a;padding:6px 14px;text-align:center;font-size:11.5px;font-weight:600;border-bottom:1px solid #b0dde2;font-family:'Encode Sans',sans-serif">🔓 <b>Vista pública</b> · Mapa y guía disponibles sin sesión. Para acceder al sistema completo, <a href="#" onclick="event.preventDefault();DVBA_NAV._iniciarSesion()" style="color:#007e8c;font-weight:800;text-decoration:underline">iniciar sesión</a>.</div>` : ''}
      ${bannerZonaAjenaHTML}
      <header class="dvba-nav-header">
        <div class="dvba-nav-brand">
          <div class="logo"><img src="datos/img/logo_dvba_clean.png" alt="DVBA" onerror="this.style.display='none';this.parentElement.textContent='🛣'"></div>
          <div class="titulo">
            <div class="app-row">
              <span class="app">SIG Vial PBA<sup>β</sup></span>
              <span class="dvba-nav-zona-slot" id="dvba-nav-zona-slot"></span>
            </div>
            ${titulo ? `<span class="sub">${esc(titulo)}</span>` : ''}
          </div>
        </div>
        ${(['admin','gerencia','jefe_zona','jefe_tecnica','jefe_operativa'].includes(rol)) ? `
          <button id="dvba-nav-cola-btn" class="dvba-nav-btn" title="Registros pendientes de revisión${rol==='gerencia'?' (solo lectura · gerencia interviene por sugerencia)':''}"
                  onclick="(typeof abrirColaPendientes==='function'?abrirColaPendientes():alert('Cola no disponible en este portal'))"
                  style="background:rgba(255,255,255,.16);border:1px solid rgba(255,255,255,.32);color:#fff;padding:5px 10px;border-radius:14px;font-weight:700;cursor:pointer">
            🔔 <span id="cola-count-nav">0</span>${rol==='gerencia'?' <sup style="opacity:.75">solo ver</sup>':''}
          </button>
        ` : ''}
        ${rol !== 'publico' ? `
          <button id="dvba-nav-menu-btn" class="dvba-nav-btn" onclick="DVBA_NAV.toggleMenu()">☰ ${esc((nombre.split(' ')[0]||nombre).substring(0,14))} <span class="caret">▼</span></button>
        ` : `
          <button id="dvba-nav-menu-btn" class="dvba-nav-btn" onclick="DVBA_NAV.toggleMenu()" style="background:rgba(255,255,255,.92);color:#007e8c;border-color:#fff">🔐 Iniciar sesión <span class="caret">▼</span></button>
        `}
        <div id="dvba-nav-menu-drop" class="dvba-nav-drop menu-drop user-drop">
          <div class="user-info">
            <div class="nom">${esc(nombre)}${estaImpersonando?' <span style="color:#a56600;font-size:10px">(impersonado)</span>':''}</div>
            <div class="meta">${ROL_LABELS[rol]||rol}${zona?` · ${esc(zonaLabel)}`:''}</div>
            ${estaImpersonando?`<div class="meta" style="color:#a56600;font-size:10px;margin-top:2px">Real: ${esc(ROL_LABELS[rolReal]||rolReal)}${perfilReal.zona?' · Zona '+esc(perfilReal.zona):''}</div>`:''}
          </div>
          ${impersonarPanel}
          ${rol === 'publico' ? `<button class="item" style="background:#e6f7f9;color:#007e8c;font-weight:800" onclick="DVBA_NAV._iniciarSesion()">🔐 Iniciar sesión</button><div class="sep"></div>` : ''}
          ${menuHtml}
          ${rol !== 'publico' ? `<div class="sep"></div>
          <button class="item logout" onclick="DVBA_NAV._logout()">🚪 Cerrar sesión</button>` : ''}
          <div class="footer-min">${esc(_leerVersion())} · Legales en el footer del portal</div>
        </div>
      </header>
    `;

    // Guardar callback logout
    DVBA_NAV._onLogout = onLogout;

    // v8.82 · Zona-picker: TODOS los roles logueados pueden EXPLORAR otras zonas
    // (la RLS zonal se encarga de bloquear escritura en zonas ajenas). Solo el
    // rol 'publico' ve una etiqueta fija de la zona que está viendo.
    //  - Logueado + hay <select id="zonaPicker"> en el DOM → relocar el picker.
    //  - Logueado sin picker (otros portales sin mapa) → badge estático.
    //  - Publico → badge estático de la zona actual.
    setTimeout(() => {
      const zonaSlot = document.getElementById('dvba-nav-zona-slot');
      if (!zonaSlot) return;
      // v8.86b · Picker estilo LEGACY: "· ZONA VI [Saladillo] ▾" al lado del título.
      // Estructura visual pura + <select> invisible superpuesto que abre el dropdown
      // nativo al hacer clic en cualquier parte del slot.
      zonaSlot.innerHTML = '';
      const zonaHoy = (window.ZONA_ACTUAL || zona || 'PBA').toUpperCase();
      // Cabeceras oficiales · fuente: datos/zonas/CABECERAS.md (Luciano 2026-08-03)
      const ZONAS = [
        { cod:'PBA',  cab:'Todas las zonas' },
        { cod:'I',    cab:'Arrecifes' },
        { cod:'II',   cab:'Morón' },
        { cod:'III',  cab:'Ensenada' },
        { cod:'IV',   cab:'Junín' },
        { cod:'V',    cab:'Chivilcoy' },
        { cod:'VI',   cab:'Saladillo' },
        { cod:'VII',  cab:'Dolores' },
        { cod:'VIII', cab:'Pehuajó' },
        { cod:'IX',   cab:'Azul' },
        { cod:'X',    cab:'Mar del Plata' },
        { cod:'XI',   cab:'Bahía Blanca' },
        { cod:'XII',  cab:'Necochea' }
      ];
      const zActual = ZONAS.find(z => z.cod === zonaHoy) || ZONAS[0];
      // Parte visible
      const sep = document.createElement('span'); sep.className = 'zona-sep'; sep.textContent = '·'; zonaSlot.appendChild(sep);
      const nom = document.createElement('span'); nom.className = 'zona-nombre';
      nom.textContent = zActual.cod === 'PBA' ? 'PBA' : ('ZONA ' + zActual.cod);
      zonaSlot.appendChild(nom);
      const cab = document.createElement('span'); cab.className = 'zona-cabecera'; cab.textContent = zActual.cab; zonaSlot.appendChild(cab);
      const car = document.createElement('span'); car.className = 'zona-caret'; car.textContent = '▾'; zonaSlot.appendChild(car);
      // Select invisible superpuesto
      const sel = document.createElement('select');
      sel.className = 'zona-select-overlay';
      sel.id = 'dvba-nav-zona-select';
      ZONAS.forEach(z => {
        const opt = document.createElement('option');
        opt.value = z.cod;
        opt.textContent = z.cod === 'PBA' ? 'PBA · Todas las zonas' : ('ZONA ' + z.cod + ' · ' + z.cab);
        if (z.cod === zonaHoy) opt.selected = true;
        sel.appendChild(opt);
      });
      sel.addEventListener('change', function(){
        const nueva = this.value;
        if (window.DVBA_ZONA && typeof DVBA_ZONA.cambiar === 'function'){
          DVBA_ZONA.cambiar(nueva);
        } else {
          const url = new URL(location.href);
          url.searchParams.set('zona', nueva);
          location.href = url.toString();
        }
      });
      zonaSlot.appendChild(sel);
      // v8.83 · Al montar el nav, refrescar el badge de cola (el conteo llega
      // asincrónicamente desde Supabase; sin este refresh queda con el valor
      // inicial 0 que había cuando montó el nav).
      if (typeof actualizarBadgeCola === 'function'){
        setTimeout(actualizarBadgeCola, 500);
        setTimeout(actualizarBadgeCola, 1500);
        setTimeout(actualizarBadgeCola, 3000);
      }
    }, 100);
  },
  _iniciarSesion(){
    _cerrarTodos();
    // Intentar detectar y abrir el modal de login del portal donde estemos.
    // Cada portal expone su función global de login con nombre distinto.
    if (typeof abrirLogin === 'function') { abrirLogin(); return; }
    if (typeof mostrarLogin === 'function') { mostrarLogin(); return; }
    // Portal principal (index.html) usa el overlay #login-ov
    const loginOv = document.getElementById('login-ov');
    if (loginOv){ loginOv.style.display = 'flex'; return; }
    // Fallback: ir al portal principal donde sí está el modal de login
    if (!location.pathname.endsWith('/') && !location.pathname.endsWith('/index.html')){
      location.href = 'index.html?login=1';
    } else {
      // Ya estamos en index sin modal detectado · avisar
      alert('El modal de login no se detectó. Recargá la página o llamá a soporte.');
    }
  },
  toggleMenu(){ _toggle('dvba-nav-menu-drop','dvba-nav-menu-btn'); },
  // Alias legacy · si algo llamaba a toggleUser sigue funcionando (mismo menú unificado ahora)
  toggleUser(){ _toggle('dvba-nav-menu-drop','dvba-nav-menu-btn'); },
  async _logout(){
    _cerrarTodos();
    // v8.82 · Al hacer logout limpiamos TODOS los caches para que la próxima
    // sesión no vea la zona/rol/perfil anteriores.
    try { localStorage.removeItem('dvba_perfil_impersonado'); } catch(e){}
    try { localStorage.removeItem('dvba_perfil'); } catch(e){}
    try { localStorage.removeItem('dvba_zona'); } catch(e){}
    try { localStorage.removeItem('dvba_zona_activa'); } catch(e){}
    try { if (window.DVBA_PERFIL && DVBA_PERFIL.limpiar) DVBA_PERFIL.limpiar(); } catch(e){}
    if (typeof DVBA_NAV._onLogout === 'function') await DVBA_NAV._onLogout();
    // Fallback: si el portal no seteó onLogout, forzamos ir al index sin ?zona
    else {
      try {
        const path = location.pathname.replace(/[^/]+$/, '') + 'index.html';
        location.replace(path);
      } catch(e){ location.reload(); }
    }
  },
  // v8.80 · Impersonación (admin/gerencia)
  _aplicarImpersonacion(){
    const rolSel = document.getElementById('dvba-imp-rol');
    const zonaSel = document.getElementById('dvba-imp-zona');
    if (!rolSel || !zonaSel) return;
    const rol = rolSel.value;
    const zona = zonaSel.value;
    if (!rol){ alert('Elegí el rol a impersonar'); return; }
    // Zona no es obligatoria si es gerencia (transversal)
    const esTrans = rol === 'gerencia' || rol === 'admin';
    if (!esTrans && !zona){ alert('Elegí una zona para ese rol'); return; }
    const perfilImp = {
      rol,
      zona: esTrans ? null : zona,
      nombre: '(vista simulada)',
      impersonado: true
    };
    try { localStorage.setItem('dvba_perfil_impersonado', JSON.stringify(perfilImp)); } catch(e){}
    // Recargar la página · lo más simple para que todos los guards + queries relean el perfil
    location.reload();
  },
  volverAVistaReal(){
    try { localStorage.removeItem('dvba_perfil_impersonado'); } catch(e){}
    location.reload();
  },
  // Helper público para que los portales lean el perfil efectivo
  perfilEfectivo(){ return _leerPerfil(); },
  perfilReal(){ return _leerPerfilReal(); },
  estaImpersonando(){ return !!_leerPerfilImpersonado(); },
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
