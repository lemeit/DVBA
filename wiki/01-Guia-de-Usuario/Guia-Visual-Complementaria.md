# Guía Visual Complementaria

> Contenido original de la guía visual (versión resumida con capturas), útil como referencia rápida complementaria a las notas detalladas: [[02-Primeros-pasos]], [[07-App-Movil-Modo-Basico]], [[08-App-Movil-Modo-Avanzado]], [[13-Modo-Offline]], [[14-FAQ]].

## Instalar la app en el celular (PWA)

La app se instala como cualquier otra del celular, pero **sin pasar por Play Store o App Store**. El proceso toma 30 segundos:

<div class="demo" markdown="0">
  <div class="phone">
    <div class="screen">
      <div style="background:#009aae;padding:26px 12px 10px;color:#fff;font-weight:800;font-size:11px">SIG Vial PBA</div>
      <div style="padding:16px;background:#f4f6f9;color:#1a2a3a;font-size:11px;height:calc(100% - 50px)">
        <div style="background:#fff;border-radius:12px;padding:16px;box-shadow:0 4px 12px rgba(0,0,0,.15);text-align:center;margin-top:180px">
          <div style="font-size:28px;margin-bottom:8px">📥</div>
          <div style="font-weight:800;font-size:12px;margin-bottom:6px">Instalar SIG Vial PBA</div>
          <div style="font-size:10px;color:#666;margin-bottom:12px">Agregar a la pantalla de inicio</div>
          <div style="display:flex;gap:6px">
            <div style="flex:1;padding:9px;background:#e0e0e0;color:#333;border-radius:6px;font-size:10px;font-weight:700">Cancelar</div>
            <div style="flex:1;padding:9px;background:#009aae;color:#fff;border-radius:6px;font-size:10px;font-weight:700">Instalar</div>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="step" markdown="1">

**Paso a paso**

1. Abrir **Chrome** en el celular.
2. Ir a `lemeit.github.io/DVBA/app.html` (importante: el `/app.html` al final, sino se abre el portal escritorio).
3. Al abrir aparece un banner, o el menú `⋮` muestra la opción **"Instalar aplicación"**.
4. Tocarla y aceptar. Se agrega el ícono al launcher del celular.
5. A partir de ahí, abrís la app tocando el ícono como cualquier otra.

<div class="box info" markdown="0"><strong>El ícono se llama "SIG Vial PBA"</strong> y aparece con el logo institucional DVBA.</div>

  </div>
</div>

### Actualizaciones automáticas

Cuando hay una versión nueva del sistema, al abrir la app aparece un banner verde arriba:

<div class="demo" markdown="0">
  <div class="phone">
    <div class="screen">
      <div class="pwa-update">
        <div class="ub-icon">🔄</div>
        <div class="ub-text"><b>Hay una versión más nueva</b><small>De v9.93 → v9.94 · tocá Actualizar</small></div>
        <div class="ub-btn">Actualizar</div>
      </div>
      <div class="lite-hdr" style="margin-top:52px">
        <div class="hdr-top">
          <div class="logo"><img src="img/logo_dvba_clean.png" alt="DVBA"></div>
          <div class="brand">SIG Vial PBA · Modo Básico<span class="sub">👷 Técnico · Zona VI</span></div>
        </div>
        <div class="gps-badge on"><span class="dot"></span>±8m · 65m</div>
      </div>
      <div class="lite-main"><div class="big-btn"><div class="icon">📸</div><div class="lbl">Sacar foto</div><div class="sublbl">y guardar ubicación</div></div></div>
    </div>
  </div>
  <div class="step" markdown="1">

**Cómo actualizar**

1. Al abrir la app, si hay versión nueva aparece el banner verde arriba.
2. Tocar **Actualizar**.
3. La app se recarga con la versión nueva en menos de 2 segundos.

<div class="box warn" markdown="0"><strong>Importante</strong> · Si no tocás Actualizar, la app va a seguir funcionando con la versión vieja cacheada. No perdés nada, pero no tenés los últimos cambios.</div>

  </div>
</div>

## Sincronización con la oficina

Todo lo que se carga desde el celular aparece automáticamente en el sistema de escritorio, sin que nadie tenga que hacer nada manual:

