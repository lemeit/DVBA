/**
 * datos/red_vial.js — Módulo unificado de la red vial DVBA Zona VI
 * v1.0 (2026-06-30)
 *
 * Provee acceso unificado a:
 *   - RUTAS PROVINCIALES (RPs): 15 rutas con bundles rutas_rpXX.js (cadenas, mojones, anchors)
 *   - CAMINOS SECUNDARIOS: ~128 caminos en datos/zona_vi/red_secundaria_zonaVI_final.geojson
 *
 * USO:
 *   await RED_VIAL.init();
 *   RED_VIAL.listarRPs()                        → [{key:'30', label:'RP 30', tipo:'rp', longKm, clase, ...}]
 *   RED_VIAL.listarCaminos()                    → [{key:'034-01', label:'034-01 — Yerbas...', partido:'General Alvear', tipo:'camino', clase, longKm}]
 *   RED_VIAL.getCaminosPorPartido('Saladillo')  → solo los del partido
 *   RED_VIAL.inferTipoVia(rutaStr)              → 'rp' | 'camino' | null
 *   RED_VIAL.getCaminoByKey('034-01')           → feature completo con geometry
 *
 * Cero dependencias externas. 100% offline una vez cacheado el geojson por el SW.
 */

const RED_VIAL = (() => {

  // RPs hardcodeadas (las 15 de Zona VI, las que tienen bundle JS son las "procesadas")
  const RP_LIST = ['6', '20', '24', '30', '40', '41', '42', '43', '44', '46', '47', '48', '51', '61', '91'];

  // Estado interno
  let _caminosGeoJSON = null;
  let _caminosIndex = null;  // Map<nomemclatura, feature>
  let _caminosPorPartido = null;  // Map<partido, [features]>
  let _initPromise = null;

  // ── Inicializar (carga lazy del geojson) ────────────────────────────
  async function init() {
    if (_caminosGeoJSON) return _caminosGeoJSON;
    if (_initPromise) return _initPromise;
    _initPromise = fetch('datos/zona_vi/red_secundaria_zonaVI_final.geojson')
      .then(r => {
        if (!r.ok) throw new Error('HTTP ' + r.status);
        return r.json();
      })
      .then(j => {
        _caminosGeoJSON = j;
        // Indexar para queries rápidas
        _caminosIndex = new Map();
        _caminosPorPartido = new Map();
        for (const f of (j.features || [])) {
          const nom = f.properties.NOMEMCLATURA;
          if (nom) _caminosIndex.set(nom, f);
          const part = f.properties.PARTIDO_NOMBRE;
          if (part) {
            if (!_caminosPorPartido.has(part)) _caminosPorPartido.set(part, []);
            _caminosPorPartido.get(part).push(f);
          }
        }
        console.log('[RedVial] cargados', j.features.length, 'caminos en', _caminosPorPartido.size, 'partidos');
        return j;
      })
      .catch(e => {
        console.warn('[RedVial] no se pudo cargar caminos secundarios:', e);
        _initPromise = null;  // permite reintento
        return null;
      });
    return _initPromise;
  }

  // ── Listar RPs (formato uniforme con caminos) ──────────────────────
  function listarRPs() {
    const out = [];
    for (const k of RP_LIST) {
      // Si tiene bundle (CHAINS_DATA), se incluyen datos extras
      const tieneBundle = (typeof CHAINS_DATA !== 'undefined') && !!CHAINS_DATA[k];
      out.push({
        key: k,
        label: 'RP ' + k,
        tipo: 'rp',
        tieneBundle,
        clase: 'PAVIMENTADO'  // asumido para todas las RPs (la mayoría)
      });
    }
    return out;
  }

  // ── Listar TODOS los caminos secundarios ──────────────────────────
  function listarCaminos() {
    if (!_caminosGeoJSON) return [];
    const out = [];
    for (const f of _caminosGeoJSON.features) {
      const p = f.properties;
      out.push({
        key: p.NOMEMCLATURA,
        label: p.NOMEMCLATURA + (p.DENOMINACION ? ' — ' + p.DENOMINACION : ''),
        denominacion: p.DENOMINACION || '',
        partido: p.PARTIDO_NOMBRE,
        partidoCode: p.PARTIDO,
        tipo: 'camino',
        clase: p.CLASE,
        transitabilidad: p.TRANSITABIlIDAD,  // sic — el campo viene con typo del original
        longKm: p.LONGITUD_KM_WGS84 || p.LONGITUD_KM_ORIG,
      });
    }
    // Ordenar por NOMEMCLATURA
    out.sort((a, b) => String(a.key).localeCompare(String(b.key)));
    return out;
  }

  // ── Caminos filtrados por partido ─────────────────────────────────
  function getCaminosPorPartido(partidoNombre) {
    if (!_caminosPorPartido) return [];
    const feats = _caminosPorPartido.get(partidoNombre) || [];
    return feats.map(f => {
      const p = f.properties;
      return {
        key: p.NOMEMCLATURA,
        label: p.NOMEMCLATURA + (p.DENOMINACION ? ' — ' + p.DENOMINACION : ''),
        denominacion: p.DENOMINACION || '',
        partido: p.PARTIDO_NOMBRE,
        tipo: 'camino',
        clase: p.CLASE,
        longKm: p.LONGITUD_KM_WGS84 || p.LONGITUD_KM_ORIG,
      };
    }).sort((a, b) => String(a.key).localeCompare(String(b.key)));
  }

  // ── Obtener feature completo de un camino (con geometry) ──────────
  function getCaminoByKey(nomemclatura) {
    if (!_caminosIndex) return null;
    return _caminosIndex.get(nomemclatura) || null;
  }

  // ── Inferir tipo_via desde un string de ruta ──────────────────────
  // Heurística:
  //   - "30", "RP 30", "rp30"            → 'rp'
  //   - "034-01", "093-12", "Camino X"   → 'camino'
  //   - "RP 30 km 250"                   → 'rp' (toma el prefijo)
  function inferTipoVia(rutaStr) {
    if (!rutaStr) return null;
    const s = String(rutaStr).trim();
    // Match RP explícito o número solo (1-3 dígitos)
    if (/^RP\s*\d{1,3}/i.test(s)) return 'rp';
    if (/^\d{1,3}$/.test(s)) return 'rp';
    // Match nomenclatura tipo NNN-NN (códigos de caminos secundarios)
    if (/^\d{3}-\d{2,3}$/.test(s)) return 'camino';
    // Si existe en el índice de caminos, es camino
    if (_caminosIndex && _caminosIndex.has(s)) return 'camino';
    // Match palabras tipo "camino" en el nombre
    if (/\bcamino\b/i.test(s)) return 'camino';
    return null;
  }

  // ── Estadísticas rápidas ──────────────────────────────────────────
  function stats() {
    return {
      rpsCargadas: RP_LIST.length,
      rpsConBundle: RP_LIST.filter(k => typeof CHAINS_DATA !== 'undefined' && CHAINS_DATA[k]).length,
      caminos: _caminosGeoJSON ? _caminosGeoJSON.features.length : 0,
      partidosConCaminos: _caminosPorPartido ? _caminosPorPartido.size : 0,
    };
  }

  // Auto-inicializar (silencioso)
  init().catch(() => {});

  return {
    init,
    listarRPs,
    listarCaminos,
    getCaminosPorPartido,
    getCaminoByKey,
    inferTipoVia,
    stats,
    RP_LIST,
  };
})();

if (typeof module !== 'undefined') module.exports = RED_VIAL;
