# 02 — Arquitectura

- **Versión:** 2.0 — 2026-11-19
- **Ámbito:** capas, sistemas, persistencia, navegación y streaming del mundo abierto regional.
- **Marco:** [visión](01_vision_y_alcance.md), [GDD de mundo](11_diseno_de_mundo.md), [pipeline](13_pipeline_de_escenarios.md) y [estándares](03_estandares_de_codigo.md).

## 1. Capas

```text
┌──────────────────────────────────────────┐
│ campaigns/NN_nombre/                     │  Contenido de una época
│   data, scenes, assets, scripts          │
└───────────────┬──────────────────────────┘
                │ depende de
┌───────────────▼──────────────────────────┐
│ core/                                    │  Sistemas compartidos
│   world, npc, quests, save, player, ui   │
└───────────────┬──────────────────────────┘
                │ depende de
┌───────────────▼──────────────────────────┐
│ shared_assets/                           │  Recursos sin lógica de campaña
│   materials, shaders, fonts, audio, ui   │
└──────────────────────────────────────────┘
```

### Reglas de dependencia (obligatorias)

1. `core/` **no** referencia rutas, clases ni recursos de `campaigns/`.
2. Una campaña **no** referencia otra campaña.
3. `shared_assets/` no contiene scripts con lógica de juego.
4. La comunicación de abajo hacia arriba (Core → contenido/UI) se hace **por señales**, nunca por rutas rígidas.
5. Las dependencias entre sistemas Core se inyectan (`@export`, parámetros, señales) o se acceden vía autoload documentado. Sin dependencias circulares.
6. Una campaña nueva no requiere modificar jugador, guardado, interacción, navegación ni audio. Si lo requiere, se revisa la arquitectura y se anota en la bitácora.
7. **Core interpreta datos; no contiene contenido.** Los IDs, textos, rutas y reglas de una campaña viven en `campaigns/`.

## 2. Estructura del repositorio

```text
memorias-del-peru/
├── project.godot
├── README.md
├── AGENTS.md
├── docs/
├── tests/
├── core/
│   ├── autoload/            game_manager, audio_manager, session_log, campaign_state
│   ├── player/              player_fps, manos, pasos, respiración
│   ├── interaction/         interactable, resaltado
│   ├── world/               reloj, sectores, streaming, navegación, eventos
│   ├── npc/                 definición, horario, director, LOD
│   ├── quests/              definición, estado, condiciones, efectos
│   ├── save/                esquema, manager, migraciones
│   ├── systems/             stamina, inventory, dialogue, journal, combat, graphics
│   ├── ui/                  HUD, diálogo, diario, mapa, portada
│   └── localization/        core_texts.csv
├── shared_assets/           materials/, shaders/, fonts/, textures/, audio/, ui/
├── campaigns/
│   └── 01_pachacutec/
│       ├── data/            npcs/, quests/, locations/, items/, schedules/
│       ├── scenes/          world/, interiors/, sequences/, npcs/, objects/
│       ├── assets/          models/, textures/, audio/, animations/, blender/
│       ├── localization/    pachacutec_texts.csv
│       └── documentation/   biblia, guion, expediente, registro, mundo/
├── tools/
└── addons/                  solo si se aprueba; excluido del lint
```

Los directorios se crean **solo** cuando reciben su primer archivo funcional.

## 3. Autoloads

| Autoload | Responsabilidad | Estado |
|---|---|---|
| `GameManager` | Pausa, cierre ordenado, cambio de escena de alto nivel | Implementado |
| `AudioManager` | Buses, reproducción de efectos y ambiente, volumen | Implementado |
| `GraphicsSettings` | Perfil gráfico activo y ajustes | Implementado |
| `CampaignState` | Banderas y datos de campaña en memoria | Implementado; se integra con `WorldState` |
| `SessionLog` | Registro de sesión y duración | Implementado |
| `WorldClock` | Hora, día, clima y señales de cambio | F1 |
| `WorldState` | Fase, banderas, descubrimientos, estado de NPC y mundo físico | F1 |
| `SaveManager` | Serialización versionada, ranuras, autoguardado | F1 |
| `ContentRegistry` | Carga y valida definiciones de la campaña activa | F1 |

Máximo 9. Un autoload solo se registra cuando tiene responsabilidad real y pruebas.

## 4. Jugador en primera persona

Se conserva `PlayerFPS` (`CharacterBody3D`) con esta jerarquía:

```text
PlayerFPS (CharacterBody3D)
├── CollisionShape3D            CapsuleShape3D
├── StaminaComponent
└── Head (Node3D)               rotación vertical (pitch)
    └── Camera3D                head bobbing
        └── InteractionRay (RayCast3D)
```

### Contratos que se conservan

- Origen a los pies; ojos a 1,60 m; cápsula centrada a 0,875 m.
- Yaw en el cuerpo, pitch en `Head`, límite ±80°.
- Movimiento con `Input.get_vector`, aceleración/desaceleración, gravedad y `move_and_slide`.
- Head bobbing calculado desde `camera_base_position`; sin acumulación.
- Pasos sincronizados con el balanceo; superficie por metadato `footstep_surface`.
- Interacción por rayo con caché del collider; señales `interactable_focused`, `interactable_unfocused`, `interacted`.
- El jugador no decide la pausa: escucha `GameManager.pause_changed`.
- El jugador no conoce campañas, UI ni tipos concretos de objetos.

