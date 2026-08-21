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

## Matriz completa de permisos

| Rol | Alcance | Cargar relev. | Aprobar/editar | Asignar tareas | Ejecutar tareas | Reportes | Admin usuarios |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|
| **publico** | Solo mapa institucional | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **tecnico** | Su zona | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **capataz** | Su zona | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ |
| **jefe_tecnica** | Su zona | ✓ | ✓ (relev.) | ✗ | ✗ | ✓ (parcial) | ✗ |
| **jefe_operativa** | Su zona | ✓ | ✓ (tareas cerradas) | ✓ | ✗ | ✓ (parcial) | ✗ |
| **jefe_administrativa** | Su zona (lectura amplia) | ✓ | ✗ | ✗ | ✗ | ✓ (parcial) | ✗ |
| **jefe_automotores** | Su zona (lectura amplia) | ✓ | ✗ | ✗ | ✗ | ✓ (parcial) | ✗ |
| **jefe_zona** | Su zona (autoridad global de zona) | ✓ | ✓ | ✓ | ✗ | ✓ | ✗ |
| **gerencia** | Todas las zonas | ✗ (por convención) | ✗ | ✗ (interviene sugiriendo) | ✗ | ✓ | ✗ |
| **admin** | Todo el sistema | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

**Nota sobre `gerencia`**: por convención institucional, gerencia solo **lee y sugiere intervenciones** a las zonas (no aprueba ni edita). Esto preserva la descentralización — cada zona gestiona sus tareas y Casa Central acompaña.

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
