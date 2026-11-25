# 06 — Estrategia de pruebas

Principio: **una funcionalidad está terminada cuando se comprobó**, no cuando se escribió.

## 1. Niveles de validación

| Nivel | Qué detecta | Cuándo |
|---|---|---|
| 1. Importación / análisis | Errores de sintaxis, tipado, advertencias como errores, recursos rotos | Tras cada cambio |
| 2. Pruebas automatizadas headless | Contratos (Input Map, jerarquía de escenas, lógica pura) | Tras cada cambio de código |
| 3. Carga de escenas | Escenas que no instancian o producen errores al entrar al árbol | Tras cambios en escenas |
| 4. Verificación manual en ejecución | Sensación de control, visuales, audio | Al cerrar cada tarea con impacto jugable |
| 5. Mundo y persistencia | Sectores, streaming, navegación, NPC, guardado/carga y presupuesto | Al cerrar cada tarea de mundo o sistema nuevo |

## 2. Comandos

> Comandos verificados con Godot 4.7.2. `--check-only` no carga los autoloads; para scripts que los usan, validar con `--import` o con el ejecutor de pruebas.

Importar el proyecto y detectar errores de recursos y scripts:

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

Comprobar la carga y descarga asíncrona de sectores con escenas reales:

```bash
godot --headless --path . --script res://tests/sector_streaming_check.gd
```

Comprobar una ruta entre dos regiones de navegación unidas por un enlace:

```bash
godot --headless --path . --script res://tests/navigation_check.gd
```

Comprobar que Terrain3D carga y que una heightmap mínima se puede consultar:

```bash
godot --headless --path . --script res://tests/terrain3d_check.gd
```

Comprobar el sector gris de integración (Terrain3D, pirca Cyclops, navmesh, 20 NPC y guardado):

```bash
godot --headless --path . --script res://tests/grey_sector_check.gd
```

Comprobar el LOD con 60 NPC, el presupuesto de 25 animados y el snapshot:

```bash
godot --headless --path . --script res://tests/npc_lod_check.gd
```

Comprobar el blockout de F1.7 (casas y pircas Cyclops, multitud, vegetación y navmesh):

```bash
godot --headless --path . --script res://tests/sector_blockout_check.gd
```

Medir carga/descarga repetida de sectores (latencia, hitch y memoria):

```bash
godot --headless --path . --script res://tests/streaming_soak_check.gd
```

Comprobar el relieve regional de F2 (seis sectores, cumbres y río):

```bash
godot --headless --path . --script res://tests/region_terrain_check.gd
```

Auditar la geometría flotante del blockout (sectores, discos, cintas y plazas):

```bash
godot --headless --path . --script res://tools/blockout_float_audit.gd
```

El código de salida es `0` solo si la cara inferior de ningún volumen no exento supera los 0,30 m de hueco, ninguna cinta o disco flota y todo techo, toldo, viga o casa elevada tiene una malla de apoyo debajo (solape XZ y tolerancia de 0,35 m). El informe completo queda en `build/evidencia/blockout_float_audit.txt`.

Comprobar el streaming de los seis sectores sobre el terreno continuo:

```bash
godot --headless --path . --script res://tests/region_streaming_check.gd
```

Comprobar las ocho rutas, los seis navmeshes y la continuidad llacta–Cusco–frontera:

```bash
godot --headless --path . --script res://tests/route_network_check.gd
```

Comprobar el blockout de S3 (17 casas, nueve POI, colisiones y rutas):

```bash
godot --headless --path . --script res://tests/llacta_blockout_check.gd
```

Comprobar el blockout de S1 (28 casas, Coricancha, mercado, talleres y depósitos):

```bash
godot --headless --path . --script res://tests/cusco_blockout_check.gd
```

Comprobar los blockouts de S4, S5 y S6 y sus rutas:

```bash
godot --headless --path . --script res://tests/frontier_sectors_check.gd
```

Comprobar los 30 POI, el diario, el mapa y su persistencia:

