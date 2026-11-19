# 14 — Auditoría y migración

- **Versión:** 1.0 — 2026-11-19
- **Ámbito:** estado del repositorio al cambiar a mundo abierto, qué se conserva y cómo se migra.
- **Marco:** [visión](01_vision_y_alcance.md), [arquitectura](02_arquitectura.md), [plan](05_plan_de_implementacion.md) y [GDD](11_diseno_de_mundo.md).

## 1. Método

Auditoría de solo lectura sobre `main` (2026-11-19): estructura de carpetas, documentos, escenas, scripts, pruebas, CI, assets y mediciones existentes. No se modificó código, escenas ni assets. Las cifras de rendimiento son las publicadas en [docs/08](08_entorno_y_rendimiento.md); no se re-midieron en esta auditoría.

## 2. Estado actual

| Área | Estado | Evidencia |
|---|---|---|
| Motor | Godot 4.7.2, Forward+, GDScript tipado | `project.godot`; `godot --version` |
| Código | ~24.200 líneas GDScript | `core/`, `campaigns/`, `tests/`, `tools/` |
| Núcleo RPG | Jugador FPS, interacción, estamina, diálogo, inventario, diario, combate, moral, estados, reputación | `core/player`, `core/interaction`, `core/systems/*` |
| Campaña 01 lineal | Cinco actos, 15 misiones, 22 fichas de escena, banderas, coste narrativo | `campaigns/01_pachacutec/documentation/` |
| Mundo | Llacta 150 × 150 m, paso 80 × 80 m, Cusco 150 × 150 m con cáscara de 520 m | `llacta.gd`, `paso.gd`, `ciudad.gd` |
| NPC | Actor con animación, mirada, caminata y diálogo; multitud con rutinas simples | `npc_actor.gd`, `ciudad.gd` |
| Arte | GLB de casas, props, vegetación, maniquíes UAL1/UAL2, Quaternius, shaders y audio | `campaigns/.../assets`, `shared_assets` |
| Pruebas | Suite headless, recorridos de integración, arco, arena, auditoría de escena | `tests/`, `tools/scene_audit.gd` |
| CI | Importación, límites, lint de archivos nuevos, pruebas, arco, exportación y arranque Linux | `.github/workflows/ci.yml` |
| Rendimiento | 218–331 draw calls por acto; ~64–99 FPS; presupuesto ≤ 350 | `docs/08` |
| Rigor histórico | Registro PCH-001 a PCH-037 con clasificación H/A/R/N | `registro_historico.md`, `docs/07` |
| Assets | ~52 MB de campaña y ~30 MB compartidos; 96 modelos/audios/texturas | `du -sh`, `find` |

## 3. Lo que no existe

| Ausencia | Consecuencia para mundo abierto |
|---|---|
| Guardado en disco | `SaveManager` pospuesto; solo banderas en memoria y puntos de control |
| Navegación | Sin `NavigationRegion3D` ni `NavigationAgent3D`; NPC por guiones |
| Streaming | Sin carga asíncrona de sectores |
| Rutinas persistentes | Los NPC no tienen casa, horario ni estado fuera de escena |
| Reloj de mundo | Sin ciclo día/noche real |
| Sistema de misiones por datos | Las misiones son directores de acto |
| Descubrimientos | Sin POI, mapa ni conocimiento del territorio |
| Economía | Sin trueque, precios ni almacenamiento |
| Selector de campañas | La portada solo conoce una campaña configurada |
| Interiores | Las casas son volúmenes, no espacios transitables con estado |

## 4. Fortalezas que se protegen

- El jugador en primera persona: movimiento, cámara, balanceo, pasos por superficie, interacción por rayo y diálogo.
- El diálogo, el diario y la localización tienen contratos limpios y pruebas.
- El registro histórico y la disciplina de fichas son un activo diferencial.
- El pipeline de Blender a GLB, los materiales y la medición de rendimiento ya existen.
- La CI y el ejecutor de pruebas son suficientes para crecer.

## 5. Límites del modelo lineal

| Límite | Por qué no sobrevive |
|---|---|
| Cinco actos = cinco escenarios | El jugador recorre escenarios, no habita un lugar |
| Directores de acto | Asumen secuencia lineal y estado de escena |
| NPC decorado | Sin casa, horario, relación ni persistencia |
| Puntos de control | No sustituyen un guardado de mundo |
| Marcadores de objetivo | La exploración y el descubrimiento no existen |
| 40–50 minutos | Incompatible con vida cotidiana y contenido no principal |
| Ocho huecos de inventario | Insuficiente para una región y una economía |
| Mapas duplicados de posguerra y obra | No son fases; son copias del mismo terreno |

## 6. Clasificación de sistemas