### Añadidos para mundo abierto

- `stamina` con coste por terreno, carga y altitud.
- `carry` y `q'ipi` (almacenamiento) sin sistema de peso.
- `orientation` (brújula/mapa del diario) y modo guía opcional.
- `rest` y `sleep` como acciones de mundo, no de escena lineal.
- Interacción contextual con NPC, contenedores, puertas, oficios y descubrimientos.

## 5. Interacción

- `class_name Interactable extends Node3D` con `interact(interactor)`, `get_interaction_text()` e `is_available()`.
- El script del objeto hereda de `Interactable` y se asigna a la raíz de su escena.
- El jugador detecta el collider y sube por ancestros hasta encontrar un `Interactable` (límite documentado).
- `InteractionHighlight` resalta el objeto enfocado; no ilumina la escena entera.
- Un interactuable no disponible no se enfoca ni responde.
- Los objetos de una campaña declaran su clave de texto; Core no contiene textos de campaña.

## 6. Sistemas RPG

| Sistema | Ubicación | Contrato |
|---|---|---|
| Estado | `core/systems/rpg/character_state.gd` | Salud, ánimo, habilidades 0–5 por uso, reputación por grupo; señales de cambio |
| Inventario | `core/systems/inventory/` | Huecos, equipados, `add`, `remove`, `count`, `has`, `use`; sin peso ni loot aleatorio |
| Diálogo | `core/systems/dialogue/` | Nodos con texto, opciones, condiciones y efectos; no conoce la UI |
| Diario | `core/systems/journal/` | Encargos, descubrimientos, personas, lugares y memoria; sello H/A/R/N |
| Combate | `core/systems/combat/` | Honda, porra y escudo; moral enemiga; sin barras flotantes |
| Estamina | `core/systems/stamina/` | Consumo/regeneración; el jugador decide las reglas de carrera |

### Cambios de contrato para mundo abierto

- Inventario: **16 huecos + 3 equipados + almacenamiento en casa**. El valor de 8 huecos queda como histórico de la versión lineal.
- Habilidades: se conservan las cinco (Honda, Mano, Palabra, Oficio, Monte), con desbloqueos de acción, no solo números.
- Reputación: por comunidad/ayllu/facción; no una barra única.
- Relaciones: valor individual por NPC nombrado.
- Diario: además de encargos, registra descubrimientos y conocimiento del territorio.
- Combate: contextual; el sistema no cambia el resultado histórico.
- Guardado: el estado del jugador se serializa con IDs estables.

## 7. Sistemas de mundo (nuevos)

| Sistema | Responsabilidad | Señales / contrato |
|---|---|---|
| `WorldClock` | Hora, día, clima, franjas | `time_changed`, `day_changed`, `weather_changed` |
| `SectorStreamer` | Carga/descarga de sectores exteriores | `sector_loaded`, `sector_unloaded`, `load_sector`, `unload_sector` |
| `SectorState` | Estado persistente del sector | Contenedores, puertas, props, NPC |
| `InteriorManager` | Carga aditiva de interiores | `enter_interior`, `exit_interior` |
| `NavigationService` | Navmesh por sector, rutas y enlaces | `find_path`, `map_changed` |
| `NpcDirector` | Spawn/despawn, LOD, horarios | `npc_spawned`, `npc_despawned`, `schedule_applied` |
| `QuestDirector` | Estado de misiones | `quest_started`, `stage_changed`, `quest_completed` |
| `WorldEventDirector` | Disparadores y secuencias | `event_started`, `event_finished` |
| `DiscoveryRegistry` | POI y mapa del diario | `discovered` |

Reglas:

- Los sistemas de mundo no conocen campañas; leen definiciones por `ContentRegistry`.
- Los IDs son estables y legibles (`npc_sisa`, `poi_mirador`, `quest_mensajero`).
- Todo estado que sobrevive a una escena declara su serialización.
- Las secuencias controladas usan el mismo director de eventos, no un script de acto.

## 8. NPC

### 8.1. Datos

`NpcDefinition` (Resource):

```gdscript
class_name NpcDefinition
extends Resource

@export var id: StringName
@export var name_key: StringName
@export var tier: int                 # 0 = narrativo, 1 = comunidad, 2 = ambiente
@export var home_anchor: StringName
@export var work_anchor: StringName
@export var schedule: Array[ScheduleEntry]
@export var dialogue: DialogueGraph
@export var faction: StringName
@export var appearance: StringName
```

`ScheduleEntry`: inicio, fin, ancla, actividad, condiciones.

### 8.2. Simulación por niveles

| Nivel | Distancia | Actualización | Navegación | Persistencia |
|---|---|---|---|---|
| Cerca | < 30 m | 60 Hz | Completa | Sí |
| Medio | 30–80 m | 5–10 Hz | Simple | Sí |
| Lejos | > 80 m / fuera de sector | 1 Hz o evento | No | Solo estado |

