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
| `test_graphics_default_profile` | El juego arranca en Medio (SSAO activo y escala 1.0) y `--profile=N` elige otro perfil |
| `test_graphics_settings_apply` | `set_profile` emite `profile_changed`, aplica escala, MSAA y antialiasing al Viewport, y deja constancia del atlas de sombras y de sus 16 bits |
| `test_shadow_atlas_per_profile` | Los cuatro perfiles fijan su tamaño de atlas y todos usan 16 bits |
| `test_environment_quality_controller` | El controlador aplica niebla, SSAO, SDFGI y distancia de sombras al cambiar de perfil |
| `test_player_spawn` | El jugador aparece en la transformación de `PlayerSpawn` |
| `test_terrain_normals_up` | Las normales del terreno apuntan hacia +Y |
| `test_terrain_collision_shape` | El terreno tiene una forma de colisión `ConcavePolygonShape3D` |

### Pruebas de Fase 4

| Prueba | Comprueba |
|---|---|
| `test_llacta_layout` | Existen plaza, entre 6 y 8 viviendas, terrazas, los cuatro caminos y el mirador |
| `test_world_sky_layers` | La cúpula de nubes tiene `SphereMesh` y shader propio, y las tres siluetas de cordillera lejana tienen malla, material sin sombreado y ninguna colisión |
| `test_houses_clear_paths` | Ninguna vivienda ocupa el eje de un camino |
| `test_terraces_have_ramps` | Cada nivel de terraza tiene una rampa inclinada con colisión |
| `test_terraces_solid` | Los bloques de cada terraza llegan al suelo, bajo cada rampa elevada hay relleno y una tapa cierra el extremo alto; cada nivel tiene su malla de piedras (`TerraceNNWalls`) y `StoneWall.build()` da el mismo resultado con la misma semilla |
| `test_terrain_relief` | Las lomas del campo valen 0 en la plaza, las casas, las terrazas, los caminos, el inicio, el mensajero y el vecino que recibe, y tienen relieve en el campo abierto sin pasar de su amplitud |
| `test_world_bounds` | El límite del mundo tiene colisión a ~70 m del centro |
| `test_llacta_interactables` | Quero, ofrenda y pututu existen, son `Interactable` y de tipos distintos |
| `test_first_person_hands` | El jugador tiene manos ocultas por defecto; la ofrenda, el quero y el pututu declaran sus gestos y «Hablar» no muestra mano |
| `test_npcs_present` | Tejedora y agricultor existen con presencia |
| `test_messenger_event_starts_on_clock` | El evento no arranca antes del reloj y arranca al cumplirse con el jugador en la plaza |
| `test_messenger_event_waits_for_plaza` | Si el jugador no está en la plaza, el evento espera y arranca al agotarse la espera |
| `test_messenger_event_hastens_by_action` | Completar las tareas cerca de la plaza adelanta la llegada; lejos, la petición espera a que el jugador se acerque; mientras espera, el mensajero se ve acercarse (ADR-0030) |
| `test_messenger_event_finishes_without_pututu` | La máquina llega a `DONE` aunque el jugador nunca toque el pututu |
| `test_pututu_convenes_meeting` | El pututu está disponible en `CALL` y al usarlo pasa a `DEPARTURE` con `pututu_by_player` |
| `test_pututu_ignores_early_touch` | Un toque antes de `CALL` no gasta el pututu y el evento termina igual |
| `test_event_finishes_with_spent_pututu` | Con el pututu ya gastado, el relevo del curaca cierra el evento |
| `test_curaca_calls_once` | El curaca convoca una sola vez y no reintenta cada fotograma |
| `test_party_leaves_and_neighbors_stay` | La comitiva sale por el camino norte y se oculta; los vecinos se quedan |
| `test_narrative_beats_order` | Apertura, señal intermedia de la espera, noticia, aviso de llamada y cierre se emiten en orden y una sola vez |
| `test_subtitle_widget` | El HUD da a cada subtítulo al menos su tiempo de lectura, pone en cola los siguientes sin repetirlos, limita la cola y la vacía con `clear_subtitle()`; el rótulo de lugar aparece con fundido y se oculta (ADR-0012) |
| `test_hud_feedback` | El HUD muestra y oculta el aviso de pausa y etiqueta la barra de aliento; la tarjeta de fin aparece 50 s después de terminar el evento, con fundido y texto traducido; `InteractionHighlight` resalta las mallas del interactuable, o las de su padre si no tiene, y restaura la superposición anterior al cambiar o perder el foco |
| `test_quero_cooldown` | El quero respeta su espera entre usos y no está disponible mientras dura (ADR-0008) |
| `test_offering_once` | La ofrenda solo se usa una vez y, ya usada, deja de estar disponible (ADR-0008) |
| `test_offering_visual` | Al dejar la ofrenda aparece el atado de coca y maíz sobre el adoratorio, con su modelo cargado; antes estaba oculto |
| `test_world_spawn_south` | El jugador aparece en el camino sur, a menos de 25 m de la plaza y con el quero a la vista |
| `test_mouse_capture_requires_focus` | El jugador solo pide capturar el ratón en juego y con la ventana enfocada |
| `test_footsteps_follow_bob` | Un paso por ciclo de balanceo, más frecuentes al correr, ninguno quieto o en el aire, y siempre con la cámara en su punto bajo |
| `test_meeting_keeps_objects_clear` | En la reunión, todos los personajes quedan en la mitad norte de la plaza y a ≥ 2,5 m del quero, el pututu y la ofrenda |
| `test_meeting_gathers_around_messenger` | Durante `ARRIVAL` el grupo sale hacia el mensajero y, en `CALL`, forma un anillo apretado a su alrededor con gente en los flancos |
| `test_footstep_surfaces` | El paso usa el conjunto de la superficie pisada y, sin conjunto, el de por defecto. En el mundo, las rampas de las terrazas son de piedra, encima de los bloques se pisa tierra de cultivo (con su malla de surcos) y el terreno no declara superficie |
| `test_plaza_murmur_phases` | El murmullo de la plaza suena en `MESSAGE` y `CALL` y calla en el resto; su recurso existe |
| `test_boundary_ridge` | La cresta deja a nivel el interior, el inicio y el paso norte, sube más de 8 m en el borde y su ladera supera los 45° |
| `test_model_validator` | El validador de modelos acepta casos correctos y rechaza nombre, escala, origen, tamaño, colisión de casa y altura de personaje incorrectos; incluye un `.glb` exportado e importado con `GLTFDocument` |
| `test_model_files_valid` | Todo `.glb` de `campaigns/01_pachacutec/assets/models/` cumple las reglas de §7 del alcance y no hay `.blend` (sin modelos, pasa sin comprobar nada) |
| `test_model_slot` | `ModelSlot` conserva el bloqueo sin archivo, carga el modelo y oculta el bloqueo con archivo, y solo sustituye la colisión si el modelo trae la suya; el mundo tiene hueco en 8 casas, 9 personajes (colgado del cuerpo, con los pies en el origen del personaje), 3 objetos y el telar; `enable_vertex_colors` activa el color por vértice solo en las superficies que lo traen; cada casa tiene sus props (cántaros, leña) en huecos aparte, al menos 8 |
| `test_npc_talk_and_wander` | El mundo muestra el rótulo de lugar; el mensajero sale como tarde a los 100 s y se le ve acercarse antes; el vecino del camino sur saluda solo cuando el jugador se acerca; seis personajes tienen «Hablar» en la capa de interactuables solo antes de la noticia; la frase llega al HUD y el personaje se gira hacia el jugador; los vecinos pasean balanceando las piernas, se detienen al hablarles y dejan el paseo para acercarse al mensajero cuando llega (ADR-0012, ADR-0032) |
| `test_vegetation` | El reparto de ichu y queñua es determinista y deja libres la plaza, los caminos, las casas, las terrazas, la tejedora, el inicio, la salida de la comitiva y el mirador; las matas se apoyan en el terreno; los bloques de ichu se ocultan a 50 m y no proyectan sombra; cada queñua tiene tronco con colisión y separación mínima |
| `test_quit_stops_audio` | `GameManager` desactiva `auto_accept_quit`, pausa el árbol antes de cerrar y `stop_audio_in()` detiene los reproductores bajo un nodo, incluido el propio nodo, y suelta sus flujos |
| `test_session_log` | El registro de sesión valida los códigos, escribe cabecera y marcas en orden con el tiempo transcurrido, no abre una segunda sesión y no escribe nada fuera de una sesión (alcance v4.16) |
| `test_hud_objective` | La línea de objetivo aparece con texto traducido, cambia de texto y se retira sin dejar rastro |
| `test_tour_card` | La tarjeta de estación muestra título, cuerpo, sello y fuente, se cierra y emite `closed` |
| `test_world_tour` | El mundo crea siete zonas de lugar, no hay objetivo ni contador al empezar, entrar en una zona o beber del quero abre la tarjeta y desactiva al jugador, las nueve tarjetas se abren en orden, la segunda visita no las reabre y llegar al mirador abre el evento (ADR-0036, ADR-0037) |

