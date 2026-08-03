// datos/rutas/rutas.js (dispatcher agnóstico multi-zona, movido en v8.59 desde datos/rutas.js)
// Inicializa las estructuras globales que usa index.html (app de escritorio)
// Cargar DESPUÉS de todos los rutas_rpXX.js

(function() {
  if (typeof window.CHAINS_DATA  === 'undefined') window.CHAINS_DATA  = {};
  if (typeof window.ANCHORS_DATA === 'undefined') window.ANCHORS_DATA = {};
  if (typeof window.MOJONES_DATA === 'undefined') window.MOJONES_DATA = [];

  // ── Función auxiliar para registrar una ruta sin duplicar código ──
  function registrar(num, chain, anchors, mojones) {
    if (chain    !== undefined) CHAINS_DATA[num]  = chain;
    if (anchors  !== undefined) ANCHORS_DATA[num] = anchors;
    if (mojones  !== undefined) {
      MOJONES_DATA = MOJONES_DATA.filter(m => m.ruta !== num);
      MOJONES_DATA = MOJONES_DATA.concat(mojones);
    }
  }

  // ── Rutas con bundle generado ─────────────────────────────────────────
  if (typeof CHAIN_RP30 !== 'undefined') registrar('30', CHAIN_RP30, ANCHORS_RP30, MOJONES_RP30_TODOS);
  if (typeof CHAIN_RP40 !== 'undefined') registrar('40', CHAIN_RP40, ANCHORS_RP40, MOJONES_RP40_TODOS);
  if (typeof CHAIN_RP41 !== 'undefined') registrar('41', CHAIN_RP41, ANCHORS_RP41, MOJONES_RP41_TODOS);
  if (typeof CHAIN_RP46 !== 'undefined') registrar('46', CHAIN_RP46, ANCHORS_RP46, MOJONES_RP46_TODOS);
  if (typeof CHAIN_RP47 !== 'undefined') registrar('47', CHAIN_RP47, ANCHORS_RP47, MOJONES_RP47_TODOS);
  if (typeof CHAIN_RP51 !== 'undefined') registrar('51', CHAIN_RP51, ANCHORS_RP51, MOJONES_RP51_TODOS);
  if (typeof CHAIN_RP61 !== 'undefined') registrar('61', CHAIN_RP61, ANCHORS_RP61, MOJONES_RP61_TODOS);
  if (typeof CHAIN_RP91 !== 'undefined') registrar('91', CHAIN_RP91, ANCHORS_RP91, MOJONES_RP91_TODOS);

  // ── Pendientes — agregar acá cuando se generen los bundles ──
  // if (typeof CHAIN_RP6  !== 'undefined') registrar('6',  CHAIN_RP6,  ANCHORS_RP6,  MOJONES_RP6_TODOS);
  // if (typeof CHAIN_RP20 !== 'undefined') registrar('20', CHAIN_RP20, ANCHORS_RP20, MOJONES_RP20_TODOS);
  // if (typeof CHAIN_RP24 !== 'undefined') registrar('24', CHAIN_RP24, ANCHORS_RP24, MOJONES_RP24_TODOS);
  // if (typeof CHAIN_RP42 !== 'undefined') registrar('42', CHAIN_RP42, ANCHORS_RP42, MOJONES_RP42_TODOS);
  // if (typeof CHAIN_RP43 !== 'undefined') registrar('43', CHAIN_RP43, ANCHORS_RP43, MOJONES_RP43_TODOS);
  // if (typeof CHAIN_RP44 !== 'undefined') registrar('44', CHAIN_RP44, ANCHORS_RP44, MOJONES_RP44_TODOS);
  // if (typeof CHAIN_RP48 !== 'undefined') registrar('48', CHAIN_RP48, ANCHORS_RP48, MOJONES_RP48_TODOS);

  console.log('[rutas.js] Rutas cargadas:', Object.keys(CHAINS_DATA).sort((a,b)=>+a-+b));
  console.log('[rutas.js] Mojones totales:', MOJONES_DATA.length);
})();
