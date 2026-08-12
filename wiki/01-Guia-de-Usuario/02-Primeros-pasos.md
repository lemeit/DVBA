> [[01-Que-es-el-sistema|← ¿Qué es el sistema?]] · [[00-Indice|Índice]] · [[03-Modo-Publico|Modo público (sin login) →]]

# Primeros pasos

> Cómo acceder al sistema, instalar la app en el celular y entender cómo sincroniza. Para la visión general del sistema ver [[01-Que-es-el-sistema]].

## 2. Cómo se accede

El sistema tiene **dos URLs** según lo que quieras usar:

- 🖥 **Portal escritorio** — [lemeit.github.io/DVBA/](https://lemeit.github.io/DVBA/). Se abre el mapa + herramientas de oficina + Plan de Seguridad + Reportes. Pensado para computadora.
- 📱 **App móvil (Modo Básico / Modo Avanzado)** — [lemeit.github.io/DVBA/app.html](https://lemeit.github.io/DVBA/app.html). Se abre la app para instalar en el celular. Este es el link que hay que abrir en Chrome del teléfono.

!!! tip "No hace falta bajar nada de la tienda"
    Todo funciona con el navegador del celular o de la compu. Si abrís la URL base (`/DVBA/`) en un celular vas a caer en el portal — para instalar la app tenés que ir directo a `/app.html`.

## 3. Instalar la app en el celular (PWA)

La app se instala como cualquier otra app del celular, pero **sin pasar por la Play Store o App Store**. El proceso lleva 30 segundos:

#### Paso a paso

1. Abrir **Chrome** en el celular.
2. Ir a `lemeit.github.io/DVBA/app.html` (importante: el `/app.html` al final, sino se abre el portal escritorio).
3. Al abrir aparece un banner o el menú ⋮ muestra la opción **"Instalar aplicación"**.
4. Tocarla y aceptar. Se agrega el ícono al launcher del celular.
5. A partir de acá, abrís la app tocando ese ícono como cualquier otra app.

El ícono se llama **"SIG Vial PBA"** y aparece con el logo institucional DVBA.

### Actualizaciones automáticas

Cuando hay una versión nueva del sistema, al abrir la app aparece un banner verde arriba: **🔄 Hay una versión más nueva · De v9.90 → v9.91 · tocá Actualizar**.

#### Cómo actualizar

1. Al abrir la app, si hay versión nueva aparece el banner verde arriba.
2. Tocar **Actualizar**.
3. La app se recarga con la versión nueva en menos de 2 segundos.

!!! warning "Importante"
    Si no tocás Actualizar, la app va a seguir funcionando con la versión vieja cacheada. No perdés nada, pero no tenés los últimos cambios.

## 4. Navegador vs app instalada · WiFi/datos vs GPS

### 🌐 Desde el navegador (sin instalar)

Si abrís la URL directamente en Chrome sin instalar la app:

- Necesitás **obligatoriamente** WiFi o datos móviles para que la app cargue.
- Si se corta la conexión, se pierde todo lo que estabas haciendo.
- No hay cola offline: cada foto necesita internet en el momento.

**Uso recomendado**: prueba rápida, primera vez, o desde la computadora de oficina.

### 📱 Como app instalada (PWA)

Una vez que instalaste la app y te logueaste al menos una vez con internet:

- **NO requiere WiFi ni datos** para funcionar.
- Solo necesita **señal de GPS** del celular (que funciona incluso sin internet).
- Guarda las fotos en una cola local.
- Sincroniza automáticamente cuando vuelva la conexión.

**Uso recomendado**: campo, zonas rurales, cualquier situación operativa.

!!! tip "💡 Regla práctica"
    Instalá la app la primera vez que tengas WiFi (en la oficina). Después usala en el campo sin importar si tenés señal — el GPS funciona en cualquier lado. Cuando volvés a la oficina o entrás en zona con señal, todo se sincroniza solo.

## 5. Cómo sincroniza con el sistema de escritorio

Todo lo que se carga desde el celular aparece automáticamente en el sistema de escritorio, sin que nadie tenga que hacer nada manual:

| Paso | Dónde | Qué pasa |
|:---:|---|---|
| **1.** 📱 | App celular | Saca la foto con GPS y la guarda en cola local |
| **2.** ☁ | Supabase | Sube automáticamente cuando hay conexión |
| **3.** 🖥 | Portal escritorio | Aparece en el mapa, lista para aprobar |

### Qué ve el personal de oficina

Cuando el técnico de campo envía una foto, en el portal de escritorio (abierto en la computadora de la oficina o de cualquier notebook con conexión) aparece:

- Un pin nuevo en el mapa, en la posición GPS exacta donde se sacó la foto.
- Un registro en la cola de aprobación con estado *"campo"* (a la espera de revisión).
- La foto cruda sin sello (el sello institucional se aplica al aprobar).

Desde escritorio, el personal responsable revisa, completa datos y aprueba. La foto queda sellada con los datos definitivos y trazable con QR de Google Maps.

!!! info "🔒 Seguridad"
    Todos los registros llevan el ID del usuario que los cargó. Cada zona de la DVBA solo ve sus propios datos (excepto Gerencia y Admin, que ven todo).
