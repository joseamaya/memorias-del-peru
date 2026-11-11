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

Estructura oficial (de la [especificación](00_especificacion.md) §3) más dos adiciones justificadas en [ADR-0001](adr/0001-estructura-de-repositorio.md): `docs/` y `tests/`.

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
│   ├── ui/                     indicación de interacción, HUD mínimo (Fase 2)
│   ├── localization/           core_texts.csv (Fase 2, §7)
│   └── systems/                stamina/, graphics/ (Fase 3), inventory/, dialogue/, quest/
├── shared_assets/              materials/, shaders/, fonts/, textures/, audio/, ui/
└── campaigns/
    └── 01_pachacutec/
        ├── scenes/             world/, characters/, objects/, missions/
        ├── scripts/            missions/, interactions/, characters/, world/ (Fase 3)
        ├── assets/             models/, textures/, audio/, animations/
        ├── localization/       pachacutec_texts.csv (Fase 2, §7)
        └── documentation/
```

Los directorios se crean **solo** cuando reciben su primer archivo funcional.

## 3. Autoloads

| Autoload | Responsabilidad | Fase en que nace |
|---|---|---|
| `GameManager` | Estado global de juego (en juego / pausado): `set_paused(paused: bool)`, `is_paused() -> bool`, señal `pause_changed(paused: bool)`. (El parámetro se llama `paused` y no `is_paused` para no ensombrecer el método `is_paused()`, lo que dispararía `SHADOWED_VARIABLE`.) No gestiona escenas de campaña concretas. Gobierna también el cierre: desactiva `auto_accept_quit` y, ante `NOTIFICATION_WM_CLOSE_REQUEST`, `request_quit(exit_code: int = 0)` detiene todos los reproductores de audio (`stop_audio_in(root: Node) -> int`), espera 100 ms de tiempo real y sale. En 4.7.2, salir con un Ogg sonando deja la reproducción sin liberar y el motor imprime un error. | Fase 1 (versión mínima: solo pausa); cierre ordenado en Fase 4 |
| `AudioManager` | Buses, reproducción de efectos y ambiente, volumen | Fase 2 (primer sonido: quero) |
| `GraphicsSettings` | Perfil gráfico activo, aplicación de ajustes de `Viewport`/`RenderingServer`, señal `profile_changed` | Fase 3 (ver §6 y docs/08 §2) |
| `SaveManager` | Serialización del estado | Cuando exista estado que guardar (posterior a Fase 3) |

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

Esta es la jerarquía de la Fase 1. En la Fase 2 se añade `StaminaComponent` como hijo directo de `PlayerFPS` (ver §5); no se prevén otros cambios antes del vertical slice.

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
| 3+ | `mundo_base.tscn` | Contiene instancias de `PlayerFPS` y del HUD; el script del mundo (`campaigns/01_pachacutec/scripts/world/mundo_base.gd`) coloca al jugador en la transformación de `PlayerSpawn` en `_ready()` |

Un sistema genérico de aparición o cambio de escena en Core solo se crea cuando exista más de una escena de mundo.

### Parámetros exportados (sin valores mágicos)

Todos como `@export` con tipo y agrupados (`@export_group`): `walk_speed`, `run_speed`, `acceleration`, `deceleration`, `mouse_sensitivity`, `pitch_limit_degrees` (80), `gravity` (por defecto, el valor de `ProjectSettings` `physics/3d/default_gravity`), `bob_walk_frequency`, `bob_walk_amplitude`, `bob_run_frequency`, `bob_run_amplitude`, `bob_blend_speed`, `bob_min_speed` (velocidad horizontal por debajo de la cual se considera que el jugador está quieto). Valores iniciales propuestos en [05_plan_de_implementacion.md](05_plan_de_implementacion.md). En la Fase 2 se añaden los `@export` de estamina descritos en §5.

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
- **Reanudar:** en la Fase 1 no hay menú de pausa; la acción `pause` (Escape) **alterna** entre pausado y en juego. Cuando exista un menú de pausa, su botón “Continuar” llamará a `GameManager.set_paused(false)`.
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

Riesgo a verificar: a frecuencias de refresco mayores que la tasa de física (60 Hz) el balanceo calculado en física puede verse escalonado. Mitigación a evaluar con medición: interpolación de física de Godot (`physics/common/physics_interpolation`, disponible en 3D desde Godot 4.4) o interpolar el desplazamiento en `_process`. Se decide en Fase 1 tras probar; si se cambia, se documenta en un ADR.

## 5. Sistema de interacción

Diseño propuesto en [ADR-0003](adr/0003-deteccion-de-interactuables.md) (se acepta formalmente al iniciar la Fase 2).

- `class_name Interactable extends Node` con `interact(interactor: Node3D) -> void` y `get_interaction_text() -> String`.
- El script de un objeto interactuable (p. ej. `quero_chicha.gd`) hereda de `Interactable` y se asigna a la **raíz** de la escena del objeto.
- En cada tick de física el jugador lee el collider de `InteractionRay`. Solo si el collider **cambió** respecto al tick anterior, recalcula el interactuable subiendo por los ancestros hasta encontrar un nodo `is Interactable` (o llegar al límite definido en ADR-0003); si no cambió, reutiliza el resultado cacheado.
- El jugador emite señales (`interactable_focused(interactable: Interactable)`, `interactable_unfocused()`); la UI de indicaciones se suscribe. El jugador no conoce la UI ni tipos concretos de objetos.
- Al presionar `interact`, el jugador llama `interact(self)` sobre el interactuable enfocado.

### Pasos (Fase 4)

- Un paso por ciclo de balanceo vertical, al mismo ritmo (`bob_frequency_for(horizontal_speed)`) y en el punto más bajo de la cámara (`FOOTSTEP_CYCLE_POINT = 0.75` del ciclo, mínimo de `sin`). `advance_footstep(horizontal_speed, grounded, delta) -> bool` avanza el ciclo solo con las mismas condiciones que el balanceo, así que ambos quedan sincronizados.
- En cada paso se emite `footstep_taken` y, si `footstep_streams` no está vacío, se reproduce la siguiente variante con `AudioManager.play_sfx(stream, footstep_volume_db)`.
- `PlayerFPS` no conoce los sonidos: la escena del mundo asigna `footstep_streams` (por defecto; en la campaña 01, tierra) y `footstep_sets: Array[FootstepSet]` (`core/player/footstep_set.gd`: `surface: StringName`, `streams: Array[AudioStream]`).
- **Superficie:** en cada paso, un rayo corto bajo los pies busca el suelo; si el cuerpo tiene el metadato `footstep_surface` (`PlayerFPS.FOOTSTEP_SURFACE_META`), se usa el conjunto con esa superficie, y si no, los de por defecto. Core no define superficies; la campaña 01 marca como `&"stone"` los muros y rampas de las terrazas.

### Estamina (Fase 2)

Contrato cerrado (se implementa en Fase 2). El bloque siguiente es **documentación de firmas**, no un archivo de código: muestra la interfaz pública que deberá tener la implementación completa de la Fase 2.

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
- **Jugador:** el componente no sabe nada de correr; las reglas de carrera viven en `PlayerFPS`, que añade en la Fase 2 estos `@export`:
  - `stamina: StaminaComponent` (opcional). Si es `null`, correr no tiene límite (útil en escenas de prueba).
  - `run_stamina_cost_per_second: float = 15.0`: consumo mientras corre.
  - `run_resume_stamina: float = 25.0`: al agotarse la estamina, el jugador no vuelve a correr hasta que el valor actual alcance este umbral.
- **Quero:** no conoce `PlayerFPS` ni la UI. En `interact(interactor)` llama `StaminaComponent.find_in(interactor)`; si devuelve un componente, llama `restore(restore_amount)` con su cantidad `@export`. Si no hay componente, la interacción visual y sonora ocurre igual.
- **UI:** el HUD recibe el `StaminaComponent` por `@export` (o se lo asigna la escena que compone jugador y HUD) y escucha `stamina_changed`. No hay rutas rígidas entre UI y jugador.
- Los valores por defecto del bloque son propuestas iniciales, ajustables durante la Fase 2 sin cambiar el contrato.

## 6. Puntos de extensión previstos (no implementar sin fase asignada)

| Sistema | Ubicación | Relación prevista |
|---|---|---|
| Inventario | `core/systems/inventory/` | Interactuables de tipo “recoger” |
| Diálogo | `core/systems/dialogue/` | Interactuables de tipo “hablar” |
| Misiones | `core/systems/quest/` | Escuchan señales de interacción y eventos |
| Guardado | `core/autoload/save_manager.gd` | Cada sistema expone su propio estado serializable |
| Opciones gráficas | `core/systems/graphics/` (Fase 3) | Perfiles aplicados en ejecución a `Environment`, luces, `Viewport` y `RenderingServer`. **No** a `ProjectSettings`, que solo aporta valores de arranque. Detalle en [08_entorno_y_rendimiento.md](08_entorno_y_rendimiento.md) §2 |
| Códice histórico | Por definir (posterior al vertical slice) | Consulta del registro histórico desde el juego; ver docs/01 §6 |

## 7. Textos para el jugador

Todos los textos visibles se obtienen con `tr("CLAVE")` mediante el sistema de traducción de Godot (`TranslationServer`). Nacen en la Fase 2 con el primer texto (la indicación de interacción).

| Ámbito | Tabla | Ejemplo de clave |
|---|---|---|
| Core | `core/localization/core_texts.csv` | `INTERACT_DEFAULT` = “Interactuar” |
| Campaña 01 | `campaigns/01_pachacutec/localization/pachacutec_texts.csv` | `PCH_QUERO_INTERACT` = “Beber chicha” |

- Formato CSV de traducciones de Godot: primera columna `keys`, una columna por idioma (inicialmente solo `es`).
- Prefijo de clave por campaña (`PCH_`) para evitar colisiones entre campañas.
- `Interactable.get_interaction_text()` devuelve `tr("INTERACT_DEFAULT")` en la clase base, que equivale al “Interactuar” de la especificación; las clases derivadas devuelven su propia clave traducida.
