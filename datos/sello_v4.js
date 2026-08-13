/* ══════════════════════════════════════════════════════════════════
   DVBA · Sello v4 · módulo compartido
   Extraído de dvba_campo.html (v9.66) en v7.89.
   Reusa la misma lógica de estampado que aplica la app móvil, para
   que las fotos que se suban desde partes_diarios.html se vean
   idénticas a las que llegan desde el campo.

   Depende de qrcode-generator (datos/qrcode.min.js).
   Carga el logo institucional desde datos/img/logo_dvba_clean.png.

   Uso:
     const b64Sellado = await DVBA_SELLO.aplicar(fotoBase64, {
       localidad: 'Saladillo, Buenos Aires, Argentina',
       lat:  '-35.641234',
       lng:  '-59.784567',
       fecha:'2026-07-17',   // YYYY-MM-DD
       hora: '14:32:15',     // HH:mm:ss
       alt:  '85',           // metros (opcional)
       ruta: 'RP 30',        // ya con prefijo
       prog: '12+500',       // texto libre
       tipo: 'Bacheo asfaltico',
       origen: 'oficina'     // 'campo' | 'oficina' — cambia el texto de versión
     });
   ══════════════════════════════════════════════════════════════════ */
(function(global){
'use strict';

const SELLO_VER = 'v4';

// Logo institucional cargado una única vez y cacheado
let _logoImg = null;
let _logoPromise = null;
function _cargarLogo(){
  if (_logoImg && _logoImg.complete && _logoImg.naturalWidth > 0) return Promise.resolve(_logoImg);
  if (_logoPromise) return _logoPromise;
  _logoPromise = new Promise((res) => {
    const img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload  = () => { _logoImg = img; res(img); };
    img.onerror = () => { console.warn('[sello_v4] logo no cargó, se usa fallback'); res(null); };
    img.src = 'datos/img/logo_dvba_clean.png';
  });
  return _logoPromise;
}

// Helper: prefijo correcto para la ruta según tipo_via
function _prefijoRutaSello(rutaRaw, tipoVia){
  const r = String(rutaRaw || '').trim();
  if (!r) return '';
  if (/^(RP|CS|Cno)/i.test(r)) return r;
  const esCamino = tipoVia === 'camino' || /^\d{3}-\d{2,3}$/.test(r);
  return esCamino ? ('Cno. ' + r) : ('RP ' + r);
}

// Estampa el sello v4 sobre la foto. base64 → base64.
function aplicar(base64, datos, opts){
  datos = datos || {};
  opts  = opts  || {};
  const origen = datos.origen || opts.origen || 'oficina';
  return _cargarLogo().then(logoImg => new Promise((res, rej) => {
    const img = new Image();
    img.onload = () => {
      try {
        const W = img.width;
        // v8.66f · Escala opcional del sello (0.50 - 1.00) para casos puntuales
        // donde el sello tapa algo importante de la foto (ej. puente en el bottom).
        // Se pasa vía datos.escalaSello. Default 1.0 = tamaño normal (sin cambios).
        // Achica proporcionalmente banner + fuentes + QR + logo.
        const _esc = (typeof datos.escalaSello === 'number' && datos.escalaSello >= 0.5 && datos.escalaSello <= 1)
                     ? datos.escalaSello : 1.0;
        // Banner con AJUSTE DINÁMICO · v8.16 · escalado v8.66f
        const bH_base = Math.round(Math.max(160, Math.min(Math.round(W*0.16), 270)) * _esc);
        const _baseF = Math.round(Math.max(16, Math.min(Math.round(W*0.022), 36)) * _esc);
        const _fT_ = Math.round(_baseF*1.20), _fM_ = Math.round(_baseF*1.05),
              _fS_ = Math.round(_baseF*0.85), _fV_ = Math.round(_baseF*0.65);
        const _LH_ = 1.35;  // interlineado (1.5 era demasiado, 1.26 pisaba)
        let _espLineas = Math.round(bH_base*0.12);  // padTop
        if (datos.localidad)            _espLineas += Math.round(_fT_*_LH_);
        if (datos.ruta || datos.prog)   _espLineas += Math.round(_fM_*_LH_);
        if (datos.tipo)                 _espLineas += Math.round(_fM_*_LH_);
        if (datos.lat && datos.lng)     _espLineas += Math.round(_fS_*_LH_);
        if (datos.fecha || datos.hora)  _espLineas += Math.round(_fS_*_LH_);
        // v8.66f.5 · YA NO sumamos línea de versión al bH (se movió a la col DER debajo del QR).
        _espLineas += Math.round(bH_base*0.10);  // padBottom
        const bH = Math.max(bH_base, _espLineas);
        let H = img.height;
        if (datos.esResellado){
          // v8.13 · Detección estricta · SOLO línea dorada #d4a820 (no falsos
          // positivos con fila oscura, que confundía sombras de foto real con
          // banner). Escanear desde ABAJO hacia arriba (banner siempre está
          // al pie) y limitar la búsqueda a los últimos 350px (el banner nunca
          // es más grande que eso).
          try {
            const probe = document.createElement('canvas');
            probe.width = W;
            probe.height = img.height;
            const pctx = probe.getContext('2d', { willReadFrequently: true });
            pctx.drawImage(img, 0, 0);
            const maxBannerH = Math.min(350, Math.floor(img.height * 0.35));
            const scanFrom = img.height - maxBannerH;
            const scanTo = img.height - 30;
            let bordeBanner = -1;
            const step = Math.max(1, Math.floor(W / 80));
            // Escaneo estricto: SOLO buscar la línea dorada del separador
            for (let y = scanFrom; y < scanTo; y++) {
              const row = pctx.getImageData(0, y, W, 1).data;
              let dorados = 0, total = 0;
              for (let x = 0; x < W; x += step) {
                const i = x * 4;
                const r = row[i], g = row[i+1], b = row[i+2];
                if (r > 180 && r < 240 && g > 130 && g < 190 && b < 60) dorados++;
                total++;
              }
              // Línea dorada: 50%+ de la fila es dorado → borde del banner
              if (dorados / total > 0.50) { bordeBanner = y; break; }
            }
            // v8.66f.2 · REVERT del método luma de v8.66f.1: causaba falsos positivos
            // (sombras naturales de árboles/terreno se detectaban como banner y recortaban
            // parte de la foto real). Volvemos al método original solo con línea dorada
            // pero con UMBRAL MÁS PERMISIVO (30% en vez de 50%) para tolerar compresión
            // JPEG que degrada el amarillo dorado a naranja/verdoso.
            if (bordeBanner < 0) {
              for (let y = scanFrom; y < scanTo; y++) {
                const row = pctx.getImageData(0, y, W, 1).data;
                let dorados = 0, total = 0;
                for (let x = 0; x < W; x += step) {
                  const i = x * 4;
                  const r = row[i], g = row[i+1], b = row[i+2];
                  // v8.66f.2 · Rango dorado ampliado: tolera JPEG que degrada #d4a820
                  if (r > 160 && r < 250 && g > 110 && g < 200 && b < 90) dorados++;
                  total++;
                }
                // Umbral 30% (antes 50%) → detecta mejor con compresión JPEG
                if (dorados / total > 0.30) { bordeBanner = y; break; }
              }
              if (bordeBanner > 0) console.log('[sello_v4 resello] línea dorada detectada (umbral 30%) a y=' + bordeBanner);
            }
            if (bordeBanner > 0) {
              H = bordeBanner;
            } else {
              // v8.66f.4 · Fallback ASUMIDO: si no detectamos la línea dorada,
              // asumimos que el banner viejo fue estampado al 100% (tamaño default)
              // y recortamos EXACTAMENTE esa altura. Antes se dejaba la foto entera,
              // lo que causaba doble sello garantizado al re-sellar con escala < 1.
              // Este recorte es reversible: si NO había sello viejo la foto queda
              // recortada de más (aceptable — el user re-sella intencionalmente).
              const bH_asumido = Math.max(160, Math.min(Math.round(W*0.16), 270));
              H = Math.max(1, img.height - bH_asumido);
              console.warn('[sello_v4 resello] línea dorada no detectada — recorte ASUMIDO de ' + bH_asumido + 'px del bottom (banner 100% inferido). Sin backup limpio, esta es la mejor aproximación.');
            }
          } catch(e) {
            console.warn('[sello_v4 resello] error detectando banner:', e);
            H = img.height;  // fallback seguro: no cortar
          }
        }
        // v8.16 · OVERLAY sobre la foto (no agrega altura → foto NO se afina).
        // Banner semitransparente (fondo gris/negro con alpha) en la parte
        // inferior de la imagen. Texto blanco + sombra negra para legibilidad.
        // QR con fondo blanco sólido para conservar contraste de escaneo.
        const totalH = H;  // <-- MISMO tamaño que la foto (no suma banner)
        const C = document.createElement('canvas');
        C.width = W; C.height = totalH;
        const ctx = C.getContext('2d');
        ctx.imageSmoothingEnabled = true;
        ctx.imageSmoothingQuality = 'high';
        // Dibujar la foto entera (recortando banner viejo si esResellado)
        if (datos.esResellado && img.height > H){
          ctx.drawImage(img, 0, 0, W, H, 0, 0, W, H);
        } else {
          ctx.drawImage(img, 0, 0, W, H);
        }
        // Banner OVERLAY semitransparente (últimos bH px de la foto)
        const y0 = H - bH;
        const grad = ctx.createLinearGradient(0, y0, 0, H);
        grad.addColorStop(0, 'rgba(0,0,0,0.55)');   // arriba: semitransparente
        grad.addColorStop(1, 'rgba(0,0,0,0.75)');   // abajo: más oscuro
        ctx.fillStyle = grad;
        ctx.fillRect(0, y0, W, bH);
        // Línea dorada superior (marca del banner para detección al re-sellar)
        ctx.strokeStyle = '#d4a820';
        ctx.lineWidth = Math.max(2, Math.round(H*0.0025));
        ctx.beginPath(); ctx.moveTo(0, y0); ctx.lineTo(W, y0); ctx.stroke();
        // v8.16 · QR más grande + logo no invade texto.
        // Cap subido a W*0.20 (era 0.15) → QR visible + legible en cualquier
        // orientación de foto. Logo se limita al colSide para no invadir texto.
        const mostrarQR = W >= 400;
        const colSide = mostrarQR
          ? Math.min(Math.round(bH * 0.85), Math.round(W * 0.20))
          : Math.min(Math.round(bH * 0.85), Math.round(W * 0.20));
        const colLX = 0;
        const colRX = mostrarQR ? (W - colSide) : W;   // sin QR → texto ocupa todo el resto
        const colCX = colSide;
        const colCW = colRX - colSide;
        // Separadores verticales
        ctx.strokeStyle = 'rgba(212,168,32,0.35)';
        ctx.lineWidth = 1;
        ctx.beginPath(); ctx.moveTo(colSide, y0+bH*0.10); ctx.lineTo(colSide, totalH-bH*0.10); ctx.stroke();
        if (mostrarQR) {
          ctx.beginPath(); ctx.moveTo(colRX, y0+bH*0.10); ctx.lineTo(colRX, totalH-bH*0.10); ctx.stroke();
        }
        // === COL IZQ: Logo ===
        // v8.16 · logoSz limitado por colSide para no invadir la columna del texto
        const logoSz = Math.min(Math.round(bH * 0.78), Math.round(colSide * 0.9));
        const logoX  = colLX + Math.round((colSide - logoSz)/2);
        const logoY  = y0    + Math.round((bH      - logoSz)/2);
        if (logoImg && logoImg.complete && logoImg.naturalWidth > 0){
          ctx.drawImage(logoImg, logoX, logoY, logoSz, logoSz);
        } else {
          // Fallback: círculo dorado con "DVBA"
          const cx = logoX + logoSz/2, cy = logoY + logoSz/2;
          ctx.fillStyle = '#d4a820';
          ctx.beginPath(); ctx.arc(cx, cy, logoSz/2, 0, Math.PI*2); ctx.fill();
          ctx.fillStyle = '#000';
          ctx.font = '900 ' + Math.round(logoSz*0.30) + 'px Arial';
          ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
          ctx.fillText('DVBA', cx, cy);
          ctx.textAlign = 'left';
        }
        // === COL DER: QR Google Maps === (solo si mostrarQR)
        // v9.84 · QR con tamaño garantizado + logo DVBA al centro.
        // Se omite en foto muy angosta (W < 500) para no pisar el texto.
        // v8.66f.6 · QR más chico (0.72 vs 0.85) y anclado al TOP del banner
        // para dejar franja libre ABAJO donde va la versión. Antes el QR ocupaba
        // casi todo el alto y la versión quedaba encima del QR.
        const qrSz = Math.min(Math.round(bH * 0.72), Math.round(colSide * 0.98));
        const qrX  = colRX + Math.round((colSide - qrSz)/2);
        const qrY  = y0    + Math.round(bH * 0.06);   // pegado al top del banner
        if (mostrarQR && typeof qrcode === 'function' && datos.lat && datos.lng){
          try {
            const url = 'https://www.google.com/maps/search/?api=1&query=' + datos.lat + ',' + datos.lng;
            const qr = qrcode(0, 'H');  // High error correction para logo al centro
            qr.addData(url); qr.make();
            const n = qr.getModuleCount();
            ctx.fillStyle = '#ffffff';
            ctx.fillRect(qrX, qrY, qrSz, qrSz);
            // v8.13 · Padding chico (2%) para que el QR ocupe casi todo el cuadrado
            const pad = Math.round(qrSz*0.02);
            const inner = qrSz - pad*2;
            const cell  = Math.floor(inner / n);
            const ox = qrX + pad + Math.floor((inner - cell*n)/2);
            const oy = qrY + pad + Math.floor((inner - cell*n)/2);
            ctx.fillStyle = '#000000';
            for (let r=0; r<n; r++) for (let c=0; c<n; c++){
              if (qr.isDark(r,c)) ctx.fillRect(ox+c*cell, oy+r*cell, cell, cell);
            }
            // Logo DVBA al centro del QR · v8.7 · bajado a 18% para no romper
            // el escaneo (24% tapaba módulos críticos aún con EC=H)
            const logoQrSz = Math.round(qrSz * 0.18);
            const logoQrX = qrX + Math.round((qrSz - logoQrSz)/2);
            const logoQrY = qrY + Math.round((qrSz - logoQrSz)/2);
            // Fondo blanco redondeado detrás del logo (para que resalte)
            const rr = Math.round(logoQrSz * 0.15);
            ctx.fillStyle = '#ffffff';
            ctx.beginPath();
            ctx.moveTo(logoQrX + rr, logoQrY);
            ctx.lineTo(logoQrX + logoQrSz - rr, logoQrY);
            ctx.quadraticCurveTo(logoQrX + logoQrSz, logoQrY, logoQrX + logoQrSz, logoQrY + rr);
            ctx.lineTo(logoQrX + logoQrSz, logoQrY + logoQrSz - rr);
            ctx.quadraticCurveTo(logoQrX + logoQrSz, logoQrY + logoQrSz, logoQrX + logoQrSz - rr, logoQrY + logoQrSz);
            ctx.lineTo(logoQrX + rr, logoQrY + logoQrSz);
            ctx.quadraticCurveTo(logoQrX, logoQrY + logoQrSz, logoQrX, logoQrY + logoQrSz - rr);
            ctx.lineTo(logoQrX, logoQrY + rr);
            ctx.quadraticCurveTo(logoQrX, logoQrY, logoQrX + rr, logoQrY);
            ctx.closePath();
            ctx.fill();
            // Texto "DVBA" al centro (o el logoImg si es lo bastante chico)
            if (logoImg && logoImg.complete && logoImg.naturalWidth > 0) {
              const lp = Math.round(logoQrSz * 0.08);  // padding interno
              ctx.drawImage(logoImg, logoQrX + lp, logoQrY + lp, logoQrSz - lp*2, logoQrSz - lp*2);
            } else {
              ctx.fillStyle = '#003366';
              ctx.font = '900 ' + Math.round(logoQrSz * 0.38) + 'px Arial,Helvetica,sans-serif';
              ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
              ctx.fillText('DVBA', logoQrX + logoQrSz/2, logoQrY + logoQrSz/2);
              ctx.textAlign = 'left'; ctx.textBaseline = 'top';
            }
          } catch(e){ console.warn('[sello_v4] QR:', e); }
        }
        // === COL CENTRO: texto blanco ===
        const padX = Math.round(W * 0.018);
        const tx = colCX + padX;
        const maxW = colCW - padX*2;
        // v8.66f.7 · Fuentes DE DIBUJO escaladas igual que en el cálculo de bH.
        // Bug histórico v8.66f: _baseF (bH) se escalaba pero baseFont (dibujo) NO,
        // → con Mínimo el banner quedaba chico pero el texto se dibujaba tamaño
        // completo → se cortaba la fecha/hora (última línea) fuera del banner.
        const baseFont = Math.round(Math.max(16, Math.min(Math.round(W*0.022), 36)) * _esc);
        const fT = Math.round(baseFont * 1.20);
        const fM = Math.round(baseFont * 1.05);
        const fS = Math.round(baseFont * 0.85);
        function txtFit(txt, x, y, mxW, fs, color, bold, mono){
          if (!txt) return 0;
          let sz = fs;
          const ff = mono ? "'Courier New',monospace" : "Arial,Helvetica,sans-serif";
          ctx.font = (bold?'700':'500') + ' ' + sz + 'px ' + ff;
          while (ctx.measureText(txt).width > mxW && sz > 9){
            sz--; ctx.font = (bold?'700':'500') + ' ' + sz + 'px ' + ff;
          }
          ctx.fillStyle = color; ctx.textBaseline = 'top';
          ctx.shadowColor = 'rgba(0,0,0,0.9)';
          ctx.shadowBlur = 2; ctx.shadowOffsetX = 1; ctx.shadowOffsetY = 1;
          ctx.fillText(txt, x, y);
          ctx.shadowColor = 'transparent';
          ctx.shadowBlur = 0; ctx.shadowOffsetX = 0; ctx.shadowOffsetY = 0;
          return sz;
        }
        let yB = y0 + Math.round(bH * 0.10);
        if (datos.localidad){
          txtFit(datos.localidad, tx, yB, maxW, fT, '#ffffff', true);
          yB += Math.round(fT * 1.35);
        }
        const rutaKm = [datos.ruta, datos.prog ? 'Km ' + datos.prog : ''].filter(Boolean).join('  ·  ');
        if (rutaKm){
          txtFit(rutaKm, tx, yB, maxW, fM, '#ffffff', true);
          yB += Math.round(fM * 1.35);
        }
        if (datos.tipo){
          txtFit(datos.tipo, tx, yB, maxW, fM, '#ffffff', false);
          yB += Math.round(fM * 1.35);
        }
        if (datos.lat && datos.lng){
          let coords = 'Lat ' + datos.lat + '   Long ' + datos.lng;
          if (datos.alt) coords += '   Alt ' + datos.alt + ' m';
          txtFit(coords, tx, yB, maxW, fS, '#6ecba0', false, true);
          yB += Math.round(fS * 1.35);
        }
        const partes = [];
        if (datos.fecha){
          const m = datos.fecha.match(/^(\d{4})-(\d{2})-(\d{2})/);
          if (m) partes.push(m[3] + '/' + m[2] + '/' + m[1]);
          else   partes.push(datos.fecha);
        }
        if (datos.hora){
          const hm = datos.hora.split(':');
          partes.push(hm[0] + ':' + (hm[1] || '00') + ' hs');
        }
        if (partes.length){
          txtFit(partes.join('  ·  '), tx, yB, maxW, fS, '#dddddd', false);
          yB += Math.round(fS * 1.35);
        }
        // Versión + origen (campo/oficina/re-sello)
        // v8.66f.5 · MOVIDA a la columna DERECHA (debajo del QR) para NO pisar
        // el texto principal cuando este ocupa muchas líneas (localidad larga
        // + ruta + tipo + coords + fecha llenan el bottom del banner).
        // v9.95.4 · Leer directo de window.APP_VER / window.APP_VERSION para evitar
        // problemas de scope. Antes usaba APP_VER como identificador global lo que
        // requería que estuviera declarada como var, y causó SyntaxError por doble
        // declaración en dvba_campo.html v9.95.3.
        const appVer = (typeof window !== 'undefined' && typeof window.APP_VER === 'string' && window.APP_VER) ? window.APP_VER
                     : (typeof window !== 'undefined' && typeof window.APP_VERSION === 'string' && window.APP_VERSION) ? window.APP_VERSION
                     : 'v?';
        const stampInfo = [
          appVer + '·' + origen,
          (datos.esResellado ? '↻ re-sello' : 'sello ' + SELLO_VER)
        ].join(' · ');
        ctx.textBaseline = 'bottom';
        ctx.fillStyle = 'rgba(212,168,32,0.75)';  // dorado un poco más opaco (fondo QR blanco al lado)
        if (mostrarQR) {
          // Centrado en la columna DER, en el espacio libre BAJO el QR
          const verMaxW = colSide - 6;      // ancho útil = columna QR con pad
          let fVr = Math.round(baseFont * 0.55);
          ctx.textAlign = 'center';
          ctx.font = '500 ' + fVr + 'px Arial,Helvetica,sans-serif';
          while (ctx.measureText(stampInfo).width > verMaxW && fVr > 7) {
            fVr--;
            ctx.font = '500 ' + fVr + 'px Arial,Helvetica,sans-serif';
          }
          const verCX = colRX + Math.round(colSide / 2);
          const yVer  = totalH - Math.round(bH * 0.04);  // pegado al borde
          ctx.fillText(stampInfo, verCX, yVer);
        } else {
          // Sin QR (foto muy angosta): fallback al bottom-left de la col centro
          let fVr = Math.round(baseFont * 0.65);
          ctx.textAlign = 'left';
          ctx.font = '500 ' + fVr + 'px Arial,Helvetica,sans-serif';
          while (ctx.measureText(stampInfo).width > maxW && fVr > 8) {
            fVr--;
            ctx.font = '500 ' + fVr + 'px Arial,Helvetica,sans-serif';
          }
          const yVer = totalH - Math.round(bH * 0.08);
          ctx.fillText(stampInfo, tx, yVer);
        }
        ctx.textAlign = 'left';
        ctx.textBaseline = 'top';  // restaurar default
        let jpegOut = C.toDataURL('image/jpeg', 0.95);
        // v9.80 · Inyectar metadatos EXIF (GPS + ruta + prog + tipo + registro JSON)
        if (typeof DVBA_EXIF !== 'undefined' && DVBA_EXIF.disponible()) {
          try {
            jpegOut = DVBA_EXIF.inyectar(jpegOut, {
              lat:     parseFloat(datos.lat),
              lng:     parseFloat(datos.lng),
              alt:     datos.alt ? parseFloat(datos.alt) : null,
              fecha:   datos.fecha, hora: datos.hora,
              ruta:    datos.ruta, prog: datos.prog, tipo: datos.tipo,
              partido: datos.partido, zona: datos.zona,
              origen:  origen
            });
          } catch(e){ console.warn('[sello_v4] EXIF post-sellado:', e); }
        }
        res(jpegOut);
      } catch(e){ rej(e); }
    };
    img.onerror = () => rej(new Error('Error cargando foto'));
    img.src = base64;
  }));
}

global.DVBA_SELLO = {
  aplicar,
  prefijoRuta: _prefijoRutaSello,
  version: SELLO_VER
};
})(window);
