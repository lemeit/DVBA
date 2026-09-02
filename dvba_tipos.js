/**
 * dvba_tipos.js  — Módulo compartido de tipos de registro
 * DVBA · Departamento Zona VI Saladillo · v3.0 (2026-08-14)
 *
 * v3.0 introduce el modelo Tipos v2 con eje NATURALEZA:
 *   - 'relevamiento' : se observa el estado del elemento
 *   - 'tarea'        : se registra una tarea de mantenimiento
 * La categoría (calzada, drenaje, etc.) es común a ambas naturalezas.
 * Cada categoría tiene dos listas de ítems: items_relev y items_tarea.
 *
 * v2.0 (legacy) sigue funcionando: ARBOL antiguo con categoría separada
 * 'mantenimiento' se mantiene intacto para compatibilidad con HTMLs
 * que aún no migraron al modelo v2. Los HTMLs v2 usan ARBOL_V2 y los
 * helpers itemsPorNaturaleza / categoriasV2.
 *
 * Basado en Manual de Señalamiento Vertical (MSV 2017, DNV/AAC) y
 * nomenclatura operativa de DVBA Zona VI.
 *
 * USO LEGACY (v2):
 *   DVBA_TIPOS.categorias       → array de categorías con icono y label
 *   DVBA_TIPOS.items(cat)       → array de strings para una categoría
 *   DVBA_TIPOS.todos()          → array plano de todos los items
 *   DVBA_TIPOS.categoriaDe(tipoStr) → infiere categoría del ítem
 *   DVBA_TIPOS.ARBOL            → estructura completa
 *
 * USO NUEVO (v3 · modelo Tipos v2):
 *   DVBA_TIPOS.categoriasV2         → categorías del modelo v2 (8, sin mantenimiento)
 *   DVBA_TIPOS.itemsPorNaturaleza(cat, nat)  → items filtrados por naturaleza
 *   DVBA_TIPOS.categoriaDeV2(tipoStr)        → infiere categoría en modelo v2
 *   DVBA_TIPOS.naturalezaDelItem(tipoStr)    → 'relevamiento' | 'tarea' | null
 *   DVBA_TIPOS.ARBOL_V2                      → estructura nueva completa
 */

