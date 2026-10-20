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
   - Los fallos temporales de red conservan la sesión para reintentar.

   Para usar el token en fetch a relevamientos:
     headers: {
       'apikey': SUPA_KEY,
       'Authorization': 'Bearer ' + (await dvbaAuth.token() || SUPA_KEY)
     }
   ══════════════════════════════════════════════════════════════════ */

(function(){
  const SUPA_URL = 'https://txjlfpffyzuhdqtfhlmc.supabase.co';
  const SUPA_KEY = 'sb_publishable_yplmX1jZhT9XAHCkv-CYmA_1fuaLulg';
  const SK = 'dvba_session';     // clave de localStorage
  let renovando = null;

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
    if (!r.ok) {
      const error = new Error('Refresh falló (' + r.status + ')');
      error.status = r.status;
      throw error;
    }
    const data = await r.json();
    // No resucitar una sesión cerrada ni pisar una cuenta abierta mientras
    // llegaba la respuesta de renovación.
    if (leerSesion()?.refresh_token !== refreshToken) return leerSesion();
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

  // Devuelve la sesión vigente, refrescando si está por expirar (<60s).
  // OFFLINE-tolerante: si no hay red, devuelve la sesión local aunque el
  // access_token esté vencido. El refresh se intenta sólo cuando hay red.
  // El refresh_token de Supabase tiene vida larga (típicamente 30 días o
  // configurable hasta 1 año), así que la app sigue funcionando offline
  // por mucho tiempo después del último uso online.
  async function session(){
    const s = leerSesion();
    if (!s || !s.access_token) return null;
    const expira = (s.expires_at || 0) * 1000;
    if (Date.now() < expira - 60000) return s;   // token todavía vigente
    // Token cerca de expirar o expirado:
    //   - si NO hay red → devolver la sesión local (modo offline tolerante)
    //   - si hay red → intentar refresh
    if (typeof navigator !== 'undefined' && navigator.onLine === false) {
      console.log('[auth] sin red, usando sesión local con token vencido');
      return s;
    }
    if (!s.refresh_token) {
      // Sin refresh_token y vencido — pero si está offline, devolvemos igual
      if (typeof navigator !== 'undefined' && !navigator.onLine) return s;
      borrarSesion();
      return null;
    }
    if (renovando) return renovando;
    const renovar = async () => {
      const actual = leerSesion();
      if (!actual?.access_token) return null;
      if (actual.refresh_token !== s.refresh_token || Date.now() < actual.expires_at * 1000 - 60000) return actual;
      try { return await refresh(actual.refresh_token); }
      catch (e) {
        console.warn('[auth] refresh falló:', e.message);
        if (leerSesion()?.refresh_token !== actual.refresh_token) return leerSesion();
        if (e.status === 400 || e.status === 401) { borrarSesion(); return null; }
        // navigator.onLine puede seguir en true aunque la conexión falle.
        // Propagar el fallo temporal sin borrar las credenciales guardadas.
        throw e;
      }
    };
    renovando = (typeof navigator !== 'undefined' && navigator.locks?.request)
      ? navigator.locks.request('dvba-renovar-sesion', renovar) : renovar();
    try { return await renovando; } finally { renovando = null; }
  }

  async function token(){
    const s = await session();
    return s ? s.access_token : null;
  }

  function user(){
    const s = leerSesion();
    return (s && s.user) ? s.user : null;
  }

  // Logueado si hay sesión local con refresh_token (vida larga, días/meses).
  // No exigimos que el access_token esté vigente — eso se renueva on-demand
  // o se respeta como "ok offline" si no hay red.
  function estaLogueado(){
    const s = leerSesion();
    if (!s || !s.access_token) return false;
    return !!s.refresh_token;
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
