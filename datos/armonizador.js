/**
 * datos/armonizador.js — Armonización geoespacial de registros vs GPS
 * DVBA · Zona Departamental VI Saladillo · v1.0 (2026-06-30)
 *
 * Compara los datos cargados por el operador (ruta, partido, progresiva)
 * con lo que se infiere desde las coordenadas GPS y la cartografía local.
 *
 * 100% OFFLINE: no requiere conexión.
 *   - partidos_zona_vi.geojson  (~41 KB, cacheado por SW)
 *   - CHAINS_DATA, ANCHORS_DATA, MOJONES_DATA (de los bundles rutas_rpXX.js)
 *
 * USO:
 *   await ARMONIZADOR.init();                  // carga lazy del geojson
 *   const r = ARMONIZADOR.armonizar({
 *     lat: -35.638, lng: -59.776, gpsAcc: 12,
 *     ruta: '51', partido: 'Saladillo', prog: '287'
 *   });
 *   // r = { cambios:[...], consistentes:[...], severidad:'media', ... }
 */

const ARMONIZADOR = (() => {

  // ── Estado interno ────────────────────────────────────────────────
  let _partidosGeoJSON = null;
  let _initPromise = null;

  // ── Constantes geográficas ────────────────────────────────────────
  const R_EARTH = 6371000; // metros
  const DEG2RAD = Math.PI / 180;

  // ── Utilidades de geometría ───────────────────────────────────────

  // Distancia Haversine en metros (precisión global)
  function haversineM(lat1, lng1, lat2, lng2) {
    const f1 = lat1 * DEG2RAD, f2 = lat2 * DEG2RAD;
    const df = (lat2 - lat1) * DEG2RAD;
    const dl = (lng2 - lng1) * DEG2RAD;
    const a = Math.sin(df/2)**2 + Math.cos(f1)*Math.cos(f2)*Math.sin(dl/2)**2;
    return R_EARTH * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  }

  // Proyección equirectangular local — escala metros/grado a la latitud de referencia
  function _localScale(latRef) {
    return {
      mPerLng: R_EARTH * Math.cos(latRef * DEG2RAD) * DEG2RAD,
      mPerLat: R_EARTH * DEG2RAD
    };
  }

  // Distancia de punto a segmento + proyección. Devuelve {distM, projLat, projLng, t∈[0,1]}
  function distPuntoASegmento(lat, lng, lat1, lng1, lat2, lng2) {
    const { mPerLng, mPerLat } = _localScale(lat);
    const x  = lng  * mPerLng,  y  = lat  * mPerLat;
    const x1 = lng1 * mPerLng,  y1 = lat1 * mPerLat;
    const x2 = lng2 * mPerLng,  y2 = lat2 * mPerLat;
    const dx = x2 - x1, dy = y2 - y1;
    const lenSq = dx*dx + dy*dy;
    if (lenSq === 0) {
      return { distM: Math.hypot(x-x1, y-y1), projLat: lat1, projLng: lng1, t: 0 };
    }
    let t = ((x - x1)*dx + (y - y1)*dy) / lenSq;
    t = Math.max(0, Math.min(1, t));
    const px = x1 + t*dx, py = y1 + t*dy;
    return {
      distM: Math.hypot(x - px, y - py),
      projLat: py / mPerLat,
      projLng: px / mPerLng,
      t
    };
  }

  // Point-in-polygon (ray casting). polygon = array de [lng,lat]
  function _pointInRing(lng, lat, ring) {
    let inside = false;
    for (let i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      const xi = ring[i][0], yi = ring[i][1];
      const xj = ring[j][0], yj = ring[j][1];
      const intersect = ((yi > lat) !== (yj > lat))
        && (lng < (xj - xi) * (lat - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  // Point-in-MultiPolygon (con holes)
  function _pointInMultiPolygon(lng, lat, multiPoly) {
    for (const poly of multiPoly) {
      // poly[0] = outer ring, poly[1+] = holes
      if (_pointInRing(lng, lat, poly[0])) {
        let inHole = false;
        for (let i = 1; i < poly.length; i++) {
          if (_pointInRing(lng, lat, poly[i])) { inHole = true; break; }
        }
        if (!inHole) return true;
      }
    }
    return false;
  }

  // Distancia mínima de un punto a un MultiPolygon (en metros)
  // Solo se llama cuando el punto NO está dentro — para detectar "borde"
  function _distAlBordeMultiPoly(lat, lng, multiPoly) {
    let minDist = Infinity;
    for (const poly of multiPoly) {
      for (const ring of poly) {
        for (let i = 0; i < ring.length - 1; i++) {
          const r = distPuntoASegmento(lat, lng, ring[i][1], ring[i][0], ring[i+1][1], ring[i+1][0]);
          if (r.distM < minDist) minDist = r.distM;
        }
      }
    }
    return minDist;
  }

  // ── Umbrales adaptativos según precisión GPS (en metros) ──────────
  function umbralRuta(gpsAcc)        { return Math.max(50,  (gpsAcc || 10) * 2); }
  function umbralProgresiva(gpsAcc)  { return Math.max(80,  (gpsAcc || 10) * 3); }
  function umbralPartidoLim(gpsAcc)  { return Math.max(30,  (gpsAcc || 10) * 2); }

  // ── Inicialización (carga lazy del geojson de partidos) ──────────
  async function init() {
    if (_partidosGeoJSON) return _partidosGeoJSON;
    if (_initPromise) return _initPromise;
    _initPromise = fetch('datos/partidos_zona_vi.geojson')
      .then(r => {
        if (!r.ok) throw new Error('HTTP ' + r.status);
        return r.json();
      })
      .then(j => { _partidosGeoJSON = j; return j; })
      .catch(e => {
        console.warn('[Armonizador] no se pudo cargar partidos_zona_vi.geojson:', e);
        _initPromise = null;  // permite reintento
        return null;
      });
    return _initPromise;
  }

  // ── 1. Detectar partido por point-in-polygon ─────────────────────
  function detectarPartido(lat, lng) {
    if (!_partidosGeoJSON) return null;
    for (const feat of _partidosGeoJSON.features) {
      const geom = feat.geometry;
      const nombre = feat.properties.partido || feat.properties.NAM || feat.properties.name;
      if (!geom || !nombre) continue;
      if (geom.type === 'MultiPolygon' && _pointInMultiPolygon(lng, lat, geom.coordinates)) {
        return nombre;
      }
      if (geom.type === 'Polygon' && _pointInRing(lng, lat, geom.coordinates[0])) {
        // verificar holes
        let inHole = false;
        for (let i = 1; i < geom.coordinates.length; i++) {
          if (_pointInRing(lng, lat, geom.coordinates[i])) { inHole = true; break; }
        }
        if (!inHole) return nombre;
      }
    }
    return null;
  }

  // Cuán cerca está la coordenada del límite del partido detectado (metros)
  function distAlLimitePartido(lat, lng, nombrePartido) {
    if (!_partidosGeoJSON || !nombrePartido) return Infinity;
    for (const feat of _partidosGeoJSON.features) {
      const nom = feat.properties.partido || feat.properties.NAM;
      if (nom !== nombrePartido) continue;
      const geom = feat.geometry;
      if (geom.type === 'MultiPolygon') return _distAlBordeMultiPoly(lat, lng, geom.coordinates);
      if (geom.type === 'Polygon')      return _distAlBordeMultiPoly(lat, lng, [geom.coordinates]);
    }
    return Infinity;
  }

  // ── 2. Ruta más cercana ──────────────────────────────────────────
  // Recorre todas las CHAINS_DATA y devuelve la que tenga la mínima dist
  function rutaMasCercana(lat, lng, radioMaxM = 500) {
    if (typeof CHAINS_DATA === 'undefined') return null;
    let mejor = { ruta: null, distM: Infinity, progKm: null };
    for (const rutaKey of Object.keys(CHAINS_DATA)) {
      const r = progresivaEnRuta(lat, lng, rutaKey);
      if (r && r.distM < mejor.distM) {
        mejor = { ruta: rutaKey, distM: r.distM, progKm: r.progKm, projLat: r.projLat, projLng: r.projLng };
      }
    }
    if (mejor.ruta && mejor.distM <= radioMaxM) return mejor;
    return null;
  }

  // ── 3. Progresiva sobre una ruta específica ──────────────────────
  // Devuelve {distM, progKm, projLat, projLng} o null si no hay cadena
  function progresivaEnRuta(lat, lng, rutaKey) {
    if (typeof CHAINS_DATA === 'undefined') return null;
    const chain = CHAINS_DATA[String(rutaKey)];
    if (!chain || chain.length < 2) return null;
    const anchors = (typeof ANCHORS_DATA !== 'undefined') ? ANCHORS_DATA[String(rutaKey)] : null;

    // Recorrer segmentos buscando el más cercano + acumulado al inicio
    let mejorDist = Infinity, mejorAcc = 0, mejorProj = null;
    let accAcum = 0;
    for (let i = 0; i < chain.length - 1; i++) {
      const lng1 = chain[i][0],   lat1 = chain[i][1];
      const lng2 = chain[i+1][0], lat2 = chain[i+1][1];
      const proj = distPuntoASegmento(lat, lng, lat1, lng1, lat2, lng2);
      const segLen = haversineM(lat1, lng1, lat2, lng2);
      if (proj.distM < mejorDist) {
        mejorDist = proj.distM;
        mejorAcc = (accAcum + proj.t * segLen) / 1000;  // km local
        mejorProj = proj;
      }
      accAcum += segLen;
    }

    // Convertir acc local → km real interpolando con anchors
    let kmReal = mejorAcc;
    if (anchors && anchors.length >= 2) {
      let a1 = anchors[0], a2 = anchors[anchors.length - 1];
      for (let i = 0; i < anchors.length - 1; i++) {
        if (anchors[i].acc <= mejorAcc && mejorAcc <= anchors[i+1].acc) {
          a1 = anchors[i]; a2 = anchors[i+1];
          break;
        }
      }
      const ratio = (a2.acc !== a1.acc) ? (mejorAcc - a1.acc) / (a2.acc - a1.acc) : 0;
      kmReal = a1.km + ratio * (a2.km - a1.km);
    }

    return {
      distM: mejorDist,
      progKm: kmReal,
      accLocal: mejorAcc,
      projLat: mejorProj ? mejorProj.projLat : null,
      projLng: mejorProj ? mejorProj.projLng : null
    };
  }

  // ── 4. Mojón físico más cercano (para referencia visual al operador) ──
  function mojonMasCercano(lat, lng, rutaKey, maxDistM = 5000) {
    if (typeof MOJONES_DATA === 'undefined') return null;
    let mejor = null;
    for (const m of MOJONES_DATA) {
      if (rutaKey && String(m.ruta) !== String(rutaKey)) continue;
      const d = haversineM(lat, lng, m.lat, m.lng);
      if ((!mejor || d < mejor.distM) && d <= maxDistM) {
        mejor = { km: m.km, kmLabel: m.km_label, ruta: m.ruta, distM: d };
      }
    }
    return mejor;
  }

  // ── 5. Función principal: comparar datos del usuario vs GPS ──────
  function armonizar(form) {
    const lat = parseFloat(form.lat), lng = parseFloat(form.lng);
    const gpsAcc = parseFloat(form.gpsAcc) || 10;
    const cambios = [];
    const consistentes = [];
    const sugerencias = [];

    if (!isFinite(lat) || !isFinite(lng)) {
      return { cambios: [], consistentes: [], sugerencias: [], severidad: 'ninguna', motivo: 'sin_coords' };
    }

    // ── Validación de "GPS sospechoso" ───────────────────────────
    // Zona VI Saladillo está aprox entre lat -34.5..-37.5 y lng -58.5..-61.5
    if (lat < -38 || lat > -34 || lng < -62 || lng > -58) {
      return {
        cambios: [], consistentes: [], sugerencias: [],
        severidad: 'alta',
        motivo: 'gps_sospechoso',
        mensaje: 'Las coordenadas GPS están fuera del rango esperado de Zona VI. Revisar GPS.'
      };
    }

    // ── Partido ───────────────────────────────────────────────────
    const partidoReal = detectarPartido(lat, lng);
    if (partidoReal) {
      if (!form.partido) {
        cambios.push({
          campo: 'partido', cargado: null, sugerido: partidoReal,
          confianza: 'alta', motivo: 'GPS dentro del polígono de ' + partidoReal,
          severidad: 'baja'  // no había nada, sumar info
        });
      } else if (form.partido !== partidoReal) {
        // Verificar si está cerca del límite (zona ambigua)
        const distLim = distAlLimitePartido(lat, lng, partidoReal);
        const umbralLim = umbralPartidoLim(gpsAcc);
        if (distLim > umbralLim) {
          cambios.push({
            campo: 'partido', cargado: form.partido, sugerido: partidoReal,
            confianza: 'alta',
            motivo: `GPS está dentro de ${partidoReal} (a ${Math.round(distLim)}m del límite, fuera de la zona dudosa de ${umbralLim}m)`,
            severidad: 'alta'  // cambiar de partido es importante
          });
        } else {
          sugerencias.push({
            texto: `Estás a ${Math.round(distLim)}m del límite con ${partidoReal} — partido ambiguo, se mantiene "${form.partido}"`
          });
          consistentes.push('partido');
        }
      } else {
        consistentes.push('partido');
      }
    }

    // ── Ruta y progresiva ────────────────────────────────────────
    // Si el operador puso una ruta, validar contra ella + sugerir alternativa si está lejos
    let rutaParaProg = form.ruta;
    let progReal = null;

    if (form.ruta) {
      progReal = progresivaEnRuta(lat, lng, form.ruta);
      const umbR = umbralRuta(gpsAcc);
      if (progReal) {
        if (progReal.distM > umbR) {
          // GPS está lejos de la ruta cargada — buscar mejor opción
          const masCercana = rutaMasCercana(lat, lng, 500);
          if (masCercana && masCercana.ruta !== form.ruta && masCercana.distM < progReal.distM) {
            cambios.push({
              campo: 'ruta', cargado: 'RP ' + form.ruta, sugerido: 'RP ' + masCercana.ruta,
              confianza: progReal.distM > 2 * umbR ? 'alta' : 'media',
              motivo: `GPS está a ${Math.round(progReal.distM)}m de RP${form.ruta} pero a solo ${Math.round(masCercana.distM)}m de RP${masCercana.ruta}`,
              severidad: progReal.distM > 2 * umbR ? 'alta' : 'media'
            });
            rutaParaProg = masCercana.ruta;
            progReal = { distM: masCercana.distM, progKm: masCercana.progKm };
          } else {
            sugerencias.push({
              texto: `GPS está a ${Math.round(progReal.distM)}m de la traza de RP${form.ruta} — verificar`
            });
          }
        } else {
          consistentes.push('ruta');
        }
      }
    } else {
      // No cargó ruta → sugerir desde GPS
      const masCercana = rutaMasCercana(lat, lng, 500);
      if (masCercana) {
        cambios.push({
          campo: 'ruta', cargado: null, sugerido: 'RP ' + masCercana.ruta,
          confianza: 'alta', motivo: `GPS está a ${Math.round(masCercana.distM)}m de RP${masCercana.ruta}`,
          severidad: 'baja'
        });
        rutaParaProg = masCercana.ruta;
        progReal = { distM: masCercana.distM, progKm: masCercana.progKm };
      }
    }

    // ── Progresiva (solo si tenemos ruta + cálculo) ──────────────
    if (rutaParaProg && progReal && isFinite(progReal.progKm)) {
      const progCargada = parseFloat(String(form.prog || '').replace(',', '.'));
      const umbP = umbralProgresiva(gpsAcc) / 1000;  // a km
      if (!isFinite(progCargada)) {
        cambios.push({
          campo: 'prog', cargado: null, sugerido: progReal.progKm.toFixed(2),
          confianza: 'alta', motivo: `Calculado por proyección sobre RP${rutaParaProg}`,
          severidad: 'baja'
        });
      } else {
        const dif = Math.abs(progCargada - progReal.progKm);
        if (dif > umbP) {
          cambios.push({
            campo: 'prog', cargado: progCargada, sugerido: progReal.progKm.toFixed(2),
            confianza: dif > 2 * umbP ? 'alta' : 'media',
            motivo: `Diferencia ${(dif*1000).toFixed(0)}m respecto a la proyección sobre la ruta`,
            severidad: dif > 5 ? 'alta' : 'media'  // > 5 km es muy raro
          });
        } else {
          consistentes.push('prog');
        }
      }

      // Mojón cercano como info adicional
      const mj = mojonMasCercano(lat, lng, rutaParaProg, 3000);
      if (mj) {
        sugerencias.push({
          texto: `Mojón km ${mj.km} a ${Math.round(mj.distM)}m de tu posición`
        });
      }
    }

    // ── Severidad global = máxima de los cambios ─────────────────
    let severidad = 'ninguna';
    const orden = { ninguna: 0, baja: 1, media: 2, alta: 3 };
    for (const c of cambios) {
      if (orden[c.severidad] > orden[severidad]) severidad = c.severidad;
    }

    return { cambios, consistentes, sugerencias, severidad };
  }

  // ── Auto-inicializar al cargar (mejor para uso interactivo) ──────
  init().catch(() => {/* silenciado, ya se loguea en init() */});

  // ── API pública ──────────────────────────────────────────────────
  return {
    init,
    detectarPartido,
    distAlLimitePartido,
    rutaMasCercana,
    progresivaEnRuta,
    mojonMasCercano,
    armonizar,
    haversineM,
    umbralRuta,
    umbralProgresiva,
    umbralPartidoLim
  };
})();

if (typeof module !== 'undefined') module.exports = ARMONIZADOR;
