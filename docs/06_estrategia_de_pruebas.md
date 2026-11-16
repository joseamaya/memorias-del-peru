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

Criterio: el código de salida es `0` **y** la salida no contiene líneas `ERROR`, `SCRIPT ERROR` ni `WARNING` provenientes de `res://`.

## 3. Pruebas automatizadas

Un ejecutor propio mínimo en `tests/run_tests.gd` (`extends SceneTree`) carga cada archivo `tests/test_*.gd`, ejecuta sus métodos `test_*` y termina con `quit(codigo)` (0 = éxito, 1 = fallo). Cada prueba enumera aquí su archivo al abrirse la fase correspondiente.

**Política:** “pruebas en verde” significa que todas las de esta sección pasan.

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
| `test_mouse_capture_requires_focus` | El ratón se captura solo con la ventana enfocada |
| `test_player_collision_layers` | Capas y máscaras del jugador |
| `test_player_camera_dialogue` | Bloqueo de controles, encuadre del interlocutor y retorno de la cámara |
| `test_footsteps_follow_bob` | Los pasos siguen el balanceo |
| `test_quit_stops_audio` | El cierre ordenado detiene el audio |

### 3.2. Interacción y objetos rituales

| Archivo | Qué cubre |
|---|---|
| `test_interactable_contract` | Contrato de `Interactable` |
| `test_interaction_focus` | Enfoque por rayo y señales de foco |
| `test_interaction_blocked_by_world` | Una pared bloquea el enfoque |
| `test_interaction_calls_interact` | La acción `interact` llama al objeto enfocado |
| `test_stamina_contract` | Límites y señal de estamina |
| `test_stamina_find_in` | Búsqueda del componente de estamina |
| `test_run_uses_stamina` | Correr consume y se detiene sin aliento |
| `test_quero_restores_stamina` | El quero restaura estamina sin conocer la UI |
| `test_quero_cooldown` | El quero no se puede usar durante la espera |
| `test_offering_once` | La ofrenda se usa una sola vez |
| `test_ui_stamina_signal` | El HUD reacciona a la estamina |
| `test_sandbox_loads` | La escena sandbox instancia y entra al árbol |
| `test_sandbox_interaction_hud` | El HUD muestra la acción del quero al enfocarlo |
| `test_localization_tables` | Las claves usadas por Core y campaña existen en sus CSV |
| `test_llacta_loads` | La llacta carga con terreno, ocho casas, terrazas, corrales, ocho personajes, cuatro encargos y límites |
| `test_act_one_tasks` | Tres encargos dan agua, maíz y manta, dejan el cuarto disponible y cambian el objetivo |
| `test_assembly` | El tercer encargo abre la asamblea, la elección deja su bandera y aparece la tarjeta de fin |
| `test_post_acts` | El acto IV abre la asamblea de posguerra y el maíz guardado paga; el acto V completa las cinco obras, incluida la casa, y cierra la campaña |
| `test_campaign_progress` | Recursos, oficio y habilidades del acto I sobreviven al paso al acto II |
| `test_end_card_body` | La tarjeta de fin muestra la noticia de Viracocha y el nombre nuevo con su variante |
| `test_act_three_cost` | La defensa tiene tres oleadas; el costo de Anca y el del hijo de Puma llegan al epílogo |
| `test_paso_sneak` | El sigilo exige Monte o el aviso del mensajero; la cuerda se consume al distraer |
| `test_camp_dialogue` | El campamento reparte sus seis opciones en dos páginas y no pierde coca ni salida |
| `test_city_staging` | Cusi recibe en la puerta, la preparación y la trampa tienen ancla y las cuentas están en casas |
| `test_highlight_scope` | Un punto de conversación sin malla no resalta la escena entera |
| `test_campaign_bible` | Casa al este, cuentas según el coste, Puma reconciliado con y sin coste, oficio en la obra, coste de Anca, trampa obligatoria, cruce que activa la emboscada y Anca testificando en la asamblea |
| `test_core_layering` | `core/` no referencia rutas, clases ni recursos de `campaigns/` |
| `test_checkpoint` | El punto de control restaura salud, aliento, inventario y posición |