```bash
godot --headless --path . --script res://tests/poi_discovery_check.gd
```

Comprobar el recorrido Cusco → frontera por el mundo continuo:

```bash
godot --headless --path . --script res://tests/region_walkthrough_check.gd
```

Comprobar el modo de revisión del blockout (cámara cercana, etiquetas y cenital):

```bash
godot --headless --path . --script res://tests/region_review_check.gd
```

Comprobar que el mundo se recorre a pie (jugador, colisión, streaming y rescate):

```bash
godot --headless --path . --script res://tests/region_player_check.gd
```

Criterio: el código de salida es `0` **y** la salida no contiene líneas `ERROR`, `SCRIPT ERROR` ni `WARNING` provenientes de `res://`. Para comprobarlo sin depender de la vista:

```bash
set -o pipefail
godot --headless --path . --script res://tests/run_tests.gd 2>&1 | tee /tmp/pruebas.log
python3 tools/check_output.py /tmp/pruebas.log
```

```bash
set -o pipefail
godot --headless --path . --import 2>&1 | tee /tmp/import.log
python3 tools/check_output.py /tmp/import.log
```

La CI de GitHub Actions (`.github/workflows/ci.yml`) comprueba en cada PR y push a `main`: inventario de pruebas, lint y formato de los GDScript nuevos, importación, límites de GDScript, pruebas, comportamiento del combate, recorrido de la llacta, mensajero y duda del acto I, arco completo, sector gris, LOD de 60 NPC, blockout de F1.7, streaming con carga/memoria, relieve regional de F2, streaming de sectores, rutas y navmesh, blockout de la llacta, del Cusco y del oeste, POI, recorrido regional, población, descanso y guardado, diálogo y diario, misión principal, actividades secundarias, mirador de Carmenca, obras de defensa, combate del jugador, batalla de Carmenca, antorcha de mano, modo de revisión y exportación de Linux/Windows; el build de Linux se arranca en headless. La salida de cada ejecución pasa por `tools/check_output.py`: cualquier error o advertencia ligado a `res://` falla el job. Si la CI falla, la entrega no está terminada.

Medir la batalla de Carmenca con la oleada completa (peor caso de F3):

```bash
godot --path . --disable-vsync --resolution 1920x1080 \
    res://tests/scenes/measure_battle.tscn -- --profile=1
```

Auditar una escena antes de añadir arte (draw calls, primitivas, luces con sombra):

```bash
godot --path . --resolution 1280x720 -s res://tools/scene_audit.gd -- \
    --scene=res://campaigns/01_pachacutec/scenes/world/region_world.tscn --frames=20
```

Con `--breakdown` oculta cada grupo de primer nivel y mide su aportación, incluido
el pase de sombra. Es la herramienta que localizó el peso de la multitud del Cusco
(173 draw calls) y del pase de sombra (266) antes de optimizar.

## 3. Pruebas automatizadas

Un ejecutor propio mínimo en `tests/run_tests.gd` (`extends SceneTree`) carga cada archivo `tests/test_*.gd`, ejecuta sus métodos `test_*` y termina con `quit(codigo)` (0 = éxito, 1 = fallo). Toda prueba nueva se añade a esta sección en el mismo lote: `tools/check_test_inventory.py` comprueba que no falte ninguna y que todos los recorridos de integración se ejecuten en la CI.

**Política:** “pruebas en verde” significa que todas las de esta sección pasan.

**Aislamiento del guardado:** los recorridos de integración que guardan llaman a `SaveManagerService.set_save_root("user://test-saves")` antes de crear el mundo. Así no leen ni borran la ranura del jugador en `user://saves`. La raíz se puede consultar con `SaveManagerService.save_root()` y restaurar con `reset_save_root()`.

**Aislamiento del mundo:** `run_tests.gd` limpia `WorldState` antes de cada archivo de prueba. El catálogo de POI marca los descubrimientos de inicio y, sin esta limpieza, las pruebas siguientes los heredaban.

### 3.1. Motor y jugador

