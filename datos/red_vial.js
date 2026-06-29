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
  let _caminosIndex = null;       // Map<nomemclatura, feature> — primer feature por key (legacy)
  let _caminosGrupos = null;      // Map<nomemclatura, grupo agrupado> — v1.1 (post agrupación)
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
          if (nom) _caminosIndex.set(nom, f);  // legacy: solo guarda el último
          const part = f.properties.PARTIDO_NOMBRE;
          if (part) {
            if (!_caminosPorPartido.has(part)) _caminosPorPartido.set(part, []);
            _caminosPorPartido.get(part).push(f);
          }
        }
        // v1.1 — pre-agrupar caminos por NOMEMCLATURA (cada camino puede tener varios tramos)
        _caminosGrupos = new Map();
        for (const g of _agruparPorNomenclatura(j.features || [])) {
          _caminosGrupos.set(g.key, g);
        }
        const tramos = j.features.length;
        const caminosUnicos = _caminosGrupos.size;
        console.log('[RedVial] cargados', caminosUnicos, 'caminos únicos (' + tramos + ' tramos) en', _caminosPorPartido.size, 'partidos');
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

  // ── Agrupar features por NOMEMCLATURA ─────────────────────────────
  // Cada camino tiene múltiples tramos en el GeoJSON original. Esta función
  // los agrupa y arma una sola entrada por camino (suma longitudes, concatena
  // denominaciones de tramos únicas).
  function _agruparPorNomenclatura(features) {
    const grupos = new Map();
    for (const f of features) {
      const p = f.properties;
      const k = p.NOMEMCLATURA;
      if (!k) continue;
      if (!grupos.has(k)) {
        grupos.set(k, {
          key: k,
          partido: p.PARTIDO_NOMBRE,
          partidoCode: p.PARTIDO,
          tipo: 'camino',
          clase: p.CLASE,
          longKm: 0,
          tramos: [],
          featuresOrig: [],   // para acceso futuro (geometry, etc.)
        });
      }
      const g = grupos.get(k);
      g.longKm += (p.LONGITUD_KM_WGS84 || p.LONGITUD_KM_ORIG || 0);
      if (p.DENOMINACION) g.tramos.push(p.DENOMINACION);
      g.featuresOrig.push(f);
    }
    // Construir label final — limpio para la app móvil (sin "N tramos")
    const out = [];
    for (const g of grupos.values()) {
      const denomsUnicas = [...new Set(g.tramos.filter(d => d))];
      g.denominacion = denomsUnicas.join(' / ');
      g.longKm = Math.round(g.longKm * 100) / 100;  // 2 decimales
      const kmStr = g.longKm > 0 ? g.longKm.toFixed(1) + ' km' : '';
      if (denomsUnicas.length === 0) {
        // Sin denominación: solo código + km
        g.label = kmStr ? g.key + ' — ' + kmStr : g.key;
      } else if (denomsUnicas.length === 1) {
        // 1 sola denominación: código + denominación + km
        g.label = g.key + ' — ' + denomsUnicas[0] + (kmStr ? ' (' + kmStr + ')' : '');
      } else {
        // Múltiples tramos: solo código + km total (no listar todas las denoms — ruido)
        g.label = kmStr ? g.key + ' — ' + kmStr : g.key;
      }
      out.push(g);
    }
    out.sort((a, b) => String(a.key).localeCompare(String(b.key)));
    return out;
  }

  // ── Listar TODOS los caminos secundarios (agrupados) ──────────────
  function listarCaminos() {
    if (!_caminosGeoJSON) return [];
    return _agruparPorNomenclatura(_caminosGeoJSON.features);
  }

  // ── Caminos filtrados por partido (agrupados) ─────────────────────
  function getCaminosPorPartido(partidoNombre) {
    if (!_caminosPorPartido) return [];
    const feats = _caminosPorPartido.get(partidoNombre) || [];
    return _agruparPorNomenclatura(feats);
  }

  // ── Obtener grupo agrupado de un camino (con todos sus tramos / features) ──
  // Devuelve { key, label, partido, clase, longKm, tramos[], featuresOrig[] }
  function getCaminoByKey(nomemclatura) {
    if (!_caminosGrupos) return null;
    return _caminosGrupos.get(nomemclatura) || null;
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
      caminosUnicos: _caminosGrupos ? _caminosGrupos.size : 0,
      tramosTotales: _caminosGeoJSON ? _caminosGeoJSON.features.length : 0,
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
