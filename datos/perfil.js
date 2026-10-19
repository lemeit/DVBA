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

   Si falta el perfil o no se puede verificar, no se inventan rol,
   habilitación ni zona. El servidor conserva la autoridad de permisos.

   Depende únicamente del cliente Supabase pasado por argumento —
   funciona en las 4 apps sin código repetido.
   ══════════════════════════════════════════════════════════════════ */
(function(global){
'use strict';

const STORAGE_KEY = 'dvba_perfil';
const ZONA_DEFAULT = 'VI';  // Zona operativa histórica hasta que llegue multi-zona real

let _perfilCache = null;    // { user_id, nombre, rol, zona, activo }
// Cada carga verifica identidad y perfil; la caché se usa solo para presentar la UI.

// Verificar la cuenta actual y cargar su perfil real desde el servidor.
let _generacion = 0;
async function cargar(supa, opts){
  const generacion=++_generacion;
  try {
    const {data: identidad,error: errorUsuario}=await supa.auth.getUser();
    if(errorUsuario || !identidad?.user)throw errorUsuario || new Error('Sin usuario autenticado');
    const {data,error}=await supa.from('usuarios_perfil').select('*').eq('user_id',identidad.user.id).maybeSingle();
    if(error)throw error;
    if(generacion!==_generacion)return null;
    if(!data || data.user_id!==identidad.user.id || data.activo!==true){
      _perfilCache=null;_persistir(null);return null;
    }
    _perfilCache=data;_persistir(data);return data;
  }catch(e){
    console.warn('[perfil] no se pudo verificar el perfil activo');
    if(generacion===_generacion){_perfilCache=null;_persistir(null);}
    return null;
  }
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

// Cache al arranque · v7.96: si NO hay sesion activa (dvba_session vacio),
// descartamos cualquier perfil huerfano — pasa cuando el user cerro sesion
// desde otra pestaña o el logout no limpio el cache.
_perfilCache = _hydrate();
try {
  const sesion=JSON.parse(localStorage.getItem('dvba_session')||'null');
  const actual=(sesion?.session||sesion)?.user?.id;
  if (_perfilCache && (!actual || _perfilCache.user_id!==actual || _perfilCache.activo!==true || _perfilCache._fallback)){
    console.log('[perfil] hay perfil cacheado pero no sesion — limpiando');
    _perfilCache = null;
    _persistir(null);
  }
} catch(e){}

// ─── API pública ───────────────────────────────────────────────────
function get(){ return _perfilCache; }
function rol(){ return _perfilCache ? _perfilCache.rol : null; }
function zona(){ return _perfilCache ? _perfilCache.zona : null; }

// Zona a usar en INSERTs. Cadena de fallbacks:
//   1) Perfil cargado (usuarios_perfil.zona)
//   2) Zona activa del selector del header (localStorage['dvba_zona'])
//   3) Default 'VI' (compat pre-multi-zona)
function zonaActual(){
  if(!_perfilCache || !_perfilCache.activo || _perfilCache.area_codigo==='ambiente')return null;
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
  _generacion++;
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