<div class="sync-diagram" markdown="0">
  <div class="sync-node">
    <div class="box-ico">📱</div>
    <div class="name">App celular</div>
    <div class="detail">Saca la foto con GPS<br>y la guarda en cola local</div>
  </div>
  <div class="sync-arrow">→</div>
  <div class="sync-node">
    <div class="box-ico">☁</div>
    <div class="name">Supabase</div>
    <div class="detail">Sube automáticamente<br>cuando hay conexión</div>
  </div>
  <div class="sync-arrow">→</div>
  <div class="sync-node">
    <div class="box-ico">🖥</div>
    <div class="name">Portal escritorio</div>
    <div class="detail">Aparece en el mapa,<br>lista para aprobar</div>
  </div>
</div>

### Qué ve el personal de oficina

Cuando el técnico de campo envía una foto, en el portal (abierto en la computadora de oficina o cualquier notebook con conexión) aparece:

- Un **pin nuevo en el mapa**, en la posición GPS exacta donde se sacó la foto.
- Un registro en la **cola de aprobación** con estado *"campo"* (a la espera de revisión).
- La foto cruda **sin sello** (el sello institucional se aplica al aprobar).

Desde escritorio, el personal responsable revisa, completa datos y aprueba. La foto queda sellada con los datos definitivos y trazable con QR de Google Maps.

<div class="box info" markdown="0"><strong>🔒 Seguridad</strong> · Todos los registros llevan el ID del usuario que los cargó. Cada zona de la DVBA solo ve sus propios datos (excepto Gerencia y Admin, que ven todo).</div>

## Navegador vs app instalada · WiFi/datos vs GPS

<div class="grid2" markdown="0">
  <div class="card" style="border-left:4px solid #f0a500" markdown="1">

**🌐 Desde el navegador (sin instalar)**

Si abrís la URL directamente en Chrome sin instalar la app:

- Necesitás **obligatoriamente** WiFi o datos móviles para que la app cargue.
- Si se corta la conexión, se pierde todo lo que estabas haciendo.
- No hay cola offline: cada foto necesita internet en el momento.

**Uso recomendado**: prueba rápida, primera vez, o desde la computadora de oficina.

  </div>
  <div class="card" style="border-left:4px solid #28a745" markdown="1">

**📱 Como app instalada (PWA)**

Una vez que instalaste la app y te logueaste al menos una vez con internet:

- **NO requiere WiFi ni datos** para funcionar.
- Solo necesita **señal de GPS** del celular (que funciona incluso sin internet).
- Guarda las fotos en una cola local.
- Sincroniza automáticamente cuando vuelva la conexión.

**Uso recomendado**: campo, zonas rurales, cualquier situación operativa.

  </div>
</div>

<div class="box tip" markdown="0"><strong>💡 Regla práctica</strong> · Instalá la app la primera vez que tengas WiFi (en la oficina). Después usala en el campo sin importar si tenés señal — el GPS funciona en cualquier lado. Cuando volvés a la oficina o entrás en zona con señal, todo se sincroniza solo.</div>

## Uso del Modo Básico

Es la app **por default** al instalar. Está pensada para operarios que necesitan solo sacar fotos con GPS, sin cargar formularios largos. Todos los demás datos los completa alguien en la oficina.

### Primera vez que la abrís · Ingresar

<div class="demo" markdown="0">
  <div class="phone">
    <div class="screen">
      <div class="lite-hdr" style="padding-top:34px">
        <div class="hdr-top">
          <div class="logo"><img src="img/logo_dvba_clean.png" alt="DVBA"></div>
          <div class="brand">SIG Vial PBA · Modo Básico<span class="sub">👷 Técnico · Zona VI</span></div>
        </div>
        <div class="gps-badge"><span class="dot"></span>Ubicando…</div>
      </div>
      <div class="modal-lite">
        <div class="modal-lite-box">
          <div style="font-size:22px;margin-bottom:4px">🔐</div>
          <h3>Ingresar</h3>
          <p style="text-align:center;font-size:10px;color:#666;margin-bottom:10px">Ingresá con tu cuenta para poder enviar registros.</p>
          <input type="text" placeholder="Correo">
          <input type="password" placeholder="Contraseña">
          <div style="background:#1a8a4a;color:#fff;padding:10px;border-radius:8px;font-size:11px;font-weight:800;text-transform:uppercase;margin-top:4px">Ingresar</div>
          <p style="font-size:9px;color:#888;margin-top:10px">O usá la <span style="color:#009aae;text-decoration:underline">Modo Avanzado</span>.</p>
        </div>
      </div>
    </div>
  </div>