| Archivo | Qué cubre |
|---|---|
| `test_input_map` | Las acciones del Input Map existen y tienen eventos |
| `test_player_scene_structure` | Jerarquía de `player_fps.tscn`: cámara, rayo de interacción y tipos |
| `test_pitch_clamp` | Límite vertical de la cámara en ±80° |
| `test_head_bob_no_drift` | El balanceo vuelve a la posición base sin acumular desplazamiento |
| `test_head_bob_max_step` | El balanceo no da saltos por tick |
| `test_player_eye_height` | El origen del jugador está a los pies; ojos a 1,60 m |
| `test_gravity_default` | Gravedad coherente con la del proyecto |
| `test_pause` | Pausa y señal `pause_changed` |
| `test_mouse_mode_for_pause` | Modo de ratón al pausar y reanudar |
| `test_mouse_capture_requires_focus` | El ratón se captura solo con la ventana enfocada, sin controles bloqueados ni UI con el puntero |
| `test_player_mouse_unlock` | Al liberar los controles (diálogo, diario o pausa) se vuelve a pedir la captura del ratón |
| `test_player_collision_layers` | Capas y máscaras del jugador |
| `test_player_camera_dialogue` | Bloqueo de controles, encuadre del interlocutor, retorno de la cámara y arma oculta al cerrar el diario sin equipo |
| `test_jump` | El salto solo se aplica en el suelo y con los controles libres |
| `test_pause_menu` | El panel de pausa ofrece continuar, volver al título y salir, con textos traducidos |
| `test_footsteps_follow_bob` | Los pasos siguen el balanceo |
| `test_quit_stops_audio` | El cierre ordenado detiene el audio |

### 3.2. Interacción y objetos rituales

| Archivo | Qué cubre |
|---|---|
| `test_interactable_contract` | Contrato de `Interactable` |
| `test_interaction_focus` | Enfoque por rayo y señales de foco, también si el objetivo se libera |
| `test_interaction_blocked_by_world` | Una pared bloquea el enfoque |
| `test_interaction_calls_interact` | La acción `interact` llama al objeto enfocado |
| `test_stamina_contract` | Límites y señal de estamina |
| `test_stamina_find_in` | Búsqueda del componente de estamina |
| `test_run_uses_stamina` | Correr consume y se detiene sin aliento |
| `test_ui_stamina_signal` | El HUD reacciona a la estamina |
| `test_localization_tables` | Las claves usadas por Core y campaña existen en sus CSV |
| `test_core_layering` | `core/` no referencia rutas, clases ni recursos de `campaigns/` |

### 3.3. Núcleo RPG

| Archivo | Qué cubre |
|---|---|
| `test_character_state` | Salud, ánimo, habilidades por uso y reputación |
| `test_inventory` | Huecos, equipamiento y consumibles |
| `test_dialogue` | Nodos, condiciones por bandera, objeto, habilidad y reputación |
| `test_journal` | Encargos y entradas de Memoria con sello y fuente |
| `test_combat` | Carga, daño, bloqueo, aliento y moral enemiga |
| `test_combat_loadout` | Honda, porra y escudo; munición de piedras; alcance y bloqueo |
| `test_combat_input` | Munición ligada al arma equipada, clic del escudo que suelta el bloqueo, botón derecho que baja si la suelta se pierde y carga cancelada al bloquear o perder la suelta |
| `test_combat_feel` | Fases del golpe, parry de 0,15 s, bloqueo del 70 % y fichas del director |
| `test_campaign_state` | Banderas entre escenas |
| `test_dialogue_panel` | Panel de diálogo y opciones; con el juego en pausa no avanza ni elige |
| `test_journal_panel` | Diario y detalle de entradas |
| `test_hud_hint` | Aviso contextual |
| `test_hud_interaction` | El aviso de interacción desaparece al perder el foco |
| `test_hud_combat` | Viñeta de salud y munición visible solo con la honda |
| `test_session_log` | Registro de sesión y marcas |

### 3.4. Configuración, gráficos y audio

