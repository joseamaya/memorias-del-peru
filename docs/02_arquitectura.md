# 02 — Arquitectura

## 1. Capas

```text
┌──────────────────────────────────────────┐
│ campaigns/NN_nombre/                     │  Contenido de una época
│   escenas, personajes, misiones, scripts │
└───────────────┬──────────────────────────┘
                │ depende de
┌───────────────▼──────────────────────────┐
│ core/                                    │  Sistemas compartidos
│   autoload, player, interaction, systems │
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
3. `shared_assets/` no contiene scripts con lógica de juego (solo shaders, materiales, temas de UI y recursos).
4. La comunicación de abajo hacia arriba (Core → contenido/UI) se hace **por señales**, nunca por rutas rígidas de nodos (`get_node("/root/...")`).
5. Las dependencias entre sistemas Core se inyectan (`@export`, parámetros, señales) o se acceden vía autoload documentado. Sin dependencias circulares.
6. Una campaña nueva no requiere modificar el jugador, el guardado, la interacción ni el audio. Si lo requiere, se abre un ADR.

## 2. Estructura del repositorio

Estructura oficial (de la [especificación](00_especificacion.md) §3) más dos adiciones justificadas en ADR-0001: `docs/` y `tests/`.

```text
memorias-del-peru/
├── project.godot
├── README.md
├── AGENTS.md
├── docs/                       ← adición (ADR-0001)
├── tests/                      ← adición (ADR-0001)
├── core/
│   ├── autoload/               game_manager.gd, audio_manager.gd, save_manager.gd
│   ├── player/                 player_fps.tscn, player_fps.gd
│   ├── interaction/            interactable.gd
│   ├── ui/                     indicación de interacción, HUD mínimo
│   ├── localization/           core_texts.csv (§7)
│   └── systems/                stamina/, graphics/, inventory/, dialogue/, journal/, combat/, checkpoint/
├── shared_assets/              materials/, shaders/, fonts/, textures/, audio/, ui/
└── campaigns/
    └── 01_pachacutec/
        ├── scenes/             world/, characters/, objects/, missions/
        ├── scripts/            interactions/, world/
        ├── assets/             models/, textures/, audio/, animations/
        ├── localization/       pachacutec_texts.csv (§7)
        └── documentation/
```

Los directorios se crean **solo** cuando reciben su primer archivo funcional.

## 3. Autoloads

| Autoload | Responsabilidad | Estado |
|---|---|---|
| `GameManager` | Estado global de juego (en juego / pausado): `set_paused(paused: bool)`, `is_paused() -> bool`, señal `pause_changed(paused: bool)`. (El parámetro se llama `paused` y no `is_paused` para no ensombrecer el método `is_paused()`, lo que dispararía `SHADOWED_VARIABLE`.) No gestiona escenas de campaña concretas. Gobierna también el cierre: desactiva `auto_accept_quit` y, ante `NOTIFICATION_WM_CLOSE_REQUEST`, `request_quit(exit_code: int = 0)` detiene todos los reproductores de audio (`stop_audio_in(root: Node) -> int`), espera 100 ms de tiempo real y sale. En 4.7.2, salir con un Ogg sonando deja la reproducción sin liberar y el motor imprime un error. | Implementado |
| `AudioManager` | Buses, reproducción de efectos y ambiente, volumen | Implementado |
| `GraphicsSettings` | Perfil gráfico activo, aplicación de ajustes de `Viewport`/`RenderingServer`, señal `profile_changed` | Implementado (docs/08 §2) |
| `CampaignState` | Banderas de campaña entre escenas (`set_flag`, `get_flag`, `has_flag`, `clear`); sin escritura en disco | Implementado |
| `SaveManager` | Serialización del estado | Cuando exista estado que guardar |

Un autoload solo se registra cuando tiene una responsabilidad real en la fase activa.

## 4. Jugador en primera persona

Archivos: `core/player/player_fps.gd`, `core/player/player_fps.tscn`. Clase: `class_name PlayerFPS extends CharacterBody3D`.

```text
PlayerFPS (CharacterBody3D)
├── CollisionShape3D            CapsuleShape3D
└── Head (Node3D)               rotación vertical (pitch); altura de ojos
    └── Camera3D                desplazamiento de head bobbing (posición local)
        └── InteractionRay (RayCast3D)
