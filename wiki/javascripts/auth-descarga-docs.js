/* ═══════════════════════════════════════════════════════════════════
 * DVBA · Wiki · Filtro de descargas oficiales por sesión (v8.72)
 *
 * Convención: cualquier <a class="doc-oficial" href="..."> se filtra
 * según si el usuario tiene sesión activa en el portal DVBA.
 *
 *  - Con sesión: se muestra el link normal.
 *  - Sin sesión: se reemplaza por un aviso "🔒 Iniciar sesión para descargar".
 *
 * Esto NO es seguridad real (los PDFs siguen accesibles por URL directa).
 * Es una capa de disuasión + marca institucional de "uso restringido".
 * Para docs realmente sensibles → migrar a Supabase Storage privado.
 * ═══════════════════════════════════════════════════════════════════ */
(function(){
  'use strict';

  // El portal y la wiki comparten dominio (lemeit.github.io) →
  // localStorage se comparte. Buscamos la key de sesión Supabase.
  function hayaSesionActiva(){
    try {
      for (var i = 0; i < localStorage.length; i++) {
        var k = localStorage.key(i);
        // Supabase v2 usa "sb-<projectref>-auth-token"
        if (k && k.indexOf('sb-') === 0 && k.indexOf('-auth-token') > -1) {
          var raw = localStorage.getItem(k);
          if (!raw) continue;
          try {
            var obj = JSON.parse(raw);
            // Verificar que el token no esté expirado
            if (obj && obj.access_token) {
              if (obj.expires_at) {
                // expires_at está en segundos (unix timestamp)
                if (obj.expires_at * 1000 > Date.now()) return true;
              } else {
                return true;
              }
            }
          } catch(_){ /* raw no es JSON */ }
        }
      }
    } catch(e){ console.warn('[auth-descarga]', e); }
    return false;
  }

  var URL_PORTAL_LOGIN = 'https://lemeit.github.io/DVBA/';

  function aplicarFiltro(){
    var links = document.querySelectorAll('a.doc-oficial');
    if (!links.length) return;
    var logueado = hayaSesionActiva();
    links.forEach(function(a){
      if (logueado) {
        // Sesión activa · marcamos con badge de auth verificada
        if (a.dataset.dvbaAuthMarked) return;
        a.dataset.dvbaAuthMarked = '1';
        var badge = document.createElement('span');
        badge.textContent = ' ✓ acceso autorizado';
        badge.style.cssText = 'font-size:.85em;color:#22a954;font-weight:600;margin-left:6px';
        a.parentNode.insertBefore(badge, a.nextSibling);
      } else {
        // Sin sesión · reemplazar link por aviso
        var wrap = document.createElement('div');
        wrap.style.cssText = 'display:inline-block;padding:8px 12px;background:#fef6e4;border:1px solid #c47a00;border-left:4px solid #c47a00;border-radius:4px;font-size:.9em;color:#7a4400;line-height:1.5';
        wrap.innerHTML =
          '🔒 <b>Documento restringido a usuarios autorizados</b><br>' +
          '<a href="' + URL_PORTAL_LOGIN + '" target="_blank" rel="noopener" style="color:#007e8c;font-weight:600;text-decoration:underline">Iniciá sesión en el portal DVBA</a> ' +
          'y volvé a esta página para descargar.<br>' +
          '<span style="font-size:.85em;color:#8a5a00;font-style:italic">Documento: ' + (a.textContent || a.title || 'oficial DVBA').replace(/</g,'&lt;') + '</span>';
        a.parentNode.replaceChild(wrap, a);
      }
    });
  }

  // Correr al cargar la página + reejecutar si cambia el DOM (navegación SPA de Material)
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', aplicarFiltro);
  } else {
    aplicarFiltro();
  }
  // Material navigation.instant hace SPA — capturar cambio de página
  if (typeof document$ !== 'undefined' && document$.subscribe) {
    document$.subscribe(function(){ setTimeout(aplicarFiltro, 50); });
  } else {
    // Fallback: observar mutaciones en el contenido principal
    var target = document.querySelector('article.md-content__inner') || document.body;
    if (window.MutationObserver && target) {
      new MutationObserver(function(muts){
        for (var i = 0; i < muts.length; i++) {
          if (muts[i].addedNodes && muts[i].addedNodes.length) {
            setTimeout(aplicarFiltro, 50);
            break;
          }
        }
      }).observe(target, { childList: true, subtree: true });
    }
  }
})();