| Archivo | Qué cubre |
|---|---|
| `test_graphics_profiles_load` | Los cuatro perfiles cargan |
| `test_graphics_default_profile` | Perfil por defecto y selección por argumento |
| `test_graphics_settings_apply` | Aplicación de escala, upscaler, MSAA y antialiasing |
| `test_audio_manager_buses` | Buses y limitador |
| `test_model_validator` | Validación de modelos |
| `test_character_outfit` | El atuendo descarta una pieza nula sin leer su hueso |
| `test_chaquitaclla` | GLB de la chaquitaclla del Agricultor, validador, altura y estribo |
| `test_first_person_hands` | Mano de maniquí: antebrazo UAL1, falanges y poses abierta y puño |
| `test_main_scene_is_title` | La escena principal es la pantalla de título |
| `test_title_screen` | La portada traduce sus textos y, sin campaña, deshabilita Comenzar |

### 3.4.1. Mundo y persistencia (F1)

| Archivo | Qué cubre |
|---|---|
| `test_world_clock` | Avance, pausa, franjas, `minutes_until`, día cruzado y round-trip |
| `test_world_state` | Fase, banderas, descubrimientos, estado de NPC, cambios físicos y round-trip |
| `test_save_round_trip` | Guardado versionado, sobrescritura, nombres inválidos, listado, recuperación del respaldo tras un cierre a medias o con el principal corrupto y ciclo mundo/reloj/jugador |
| `test_resource_catalog` | Diálogos y POI se cargan con las mismas entradas del juego (`register_directory` y `load_catalog`), que resuelven los `.tres.remap`, y el catálogo completo (11 y 31) está presente |
| `test_rest_cycle` | Descanso: hora de despertar, salto de día antes y después de la hora y aplicación al reloj |
| `test_npc_schedule` | Franjas diarias, cruce de medianoche, condiciones, ancla/actividad y validez |
| `test_sector_streamer` | Celdas, radio de carga, distancia, siempre cargado y registro de definiciones |
| `sector_streaming_check.gd` | Carga asíncrona de escenas reales, descarga por radio y sector siempre cargado |
| `streaming_soak_check.gd` | 60 ciclos de carga/descarga: latencia < 150 ms, hitch < 50 ms y memoria estable |
| `region_terrain_check.gd` | 3,5 × 2,5 km de relieve: seis sectores con alturas plausibles, cumbres y cauce bajo la vega |
| `region_streaming_check.gd` | Seis sectores cargan por cercanía, se descargan al alejarse y el terreno regional sigue cargado |
| `route_network_check.gd` | Ocho rutas dibujadas, seis navmeshes con enlaces, rutas continuas a Cusco/frontera y R7 como acequia que termina en el río |
| `llacta_blockout_check.gd` | S3 con 17 casas, 9 POI, 20 colisiones, plaza despejada, acequia sin cruzar casas y rutas al manantial y a las afueras |
| `cusco_blockout_check.gd` | S1 con 38 casas (28 de ayllu y 10 del arrabal), 7 POI, Coricancha, mercado, talleres, depósitos, acequia entre calles y rutas a afueras y llacta |
| `city_check.gd` | Ciudad habitable: aparición en el arrabal de Chocos-chacona, 10 casas de barrio, plaza del Cusco a 154 m y jugador sobre el terreno |
| `interiors_check.gd` | Tres interiores transitables: sala instanciada fuera del terreno, vestidos distintos, lecho bajo andino solo en la casa del jugador, leyendas visibles y vuelta exacta a la puerta |
| `day_night_check.gd` | Ciclo día/noche: el reloj mueve sol, ambiente y niebla; cuatro franjas distinguibles y sin saltos de energía |
| `lantern_check.gd` | Antorcha de mano: apagada de día, encendida de noche, encendido gradual en el atardecer y sin sombras |
| `city_population_check.gd` | 24 NPC registrados, 8 nombrados a 0,9 ± 0,10 m del suelo, rutinas de mañana y noche, y 20 min simulados sin atravesar casas |
| `city_save_round_trip.gd` | Dormir en la casa del jugador, guardado automático y carga en una instancia nueva: hora, NPC, misión, inventario y obras |
| `dialogue_check.gd` | Conversación y diario en el mundo: interactable de NPC con nombre, grafo traducido, bandera en `WorldState` y diario que abre y cierra con J |
| `mission_check.gd` | Misión principal: tres etapas, encargos en el mundo, partida de Viracocha, fase de guerra, diario y guardado a mitad |
| `mission_stage2_check.gd` | Cargar en la etapa 2 conserva la conversación de partida y `m01_queda` se fija recorriendo el grafo real de la curáca; cada paso lleva etiqueta |
| `side_activities_check.gd` | Secundarias: reparto del agua con sus tres desenlaces y diario, manta tejida en el telar, negativo del telar sin encargo y guardado/carga |
| `side_manta_load_check.gd` | Cargar con la lana entregada y la manta sin aceptar conserva la oferta de la tejedora y su encargo |
| `mirador_check.gd` | Descubrimiento sin marcador: el mirador de Carmenca se descubre por proximidad, deja su memoria en el diario, muestra el campamento con las doce tiendas y su colisión, y sobrevive a la carga sin duplicar la entrada |
| `defense_works_check.gd` | Obras de defensa con pasos etiquetados: cuatro fosos, negativo antes de quedarse, construcción persistente en `WorldState.changes`, geometría cubierta y guardado/carga sin perder obras; si falta un foso informa del paso en vez de colgarse |
| `combat_check.gd` | Combate del jugador: arma y desarme, golpe de porra contra un chanca, golpe recibido, escudo que absorbe y honda que gasta piedra |
| `test_allied_follow` | El aliado espera detrás del jugador y, si lo tiene encima, cede el paso de lado en vez de bloquear la ruta |
| `test_carmenca_spawn` | Anillo de aparición: ningún hueco cae a menos de 6 m del jugador y el que cae encima se refleja al otro lado |
| `carmenca_check.gd` | Batalla: radio de activación del campamento por fuera y por dentro, porra inicial y aviso de teclas, tres oleadas con obras que restan enemigos, aliados, derrota con reaparición junto a los aliados, aparición reflejada con el jugador dentro del campamento, estandarte que fija `m01_victoria` y cierra la misión |
| `frontier_sectors_check.gd` | S4 quebrada, S5 paso y S6 frontera con POI, colisiones y rutas al oeste |
| `poi_discovery_check.gd` | 30 POI, inicio y proximidad, diario/mapa, fases y persistencia |
| `region_walkthrough_check.gd` | Recorrido Cusco–frontera de 2.758 m y 23 min a pie; seis sectores y ocho POI sin fallos |
| `region_review_check.gd` | Cámara cercana, etiquetas de POI ocultas por defecto, tecla H con una etiqueta y vista cenital con T (las de interacción siempre visibles) |
| `region_player_check.gd` | Jugador en primera persona sobre el terreno, 9 m andados, plaza, streaming, rescate y marcador de S2 oculto |
| `test_navigation_service` | Consulta fuera del árbol, mapa no listo, longitud de ruta y punto más cercano |
| `test_npc_mover` | Ruta de NPC: avance por tramos, altura interpolada, fin de ruta y ruta vacía |
| `test_npc_ground_goal` | El destino del NPC sigue el suelo del punto desplazado en pendiente y la carga corrige la altura guardada |
| `test_npc_walk_height` | Al caminar, el cuerpo sigue el suelo muestreado y no la Y de la ruta del navmesh |
| `test_npc_lod` | Distancias de LOD, presupuesto 60 activos/25 animados, despawn, snapshot y horario |
| `navigation_check.gd` | Ruta entre dos regiones unidas por `NavigationLink3D`, con hueco de 5 m |
| `terrain3d_check.gd` | Terrain3D carga, crea una región y devuelve la altura importada |
| `grey_sector_check.gd` | Sector gris: navmesh horneado sobre Terrain3D, pirca Cyclops como obstáculo, 20 NPC que llegan caminando y guardado |
| `npc_lod_check.gd` | 60 NPC con 60 activos y 25 animados, despawn al alejar la vista, rutas y snapshot |
| `sector_blockout_check.gd` | 6 casas y pircas Cyclops, 120 de multitud, 180 de vegetación, navmesh con obstáculos y 60 NPC |