| Veredicto | Sistemas / archivos |
|---|---|
| **Conservar** | `PlayerFPS`, `Interactable`, `InteractionHighlight`, `StaminaComponent`, `DialogueRunner` y recursos de diálogo, `AudioManager`, `GraphicsSettings` y perfiles, `UiTheme`, HUD base, localización CSV, `SessionLog`, ejecutor de pruebas, CI, pipeline Blender/GLB, modelos, audio, shaders, registro histórico |
| **Adaptar** | `CharacterState` (habilidades, salud, ánimo, reputación), `Inventory` (16 huecos + almacenamiento), `Journal` (encargos + descubrimientos + personas + lugares), `CombatLoadout` (contextual), `NpcActor` (horarios, navegación, LOD), `CampaignInfo` (selector), `CampaignState` → `WorldState`, `QuestTracker` → guía opcional, `HUD` (menos barras, más contexto) |
| **Reconstruir** | Composición del mundo/terreno, generadores `llacta.gd`/`ciudad.gd`/`paso.gd` como escena final, simulación de NPC, navegación, streaming, persistencia, misiones/eventos, interiores, mapa del diario, selector de campañas, pruebas de mundo |
| **Retirar** | Los cinco mapas como niveles separados, `llacta_act4.tscn`/`llacta_act5.tscn` como duplicados, directores de acto, puntos de control como único guardado, marcadores como guía principal, objetivo de 40–50 min, política de “sin guardado” |
| **Investigar** | Rendimiento real de Terrain3D en UHD 770, streaming sin regiones, navmesh sobre terreno, coste de interiores, multitudes, DEM/GIS, región de la campaña III, alcance de Huamachuco en la IV |

## 7. Estrategia de migración

1. **Congelar, no borrar.** La versión lineal se queda como historial y banco de pruebas. No se amplía.
2. **Construir al lado.** Los sistemas nuevos viven en `core/world`, `core/npc`, `core/quests` y `core/save`, con pruebas propias.
3. **Sustituir por criterio.** Un sistema lineal se retira cuando su sustituto pasa las pruebas de la vertical slice.
4. **No duplicar contenido.** La historia, el elenco y las fichas se reutilizan; los mapas y directores se reinterpretan o se retiran.
5. **Medir antes de adoptar.** Terrain3D y Cyclops se prueban en F1; no se convierten en dependencia sin evidencia.
6. **Mantener CI verde.** La suite legacy sigue corriendo hasta que las escenas se retiren; las pruebas nuevas entran con su sistema.

## 8. Riesgos

| Riesgo | Impacto | Mitigación | Punto de decisión |
|---|---|---|---|
| Explosión de alcance | Muy alto | Una campaña, una región, una slice; II–IV solo diseño | F3 |
| Terrain3D no rinde en UHD 770 o CI | Alto | Spike D1; respaldo con malla/LOD propio | F1 |
| Sin streaming de regiones en Terrain3D 1.1 | Medio | Terreno siempre cargado; stream de props/NPC | F1 |
| Cyclops rompe exportación | Medio | Solo blockout; conversión a malla; probar export | F1 |
| Navmesh sobre terreno irregular | Medio | Horneado por sector desde alturas + huellas de obstáculo; waypoints de respaldo | F1 hecho en sector gris; F2/F3 |
| Guardado complejo y frágil | Alto | Esquema versionado y round-trip desde el inicio | F1 |
| Contenido de NPC y misiones mucho mayor | Muy alto | Kits, datos, reutilización, densidad sobre escala | F3 |
| Guion lineal no encaja | Alto | Fases del mismo mundo; secuencias controladas para clímax | F2 |
| Pérdida de rigor histórico al inventar geografía | Alto | GD/GR/GN; revisión externa | F2 |
| Región III/IV mal elegida | Alto | Expediente comparativo antes de fijar | F2 |
| Pruebas de actos se rompen | Medio | Suite legacy hasta sustituir escenas | F3 |
| Rendimiento de multitudes y sombras | Medio | LOD probado con 60 activos y 25 animados; MultiMesh y sombras selectivas pendientes | F1/F3 |
| Equipo pequeño y tiempo | Muy alto | Gates, recortes definidos, no abrir II–IV | Todas |

## 9. Recortes, en orden

1. Tamaño de región: de 3,5 × 2,5 km a 2 × 2 km.
2. Multitud ambiente y NPC tier C.
3. Interiores: 3 por comunidad.
4. Clima: claro/lluvia.
5. Combate: solo encuentros authored.
6. Viaje rápido: eliminado.
7. Campañas II–IV: solo documentos de diseño.

No se recorta: rigor histórico, guardado, navegación básica, rendimiento, pruebas de bloqueo.

## 10. No verificado

- Rendimiento real de Terrain3D en la UHD 770 con el terreno y la vegetación previstos.
- Comportamiento de Cyclops en exportación y CI.
- Coste del navmesh sobre Terrain3D y de los interiores aditivos.
- Región definitiva de la campaña III y alcance de Huamachuco en la IV.
- Duración real de la campaña 01 en mundo abierto.
- Que el guion lineal sobreviva completo a la reestructuración; se conserva la historia, no la implementación.