</div>

#### Instrucciones

1. Ingresá con el correo y contraseña que te asignó el administrador.
2. La primera vez **necesitás WiFi o datos** para que la app valide tu identidad con el servidor.
3. Una vez logueado, la app te recuerda por tiempo indefinido. Podés cerrar y abrir sin volver a poner clave.

!!! tip "💡 ¿No tenés usuario?"
    Contactá al administrador del sistema: [lulamaita@vialidad.gba.gov.ar](mailto:lulamaita@vialidad.gba.gov.ar). Te van a dar de alta con tu correo institucional.

!!! info "📱 Multi-zona (v9.91+)"
    La app es la misma para todas las zonas DVBA (I a XII). Una vez logueado, el header muestra tu **rol** y **zona** real (ej. `👷 Técnico · Zona IV`). El sistema aplica automáticamente las políticas de la zona asignada — solo ves y cargás datos de tu área.

### Verificar el GPS antes de sacar fotos

<div class="demo" markdown="0">
  <div class="phone">
    <div class="screen">
      <div class="lite-hdr" style="padding-top:34px">
        <div class="hdr-top">
          <div class="logo"><img src="img/logo_dvba_clean.png" alt="DVBA"></div>
          <div class="brand">SIG Vial PBA · Modo Básico<span class="sub">👷 Técnico · Zona VI</span></div>
        </div>
        <div class="gps-badge off"><span class="dot"></span>Sin ubicación · tocar</div>
      </div>
      <div class="lite-main">
        <div class="big-btn dis"><div class="icon">📸</div><div class="lbl">Sacar foto</div><div class="sublbl">y guardar ubicación</div></div>
        <div class="hint-alerta">⚠ La ubicación no está lista.<br><b>Tocá el indicador de arriba</b> para intentar de nuevo.</div>
      </div>
      <div class="lite-footer">
        <div class="fb pend"><span class="ico">📤</span><span>Sin enviar</span></div>
        <div class="fb"><span class="ico">⚙</span><span>Modo Avanzado</span></div>
        <div class="fb info"><span class="ico">ℹ</span><span>Info</span></div>
      </div>
    </div>
  </div>
</div>

#### Instrucciones

1. El **banner del GPS** al pie del header cambia de color según el estado:
        
🟢 **Verde · ±Nm** · GPS OK, podés sacar fotos.
🟡 **Amarillo · Ubicando…** · Está buscando señal.
🔴 **Rojo · Sin ubicación** · No hay señal. Tocá para reintentar o abrir ajustes.

2. Mientras el GPS esté en rojo, el botón central queda deshabilitado.

3. Si estás en zona sin buena señal, movete al aire libre y esperá 30 segundos.

### Sacar y enviar una foto

<div class="demo" markdown="0">
  <div class="phone">
    <div class="screen">
      <div class="lite-hdr" style="padding-top:34px">
        <div class="hdr-top">
          <div class="logo"><img src="img/logo_dvba_clean.png" alt="DVBA"></div>
          <div class="brand">SIG Vial PBA · Modo Básico<span class="sub">👷 Técnico · Zona VI</span></div>
        </div>
        <div class="gps-badge on"><span class="dot"></span>±6m · 78m</div>
      </div>
      <div class="lite-main">
        <div class="big-btn"><div class="icon">📸</div><div class="lbl">Sacar foto</div><div class="sublbl">y guardar ubicación</div></div>
        <div class="hint">Solo tocá el botón para <b>sacar la foto</b> y guardar el <b>lugar exacto</b>.<br><br>Los demás datos los completa <b>alguien en la oficina</b>.</div>
      </div>
      <div class="lite-footer">
        <div class="fb pend"><span class="ico">📤</span><span>Sin enviar</span></div>
        <div class="fb"><span class="ico">⚙</span><span>Modo Avanzado</span></div>
        <div class="fb info"><span class="ico">ℹ</span><span>Info</span></div>
      </div>
    </div>
  </div>
  <div class="phone">
    <div class="screen">
      <div class="preview-ov">
        <div class="prev-img"><div class="fake">🛣</div></div>
        <div class="prev-info">📍 <b>Lat -35.641234   Long -59.784567</b><br><span style="opacity:.75">±6m · 78m alt · 19/07/2026, 08:45</span></div>
        <div class="prev-actions">
          <div class="btn btn-desc">↺ Sacar otra</div>
          <div class="btn btn-gua">✓ Enviar</div>
        </div>
      </div>
    </div>
  </div>
