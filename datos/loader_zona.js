/**
 * datos/loader_zona.js — Loader dinámico multi-zona (v8.62)
 *
 * ROL:
 * Reemplaza los <script src="datos/rutas/rutas_rpXX.js"> hardcoded a VI en
 * index.html. Detecta la zona activa y carga sincrónicamente (via document.write)
 * los bundles RP calibrados + red_vial + caracteristicas_viales de esa zona.
 *
 * DETECCIÓN DE ZONA (prioridad descendente):
 *   1. URL: ?zona=X (ej. /DVBA/?zona=IV)
 *   2. Perfil del user técnico logueado (localStorage dvba_perfil.zona)
 *   3. Default: 'VI' (zona piloto en producción)
 *
 * AUTO-REDIRECT:
 *   Si el user es técnico y el URL NO trae ?zona pero su perfil tiene zona X,
 *   redirige a ?zona=X. Solo en index.html. Admin/gerencia no auto-redirigen
 *   (usan el picker manualmente).
 *
 * EXPORTA A window:
 *   - window.ZONA_ACTUAL = 'VI' (o la detectada)
 *   - window.ZONA_META = { codigo, nombre, cabecera, ...manifest }
 *   - window.DVBA_ZONA = { cambiar(cod), actual(), esCompleta() }
 *
 * NOTA v1 (v8.62): solo VI tiene red_vial_zonaVI.js y caracteristicas_viales_zonaVI.js
 * calibrados. Para IV/V, se cargan solo bundles RP calibrados compartidos + geojson
 * básicos (partidos + rutas). Cuando esos módulos existan para IV/V, se activan aquí.
 *
 * MUST BE LOADED SINCHRONOUSLY EN EL <HEAD>, ANTES DE TODO OTRO SCRIPT.
 * Ej: <script src="datos/loader_zona.js?v=8.62"></script>
 *     ↑ SIN defer, SIN async — necesita document.write durante el parse.
 */

