> [[13-Modo-Offline|← Modo offline y sincronización]] · [[00-Indice|Índice]] · [[00-Indice|Volver al índice →]]

# Preguntas frecuentes

### ¿Cómo pido un usuario?

Contactá al administrador del sistema ([lulamaita@vialidad.gba.gov.ar](mailto:lulamaita@vialidad.gba.gov.ar)). Te dará de alta en Supabase Auth y te asignará rol y zona.

### Me olvidé la contraseña. ¿Cómo la recupero?

Desde el dashboard de Supabase, el admin puede enviar un email de *Password recovery* al correo del usuario. También puede setear una password manualmente.

### La app móvil no carga el GPS.

Verificar:

1. Permiso de ubicación otorgado al navegador (Ajustes → Apps → Chrome → Permisos → Ubicación).

2. GPS del sistema encendido (barra de notificaciones → tocar el ícono de ubicación).

3. Estás al aire libre con vista al cielo (dentro de edificios el GPS puede no captar).

El botón del GPS en la app abre un modal con estas mismas instrucciones.

### Subí una foto pero no aparece en el mapa.

Verificar en la cola de pendientes (📤 Sin enviar). Si está ahí, es porque no se sincronizó. Reintentar con conexión. Si la foto no tiene GPS, no puede ubicarse en el mapa — completar la ubicación desde oficina al aprobar.

### El link "Modo Avanzado" en el login no hace nada.

Corregido en **v9.73**. Si estás en una versión anterior, tocá *Actualizar* en el banner verde de arriba.

### La app se llama "DVBA Campo Zona VI" en mi celular, no "SIG Vial PBA".

Es cache de Android. La app se renombró institucionalmente en v8.2/v9.72. Al actualizar por el banner, Android va a proponer el nuevo nombre en un diálogo *"Revisar actualización del nombre"*. Aceptar. Si no aparece, desinstalar y reinstalar la PWA.

### ¿Puedo instalar la app en la notebook?

Sí. Chrome/Edge muestran un botón "Instalar" en la barra de direcciones cuando abrís [lemeit.github.io/DVBA/app.html](https://lemeit.github.io/DVBA/app.html) (o la variante `dvba_campo.html`). La PWA queda como app nativa del sistema.

### ¿Los reportes generan un PDF idéntico al Informe Mensual de Gerencia?

El módulo Reportes genera un PDF con charts + tabla, con la paleta oficial de 8 colores. El PDF oficial Gerencia completo (portada institucional + 2 hojas por zona + luminarias LED + anexo fotográfico) está previsto para la **Fase 5 del Plan de Roles** — ver [PLAN_ROLES_MULTIZONA.md](https://github.com/lemeit/DVBA/blob/main/docs/PLAN_ROLES_MULTIZONA.md) en el repositorio.

Guía · SIG Vial PBA · v1.3 · 2 de agosto de 2026

División Técnica DVBA · Departamento Zona VI Saladillo · Contacto:

lulamaita@vialidad.gba.gov.ar

lemeit.github.io/DVBA/

·

github.com/lemeit/DVBA

> Preguntas adicionales de la versión visual: [[Guia-Visual-Complementaria#Preguntas frecuentes|ver acá]]
