// datos/rutas.js
// Inicializa las estructuras globales que usa dvba_zona6.html
// Cargar DESPUÉS de todos los rutas_rpXX.js

(function() {
  if (typeof window.CHAINS_DATA  === 'undefined') window.CHAINS_DATA  = {};
  if (typeof window.ANCHORS_DATA === 'undefined') window.ANCHORS_DATA = {};
  if (typeof window.MOJONES_DATA === 'undefined') window.MOJONES_DATA = [];

  // ── RP40 ──────────────────────────────────────────────────────────────────
  if (typeof CHAIN_RP40   !== 'undefined') CHAINS_DATA['40']  = CHAIN_RP40;
  if (typeof ANCHORS_RP40 !== 'undefined') ANCHORS_DATA['40'] = ANCHORS_RP40;
  if (typeof MOJONES_RP40_TODOS !== 'undefined') {
    MOJONES_DATA = MOJONES_DATA.filter(m => m.ruta !== '40');
    MOJONES_DATA = MOJONES_DATA.concat(MOJONES_RP40_TODOS);
  }

  // ── RP91 ──────────────────────────────────────────────────────────────────
  if (typeof CHAIN_RP91   !== 'undefined') CHAINS_DATA['91']  = CHAIN_RP91;
  if (typeof ANCHORS_RP91 !== 'undefined') ANCHORS_DATA['91'] = ANCHORS_RP91;
  if (typeof MOJONES_RP91_TODOS !== 'undefined') {
    MOJONES_DATA = MOJONES_DATA.filter(m => m.ruta !== '91');
    MOJONES_DATA = MOJONES_DATA.concat(MOJONES_RP91_TODOS);
  }

  // Próximas rutas — descomentar al agregar:
  // if (typeof CHAIN_RP51 !== 'undefined') CHAINS_DATA['51'] = CHAIN_RP51;
  // if (typeof ANCHORS_RP51 !== 'undefined') ANCHORS_DATA['51'] = ANCHORS_RP51;

  console.log('[rutas.js] Rutas cargadas:', Object.keys(CHAINS_DATA));
  console.log('[rutas.js] Mojones totales:', MOJONES_DATA.length);
})();
