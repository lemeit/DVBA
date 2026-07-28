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
        // Banner compactado (mismo cálculo que móvil v9.58)
        const bH = Math.max(150, Math.min(Math.round(W*0.16), 260));
        let H = img.height;
        if (datos.esResellado){
          // v9.81 · Detectar banner viejo por escaneo de píxeles.
          // Antes se asumía un alto fijo (bH_pred ≈ 260) — si el banner real
          // era más chico se recortaba parte de la foto, y si era más grande
          // quedaba banner-fantasma. Ahora buscamos la línea dorada #d4a820
          // que separa foto de banner en TODOS los sellos v3/v4.
          try {
            const probe = document.createElement('canvas');
            probe.width = W;
            probe.height = img.height;
            const pctx = probe.getContext('2d');
            pctx.drawImage(img, 0, 0);
            // Escanear desde 40% hacia abajo buscando primera fila oscura homogénea
            const scanFrom = Math.floor(img.height * 0.40);
            const scanTo = img.height - 1;
            let bordeBanner = -1;
            const step = Math.max(1, Math.floor(W / 60));  // ~60 muestras horizontales
            for (let y = scanFrom; y < scanTo; y++) {
              const row = pctx.getImageData(0, y, W, 1).data;
              let oscuros = 0, dorados = 0, total = 0;
              for (let x = 0; x < W; x += step) {
                const i = x * 4;
                const r = row[i], g = row[i+1], b = row[i+2];
                const brillo = (r + g + b) / 3;
                if (brillo < 30) oscuros++;
                // Dorado ~ #d4a820 (r=212,g=168,b=32) — línea separadora
                if (r > 180 && r < 240 && g > 130 && g < 190 && b < 60) dorados++;
                total++;
              }
              // Si 80%+ de la fila es oscura → estamos en el banner
              if (oscuros / total > 0.80) { bordeBanner = y; break; }
              // O si detectamos línea dorada (más precisa) → ahí está el borde
              if (dorados / total > 0.40) { bordeBanner = y + 1; break; }
            }
            if (bordeBanner > 0 && bordeBanner < img.height - 50) {
              H = bordeBanner;
              console.log('[sello_v4 resello] banner viejo detectado a y=' + bordeBanner + ' (alto ' + (img.height-bordeBanner) + 'px)');
            } else {
              // Fallback: asumir alto default v4
              H = img.height - bH;
              console.warn('[sello_v4 resello] no se detectó banner viejo, usando fallback bH=' + bH);
            }
          } catch(e) {
            console.warn('[sello_v4 resello] error detectando banner:', e);
            H = img.height - bH;  // fallback conservador
          }
        }
        const totalH = H + bH;
        const C = document.createElement('canvas');
        C.width = W; C.height = totalH;
        const ctx = C.getContext('2d');
        ctx.imageSmoothingEnabled = true;
        ctx.imageSmoothingQuality = 'high';
        // Fondo negro + foto arriba (recortando banner viejo si esResellado)
        ctx.fillStyle = '#0a0a0a';
        ctx.fillRect(0, 0, W, totalH);
        if (datos.esResellado && img.height > H){
          ctx.drawImage(img, 0, 0, W, H, 0, 0, W, H);
        } else {
          ctx.drawImage(img, 0, 0);
        }
        // Banner degradado
        const y0 = H;
        const grad = ctx.createLinearGradient(0, y0, 0, totalH);
        grad.addColorStop(0, '#0d0d0d');
        grad.addColorStop(1, '#000000');
        ctx.fillStyle = grad;
        ctx.fillRect(0, y0, W, bH);
        // Línea dorada superior
        ctx.strokeStyle = '#d4a820';
        ctx.lineWidth = Math.max(2, Math.round(H*0.0025));
        ctx.beginPath(); ctx.moveTo(0, y0); ctx.lineTo(W, y0); ctx.stroke();
        // 3 columnas · v9.84 · layout adaptativo para foto vertical
        // - En foto ancha (W > 700): columnas laterales normales (bH*0.9)
        // - En foto vertical (W ≤ 700): columnas más chicas cap 15% del ancho
        // - En foto MUY angosta (W < 500): APAGAR el QR (no entra bien, la
        //   coord ya está en el texto de la col central). Solo 2 columnas.
        const mostrarQR = W >= 500;
        const colSide = mostrarQR
          ? Math.min(Math.round(bH * 0.9), Math.round(W * 0.15))
          : Math.min(Math.round(bH * 0.9), Math.round(W * 0.18));  // solo columna izq (logo)
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
        const logoSz = Math.round(bH * 0.78);
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
        const qrSz = Math.min(Math.round(bH * 0.85), Math.round(colSide * 0.98));
        const qrX  = colRX + Math.round((colSide - qrSz)/2);
        const qrY  = y0    + Math.round((bH      - qrSz)/2);
        if (mostrarQR && typeof qrcode === 'function' && datos.lat && datos.lng){
          try {
            const url = 'https://www.google.com/maps/search/?api=1&query=' + datos.lat + ',' + datos.lng;
            const qr = qrcode(0, 'H');  // High error correction para logo al centro
            qr.addData(url); qr.make();
            const n = qr.getModuleCount();
            ctx.fillStyle = '#ffffff';
            ctx.fillRect(qrX, qrY, qrSz, qrSz);
            const pad = Math.round(qrSz*0.05);
            const inner = qrSz - pad*2;
            const cell  = Math.floor(inner / n);
            const ox = qrX + pad + Math.floor((inner - cell*n)/2);
            const oy = qrY + pad + Math.floor((inner - cell*n)/2);
            ctx.fillStyle = '#000000';
            for (let r=0; r<n; r++) for (let c=0; c<n; c++){
              if (qr.isDark(r,c)) ctx.fillRect(ox+c*cell, oy+r*cell, cell, cell);
            }
            // Logo DVBA al centro del QR (~22% del área, seguro con error correction H)
            const logoQrSz = Math.round(qrSz * 0.24);
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
              const lp = Math.round(logoQrSz * 0.10);  // padding interno
              ctx.drawImage(logoImg, logoQrX + lp, logoQrY + lp, logoQrSz - lp*2, logoQrSz - lp*2);
            } else {
              ctx.fillStyle = '#003366';
              ctx.font = '900 ' + Math.round(logoQrSz * 0.35) + 'px Arial,Helvetica,sans-serif';
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
        const baseFont = Math.max(16, Math.min(Math.round(W*0.022), 36));
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
          yB += Math.round(fT * 1.28);
        }
        const rutaKm = [datos.ruta, datos.prog ? 'Km ' + datos.prog : ''].filter(Boolean).join('  ·  ');
        if (rutaKm){
          txtFit(rutaKm, tx, yB, maxW, fM, '#ffffff', true);
          yB += Math.round(fM * 1.26);
        }
        if (datos.tipo){
          txtFit(datos.tipo, tx, yB, maxW, fM, '#ffffff', false);
          yB += Math.round(fM * 1.26);
        }
        if (datos.lat && datos.lng){
          let coords = 'Lat ' + datos.lat + '   Long ' + datos.lng;
          if (datos.alt) coords += '   Alt ' + datos.alt + ' m';
          txtFit(coords, tx, yB, maxW, fS, '#6ecba0', false, true);
          yB += Math.round(fS * 1.26);
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
          yB += Math.round(fS * 1.26);
        }
        // Versión + origen (campo/oficina/re-sello)
        // v9.76 · Anclamos al FONDO del banner en vez de arrastrar yB — antes
        // se salía cuando había muchas líneas (localidad+ruta+tipo+coords+fecha
        // superaban bH y la versión quedaba fuera del banner).
        const fV = Math.round(baseFont * 0.65);
        const appVer = (typeof APP_VER === 'string') ? APP_VER : 'v?';
        const stampInfo = [
          appVer + '·' + origen,
          (datos.esResellado ? '↻ re-sello' : 'sello ' + SELLO_VER)
        ].join('  ·  ');
        ctx.font = '500 ' + fV + 'px Arial,Helvetica,sans-serif';
        ctx.fillStyle = 'rgba(212,168,32,0.55)';
        ctx.textBaseline = 'bottom';
        ctx.textAlign = 'left';
        // Padding inferior fijo — la versión queda pegada al borde del banner
        const yVer = totalH - Math.round(bH * 0.08);
        ctx.fillText(stampInfo, tx, yVer);
        ctx.textBaseline = 'top';  // restaurar default por si se reutiliza
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
