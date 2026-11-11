# 06 — Estrategia de pruebas

Principio: **una funcionalidad está terminada cuando se comprobó**, no cuando se escribió.

## 1. Niveles de validación

| Nivel | Qué detecta | Cuándo |
|---|---|---|
| 1. Importación / análisis | Errores de sintaxis, tipado, advertencias como errores, recursos rotos | Tras cada cambio |
| 2. Pruebas automatizadas headless | Contratos (Input Map, jerarquía de escenas, lógica pura) | Tras cada cambio de código |
| 3. Carga de escenas | Escenas que no instancian o producen errores al entrar al árbol | Tras cambios en escenas |
| 4. Verificación manual en ejecución | Sensación de control, visuales, audio | Al cerrar cada tarea con impacto jugable |

## 2. Comandos

> Comandos verificados con Godot 4.7.2 el 2026-11-10. `--check-only` no carga los autoloads; para scripts que los usan, validar con `--import` o con el ejecutor de pruebas.

Importar el proyecto y detectar errores de recursos/scripts (sale al terminar):

```bash
godot --headless --path . --import
```

Validar un script concreto sin ejecutarlo:

```bash
godot --headless --path . --check-only --script res://core/player/player_fps.gd
```

> `--check-only` compila el script sin cargar los autoloads. Si el script referencia uno (por ejemplo, `PlayerFPS` usa `GameManager`), falla con "Identifier not found". En ese caso se valida con `--import` o con el ejecutor de pruebas, que sí cargan el proyecto.

Ejecutar las pruebas automatizadas:

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

Criterio: el código de salida es `0` **y** la salida no contiene líneas `ERROR`, `SCRIPT ERROR` ni `WARNING` provenientes de `res://`. Como ninguna categoría de advertencia está en nivel 1 (docs/04 §5), cualquier problema de GDScript aparece como error.

## 3. Pruebas automatizadas

Sin dependencias externas en la Fase 1: un ejecutor propio mínimo en `tests/run_tests.gd` (`extends SceneTree`) que carga cada archivo `tests/test_*.gd`, ejecuta sus métodos `test_*` y termina con `quit(codigo)` (0 = éxito, 1 = fallo). La adopción de un framework (GUT, gdUnit4) requiere un ADR cuando el volumen de pruebas lo justifique.

**Riesgo a comprobar en la Fase 1:** que los autoloads (`GameManager`) estén disponibles al ejecutar con `--script`. Los scripts que usan el autoload (p. ej. `player_fps.gd`) deben compilar en ese modo. Si no lo están, el ejecutor pasa a ser una escena (`tests/run_tests.tscn` con un nodo raíz que ejecuta las pruebas), lanzada con `godot --headless --path . res://tests/run_tests.tscn`, y se actualiza §2. Las pruebas de lógica crean sus propias instancias en lugar de depender del autoload global.

**Política:** cada fase enumera aquí sus pruebas automatizadas como primera tarea al abrirse, antes de escribir código. “Pruebas en verde” significa: todas las de esta sección (de la fase actual y de las anteriores) pasan.

### Pruebas de Fase 1

