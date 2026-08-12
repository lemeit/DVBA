# 🗂️ DVBA — SIG Vial PBA · Wiki del Proyecto

> Zona VI Saladillo · Dirección de Vialidad de la Provincia de Buenos Aires
> Vault local de Obsidian — documentación completa del sistema: uso, arquitectura, historia, desarrollo y roadmap.

---

## 📘 [[00-Indice|Guía de Usuario]]
Manual completo para quien **usa** el sistema (técnicos de campo, oficina, gerencia): qué es, cómo acceder, roles, portal, app móvil, reportes, modo offline, FAQ.
→ *Esta es la sección pensada para publicarse como ayuda pública del proyecto.*

## 🏗️ Arquitectura Técnica
Cómo está construido el sistema por dentro.
- [[MODELO_TIPOS_ESTADOS]] — modelo de categorías, ítems y estados
- [[SETUP_AUTH]] — autenticación y RLS en Supabase
- [[PLAN_STORAGE]] — estrategia de storage de fotos
- [[HANDOFF_caminos_secundarios]] — procesamiento de la capa de caminos secundarios

## 🕰️ Origen e Historia
De dónde viene el proyecto y sus fuentes históricas.
- [[REFERENCIA_NOMENCLADOR_1989]] — cuadernillo DVBA de 1989, fuente autoritativa de rutas y caminos

## 🚧 Desarrollo y Estado Actual
Qué se hizo y cuándo.
- [[bitacora|Bitácora]] — changelog completo del proyecto

## 🔭 Roadmap y Proyecciones
Qué falta y hacia dónde va el proyecto.
- [[PLAN_ESCALADO_MULTIZONA]] — escalado a las 12 zonas de la DVBA
- [[PLAN_ROLES_MULTIZONA]] — modelo de roles y permisos multi-zona
- [[CONCURSO_VIAL_2026]] — presentación al XLI Concurso sobre Temas Viales

## 🧭 Decisiones Técnicas (ADRs)
Registro de decisiones importantes, con contexto y alternativas consideradas.
- [[2026-08-Cruce-partidos-zonas-rutas|Cruce Partidos ↔ Zonas ↔ Rutas]]

## 📊 Informes Gerenciales
- [[ANALISIS_INFORME_GERENCIAL_DVBA]] — estructura del informe mensual oficial de Gerencia

---

### Cómo navegar
- Abrí el **Graph View** (Ctrl+G) para ver todo el proyecto conectado visualmente.
- Cada nota tiene links de "anterior / índice / siguiente" cuando corresponde a una secuencia de lectura (ver la Guía de Usuario).
- Las notas de **Decisiones Técnicas** siguen formato `AAAA-MM-Titulo.md` — se agrega una nueva cada vez que se resuelve algo importante.

### Sobre esta estructura
- `01-Guia-de-Usuario/` es la única carpeta pensada para hacerse pública en algún momento (vía Quartz → GitHub Pages).
- El resto de las carpetas son documentación **interna** del proyecto — arquitectura, historia, roadmap, decisiones — y quedan fuera de cualquier publicación futura salvo que se decida lo contrario.
