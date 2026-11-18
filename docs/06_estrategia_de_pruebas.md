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

Comprobar el comportamiento del combate con tres enemigos y un bot (fichas de
ataque, resolución y atascos):

```bash
godot --headless --path . --script res://tests/combat_arena_check.gd
```

Comprobar el recorrido de la llacta (entrada sur, plaza, manantial, casa,
mirador del norte, pirca y corrales) con el jugador real:

```bash
godot --headless --path . --script res://tests/llacta_walk_check.gd
```

Criterio: el código de salida es `0` **y** la salida no contiene líneas `ERROR`, `SCRIPT ERROR` ni `WARNING` provenientes de `res://`.

La CI de GitHub Actions (`.github/workflows/ci.yml`) repite en cada push a `main`:
importar, límites de GDScript, pruebas, comportamiento del combate, recorrido de la
llacta, arco completo y exportación de Linux/Windows; el build de Linux se arranca en headless. Si la CI falla, la entrega no
está terminada.

Auditar una escena antes de añadir arte (draw calls, primitivas, luces con sombra):

```bash
godot --path . --resolution 1280x720 -s res://tools/scene_audit.gd -- \
    --scene=res://campaigns/01_pachacutec/scenes/world/ciudad.tscn --frames=20
```

Con `--breakdown` oculta cada grupo de primer nivel y mide su aportación, incluido
el pase de sombra. Es la herramienta que localizó el peso de la multitud del Cusco
(173 draw calls) y del pase de sombra (266) antes de optimizar.

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
| `test_llacta_layout` | Caminos visibles, borde de plaza, manantial, mirador, fondo de valle y colisión de casa por variante |
| `llacta_walk_check.gd` | Recorrido real de entrada, plaza, manantial, casa, mirador, pirca y corrales sin atascos |
| `test_act_one_tasks` | Tres encargos dan agua, maíz y manta, dejan el cuarto disponible y abren la duda |
| `test_act_one_flow` | Recorrido de jugador nuevo: mañana, honda de tres aciertos, cuatro encargos, duda, mensajero y asamblea; lista, contador y marcadores solo cuando toca; el cuarto encargo no rebobina |
| `test_assembly` | La duda abre el mensajero, la asamblea pregunta, la elección deja su bandera y aparece la tarjeta de fin |
| `test_post_acts` | El acto IV abre la asamblea de posguerra y el maíz guardado paga; el acto V completa las cinco obras, incluida la casa, y cierra la campaña |
| `test_campaign_progress` | Recursos, oficio y habilidades del acto I sobreviven al paso al acto II |
| `test_end_card_body` | La tarjeta de fin muestra la noticia de Viracocha y el nombre nuevo, y espera al fondo oscuro antes de mostrar el cuerpo |
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
| `test_combat_feel` | Fases del golpe, parry de 0,15 s, bloqueo del 70 % y fichas del director |
| `combat_arena_check.gd` | Tres chancas contra un bot: ≤ 2 atacantes, resolución y sin atascos |
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
| `test_palette_tuning` | Las paletas de acto se aplican al sol, ambiente, niebla y cielo; los cinco recursos cargan |
| `test_graphics_default_profile` | Perfil por defecto y selección por argumento |
| `test_graphics_settings_apply` | Aplicación de escala, upscaler, MSAA y antialiasing |
| `test_audio_manager_buses` | Buses y limitador |
| `test_campaign_audio` | Recursos de audio de la campaña y bucles |
| `test_model_validator` | Validación de modelos |
| `test_quaternius_characters` | Rig de 76 huesos (65 UBC + 6 de manto + 1 mandíbula + 4 de expresión), clips lógicos, `NpcActor`, catálogo de todos los papeles, política de sombras, LOD de multitud, muelles del manto, mandíbula de habla, parpadeo, cejas, porra que se oculta cerca de la cámara y altura de HijoPuma |
| `test_chaquitaclla` | GLB de la chaquitaclla del Agricultor, validador, altura y estribo |
| `test_mannequin_prototype` | Looks UAL1, huesos reales, atuendo, nodo `OutfitMannequin` y mano extraída |
| `test_first_person_hands` | Malla propia de la mano, falanges articuladas y gesto de interacción |
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
| 2026-11-16 | Tanda completa con cordilleras (shader intermedio) | `measure_performance.tscn` | Carga 1,6–3,7; Cusco 59,4 FPS de mediana (55,6–60,9), por debajo de 60. Se aligera el shader y la escala de Medio baja a 0,68 |
| 2026-11-16 | Medición final de Medio con cordilleras, shader aligerado y escala 0,68 | `measure_performance.tscn` | Carga 1,8–2,7; 3 pasadas; llacta 89,4, paso 93,4, Cusco 63,6, posguerra 97,5, obra 90,5 FPS (mediana); los cinco actos ≥ 60 |
| 2026-11-16 | Medición final del perfil Bajo con el arte nuevo | `measure_performance.tscn` | Carga 1,6–3,8; 3 pasadas; llacta 102,4, paso 102,0, Cusco 74,2, posguerra 124,5, obra 105,3 FPS (mediana); mínimo 73,8 |
| 2026-11-16 | Paletas por acto y guía visual 4.9 | `run_tests.gd`, `test_palette_tuning.gd` y `capture_palettes.tscn` | 121 pruebas, 0 fallos; cinco capturas generadas y revisadas; `ARCO_OK` |
| 2026-11-16 | Sensación de combate 4.11: fases del golpe, parry, hitstop, cámara, telegrafía y fichas | `run_tests.gd`, `test_combat_feel.gd` y `combat_arena_check.gd` | 126 pruebas, 0 fallos; arena 3 enemigos resueltos con ≤ 2 atacantes; `ARCO_OK` |
| 2026-11-15 | Rendimiento por acto, perfil Bajo y Medio | `measure_performance.tscn` | Bajo ≥ 46,6 FPS; Medio 48,4–52,6 FPS |
| 2026-11-16 | Prototipo Quaternius: 4 cuerpos UBC, ropa propia, clips UAL1 y catálogo legacy/quaternius | `run_tests.gd`, `combat_arena_check.gd` y `arc_playthrough.gd -- --visual-set=quaternius` | 130 pruebas, 0 fallos; arena 3 resueltos con ≤ 2 atacantes; `ARCO_OK`; importación sin errores |
| 2026-11-16 | Rendimiento del prototipo Quaternius en llacta y Cusco | `measure_performance.tscn -- --act=llacta.tscn` y `--act=ciudad.tscn` con y sin `--visual-set=quaternius` | Carga 1,2–1,4; llacta 105,4 → 98,3 y Cusco 65,1 → 71,6 FPS; +5/+10 draw calls; ambos > 60 |

