/**
 * dvba_estados.js  —  Modelo de Estados, Tipos de Superficie y Modalidades
 * DVBA · Departamento Zona VI Saladillo · v1.0 (2026-06-24)
 *
 * Define qué ESTADOS son válidos para cada CATEGORÍA del árbol de tipos,
 * más sub-atributos condicionales (tipo de superficie, modalidad de tarea).
 *
 * USO:
 *   DVBA_ESTADOS.getEstados('calzada')   → array de {key, label, color}
 *   DVBA_ESTADOS.todosLosEstados()        → set único para filtros agregados
 *   DVBA_ESTADOS.getSuperficies()         → tipos de pavimento/superficie
 *   DVBA_ESTADOS.getModalidades()         → manual / mecánico / mixto
 *   DVBA_ESTADOS.aplicaSuperficie(cat)    → boolean (¿muestra "Tipo superficie"?)
 *   DVBA_ESTADOS.aplicaModalidad(cat)     → boolean (¿muestra "Modalidad"?)
 *
 * NO se hace migración de registros viejos. Los strings antiguos
 * ("Bueno", "Crítico", "Malo", "En obra") se siguen mostrando tal cual
 * en las listas. Al editar uno viejo, el dropdown se inicializa vacío
 * porque el valor antiguo no matchea con los keys nuevos.
 */