### 3.3. Núcleo RPG

| Archivo | Qué cubre |
|---|---|
| `test_character_state` | Salud, ánimo, habilidades por uso y reputación |
| `test_inventory` | Huecos, equipamiento y consumibles |
| `test_dialogue` | Nodos, condiciones por bandera, objeto, habilidad y reputación |
| `test_journal` | Encargos y entradas de Memoria con sello y fuente |
| `test_combat` | Carga, daño, bloqueo, aliento y moral enemiga |
| `test_combat_loadout` | Honda, porra y escudo; munición de piedras; alcance y bloqueo |
| `test_campaign_state` | Banderas entre escenas |
| `test_dialogue_panel` | Panel de diálogo y opciones |
| `test_journal_panel` | Diario y detalle de entradas |
| `test_hud_objective` | Línea de objetivo |
| `test_hud_hint` | Aviso contextual |
| `test_hud_combat` | Viñeta de salud y munición visible solo con la honda |
| `test_intro_cards` | Tarjetas de introducción |
| `test_session_log` | Registro de sesión y marcas |

### 3.4. Configuración, gráficos y audio

| Archivo | Qué cubre |
|---|---|
| `test_graphics_profiles_load` | Los cuatro perfiles cargan |
| `test_graphics_default_profile` | Perfil por defecto y selección por argumento |
| `test_graphics_settings_apply` | Aplicación de escala, upscaler, MSAA y antialiasing |
| `test_audio_manager_buses` | Buses y limitador |
| `test_campaign_audio` | Recursos de audio de la campaña y bucles |
| `test_model_validator` | Validación de modelos |
| `test_main_scene_is_title` | La escena principal es la pantalla de título |
| `test_title_screen` | La portada traduce sus textos y, sin campaña, deshabilita Comenzar |

### 3.5. Pruebas de la campaña (se escriben en la Fase 3)

| Nivel | Qué debe cubrir |
|---|---|
| Acto I | Encargos, recursos, oficio, familia, mensajero y asamblea |
| Acto II | Campamento, emboscada, sigilo, herido, maíz, reclutamiento y preparación |
| Acto III | Oleadas, trampa, costo y contraofensiva |
| Acto IV | Regreso, cuentas, asamblea y noticia |
| Acto V | Reconstrucción, nombre nuevo y cierre |
| Sistemas | Recursos, oficio aplicado, confianza de Sisa, asamblea y puntos de control |
| Del arco | Partida guionizada I→V (`ARCO_OK`) |
| Duración | Marcas por acto y total; objetivo 40–50 min |

### 3.6. Aceptación de escenas

Cada escena de `campaigns/01_pachacutec/documentation/guion_escenas.md` tiene una lista de aceptación. La prueba puede ser:

- **Estructural:** nodos, puntos, textos y banderas.
- **De escena:** personajes presentes, bloqueo, cámara, ropa o prop.
- **De consecuencia:** la bandera se lee donde el guion dice.
- **Manual:** captura o prueba de humo cuando el arte o el audio son el criterio.

Una escena no se marca `Implementado` si su aceptación no se puede verificar. Las deudas se anotan en la ficha y en la bitácora.

## 4. Verificación manual

Al cerrar cada acto:

1. Recorrer el acto completo, sin atajos, con el perfil por defecto.
2. Comprobar la legibilidad de los textos y del HUD.
3. Comprobar la sensación de control: caminar, correr, girar, enfocar y combatir.
4. Escuchar el ambiente y comprobar que no hay cortes ni bucles rotos.
5. Verificar que las decisiones tomadas se notan en el acto siguiente.
6. Anotar la duración con `--session <código>`.
7. Antes de la escucha, medir los niveles con `python3 tools/audio_levels.py`: picos por debajo de -0,5 dBFS, sin clips y sin efectos casi mudos.

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

