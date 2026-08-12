# Guía Visual Complementaria

> Contenido original de la guía visual (versión resumida con capturas), útil como referencia rápida complementaria a las notas detalladas: [[07-App-Movil-Modo-Basico]], [[08-App-Movil-Modo-Avanzado]], [[14-FAQ]].

## 6. Uso del Modo Básico

Es la app **por default** al instalar. Está pensada para operarios que necesitan solo sacar fotos con GPS, sin cargar formularios largos. Todos los demás datos los completa alguien en la oficina.

### 6.1 Primera vez que la abrís · Ingresar

👷 Técnico · Zona VI

🔐

### Ingresar

Ingresá con tu cuenta para poder enviar registros.

Ingresar

O usá la Modo Avanzado.

#### Instrucciones

1. Ingresá con el correo y contraseña que te asignó el administrador.

2. La primera vez **necesitás WiFi o datos** para que la app valide tu identidad con el servidor.

3. Una vez logueado, la app te recuerda por tiempo indefinido. Podés cerrar y abrir sin volver a poner clave.

💡

¿No tenés usuario? Contactá al administrador del sistema:

lulamaita@vialidad.gba.gov.ar

. Te van a dar de alta con tu correo institucional.

**📱 Multi-zona (v9.91+)** — la app es la misma para todas las zonas DVBA (I a XII). Una vez logueado, el header muestra tu **rol** y **zona** real (ej. `👷 Técnico · Zona IV`). El sistema aplica automáticamente las políticas de la zona asignada — solo ves y cargás datos de tu área.

### 6.2 Verificar el GPS antes de sacar fotos

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

### 6.3 Sacar y enviar una foto

👷 Técnico · Zona VI

📸

Sacar foto

y guardar ubicación

Solo tocá el botón para

sacar la foto

y guardar el

lugar exacto

.

Los demás datos los completa

alguien en la oficina

.

📤

Sin enviar

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

### 6.4 Ver y gestionar los pendientes

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

### 6.5 Panel de información y cerrar sesión

👷 Técnico · Zona VI

ℹ

### Información

SIG Vial PBA · Modo Básico

Versión

v9.91

---

Sesión

👷 Técnico · Zona VI

tecnica.dvba.z6@vialidad.gba.gov.ar

🟢 Con internet

📤 Sin enviar:

0

Cerrar

Cerrar sesión

#### Instrucciones

1. Tocá **ℹ Info** en el footer.

2. Aparece un panel con:
        
Nombre y versión de la app.
Sesión activa (correo del usuario).
Estado de conexión (🟢 con internet / 🔴 sin internet).
Cantidad de fotos sin enviar.

3. Botón **Cerrar sesión** · si hay pendientes te avisa que se van a perder. Doble confirmación antes de proceder.

## 7. Uso del Modo Avanzado

Es la app tradicional con wizard completo. Se accede desde el link **⚙ App completa** del footer de la lite o directamente en `lemeit.github.io/DVBA/dvba_campo.html`. Se recomienda para operarios con fluidez técnica que quieren clasificar en el momento.

### 7.1 Elegir categoría

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

Ver la lista completa de tipos disponibles en la [sección 8](#tipos).

### 7.2 Elegir tipo específico

Elegí el tipo específico

Bache

Bache crítico

Pavimento fisurado

Huellas (camino tierra)

Anegamiento por mala conformación

Erosión de calzada

Calzada en buen estado

#### Instrucciones

1. Buscá en la lista el tipo específico y tocalo.

2. El sistema activa los **estados válidos** para esa categoría.

3. Si el tipo aplica **sub-atributos** (superficie, modalidad), aparecen automáticamente.

4. Si el tipo ya incluye el sub-atributo en el nombre (ej. "Desmalezado *mecánico*"), el selector se oculta y el valor se guarda solo.

### 7.3 Completar datos, sacar foto y guardar

Bache crítico · Calzada

Ruta

RP 30

Progresiva

274,50

Estado

🟠 Malo

Superficie

Asfalto

📷

Foto tomada

GPS ±5m · 82m

Guardar

#### Instrucciones

1. Completá la ruta y la progresiva (la app ayuda con autocomplete).

2. Elegí el **estado** (Bueno / Regular / Malo / Crítico según categoría).

3. Si aplica: superficie (asfalto/tierra/…), modalidad (manual/mecánico), observaciones.

4. Tocá el botón de **cámara** para sacar la foto.

5. Botón **Guardar**: se sube a Supabase o queda en cola offline.

Sellado en oficina

· La foto se sube

sin sello

. El sello institucional v4 se aplica cuando alguien de oficina apruebe el registro con los datos definitivos.

## 8. Tipos de relevamiento disponibles

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

Ver el detalle completo del modelo Tipo↔Estado en [docs/MODELO_TIPOS_ESTADOS.md](MODELO_TIPOS_ESTADOS.md).

## 9. Preguntas frecuentes

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