### 3.7. Mundo abierto (previstas, F1–F3)

Estas pruebas **todavía no existen**, salvo las de reloj, estado, guardado, horario y streaming, que ya están en §3.4.1. Se escriben con su sistema, en el mismo PR, y entonces se incorporan a §3.1–§3.4. La lista fija el contrato mínimo:

| Área | Prueba prevista | Criterio |
|---|---|---|
| NPC LOD | `test_npc_lod` | Cerca/medio/lejos; límite de animados y de sombras |
| Misiones | `test_quest_state` | Etapas, condiciones, consecuencias y guardado |
| Descubrimientos | `test_discovery_registry` | POI, mapa y rumor; sin duplicados |
| Contenido | `test_content_ids` | IDs, textos y fichas existen; ninguna referencia rota |
| Rendimiento | `test_sector_budget` | Draw calls, primitivas y VRAM dentro del presupuesto |
| Recorrido | `world_slice_check.gd` | 30–45 min de slice: salir, descubrir, trabajar, volver y guardar |

Pruebas de la slice de F3, que se escriben con cada tarea de la [ficha de F3](fases/F3-vertical-slice.md):

| Área | Prueba prevista | Criterio |
|---|---|---|
| Ciudad | `city_check` | Aparición en el arrabal; arrabal, plaza y Coricancha sin huecos ni flotantes |
| Interiores | `interiors_check` | Entrar y salir de las tres casas; ≤ 15 draw calls cada una |
| Día y noche | `day_night_check` | Cuatro franjas distinguibles sin saltos; FPS estable |
| Población | `city_population_check` | 24 NPC, 8 nombrados, 20 min sin atascos |
| Misión | `mission_check` | Tres etapas con estado y consecuencia persistente |
| Secundarias | `side_activities_check` | Dos actividades con consecuencia; descubrimiento sin marcador |
| Defensa | `defense_works_check` | Fosos y púas persistentes y leídos por la batalla |
| Batalla | `carmenca_check` | Arranca al entrar en el campamento (no antes del mirador); tres oleadas sin bloqueos; estandarte como objetivo |