(function () {
  'use strict';

  // ═══════════════════════════════════════════════════════════════════════════
  // Config: manifiestos hardcoded (evita fetch síncrono que ya no está soportado)
  // Los mismos datos viven en datos/zonas/zona_XX/manifest.json — mantener sync.
  // ═══════════════════════════════════════════════════════════════════════════
  const MANIFESTS = {
    VI: {
      codigo: 'VI', nombre: 'Saladillo', cabecera: 'Saladillo',
      estado: 'produccion',
      rps_calibradas: ['30', '40', '41', '46', '47', '51', '61', '91'],
      assets_zona: {
        red_vial:    'datos/zonas/zona_VI/red_vial_zonaVI.js',
        caract:      'datos/zonas/zona_VI/caracteristicas_viales_zonaVI.js',
        partidos:    'datos/zonas/zona_VI/partidos_zonaVI.geojson',
        red_secund:  'datos/zonas/zona_VI/red_secundaria_zonaVI_final.geojson'
      }
    },
    IV: {
      codigo: 'IV', nombre: 'Junín', cabecera: 'Junín',
      estado: 'piloto',
      rps_calibradas: ['46'],  // compartida con VI
      assets_zona: {
        partidos:    'datos/zonas/zona_IV/partidos_zonaIV.geojson',
        rutas_geo:   'datos/zonas/zona_IV/rutas_zonaIV.geojson'
        // red_vial + caract aún no generados para IV
      }
    },
    V: {
      codigo: 'V', nombre: 'Chivilcoy', cabecera: 'Chivilcoy',
      estado: 'piloto',
      rps_calibradas: ['30', '46', '51', '61'],  // compartidas con VI
      assets_zona: {
        partidos:    'datos/zonas/zona_V/partidos_zonaV.geojson',
        rutas_geo:   'datos/zonas/zona_V/rutas_zonaV.geojson'
      }
    }
    // Cuando se agreguen I, II, III, VII-XII, extender aquí.
  };

  const VERSION = '8.62'; // para cache-bust de los <script src>

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. Detectar zona
  // ═══════════════════════════════════════════════════════════════════════════
  function detectarZona() {
    // 1.a URL
    try {
      const params = new URLSearchParams(location.search);
      const z = (params.get('zona') || '').toUpperCase();
      if (z && MANIFESTS[z]) return { zona: z, origen: 'url' };
    } catch (_) {}

    // 1.b Perfil del user técnico (si logueado)
    try {
      const raw = localStorage.getItem('dvba_perfil');
      if (raw) {
        const perfil = JSON.parse(raw);
        if (perfil && perfil.rol === 'tecnico' && perfil.zona && MANIFESTS[perfil.zona]) {
          return { zona: perfil.zona, origen: 'perfil-tecnico' };
        }
      }
    } catch (_) {}

    // 1.c Default piloto
    return { zona: 'VI', origen: 'default' };
  }

  const deteccion = detectarZona();
  const zonaCod = deteccion.zona;
  const manifest = MANIFESTS[zonaCod];

  // Exponer estado a window ANTES de cargar los scripts
  window.ZONA_ACTUAL = zonaCod;
  window.ZONA_META = manifest;
  window.ZONA_ORIGEN = deteccion.origen;

  console.log(`[loader_zona] Zona ${zonaCod} · ${manifest.nombre} (origen: ${deteccion.origen})`);

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. Auto-redirect: técnico sin ?zona → redirect con ?zona=X
  // ═══════════════════════════════════════════════════════════════════════════
  // Solo redirige si:
  // - Estamos en index.html (o /)
  // - Detectamos zona por perfil-técnico
  // - El URL NO tiene ?zona explícito
  try {
    const enIndex = /(\/|\/index\.html)($|\?|#)/.test(location.pathname + location.search);
    const hayZonaEnURL = new URLSearchParams(location.search).has('zona');
    if (enIndex && !hayZonaEnURL && deteccion.origen === 'perfil-tecnico') {
      const nuevoURL = location.pathname + '?zona=' + zonaCod + location.hash;
      console.log('[loader_zona] Auto-redirect técnico → ' + nuevoURL);
      location.replace(nuevoURL);
      return; // no seguir cargando scripts, redirige
    }
  } catch (_) {}

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. Cargar bundles RP calibrados (via document.write, sincrónico)
  // ═══════════════════════════════════════════════════════════════════════════
  // Los bundles RP viven en datos/rutas/ (compartidos entre zonas).
  // Solo cargamos los que la zona tenga marcados como calibrados.
  const bundlesRP = manifest.rps_calibradas || [];
  bundlesRP.forEach(rp => {
    document.write(`<script src="datos/rutas/rutas_rp${rp}.js?v=${VERSION}"><\/script>`);
  });
  // Dispatcher que arma CHAINS_DATA/ANCHORS_DATA/MOJONES_DATA desde los bundles
  document.write(`<script src="datos/rutas/rutas.js?v=${VERSION}"><\/script>`);

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. Cargar assets específicos de la zona
  // ═══════════════════════════════════════════════════════════════════════════
  // red_vial_zonaXX.js y caracteristicas_viales_zonaXX.js solo existen para VI hoy.
  // Para IV/V, se dejan como no cargados — el código debe manejar RED_VIAL undefined.
  const assets = manifest.assets_zona || {};
  if (assets.red_vial) {
    document.write(`<script src="${assets.red_vial}?v=${VERSION}" defer><\/script>`);
  }
  if (assets.caract) {
    document.write(`<script src="${assets.caract}?v=${VERSION}" defer><\/script>`);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. Exponer API DVBA_ZONA (cambio de zona, consulta)
  // ═══════════════════════════════════════════════════════════════════════════
  window.DVBA_ZONA = {
    /** Cambia la zona activa · hace reload con ?zona=X. */
    cambiar: function (cod) {
      cod = String(cod || '').toUpperCase();
      if (!MANIFESTS[cod]) {
        console.warn('[DVBA_ZONA] Zona desconocida:', cod);
        return;
      }
      const params = new URLSearchParams(location.search);
      params.set('zona', cod);
      location.href = location.pathname + '?' + params.toString() + location.hash;
    },
    /** Devuelve el código de la zona activa. */
    actual: function () { return zonaCod; },
    /** Devuelve el manifest completo de la zona activa. */
    meta: function () { return manifest; },
    /** True si la zona tiene todos los assets calibrados (VI). False para IV/V hoy. */
    esCompleta: function () { return manifest.estado === 'produccion'; },
    /** Lista de zonas disponibles en el loader. */
    listar: function () { return Object.keys(MANIFESTS); }
  };

  // Aviso visual si la zona es piloto (incompleta)
  if (!window.DVBA_ZONA.esCompleta()) {
    console.log(`⚠ [DVBA_ZONA] Zona ${zonaCod} · ${manifest.nombre} está en modo piloto (assets básicos, sin calibración completa)`);
  }
})();
