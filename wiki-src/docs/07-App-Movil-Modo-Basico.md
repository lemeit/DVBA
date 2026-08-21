> [← Panel de Administración de Usuarios](06-Panel-Administracion.md) · [Índice](00-Indice.md) · [App móvil · Modo Avanzado →](08-App-Movil-Modo-Avanzado.md)

# App móvil · Modo Básico

Es la app **por default** al instalar la PWA en el celular. Está diseñada para operarios que necesitan sacar fotos con GPS sin cargar formularios largos.

### Quién puede usarla

Cualquier agente DVBA con usuario activo puede loguearse y cargar registros desde el celular. La app **no restringe por rol** — un capataz, un técnico, un jefe de división, un jefe de zona e incluso Admin pueden usarla indistintamente. La diferencia está en dónde va a parar cada registro: el sistema lo asigna automáticamente a la zona del partido donde se sacó la foto (no a la zona del usuario que la cargó).

Ejemplo: un agente de casa central que recorra la Provincia y saque fotos en distintos partidos, verá que cada registro llega al jefe de la zona correspondiente sin tener que elegir zona manualmente.

Los siguientes roles ven la app en su celular:

- **Técnico** de zona (uso más común, en campo).
- **Capataz** de cuadrilla (carga la foto de la obra terminada).
- **Jefe** de cualquier división (Técnica, Operativa, Administrativa, Automotores) — para acompañar operativos.
- **Jefe de Zona** — para revisar directamente en campo.
- **Admin** — con acceso pleno.

La única restricción efectiva pasa por la aprobación posterior en oficina: quién aprueba el registro depende del organigrama de la zona donde cayó.

### Cómo instalarla

1. **Abrir la URL en Chrome del celular** — Ir a [lemeit.github.io/DVBA/app.html](https://lemeit.github.io/DVBA/app.html) desde Chrome (Android) o Safari (iOS). ⚠ Si ponés solo `/DVBA/` se abre el portal escritorio; para instalar la app hay que ir directo al link con `/app.html`.

2. **Instalar como app** — Menú ⋮ → *Instalar aplicación* (Android) o *Agregar a pantalla de inicio* (iOS). Aceptar el nombre **SIG Vial PBA**.

3. **Abrir desde el ícono** — El ícono aparece como cualquier otra app en el launcher. Al abrir arranca directo en Modo Básico.

!!! note "📷 Screenshot sugerido:"
    diálogo de instalación de la PWA en Android mostrando "SIG Vial PBA".

### Primer uso: ingresar

La primera vez la app pide credenciales:

!!! note "📷 Screenshot:"
    Modal de login de la lite con "Ingresar" y link "O usá la Modo Avanzado". (Ver captura tuya del 20/7.) Nota · Una vez que el usuario ingresó por primera vez con internet, la app queda logueada indefinidamente y puede usarse offline. La sesión se guarda en localStorage con el token JWT de Supabase.

### Uso diario

1. **Verificar GPS** — El banner al pie del header muestra el estado del GPS: verde = OK, amarillo = ubicando, rojo = sin señal. Si está en rojo, tocar el banner para reintentar o abrir ajustes.

2. **Tocar el botón central** — "Sacar foto" en grande. Se abre la cámara del sistema.

3. **Confirmar la foto** — Aparece un preview con las coordenadas y la fecha. Botones "Sacar otra" o "Enviar".

4. **Enviar** — Sube la foto a Supabase Storage y crea el registro. Si no hay internet, queda en cola local y se sincroniza cuando vuelva la conexión.

### Footer con acciones

- **📤 Sin enviar** · muestra fotos que quedaron en cola. Podés reintentar o borrar las que fallen.

- **⚙ Modo Avanzado** · abre la app móvil completa (queda como preferencia para próxima apertura).

- **ℹ Info** · modal con versión, estado de conexión y botón *Cerrar sesión*.

!!! note "📷 Screenshot:"
    Modal Info de la lite con datos de sesión y botón "Cerrar sesión". (Ver captura tuya del 20/7.) ⚠ Importante · La lite no clasifica ni asigna tipo de tarea. Solo captura foto + GPS. Los demás datos los completa alguien en oficina desde el portal escritorio, en la cola de aprobación. > Complemento visual (capturas/paso a paso simplificado): [ver acá](Guia-Visual-Complementaria.md#uso-del-modo-basico)