## 4. Verificación manual

### 4.1. Validación visual

Se exige cuando una tarea cambia escenarios, personajes, iluminación, materiales, props o interfaz. El agente prepara la evidencia y señala lo que ve; **el veredicto estético es del responsable**.

**Tomas fijas.** Cada revisión repite las mismas tomas, anotadas en la ficha de la tarea con nombre, posición, objetivo, inclinación y perfil. Se hacen con la cámara real del jugador, no con cámara libre, y con HUD, manos y arma ocultos. Resolución: 1280×720 (1920×1080 si el criterio es la interfaz). Escenas disponibles:

| Escena | Qué enseña |
|---|---|
| `tests/scenes/capture_title.tscn` | Portada |
| `tests/scenes/capture_region.tscn` | Región completa desde el mirador |
| `tests/scenes/capture_routes.tscn` | Rutas y red de caminos |
| `tests/scenes/capture_cusco_blockout.tscn` | S1 Cusco preimperial |
| `tests/scenes/capture_llacta_blockout.tscn` | S3 Llacta del valle |
| `tests/scenes/capture_west.tscn` | Quebrada, paso y frontera |

```bash
godot --path . --resolution 1280x720 res://tests/scenes/capture_llacta_blockout.tscn
```

Las capturas se escriben en `build/evidencia/`; las aprobadas, en la documentación de la campaña.

