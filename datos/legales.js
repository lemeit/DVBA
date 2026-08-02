/* ══════════════════════════════════════════════════════════════════
   DVBA · Módulo LEGALES compartido (v8.52)

   Contenido único de Acerca de, Términos, Privacidad, Tecnologías y
   Permisos PWA (cámara, ubicación, storage). Se importa desde los 6
   HTMLs (index, reportes, partes_diarios, admin_usuarios, dvba_campo,
   dvba_campo_lite) para garantizar que todos digan lo mismo.

   Uso desde cualquier HTML:

       <script src="datos/legales.js"></script>
       // en el footer:
       <a href="#" onclick="DVBA_LEGAL.abrir('acerca');return false">Acerca</a>
       <a href="#" onclick="DVBA_LEGAL.abrir('terminos');return false">Términos</a>
       <a href="#" onclick="DVBA_LEGAL.abrir('privacidad');return false">Privacidad</a>

   El modal se inyecta automáticamente al cargar la página.
   ══════════════════════════════════════════════════════════════════ */
(function(global){
'use strict';

const VER_APP     = 'v8.52';
const MAIL_INST   = 'lulamaita@vialidad.gba.gov.ar';
const MAIL_PERS   = 'lucianolamaita@gmail.com';

// ═══════════════════════════════════════════════════════════════════════════════
// CONTENIDOS · misma copia en todos los sitios
// ═══════════════════════════════════════════════════════════════════════════════
const CONTENIDOS = {
  acerca: {
    tit: 'Acerca de SIG Vial PBA<sup style="font-size:.65em;color:#c47a00;letter-spacing:0">β</sup>',
    body: `
      <div style="background:#fef6e4;border-left:3px solid #c47a00;padding:10px 12px;border-radius:4px;margin-bottom:14px;font-size:12px;line-height:1.55;color:#7a4400">
        <b>Versión BETA · en desarrollo activo.</b><br>
        Sistema piloto desarrollado para el Departamento Zona VI Saladillo (Dirección de Vialidad de la Provincia de Buenos Aires). Aún no es una versión oficial de la DVBA; se presenta al <b>XLI Concurso Vial DVBA 2026</b> como propuesta técnica.
      </div>

      <p><b>¿Qué es este sistema?</b></p>
      <p>SIG Vial PBA es un sistema integral de <b>relevamiento, cartografía y gestión</b> de la Red Vial Provincial. Combina un portal web para el escritorio y una app móvil (PWA) para uso en campo, con backend en la nube y control de acceso por rol y zona.</p>

      <p><b>Alcance actual</b></p>
      <ul>
        <li>Portal web con mapa Leaflet + Red Vial Provincial Primaria (15 RPs) + Secundaria (100 caminos secundarios).</li>
        <li>App móvil PWA con 2 modos (Básico + Avanzado) para carga de tareas desde campo.</li>
        <li>Módulo Plan de Seguridad en la Circulación con partes diarios y vehículos.</li>
        <li>Reportes técnicos de la Red Vial (CSV + PDF con logo institucional).</li>
        <li>Panel administrativo con gestión de usuarios multi-zona.</li>
        <li>Diseñado para escalar a las 12 zonas viales de la DVBA.</li>
      </ul>

      <p><b>Autoría</b></p>
      <p style="margin-top:4px">
        <b>Ing. Luciano Lamaita</b><br>
        División Técnica · Departamento Zona VI Saladillo
      </p>

      <p><b>Contacto</b></p>
      <p style="margin-top:4px">
        Institucional: <a href="mailto:${MAIL_INST}" style="color:#007e8c">${MAIL_INST}</a><br>
        Personal: <a href="mailto:${MAIL_PERS}" style="color:#007e8c">${MAIL_PERS}</a>
      </p>

      <p><b>Institución</b></p>
      <p style="margin-top:4px">Dirección de Vialidad de la Provincia de Buenos Aires (DVBA) · Departamento Zona VI Saladillo. Cobertura: 8 partidos (Saladillo, Gral. Alvear, Gral. Las Heras, Lobos, Roque Pérez, Las Flores, Navarro, 25 de Mayo).</p>

      <p style="margin-top:14px;font-size:11px;color:#666;text-align:center;font-style:italic;border-top:1px solid #e0e0e0;padding-top:8px">
        Versión ${VER_APP} · La consulta del mapa y datos oficiales es pública.
      </p>
    `
  },

  terminos: {
    tit: 'Términos de uso',
    body: `
      <p><b>Uso interno institucional</b></p>
      <p>Esta aplicación es de uso preferente del personal autorizado de la Dirección de Vialidad de la Provincia de Buenos Aires (DVBA), en cualquiera de sus zonas viales. La consulta pública del mapa y datos oficiales de la Red Vial no requiere autenticación.</p>

      <p><b>Carga de información</b></p>
      <p>Los datos aquí registrados forman parte del sistema de relevamiento y gestión vial. La información cargada debe reflejar fielmente las tareas ejecutadas en campo, así como los recursos utilizados. El acceso para carga y edición está restringido por autenticación con rol y zona asignados.</p>

      <p><b>Responsabilidad</b></p>
      <p>Cualquier uso indebido, alteración maliciosa o divulgación no autorizada de la información puede constituir falta grave conforme a la normativa vigente. El acceso al sistema queda registrado en logs de auditoría.</p>

      <p><b>Sin garantía</b></p>
      <p>El sistema se ofrece "tal cual", sin garantía comercial. Es una versión <b>BETA en desarrollo</b>; su función es asistir la gestión operativa y no reemplaza los registros oficiales requeridos por las Gerencias de la DVBA.</p>

      <p><b>Cambios de estos términos</b></p>
      <p>Estos términos pueden actualizarse durante la evolución del sistema. Se notificará mediante el mismo canal (footer del portal) cualquier cambio significativo.</p>
    `
  },

  privacidad: {
    tit: 'Política de privacidad',
    body: `
      <p><b>Datos que recopila el sistema</b></p>
      <ul>
        <li><b>Sesión</b>: email del usuario, timestamps de acceso, rol y zona asignados.</li>
        <li><b>Operativos</b>: fechas, rutas y caminos relevados, tareas, equipos utilizados, observaciones, fotografías.</li>
        <li><b>Metadatos técnicos</b>: coordenadas GPS, hora de captura, orientación EXIF de las imágenes.</li>
      </ul>

      <p><b>Almacenamiento y seguridad</b></p>
      <p>Los datos se almacenan en <b>Supabase Inc.</b> (infraestructura AWS con servidores en Europa), cifrados <b>en tránsito</b> (TLS) y <b>en reposo</b>. El acceso está restringido mediante políticas <b>Row-Level Security</b> (RLS) que aplican filtros automáticos por rol y zona a nivel de base de datos.</p>

      <p><b>Fotografías</b></p>
      <p>Las imágenes cargadas se guardan en <b>Supabase Storage</b> con URLs públicas de solo lectura (no listables). Al aplicar el sello institucional se embeben metadatos EXIF de fecha, hora y coordenadas para trazabilidad.</p>

      <p><b>Servicios externos</b></p>
      <p>El sistema utiliza:</p>
      <ul>
        <li><b>OpenStreetMap</b> para la cartografía base del mapa.</li>
        <li><b>Google Maps</b> para verificación puntual de coordenadas al escanear el QR del sello.</li>
        <li><b>GitHub Pages</b> para hosting estático del frontend.</li>
      </ul>
      <p>Ningún dato personal se comparte con estos servicios más allá de la solicitud HTTP estándar (IP, user-agent).</p>

      <p><b>Retención y baja</b></p>
      <p>Los datos operativos se conservan de forma indefinida para fines históricos de gestión vial. Si un usuario solicita la baja de su cuenta, su email se anonimiza pero los registros operativos asociados permanecen (auditoría). Para solicitar baja, escribir a <a href="mailto:${MAIL_INST}" style="color:#007e8c">${MAIL_INST}</a>.</p>

      <p><b>Datos públicos vs. restringidos</b></p>
      <ul>
        <li><b>Público (sin login)</b>: mapa, red vial oficial, reportes técnicos de RPs y Caminos.</li>
        <li><b>Restringido (requiere login)</b>: fotografías de tareas, edición de registros, panel administrativo.</li>
      </ul>
    `
  },

  permisos: {
    tit: 'Permisos que solicita la app',
    body: `
      <div style="background:#e6f6fa;border-left:3px solid #00aec3;padding:10px 12px;border-radius:4px;margin-bottom:14px;font-size:12px;line-height:1.55;color:#004050">
        <b>Tranquilidad para el usuario:</b> la app pide permisos solo para las funciones estrictamente necesarias del trabajo en campo. Todos los datos van a servidores DVBA/Supabase con cifrado TLS. Nada se comparte con terceros con fines comerciales.
      </div>

      <p><b>📷 Cámara</b></p>
      <p>Se solicita <b>solo cuando el operario toca "Sacar foto"</b>. Se usa exclusivamente para capturar la fotografía de la tarea vial (bache, corte de pasto, señalización, etc.). La foto queda embebida con metadatos GPS y se envía cifrada al servidor institucional.</p>

      <p><b>📍 Ubicación (GPS)</b></p>
      <p>Se solicita al iniciar la sesión de campo para <b>geolocalizar automáticamente cada foto</b> (latitud, longitud, altitud, precisión). La ubicación se guarda solo dentro del registro operativo, no se comparte en tiempo real con terceros ni se usa para rastreo del operario fuera de las tareas.</p>

      <p><b>💾 Almacenamiento local</b></p>
      <p>La app usa el almacenamiento del navegador para:</p>
      <ul>
        <li>Cachear la aplicación y datos cartográficos (para funcionar offline).</li>
        <li>Guardar temporalmente fotos y datos pendientes cuando no hay señal (cola offline).</li>
        <li>Recordar la sesión iniciada.</li>
      </ul>

      <p><b>🌐 Conexión a Internet</b></p>
      <p>Necesaria para sincronizar tareas al servidor. Cuando no hay señal, la app <b>guarda todo localmente</b> y envía automáticamente al recuperar conexión.</p>

      <p><b>Sin publicidad ni tracking</b></p>
      <p>El sistema <b>no muestra publicidad</b>, <b>no rastrea comportamiento</b> y <b>no vende datos</b> a terceros. Es una herramienta de trabajo institucional.</p>

      <p style="margin-top:14px;font-size:11px;color:#666;text-align:center;font-style:italic;border-top:1px solid #e0e0e0;padding-top:8px">
        Si tenés dudas o querés revocar algún permiso, entrá a: Configuración del navegador → Sitios web → SIG Vial PBA → Permisos.
      </p>
    `
  }
};

// ═══════════════════════════════════════════════════════════════════════════════
// INYECCIÓN AUTOMÁTICA DEL MODAL AL CARGAR LA PÁGINA
// ═══════════════════════════════════════════════════════════════════════════════
function _inyectarModal(){
  if (document.getElementById('dvba-legal-modal')) return;  // ya inyectado
  const style = document.createElement('style');
  style.textContent = `
    #dvba-legal-modal{position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:99998;display:none;align-items:center;justify-content:center;padding:16px;box-sizing:border-box;font-family:Roboto,'Segoe UI',Arial,sans-serif}
    #dvba-legal-modal.on{display:flex}
    #dvba-legal-modal .lm-box{background:#fff;width:100%;max-width:640px;max-height:90vh;border-radius:10px;display:flex;flex-direction:column;box-shadow:0 20px 60px rgba(0,0,0,.35);overflow:hidden}
    #dvba-legal-modal .lm-h{background:linear-gradient(135deg,#00aec3,#007e8c);color:#fff;padding:12px 20px;display:flex;align-items:center;justify-content:space-between;gap:10px}
    #dvba-legal-modal .lm-h h3{margin:0;font-size:15px;font-family:'Encode Sans',Arial,sans-serif;font-weight:700}
    #dvba-legal-modal .lm-h button{background:transparent;border:0;color:#fff;font-size:22px;cursor:pointer;padding:0 6px;line-height:1}
    #dvba-legal-modal .lm-tabs{display:flex;gap:2px;background:#eef2f5;padding:6px 8px;border-bottom:1px solid #e0e0e0;flex-wrap:wrap}
    #dvba-legal-modal .lm-tab{padding:6px 12px;background:#fff;color:#838383;border:1px solid #e0e0e0;border-radius:4px;cursor:pointer;font-size:11px;font-weight:600;font-family:inherit}
    #dvba-legal-modal .lm-tab.on{background:#00aec3;color:#fff;border-color:#007e8c}
    #dvba-legal-modal .lm-body{overflow-y:auto;padding:18px 22px;flex:1;font-size:12.5px;line-height:1.55;color:#333}
    #dvba-legal-modal .lm-body p{margin:0 0 10px}
    #dvba-legal-modal .lm-body ul{margin:0 0 10px 22px;padding:0}
    #dvba-legal-modal .lm-body li{margin-bottom:4px}
    #dvba-legal-modal .lm-body a{color:#007e8c;text-decoration:none}
    #dvba-legal-modal .lm-body a:hover{text-decoration:underline}
    #dvba-legal-modal .lm-f{padding:10px 20px;background:#f0f0f0;border-top:1px solid #e0e0e0;display:flex;justify-content:flex-end}
    #dvba-legal-modal .lm-f button{padding:8px 18px;background:#00aec3;color:#fff;border:0;border-radius:5px;font-size:12px;font-weight:700;cursor:pointer;font-family:inherit}
    #dvba-legal-modal .lm-f button:hover{background:#007e8c}
  `;
  document.head.appendChild(style);

  const div = document.createElement('div');
  div.id = 'dvba-legal-modal';
  div.innerHTML = `
    <div class="lm-box">
      <div class="lm-h">
        <h3id="lm-titulo">Acerca de</h3>
        <button onclick="DVBA_LEGAL.cerrar()" title="Cerrar">×</button>
      </div>
      <div class="lm-tabs">
        <button class="lm-tab" data-tab="acerca" onclick="DVBA_LEGAL.abrir('acerca')">Acerca de</button>
        <button class="lm-tab" data-tab="terminos" onclick="DVBA_LEGAL.abrir('terminos')">Términos</button>
        <button class="lm-tab" data-tab="privacidad" onclick="DVBA_LEGAL.abrir('privacidad')">Privacidad</button>
        <button class="lm-tab" data-tab="permisos" onclick="DVBA_LEGAL.abrir('permisos')">Permisos</button>
      </div>
      <div class="lm-body" id="lm-body">
      </div>
      <div class="lm-f">
        <button onclick="DVBA_LEGAL.cerrar()">Cerrar</button>
      </div>
    </div>
  `;
  document.body.appendChild(div);
  // Fix del typo del h3 (el atributo se pegó sin espacio arriba)
  const h3 = div.querySelector('h3');
  if (h3) h3.id = 'lm-titulo';
  // Cerrar al hacer click fuera del box
  div.addEventListener('click', (e) => {
    if (e.target.id === 'dvba-legal-modal') cerrar();
  });
}

function abrir(cual){
  _inyectarModal();
  const c = CONTENIDOS[cual] || CONTENIDOS.acerca;
  document.getElementById('lm-titulo').innerHTML = c.tit;
  document.getElementById('lm-body').innerHTML = c.body;
  // Marcar tab activo
  document.querySelectorAll('#dvba-legal-modal .lm-tab').forEach(t => {
    t.classList.toggle('on', t.dataset.tab === cual);
  });
  document.getElementById('dvba-legal-modal').classList.add('on');
}

function cerrar(){
  const m = document.getElementById('dvba-legal-modal');
  if (m) m.classList.remove('on');
}

// Inyectar al cargar el DOM (aunque también se inyecta lazy al abrir)
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', _inyectarModal);
} else {
  _inyectarModal();
}

global.DVBA_LEGAL = { abrir, cerrar };
})(window);