- Máximo de NPC animados y de sombras por sector, medido.
- Fuera de sector se guarda la ubicación lógica; al volver, se coloca en su ancla.
- Los NPC tier C no se guardan.

### 8.3. Rutinas

- Amanecer, mañana, mediodía, tarde, noche.
- Trabajo, comida, descanso, sociabilidad, culto, vigilancia.
- Excepciones por clima, fase histórica, evento y relación.
- El horario se puede interrumpir por una secuencia controlada; al terminar, se reanuda.

## 9. Persistencia

### 9.1. Esquema

```json
{
  "version": 1,
  "campaign": "01_pachacutec",
  "slot": "auto_01",
  "saved_at": "2026-11-19T12:00:00Z",
  "clock": {"day": 3, "minute": 480, "weather": "clear"},
  "phase": "noticia",
  "flags": {"mensajero_ayudado": 1},
  "player": {"position": [0, 0, 0], "inventory": [], "skills": {}},
  "npcs": {"npc_sisa": {"alive": true, "anchor": "plaza", "relation": 2}},
  "quests": {"quest_mensajero": {"stage": 2, "choices": []}},
  "discoveries": ["poi_mirador"],
  "world": {"corral_reparado": 1}
}
```

### 9.2. Reglas

- Versión de esquema y migraciones explícitas.
- Escritura atómica (temporal + rename).
- IDs estables; nunca rutas de nodo.
- Autoguardado al dormir, cambiar de fase y entrar/salir de un sector seguro.
- Guardado manual fuera de combate.
- Prueba de round-trip (`save → load → save`) y de migración.

## 10. Navegación y streaming

### 10.1. Navegación

- `NavigationRegion3D` por sector, horneado en editor.
- `NavigationAgent3D` para tier A; `NavigationObstacle3D` para obstáculos dinámicos.
- Enlaces para puertas, escaleras y desniveles.
- Respaldo: waypoints de ancla + movimiento local si el navmesh falla.

### 10.2. Streaming

- Terrain3D 1.1 no transmite regiones; el terreno de la región se mantiene cargado.
- Se transmiten props, edificios, vegetación y NPC por sector.
- `SectorStreamer` carga en radio de 2 y descarga en radio de 3, con `ResourceLoader.load_threaded_request`.
- Prioridad: sector actual, adyacentes, resto.
- Interiores: carga aditiva al cruzar la puerta.
- Presupuesto: carga < 150 ms, hitch < 50 ms, memoria estable.

## 11. Contenido por datos

| Definición | Campos mínimos |
|---|---|
| `NpcDefinition` | Id, nombre, tier, casa, trabajo, horario, diálogo, facción |
| `QuestDefinition` | Id, título, etapas, objetivos, condiciones, consecuencias, fichas |
| `LocationDefinition` | Id, sector, posición, radio, nombre, descripción, mapa |
| `ItemDefinition` | Id, nombre, descripción, uso, icono, trueque |
| `ScheduleEntry` | Inicio, fin, ancla, actividad, condiciones |
| `EventDefinition` | Id, disparador, secuencia, condiciones, una vez |

Validación obligatoria: todos los IDs referenciados existen; todos los textos tienen clave; todas las fichas históricas están clasificadas.

## 12. UI y localización

- Core UI: HUD, diálogo, diario, mapa, portada, pausa.
- La UI se suscribe a señales; no consulta el mundo en cada fotograma.
- Todos los textos visibles pasan por `tr()`.
- Tablas CSV por ámbito: `core/localization/core_texts.csv` y `campaigns/<campaña>/localization/<campaña>_texts.csv`.
- Prefijo de campaña (`PCH_`) para evitar colisiones.
- Sin literales en código.

## 13. Migración desde la versión lineal

| Elemento | Acción |
|---|---|
| `PlayerFPS`, interacción, diálogo, diario, inventario, combate, audio, gráficos | Conservar y adaptar contratos |
| `CampaignState` | Integrar en `WorldState` manteniendo banderas |
| `CampaignInfo` | Convertir en selector de campañas |
| `act_one_director.gd`, directores de acto | Retirar cuando la secuencia de mundo los sustituya |
| `llacta.gd`, `ciudad.gd`, `paso.gd` | Conservar como referencia/blockout; no como escena final |
| `llacta_act4.tscn`, `llacta_act5.tscn` | Sustituir por fases del mismo territorio |
| Puntos de control | Sustituir por guardado completo |
| Marcadores de misión | Convertir en guía opcional |
| Pruebas de acto | Mantener como legacy hasta sustituirlas; retirar con las escenas |

## 14. Pruebas de arquitectura

- Capas: `test_core_layering` ampliado para datos y mundo.
- Contratos: jugador, interacción, estamina, diálogo, inventario, diario.
- Mundo: carga de sector, streaming, navegación, guardado, NPC, reloj.
- Contenido: IDs, textos, fichas, definiciones.
- Rendimiento: presupuesto por sector.

La estrategia completa vive en [docs/06](06_estrategia_de_pruebas.md).
