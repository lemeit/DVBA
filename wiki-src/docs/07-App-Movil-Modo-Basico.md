> [← Panel de Administración de Usuarios](06-Panel-Administracion.md) · [Índice](00-Indice.md) · [App móvil · Modo Avanzado →](08-App-Movil-Modo-Avanzado.md)

# App móvil · Modo Básico

Es la app **por default** al instalar la PWA en el celular. Está diseñada para operarios que necesitan sacar fotos con GPS sin cargar formularios largos.

### Cómo instalarla

1. **Abrir la URL en Chrome del celular** — Ir a [lemeit.github.io/DVBA/app.html](https://lemeit.github.io/DVBA/app.html) desde Chrome (Android) o Safari (iOS). ⚠ Si ponés solo `/DVBA/` se abre el portal escritorio; para instalar la app hay que ir directo al link con `/app.html`.

2. **Instalar como app** — Menú ⋮ → *Instalar aplicación* (Android) o *Agregar a pantalla de inicio* (iOS). Aceptar el nombre **SIG Vial PBA**.

3. **Abrir desde el ícono** — El ícono aparece como cualquier otra app en el launcher. Al abrir arranca directo en Modo Básico.

📷

Screenshot sugerido:

diálogo de instalación de la PWA en Android mostrando "SIG Vial PBA".

### Primer uso: ingresar

La primera vez la app pide credenciales:

📷

Screenshot:

Modal de login de la lite con "Ingresar" y link "O usá la Modo Avanzado"

. (Ver captura tuya del 20/7.)

Nota

· Una vez que el usuario ingresó por primera vez con internet, la app queda logueada indefinidamente y puede usarse offline. La sesión se guarda en

localStorage

con el token JWT de Supabase.

### Uso diario

1. **Verificar GPS** — El banner al pie del header muestra el estado del GPS: verde = OK, amarillo = ubicando, rojo = sin señal. Si está en rojo, tocar el banner para reintentar o abrir ajustes.

2. **Tocar el botón central** — "Sacar foto" en grande. Se abre la cámara del sistema.

3. **Confirmar la foto** — Aparece un preview con las coordenadas y la fecha. Botones "Sacar otra" o "Enviar".

4. **Enviar** — Sube la foto a Supabase Storage y crea el registro. Si no hay internet, queda en cola local y se sincroniza cuando vuelva la conexión.

### Footer con acciones

- **📤 Sin enviar** · muestra fotos que quedaron en cola. Podés reintentar o borrar las que fallen.

- **⚙ Modo Avanzado** · abre la app móvil completa (queda como preferencia para próxima apertura).

- **ℹ Info** · modal con versión, estado de conexión y botón *Cerrar sesión*.

📷

Screenshot:

Modal Info de la lite con datos de sesión y botón "Cerrar sesión"

. (Ver captura tuya del 20/7.)

⚠ Importante

· La lite

no clasifica

ni asigna tipo de tarea. Solo captura foto + GPS. Los demás datos los completa

alguien en oficina

desde el portal escritorio, en la cola de aprobación.

> Complemento visual (capturas/paso a paso simplificado): [ver acá](Guia-Visual-Complementaria.md#uso-del-modo-basico)
