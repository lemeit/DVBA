/* ══════════════════════════════════════════════════════════════════
   datos/auth.js — Módulo compartido de autenticación Supabase
   Usado por dvba_campo.html (PWA móvil) e index.html (escritorio)

   Provee:
     window.dvbaAuth.login(email, password) → bool
     window.dvbaAuth.logout()
     window.dvbaAuth.session() → object|null   (refresca si expiró)
     window.dvbaAuth.token() → string|null     (access_token actual)
     window.dvbaAuth.user() → object|null      (email, id, etc.)
     window.dvbaAuth.estaLogueado() → bool

   Estrategia:
   - Login estándar Supabase Auth (email + password).
   - Sesión guardada en localStorage bajo 'dvba_session'.
   - Auto-refresh con refresh_token cuando access_token está por expirar.
   - Si refresh falla, se borra la sesión local y session() devuelve null.

   Para usar el token en fetch a relevamientos:
     headers: {
       'apikey': SUPA_KEY,
       'Authorization': 'Bearer ' + (await dvbaAuth.token() || SUPA_KEY)
     }
   ══════════════════════════════════════════════════════════════════ */

(function(){
  const SUPA_URL = 'https://txjlfpffyzuhdqtfhlmc.supabase.co';
  const SUPA_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4amxmcGZmeXp1aGRxdGZobG1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI1NDY5ODQsImV4cCI6MjA4ODEyMjk4NH0.LEqkMHh_t4TUb-2rKOlGmZmKTAw9mRrfL63UxK7LGNc';
  const SK = 'dvba_session';     // clave de localStorage

  function leerSesion(){
    try { return JSON.parse(localStorage.getItem(SK) || 'null'); }
    catch { return null; }
  }
  function guardarSesion(s){
    // Supabase devuelve expires_in (segundos). Calculamos expires_at absoluto.
    if (s && s.expires_in && !s.expires_at) {
      s.expires_at = Math.floor(Date.now()/1000) + parseInt(s.expires_in);
    }
    localStorage.setItem(SK, JSON.stringify(s));
  }
  function borrarSesion(){
    localStorage.removeItem(SK);
  }

  async function login(email, password){
    const r = await fetch(SUPA_URL + '/auth/v1/token?grant_type=password', {
      method: 'POST',
      headers: { 'apikey': SUPA_KEY, 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: (email||'').trim(), password: password||'' })
    });
    if (!r.ok) {
      const txt = await r.text();
      let msg = 'Credenciales inválidas';
      try { const j = JSON.parse(txt); msg = j.error_description || j.msg || msg; } catch {}
      throw new Error(msg);
    }
    const data = await r.json();
    guardarSesion(data);
    return data;
  }

  async function refresh(refreshToken){
    const r = await fetch(SUPA_URL + '/auth/v1/token?grant_type=refresh_token', {
      method: 'POST',
      headers: { 'apikey': SUPA_KEY, 'Content-Type': 'application/json' },
      body: JSON.stringify({ refresh_token: refreshToken })
    });
    if (!r.ok) throw new Error('Refresh falló (' + r.status + ')');
    const data = await r.json();
    guardarSesion(data);
    return data;
  }

  async function logout(){
    const s = leerSesion();
    if (s && s.access_token) {
      try {
        await fetch(SUPA_URL + '/auth/v1/logout', {
          method: 'POST',
          headers: {
            'apikey': SUPA_KEY,
            'Authorization': 'Bearer ' + s.access_token,
            'Content-Type': 'application/json'
          }
        });
      } catch {}
    }
    borrarSesion();
  }

  // Devuelve la sesión vigente, refrescando si está por expirar (<60s)
  async function session(){
    const s = leerSesion();
    if (!s || !s.access_token) return null;
    const expira = (s.expires_at || 0) * 1000;
    if (Date.now() < expira - 60000) return s;
    // Está cerca de expirar o expirado: intentar refresh
    if (!s.refresh_token) { borrarSesion(); return null; }
    try {
      const nuevo = await refresh(s.refresh_token);
      return nuevo;
    } catch (e) {
      console.warn('[auth] refresh falló:', e.message);
      borrarSesion();
      return null;
    }
  }

  async function token(){
    const s = await session();
    return s ? s.access_token : null;
  }

  function user(){
    const s = leerSesion();
    return (s && s.user) ? s.user : null;
  }

  function estaLogueado(){
    const s = leerSesion();
    if (!s || !s.access_token) return false;
    const expira = (s.expires_at || 0) * 1000;
    // Considerar logueado si tiene refresh_token aunque access esté vencido
    return !!s.refresh_token || Date.now() < expira;
  }

  // Wrapper para fetch con auth automático (refresca si hace falta)
  async function fetchAuth(url, options){
    options = options || {};
    const t = await token();
    if (!t) throw new Error('No hay sesión activa');
    options.headers = Object.assign({}, options.headers || {}, {
      'apikey': SUPA_KEY,
      'Authorization': 'Bearer ' + t
    });
    const r = await fetch(url, options);
    if (r.status === 401) {
      borrarSesion();
      throw new Error('Sesión expirada — volvé a iniciar sesión');
    }
    return r;
  }

  // Exponer
  window.dvbaAuth = {
    SUPA_URL, SUPA_KEY,
    login, logout, session, token, user, estaLogueado, fetchAuth
  };

  // Log inicial para debugging
  const u = user();
  if (u) console.log('[auth] sesión activa:', u.email);
  else   console.log('[auth] sin sesión');
})();