| 2026-11-17 | UAL2 compacto y texturas compartidas del prototipo | `run_tests.gd`, `combat_arena_check.gd` y `measure_performance.tscn --visual-set=quaternius` | 130 pruebas, 0 fallos; 11 clips UAL2; GLB 1–1,6 MB; llacta 114,8 y Cusco 73,1 FPS; +5/+8 draw calls |

| 2026-11-17 | Caras Quaternius con textura propia y cejas separadas | `run_tests.gd`, `capture_quaternius.tscn` y `measure_performance.tscn --visual-set=quaternius` | 131 pruebas, 0 fallos; texturas 1024 con rugosidad; 111,0/71,7 FPS con carga 9,5; +2 MB de vídeo |

| 2026-11-17 | Arquetipos andinos de multitud (mujer mayor y hombre joven) | `run_tests.gd`, `capture_quaternius.tscn` y `measure_performance.tscn` (Cusco) | 131 pruebas, 0 fallos; seis modelos y seis caras; Cusco 69,1 FPS con 494 draw calls y 219 MB; +14 draw calls frente al elenco anterior |

| 2026-11-17 | Fusión de estática del Cusco y la llacta | `run_tests.gd`, `capture_quaternius.tscn`, `measure_performance.tscn` y capturas de santuario/mercado | 131 pruebas, 0 fallos; Cusco 343 draw calls (328 legacy) y 233 MB; llacta 297 y 217 MB; presupuesto de 350 cumplido; +8 MB por la geometría fusionada |

| 2026-11-17 | Familia de la llacta con caras y ropa propias | `run_tests.gd`, `capture_quaternius.tscn` y `measure_performance.tscn` | 131 pruebas, 0 fallos; diez modelos y diez caras; llacta 300 draw calls y 209 MB; Cusco 343 y 233 MB |

