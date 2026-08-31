> [← Modo público (sin login)](03-Modo-Publico.md) · [Índice](00-Indice.md) · [Portal web (escritorio) →](05-Portal-Escritorio.md)

# Roles y accesos

SIG Vial PBA refleja el organigrama real de la DVBA en **10 roles operativos**. La interfaz se adapta automáticamente al rol del usuario logueado, y cada registro que se carga queda asociado a la zona que corresponde según el partido donde ocurrió.

---

## Organigrama de roles

```
                       ┌───────────────┐
                       │   gerencia    │  ← Central, ve las 12 zonas (solo lectura)
                       └───────┬───────┘
                               │
                       ┌───────▼───────┐
                       │   jefe_zona   │  ← 12 (uno por zona vial)
                       └───────┬───────┘
                               │
        ┌──────────────┬───────┼───────┬─────────────────┐
        │              │       │       │                 │
   ┌────▼─────┐  ┌─────▼────┐ ┌▼──────┐┌▼────────────────┐
   │jefe_admin│  │jefe_autom│ │jefe_  ││   jefe_operativa│
   │istrativa │  │otores    │ │tecnica││                 │
   └──────────┘  └──────────┘ └───┬───┘└────────┬────────┘
                                  │              │
                                  ▼              ▼
                             ┌─────────┐   ┌──────────┐
                             │ tecnico │   │ capataz  │
                             └─────────┘   └──────────┘

  admin (transversal · gestiona el sistema)
  publico (sin login · solo mapa)
```

---

## Matriz completa de permisos (fuente única de verdad)

| Rol | Alcance | Ver | Cargar | Editar | Borrar | Aprobar | Sugerir | Asignar tareas |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **publico** | Solo mapa institucional | mapa | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **tecnico** | Su zona | ✓ zona | ✓ | ✓ (propios) | ✗ | ✗ | ✗ | ✗ |
| **capataz** | Su zona | ✓ zona | ✓ (cierre de tarea) | ✗ | ✗ | ✗ | ✗ | ✗ |
| **jefe_tecnica** | Su zona | ✓ zona | ✓ | ✓ | ✗ | ✓ (relevamientos) | ✗ | ✗ |
| **jefe_operativa** | Su zona | ✓ zona | ✓ | ✓ | ✗ | ✓ (tareas cerradas) | ✗ | ✓ |
| **jefe_administrativa** | Su zona | ✓ zona | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **jefe_automotores** | Su zona | ✓ zona | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **jefe_zona** | Su zona | ✓ zona | ✓ | ✓ | ✓ con motivo | ✓ | ✗ | ✓ |
| **gerencia** | Todas las zonas | ✓ todas | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ |
| **admin** | Todo el sistema | ✓ todo | ✓ | ✓ | ✓ definitivo | ✓ | ✓ | ✓ |

**Sobre el borrado de registros**: solo admin puede borrar de forma definitiva. El jefe de zona puede borrar registros de su zona pero **debe completar un formulario con el motivo del borrado** (mínimo 10 caracteres). Los registros borrados de esa forma quedan ocultos para todos los demás roles pero **el admin los conserva y puede restaurarlos si fue un error**. Toda la actividad de borrado queda registrada en una sección de auditoría en el Panel de Administración con: fecha del archivado, quién lo archivó, motivo declarado, **quién había cargado originalmente el registro** (con su rol y zona en ese momento), y botones para restaurar o eliminar definitivamente. Los demás roles (jefes operativa/técnica/administrativa/automotores, capataces, técnicos) no pueden borrar bajo ninguna circunstancia.

**Sobre la trazabilidad de autor**: cada registro (relevamiento o parte diario) guarda automáticamente quién lo cargó, con qué rol y desde qué zona en ese momento. Esta información se conserva aunque el usuario cambie de rol o zona después. En la cola de aprobación aparece visible el autor de cada registro pendiente (ej. "👤 técnico · Zona VI") para que el aprobador sepa el origen antes de aprobar. Un caso concreto: un agente de casa central que recorra la Provincia y saque fotos desde el móvil, verá que cada registro cae en la cola del jefe de la zona geográfica correspondiente, y ese jefe verá que el autor fue "admin · (sin zona)" — información inmediata de que vino de casa central, no de su propio equipo.

**Principios que guían la matriz**:

- **Descentralización zonal**: cada zona gestiona su operativa; gerencia consulta y sugiere pero no ejecuta.
- **Jerarquía real DVBA**: los jefes de las divisiones administrativa y de automotores no cargan trabajo de campo vial (gestionan RRHH/contable y parque vehicular respectivamente); consultan datos de su zona pero no operan.
- **Mínimo privilegio con trazabilidad**: nadie borra sin dejar registro. Admin borra definitivo. Jefe de zona borra con motivo obligatorio, y su acción queda auditada.
- **Trazabilidad geográfica**: cada registro cae en la zona del partido donde ocurrió, independientemente de qué usuario lo cargó.

**Nota sobre `gerencia`**: por convención institucional y decisión de diseño, gerencia solo **lee todas las zonas y sugiere intervenciones** al jefe de la zona correspondiente. No aprueba, no edita, no borra. Preserva la descentralización — cada zona gestiona su operativa.

**Nota sobre `admin`**: además de la gestión del sistema, los usuarios admin pueden **impersonar** a cualquier otro rol o zona desde el menú para testear vistas y ayudar en soporte.

---

## Ciclo operativo completo

El sistema modela el flujo real de trabajo de la DVBA:

```
   Div. Técnica        Jefe de Zona          Capataz               Oficina (Jefe)
   ────────────        ────────────          ───────               ──────────────
   (releva foto)  ───► (asigna tarea)  ───► (ejecuta+foto)  ───► (aprueba+sella)
        │                    │                   │                     │
        ▼                    ▼                   ▼                     ▼
   RELEVAMIENTO         ASIGNACIÓN         REGISTRO CIERRE       APROBADO
   estado=pendiente    estado=en_ejec.      estado=cerrada       estado=finalizado
                                                                        │
                                                                        ▼
                                                                 REPORTES MENSUALES
                                                                    (Gerencia)
```

Cada rol interviene en una etapa distinta del ciclo:

- **Div. Técnica** (rol `tecnico` o `jefe_tecnica`) sale a campo, saca fotos con GPS, deja registros crudos.
- **Jefe de Zona / Jefe Operativa** revisa los crudos, decide qué tareas asignar y a qué capataz.
- **Capataz** ve su agenda del día en la app móvil, ejecuta, cierra con foto de la obra terminada.
- **Oficina (Jefe)** sella y aprueba el registro de cierre (armonización de datos + sello institucional).
- **Gerencia** consulta reportes mensuales consolidados por zona.

---

## Filtrado por zona · el registro sigue al **partido geográfico**

Cambio arquitectónico importante de la Fase 2: **la zona del registro NO se define por el rol del usuario que lo cargó, sino por el partido donde ocurrió**.

**Ejemplo**: un agente de Casa Central (admin/gerencia) que recorra la Provincia y cargue una foto en RP7 (partido Las Heras), verá que el registro cae automáticamente en la **cola del jefe de Zona VI Saladillo**, porque Las Heras pertenece geográficamente a esa zona.

Un capataz de Zona VI que viaje a Junín (Zona IV) y cargue un bache ahí, el registro va a la **cola del jefe IV**, no al de su propia zona.

El sistema tiene cargado el mapeo oficial de los 135 partidos bonaerenses cruzado con las 12 zonas viales DVBA, y lo aplica automáticamente cada vez que se guarda un registro.

---

## Navegación multi-zona (todos ven el mapa completo)

Cualquier usuario logueado puede **explorar el mapa** de cualquier zona con el picker `ZONA X · [Cabecera] ▾` en el header. La RLS filtra automáticamente la escritura:

- Un Jefe de Zona VI puede **navegar** el mapa de Zona IV para consultar, pero no puede cargar registros ni ver la cola de pendientes de esa zona.
- Los datos institucionales (rutas, caminos, partidos, límites administrativos) son **públicos** en las 12 zonas.

---

## Impersonación (solo admin y gerencia)

Desde el menú del header, un admin o gerencia puede **"ver como"** otro rol/zona a través del panel de impersonación. El sistema completo se comporta como si fueras ese rol/zona: menús, mapa, colas y permisos de escritura. Sirve para testear vistas de otros usuarios sin necesidad de mantener sesiones separadas.

Un banner amarillo superior indica que estás viendo el sistema como otra persona, con un botón **✕ Volver a vista real** para regresar.

---

## Cómo pedir tu usuario

Contactá al administrador del sistema (admin.zonavi@vialidad.gba.gov.ar) con tu correo institucional indicando el rol y la zona que solicitás. El administrador te crea el usuario y recibís por mail un link para definir tu contraseña.

!!! note "📷 Screenshot sugerido"
    Header del portal con el badge del usuario (tooltip "Jefe de Zona · VI · Saladillo") + picker de zona en amarillo + botón 🔔 pendientes de cola.
