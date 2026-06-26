/**
 * dvba_tipos.js  — Módulo compartido de tipos de registro
 * DVBA · Zona Departamental VI Saladillo · v2.0 (2026-06-24)
 *
 * Reorganizado en 10 categorías separando RELEVAMIENTO (estado de un elemento)
 * de TAREA (mantenimiento que se hizo o hay que hacer). Cada categoría tiene
 * su propio set de estados válidos en datos/dvba_estados.js.
 *
 * Basado en Manual de Señalamiento Vertical (MSV 2017, DNV/AAC) y
 * nomenclatura operativa de DVBA Zona VI.
 *
 * USO:
 *   DVBA_TIPOS.categorias       → array de categorías con icono y label
 *   DVBA_TIPOS.items(cat)       → array de strings para una categoría
 *   DVBA_TIPOS.todos()          → array plano de todos los items
 *   DVBA_TIPOS.normStr(s)       → normaliza tilde/mayúscula para comparar
 *   DVBA_TIPOS.categoriaDe(tipoStr) → infiere categoría del ítem (devuelve cat key)
 *   DVBA_TIPOS.ARBOL            → estructura completa (lectura)
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
        'Guardarrail',
        'Delineador',
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
        // Caminos de tierra (motoniveladora)
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

  return { categorias, items, todos, normStr, categoriaDe, ARBOL };
})();

if (typeof module !== 'undefined') module.exports = DVBA_TIPOS;