```

Esta es la jerarquía del jugador. `StaminaComponent` cuelga como hijo directo de `PlayerFPS` (ver §5).

### Reparto de responsabilidades por nodo

| Nodo | Transformación que controla | Quién la escribe |
|---|---|---|
| `PlayerFPS` | Posición física y rotación horizontal (yaw) | Física (`move_and_slide`) y ratón (eje X) |
| `Head` | Rotación vertical (pitch), limitada a ±80° | Ratón (eje Y) |
| `Camera3D` | Desplazamiento local de balanceo | Head bobbing, calculado cada tick de física |

Así la rotación vertical nunca altera la orientación física y el balanceo nunca toca el origen físico.

El origen de `PlayerFPS` está a los pies: la cápsula se centra a 0.875 m y `Head` queda a 1.60 m sobre el suelo.

### Composición en escena (quién instancia al jugador)

`player_fps.tscn` no instancia nada por sí mismo; lo instancia la escena que lo usa:

| Fase | Escena | Composición |
|---|---|---|
| 1 | `tests/scenes/player_sandbox.tscn` | Instancia de `PlayerFPS` colocada directamente en la escena |
| 2 | La misma escena sandbox | Añade el HUD (`core/ui/`) y le asigna por `@export` el `StaminaComponent` del jugador |
| 3+ | Escena de mundo de la campaña | Instancia `PlayerFPS` y el HUD; el script del mundo coloca al jugador en la transformación de `PlayerSpawn` en `_ready()` |

Un sistema genérico de aparición o cambio de escena en Core solo se crea cuando exista más de una escena de mundo.

### Parámetros exportados (sin valores mágicos)

Todos como `@export` con tipo y agrupados (`@export_group`): `walk_speed`, `run_speed`, `acceleration`, `deceleration`, `mouse_sensitivity`, `pitch_limit_degrees` (80), `gravity` (por defecto, el valor de `ProjectSettings` `physics/3d/default_gravity`), `bob_walk_frequency`, `bob_walk_amplitude`, `bob_run_frequency`, `bob_run_amplitude`, `bob_blend_speed`, `bob_min_speed` (velocidad horizontal por debajo de la cual se considera que el jugador está quieto). Valores iniciales propuestos en [05_plan_de_implementacion.md](05_plan_de_implementacion.md). Los `@export` de estamina se describen en §5.

### Movimiento

1. Leer entrada con `Input.get_vector("move_left", "move_right", "move_forward", "move_backward")`.
2. Convertir a dirección mundial con la base horizontal del `PlayerFPS` (`transform.basis`), normalizada.
3. Velocidad objetivo = `run_speed` si `run` está presionado y hay entrada, si no `walk_speed`.
4. Interpolar la velocidad horizontal hacia el objetivo con `move_toward` usando `acceleration` (con entrada) o `deceleration` (sin entrada), multiplicado por `delta`.
5. Aplicar gravedad a `velocity.y` si `not is_on_floor()`.
6. `move_and_slide()`.

### Cámara y ratón

- Rotación en `_unhandled_input` con `InputEventMouseMotion.relative` (solo si el ratón está capturado).
- Yaw → `rotate_y` del cuerpo. Pitch → `Head.rotation.x`, con `clampf` a `±deg_to_rad(pitch_limit_degrees)`.
- Captura solo con la ventana enfocada y en juego (`static func should_capture_mouse(paused: bool, window_focused: bool) -> bool`): al recibir el foco (`NOTIFICATION_WM_WINDOW_FOCUS_IN` / `NOTIFICATION_APPLICATION_FOCUS_IN`), con un clic si el ratón está libre, al salir de la pausa y, como respaldo, 0,3 s después de `_ready()`. No se captura dentro de `_ready()`: la ventana puede no ser visible aún y X11 responde «NO GRAB».
- El jugador **no** decide la pausa: escucha `GameManager.pause_changed` y libera o recaptura el ratón. `GameManager` procesa la acción `pause` (con `process_mode = PROCESS_MODE_ALWAYS` para seguir recibiendo entrada en pausa) y aplica `get_tree().paused`.
- **Reanudar:** no hay menú de pausa; la acción `pause` (Escape) **alterna** entre pausado y en juego. Cuando exista un menú de pausa, su botón “Continuar” llamará a `GameManager.set_paused(false)`.
- La elección del modo de ratón según el estado de pausa se aísla en un método puro estático (`static func mouse_mode_for_pause(paused: bool) -> Input.MouseMode`) para poder probarla sin pantalla.

### Head bobbing (diseño matemático)

Ejecutado en `_physics_process(delta)`:

```text
horizontal_speed = longitud de (velocity.x, velocity.z)
moving           = is_on_floor() y horizontal_speed > bob_min_speed
target_weight    = 1 si moving, si no 0
bob_weight       = move_toward(bob_weight, target_weight, bob_blend_speed * delta)
frequency, amplitude = valores de carrera o caminata (interpolados según velocidad)
si moving: bob_phase += delta * frequency * TAU   (fase envuelta con fposmod)
offset.y = sin(bob_phase) * amplitude * bob_weight
offset.x = cos(bob_phase * 0.5) * amplitude * 0.5 * bob_weight
camera.position = camera_base_position + offset
```

Garantías:

- **Sin acumulación:** la posición se **recalcula** desde `camera_base_position` en cada tick; nunca se suma al valor anterior.
- **Sin saltos:** al detenerse, `bob_weight` decae suavemente hacia 0; la fase no se reinicia bruscamente.
- **Origen físico intacto:** solo se modifica la posición local de `Camera3D`.

Riesgo a verificar: a frecuencias de refresco mayores que la tasa de física (60 Hz) el balanceo calculado en física puede verse escalonado. Mitigación a evaluar con medición: interpolación de física de Godot (`physics/common/physics_interpolation`, disponible en 3D desde Godot 4.4) o interpolar el desplazamiento en `_process`. Se decide tras probar; si se cambia, se documenta en la bitácora.

## 5. Sistema de interacción

Diseño del sistema de pasos.

- `class_name Interactable extends Node` con `interact(interactor: Node3D) -> void` y `get_interaction_text() -> String`.
- El script de un objeto interactuable (p. ej. `quero_chicha.gd`) hereda de `Interactable` y se asigna a la **raíz** de la escena del objeto.
- En cada tick de física el jugador lee el collider de `InteractionRay`. Solo si el collider **cambió** respecto al tick anterior, recalcula el interactuable subiendo por los ancestros hasta encontrar un nodo `is Interactable` (o llegar al límite definido en ADR-0003); si no cambió, reutiliza el resultado cacheado.
- El jugador emite señales (`interactable_focused(interactable: Interactable)`, `interactable_unfocused()`); la UI de indicaciones se suscribe. El jugador no conoce la UI ni tipos concretos de objetos.
- Al presionar `interact`, el jugador llama `interact(self)` sobre el interactuable enfocado.

### Pasos

- Un paso por ciclo de balanceo vertical, al mismo ritmo (`bob_frequency_for(horizontal_speed)`) y en el punto más bajo de la cámara (`FOOTSTEP_CYCLE_POINT = 0.75` del ciclo, mínimo de `sin`). `advance_footstep(horizontal_speed, grounded, delta) -> bool` avanza el ciclo solo con las mismas condiciones que el balanceo, así que ambos quedan sincronizados.
- En cada paso se emite `footstep_taken` y, si `footstep_streams` no está vacío, se reproduce la siguiente variante con `AudioManager.play_sfx(stream, footstep_volume_db)`.
- `PlayerFPS` no conoce los sonidos: la escena del mundo asigna `footstep_streams` (por defecto; en la campaña 01, tierra) y `footstep_sets: Array[FootstepSet]` (`core/player/footstep_set.gd`: `surface: StringName`, `streams: Array[AudioStream]`).
- **Superficie:** en cada paso, un rayo corto bajo los pies busca el suelo; si el cuerpo tiene el metadato `footstep_surface` (`PlayerFPS.FOOTSTEP_SURFACE_META`), se usa el conjunto con esa superficie, y si no, los de por defecto. Core no define superficies; la campaña 01 marca como `&"stone"` los muros y rampas de las terrazas.

### Estamina

Contrato cerrado. El bloque siguiente es **documentación de firmas**, no un archivo de código: muestra la interfaz pública de la implementación completa.

```gdscript
## core/systems/stamina/stamina_component.gd
class_name StaminaComponent
extends Node