</div>

#### Instrucciones

1. Con el GPS en verde, tocá el **botón grande "Sacar foto"**.

2. Se abre la cámara del celular. Sacá la foto.

3. Aparece el **preview** con la foto y sus coordenadas.

4. Si te gustó → **✓ Enviar**. Si querés otra → **↺ Sacar otra**.

5. Al enviar, la foto queda en la cola local. Si hay internet, se sube al toque. Si no, queda esperando.

Feedback visual

· Después de tocar Enviar, aparece un panel con el resultado: ✓ subida OK, 📴 sin conexión (queda en cola), ✗ error. Te dice cuántas fotos hay sin enviar en el celular.

### Ver y gestionar los pendientes

<div class="demo" markdown="0">
  <div class="phone">
    <div class="screen">
      <div class="lite-hdr" style="padding-top:34px">
        <div class="hdr-top"><div class="logo"><img src="img/logo_dvba_clean.png" alt="DVBA"></div><div class="brand">Fotos sin enviar<span class="sub">3 pendientes</span></div></div>
      </div>
      <div style="background:#fff;color:#1a1a1a;flex:1;padding:10px 8px;overflow-y:auto;height:calc(100% - 130px)">
        <div style="display:flex;gap:8px;padding:8px;border:1px solid #e0e0e0;border-radius:8px;margin-bottom:6px">
          <div style="width:44px;height:44px;background:#8b6f47;border-radius:4px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:16px">🛣</div>
          <div style="flex:1;font-size:9.5px"><div style="font-weight:700;font-size:10px">19/07 08:45</div><div style="color:#888;font-size:9px">-35.6412, -59.7846</div></div>
          <div style="background:#ffe8e8;color:#b20900;padding:5px 8px;border-radius:6px;font-size:9px;font-weight:800">Borrar</div>
        </div>
        <div style="display:flex;gap:8px;padding:8px;border:1px solid #e0e0e0;border-radius:8px;margin-bottom:6px">
          <div style="width:44px;height:44px;background:#a08055;border-radius:4px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:16px">🛣</div>
          <div style="flex:1;font-size:9.5px"><div style="font-weight:700;font-size:10px">19/07 09:02</div><div style="color:#888;font-size:9px">-35.6398, -59.7889</div><div style="color:#b20900;font-size:8.5px;font-weight:700">⚠ Sin ubicación GPS</div></div>
          <div style="background:#ffe8e8;color:#b20900;padding:5px 8px;border-radius:6px;font-size:9px;font-weight:800">Borrar</div>
        </div>
      </div>
      <div style="padding:8px;background:#f8f8f8;display:flex;gap:6px;border-top:1px solid #e0e0e0">
        <div style="flex:1;padding:10px;background:#fff;color:#b20900;border:1.5px solid #d24040;border-radius:8px;font-size:9.5px;font-weight:800;text-align:center">Borrar todo</div>
        <div style="flex:1;padding:10px;background:#1a8a4a;color:#fff;border-radius:8px;font-size:10px;font-weight:800;text-transform:uppercase;text-align:center">↻ Enviar ahora</div>
      </div>
    </div>
  </div>
</div>

#### Instrucciones

1. Tocá **📤 Sin enviar** en el footer.

2. Aparece la lista de fotos que quedaron en cola local.

3. Cada foto muestra: miniatura, fecha, coordenadas y un aviso si falta GPS.

4. Botón **Borrar** por cada foto (por si quedó rota o sin GPS y no querés que se envíe).

5. Botón **↻ Enviar ahora** reintenta la sincronización si hay internet.

### Panel de información y cerrar sesión