### Pruebas de la Fase 6 (núcleo RPG)

| Prueba | Qué comprueba |
|---|---|
| `test_character_state` | Salud, ánimo, habilidades por uso (umbrales 3/8/15/24/35) y reputación por grupo; señales y límites |
| `test_inventory` | Ocho huecos, tres equipados, apilar, retirar, contar y usar consumibles; sin perder objetos al llenarse |
| `test_dialogue` | Nodos con condiciones por bandera, objeto, habilidad y reputación; efectos y opciones bloqueadas |
| `test_journal` | Encargos activos y cumplidos; entradas de Memoria con clave, sello y fuente; sin duplicados |
| `test_combat_sling` | Carga, proyectil, daño según habilidad, munición y moral enemiga con huida |
| `test_act_one_playthrough` | El acto I se juega de principio a fin: tres encargos, mensajero y partida, sin bloqueos |
| `test_dialogue_panel` | El panel muestra hablante, línea y opciones; elegir emite el índice; E avanza sin opciones |
| `test_journal_panel` | El diario lista encargos y Memoria, muestra detalle con sello y fuente, y se cierra |
| `test_world_dialogue` | Hablar con la tejedora abre el diálogo, la opción deja una entrada de Memoria y J abre y cierra el diario |

La partida del arco completo (tres actos) se añade en la Fase 7 y sustituye al
`demo_playthrough` del vertical slice como prueba de extremo a extremo.

