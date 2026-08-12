> [[03-Modo-Publico|← Modo público (sin login)]] · [[00-Indice|Índice]] · [[05-Portal-Escritorio|Portal web (escritorio) →]]

# Roles y accesos

SIG Vial PBA maneja 4 niveles de usuario. La UI se adapta automáticamente al rol del usuario logueado:

| Rol | Alcance | Reportes | Panel Visualización | Picker de zonas |

|---|---|---|---|---|

| Público sin login | Solo mapa base + info de rutas y caminos. | ✗ | ✗ | ✓ (explora cualquier zona) |

| Técnico de zona | CRUD completo dentro de su zona asignada. | ✗ | ✗ | ✗ (zona fija de su perfil) |

| Gerencia o Auditoría | Todas las zonas + reportes consolidados. | ✓ | ✗ | ✓ (elige zona a visualizar) |

| Admin o Desarrollador | Todo + gestión de usuarios y catálogos. | ✓ | ✓ | ✓ |

💡 Cómo pedir tu usuario

Contactá al administrador del sistema (

lulamaita@vialidad.gba.gov.ar

) con tu correo institucional. Te van a asignar rol y zona en la tabla

usuarios_perfil

de Supabase, y podés loguearte con ese correo + la contraseña que definas al recibir el link de invitación.

📷

Screenshot sugerido:

header del portal mostrando el badge del usuario con tooltip

"Técnico · Zona VI"

.

════════════════════════════════════════════════════════════

