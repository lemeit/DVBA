// ================================================================
// datos/rutas.js — índice de módulos de rutas DVBA Zona VI
// Orden de carga en HTML:
//   <script src="datos/rutas_rp40.js"></script>
//   <!-- <script src="datos/rutas_rp91.js"></script> -->
//   <!-- <script src="datos/rutas_rp51.js"></script> -->
//   <script src="datos/rutas_mojones.js"></script>
//   <script src="datos/rutas.js"></script>
// ================================================================

function initRutasData() {
  if (typeof CHAINS_DATA  === 'undefined') window.CHAINS_DATA  = {};
  if (typeof ANCHORS_DATA === 'undefined') window.ANCHORS_DATA = {};
  if (typeof MOJONES_DATA === 'undefined') window.MOJONES_DATA = [];

  if (typeof CHAIN_RP40   !== 'undefined') CHAINS_DATA['40']  = CHAIN_RP40;
  if (typeof ANCHORS_RP40 !== 'undefined') ANCHORS_DATA['40'] = ANCHORS_RP40;
  // Próximas rutas:
  // if (typeof CHAIN_RP91 !== 'undefined') CHAINS_DATA['91'] = CHAIN_RP91;

  initMojonesData();
  console.log('[rutas.js] Rutas:', Object.keys(CHAINS_DATA));
  console.log('[rutas.js] Mojones totales:', MOJONES_DATA.length);
}

// Auto-inicializar si el DOM ya está listo
if (document.readyState === 'loading')
  document.addEventListener('DOMContentLoaded', initRutasData);
else
  initRutasData();