Prueba de humo con tiempo real acelerado (no forma parte del ejecutor):

```bash
godot --headless --path . --script res://tests/soak_messenger_event.gd
```

Carga el mundo, acelera el reloj ×20 y exige que el evento llegue a `DONE` sin intervención. Verifica el camino real de `_process`, no solo `step()`.

Partida completa conducida por guion (tampoco forma parte del ejecutor; sin pantalla tarda unos segundos):

```bash
godot --headless --path . --fixed-fps 30 --script res://tests/demo_playthrough.gd
```

El jugador recorre la plaza, el oeste, las terrazas y el mirador, bebe del quero, deja la ofrenda, habla con la tejedora, espera al mensajero y toca el pututu en la llamada. Exige `DEMO_OK`: el evento llega a `DONE`, el quero, la ofrenda y la tejedora responden y el pututu lo toca el jugador. Es la prueba de extremo a extremo del vertical slice: entrada, interacción, evento y cierre ordenado.

La misma partida con `--session PIL-TEST` comprueba el registro de las sesiones de prueba (alcance v4.16): deja `user://sesiones/PIL-TEST.log` con las marcas de introducción, llegada, pututu, cierre y tarjeta final.

La misma partida sirve para grabar un vídeo de demostración con Movie Maker (AVI MJPEG con sonido):

```bash
godot --path . --write-movie demo.avi --fixed-fps 30 --script res://tests/demo_playthrough.gd
```

Capturas fijas para comparar materiales (tampoco forma parte del ejecutor):

```bash
godot --path . --resolution 1280x720 --script res://tests/capture_views.gd
```

Carga el mundo sin HUD, congela el evento y guarda cinco vistas en `user://capturas/`: aparición, suelo a media distancia, muro de pirca a 1,5 m, casa a 6 m y horizonte desde el mirador. Sirve para evaluar un cambio de materiales contra el mismo encuadre, no para probar lógica.

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