| 2026-11-17 | Textiles andinos, cuello alto y tupu de metal | `run_tests.gd`, `capture_quaternius.tscn` y `measure_performance.tscn` | 131 pruebas, 0 fallos; diez atlas textiles embebidos; llacta 310 draw calls y 225 MB; Cusco 349 y 245 MB; Cusco a un draw call del presupuesto |
| 2026-11-17 | Quaternius único: todos los papeles y retirada del legado | `run_tests.gd`, `combat_arena_check.gd`, `arc_playthrough.gd`, `capture_quaternius.tscn` y `measure_performance.tscn` | 131 pruebas, 0 fallos; sin bandera; todos los roles con GLB Q; llacta 321 draw calls/222,2 MB y Cusco 413/230,8 MB; Cusco sobre el presupuesto de 350; FPS no concluyentes |
| 2026-11-17 | Rendimiento del Cusco: sombras y LOD de multitud | `scene_audit.gd --breakdown`, `run_tests.gd`, `combat_arena_check.gd`, `arc_playthrough.gd` y `measure_performance.tscn` | 133 pruebas, 0 fallos; multitud del Cusco 173→100 draw calls y pase de sombra 266→140; llacta 248, paso 244, Cusco 288, posguerra 226 y obra 257; los cinco actos bajo 350; Cusco 62,6 FPS de mediana y p1 60,0 con carga 4,3–6,9 (peor p1 54,8) |
| 2026-11-18 | Chaquitaclla del Agricultor en la terraza | `pch_models.py`, `run_tests.gd`, `capture_quaternius.tscn` y `measure_performance.tscn` | 134 pruebas, 0 fallos; `pch_prop_chaquitaclla.glb` de 430 triángulos, 1,48 m y estribo de 22 cm; llacta 249 draw calls/222,2 MB; ficha PCH-037 |
| 2026-11-18 | HijoPuma: búsqueda de base infantil cerrada | Revisión del pack UBC Standard y `run_tests.gd` | 135 pruebas, 0 fallos; el Standard gratuito solo trae los cuerpos Superhero (hombre y mujer); Regular/Teen es Source de pago; se mantiene el Joven Q a 1,20 m y no se mezcla otro set |
| 2026-11-18 | Mano articulada y manto con muelles | `pch_quaternius.py`, `run_tests.gd`, `capture_quaternius.tscn` y `measure_performance.tscn` | 136 pruebas, 0 fallos; diez GLB con 71 huesos (65 UBC + 6 de manto); mano con falanges que se cierran; llacta 249 draw calls/222,3 MB y 101,7 FPS; Cusco 288/230,8 MB y 70,6 FPS |
| 2026-11-18 | Mandíbula de habla | `pch_quaternius.py`, `run_tests.gd` y `capture_quaternius.tscn` | 137 pruebas, 0 fallos; diez GLB con 72 huesos (65 UBC + 6 de manto + 1 mandíbula); la boca se abre con el clip `talk`; sin fonemas, cejas animadas ni parpadeo |
| 2026-11-18 | Parpadeo y cejas | `pch_quaternius.py`, `character_face.gd`, `run_tests.gd` y `capture_quaternius.tscn` | 138 pruebas, 0 fallos; diez GLB con 76 huesos; `Blink_L/R` cierra el párpado y `Brow_L/R` alza la ceja; la multitud parpadea; sin fonemas |
| 2026-11-18 | Revisión general: HUD y puño del arma | `hud.gd`, `hud_text.gd`, `first_person_weapon.gd`, `run_tests.gd`, `capture_quaternius.tscn` y `measure_performance.tscn` | 139 pruebas, 0 fallos; la pista baja de la banda cinematográfica; el texto de la tarjeta de fin espera al fondo oscuro y no deja la pista detrás; la honda y la porra se sostienen con un puño de bloqueo (+9 draw calls en primera persona); Cusco 297, llacta 248 |
| 2026-11-18 | Mano de maniquí en primera persona | `core/player/mannequin_hand.gd`, `first_person_hands.gd`, `first_person_weapon.gd`, `tools/blender_mannequin_forearm.py`, `run_tests.gd`, `combat_arena_check.gd`, `arc_playthrough.gd` y `measure_performance.tscn` | 144 pruebas, 0 fallos; antebrazo UAL1 de 218 vértices y dos superficies; pose abierta y puño, dos mallas por mano; capturas con honda y porra; llacta 221 draw calls/223,3 MB y Cusco 296/231,4 MB; 87,4 y 67,6 FPS de media |
| 2026-11-18 | Retirada del legado UBC | `character_catalog.gd`, `character_face.gd`, `cape_springs.gd`, `quaternius_materials.gd`, `dressed_mannequin.gd`, `shared_assets/characters/quaternius/{base,faces,hair}`, `pch_npc_*`, `tools/build_face_textures.py`, `test_quaternius_characters.gd`, `run_tests.gd`, `combat_arena_check.gd`, `arc_playthrough.gd` y `measure_performance.tscn` | 139 pruebas, 0 fallos; sin cambio de draw calls/memoria; el juego queda solo con maniquíes UAL1; la mano sigue en revisión |
| 2026-11-18 | Elenco de maniquíes integrado | `mannequin_looks.gd`, `character_outfit.gd`, `npc_actor.gd`, `character_model_visual.gd`, `llacta.gd`, `ciudad.gd`, `paso.gd`, `ambush_enemy.gd`, `test_mannequin_cast.gd`, `run_tests.gd`, `combat_arena_check.gd`, `arc_playthrough.gd` y `measure_performance.tscn` | 150 pruebas, 0 fallos; diez looks en llacta/Cusco/paso/chancas, atuendo fusionado por hueso, LOD de multitud y porra del chanca; llacta 257/145,2 MB, paso 270/121,1, Cusco 334/158,5, posguerra 259/145,3 y obra 275/140,2; Cusco 72,9–73,5 FPS y p1 60,0–62,1; UBC legado pendiente de retirada; mano en revisión |
| 2026-11-18 | Diez looks de maniquí | `mannequin_looks.gd`, `tests/mannequin_prototype.gd`, `test_mannequin_prototype.gd` y `run_tests.gd` | 144 pruebas, 0 fallos; diez looks (Curaca, Sisa, Chanca, Anca, Puma, Madre, Hermano, Joven, Anciana, Mensajero), capturas `maniquies_principales.png` y `maniquies_apoyo.png`; sin impacto en partida porque aún no se usan en NPC; pendiente de aprobación e integración; la mano sigue en revisión |
| 2026-11-18 | Prototipo de maniquíes UAL1 | `core/characters/*`, `MannequinLooks`, `OutfitMannequin`, `tools/blender_mannequin_forearm.py`, `tests/scenes/mannequin_prototype.tscn` y `run_tests.gd` | 144 pruebas, 0 fallos; tres looks iniciales (Curaca, Sisa, Chanca), mano de maniquí con antebrazo UAL1 y panel de objetivo arriba a la izquierda; capturas en `documentation/img/prototipo/`; maniquíes aprobados; mano pendiente de revisión; UBC sigue activo |
| 2026-11-18 | Pase visual: casas, llama y tarjetas | `llacta.gd`, `ciudad.gd`, `character_model_visual.gd`, `first_person_weapon.gd`, `first_person_hands.gd`, `hud.gd`, `capture_quaternius.tscn` y `run_tests.gd` | 140 pruebas, 0 fallos; casas de la llacta con `SurfaceMaterials` (piedra, paja y madera); llama por shader; tarjeta del acto IV a 0,80; párrafos en la del III; porra de PNJ oculta a menos de 1,4 m; honda con correa fina; mano de interacción a 0,68 |
| 2026-11-18 | Acto I con objetivos visibles y territorio compuesto: pasos, honda, caminos, manantial, mirador y vivienda coherente | `run_tests.gd`, `llacta_walk_check.gd`, `arc_playthrough.gd`, `combat_arena_check.gd`, `capture_act_one_flow.tscn`, `capture_llacta_tour.tscn` y `measure_performance.tscn` | 141 pruebas, 0 fallos; recorrido de la llacta OK; `ARCO_OK`; arena 3 enemigos con ≤ 2 atacantes; capturas de mañana/honda/encargos y de plaza/manantial/mirador; draw calls 294/270/331/306/315, bajo 350; Cusco 63,8 FPS y p1 60,0 con carga 0,45–0,51 |

Cada entrega añade una fila con el alcance, el comando y el resultado.