signal stamina_changed(current: float, maximum: float)

@export var max_stamina: float = 100.0
@export var regeneration_per_second: float = 8.0
@export var regeneration_delay_seconds: float = 1.5

func get_current() -> float
func get_maximum() -> float
func has_stamina() -> bool                    # current > 0
func consume(amount: float) -> float          # devuelve lo realmente consumido
func restore(amount: float) -> float          # devuelve lo realmente recuperado
static func find_in(owner_node: Node) -> StaminaComponent   # busca entre los hijos directos; null si no hay
```

Reglas:

- Es un nodo hijo de quien tenga estamina (el jugador; en el futuro, NPC). Emite `stamina_changed` solo cuando el valor cambia.
- **Jugador:** el componente no sabe nada de correr; las reglas de carrera viven en `PlayerFPS`, que añade estos `@export`:
  - `stamina: StaminaComponent` (opcional). Si es `null`, correr no tiene límite (útil en escenas de prueba).
  - `run_stamina_cost_per_second: float = 15.0`: consumo mientras corre.
  - `run_resume_stamina: float = 25.0`: al agotarse la estamina, el jugador no vuelve a correr hasta que el valor actual alcance este umbral.
- **Quero:** no conoce `PlayerFPS` ni la UI. En `interact(interactor)` llama `StaminaComponent.find_in(interactor)`; si devuelve un componente, llama `restore(restore_amount)` con su cantidad `@export`. Si no hay componente, la interacción visual y sonora ocurre igual.
- **Subtítulos y rótulo (ADR-0006, ADR-0012):** `show_subtitle(text, seconds)` muestra un subtítulo durante al menos `PlayerHud.reading_seconds(text, seconds)`: lo pedido, 4 s como mínimo y el tiempo de lectura (largo ÷ 13 caracteres por segundo + 1,5 s). Si ya hay uno a la vista, el nuevo espera en una cola de hasta 4. `advance_subtitle(delta)`, `is_showing_subtitle()`, `queued_subtitles()` y `clear_subtitle()` permiten probarlo sin fotogramas. `show_title(text, seconds)` muestra un rótulo arriba con fundidos (`advance_title(delta)`).
- **Tarjeta de fin (ADR-0013):** `show_end_card(title, hint)` muestra un fundido a negro con título y cómo seguir (`advance_end_card(delta)`, `is_end_card_visible()`). La escena del mundo decide cuándo y gestiona las teclas: R recarga la escena y Esc sale.
- **Pausa y aliento:** el HUD escucha `GameManager.pause_changed` y muestra «Pausa · Esc para continuar» sobre la imagen oscurecida (`show_pause(paused)`; funciona con el árbol en pausa). La barra de estamina lleva la etiqueta «Aliento» y colores de alto contraste.
- **Resalte del enfoque:** `core/interaction/interaction_highlight.gd` (`class_name InteractionHighlight`), hijo de `PlayerFPS`, añade un brillo aditivo tenue (`material_overlay`) a las mallas del interactuable enfocado. Si el interactuable no tiene mallas propias, como el cuerpo de «Hablar», usa las de su padre. Al perder el foco restaura la superposición anterior.
- **Disponibilidad (ADR-0008):** un interactuable que no respondería no se ofrece. La ofrenda deja de estar disponible una vez usada, y el quero, durante su espera entre usos.
- **UI:** el HUD recibe el `StaminaComponent` por `@export` (o se lo asigna la escena que compone jugador y HUD) y escucha `stamina_changed`. No hay rutas rígidas entre UI y jugador.
- Los valores por defecto del bloque son propuestas iniciales, ajustables sin cambiar el contrato.

### Modelos definitivos con respaldo al bloqueo

- `core/systems/assets/model_slot.gd` (`class_name ModelSlot extends Node3D`): al entrar en el árbol carga como hijo `Model` el primer archivo existente de `model_paths: Array[String]` y oculta `blockout_nodes: Array[Node3D]`. Si el hueco cuelga de uno de esos nodos (para heredar sus animaciones), a ese nodo se le quita la malla en lugar de ocultarlo. Si no existe ningún archivo, no hace nada.
- `blockout_collisions: Array[Node]` se eliminan solo si el modelo trae colisión propia y `use_model_collision` es `true`. Señal `model_loaded(model: Node3D)`.
- Color por vértice: `static enable_vertex_colors(mesh: Mesh) -> int` activa `vertex_color_use_as_albedo` en cada superficie con color por vértice (y le crea un `StandardMaterial3D` si no tiene material). Hace falta porque el importador glTF de Godot ignora ese color en los modelos exportados sin material. `load_model()` lo aplica al modelo con `enable_vertex_colors_in(root)`, y la vegetación de la campaña lo aplica a las mallas que repite con `MultiMesh`.
- `ModelSlot` no conoce campañas: la escena del mundo decide qué archivo corresponde a cada bloqueo (la campaña define su tabla de modelos).
- Las reglas de los `.glb` (nombre, metros, origen en la base, escalas aplicadas, colisión) se comprueban en `tests/asset_validation.gd`, que usa `test_model_validator`.

## 6. Sistemas RPG

La campaña 01 se juega como un RPG en primera persona.
Estos módulos viven en `core/` y no conocen la campaña; la campaña los compone.

| Sistema | Ubicación | Contrato público |
|---|---|---|
| Estado | `core/systems/rpg/character_state.gd` | Salud, ánimo, habilidades (0–5 por uso) y reputación por grupo; señales `health_changed`, `morale_changed`, `skill_changed`, `reputation_changed`; `damage`, `heal`, `register_skill_use`, `change_reputation` |
| Inventario | `core/systems/inventory/inventory.gd` y `item_definition.gd` | Ocho huecos y tres equipados; `add`, `remove`, `count`, `has`, `use`; señal `changed`. Sin peso ni loot aleatorio |
| Diálogo | `core/systems/dialogue/dialogue_runner.gd` | Nodos con texto, opciones, condiciones y efectos; no conoce la UI: emite `line_shown` y `choices_shown`, recibe la opción elegida |
| Diario | `core/systems/journal/journal.gd` | Encargos y «Memoria»; añade entradas con clave de texto, sello H/A/R/N y fuente; señal `changed` |
| Combate | `core/systems/combat/` | `CombatLoadout` con honda, porra y escudo; honda con carga y munición de piedras, porra corta y escudo con bloqueo; enemigos con moral; la UI lee viñeta y munición |
| Puntos de control | `campaigns/<campaña>/scripts/systems/campaign_progress.gd` sobre `CampaignState` | Estado en memoria al empezar cada acto y a mitad del II, III y IV; salud, aliento, ánimo, inventario, oficio, diario, munición y posición; sin guardado completo |

Reglas:

- El estado del jugador es un nodo hijo; la UI se suscribe a señales y no consulta
  el estado en cada fotograma.
- Los objetos son recursos (`ItemDefinition`) con clave de nombre y descripción;
  ningún texto literal en código.
- El diario no muestra marcadores en el mundo: es la única superficie de lectura.
- La UI de Core (`core/ui/dialogue_panel`, `core/ui/journal_panel`) se suscribe a
  las señales; la campaña no escribe texto en el código.
- El combate no expone barras: salud por viñeta y respiración, ánimo por sonido,
  munición por la mano. Las pruebas pueden leer los valores internos.
- El guardado completo sigue fuera de alcance; `core/autoload/save_manager.gd`
  se pospone.

## 7. Textos para el jugador

Todos los textos visibles se obtienen con `tr("CLAVE")` mediante el sistema de traducción de Godot (`TranslationServer`).

| Ámbito | Tabla | Ejemplo de clave |
|---|---|---|
| Core | `core/localization/core_texts.csv` | `INTERACT_DEFAULT` = “Interactuar” |
| Campaña 01 | `campaigns/01_pachacutec/localization/pachacutec_texts.csv` | `PCH_QUERO_INTERACT` = “Beber chicha” |

- Formato CSV de traducciones de Godot: primera columna `keys`, una columna por idioma (inicialmente solo `es`).
- Prefijo de clave por campaña (`PCH_`) para evitar colisiones entre campañas.
- `Interactable.get_interaction_text()` devuelve `tr("INTERACT_DEFAULT")` en la clase base, que equivale al “Interactuar” de la especificación; las clases derivadas devuelven su propia clave traducida.
