/**
 * dvba_estados.js  —  Modelo de Estados, Superficies y Modalidades
 * DVBA · Departamento Zona VI Saladillo · v2.0 (2026-08-14)
 *
 * v2.0 introduce el eje NATURALEZA para separar formalmente:
 *   - 'relevamiento' : se observa el estado de un elemento vial
 *   - 'tarea'        : se registra una tarea de mantenimiento
 *
 * La categoría (calzada, drenaje, señalización, etc.) es común a ambas
 * naturalezas: sobre el mismo elemento se puede relevar su condición o
 * registrar una tarea que se hizo.
 *
 * COMPATIBILIDAD:
 *   La API vieja (getEstados, POR_CAT) sigue intacta para que los
 *   HTMLs actuales sigan funcionando sin cambios. La API nueva
 *   (getEstadosPorNaturaleza, POR_CAT_RELEV, ESTADOS_TAREA) es lo
 *   que consumen las UIs v2.
 *
 * USO NUEVO (v2):
 *   DVBA_ESTADOS.getEstadosPorNaturaleza(cat, naturaleza)
 *     → array de {key, label, color}
 *   DVBA_ESTADOS.getEstadosTarea()           → estados de ejecución
 *   DVBA_ESTADOS.getEstadosRelev(cat)        → estados de condición
 *
 * USO LEGACY (v1, sigue funcionando):
 *   DVBA_ESTADOS.getEstados(cat)             → mismos estados que antes
 */