## 5. Registro de resultados

| Fecha | Alcance | Comando | Resultado |
|---|---|---|---|
| 2026-11-15 | Arco completo I–V, guion, sistemas de campaña y finales | `run_tests.gd` | 97 pruebas, 0 fallos, 0 advertencias |
| 2026-11-15 | Cierre jugable P0: campamento en dos páginas, resaltado acotado, diario navegable y cierre con E/Intro/R | `run_tests.gd` y `arc_playthrough.gd` | 99 pruebas, 0 fallos, 0 advertencias; `ARCO_OK` |
| 2026-11-15 | Puesta en escena 4.2: Cusi en la puerta, preparación visible, trampa con curaca, cuentas en casas y oficio en el diario | `run_tests.gd` y `arc_playthrough.gd` | 100 pruebas, 0 fallos, 0 advertencias; `ARCO_OK` |
| 2026-11-16 | Cierre narrativo 4.3: costo de Anca y del hijo de Puma, casa de Rumi, cinco obras, asamblea con maíz y curaca, intro y aviso del mensajero | `run_tests.gd` y `arc_playthrough.gd` | 103 pruebas, 0 fallos, 0 advertencias; `ARCO_OK`; vídeo `build/partida_completa.mp4` |
| 2026-11-16 | Alineación con la biblia 4.4: casa al este, cuentas variables, Puma con coste, Anca con provisiones y aliento máximo, mensajeros de IV.4/V.2, familia en el cierre, oficio en la obra y trampa obligatoria | `run_tests.gd`, `test_campaign_bible.gd` y `arc_playthrough.gd` | 112 pruebas, 0 fallos, 0 advertencias; `ARCO_OK` |
| 2026-11-16 | Guion de escena 4.5: plantilla reutilizable y 22 fichas de la campaña 01 con bloqueo, cámara, banderas, aceptación y deudas | `run_tests.gd`, `test_campaign_bible.gd` y `arc_playthrough.gd` | 113 pruebas, 0 fallos, 0 advertencias; `ARCO_OK` |
| 2026-11-16 | Cierre de escenas 4.6: I.3, II.1, II.2, III.3, IV.3 y V.1; banderas muertas, rótulos de nombre, campos sin cuidar y coste en la última oleada | `run_tests.gd`, `test_campaign_bible.gd` y `arc_playthrough.gd` | 115 pruebas, 0 fallos, 0 advertencias; `ARCO_OK` |
| 2026-11-16 | Combate 4.7: honda, porra y escudo, munición, viñeta de salud, respiración y HUD sin barra fija | `run_tests.gd`, `test_combat_loadout.gd`, `test_hud_combat.gd` y `arc_playthrough.gd` | 117 pruebas, 0 fallos, 0 advertencias; `ARCO_OK` |
| 2026-11-16 | Duración 4.8: marcas de acto en los cinco mundos y resumen automático del registro | `run_tests.gd`, `test_session_acts.gd`, `arc_playthrough.gd` y `tools/session_duration.py` | 118 pruebas, 0 fallos, 0 advertencias; `ARCO_OK`; herramienta validada con registros sintéticos |
| 2026-11-16 | Rendimiento 4.10: tres pasadas de Medio y ajuste de escala | `measure_performance.tscn` | Bajo y Medio cumplen; Medio: llacta 89,9, paso 88,4, Cusco 62,2, posguerra 91,3, obra 86,6 FPS (mediana) |
| 2026-11-16 | Re-medición de Medio tras el pase visual 4.9 | `measure_performance.tscn` | Carga 2,6–2,8; llacta 87,2, paso 88,5, Cusco 62,4, posguerra 99,6, obra 84,0 FPS (mediana); los cinco actos ≥ 60 |
| 2026-11-15 | Rendimiento por acto, perfil Bajo y Medio | `measure_performance.tscn` | Bajo ≥ 46,6 FPS; Medio 48,4–52,6 FPS |

Cada entrega añade una fila con el alcance, el comando y el resultado.