**Antes y después.** Antes de tocar la escena se guarda la tanda base en `campaigns/<campaña>/documentation/img/<tarea>/antes/`; después del cambio, la misma tanda en `.../despues/`. Una tanda anterior no se sobrescribe: si hace falta otra iteración, se usa `antes_2`/`despues_2` o una carpeta con fecha.

**Blockout regional.** La prueba humana de F2 tiene un protocolo propio con rutas, checkpoints, registro de incidencias y veredicto en [prueba_blockout.md](../campaigns/01_pachacutec/documentation/mundo/prueba_blockout.md). Las capturas de trabajo van a `build/evidencia/`; las aprobadas, a `campaigns/01_pachacutec/documentation/img/f2_blockout/`.

**Vertical slice.** La pasada humana de F3, de 30 a 45 minutos, tiene su propio protocolo cronometrado, con registro de bloques e incidencias, en [prueba_vertical_slice.md](../campaigns/01_pachacutec/documentation/prueba_vertical_slice.md); el veredicto se firma en el [acta de cierre de F3](fases/F3-acta-de-cierre.md).

**Qué se revisa:**

1. **Cámara del jugador:** horizonte, encuadre y escala de puertas, casas, personas (1,70 m) y caminos.
2. **Materiales y formas:** paleta de blockout, siluetas y escala; la guía visual definitiva se escribe con el arte de F3.
3. **Legibilidad:** textos, HUD, siluetas y objetos interactuables.
4. **Anacronismos:** lista de [docs/07](07_convenciones_historicas.md) §4.
5. **Comparación:** qué mejora, qué empeora y qué no cambió.

**Rendimiento.** En la misma sesión, medir con `tools/scene_audit.gd` (draw calls, primitivas y luces con sombra) y, si cambia el sector, con `measure_cusco.tscn`, `measure_blockout.tscn` o `measure_battle.tscn`: tres pasadas por perfil, mediana, p1 y carga del sistema. Presupuesto en [docs/08](08_entorno_y_rendimiento.md) §4.

**Evidencia.** Las capturas aprobadas se versionan en la documentación de la campaña; las de trabajo pueden quedar en `build/` (ignorado por Git). La ficha de la tarea anota tomas, comandos, cifras, veredicto y fecha; el PR enlaza la carpeta y resume el antes/después.

**Cierre.** Una tarea visual no se marca terminada sin capturas antes/después, medición, revisión del responsable y deudas declaradas. Lo que falte queda como *no verificado*.

### 4.2. Mundo abierto (F1–F3)

Al cerrar una tarea de mundo:

1. **Recorrido:** entrar al sector, cruzarlo en varias direcciones, salir y volver; sin bloqueos ni caídas.
2. **Streaming:** medir carga, hitch y memoria en un recorrido de 10 minutos; anotar el peor caso.
3. **Navegación:** una ruta de NPC entre casa, trabajo y puerta; una ruta del jugador entre comunidad y paso.
4. **Guardado:** guardar, salir, cargar y comprobar posición, misión, NPC, inventario, hora y un cambio del mundo.
5. **Vida:** comprobar que al menos tres NPC siguen su rutina y que el mundo cambia con la hora.
6. **Descubrimiento:** encontrar un POI sin marcador y verificar que el diario y el mapa lo registran.
7. **Rendimiento:** `scene_audit.gd` por sector, `measure_cusco.tscn` en la ciudad y `measure_battle.tscn` en la batalla.
8. **Histórico:** revisar la clasificación del sector y sus fichas.

### Duración de la partida

Cada mundo marca su acto al tomar el control (`SessionLog.mark(&"act", ...)`) y
la campaña cierra con `act_five_end`. El registro permite calcular la duración
real sin cronómetro externo:

```bash
godot --path . -- --session PCH-DUR-1
python3 tools/session_duration.py PCH-DUR-1
```

El script imprime una tabla con inicio, fin y duración de cada acto, y el total
entre la primera marca y el cierre. `--json` sirve para adjuntar la medición a
un informe. La partida debe jugarse sin atajos y con el perfil por defecto; los
tiempos de carga de escena quedan dentro del acto que empieza.