| Prueba | Comprueba |
|---|---|
| `test_input_map` | Las 8 acciones existen y tienen al menos un evento |
| `test_player_scene_structure` | `player_fps.tscn` instancia; raíz `CharacterBody3D` con script `PlayerFPS`; existen `CollisionShape3D`, `Head`, `Head/Camera3D`, `Head/Camera3D/InteractionRay` con sus tipos |
| `test_pitch_clamp` | Aplicar un desplazamiento vertical grande deja el pitch en ±80° |
| `test_head_bob_no_drift` | Tras N ticks simulados de movimiento y M de reposo, la cámara vuelve a la posición base (tolerancia 1e-3) |
| `test_head_bob_max_step` | El desplazamiento del balanceo no cambia más de 0,02 m por tick en caminata y carrera |
| `test_player_eye_height` | El origen del jugador está a los pies: ojos a 1,60 m y fondo de la cápsula a 0,00 m |
| `test_gravity_default` | `gravity` coincide con `physics/3d/default_gravity` |
| `test_pause` | Sobre una instancia de `game_manager.gd` creada por la prueba: `set_paused(true)` emite `pause_changed(true)` y deja `get_tree().paused == true`; `set_paused(false)` revierte ambos; llamar dos veces con el mismo valor no emite la señal de nuevo |
| `test_mouse_mode_for_pause` | `PlayerFPS.mouse_mode_for_pause(true)` devuelve `MOUSE_MODE_VISIBLE` y `(false)` devuelve `MOUSE_MODE_CAPTURED` |
| `test_player_collision_layers` | `PlayerFPS` usa la capa `player` y la máscara `world` + `npc` (docs/04 §7) |
| `test_sandbox_loads` | La escena sandbox instancia y entra al árbol sin errores |

La aplicación efectiva del modo de ratón (`Input.mouse_mode`) depende del servidor de pantalla y no puede comprobarse en modo headless: se cubre con la lógica pura de arriba y con la verificación manual (punto 8 de §4).

Para que la lógica sea comprobable sin entrada real, los cálculos (dirección de movimiento, clamp de pitch, desplazamiento de balanceo) se aíslan en métodos puros con parámetros, invocados desde los callbacks del motor.

### Pruebas de Fase 2

| Prueba | Comprueba |
|---|---|
| `test_interactable_contract` | `Interactable` expone `interact()` y `get_interaction_text()`; el texto base sale de `tr("INTERACT_DEFAULT")` |
| `test_interaction_focus` | El rayo detecta un collider hijo de un `Interactable`, emite `interactable_focused` y, al salir, `interactable_unfocused` |
| `test_interaction_blocked_by_world` | Una pared en la capa `world` impide enfocar un interactuable detrás |
| `test_interaction_calls_interact` | La acción `interact` llama `interact(self)` sobre el interactuable enfocado |
| `test_stamina_contract` | `consume`/`restore` respetan los límites y emiten `stamina_changed` solo cuando el valor cambia |
| `test_stamina_find_in` | `StaminaComponent.find_in` encuentra el componente entre los hijos directos y devuelve `null` si no existe |
| `test_run_uses_stamina` | Correr consume; sin estamina no se corre hasta alcanzar `run_resume_stamina`; sin componente, correr es ilimitado |
| `test_quero_restores_stamina` | El quero restaura la cantidad exportada vía `StaminaComponent.find_in`, sin rutas a UI |
| `test_ui_stamina_signal` | El HUD actualiza su estado al recibir `stamina_changed` |
| `test_localization_tables` | Las claves usadas por Core y campaña existen en sus CSV y hay una columna `es` |
| `test_quero_scene_loads` | `quero_chicha.tscn` instancia y su raíz es `Interactable` |
| `test_sandbox_interaction_hud` | El sandbox, con el jugador mirando al quero, muestra “Beber chicha” en el HUD |

### Pruebas de Fase 3

| Prueba | Comprueba |
|---|---|
| `test_main_scene_is_world` | `application/run/main_scene` apunta a `mundo_base.tscn` |
| `test_world_scene_loads` | `mundo_base` contiene `WorldEnvironment`, `Inti`, `Terrain` con malla y colisión, `PlayerSpawn`, `EnvironmentAudio`, `PlayerFPS` y HUD |
| `test_sky_material` | El `Environment` usa `PhysicalSkyMaterial` |
| `test_graphics_profiles_load` | Los cuatro perfiles cargan; Bajo/Medio sin niebla volumétrica, Alto/Ultra con ella, y el atlas de sombras crece con el perfil |
| `test_graphics_settings_apply` | `set_profile` emite `profile_changed`, aplica escala, MSAA y antialiasing al Viewport, y deja constancia del atlas de sombras y de sus 16 bits |
| `test_shadow_atlas_per_profile` | Los cuatro perfiles fijan su tamaño de atlas y todos usan 16 bits |
| `test_environment_quality_controller` | El controlador aplica niebla, SSAO, SDFGI y distancia de sombras al cambiar de perfil |
| `test_player_spawn` | El jugador aparece en la transformación de `PlayerSpawn` |
| `test_terrain_normals_up` | Las normales del terreno apuntan hacia +Y |
| `test_terrain_collision_shape` | El terreno tiene una forma de colisión `ConcavePolygonShape3D` |

