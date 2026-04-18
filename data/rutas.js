// ================================================================
// datos/rutas.js — índice de rutas DVBA Zona VI Saladillo
// Cargar ANTES de dvba_zona6.html
// ================================================================

// Inicializar estructuras si no existen
if (typeof CHAINS_DATA === 'undefined')  window.CHAINS_DATA  = {};
if (typeof ANCHORS_DATA === 'undefined') window.ANCHORS_DATA = {};
if (typeof MOJONES_DATA === 'undefined') window.MOJONES_DATA = [];

// ── RP40 (cargado desde rutas_rp40.js) ──────────────────────────
// CHAINS_DATA['40']  = CHAIN_RP40;
// ANCHORS_DATA['40'] = ANCHORS_RP40;
// Los mojones se agregan en rutas_mojones.js

// Función de inicialización — llamar después de cargar todos los módulos
function initRutasData() {
  if (typeof CHAIN_RP40  !== 'undefined') CHAINS_DATA['40']  = CHAIN_RP40;
  if (typeof ANCHORS_RP40 !== 'undefined') ANCHORS_DATA['40'] = ANCHORS_RP40;
  // Agregar más rutas acá al incorporarlas:
  // if (typeof CHAIN_RP91  !== 'undefined') CHAINS_DATA['91']  = CHAIN_RP91;
  // if (typeof CHAIN_RP51  !== 'undefined') CHAINS_DATA['51']  = CHAIN_RP51;
  console.log('[rutas.js] Rutas cargadas:', Object.keys(CHAINS_DATA));
}
