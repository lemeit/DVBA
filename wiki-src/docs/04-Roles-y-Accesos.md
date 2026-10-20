> [← Modo público (sin login)](03-Modo-Publico.md) · [Índice](00-Indice.md) · [Portal web (escritorio) →](05-Portal-Escritorio.md)

# Roles y accesos

**Actualización: 20/10/2026.** Las reglas de esta página reemplazan la autorización anterior de archivado del Jefe de Zona. El sistema está en pruebas con datos reales.

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

## Matriz vigente de accesos y borrado

Todos pueden consultar la cartografía pública. Ver el mapa de una zona no permite ver ni modificar sus registros.

| Perfil | Registros que consulta | Captura de fotos/registros | Eliminar o archivar | Solicitar borrado |
|---|---|---|---|---|
| Público / sin sesión | Ninguno; solo cartografía | No | No | No |
| Sin perfil o desactivado | Ninguno | No | No | No |
| **Unidad Ambiental** | Solo propios, en toda la provincia | En toda la provincia; fotos privadas | No | No sobre operativa zonal |
| Técnico vial | Su zona | Zonal, según configuración¹ | No | No |
| Capataz | Su zona¹; trabajo previsto con tareas asignadas | Cierre de tareas¹ | No | No |
| Jefe de Zona | Su zona | Su zona | **No** | Sí, en su zona |
| Jefe de División Técnica | Su zona | Su zona | **No** | Sí, en su zona |
| Jefe de División Operativa | Su zona | Su zona | **No** | Sí, en su zona |
| Jefe de División Administrativa | Su zona, consulta | No | **No** | Sí, en su zona |
| Jefe de División Automotores | Su zona, consulta | No | **No** | Sí, en su zona |
| Gerencia | Operativa vial provincial; no originales privados de Ambiente | No | **No** | Sí |
| Administrador | Todo, incluyendo Ambiente | Provincial | **Sí** | Ejecuta o descarta pedidos |

¹ La captura provincial opcional del técnico y el control fino del cierre del capataz siguen sujetos a integración y revisión. La matriz resume los accesos principales; no certifica todas las operaciones históricas de edición.

### Unidad Ambiental

La cuenta usa la misma app con **Modo Básico y Modo Avanzado**, sin una pantalla independiente ni mapa móvil. El encabezado muestra **Unidad Ambiental · Todas las Zonas Viales**. El mapa se consulta desde el portal de escritorio.

Puede recorrer cualquier zona y crear sus propios registros. No accede a los registros operativos de cada zona ni a los de otros integrantes del área. Ubicar una foto en una zona no la comparte automáticamente. El administrador puede consultar los registros y fotos privados. Una compartición explícita autorizada con jefes destinatarios puede revocarse y no se extiende a Gerencia.

### Solicitud de borrado

Gerencia y los cinco roles de jefatura pueden pedir el borrado de un registro o parte de su alcance. Deben escribir una **justificación de al menos 10 caracteres**. El pedido llega a **Administración → Solicitudes** y el registro sigue disponible hasta que admin actúe. La notificación queda dentro del sistema; no se envía un correo.

**Solo el administrador elimina o archiva.** Los jefes no tienen borrado delegado ni archivo autónomo. El administrador ejecuta o descarta y queda la respuesta en la solicitud. Los archivos históricos pueden restaurarse; una eliminación definitiva es irreversible.

### Seguridad de las fotos

La subida anónima está bloqueada en el servidor. Gerencia y perfiles de consulta no pueden subir, reemplazar ni borrar fotos. Un operativo puede actualizar sus archivos propios; los jefes operativos pueden actualizar fotos vinculadas a registros de su zona. Solo admin puede eliminar archivos zonales. Las fotos nuevas de Ambiente son privadas; las fotos zonales históricas conservan su lectura pública.

### Usuarios y contraseñas

El administrador asigna roles, área y zona. Unidad Ambiental es un perfil de técnico con área Ambiente y alcance provincial de captura; **no necesita ser admin**. Una cuenta sin perfil activo no obtiene permisos por defecto.

Las cuentas de prueba se conservan. Se retiró la contraseña inicial compartida del código publicado, pero **el usuario decidió cambiarla o revocarla más adelante**. Hasta hacerlo, quitar el texto no invalida una contraseña que siga en uso y Git puede conservar versiones anteriores.

La matriz técnica y las limitaciones de la revisión están en el [README técnico](95-README-Tecnico.md). No es una certificación integral de seguridad.

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

**Ejemplo:** una captura vial autorizada en Las Heras se ubica geográficamente en Zona VI. La ubicación no amplía los permisos de la cuenta. Gerencia consulta y sugiere; no captura fotos. El capataz trabaja en el circuito de tareas habilitado para su perfil.

**Excepción de privacidad:** un registro de Unidad Ambiental conserva su ubicación geográfica, pero no entra por ese solo hecho en la operativa visible de la zona. Continúa siendo propio y privado hasta una compartición autorizada.

El sistema tiene cargado el mapeo oficial de los 135 partidos bonaerenses cruzado con las 12 zonas viales DVBA, y lo aplica automáticamente cada vez que se guarda un registro.

---

## Navegación multi-zona (todos ven el mapa completo)

Cualquier usuario logueado puede **explorar el mapa** de cualquier zona con el picker `ZONA X · [Cabecera] ▾` en el header. La RLS filtra automáticamente la escritura:

- Un Jefe de Zona VI puede **navegar** el mapa de Zona IV para consultar, pero no puede cargar registros ni ver la cola de pendientes de esa zona.
- Los datos institucionales (rutas, caminos, partidos, límites administrativos) son **públicos** en las 12 zonas.

---

## Impersonación (solo admin y gerencia)

Desde el menú del header, un admin o gerencia puede **"ver como"** otro rol/zona a través del panel de impersonación. La vista cambia menús y contexto para probar la interfaz. Esto no cambia la identidad autenticada ni reemplaza la autorización del servidor; no certifica los permisos reales de otra cuenta. Sirve para testear vistas de otros usuarios sin necesidad de mantener sesiones separadas.

Un banner amarillo superior indica que estás viendo el sistema como otra persona, con un botón **✕ Volver a vista real** para regresar.

---

## Cómo pedir tu usuario

Contactá al administrador del sistema (admin.zonavi@vialidad.gba.gov.ar) con tu correo institucional indicando el rol y la zona que solicitás. El administrador te crea el usuario y recibís por mail un link para definir tu contraseña.

!!! note "📷 Screenshot sugerido"
    Header del portal con el badge del usuario (tooltip "Jefe de Zona · VI · Saladillo") + picker de zona en amarillo + botón 🔔 pendientes de cola.