<div class="demo" markdown="0">
  <div class="phone">
    <div class="screen">
      <div class="lite-hdr" style="padding-top:34px">
        <div class="hdr-top"><div class="logo"><img src="img/logo_dvba_clean.png" alt="DVBA"></div><div class="brand">SIG Vial PBA · Modo Básico<span class="sub">👷 Técnico · Zona VI</span></div></div>
      </div>
      <div class="modal-lite" style="top:75px">
        <div class="modal-lite-box" style="max-width:230px">
          <div style="font-size:22px;color:#009aae;line-height:1;margin-bottom:6px">ℹ</div>
          <h3 style="margin-bottom:10px">Información</h3>
          <div style="text-align:left;font-size:10px;line-height:1.6;color:#333">
            <b>SIG Vial PBA · Modo Básico</b><br>
            Versión <b>v9.93.1</b>
            <hr style="border:0;border-top:1px solid #e0e0e0;margin:8px 0">
            <b>Sesión</b><br>
            <span style="font-size:10px;color:#333"><b>👷 Técnico · Zona VI</b></span><br>
            <span style="font-size:9px;color:#888">tecnica.dvba.z6@vialidad.gba.gov.ar</span><br>
            <span style="font-size:9.5px;color:#555">🟢 Con internet</span><br>
            <span style="font-size:9.5px;color:#555">📤 Sin enviar: <b>0</b></span>
          </div>
          <div class="actions">
            <div class="btn gris">Cerrar</div>
            <div class="btn rojo">Cerrar sesión</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

#### Instrucciones

1. Tocá **ℹ Info** en el footer.
2. Aparece un panel con:
    - Nombre y versión de la app.
    - Sesión activa (correo del usuario).
    - Estado de conexión (🟢 con internet / 🔴 sin internet).
    - Cantidad de fotos sin enviar.
3. Botón **Cerrar sesión** · si hay pendientes te avisa que se van a perder. Doble confirmación antes de proceder.

## Uso del Modo Avanzado

Es la app tradicional con wizard completo. Se accede desde el link **⚙ App completa** del footer de la lite o directamente en `lemeit.github.io/DVBA/dvba_campo.html`. Se recomienda para operarios con fluidez técnica que quieren clasificar en el momento.

### Elegir categoría

👷 Técnico · Zona VI

<div class="demo" markdown="0">
  <div class="phone">
    <div class="screen">
      <div class="full-hdr" style="padding-top:34px">SIG Vial PBA · Campo<span class="sub">👷 Técnico · Zona VI</span></div>
      <div style="background:#fff;color:#1a2a3a;padding:10px 12px 6px;font-size:10px;font-weight:700;color:#009aae">¿Qué vas a relevar?</div>
      <div class="full-cats">
        <div class="full-cat"><span class="ico">🛣️</span>Calzada</div>
        <div class="full-cat"><span class="ico">💧</span>Drenaje</div>
        <div class="full-cat"><span class="ico">🌉</span>Estructura</div>
        <div class="full-cat"><span class="ico">🚧</span>Señalización</div>
        <div class="full-cat"><span class="ico">🛑</span>Demarcación</div>
        <div class="full-cat"><span class="ico">💡</span>Iluminación</div>
        <div class="full-cat"><span class="ico">🌿</span>Entorno</div>
        <div class="full-cat"><span class="ico">🚨</span>Seguridad</div>
        <div class="full-cat"><span class="ico">🚜</span>Mantenimiento</div>
        <div class="full-cat"><span class="ico">📝</span>Otro</div>
      </div>
    </div>
  </div>
</div>

#### Instrucciones

1. Se muestra una grilla con **10 categorías** de relevamiento.

2. Tocá la que corresponde a lo que vas a relevar.

3. Se abre la lista de tipos específicos dentro de esa categoría.