const DVBA_ESTADOS = (() => {

  // ── Estados de seguimiento universales (aparecen mezclados en POR_CAT viejo) ──
  const UNIVERSALES = {
    pendiente:  { key:'pendiente',  label:'Pendiente',  color:'#6c757d' },
    en_obra:    { key:'en_obra',    label:'En obra',    color:'#f0a500' },
    reparado:   { key:'reparado',   label:'Reparado',   color:'#28a745' },
  };

  // ═════════════════════════════════════════════════════════════════
  // MODELO v2 · Estados de TAREA (naturaleza='tarea')
  // Son iguales para todas las categorías: describen la ejecución
  // de una acción de mantenimiento, no la condición de un elemento.
  // ═════════════════════════════════════════════════════════════════
  const ESTADOS_TAREA = [
    { key:'programado',   label:'Programado',    color:'#9c27b0' },
    { key:'en_ejecucion', label:'En ejecución',  color:'#f0a500' },
    { key:'finalizado',   label:'Finalizado',    color:'#28a745' },
    { key:'suspendido',   label:'Suspendido',    color:'#ffc107' },
    { key:'cancelado',    label:'Cancelado',     color:'#6c757d' },
  ];

  // ═════════════════════════════════════════════════════════════════
  // MODELO v2 · Estados de RELEVAMIENTO (naturaleza='relevamiento')
  // Cada categoría tiene su propio set de condiciones específicas.
  // Sin mezclar con universales de seguimiento (que corresponden a
  // tarea, no a relevamiento del estado observado).
  // ═════════════════════════════════════════════════════════════════
  const POR_CAT_RELEV = {

    calzada: [
      { key:'bueno',    label:'Bueno',    color:'#28a745' },
      { key:'regular',  label:'Regular',  color:'#ffc107' },
      { key:'malo',     label:'Malo',     color:'#fd7e14' },
      { key:'critico',  label:'Crítico',  color:'#dc3545' },
    ],

    drenaje: [
      { key:'bueno',    label:'Bueno',    color:'#28a745' },
      { key:'regular',  label:'Regular',  color:'#ffc107' },
      { key:'malo',     label:'Malo',     color:'#fd7e14' },
      { key:'critico',  label:'Crítico',  color:'#dc3545' },
    ],

    estructura: [
      { key:'bueno',           label:'Bueno',                color:'#28a745' },
      { key:'regular',         label:'Regular',              color:'#ffc107' },
      { key:'malo',            label:'Malo',                 color:'#fd7e14' },
      { key:'critico',         label:'Crítico',              color:'#dc3545' },
      { key:'inspeccion_urg',  label:'Inspección urgente',   color:'#b71c1c' },
    ],

    senial_vertical: [
      { key:'ok',         label:'OK / Visible',   color:'#28a745' },
      { key:'danada',     label:'Dañada',         color:'#ffc107' },
      { key:'ilegible',   label:'Ilegible',       color:'#fd7e14' },
      { key:'falta',      label:'Falta',          color:'#dc3545' },
      { key:'mal_ubic',   label:'Mal ubicada',    color:'#6c757d' },
    ],

    demarcacion: [
      { key:'visible',    label:'Visible',      color:'#28a745' },
      { key:'borrada',    label:'Borrada',      color:'#ffc107' },
      { key:'inexistente',label:'Inexistente',  color:'#dc3545' },
    ],

    iluminacion: [
      { key:'funciona',     label:'Funciona',          color:'#28a745' },
      { key:'parcial',      label:'Funciona parcial',  color:'#ffc107' },
      { key:'no_funciona',  label:'No funciona',       color:'#dc3545' },
    ],

    entorno: [
      { key:'activo',      label:'Activo',         color:'#dc3545' },
      { key:'monitoreo',   label:'Bajo monitoreo', color:'#ffc107' },
      { key:'resuelto',    label:'Resuelto',       color:'#28a745' },
    ],

    seguridad: [
      { key:'activo',      label:'Activo',         color:'#dc3545' },
      { key:'monitoreo',   label:'Bajo monitoreo', color:'#ffc107' },
      { key:'resuelto',    label:'Resuelto',       color:'#28a745' },
    ],

    otro: [
      { key:'sin_esp',     label:'Sin especificar', color:'#888' },
    ],
  };

  // ═════════════════════════════════════════════════════════════════
  // MODELO v1 (legacy) · POR_CAT mezcla condición + universales
  // Mantener para que HTMLs viejos que llaman getEstados(cat) sigan
  // funcionando. La UI nueva llama getEstadosPorNaturaleza(cat, nat).
  // ═════════════════════════════════════════════════════════════════
  const POR_CAT = {

    calzada: [
      ...POR_CAT_RELEV.calzada,
      UNIVERSALES.pendiente,
      UNIVERSALES.en_obra,
      UNIVERSALES.reparado,
    ],

    drenaje: [
      ...POR_CAT_RELEV.drenaje,
      UNIVERSALES.pendiente,
      UNIVERSALES.en_obra,
      UNIVERSALES.reparado,
    ],

    estructura: [
      ...POR_CAT_RELEV.estructura,
      UNIVERSALES.pendiente,
      UNIVERSALES.en_obra,
      UNIVERSALES.reparado,
    ],

    senial_vertical: [
      ...POR_CAT_RELEV.senial_vertical,
      UNIVERSALES.pendiente,
      { key:'en_reposicion', label:'En reposición', color:'#f0a500' },
      { key:'reemplazada',   label:'Reemplazada',   color:'#28a745' },
    ],

    demarcacion: [
      ...POR_CAT_RELEV.demarcacion,
      UNIVERSALES.pendiente,
      { key:'en_ejec',    label:'En ejecución',  color:'#f0a500' },
      { key:'repintado',  label:'Repintado',     color:'#28a745' },
    ],

    iluminacion: [
      ...POR_CAT_RELEV.iluminacion,
      UNIVERSALES.pendiente,
      { key:'en_reparacion',label:'En reparación', color:'#f0a500' },
      UNIVERSALES.reparado,
    ],

    entorno: [
      ...POR_CAT_RELEV.entorno,
      UNIVERSALES.pendiente,
      { key:'en_limpieza', label:'En limpieza',  color:'#f0a500' },
    ],

    seguridad: POR_CAT_RELEV.seguridad,

    // Categoría legacy 'mantenimiento' = estados de tarea (equivalente a v2).
    mantenimiento: ESTADOS_TAREA,

    otro: [
      ...POR_CAT_RELEV.otro,
      UNIVERSALES.pendiente,
      UNIVERSALES.en_obra,
      UNIVERSALES.reparado,
    ],
  };

  // ── Sub-atributo: Tipo de superficie (aplica en calzada y en tareas sobre calzada) ──
  const SUPERFICIES = [
    { key:'asfalto',       label:'Asfalto (pav. flexible)' },
    { key:'hormigon',      label:'Hormigón (pav. rígido)' },
    { key:'tierra',        label:'Tierra' },
    { key:'estabilizado',  label:'Estabilizado' },
    { key:'dolomita',      label:'Mejorado con dolomita' },
    { key:'suelo_cal',     label:'Mejorado con suelo cal' },
  ];

  // ── Sub-atributo: Modalidad (aplica solo en naturaleza='tarea') ──
  const MODALIDADES = [
    { key:'manual',   label:'Manual' },
    { key:'mecanico', label:'Mecánico' },
    { key:'mixto',    label:'Mixto' },
  ];

  // ── Categorías donde aplica cada sub-atributo (compat v1) ──
  const CAT_CON_SUPERFICIE = new Set(['calzada', 'mantenimiento']);
  const CAT_CON_MODALIDAD  = new Set(['mantenimiento']);

  // ── v2: reglas de aplicabilidad de sub-atributos por categoría + naturaleza ──
  //
  //   Superficie aplica cuando el elemento tiene superficie física visible:
  //     · calzada (siempre, en ambas naturalezas)
  //     · drenaje (relevamiento — la cuneta tiene superficie de tierra/pav.)
  //   Modalidad aplica solo cuando naturaleza='tarea' (una tarea se ejecuta
  //     manual, mecánica o mixta; un elemento no "tiene" modalidad).
  //
  function aplicaSuperficieV2(catKey, naturaleza) {
    if (catKey === 'calzada') return true;
    if (naturaleza === 'tarea' && (catKey === 'calzada' || catKey === 'entorno')) return true;
    return false;
  }
  function aplicaModalidadV2(catKey, naturaleza) {
    return naturaleza === 'tarea';
  }

  // ── Detección de sub-atributos IMPLÍCITOS en el nombre del tipo ──
  function _normTipo(s) {
    return (s || '').toLowerCase()
      .normalize('NFD').replace(new RegExp('[\\u0300-\\u036f]', 'g'), '');
  }
  function modalidadImplicita(tipoStr) {
    const s = _normTipo(tipoStr);
    if (/\bmanual\b/.test(s))       return 'manual';
    if (/\bmecanic[oa]\b/.test(s))  return 'mecanico';
    if (/\bmixt[oa]\b/.test(s))     return 'mixto';
    if (/motoniveladora/.test(s))   return 'mecanico';  // v2: motoniveladora → mecánico
    return null;
  }
  function superficieImplicita(tipoStr) {
    const s = _normTipo(tipoStr);
    if (/\bdolomita\b/.test(s))                          return 'dolomita';
    if (/\bsuelo\s*cal\b/.test(s))                       return 'suelo_cal';
    if (/\btierra\b/.test(s) && /reconformado/.test(s))  return 'tierra';
    if (/\bcamino\s*tierra\b/.test(s))                   return 'tierra';
    if (/\bcaminos?\s*rurales?\b/.test(s))               return 'tierra';  // v2
    if (/\bhormigon\b/.test(s))                          return 'hormigon';
    if (/\basfaltic[oa]\b/.test(s) || /\briego\s*asf/.test(s)) return 'asfalto';
    return null;
  }

  // ── API pública v1 (legacy — no tocar) ─────────────────────────────
  function getEstados(catKey) {
    return POR_CAT[catKey] || [
      UNIVERSALES.pendiente, UNIVERSALES.en_obra, UNIVERSALES.reparado
    ];
  }
  function todosLosEstados() {
    const set = new Map();
    Object.values(POR_CAT).forEach(arr => arr.forEach(e => set.set(e.key, e)));
    ESTADOS_TAREA.forEach(e => set.set(e.key, e));
    return Array.from(set.values());
  }
  function getSuperficies()  { return SUPERFICIES.slice(); }
  function getModalidades()  { return MODALIDADES.slice(); }
  function aplicaSuperficie(catKey) { return CAT_CON_SUPERFICIE.has(catKey); }
  function aplicaModalidad(catKey)  { return CAT_CON_MODALIDAD.has(catKey); }

  // ── API pública v2 ─────────────────────────────────────────────────
  //
  // getEstadosRelev(cat)  → estados de condición para naturaleza='relevamiento'
  // getEstadosTarea()     → estados de ejecución (universales)
  // getEstadosPorNaturaleza(cat, naturaleza) → orquestador
  //
  function getEstadosRelev(catKey) {
    return POR_CAT_RELEV[catKey] || POR_CAT_RELEV.otro;
  }
  function getEstadosTarea() {
    return ESTADOS_TAREA.slice();
  }
  function getEstadosPorNaturaleza(catKey, naturaleza) {
    if (naturaleza === 'tarea') return getEstadosTarea();
    return getEstadosRelev(catKey);
  }

  return {
    // v1 (compat)
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
    // v2 (nueva API con naturaleza)
    getEstadosRelev,
    getEstadosTarea,
    getEstadosPorNaturaleza,
    aplicaSuperficieV2,
    aplicaModalidadV2,
    POR_CAT_RELEV,
    ESTADOS_TAREA,
  };
})();

// Compat CommonJS para uso en Node si hace falta
if (typeof module !== 'undefined') module.exports = DVBA_ESTADOS;
