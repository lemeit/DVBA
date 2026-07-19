/* ══════════════════════════════════════════════════════════════════
   DVBA · Perfil de usuario (Fase 2 Roles Multi-zona · v7.93)

   Módulo compartido para cargar el registro de `usuarios_perfil` al
   login y cachearlo en localStorage. Expone helpers para leer rol/zona
   desde cualquier parte del código sin volver a pegarle a la BD.

   Uso típico (después del login exitoso):

       await DVBA_PERFIL.cargar(_supa);
       const perfil = DVBA_PERFIL.get();
       // { user_id, nombre, rol, zona, activo }

       // En un INSERT:
       await _supa.from('relevamientos').insert({
         ...datos,
         zona: DVBA_PERFIL.zonaActual()
       });

   El módulo es tolerante a errores: si el perfil no existe todavía
   (usuario nuevo sin fila en usuarios_perfil), zonaActual() cae a
   'VI' por default (compat con el sistema pre-multi-zona).

   Depende únicamente del cliente Supabase pasado por argumento —
   funciona en las 4 apps sin código repetido.
   ══════════════════════════════════════════════════════════════════ */
(function(global){
'use strict';

const STORAGE_KEY = 'dvba_perfil';
const ZONA_DEFAULT = 'VI';  // Zona operativa histórica hasta que llegue multi-zona real

let _perfilCache = null;    // { user_id, nombre, rol, zona, activo }
let _cargando = null;       // Promise mientras está en vuelo

// Cargar perfil desde Supabase para el user logueado. Cachea en memoria +
// localStorage. Si ya se cargó en esta sesión, devuelve el cache sin red.
async function cargar(supa, opts){
  opts = opts || {};
  const force = !!opts.force;

  if (!force && _perfilCache) return _perfilCache;
  if (!force && _cargando)    return _cargando;

  _cargando = (async () => {
    try {
      // 1) Obtener user actual
      const { data: { user }, error: uErr } = await supa.auth.getUser();
      if (uErr || !user){
        console.warn('[perfil] no hay user autenticado');
        _perfilCache = null;
        _persistir(null);
        return null;
      }

      // 2) SELECT sobre usuarios_perfil (RLS permite self-read)
      const { data, error } = await supa
        .from('usuarios_perfil')
        .select('user_id, nombre, rol, zona, activo')
        .eq('user_id', user.id)
        .maybeSingle();

      if (error){
        console.warn('[perfil] error al leer usuarios_perfil:', error.message);
        // Fallback: si la tabla no existe todavía o RLS falla, seguimos con default
        _perfilCache = _fallback(user);
      } else if (!data){
        console.warn('[perfil] user autenticado sin fila en usuarios_perfil, usando fallback');
        _perfilCache = _fallback(user);
      } else {
        _perfilCache = data;
      }

      _persistir(_perfilCache);
      return _perfilCache;
    } catch(e){
      console.error('[perfil] excepción al cargar:', e);
      _perfilCache = _perfilCache || _hydrate();  // último cache válido si lo hay
      return _perfilCache;
    } finally {
      _cargando = null;
    }
  })();

  return _cargando;
}

// Perfil por defecto cuando falta la fila real (compat migración)
function _fallback(user){
  return {
    user_id: user.id,
    nombre:  user.email || '(sin nombre)',
    rol:     'tecnico',
    zona:    ZONA_DEFAULT,
    activo:  true,
    _fallback: true
  };
}

// Hidratar desde localStorage al arranque (para no depender de red inmediata)
function _hydrate(){
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch(e){ return null; }
}

function _persistir(perfil){
  try {
    if (perfil) localStorage.setItem(STORAGE_KEY, JSON.stringify(perfil));
    else        localStorage.removeItem(STORAGE_KEY);
  } catch(e){ /* localStorage lleno o denegado, ignoramos */ }
}

// Cache al arranque
_perfilCache = _hydrate();

// ─── API pública ───────────────────────────────────────────────────
function get(){ return _perfilCache; }
function rol(){ return _perfilCache ? _perfilCache.rol : null; }
function zona(){ return _perfilCache ? _perfilCache.zona : null; }

// Zona a usar en INSERTs. Cadena de fallbacks:
//   1) Perfil cargado (usuarios_perfil.zona)
//   2) Zona activa del selector del header (localStorage['dvba_zona'])
//   3) Default 'VI' (compat pre-multi-zona)
function zonaActual(){
  const z = zona();
  if (z) return z;
  try {
    const zSel = localStorage.getItem('dvba_zona');
    if (zSel) return zSel;
  } catch(e){}
  return ZONA_DEFAULT;
}

// True si el user es 'gerencia' o 'admin' (ve todas las zonas)
function esGerenciaOAdmin(){
  const r = rol();
  return r === 'gerencia' || r === 'admin';
}

// Limpiar cache al logout
function limpiar(){
  _perfilCache = null;
  _persistir(null);
}

global.DVBA_PERFIL = {
  cargar,
  get,
  rol,
  zona,
  zonaActual,
  esGerenciaOAdmin,
  limpiar,
  ZONA_DEFAULT
};
})(window);