Ver la lista completa de tipos disponibles en la sección [MODELO_TIPOS_ESTADOS.md](https://github.com/lemeit/DVBA/blob/main/docs/MODELO_TIPOS_ESTADOS.md) del repositorio.

### Elegir tipo específico

<div class="demo" markdown="0">
  <div class="phone">
    <div class="screen">
      <div class="full-hdr" style="padding-top:34px">🛣️ Calzada<span class="sub">Elegí el tipo específico</span></div>
      <div style="background:#fff;color:#1a2a3a;padding:8px;flex:1;overflow-y:auto">
        <div style="padding:10px;border-bottom:1px solid #eee;font-size:11px">Bache</div>
        <div style="padding:10px;border-bottom:1px solid #eee;font-size:11px;background:#e6f4f8;border-left:3px solid #009aae">Bache crítico</div>
        <div style="padding:10px;border-bottom:1px solid #eee;font-size:11px">Pavimento fisurado</div>
        <div style="padding:10px;border-bottom:1px solid #eee;font-size:11px">Huellas (camino tierra)</div>
        <div style="padding:10px;border-bottom:1px solid #eee;font-size:11px">Anegamiento por mala conformación</div>
        <div style="padding:10px;border-bottom:1px solid #eee;font-size:11px">Erosión de calzada</div>
        <div style="padding:10px;border-bottom:1px solid #eee;font-size:11px">Calzada en buen estado</div>
      </div>
    </div>
  </div>
</div>

#### Instrucciones

1. Buscá en la lista el tipo específico y tocalo.

2. El sistema activa los **estados válidos** para esa categoría.

3. Si el tipo aplica **sub-atributos** (superficie, modalidad), aparecen automáticamente.

4. Si el tipo ya incluye el sub-atributo en el nombre (ej. "Desmalezado *mecánico*"), el selector se oculta y el valor se guarda solo.

### Completar datos, sacar foto y guardar

<div class="demo" markdown="0">
  <div class="phone">
    <div class="screen">
      <div class="full-hdr" style="padding-top:34px">Detalles del registro<span class="sub">Bache crítico · Calzada</span></div>
      <div style="background:#fff;color:#1a2a3a;padding:12px;flex:1;overflow-y:auto;font-size:10.5px">
        <div style="margin-bottom:8px"><label style="display:block;color:#666;font-size:9px;text-transform:uppercase;font-weight:700;margin-bottom:2px">Ruta</label><div style="padding:8px;background:#f4f6f9;border:1px solid #d4dce4;border-radius:6px;font-weight:600">RP 30</div></div>
        <div style="margin-bottom:8px"><label style="display:block;color:#666;font-size:9px;text-transform:uppercase;font-weight:700;margin-bottom:2px">Progresiva</label><div style="padding:8px;background:#f4f6f9;border:1px solid #d4dce4;border-radius:6px;font-weight:600">274,50</div></div>
        <div style="margin-bottom:8px"><label style="display:block;color:#666;font-size:9px;text-transform:uppercase;font-weight:700;margin-bottom:2px">Estado</label><div style="padding:8px;background:#fff4e0;border:1px solid #f0d090;border-radius:6px;font-weight:600;color:#c47a00">🟠 Malo</div></div>
        <div style="margin-bottom:8px"><label style="display:block;color:#666;font-size:9px;text-transform:uppercase;font-weight:700;margin-bottom:2px">Superficie</label><div style="padding:8px;background:#f4f6f9;border:1px solid #d4dce4;border-radius:6px;font-weight:600">Asfalto</div></div>
        <div style="background:#e6f4e8;border:1px solid #a0d0a5;border-radius:8px;padding:10px;text-align:center;margin-top:12px"><div style="font-size:20px;margin-bottom:4px">📷</div><div style="font-size:10px;color:#1a6a2e;font-weight:700">Foto tomada</div><div style="font-size:9px;color:#555;margin-top:2px">GPS ±5m · 82m</div></div>
        <div style="background:#1a8a4a;color:#fff;padding:12px;border-radius:8px;text-align:center;font-weight:800;font-size:11px;text-transform:uppercase;margin-top:12px">Guardar</div>
      </div>
    </div>
  </div>
</div>

#### Instrucciones

1. Completá la ruta y la progresiva (la app ayuda con autocomplete).
2. Elegí el **estado** (Bueno / Regular / Malo / Crítico según categoría).
3. Si aplica: superficie (asfalto/tierra/…), modalidad (manual/mecánico), observaciones.
4. Tocá el botón de **cámara** para sacar la foto.
5. Botón **Guardar**: se sube a Supabase o queda en cola offline.

!!! info "Sellado en oficina"
    La foto se sube **sin sello**. El sello institucional v4 se aplica cuando alguien de oficina apruebe el registro con los datos definitivos.

## Tipos de relevamiento disponibles

El sistema tiene **10 categorías** definidas en el catálogo `dvba_tipos.js`. Cada categoría agrupa ítems específicos con estados coherentes:

#### 🛣️ Calzada

Bache · Bache crítico · Pavimento fisurado · Huellas (camino tierra) · Anegamiento · Erosión · Calzada en buen estado

#### 💧 Banquinas y drenaje

Banquina deteriorada · Cuneta obstruida/dañada · Alcantarilla tapada/dañada · Erosión de talud

#### 🌉 Puentes y estructuras

Puente con fisura tablero/estribo · Junta deteriorada · Baranda dañada · Alcantarilla mayor · Muro de contención dañado

#### 🚧 Señalización vertical

Submenú extenso MSV 2017: P- (peligro), R- (reglamentario), I- (informativo), mojones, carteles de destino, guardarrails, delineadores

#### 🛑 Demarcación horizontal

Eje borrado · Demarcación lateral borrada · Tachones faltantes · Demarcación inexistente · Línea de frenado · Senda peatonal

#### 💡 Iluminación

Columna dañada/faltante · Lámpara fundida · Fallo eléctrico ramal · Tendido afectado

#### 🌿 Entorno

Vegetación a desmalezar · Inundación · Derrumbe · Árbol caído · Tranquera dañada · Animal muerto

#### 🚨 Seguridad vial

Siniestro vial · Punto negro · Zona peligrosa sin señalizar · Cámara de control · Radar de velocidad · Emergencia

#### 🚜 Mantenimiento / Tarea

Reconformado de tierra · Desmalezado manual/mecánico · Limpieza de cuneta · Bacheo (frío/caliente/profundo) · Sellado de fisuras · Repavimentación · Riego asfáltico · Repintado · Reposición señal/mojón · Mejoramiento (dolomita/suelo cal) · Poda

#### 📝 Otro

Ítem catch-all para casos no cubiertos por las otras categorías.

💡

Cada categoría tiene su propio set de estados coherentes. Ejemplo: Calzada usa

Bueno / Regular / Malo / Crítico

; Señalización vertical usa

OK / Dañada / Ilegible / Falta / Mal ubicada / En reposición

; Mantenimiento usa

Programado / En ejecución / Finalizado / Suspendido / Cancelado

.

Ver el detalle completo del modelo Tipo↔Estado en [docs/MODELO_TIPOS_ESTADOS.md](https://github.com/lemeit/DVBA/blob/main/docs/MODELO_TIPOS_ESTADOS.md) del repositorio.

## Preguntas frecuentes

### ¿Puedo usar la app sin instalar? ¿Solo desde el navegador?

Sí, pero **necesitás internet** siempre. La versión instalada como PWA funciona offline. Es fuertemente recomendado instalar.

### ¿Puedo instalar en varios celulares?

Sí, con el mismo usuario. Todo lo que subas desde cualquiera va al mismo backend.

### ¿Se pierde alguna foto si no tengo internet?

No. Todo queda en cola local (guardada en el propio celular). Cuando vuelve la señal se sincroniza automáticamente. Podés cerrar y volver a abrir la app; la cola persiste.

### ¿Cuántas fotos puedo tener en cola sin sincronizar?

Muchas (docenas). El límite es el espacio libre del celular. Cada foto comprimida pesa ~200-500 KB.

### La cámara del celular se abre pero no se guarda la foto.

Verificar permiso de cámara (Ajustes → Apps → SIG Vial PBA → Permisos → Cámara).

### La app dice que estoy sin GPS pero mi celular tiene GPS.

Verificar:

1. Permiso de ubicación al navegador (Ajustes → Apps → Chrome → Permisos → Ubicación).

2. GPS del sistema encendido (barra de notificaciones → tocar el ícono de ubicación).

3. Estar al aire libre con vista al cielo.

### ¿Qué pasa con las fotos que subo? ¿Quién las ve?

Van al backend (Supabase). El personal de oficina de tu misma zona las ve en el mapa y las aprueba. Fuera de tu zona no las ve nadie (salvo Gerencia y Admin).

### ¿La app funciona en iPhone / iPad?

Sí, pero con limitaciones de iOS: la instalación como PWA es distinta (Safari → Compartir → Agregar a pantalla de inicio) y el Service Worker tiene algunas restricciones. Para uso operativo recomendamos Android.

### Me cambié de celular. ¿Cómo migro?

Antes de dejar de usar el celular viejo, verificá que **no queden fotos en cola** (tocá 📤 Sin enviar y confirmá que dice "0"). En el celular nuevo, instalá la app y logueate con el mismo usuario. Listo, no hay que copiar nada.