const DVBA_ESTADOS = (() => {

  // ── Estados de seguimiento universales (aparecen en casi todas las cats) ──
  const UNIVERSALES = {
    pendiente:  { key:'pendiente',  label:'Pendiente',  color:'#6c757d' },
    en_obra:    { key:'en_obra',    label:'En obra',    color:'#f0a500' },
    reparado:   { key:'reparado',   label:'Reparado',   color:'#28a745' },
  };

  // ── Estados por categoría ──────────────────────────────────────────
  // Cada entrada es { key, label, color }. El orden importa: aparece así en el dropdown.
  const POR_CAT = {

    calzada: [
      { key:'bueno',    label:'Bueno',    color:'#28a745' },
      { key:'regular',  label:'Regular',  color:'#ffc107' },
      { key:'malo',     label:'Malo',     color:'#fd7e14' },
      { key:'critico',  label:'Crítico',  color:'#dc3545' },
      UNIVERSALES.pendiente,
      UNIVERSALES.en_obra,
      UNIVERSALES.reparado,
    ],

    drenaje: [
      { key:'bueno',    label:'Bueno',    color:'#28a745' },
      { key:'regular',  label:'Regular',  color:'#ffc107' },
      { key:'malo',     label:'Malo',     color:'#fd7e14' },
      { key:'critico',  label:'Crítico',  color:'#dc3545' },
      UNIVERSALES.pendiente,
      UNIVERSALES.en_obra,
      UNIVERSALES.reparado,
    ],

    estructura: [
      { key:'bueno',           label:'Bueno',                color:'#28a745' },
      { key:'regular',         label:'Regular',              color:'#ffc107' },
      { key:'malo',            label:'Malo',                 color:'#fd7e14' },
      { key:'critico',         label:'Crítico',              color:'#dc3545' },
      { key:'inspeccion_urg',  label:'Inspección urgente',   color:'#b71c1c' },
      UNIVERSALES.pendiente,
      UNIVERSALES.en_obra,
      UNIVERSALES.reparado,
    ],

    senial_vertical: [
      { key:'ok',         label:'OK / Visible',   color:'#28a745' },
      { key:'danada',     label:'Dañada',         color:'#ffc107' },
      { key:'ilegible',   label:'Ilegible',       color:'#fd7e14' },
      { key:'falta',      label:'Falta',          color:'#dc3545' },
      { key:'mal_ubic',   label:'Mal ubicada',    color:'#6c757d' },
      UNIVERSALES.pendiente,
      { key:'en_reposicion', label:'En reposición', color:'#f0a500' },
      { key:'reemplazada',   label:'Reemplazada',   color:'#28a745' },
    ],

    demarcacion: [
      { key:'visible',    label:'Visible',         color:'#28a745' },
      { key:'borrada',    label:'Borrada',         color:'#ffc107' },
      { key:'inexistente',label:'Inexistente',     color:'#dc3545' },
      UNIVERSALES.pendiente,
      { key:'en_ejec',    label:'En ejecución',    color:'#f0a500' },
      { key:'repintado',  label:'Repintado',       color:'#28a745' },
    ],

    iluminacion: [
      { key:'funciona',     label:'Funciona',          color:'#28a745' },
      { key:'parcial',      label:'Funciona parcial',  color:'#ffc107' },
      { key:'no_funciona',  label:'No funciona',       color:'#dc3545' },
      UNIVERSALES.pendiente,
      { key:'en_reparacion',label:'En reparación',     color:'#f0a500' },
      UNIVERSALES.reparado,
    ],

    entorno: [
      { key:'activo',      label:'Activo',         color:'#dc3545' },
      { key:'monitoreo',   label:'Bajo monitoreo', color:'#ffc107' },
      UNIVERSALES.pendiente,
      { key:'en_limpieza', label:'En limpieza',    color:'#f0a500' },
      { key:'resuelto',    label:'Resuelto',       color:'#28a745' },
    ],

    seguridad: [
      { key:'activo',      label:'Activo',         color:'#dc3545' },
      { key:'monitoreo',   label:'Bajo monitoreo', color:'#ffc107' },
      { key:'resuelto',    label:'Resuelto',       color:'#28a745' },
    ],

    mantenimiento: [
      { key:'programado',  label:'Programado',     color:'#6c757d' },
      { key:'en_ejecucion',label:'En ejecución',   color:'#f0a500' },
      { key:'finalizado',  label:'Finalizado',     color:'#28a745' },
      { key:'suspendido',  label:'Suspendido',     color:'#ffc107' },
      { key:'cancelado',   label:'Cancelado',      color:'#6c757d' },
    ],

    otro: [
      { key:'sin_esp',     label:'Sin especificar', color:'#888' },
      UNIVERSALES.pendiente,
      UNIVERSALES.en_obra,
      UNIVERSALES.reparado,
    ],
  };

  // ── Sub-atributo: Tipo de superficie (solo Calzada y Mantenimiento sobre calzada) ──
  const SUPERFICIES = [
    { key:'asfalto',       label:'Asfalto (pav. flexible)' },
    { key:'hormigon',      label:'Hormigón (pav. rígido)' },
    { key:'tierra',        label:'Tierra' },
    { key:'estabilizado',  label:'Estabilizado' },
    { key:'dolomita',      label:'Mejorado con dolomita' },
    { key:'suelo_cal',     label:'Mejorado con suelo cal' },
  ];

  // ── Sub-atributo: Modalidad (solo Mantenimiento / Tarea) ──
  const MODALIDADES = [
    { key:'manual',   label:'Manual' },
    { key:'mecanico', label:'Mecánico' },
    { key:'mixto',    label:'Mixto' },
  ];

  // ── Categorías donde aplica cada sub-atributo ──
  const CAT_CON_SUPERFICIE = new Set(['calzada', 'mantenimiento']);
  const CAT_CON_MODALIDAD  = new Set(['mantenimiento']);

  // ── Detección de sub-atributos IMPLÍCITOS en el nombre del tipo ──
  // Si el tipo ya incluye la modalidad o superficie en su nombre, no se muestra
  // el selector correspondiente (sería redundante o contradictorio).
  //
  // OJO: JavaScript `\b` no es Unicode-aware: las tildes (á,é,ó,...) NO están
  // en `\w`, así que `\b` las trata como boundary y rompe palabras como
  // "mecánico" (queda como 3 pedazos: "mec", "á", "nico"). Por eso
  // normalizamos el string ANTES de aplicar el regex.
  function _normTipo(s) {
    return (s || '').toLowerCase()
      .normalize('NFD').replace(new RegExp('[\\u0300-\\u036f]', 'g'), '');
  }
  function modalidadImplicita(tipoStr) {
    const s = _normTipo(tipoStr);
    if (/\bmanual\b/.test(s))     return 'manual';
    if (/\bmecanic[oa]\b/.test(s)) return 'mecanico';
    if (/\bmixt[oa]\b/.test(s))   return 'mixto';
    return null;
  }
  function superficieImplicita(tipoStr) {
    const s = _normTipo(tipoStr);
    if (/\bdolomita\b/.test(s))                          return 'dolomita';
    if (/\bsuelo\s*cal\b/.test(s))                       return 'suelo_cal';
    if (/\btierra\b/.test(s) && /reconformado/.test(s))  return 'tierra';
    if (/\bcamino\s*tierra\b/.test(s))                   return 'tierra';
    if (/\bhormigon\b/.test(s))                          return 'hormigon';
    if (/\basfaltic[oa]\b/.test(s) || /\briego\s*asf/.test(s)) return 'asfalto';
    return null;
  }

  // ── API pública ────────────────────────────────────────────────────
  function getEstados(catKey) {
    return POR_CAT[catKey] || [
      UNIVERSALES.pendiente, UNIVERSALES.en_obra, UNIVERSALES.reparado
    ];
  }

  function todosLosEstados() {
    const set = new Map();
    Object.values(POR_CAT).forEach(arr => arr.forEach(e => set.set(e.key, e)));
    return Array.from(set.values());
  }

  function getSuperficies()  { return SUPERFICIES.slice(); }
  function getModalidades()  { return MODALIDADES.slice(); }

  function aplicaSuperficie(catKey) { return CAT_CON_SUPERFICIE.has(catKey); }
  function aplicaModalidad(catKey)  { return CAT_CON_MODALIDAD.has(catKey); }

  return {
    getEstados,
    todosLosEstados,
    getSuperficies,
    getModalidades,
    aplicaSuperficie,
    aplicaModalidad,
    modalidadImplicita,
    superficieImplicita,
    POR_CAT,
    SUPERFICIES,
    MODALIDADES,
  };
})();

// Compat CommonJS para uso en Node si hace falta
if (typeof module !== 'undefined') module.exports = DVBA_ESTADOS;
