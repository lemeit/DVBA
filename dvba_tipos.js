/**
 * dvba_tipos.js  — Módulo compartido de tipos de registro
 * DVBA · Zona Departamental VI Saladillo
 * Basado en Manual de Señalamiento Vertical (MSV 2017, DNV/AAC)
 * y nomenclatura operativa de vialidad provincial.
 *
 * Uso:
 *   DVBA_TIPOS.categorias   → array de categorías con icono y label
 *   DVBA_TIPOS.items(cat)   → array de strings para una categoría
 *   DVBA_TIPOS.todos()      → array plano de todos los items
 *   DVBA_TIPOS.normStr(s)   → normaliza tilde/mayúscula para comparar
 */

const DVBA_TIPOS = (() => {

  // ── Árbol de tipos ──────────────────────────────────────────────
  // Claves de categoría  →  { icon, label, items[] }
  const ARBOL = {
    calzada: {
      icon: '🛣️',
      label: 'Calzada',
      items: [
        'Bache',
        'Bache crítico',
        'Calzada dañada',
        'Pavimento fisurado',
        'Pavimento ondulado',
        'Calzada de tierra deteriorada',
        'Borde de calzada deteriorado',
        'Pavimento asfáltico',
        'Calzada de hormigón',
      ]
    },
    drenaje: {
      icon: '💧',
      label: 'Banquinas y drenaje',
      items: [
        'Banquina deteriorada',
        'Cuneta obstruida',
        'Alcantarilla tapada',
        'Alcantarilla dañada',
        'Erosión de talud',
        'Zanja / cuneta dañada',
      ]
    },
    senial_preventiva: {
      icon: '⚠️',
      label: 'Señal preventiva (P-)',
      items: [
        // MSV 2017 — Señales Preventivas — Advertencia de peligro y características
        'Curva a la derecha',
        'Curva a la izquierda',
        'Curvas sucesivas (derecha)',
        'Curvas sucesivas (izquierda)',
        'Curva y contracurva',
        'Pendiente peligrosa',
        'Estrechamiento de calzada',
        'Estrechamiento (izquierda)',
        'Estrechamiento (derecha)',
        'Calzada sinuosa',
        'Desnivel / badén',
        'Cruce ferroviario con barreras',        // MSV: P-xx Cruce ferroviario
        'Cruce ferroviario sin barreras',
        'Puente angosto',                         // MSV: P-16
        'Cruce de animales',
        'Cruce de maquinaria agrícola',
        'Zona de vientos',
        'Zona de neblina',
        'Pavimento deslizante',
        'Obras en la vía (preventiva)',
        'Semáforo adelante',
        'Paso a nivel',
        'Chevrones direccionales (P-31)',          // MSV: P-31 Flecha direccional
      ]
    },
    senial_reglamentaria: {
      icon: '🚫',
      label: 'Señal reglamentaria (R-)',
      items: [
        // Prioridad  (MSV: Señales de Prioridad)
        'Señal PARE (R-1)',                        // código MSV con guión
        'Señal CEDA EL PASO (R-2)',
        'Fin de prescripción de prioridad',
        // Prohibición / Restricción
        'Velocidad máxima',
        'Fin de límite de velocidad',
        'Prohibido adelantar',
        'Fin de prohibición de adelantamiento',
        'Prohibido el paso',
        'Sentido único',
        'Doble circulación',
        'Peso máximo',
        'Altura máxima (R-12)',                    // MSV: R-12
        'Ancho máximo',
        'Longitud máxima',
      ]
    },
    senial_informativa: {
      icon: 'ℹ️',
      label: 'Señal informativa (I-)',
      items: [
        // Nomenclatura y destinos
        'Mojón kilométrico',
        'Cartel de distancia y destinos',
        'Acceso a localidad',
        'Zona urbana',
        // Características de la vía
        'Encrucijada (cruce en +)',
        'Encrucijada (cruce en T)',
        'Bifurcación en Y',
        'Incorporación de carretera',
        'Salida de camiones',
        // Turísticas y de servicios
        'Hospital / asistencia médica',
        'Área de servicio',
        'Zona escolar / establecimiento educativo',
        'Paso peatonal',
      ]
    },
    senial_estado: {
      icon: '🔧',
      label: 'Estado de señal',
      items: [
        'Señal faltante',
        'Señal dañada / ilegible',
        'Señal caída / volcada',
        'Señal mal ubicada',
        'Demarcación horizontal borrada',
        'Tachones / tachas faltantes',
        'Guardarrail dañado',
        'Guardarrail faltante',
        'Delineador deteriorado',
      ]
    },
    estructura: {
      icon: '🌉',
      label: 'Estructura',
      items: [
        'Puente / viaducto',
        'Puente — fisura',
        'Puente — deterioro tablero',
        'Alcantarilla / drenaje',
        'Muro de contención dañado',
      ]
    },
    entorno: {
      icon: '🌿',
      label: 'Entorno',
      items: [
        'Vegetación / desmalezado',
        'Inundación / anegamiento',
        'Derrumbe / corte de ruta',
        'Árbol caído',
        'Acceso a campo / tranquera',
        'Camino vecinal / rural',
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
        'Obra en ejecución',
        'Obra terminada',
        'Emergencia vial',
      ]
    },
    otro: {
      icon: '📝',
      label: 'Otro',
      items: ['Otro']
    }
  };

  // ── API pública ─────────────────────────────────────────────────
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
    return (s || '').toLowerCase()
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9 ]/g, ' ').trim();
  }

  return { categorias, items, todos, normStr, ARBOL };
})();

// Soporte CommonJS / ES module básico para uso en Node si hace falta
if (typeof module !== 'undefined') module.exports = DVBA_TIPOS;