### Pruebas de Fase 4

| Prueba | Comprueba |
|---|---|
| `test_llacta_layout` | Existen plaza, entre 6 y 8 viviendas, terrazas y al menos dos caminos |
| `test_world_bounds` | El límite del mundo tiene colisión a ~70 m del centro |
| `test_llacta_interactables` | Quero, ofrenda y pututu existen, son `Interactable` y de tipos distintos |
| `test_npcs_present` | Tejedora y agricultor existen con presencia |
| `test_messenger_event_starts_on_arrival` | El evento arranca al entrar en la plaza, no con el pututu |
| `test_messenger_event_finishes_without_pututu` | La máquina llega a `DONE` aunque el jugador nunca toque el pututu |
| `test_pututu_convenes_meeting` | El pututu, usado durante `CALL`, pasa a `DEPARTURE` y marca `pututu_by_player` |
| `test_narrative_beats_order` | Los subtítulos de apertura, noticia y cierre se emiten en orden y una sola vez cada uno |
| `test_quero_cooldown` | Un segundo uso inmediato no restaura estamina; tras el tiempo de espera sí |
| `test_offering_once` | La ofrenda solo se usa una vez por partida |
| `test_world_spawn_south` | El jugador aparece en el camino sur |
| `test_audio_manager_buses` | `AudioManager` existe y el bus de efectos está disponible |

## 4. Verificación manual — Fase 1

Ejecutar la escena sandbox y comprobar:

1. Al iniciar, el ratón está capturado.
2. W/A/S/D mueven en relación con la dirección de la vista horizontal.
3. Mantener Shift con movimiento aumenta la velocidad; sin movimiento no ocurre nada.
4. Al soltar las teclas el jugador desacelera, no se detiene en seco.
5. Mirar al cielo/suelo: la cámara se detiene en ±80°; caminar mirando hacia abajo no reduce la velocidad.
6. No se atraviesan las paredes; se sube la rampa de 30°; no se sube la de 50°; se cae desde la plataforma de 2 m.
7. Balanceo perceptible al caminar, más marcado al correr, se desvanece al parar; sin “tirones” al arrancar.
8. Escape: ratón liberado y juego pausado. Escape otra vez: juego reanudado y ratón capturado de nuevo.
9. Moverse en círculos 2 minutos: sin deriva de la cámara.
10. Consola del editor sin errores ni advertencias.

Si el entorno de ejecución no dispone de pantalla (agente sin GUI), los puntos 1–9 se declaran **no verificados** en el informe y se solicita verificación humana.

### Verificación manual — Fase 2

Con el quero colocado en el sandbox:

1. Al mirarlo desde unos 2,5 m aparece la indicación; al alejarse o girar, desaparece.
2. La indicación muestra el texto traducido, no la clave.
3. E interactúa una sola vez por pulsación: respuesta visual, sonido y recuperación de estamina.
4. Correr consume estamina; al agotarse no se puede correr hasta recuperar el umbral.
5. El quero recupera estamina y el HUD se actualiza por señal.
6. Una pared entre el jugador y el quero impide la interacción.
7. Escape sigue pausando y recapturando el ratón.
8. Consola sin errores ni advertencias.

## 5. Registro de resultados

Cada informe de entrega incluye los comandos ejecutados, su resultado y la lista manual marcada. Las limitaciones y errores pendientes se anotan en la sección correspondiente del informe y, si persisten entre fases, en el plan de implementación.