const DVBA_TIPOS = (() => {

  // ── Árbol de tipos (10 categorías) ─────────────────────────────────
  const ARBOL = {

    // ═══ A. RELEVAMIENTO (estado de algo físico) ═══

    calzada: {
      icon: '🛣️',
      label: 'Calzada',
      items: [
        'Bache',
        'Bache crítico',
        'Pavimento fisurado',
        'Pavimento ondulado',
        'Pavimento descascarado',
        'Borde de calzada deteriorado',
        'Huellas (camino tierra)',
        'Anegamiento por mala conformación',
        'Erosión de calzada (camino tierra)',
        'Calzada en buen estado',
      ]
    },

    drenaje: {
      icon: '💧',
      label: 'Banquinas y drenaje',
      items: [
        'Banquina deteriorada',
        'Cuneta obstruida',
        'Cuneta dañada',
        'Alcantarilla tapada',
        'Alcantarilla dañada',
        'Erosión de talud',
      ]
    },

    estructura: {
      icon: '🌉',
      label: 'Puentes y estructuras',
      items: [
        'Puente — fisura tablero',
        'Puente — fisura estribo',
        'Puente — junta deteriorada',
        'Puente — baranda dañada',
        'Puente — deterioro tablero',
        'Alcantarilla mayor',
        'Muro de contención dañado',
      ]
    },

    senial_vertical: {
      icon: '🚧',
      label: 'Señalización vertical',
      items: [
        // Preventivas (P-)
        'Curva a la derecha (P-)',
        'Curva a la izquierda (P-)',
        'Curvas sucesivas (P-)',
        'Pendiente peligrosa (P-)',
        'Estrechamiento de calzada (P-)',
        'Calzada sinuosa (P-)',
        'Desnivel / badén (P-)',
        'Cruce ferroviario con barreras (P-)',
        'Cruce ferroviario sin barreras (P-)',
        'Puente angosto (P-16)',
        'Cruce de animales (P-)',
        'Cruce de maquinaria agrícola (P-)',
        'Zona de vientos (P-)',
        'Zona de neblina (P-)',
        'Pavimento deslizante (P-)',
        'Obras en la vía (P-)',
        'Semáforo adelante (P-)',
        'Paso a nivel (P-)',
        'Chevrones direccionales (P-31)',
        // Reglamentarias (R-)
        'Señal PARE (R-1)',
        'Señal CEDA EL PASO (R-2)',
        'Velocidad máxima (R-)',
        'Fin de límite de velocidad (R-)',
        'Prohibido adelantar (R-)',
        'Fin de prohibición de adelantamiento (R-)',
        'Prohibido el paso (R-)',
        'Sentido único (R-)',
        'Doble circulación (R-)',
        'Peso máximo (R-)',
        'Altura máxima (R-12)',
        'Ancho máximo (R-)',
        'Longitud máxima (R-)',
        // Informativas (I-)
        'Mojón kilométrico (I-)',
        'Cartel de distancia y destinos (I-)',
        'Acceso a localidad (I-)',
        'Zona urbana (I-)',
        'Encrucijada cruce en + (I-)',
        'Encrucijada cruce en T (I-)',
        'Bifurcación en Y (I-)',
        'Incorporación de carretera (I-)',
        'Salida de camiones (I-)',
        'Hospital / asistencia médica (I-)',
        'Área de servicio (I-)',
        'Zona escolar (I-)',
        'Paso peatonal (I-)',
        // Elementos auxiliares
        'Guardarrail (tipo Flex Beam)',
        'Delineador',
        'Cebras (cabezal alcantarilla / puente)',
      ]
    },

    demarcacion: {
      icon: '🛑',
      label: 'Demarcación horizontal',
      items: [
        'Eje borrado',
        'Demarcación lateral borrada',
        'Tachones / tachas faltantes',
        'Demarcación inexistente',
        'Línea de frenado borrada',
        'Senda peatonal borrada',
      ]
    },

    iluminacion: {
      icon: '💡',
      label: 'Iluminación',
      items: [
        'Columna dañada',
        'Columna faltante',
        'Lámpara fundida',
        'Fallo eléctrico en ramal',
        'Tendido eléctrico afectado',
      ]
    },

    entorno: {
      icon: '🌿',
      label: 'Entorno',
      items: [
        'Vegetación a desmalezar',
        'Inundación / anegamiento',
        'Derrumbe / corte de ruta',
        'Árbol caído',
        'Acceso a campo / tranquera dañada',
        'Animal muerto en calzada',
        'Vehículo abandonado',
      ]
    },

    seguridad: {
      icon: '🚨',
      label: 'Seguridad vial',
      items: [
        'Siniestro vial',
        'Punto negro (accidentología)',
        'Zona peligrosa sin señalizar',
        'Zona de curva peligrosa',
        'Emergencia vial',
        'Cámara de control / fotomulta',
        'Radar de velocidad',
      ]
    },

    // ═══ B. TAREA / ACCIÓN ═══

    mantenimiento: {
      icon: '🚜',
      label: 'Mantenimiento / Tarea',
      items: [
        // Caminos rurales (motoniveladora / mantenimiento general)
        'Mantenimiento de caminos rurales',
        'Reconformado de tierra',
        // Limpieza vegetal
        'Desmalezado manual',
        'Desmalezado mecánico',
        'Poda de árboles',
        // Drenaje
        'Limpieza de cuneta',
        'Limpieza de canal',
        'Limpieza de alcantarilla',
        // Bacheo y reparaciones de calzada
        'Bacheo con material en frío',
        'Bacheo con material en caliente',
        'Bacheo profundo',
        'Sellado de fisuras',
        'Repavimentación',
        'Riego asfáltico',
        // Demarcación y señalización
        'Repintado de demarcación',
        'Reposición de señal',
        'Reposición de mojón',
        'Reposición de tachas',
        // Estabilización de superficie (caminos)
        'Mejoramiento con dolomita',
        'Mejoramiento con suelo cal',
        // Otros mantenimientos
        'Reparación de baranda / guardarrail',
        'Limpieza general de ramal',
        'Otra tarea de mantenimiento',
      ]
    },

    // ═══ C. CATCH-ALL ═══

    otro: {
      icon: '📝',
      label: 'Otro',
      items: ['Otro']
    },
  };

  // ═══════════════════════════════════════════════════════════════════
  // MODELO TIPOS v2 · ARBOL_V2
  // ═══════════════════════════════════════════════════════════════════
  // 8 categorías de ELEMENTO (sin 'mantenimiento' como categoría propia).
  // Cada categoría tiene:
  //   · icon, label
  //   · items_relev : ítems observables (naturaleza='relevamiento')
  //   · items_tarea : ítems ejecutables (naturaleza='tarea')
  // 'seguridad' solo tiene items_relev por diseño.
  const ARBOL_V2 = {

    calzada: {
      icon: '🛣️',
      label: 'Calzada',
      items_relev: [
        'Bache',
        'Bache crítico',
        'Pavimento fisurado',
        'Pavimento ondulado',
        'Pavimento descascarado',
        'Borde de calzada deteriorado',
        'Huellas (camino tierra)',
        'Anegamiento por mala conformación',
        'Erosión de calzada (camino tierra)',
        'Calzada en buen estado',
      ],
      items_tarea: [
        'Mantenimiento de caminos rurales',
        'Reconformado de tierra',
        'Bacheo con material en frío',
        'Bacheo con material en caliente',
        'Bacheo profundo',
        'Sellado de fisuras',
        'Repavimentación',
        'Riego asfáltico',
        'Mejoramiento con dolomita',
        'Mejoramiento con suelo cal',
      ],
    },

    drenaje: {
      icon: '💧',
      label: 'Banquinas y drenaje',
      items_relev: [
        'Banquina deteriorada',
        'Cuneta obstruida',
        'Cuneta dañada',
        'Alcantarilla tapada',
        'Alcantarilla dañada',
        'Erosión de talud',
      ],
      items_tarea: [
        'Limpieza de cuneta',
        'Limpieza de canal',
        'Limpieza de alcantarilla',
        'Reparación de cuneta',
        'Reparación de alcantarilla',
        'Reconformado de banquina',
      ],
    },

    estructura: {
      icon: '🌉',
      label: 'Puentes y estructuras',
      items_relev: [
        'Puente — fisura tablero',
        'Puente — fisura estribo',
        'Puente — junta deteriorada',
        'Puente — baranda dañada',
        'Puente — deterioro tablero',
        'Alcantarilla mayor',
        'Muro de contención dañado',
      ],
      items_tarea: [
        'Reparación de puente (tablero)',
        'Reparación de puente (estribo)',
        'Reparación de junta',
        'Reparación de baranda / guardarrail',
        'Reparación de alcantarilla mayor',
        'Reparación de muro de contención',
      ],
    },

    senial_vertical: {
      icon: '🚧',
      label: 'Señalización vertical',
      items_relev: [
        // Preventivas (P-)
        'Curva a la derecha (P-)',
        'Curva a la izquierda (P-)',
        'Curvas sucesivas (P-)',
        'Pendiente peligrosa (P-)',
        'Estrechamiento de calzada (P-)',
        'Calzada sinuosa (P-)',
        'Desnivel / badén (P-)',
        'Cruce ferroviario con barreras (P-)',
        'Cruce ferroviario sin barreras (P-)',
        'Puente angosto (P-16)',
        'Cruce de animales (P-)',
        'Cruce de maquinaria agrícola (P-)',
        'Zona de vientos (P-)',
        'Zona de neblina (P-)',
        'Pavimento deslizante (P-)',
        'Obras en la vía (P-)',
        'Semáforo adelante (P-)',
        'Paso a nivel (P-)',
        'Chevrones direccionales (P-31)',
        // Reglamentarias (R-)
        'Señal PARE (R-1)',
        'Señal CEDA EL PASO (R-2)',
        'Velocidad máxima (R-)',
        'Fin de límite de velocidad (R-)',
        'Prohibido adelantar (R-)',
        'Fin de prohibición de adelantamiento (R-)',
        'Prohibido el paso (R-)',
        'Sentido único (R-)',
        'Doble circulación (R-)',
        'Peso máximo (R-)',
        'Altura máxima (R-12)',
        'Ancho máximo (R-)',
        'Longitud máxima (R-)',
        // Informativas (I-)
        'Mojón kilométrico (I-)',
        'Cartel de distancia y destinos (I-)',
        'Acceso a localidad (I-)',
        'Zona urbana (I-)',
        'Encrucijada cruce en + (I-)',
        'Encrucijada cruce en T (I-)',
        'Bifurcación en Y (I-)',
        'Incorporación de carretera (I-)',
        'Salida de camiones (I-)',
        'Hospital / asistencia médica (I-)',
        'Área de servicio (I-)',
        'Zona escolar (I-)',
        'Paso peatonal (I-)',
        // Elementos auxiliares
        'Guardarrail (tipo Flex Beam)',
        'Delineador',
        'Cebras (cabezal alcantarilla / puente)',
      ],
      items_tarea: [
        'Reposición de señal',
        'Reposición de mojón',
        'Colocación de guardarrail',
        'Colocación de delineador',
        'Colocación de cebras (cabezal alcantarilla / puente)',
        'Repintado de cebras',
      ],
    },

    demarcacion: {
      icon: '🛑',
      label: 'Demarcación horizontal',
      items_relev: [
        'Eje borrado',
        'Demarcación lateral borrada',
        'Tachones / tachas faltantes',
        'Demarcación inexistente',
        'Línea de frenado borrada',
        'Senda peatonal borrada',
      ],
      items_tarea: [
        'Repintado de eje',
        'Repintado de demarcación lateral',
        'Repintado de senda peatonal',
        'Repintado de línea de frenado',
        'Reposición de tachas',
      ],
    },

    iluminacion: {
      icon: '💡',
      label: 'Iluminación',
      items_relev: [
        'Columna dañada',
        'Columna faltante',
        'Lámpara fundida',
        'Fallo eléctrico en ramal',
        'Tendido eléctrico afectado',
      ],
      items_tarea: [
        'Reposición de columna',
        'Reposición de lámpara',
        'Reparación de tendido eléctrico',
        'Migración a LED',
      ],
    },

    entorno: {
      icon: '🌿',
      label: 'Entorno',
      items_relev: [
        'Vegetación a desmalezar',
        'Inundación / anegamiento',
        'Derrumbe / corte de ruta',
        'Árbol caído',
        'Acceso a campo / tranquera dañada',
        'Animal muerto en calzada',
        'Vehículo abandonado',
      ],
      items_tarea: [
        'Desmalezado manual',
        'Desmalezado mecánico',
        'Poda de árboles',
        'Limpieza general de ramal',
        'Retiro de árbol caído',
        'Retiro de animal',
        'Retiro de vehículo abandonado',
      ],
    },

    seguridad: {
      icon: '🚨',
      label: 'Seguridad vial',
      items_relev: [
        'Siniestro vial',
        'Punto negro (accidentología)',
        'Zona peligrosa sin señalizar',
        'Zona de curva peligrosa',
        'Emergencia vial',
        'Cámara de control / fotomulta',
        'Radar de velocidad',
      ],
      items_tarea: [],   // por diseño: seguridad solo se releva
    },

    otro: {
      icon: '📝',
      label: 'Otro',
      items_relev: ['Otro'],
      items_tarea: ['Otra tarea de mantenimiento'],
    },
  };

  // ── API pública ────────────────────────────────────────────────────
  const categorias = Object.entries(ARBOL).map(([key, v]) => ({
    key,
    icon : v.icon,
    label: v.label,
  }));

  function items(catKey) {
    return (ARBOL[catKey] || { items: [] }).items;
  }

  function todos() {
    return Object.values(ARBOL).flatMap(c => c.items);
  }

  function normStr(s) {
    // Escape Unicode explícito para combining diacritical marks (U+0300..U+036F)
    // Necesario porque el carácter literal puede no preservarse bien entre Windows/Linux/Mobile
    return (s || '').toLowerCase()
      .normalize('NFD').replace(new RegExp('[\\u0300-\\u036f]', 'g'), '')
      .replace(/[^a-z0-9 ]/g, ' ').replace(/\s+/g, ' ').trim();
  }

  // Dado un nombre de tipo (string), devuelve la key de su categoría
  // Ej: categoriaDe('Bache crítico') → 'calzada'
  function categoriaDe(tipoStr) {
    if (!tipoStr) return null;
    const norm = normStr(tipoStr);
    for (const [catKey, cat] of Object.entries(ARBOL)) {
      for (const it of cat.items) {
        if (normStr(it) === norm) return catKey;
      }
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════
  // MODELO TIPOS v2 · API pública
  // ═══════════════════════════════════════════════════════════════════

  // Categorías del modelo v2 (8, sin 'mantenimiento' plana).
  const categoriasV2 = Object.entries(ARBOL_V2).map(([key, v]) => ({
    key,
    icon : v.icon,
    label: v.label,
    // hint: cuáles naturalezas tienen ítems dentro de esta categoría
    tieneRelev : (v.items_relev || []).length > 0,
    tieneTarea : (v.items_tarea || []).length > 0,
  }));

  // Ítems filtrados por categoría + naturaleza.
  // itemsPorNaturaleza('senial_vertical', 'tarea')
  //   → ['Reposición de señal', 'Reposición de mojón', ...]
  function itemsPorNaturaleza(catKey, naturaleza) {
    const c = ARBOL_V2[catKey];
    if (!c) return [];
    if (naturaleza === 'tarea') return (c.items_tarea || []).slice();
    return (c.items_relev || []).slice();
  }

  // Todos los ítems de una naturaleza dada, plano
  function todosPorNaturaleza(naturaleza) {
    return Object.values(ARBOL_V2).flatMap(c =>
      naturaleza === 'tarea' ? (c.items_tarea || []) : (c.items_relev || [])
    );
  }

  // Dado un nombre de tipo, infiere su categoría en el modelo v2.
  // Busca en items_relev + items_tarea de todas las categorías.
  function categoriaDeV2(tipoStr) {
    if (!tipoStr) return null;
    const norm = normStr(tipoStr);
    for (const [catKey, cat] of Object.entries(ARBOL_V2)) {
      const bag = [].concat(cat.items_relev || [], cat.items_tarea || []);
      for (const it of bag) {
        if (normStr(it) === norm) return catKey;
      }
    }
    // Fallback: probar con el árbol legacy (registros viejos)
    return categoriaDe(tipoStr);
  }

  // Dado un nombre de tipo, infiere si es de naturaleza 'relevamiento' o
  // 'tarea'. Devuelve null si no matchea con ningún ítem conocido.
  function naturalezaDelItem(tipoStr) {
    if (!tipoStr) return null;
    const norm = normStr(tipoStr);
    for (const cat of Object.values(ARBOL_V2)) {
      if ((cat.items_relev || []).some(it => normStr(it) === norm)) return 'relevamiento';
      if ((cat.items_tarea || []).some(it => normStr(it) === norm)) return 'tarea';
    }
    return null;
  }

  return {
    // v2 (legacy) — sigue funcionando
    categorias, items, todos, normStr, categoriaDe, ARBOL,
    // v3 · Modelo Tipos v2 (naturaleza × categoría × ítem)
    categoriasV2,
    itemsPorNaturaleza,
    todosPorNaturaleza,
    categoriaDeV2,
    naturalezaDelItem,
    ARBOL_V2,
  };
})();

if (typeof module !== 'undefined') module.exports = DVBA_TIPOS;
