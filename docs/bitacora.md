# Bitácora de cambios

Registro cronológico de los cambios y decisiones del desarrollo. Una fila por entrega, con la fecha; el commit se localiza con `git log` o en el PR.

La bitácora **no es una fuente de verdad**: no crea reglas ni prevalece sobre `docs/00`–`09` ni `AGENTS.md` ([AGENTS.md](../AGENTS.md) §3). Conserva el porqué de lo que se hizo.

Una decisión relevante se anota con su motivación, las alternativas consideradas y sus consecuencias. Los ADR se retiraron el 2026-11-14; su registro histórico vive aquí.

## 2026-11-22 — Preparación de la pasada humana

**Decisión:** antes de la pasada de 3.10 se actualizan el protocolo y el acta para que el responsable pruebe también lo que falló en la revisión, no solo el recorrido feliz.

| Cambio | Detalle |
|---|---|
| Protocolo | `prueba_vertical_slice.md` v1.1: `Esc` abre el menú de pausa; se añaden las regresiones de etapa 2, manta pendiente, victoria y carga, NPC, HUD, escudo, derrota, aturdimiento y build exportado. |
| Acta | `F3-acta-de-cierre.md` 0.10: 131 métodos `test_` en 60 archivos, 31 recorridos en CI, correcciones del PR #54 y la deuda del guardado manual desde la pausa. |
| Medición | Las correcciones no añaden geometría ni draw calls; se mantiene la medición de §2 y no se repitieron las tres pasadas. |
| Pendiente | La pasada humana, la decisión y la firma. No se marca F3 como cerrada. |

## 2026-11-21 — Revisión de la partida: correcciones

**Decisión:** antes de la pasada humana se corrige lo que bloqueaba o ensuciaba la partida, aunque la suite estuviera en verde. La revisión encontró fallos que las pruebas no cubrían porque probaban el editor, no el build, y porque no recorrían la etapa 2 cargada ni la derrota.

| Cambio | Detalle |
|---|---|
| Catálogos en el build | `DialoguePresenter` y `DiscoveryService` usan `ResourceLoader.list_directory`. `DirAccess.get_files_at` devuelve `*.tres.remap` en la exportación y el filtro `.tres` dejaba 0 diálogos y 0 POI. Se prefiere el listado del cargador a recortar el sufijo `.remap` a mano: resuelve también los recursos importados y no depende del formato del pack. |
| Etapa 1 | El reparto del agua ya no cambia al agricultor a la conversación de eco si aún no dio el pedido del maíz; el cambio se aplica cuando lo da. Así no se puede quedar sin `m01_maiz_pedido`. |
| Etapa 2 | La curáca recupera `m01_curaca_partida` cuando la población termina de construirse. `_switch_curaca` se ejecutaba antes de que existieran las definiciones y no se repetía. |
| Carmenca | `m01_victoria` cierra la batalla y el diario; al cargar no se repite la oleada ni se reabre la etapa. |
| NPC | El destino y la posición lógica pasan a ser el centro del cuerpo (0,9 m sobre el suelo), no los pies. El cuerpo deja de quedar medio enterrado y la cápsula de conversación cubre la cabeza. Un NPC dormido recibe ruta al reaparecer. |
| Manta y descubrimientos | Al cargar con la lana entregada se vuelve a ofrecer la manta; el servicio de descubrimientos se resincroniza con `WorldState` después de la carga. |
| HUD y combate | Se limpia el aviso de interacción al perder foco; la munición solo se ve con la honda en la mano; el arma no reaparece al cerrar el diario si estaba desarmada; la batalla empieza con la porra y avisa de las teclas; el clic del escudo suelta el bloqueo; el aturdimiento no adelanta la espera; al caer se vuelve al campamento. |
| Pausa y salto | Esc abre un menú con continuar, volver al título y salir. La acción `jump` existía sin código; ahora despega en el suelo. |
| Guardado | La ranura anterior se aparta como `.bak` antes de renombrar el temporal y `load_slot` la recupera. Los recorridos de integración guardan en `user://test-saves` para no borrar la partida del jugador; antes compartían `user://saves` y la borraban. |
| Pruebas | Se añaden `mission_stage2_check`, `test_resource_catalog`, `test_combat_input`, `test_hud_interaction`, `test_pause_menu`, `test_jump` y la recuperación del respaldo en `test_save_round_trip`. La CI ejecuta la etapa 2. |

**Consecuencias:** las partidas antiguas se corrigen al reaparecer el NPC (el actor sube al centro del cuerpo); no se migra el JSON. Queda **no verificado** la pasada humana de 3.10, Windows y el arranque del binario exportado completo.

## 2026-11-21 — F3.10: cierre preparado

**Decisión:** la fase no se cierra con código escrito sino con una pasada humana y una firma. Se prepara todo lo que no depende del responsable: protocolo cronometrado, medición por sector y perfil, acta y deuda declarada.

| Cambio | Detalle |
|---|---|
| Protocolo | Ocho bloques de 0 a 45 min, del arrabal al estandarte, con registro de bloques e incidencias: `documentation/prueba_vertical_slice.md`. |
| Medición | S1 y la batalla, Medio y Bajo, tres pasadas: 66,4 y 66,7 FPS de mediana en Medio; 61,0 y 61,1 en Bajo; 248–253 draw calls; 190 MB; peor fotograma de 24,0 ms. Todo bajo presupuesto. |
| Escena nueva | `measure_battle.tscn` fuerza la oleada de ocho chancas con seis aliados y muestrea 300 fotogramas. No entra en CI: necesita ventana real para contar draw calls. |
| Fallo corregido | Los chancas se liberaban solos a los 1,4 s de morir y la batalla seguía con la referencia en `_enemies`; al recorrerla, GDScript lanzaba «Trying to assign invalid previously freed instance» cada fotograma. Ahora se quitan de la lista al salir del árbol. `carmenca_check` espera a que uno caiga y se libere. |
| Deuda | Sección nueva en la ficha de F3 con lo que queda para F4: arte, personajes, texturas, audio, equilibrio, animación y perfiles. |
| Acta | `docs/fases/F3-acta-de-cierre.md`, versión 0.9: medición, evidencia, deuda y decisión pendiente de firma. |
| Observación | Bajo mide menos FPS que Medio (61 frente a 66) porque su escala 3D es 0,75 frente a 0,68. Se revisa en F4; ambos cumplen su umbral. |
| Fichas | Se firman PCH-039 (defensa del Cusco), PCH-040 (Chanan Cury Coca), PCH-041 (lecho andino) y PCH-042 (antorcha) como verificadas por el responsable. Quedan PCH-037 y PCH-038, de la llacta y fuera de la slice. |

## 2026-11-21 — F3.9.b: la batalla de Carmenca

**Decisión:** la batalla se resuelve con oleadas authored y un máximo de 8 chancas y 6 aliados, sin ejército simulado. Las obras construidas y la manta cambian el combate.

| Cambio | Detalle |
|---|---|
| Disparo | Etapa 3 y proximidad al campamento (120 m). La captura del estandarte cierra la misión con `m01_victoria`. |
| Oleadas | 4, 6 y 8; cada obra resta un enemigo, hasta dos. Pausa de 4 s entre oleadas. |
| Aliados | Seis vecinos que atacan al chanca más cercano y vuelven junto al jugador. No mueren en la slice. |
| Derrota | Se limpia la oleada, se revive al jugador (nuevo `CharacterState.revive`) y se reinicia la misma oleada. |
| Chanca | Colisiona con el jugador y se detiene a 1,15 m; el director limita a dos atacantes simultáneos. |
| Persistencia | La batalla no se serializa: cargar durante el combate devuelve a la etapa 3. |
| Pruebas | `carmenca_check`: oleadas, obras, aliados, derrota, estandarte, victoria y diario. |

## 2026-11-21 — F3.9.a: el combate del jugador

**Decisión:** el combate de Core ya existía; lo que faltaba era que el mundo lo llevara puesto. Se envuelve en un nodo de jugador y se añade el enemigo chanca, sin ejército simulado.

| Cambio | Detalle |
|---|---|
| Jugador | `PlayerCombat` (Core): estado, combatiente, selección de arma, entrada, rayo de golpe, HUD y daño recibido. Desarmado por defecto; la batalla lo arma. |
| Armas | Honda con 12 piedras, porra y escudo con parry de 0,15 s. |
| Enemigo | `ChancaWarrior`: cápsula con `EnemyCombatant`, se acerca, ataca y cae. |
| Alcance | El mínimo de la honda no se aplica al cuerpo a cuerpo: el rayo toca la superficie del rival y rechazar por cercanía anulaba todos los golpes de porra. |
| Pruebas | `combat_check`: desarme, golpe, daño recibido, escudo y munición. |
| Pendiente | Oleadas, aliados, estandarte y cierre de la misión (3.9.b). |

## 2026-11-21 — F3.8: las obras de defensa

**Decisión:** los fosos se construyen en el mundo y viven en `WorldState.changes`, no en banderas: son modificaciones físicas y la batalla las leerá.

| Cambio | Detalle |
|---|---|
| Puntos | Cuatro, en el anillo oeste y sur del arrabal, sobre los accesos. |
| Requisito | Solo después de decidir quedarse (`m01_queda`); antes el foso se ve pero no responde. |
| Foso abierto | Tierra removida con borde de piedra. Un hueco real no cabe en el blockout sin geometría destructiva. |
| Foso cubierto | Tapa oscura, cinco ramas cruzadas y nueve púas de palma; deja de ser interactuable. |
| Persistencia | `WorldState.changes`; al cargar se reconstruye la geometría desde los cambios guardados. |
| Altura | La tapa se apoya en la esquina más alta y el borde baja hasta la más baja: en ladera no queda al aire. |
| Pruebas | `defense_works_check`: cuatro obras, negativo, construcción, guardado/carga y recuento. |

## 2026-11-21 — F3.6.b: el mirador de Carmenca

**Decisión:** el descubrimiento sin marcador es un lugar real del territorio, no un radio invisible: una apacheta en el camino del oeste, con el campamento chanca a la vista. Se descubre por proximidad y se registra en el diario.

| Cambio | Detalle |
|---|---|
| Lugar | `CarmencaOverlook` en S2: montón de piedras (apacheta) y doce tiendas de campaña a unos 40 m, sobre la ladera. |
| Descubrimiento | POI-31 con radio de 14 m y disparo por proximidad; sin etiqueta ni marcador. |
| Diario | `DiscoveryNotes` escribe una memoria con clasificación N y avisa en el HUD una sola vez; al cargar se reconstruye desde los descubrimientos guardados. |
| Geometría | Se descartó una plataforma: en ladera flotaba y se leía como una mesa. La apacheta apilada es la solución andina y no inventa un edificio. |
| Auditoría | «Apacheta» entra en los elementos apilados a propósito del auditor de flotantes; las tiendas se entierran 0,5 m para que la base no quede al aire en la pendiente. |
| Pruebas | `mirador_check`: sin descubrir antes de llegar, descubierto al llegar, 12 tiendas, memoria, aviso y carga sin duplicar. |

## 2026-11-21 — F3.6.a: el turno del agua y la manta

**Decisión:** las secundarias se construyen como cadenas de banderas con sus grafos y un punto en el mundo, sin sistema de misiones aparte. La consecuencia se lee en el diario y en lo que dicen los vecinos.

| Cambio | Detalle |
|---|---|
| Reparto del agua | Al entregar el agua, la molendera plantea el conflicto con la chacra. Tres desenlaces con bandera, contador de reputación y memoria propia en el diario. |
| Reputación | Se guarda como contador en `WorldState` (`rep_molendera`, `rep_chacra`) porque la hoja de personaje aún no existe; el guardado ya la conserva. |
| Manta | La tejedora la pide al recibir la lana; el telar del taller la teje y la manta se ve colgada. En 3.9 reduce el daño recibido. |
| Orden al cargar | Los diálogos se restauran cuando la población ya está construida: antes, `set_dialogue` no encontraba a quién cambiar. |
| Pendiente | El mirador sobre Carmenca, con su campamento y el descubrimiento sin marcador (3.6.b). |
| Pruebas | `side_activities_check`: dos cadenas, negativo del telar, diario y guardado/carga. |

## 2026-11-21 — La mano de interacción, fuera del centro

**Decisión:** se conserva el gesto de mano al interactuar y se corrige su encuadre. No es código de la campaña retirada: `FirstPersonHands` es la mano del jugador y la usa **todo** interactuable (puertas, lecho, agua, encargos) con `hand_action`.

| Cambio | Detalle |
|---|---|
| Motivo | Con la antorcha de noche, el antebrazo del prototipo (escala 0,52 y centrado) tapaba media pantalla al abrir una puerta. |
| Ajuste | Escala 0,42; reposo y destinos movidos a la derecha y abajo; el gesto entra desde la esquina inferior derecha y el antebrazo sale de cuadro. |
| Alcance | Solo `FirstPersonHands`. La mano del arma no cambia: se alinea en 3.9, cuando el combate la ponga en pantalla. |
| Pruebas | `test_first_person_hands`, `interiors_check`, `city_check` y capturas de día y de noche en puerta y agua. |

## 2026-11-21 — F3.3: la antorcha de mano

**Decisión:** el jugador lleva una antorcha que se enciende sola al caer el sol. Cierra el pendiente anotado el 2026-11-20: de noche no había ninguna fuente de luz y la etapa 2 de la misión ya pide no dormir.

| Cambio | Detalle |
|---|---|
| Antorcha | `PlayerLantern` (Core) bajo la cámara: palo, cabeza de fibra y llama; puño del maniquí sin antebrazo, porque el antebrazo de 1,8 m se comía media pantalla. |
| Luz | `OmniLight3D` de 10 m, 1,55 de energía, cálida y **sin sombras**. Parpadeo del 7 %. |
| Encendido | `DayNightCycle.daylight_at(minute)` es ahora la única fórmula de luz diurna: la usan el sol y la antorcha. Nivel 0 con sol y subida gradual por debajo de 0,22 de luz. |
| Pruebas | `lantern_check`: apagada a mediodía, encendida a las 22:00, sin saltos al atardecer y apagada otra vez al volver el día. |
| Histórico | PCH-042, clasificación R: la tea de mano no tiene cita propia; se apoya en el fuego doméstico de PCH-027 y PCH-007. |

## 2026-11-21 — F3.5.b: la misión principal

**Decisión:** la misión de la ciudad se construye con recursos de etapa y banderas de `WorldState`, sin motor genérico, como pide la ficha.

| Cambio | Detalle |
|---|---|
| Etapas | `MissionDefinition`/`MissionStage` en `data/missions/`: tres etapas y sus banderas. `MissionController` avanza cuando están todas. |
| Etapa 1 | Agua, lana y maíz: se aceptan en diálogo y se cumplen en un punto del mundo (`FlagInteractable`), no por código. |
| Etapa 2 | Columna authored de siete cápsulas que abandona la ciudad hacia el oeste; la curáca cambia de conversación; quedarse fija `m01_queda`. |
| Etapa 3 | Fase `guerra` y bandera `m01_victoria`, que la batalla de 3.9 usará para cerrar la misión. |
| Persistencia | La etapa se guarda en `WorldState`; el diario se reconstruye al cargar. |
| Diario | Título «Diario», textos largos con salto de línea y encargos cumplidos marcados «· hecho». El CSV de la campaña necesitaba comillas en los textos con comas: sin ellas se cortaban. |
| Pruebas | `mission_check`: tres etapas, puntos del mundo, partida, fase, guardado y carga. |

## 2026-11-21 — F3.5.a: conversación y diario en el mundo

**Decisión:** el mundo de la slice gana HUD, conversaciones y diario; la misión principal (3.5.b) se apoya en ellos.

| Cambio | Detalle |
|---|---|
| HUD | `core/ui/hud.tscn` se instancia bajo un `CanvasLayer` en `RegionWorld`: retícula, interacción, aliento, diálogo y diario. Hasta ahora el mundo no tenía interfaz. |
| Diálogo | `DialoguePresenter` conecta el `DialogueRunner` con el HUD y con `WorldState`: siembra las banderas al empezar, escribe las que fijan los efectos y bloquea los controles. Los grafos viven en `data/dialogues/`. |
| NPC | `NpcInteractable` en los NPC con `dialogue_id`, en la capa `interactable`; el jugador ve «Hablar · Chanan Cury Coca» al enfocar. Sin etiquetas flotantes de nombre. |
| Diario | Se abre y cierra con **J**; Esc también cierra. El jugador queda inmóvil y el puntero se libera. |
| Encuadre | `NpcSimActor.focus_point()`: el actor vive en el centro del cuerpo, no en los pies; sin él la cámara apuntaba 0,75 m por encima de la cabeza. |
| Pendiente | Contenido de la misión: encargos, partida de Viracocha y etapas (3.5.b). |

## 2026-11-20 — F3.1: el santuario del sol, al sur de la plaza

**Decisión:** mover el santuario del sol del Cusco del norte al sur de la plaza, que es donde está en la ciudad real.

| Cambio | Detalle |
|---|---|
| Posición | Centro local `(0, 86)`: 86 m al sur de la plaza, comprimido y declarado. La columna `x = 0` no tiene casas, así que no se quitó ninguna: siguen 38. |
| Terraza | La ladera sur obligaba a un basamento de 6,5 m con la plataforma de 30 m de fondo, que tapaba el recinto. Se rehace como terraza de 38 × 12 m con escalinata de 30° medida contra el terreno y un recinto que sobresale del muro. |
| Piedra | La plataforma pasa de dorada a piedra: en 1438 el santuario es modesto y el «recinto de oro» es la obra posterior (PCH-027). El recinto interior conserva el color sagrado. |
| Nombre | Rótulo «Santuario del Sol»; «Coricancha» se reserva para la obra posterior. POI-18 y el ancla `coricancha` de los NPC se mueven con el edificio. |
| Código | `CuscoSanctuary` en su propio script: `CuscoBlockout` llegaba al límite de 400 líneas. |
| Pruebas | `CUSCO_OK` (38 casas, 7 POI), `CITY_OK`, `POPULATION_OK`, `SAVE_ROUND_TRIP_OK`, `WALKTHROUGH_OK`, auditoría sin flotantes. |

## 2026-11-20 — F3.7: descanso y guardado

**Decisión:** dormir en la casa del jugador avanza el día y guarda la partida en la ranura automática; el título ofrece «Continuar».

| Cambio | Detalle |
|---|---|
| Descanso | `RestCycle` despierta a las **8:00**, la misma hora con la que empieza la partida: a las 7:00 el ciclo todavía deja la ciudad en penumbra y el jugador creía que seguía de noche. |
| Lecho | `SleepSpotInteractable` en el interior de la casa del jugador; el resto de lechos se ven pero no se usan. Pide el descanso al nodo del grupo `campaign_session`, sin que Core conozca la campaña. |
| Guardado | `CampaignSession` compone posición, orientación, estado de campaña y la instantánea de los NPC con nombre, y lo escribe con `SaveManager` en la ranura `auto`. |
| Interior | Antes de guardar se sale de la sala de bolsillo: vive 400 m bajo el terreno y no sobrevive al cierre. La posición guardada es la de la puerta, así seguir jugando y cargar coinciden. |
| Carga | «Continuar» en el título deja una carga pendiente que la escena de campaña consume al arrancar; «Comenzar» la cancela y reinicia mundo, reloj y banderas. |
| Servicios | `WorldStateService`, `CampaignStateService`, `SessionLogService` y `SaveManagerService` ganan `instance()`, y las escenas dejan de depender de los identificadores de autoload, que no se resuelven cuando un `--script` las compila como dependencia. |
| Pruebas | `test_rest_cycle` y `city_save_round_trip`, que duerme, cierra la instancia del mundo, la vuelve a levantar y comprueba hora, 8 NPC, misión, inventario y obras. |
| Lecho andino | La cama con patas y colchón era anacrónica. Se sustituye por el poyo bajo de piedra con estera y manta de **PCH-041** (A: patanas de Ankasmarka de 0,30–0,80 m usadas como lecho; bancos-lecho en residencias incas de Cerro Azul. R: estera y manta). La puerta de la casa del jugador lleva «Tu casa» para distinguirla de la de la curáca. |
| Etiquetas | El modo de revisión ocultaba todas las `Label3D` de los sectores: las puertas nunca mostraban «Entrar». Ahora solo oculta las de POI (grupo `review_label`); las de interacción se ven siempre. Además, la leyenda se separa 0,28 m del panel, donde quedaba embebida y tampoco se veía. |
| Ejes | Se declara la orientación del mundo en el expediente geográfico: −X oeste, +X este, −Z norte, +Z sur. El comentario del arrabal decía «suroeste» pero sus coordenadas son al oeste. |
| Pendiente | Misión (3.5) e inventario (3.6) escribirán en `CampaignState`; hoy el canal está probado con datos de esa forma. Las obras usarán `WorldState.set_change` (3.8). |

## 2026-11-20 — F3.4: población de la ciudad

**Decisión:** 24 NPC en S1 con rutinas de mañana, tarde y noche, sobre el director y el horario que ya existían de F1.

| Cambio | Detalle |
|---|---|
| Población | `CityPopulation`: 8 NPC nombrados (entre ellos Chanan Cury Coca) y 16 de ambiente, con casa, ancla de mañana y de tarde. |
| Sistema | Reutiliza `NpcDirector` y `NpcDefinition` de Core; los datos viven en una tabla de campaña que pasará a `.tres` cuando exista el pipeline de contenido. |
| Anclas | Once anclas (plaza, mercado, Coricancha, taller, depósitos, ayllus, arrabal, camino oeste y puerta sur), con holgura respecto de las casas. |
| Navmesh | Intento de tallar las 38 casas en el navmesh de S1 con obstáculos proyectados: desconectaba los enlaces entre sectores y el recorrido regional caía de 2.758 m a 1.192 m. Se retiró; la prueba de población comprueba que nadie acaba dentro de una casa. |
| Enlaces | La espera de enlaces de sector sube de 1 a 10 segundos: con el horneado más lento no se creaban. Se conserva aunque el tallado se haya retirado. |
| Pruebas | `city_population_check`: 24 registrados, 8 nombrados, cambio de ancla entre mañana y noche y 20 min simulados con 0 NPC dentro de casas. Añadido a CI. |
| Hora de inicio | La partida empezaba a las 6:00 y con el ciclo nuevo eso es amanecer a oscuras: parecía de noche. `WorldClock` arranca a las **8:00** y `_ready()` aplica `start_minute` (antes la variable quedaba en la constante 360). `day_night_check` comprueba que a las 8:00 el sol está alto. |
| Pendiente | Rutinas con actividades visibles (trabajo, conversación), nombres inventados por confirmar y paso de la tabla a recursos de contenido. |

## 2026-11-20 — F3.3: ciclo día/noche

**Decisión:** el reloj del mundo mueve la luz. A mediodía se conservan exactamente los valores del blockout aprobado, para que la revisión diurna no cambie.

| Cambio | Detalle |
|---|---|
| Sistema | `DayNightCycle` en `core/world`: elevación y azimut del sol, energía y color, ambiente, niebla y relleno, todo derivado de `WorldClock`. |
| Franjas | Amanecer cálido con horizonte encendido, mediodía neutro, atardecer cálido y noche azul oscura con 0,35 de ambiente. |
| Corrección | La energía del sol entra con rampa suave desde el horizonte; con la curva anterior saltaba 0,26 en quince minutos y la prueba lo detectó. |
| Pruebas | `day_night_check`: 96 muestras cada 15 minutos sin saltos mayores de 0,30, noche sin sol y ambiente menor que al mediodía. Añadido a CI. |
| Evidencia | `build/evidencia/day_dawn.png`, `day_noon.png`, `day_dusk.png` y `day_night.png`. |
| Pendiente | Prueba humana de las cuatro franjas. De noche no hay luz de mano: si se juega de noche, hace falta una fuente de luz en 3.4 o 3.7. |

## 2026-11-20 — F3.2: tres interiores transitables

**Decisión:** los interiores se resuelven con una **sala de bolsillo**: se instancia a la misma XZ de la puerta y 400 m por debajo del terreno, así el streaming no cambia de celda y el mundo sigue vivo detrás.

| Cambio | Detalle |
|---|---|
| Sala | `InteriorRoom` en `core/world`: 8 × 6 × 3 m, muros, techo, suelo, luz propia y tres vestidos: casa del jugador (cama, fogón, cántaros), casa de la curáca (telar, mantas, banco) y taller (dos telares, lana). |
| Puerto | `InteriorDoor` extiende `Interactable`: marco, panel, colisionador y etiqueta «Entrar»/«Salir» con `tr()`. Claves nuevas `PCH_ENTER` y `PCH_EXIT`. |
| Control | `InteriorController`: guarda posición y rumbo de vuelta, instancia la sala, teletransporta al jugador y lo devuelve exacto. Sin pantallas de carga. |
| Puertas | Arrabal: casa del jugador (-88, -118) y casa de Chanan Cury Coca (-136, -118). Ciudad: taller textil (60, -53). |
| Pruebas | `interiors_check`: 3 puertas, vestidos `home`/`authority`/`workshop`, sala a más de 100 m por debajo y vuelta a menos de 2 m. Añadido a CI. |
| Pendiente | Prueba humana de los tres interiores y vestido más rico cuando haya arte. |

## 2026-11-20 — F3.1: ciudad habitable

**Decisión:** la partida empieza en el Cusco, en el arrabal de Chocos-chacona, tal como fija el rediseño de la campaña.

| Cambio | Detalle |
|---|---|
| Arrabal | Plaza de 13 m, 10 casas, callejón de 4 m al camino de entrada y pirca de borde con abertura al oeste, en el cuadrante suroeste de S1, que estaba vacío por diseño. |
| Aparición | `region_world` deja el camino de la llacta y aparece en la plaza del arrabal (1088, 294), mirando a la plaza del Cusco. |
| Pruebas | `city_check` nuevo: 10 casas de arrabal, aparición a 0 m del centro, 154 m a la plaza y jugador en el suelo. `region_player_check` pasa a medir la salida del arrabal hacia la ciudad (35 m y 45 m ganados a la plaza). `cusco_blockout_check` sube a 38 casas. |
| Medición | 314 mallas y 0 flotantes en la auditoría; 234 draw calls, 184,9 MB y 69,3 FPS de media (p1 68,6) en `measure_cusco`, perfil Medio a 1080p. |
| Consecuencia | La llacta deja de ser el punto de partida: es la comunidad a la que se viaja en la fase 3. |
| Pendiente | Prueba humana del arrabal (recorrido a pie) y los interiores de 3.2. |

## 2026-11-20 — Ficha de la vertical slice (F3)

**Decisión:** la F3 se acota a las fases 1 y 2 de la campaña —la ciudad que se queda y Carmenca— y se escribe como diez tareas con criterio propio.

| Cambio | Detalle |
|---|---|
| Alcance | S1 Cusco jugable (arrabal, plaza y Coricancha), tres interiores, 24 NPC con 8 nombrados, día/noche, misión de tres etapas, dos secundarias, un descubrimiento, defensa persistente y Carmenca con tres oleadas. |
| Fuera | La embajada a la llacta (fase 3), Xaquixaguana (fase 4) y el epílogo político pasan a F4. |
| Decisiones del responsable | Batalla completa en la slice; armas honda y porra; ciudad limitada a arrabal, plaza y Coricancha; interiores: casa del jugador, casa de la curáca y taller. |
| Orden | Ciudad → interiores → día/noche → descanso y guardado → población → misión → secundarias → defensa → batalla → cierre. |
| Recorte | Si no cabe: secundarias, luego NPC a 16, luego un solo interior, luego una oleada. Nunca se recorta el guardado ni la misión. |
| Presupuesto | ≤ 350 draw calls, ≤ 250 MB, 60 FPS Medio / 30 Bajo, hitch < 50 ms, carga < 150 ms; ≤ 15 draw calls por interior. |
| Consecuencia | `docs/05` pasa F3 a «en curso» con enlace a la ficha y `AGENTS.md` apunta a ella. `docs/06` fija las pruebas previstas de la slice. |
| Riesgo | La IA de oleadas y el crecimiento de S1 son los dos costes altos; la ficha los declara con mitigación. |
| Siguiente | Tarea 3.1, ciudad habitable: arrabal, aparición y acceso a Carmenca. |

## 2026-11-20 — Rediseño de la campaña 01: la ciudad que se queda

**Decisión:** la campaña se centra en el Cusco. El protagonista vive en el arrabal de Chocos-chacona, ayllus de Chaco y Chacona, es varón de 19–20 años y se queda con los pocos que no abandonan la ciudad. La estructura pasa a cuatro fases —la ciudad que se queda, Carmenca, los emisarios y Xaquixaguana— más un epílogo político.

| Cambio | Detalle |
|---|---|
| Motivo | El protagonista anterior acudía al llamado desde una llacta y la campaña ponía el hogar fuera del hecho histórico. Las fuentes permiten algo más fuerte: la ciudad se queda sola y un vecino del arrabal que resistió es testigo directo del mando, sin suplantar a ningún histórico. |
| Fuentes | Betanzos (cap. VIII) y Cieza (cap. XLV) sitúan el campamento chanca en **Carmenca**, sobre la ciudad, con fosos de piedra y púas de palma; Sarmiento (caps. XXVI–XXVIII) aporta las cuatro direcciones, el arrabal de Chocos-chacona, a Chanan Cury Coca y la edad de Cusi Yupanqui («a lad of 20 or 22 years»). Se leyó la edición de 1880 de Betanzos y Cieza en archive.org, porque Gutenberg estaba en mantenimiento. |
| Fichas | Se añaden PCH-039 (geografía y desarrollo de la defensa) y PCH-040 (Chanan Cury Coca). Ambas quedan pendientes de firma del responsable. |
| Edad | 19–20 años. No hay dato sobre la edad de los comuneros; se apoya en la del propio Cusi Yupanqui en la crónica. |
| Sector S1 | Pasa a ser hogar y hub, no lugar visitado. Crece en importancia y en contenido: arrabal, entradas y defensa. |
| Sector S2 | Aloja Carmenca, Cusi-pampa y los fosos. |
| Sector S3 | Deja de ser el hogar: es la comunidad vecina a la que se pide ayuda y que después se suma al vencedor. |
| Sector S6 | Deja de ser «frontera» genérica y pasa a ser la segunda batalla al oeste. |
| Alternativas | (a) Mantener el hogar en la llacta: rechazada por alejar al jugador del hecho central. (b) Dejar la segunda batalla como noticia: rechazada porque dejaba sin función media región y sin cierre político. |
| No verificado | Firma del responsable en PCH-039 y PCH-040. El lugar exacto de la segunda batalla (Xaquixaguana en Betanzos; Ichu-pampa en Sarmiento) se elige al construir la fase y se declara. |
| Siguiente | Ficha de la vertical slice (F3) con las funciones nuevas de los sectores. |

## 2026-11-20 — Borrado de la campaña lineal

**Decisión:** se borra del repositorio la campaña lineal completa: escenas, scripts, recursos, pruebas, guiones y rastro en textos. Solo queda el **contexto histórico** y el territorio de F2. Nada se archiva en el árbol; el historial de git es el archivo.

| Cambio | Detalle |
|---|---|
| Escenas y recursos | Cinco escenas de acto, seis escenas de apoyo, cinco paletas y el recurso de *slice*. |
| Scripts | 26 de campaña (directores, generadores de acto, vegetación, muros, materiales, lotes, honda, emboscada, audio, personajes, progreso, interacciones) y el motor de actos de `core/systems/slice`. |
| Núcleo | `QuestTracker` sale del HUD y `IntroCards` desaparece: eran guía por marcador y tarjetas del acto I. |
| Pruebas | 44 archivos, entre pruebas unitarias, recorridos y capturas; la suite pasa de 168 a 113 casos y el inventario de CI se actualiza. |
| Textos | La tabla de localización se reduce de 403 a 5 claves: nombres, diálogos, banderas y avisos de la trama. `test_localization_tables` comprueba que no vuelven. |
| Nombres | «Llacta de Rumi» pasa a «Llacta del valle» y «Casa de Rumi» a «Casa de la familia», porque el protagonista que les daba nombre ya no existe. Es un nombre provisional. |
| Herramientas | Se retiran las de tráiler, que grababan los actos. `scene_audit` apunta a `region_world`. |
| Documentos | Biblia, guion, guion de escenas, checklist, guía visual, prototipo de maniquí, personajes Quaternius, reestructuración narrativa, plan de tráiler y ficha de F4-L. `docs/09`, `docs/12` y `docs/06` se reducen a contexto histórico y a las pruebas vigentes. |
| Consecuencia | El juego arranca en `region_world` y no queda ninguna referencia a actos, paletas, guiones ni elenco anterior en `res://`. La campaña se repiensa desde el contexto histórico. |
| Validación | Importación limpia; 113 pruebas, 0 fallos; seis sectores con sus comprobaciones; `REGION_OK`, `ROUTES_OK`; auditoría 280 mallas, 0 flotantes; exportación Linux y arranque headless; captura del blockout de S3 igual que antes; 0 enlaces rotos. |
| Riesgo | Los nombres provisionales («Llacta del valle», «El despertar del Sol») se confirman o se cambian cuando la campaña rediseñada fije su toponimia. |

## 2026-11-20 — Retirada de la campaña lineal

**Decisión:** la campaña lineal y su trama inventada se retiran del repositorio. El punto de partida para repensar la campaña 01 es el **contexto histórico**: fichas PCH, expediente histórico, expediente geográfico y fuentes. La retirada efectiva del contenido va en un PR posterior; este registra la decisión y corta el arranque lineal.

| Cambio | Detalle |
|---|---|
| Motivo | La versión lineal se había conservado como «banco de pruebas» por una decisión registrada en F0 (docs/14 §7: «congelar, no borrar»). El responsable aclara que su instrucción era empezar de cero con el contexto histórico: la trama, el elenco y las quince misiones no debían sobrevivir a la redefinición. |
| Arranque | `campaign.tres` deja de apuntar a `llacta.tscn` (acto I lineal) y apunta a `region_world.tscn`. El botón Comenzar ya no abre la campaña vieja; el blockout se declara banco de pruebas, no partida. |
| Fuentes de verdad | `AGENTS.md`, `docs/05`, `docs/12`, `docs/14`, `docs/15`, `README` y la documentación de campaña dejan de decir «congelada» o «banco de pruebas» y pasan a «retirada». Las fichas de F0 y F4-L quedan como historial con aviso de la decisión posterior. |
| Alternativas | (a) Mantener la campaña lineal congelada: rechazada, es lo que provocó que se citara como canon y se propusieran sus misiones como si siguieran vigentes. (b) Borrar solo el código y conservar la trama como referencia: rechazada, porque la trama inventada condiciona el rediseño. |
| Consecuencias | La retirada de escenas, scripts, pruebas y documentos de trama va en un segundo PR: 5 escenas de acto, directores y `ciudad.gd`/`llacta.gd`/`paso.gd`, ~25 pruebas lineales y los guiones. Se conservan las fichas históricas, los expedientes geográficos, el territorio de F2 y los sistemas de `core/` que sirven al mundo abierto. Todo lo retirado queda recuperable en el historial de git. |
| Orden de F3 | Cambia: (1) retirar lo lineal, (2) revisar el contexto histórico, (3) repensar la campaña, (4) escribir la ficha de la vertical slice. |
| No verificado | Qué parte del elenco inventado se descarta por completo y cuál, si alguna, se rediseña: se decide al repensar la campaña con el contexto histórico delante. |

## 2026-11-20 — Cierre de la F2: aprobada con cambios

**Decisión:** se cierra la F2 con el veredicto **aprobada con cambios** del responsable, tras recorrer a pie la ruta A del [protocolo de blockout](../campaigns/01_pachacutec/documentation/mundo/prueba_blockout.md).

| Cambio | Detalle |
|---|---|
| Veredicto | F2 cerrada el 2026-11-20. Los bloqueantes de la revisión humana (marcador de S2 atravesable, Coricancha hundido y sin colisión, corral y muros flotantes, río sin agua, R7 como camino falso, acequia del Cusco bajo una casa) están corregidos y cubiertos por prueba. |
| Motivación | No quedan bloqueantes conocidos y la fase ya cumplía sus criterios con evidencia automatizada; mantener F2 abierta solo retrasaba F3 sin aportar criterio nuevo. |
| Alternativas | (a) Cerrar como aprobada sin reservas: rechazada, ocultaría que la ruta oeste no se recorrió a pie. (b) Mantener F2 abierta hasta la prueba humana del oeste: rechazada, porque S4–S6 no tienen bloqueantes conocidos y su contenido pertenece a una fase posterior. |
| Consecuencias | `docs/05`, la ficha de F2, `README`, `AGENTS`, `docs/12`, `docs/13` y `docs/15` pasan a F2 cerrada y F3 en preparación. F3 queda activa con la ficha de alcance como primer entregable; no se construye contenido de la slice hasta aprobarla. |
| No verificado | Ruta oeste (S4–S6) solo con recorrido automatizado; contenido de S4–S6; parpadeo de aristas al caminar (head bob + FXAA con render al 68 %); muestreo de 4 m del terreno (F3 prevé 1 m local); adopción definitiva de Terrain3D/Cyclops. |
| Siguiente | Ficha de la vertical slice con territorio, contenido, sistemas nuevos (día/noche, descanso, interiores), presupuesto y orden de trabajo. El tema de la misión principal queda como propuesta a revisar por el responsable, no como decisión tomada. |

## 2026-11-20 — F2.9: mundo caminable y protocolo de prueba humana

| Cambio | Detalle |
|---|---|
| Jugador a pie | `region_world` instancia `player_fps.tscn` en R1, con colisión dinámica de Terrain3D, streaming y descubrimiento siguiendo al jugador, rescate a 120 m de caída y sin manos ni arma. `region_player_check` recorre 9,2 m, comprueba la colisión y sigue hasta el borde de la plaza (12,0 m del centro). |
| Correcciones de la primera pasada | El punto de aparición estaba detrás de la casa de 15° y la marcha recta chocaba con ella; se movió a R1 (352,9, 28,3), entre las casas de 15° y 65°, con rumbo 62°. La cinta de ruta estaba a 0,8 m y tapaba la vista; bajó a 0,15 m. La plaza era un cilindro macizo de 0,8 m sin colisión y la cámara quedaba dentro; pasó a una losa de 0,12 m. |
| Protocolo humano | Se añade `campaigns/01_pachacutec/documentation/mundo/prueba_blockout.md` con rutas A (20–30 min) y B (30–40 min), checkpoints por sector, qué mirar, registro de incidencias y veredicto. Se enlaza desde la ficha de F2, la guía de mundo, docs/06 y docs/13. |
| Coherencia de estado | README, docs/15, docs/05, docs/13 y la ficha de F1 dejan de decir que F1 está en curso o que los addons no se han adoptado: F1 cerrada, F2 en curso y adopción provisional de Terrain3D 1.1.0 y Cyclops 1.5.2. Se fusionan los dos párrafos duplicados de blockout de F2.4 en docs/13. |
| Entorno de revisión | La escena regional tenía cielo casi negro, Terrain3D con damero por falta de assets y sol sin sombras. Se añaden cielo físico, ambiente neutro, sol con sombras, relleno frío sin sombra, bruma suave y dos texturas planas de blockout (pradera/roca) para el autoshader. Las casas bajan el cimiento hasta la esquina más baja de su huella y la plaza es una malla circular que sigue el terreno: un disco plano a la altura del centro flotaba sobre la ladera y el jugador pasaba por debajo. `region_player_check` comprueba que el jugador no queda bajo la plaza. Sigue siendo blockout, no arte final. |
| Camino apoyado en el terreno | Las cintas heredaban la altura del centro en ambos bordes y usaban `get_height`, el dato de la heightmap, no la superficie interpolada; en laderas transversales el borde cuesta abajo flotaba hasta 4 m. Cada borde se muestrea ahora con `get_surface_height`, el paso baja de 3,0 a 1,5 m y `route_network_check` revisa los 9.914 vértices: hueco máximo 0,15 m. `path_frontera` queda en 2.026 m y el recorrido regional sigue en 2.758 m. |
| Coricancha y orientación | El Coricancha se apoyaba en la altura del centro y la ladera lo enterraba por un lado; pasa a la cota más alta de su huella (+0,2 m) y la caja se extiende hasta el terreno, con lo que se lee como plataforma. La plataforma gana colisión y una rampa de acceso desde la plaza. Los conos de sector se ocultan en primera persona: el de S2 tapaba el camino y se podía atravesar. `region_player_check` comprueba que el marcador de S2 esté oculto con el jugador a pie. El protocolo de prueba humana sube a 0.2: plaza de la llacta como centro, cuesta abajo = Cusco, cuesta arriba = quebrada/paso/frontera, `H` para el POI cercano y `T` para la vista cenital. Incluye mapa de bolsillo y sección «si te pierdes». |
| Acequia del Cusco | La acequia urbana pasaba por `z ≈ 45` y atravesaba la casa de `(45, 45)`. Se mueve al corredor entre la plaza y la fila de casas (`z ≈ 30–36`). `CuscoBlockout` y `LlactaBlockout` exponen posiciones de casas y puntos de acequia; sus pruebas exigen ≥ 5 m de holgura y fallan si una canalización cruza una vivienda. |
| R7 como acequia | `CampaignRoute` gana `surface` (`path`/`water`). R7 se declara agua y se pinta azul, de 1,5 m, sin sombra; R1 y R3 siguen siendo los dos caminos marrones que llegan a Cusco. `route_network_check` comprueba que R1/R3 terminan en la plaza y que R7 termina antes, en el río. |
| Río regional y acequias | El cauce del río estaba excavado en el heightmap pero sin agua; solo se veían las acequias de 1,4 m como líneas azules. `CampaignRegion._build_water()` añade un río plano de 9 m con ribera de 15 m, y las acequias de S3/S1 pasan a 2,4 m. `region_terrain_check` comprueba ancho, longitud y cota entre orillas; la auditoría incluye `Rio`/`Ribera` y sigue en 280 mallas, 0 flotantes. |
| Auditoría de flotantes | Se añade `tools/blockout_float_audit.gd`: carga los seis sectores, compara 280 mallas con `get_surface_height` y clasifica por `blockout_kind`. Se corrigen los discos planos de nieve, bofedal, poza y plaza del Cusco con `add_terrain_disk`; las cintas locales de S3/S1/S5 con muestreo por borde; las terrazas de S4 y los cimientos de casas de S1/S3 con la altura mínima de su huella; y los postes de telar con su propia altura. La auditoría no exime techos por nombre: comprueba apoyo real con solape XZ y tolerancia de 0,35 m. Eso detectó el techo del refugio de S5, que estaba 0,5 m sobre las pircas; las pircas suben a 1,8 m y el techo se apoya en su remate. `add_box` extiende además las cajas hacia abajo hasta el terreno, salvo techos, toldos, vigas y casas con cimiento; el corral de llamas y los muros largos dejan de flotar sin añadir mallas. Resultado: `TOTAL meshes=280 floating=0`. El script corre en CI y falla si vuelve un flotante o un elemento sin apoyo. |
| Validación | Importación limpia; suite completa con 168 pruebas y 0 fallos; `region_player_check` OK; `region_walkthrough_check` OK (2.758 m, 23 min, seis sectores, ocho POI); exportación Linux de 130 MB y arranque headless sin errores ni advertencias de `res://`; enlaces relativos de los documentos tocados, 0 rotos; `gdlint`/`gdformat` de los dos archivos nuevos, limpios. |
| Evidencia | `build/evidencia/region_player.png` (aparición en R1) y `region_player_plaza.png` (camino y plaza tras 15 s). Son capturas de trabajo; las aprobadas se copiarán a `documentation/img/f2_blockout/`. |
| Pendiente | Prueba humana de 20–30 min y veredicto del responsable; arte, NPC, interiores y combate de mundo; revisión definitiva de la adopción de Terrain3D/Cyclops con el sector real. |

## 2026-11-19 — Cierre documental de la F0

**Decisión:** se cierra la F0 con las recomendaciones aprobadas por el responsable.

| Decisión | Valor |
|---|---|
| Duración | 6–8 h de historia principal; 8–12 h con contenido secundario |
| Región | 2–4 km² de área densa; hasta ~8 km² con wilderness |
| Portada | Cuatro campañas visibles; solo la 01 jugable hasta su fase |
| Campaña III | Ayacucho–Huanta–Cangallo como hipótesis principal, sujeta a expediente |
| Campaña IV | Mantaro; Huamachuco como epílogo narrado o secuencia final |
| Addons | Spikes de Terrain3D y Cyclops, no adopción definitiva |

**Cambios documentales:**

- `docs/09` se reescribe como biblia de mundo abierto: cuatro campañas, fases, reglas de guion y criterios de rigor.
- `docs/11` cierra el GDD: decisiones, accesibilidad, contenido por fase, guardado, pantallas, audio y vertical slice.
- `docs/12` desarrolla las cuatro campañas a nivel regional: lugares, historia principal, contenido no principal y riesgos.
- El dossier de la región Pachacútec se completa con rutas, 30 POI, 25 experiencias de exploración y clasificación GD/GR/GN.
- `docs/01`, `docs/05`, `docs/15`, `README` y `AGENTS` reflejan la F0 cerrada y F1 como siguiente fase.

**Consecuencias:** la F0 queda cerrada; la F1 no se abre hasta que el responsable lo indique. No se toca código, escenas ni assets en este cierre.

## 2026-11-19 — Giro a mundo abierto regional

**Decisión:** *Memorias del Perú* deja de ser una sucesión de escenas históricas lineales y pasa a ser una antología de cuatro RPG históricos de **mundo abierto regional**. Cada campaña tendrá una región continua con 2–4 km² de área densa (hasta ~8 km² con wilderness), vida cotidiana, NPC con rutinas, misiones principales y secundarias, descubrimientos y persistencia. La campaña 01 conserva la historia, el elenco y el registro histórico, pero los cinco actos se viven como fases del mismo territorio.

**Motivación:** la dirección lineal no satisfacía el objetivo de producto. El jugador recorría escenarios, no habitaba un lugar; los NPC existían solo mientras la escena estaba cargada; las decisiones se leían en la escena siguiente; no había guardado, navegación, reloj ni descubrimientos. La historia y el rigor histórico sí funcionaban y se conservan.

**Alternativas consideradas:**

1. **Ampliar los mapas actuales** y mantener los cinco actos como cinco zonas. Se descartó: produce cinco lugares desconectados y no resuelve la vida cotidiana, la persistencia ni la exploración.
2. **Mundo abierto de escala nacional** (decenas de km²). Se descartó: inviable para un equipo pequeño y para la GPU integrada; favorece mapas vacíos.
3. **Mundo abierto regional con densidad** (elegida): 2–4 km², una comunidad principal, varios núcleos, rutinas, contenido no principal y fases históricas. Permite un producto viable y medible.

**Consecuencias:**

- Se congelan **F4-L y F5-L** (las fases lineales); no se cierran ni se continúan. Su contenido queda como historial y banco de pruebas.
- Se abre **F0 — Redefinición a mundo abierto (documentación)**. Después vienen F1 (spikes), F2 (geografía y blockout), F3 (vertical slice), F4 (producción de la campaña 01), F5 (cierre) y F6 (campañas II–IV).
- La arquitectura cambia: entran `WorldClock`, `WorldState`, `SaveManager`, `ContentRegistry`, `SectorStreamer`, `NpcDirector`, `QuestDirector`, `WorldEventDirector`, navegación y datos por recursos.
- El inventario de campaña pasa a 16 huecos + 3 equipados + almacenamiento; el de 8 huecos queda como historial lineal.
- La duración objetivo pasa de 40–50 min a 6–8 h de historia principal.
- Se propone Terrain3D 1.1.0 y Cyclops 1.5.2 como candidatos, no adoptados; su adopción depende de F1.
- La geografía se clasifica con GD/GR/GN. La región de la campaña 01 es una hipótesis: Cusco preimperial, llacta ficticia, quebrada, paso y frontera chanca, con distancias comprimidas declaradas.
- Las campañas II–IV quedan como concepto y región propuesta; no se construyen hasta que la 01 esté cerrada.

**Documentos:** [docs/01](../docs/01_vision_y_alcance.md), [docs/02](../docs/02_arquitectura.md), [docs/05](../docs/05_plan_de_implementacion.md), [docs/06](../docs/06_estrategia_de_pruebas.md), [docs/07](../docs/07_convenciones_historicas.md), [docs/08](../docs/08_entorno_y_rendimiento.md), [docs/09](../docs/09_biblia_narrativa.md), [docs/10](../docs/10_plantilla_guion_de_escena.md), [docs/11](../docs/11_diseno_de_mundo.md), [docs/12](../docs/12_campanas.md), [docs/13](../docs/13_pipeline_de_escenarios.md), [docs/14](../docs/14_auditoria_y_migracion.md), [docs/15](../docs/15_resumen_de_la_redefinicion.md), [ficha de F0](../docs/fases/F0-redefinicion-mundo-abierto.md) y [dossier de región](../campaigns/01_pachacutec/documentation/mundo/README.md).

### F1.1–F1.6 — Núcleo de mundo y Terrain3D (2026-11-19)

| Cambio | Detalle |
|---|---|
| Reloj, estado y guardado | Se añaden `WorldClockService` (`core/world/world_clock.gd`), `WorldStateService` (`core/world/world_state.gd`) y `SaveManagerService` (`core/save/save_manager.gd`), registrados como autoloads `WorldClock`, `WorldState` y `SaveManager`. El reloj hace un día de juego en 48 min reales por defecto; el estado guarda fase, banderas, descubrimientos, NPC y cambios físicos; el guardado es JSON versionado por campaña/ranura, con escritura temporal y round-trip de mundo/reloj/jugador. |
| Definición y horario de NPC | Se añaden `ScheduleEntry` y `NpcDefinition` (`core/npc/`): franjas con cruce de medianoche, ancla, actividad, condiciones y niveles de simulación. `NpcDefinition.get_entry/get_anchor/get_activity` resuelven la rutina con el minuto y el estado del mundo. |
| Streaming de sectores | Se añaden `SectorDefinition` y `SectorStreamer` (`core/world/`): celdas de región, radio de carga y descarga con histéresis, carga asíncrona con `ResourceLoader.load_threaded_request`, descarga, sector siempre cargado y señales. La verificación usa tres escenas reales y descarga por radio. |
| Navegación | Se añade `NavigationService` (`core/world/`): mapa del `World3D`, ruta, alcance, longitud y punto más cercano. `navigation_check` valida dos regiones separadas por un hueco de 5 m unidas por `NavigationLink3D`; `test_navigation_service` cubre la consulta fuera del árbol. |
| Terrain3D | Se instala Terrain3D 1.1.0 (MIT) en `addons/terrain_3d` y se mide una escena de 512 × 512 m con 4 regiones, 50 árboles y 20 NPC de relleno: 113,5/114,0/114,5 FPS de media, 68 draw calls y 97 MB de VRAM en la UHD 770 (perfil Medio). La colisión se valida con un rayo. Adopción provisional para el blockout de F2; faltan texturas, vegetación densa, edificios, navmesh y exportación. |
| Cyclops | Se instala Cyclops Level Builder 1.5.2 (MIT) en `addons/cyclops_level_builder` y se valida un `ConvexBlockData` cúbico convertido por `CyclopsBlock` en malla con una superficie y forma de colisión. El plugin no se habilita por defecto para no registrar su autoload y se excluye de la exportación (`addons/cyclops_level_builder/*`). El addon deja un aviso de objetos sin liberar al salir en 4.7.2; se vigila en F2. |
| Sector gris | `grey_sector` integra 256 m de Terrain3D, una pirca de Cyclops convertida, una plaza con navmesh, 20 NPC con horario, cambio de ancla por hora y guardado/carga de fase, bandera y reloj. Tres pasadas: 94,1/89,2/89,6 FPS, 116–118 draw calls y 98,7 MB con carga del equipo 4,5–5,1. `grey_sector_check` en CI. |
| Navmesh sobre el terreno | Terrain3D no expone su malla ni su colisión como nodos: la colisión es un `Terrain3DCollision` con RID propio, así que `NavigationRegion3D.bake_navigation_mesh()` no ve el terreno. Se implementa `TerrainNavmesh` (muestreo de altura, rejilla con la orientación de Recast y horneado síncrono) y `NavmeshProfile`; los obstáculos se declaran como huellas XZ y se recortan. `NpcMover` sigue las rutas y el sector gris avanza la simulación de forma determinista. Resultado: 128 polígonos de −0,02 a 2,73 m, ruta al campo con relieve, pirca rodeada y 20 NPC que llegan caminando. Con carga 3,3–3,7: 94,2/94,8/95,0 FPS de media, p1 82,5–94,3, 91–94 draw calls y 98,7 MB. Las pasadas con carga 32–38 se descartaron por contención del equipo. |
| LOD de NPC | `NpcDirector` descarga los tier B fuera de 90 m, mantiene activos los narrativos y reparte el presupuesto de 60 activos y 25 animados por cercanía, con histéresis. `NpcSimActor` sustituye a la clase heredada `NpcActor` de la campaña lineal. El snapshot guarda minuto, posición y ancla de los tier A/B. En `npc_lod.tscn` (60 NPC, 25 animados) la mediana bajó de 76,8 a 64,6 FPS (15,9 %) con carga 47–50; 209–223 draw calls y 101,6 MB. Faltan personajes reales y MultiMesh para la multitud. |
| Streaming medido | `streaming_soak_check` encadena 60 ciclos de carga/descarga de una escena real: 21,4 ms de media, 32,2 ms el peor ciclo, 15,6 ms de hitch máximo y 1 KB de crecimiento de memoria estática. Sustituye en CI al recorrido de 10 minutos; el sector real con arte queda para F2. |
| Blockout F1.7 | `GreyBlockout` levanta seis casas y dos pircas Cyclops, 120 cápsulas de multitud y 180 matas de ichu en dos MultiMesh; las huellas de las casas recortan el navmesh. Comparación en el mismo proceso con carga 52–57: 63,9 FPS sin blockout y 62,1 con blockout (2,8 %), 255–287 draw calls, 101,7 MB y frame máximo de 30,3 ms. Presupuesto de sector fijado. F1 queda técnicamente cerrada, pendiente de la aprobación del responsable y de la adopción definitiva tras F2. |
| Cierre de F1 y apertura de F2 | El responsable aprueba cerrar F1 con los siete spikes medidos. Terrain3D y Cyclops quedan en adopción provisional hasta el sector real; el presupuesto de sector se fija en ≤ 350 draw calls, ≤ 250 MB, 60 FPS Medio y frame < 50 ms. Se abre F2 con el heightmap regional de 3,5 × 2,5 km como primera tarea. |
| Heightmap regional F2.1 | `CampaignRegion` genera el relieve de 3,5 × 2,5 km con una región de 1024 a 4 m: valle este-oeste, río serpenteante, quebrada, paso y cumbres. Alturas de sector: S1 3.392 m, S2 3.473 m, S3 3.619 m, S4 3.947 m, S5 4.090 m y S6 4.169 m; cumbres hasta ~4.800 m. Generación en memoria de ~1,5 s, 16 regiones internas. Clasificación GN/GR: es una propuesta de blockout, no una reconstrucción. Captura en `build/evidencia/region_overview.png`; `region_terrain_check` en CI. Falta DEM o aprobación del perfil y el terreno local de 1 m por sector. |
| Sectores y streaming F2.2 | `region_world` mantiene el terreno regional cargado y transmite seis escenas de sector con `SectorStreamer` (celdas de 512 m, carga 2 y descarga 3). Cada sector tiene su centro mundial, su clasificación y un marcador de blockout; S1–S6 se cargan y descargan sin cambiar de escena. `region_streaming_check`: S3 al inicio, S1 al este, S6 al oeste, descarga de S1/S3 y 0 fallos. Captura en `build/evidencia/region_streaming.png`. Falta el contenido real de cada sector (F2.4–F2.6), rutas y POI. |
| Rutas y navmesh F2.3 | Ocho `CampaignRoute` de blockout (R1–R8) dibujadas como cintas sobre el terreno con 3 m de muestreo y 0,8 m de separación. Seis navmeshes horneados sobre los límites de cada sector (paso de 6 m) y cinco enlaces creados tras la sincronización del mapa, con extremos proyectados al navmesh. `route_network_check`: 8 rutas, 6 regiones, llacta–Cusco 1.039 m y llacta–frontera 2.190 m. Horneado ~3,4 s en la referencia; es coste de blockout. Captura en `build/evidencia/routes.png`. Faltan caminos definitivos, vados, puentes y el recorrido de F2.8. |
| Blockout de S3 F2.4 | `LlactaBlockout` levanta la plaza de 18 m, 17 casas (12 exteriores, 4 interiores y la casa de Rumi), casa del curaca, telar, corral, manantial, acequia, huerto, horno y fogón. 69 mallas, 20 cuerpos estáticos y 9 etiquetas de POI; las casas quedan fuera del anillo de 21 m para no bloquear las salidas de R1, R2, R3 y R7. `llacta_blockout_check`: `LLACTA_OK houses=17 pois=9`. Medición con carga 18–30: 78,0/81,3/85,3 FPS, p1 59,7–76,5, 120 draw calls y 152 MB. Captura en `build/evidencia/llacta_blockout.png`. Faltan interiores, materiales finales y NPC. |
| Blockout de S1 F2.5 | `CuscoBlockout` levanta la plaza de 28 m, 28 casas de ayllu con callejones, Coricancha con plataforma, muros y recinto, mercado de seis puestos, taller textil, cuatro depósitos, acequia urbana y seis POI. `BlockoutKit` se extrae para compartir cajas, cilindros, cintas y etiquetas con S3. `cusco_blockout_check`: `CUSCO_OK houses=28 pois=6`, 111 mallas y 43 colisiones. Medición con carga 1,0–1,4: 76,4/79,2/82,3 FPS, p1 60,0–65,8, 247 draw calls y 128–137 MB. Captura en `build/evidencia/cusco_blockout.png`. Faltan interiores, muralla, multitud y mercado funcional. |
| Blockout del oeste F2.6 | `QuebradaBlockout`, `PasoBlockout` y `FronteraBlockout` completan S4–S6: terrazas, queñua, salto, cueva y cantera; zigzag, refugio, mirador y altar; bofedal, tambo, marcas, campamento, puesto y campo de batalla. POI: S4 5, S5 3, S6 5. `frontier_sectors_check`: `FRONTERA_OK s4=5 s5=3 s6=5` y rutas S4–llacta y S5–S6. Medición con carga 1,3–1,5: S4 80,0 FPS/146 draws, S5 95,5/103, S6 103,0/83; 127 MB. Capturas en `quebrada_blockout.png`, `paso_blockout.png` y `frontera_blockout.png`. Faltan clima, interiores, facciones y combate. |
| POI y descubrimiento F2.7 | Se crean `PoiDefinition` y `DiscoveryService`. 30 POI en `.tres` con ID, nombre, descripción, sector, clasificación, posición, radio, disparador y rango de fase. Casa de Rumi y plaza se conocen al empezar; el resto se descubre por proximidad, diálogo (casa del curaca, casa de ayllu) o evento (campo de batalla). El servicio alimenta diario y mapa solo con lo descubierto y persiste en `WorldState`. `poi_discovery_check`: `POI_OK total=30 discovered=6 start=2`, con fases y guardado. Falta UI de diario/mapa y conectar diálogos y misiones. |
| Recorrido regional F2.8 | `region_walkthrough_check` recorre el navmesh Cusco → frontera en pasos de 20 m, con streamer y descubrimiento activos: 2.758 m, 23,0 min a 2 m/s, los seis sectores vistos, S1 descargado al llegar a S6, 8 POI descubiertos, 0 fallos y ninguna pantalla de carga. Los puntos de enlace se aceptan como transitables. Al final, guardado/carga conserva los descubrimientos. La prueba humana de 20–30 min y la aprobación del blockout siguen pendientes para cerrar F2. |
| Modo de revisión del blockout | `region_world` pasa de una cámara a 130 m y nueve etiquetas simultáneas a una cámara cercana (38, 26, 48), etiquetas ocultas por defecto y una barra con las teclas: `H` muestra solo la etiqueta más cercana y `T` alterna vista cenital. Se añade `region_review_check` y capturas `region_review.png` / `region_review_labels.png`. El cambio es de revisión, no de juego; sigue sin jugador ni colisión. |
| Mundo caminable | La prueba humana de F2.8 no se podía hacer porque el mundo regional no tenía jugador. `region_world` instancia ahora `player_fps.tscn` en el camino de entrada a la llacta, con `first_person` activo por defecto: colisión dinámica de Terrain3D bajo los pies, streaming y descubrimiento siguiendo al jugador, rescate a 120 m de caída y sin manos ni arma. Las capturas y mediciones de blockout siguen usando la cámara de revisión con `first_person = false`. `region_player_check` anda 9 m sobre el terreno (hueco de 0,02 m), comprueba el seguimiento del streaming y el rescate. Queda pendiente la presentación del jugador, la interacción y el equipo. |
| Pruebas | `test_world_clock`, `test_world_state`, `test_save_round_trip`, `test_npc_schedule` y `test_sector_streamer` y `test_navigation_service` cubren avance, pausa, franjas, serialización, nombres inválidos, sobrescritura, ciclo mundo/reloj/jugador, horario diario, medianoche, condiciones, celdas, radios y longitud de ruta. `sector_streaming_check` carga y descarga escenas reales; `navigation_check` cruza dos regiones con un enlace. Se documentan en `docs/06` §3.4.1. |
| Alcance | No se integra todavía la posición real del jugador, la escena de mundo, el `NpcDirector` ni el LOD de simulación; eso es F3. Terrain3D y Cyclops quedan en adopción provisional para F2. La F0 queda cerrada y la F1 en curso. |

## 2026-11-19

| Cambio | Detalle |
|---|---|
| Actions en Node 24 | Se actualizan `actions/checkout` a v7, `actions/cache` a v6, `actions/setup-python` a v7 y `actions/upload-artifact` a v7. Las cuatro usan Node 24 y desaparece el aviso de deprecación de Node 20. Sin cambios de lógica, permisos ni retención de artefactos. YAML validado; CI en verde. |
| Limpieza documental y del ratchet | Se sustituyen las reglas activas que exigían ADR por decisiones en la bitácora (`docs/00`, `02`, `03` y `04`), se marcan las citas ADR como históricas y se corrigen los enlaces muertos de los `LICENSE.md` de texturas y modelos. El ratchet de tamaño baja a los tamaños reales (ciudad 2366, llacta 2284, paso 1371, npc_actor 582), retira `dressed_mannequin.gd` y falla si una entrada heredada ya no existe. `export_presets.cfg` deja de excluir una ruta UBC inexistente. La bitácora pierde la columna de commit vacía y gana el formato de decisión; `docs/06` §5 pasa a registro histórico y enlaza a la bitácora. `README.md` distingue plataformas verificadas. Enlaces relativos de todo el repositorio: 0 rotos. |
| Validación visual reutilizable | `docs/06` §4.1 fija el procedimiento: tomas fijas con cámara del jugador, HUD/manos ocultos, antes/después en `documentation/img/<tarea>/`, revisión de escala y paleta contra la guía visual, anacronismos, rendimiento con `scene_audit`/`measure_performance` y evidencia en la ficha y el PR. Se enlaza desde `docs/08`, la guía visual, la ficha de F4 y `AGENTS.md`. Sin cambios de código; las capturas de `capture_llacta_tour` siguen en `/tmp` y se copian a mano (deuda declarada). |
| Lint y formato de archivos nuevos | Se fijan `gdtoolkit 4.5.0` (`requirements-dev.txt`), `gdlintrc` (100 columnas, 400 líneas, 8 argumentos) y `.editorconfig`. La CI gana el job `lint`, que aplica `gdlint` y `gdformat --check` solo a los `.gd` añadidos en el PR o push; los archivos heredados sin formatear no se tocan. `docs/03` documenta el ratchet y los comandos, y `README.md` el requisito de Python. Probado con un archivo correcto (pasa) y uno incorrecto (falla por orden y formato). |
| Guardas de CI para pruebas y salida | Se añade `tools/check_test_inventory.py`: toda prueba `tests/test_*.gd` debe figurar en §3 de `docs/06`, toda prueba citada debe existir, ninguna `test_*.gd` puede quedar en una subcarpeta fuera del alcance de `run_tests.gd`, y los cinco recorridos de integración deben ejecutarse en CI. Se añade `tools/check_output.py`: la importación y cada ejecución fallan si aparece un `ERROR` o `WARNING` con `res://` o un `SCRIPT ERROR`. La CI gana el job `guard`, cachea Godot en el job de pruebas y revisa la salida de todos los pasos. `docs/06` retira `test_quaternius_characters`, documenta `test_mannequin_cast` y `test_session_acts`, corrige §3.5 y la descripción de la CI. Inventario OK (73 archivos y 5 recorridos); salida limpia en importación y pruebas. |
| Ficha de F4 y plan sin duplicación | Se añade `docs/fases/F4-arte-audio-equilibrio.md` con alcance, tabla de tareas (4.1–4.14), criterios por tarea, dependencias, riesgos, orden de recorte, checklist de cierre y deudas que pasan a F5. `docs/05` conserva solo el estado y los criterios de fase. La partida humana cronometrada, el contraste de dificultad y la prueba de humo pasan a F5. Se cierran por alcance 4.8 (equilibrio numérico) y 4.13 (composición del acto I); lo pendiente se traslada a 4.9, 4.12 y F5. `README.md` y la documentación de campaña enlazan a la ficha y dejan de repetir el estado. Enlaces verificados; sin cambios de código. |
| Reglas de trabajo por fase y PR | `AGENTS.md` pasa a 13 secciones: fase actual visible, stack fijado, plan previo para cambios importantes, tarea con criterio de aceptación, una rama y un PR, prohibición de adelantar fases, capas, verificación por alcance, informe con «no verificado» y autoridad de decisión. Se añade la plantilla de PR. Se corrigen las referencias a las secciones de `AGENTS.md` en `docs/00`, `docs/05`, `docs/bitacora.md` y los `LICENSE.md` de audio y texturas. Sin cambios de código; enlaces verificados. |
| Duda del acto I con E | El `DudaPoint` estaba disponible desde la mañana; si el jugador lo abría antes de tiempo, el punto se consumía y el paso «Escucha la discusión» quedaba sin interacción: E no hacía nada. `ActOneDirector` lo habilita solo en el paso `Doubt` (`_set_doubt_available`). Prueba nueva `llacta_doubt_check.gd`: sin foco temprano, el rayo y la E reales abren la duda, la E avanza la respuesta y el flujo pasa al mensajero; añadida a CI y a `docs/06`. 141 pruebas, mensajero, recorrido y arco OK. |
| Tráiler de redes | Se capturan 960 fotogramas por formato con cámara libre, HUD y manos ocultos, y se montan cuatro piezas: 35 s y 15 s en 9:16 y 16:9, con rótulos en español, subtítulos en inglés quemados, etalonaje, música «Over The Andes» (Pixabay, IA) y efectos del juego. La casa de Rumi da el antes/después (paño de ausencia → lumbre) sin revelar el final. Herramientas `tools/trailer_capture.gd`, `trailer_post.py`, `trailer_audio.sh` y `trailer_build.sh`; ficha en `docs/trailer_redes.md`; piezas en `build/trailer/` (ignorado por Git). Verificado con `ffprobe` y fotogramas clave; −13,9 LUFS. |

## 2026-11-18

| Cambio | Detalle |
|---|---|
| Mensajero a tiro tras la duda | El `DudaPoint` se retira al terminar su diálogo (`CampPoint.set_available(false)` apaga la capa de interacción) y el mensajero se acerca al punto de la duda, dentro del rayo de 3 m. La opción «Escuchar» se prueba con el botón y el avance con E reales; `llacta_messenger_check` recorre el rayo desde el punto de la duda. 141 pruebas, walk y mensajero OK. |
| Composición del territorio y vivienda | La llacta gana la red de caminos visibles de la referencia: diez rutas de 3 m con cinta de tierra y bordes de piedra en `MultiMesh`; borde de pirca bajo con cuatro entradas; manantial con pileta, acequia, juncos y la tarea del agua; mirador con parapeto y banco en el paso norte; roquedales; fondo de valle con campos y caserío. `HouseKit` unifica ancho, fondo, altura, escala, tinte y colisión de las cinco variantes en llacta y Cusco (antes todas usaban una base de 6 × 5 m). `LlactaPaths`, `LlactaPlazaEdges`, `LlactaSites` y `ValleyBackdrop` viven fuera de `llacta.gd`. 141 pruebas; `test_llacta_layout`; recorrido real `llacta_walk_check` OK; `ARCO_OK`; arena. Medición limpia: draw calls 294/270/331/306/315 y Cusco 63,8 FPS con p1 60,0 y carga 0,45–0,51. Capturas de [plaza](../campaigns/01_pachacutec/documentation/img/acto_i/llacta_plaza.png), [manantial](../campaigns/01_pachacutec/documentation/img/acto_i/llacta_manantial.png), [camino norte](../campaigns/01_pachacutec/documentation/img/acto_i/llacta_camino_norte.png) y [mirador](../campaigns/01_pachacutec/documentation/img/acto_i/llacta_mirador.png). |
| Acto I con objetivos visibles | Se porta el flujo de pasos de la referencia a `core/systems/slice/` (`SliceStep`, `SliceFlow`, `SliceSequence`) y se dirige el acto I con `ActOneDirector`: mañana → honda → cuatro encargos (bastan tres) → duda → mensajero → asamblea. `QuestTracker` muestra objetivo, contador, lista de encargos solo en su paso y banda de aviso; `QuestMarker` señala a la madre, el blanco, la duda, el mensajero y la plaza; el diario completa `encargos`. `SlingDrill` sustituye el «pulsa E» por un blanco de paja, apuntado con la vista y clic, piedra visible, gesto de arma y tres aciertos. El mensajero ya no aparece automáticamente al tercer encargo: llega tras la duda. Apoyar a Puma baja la reputación ante el Cusco y el arco lo refleja al perder un aliado si no se compensa. Capturas de [mañana](../campaigns/01_pachacutec/documentation/img/acto_i/acto_i_01_manana.png), [honda](../campaigns/01_pachacutec/documentation/img/acto_i/acto_i_02_honda.png) y [encargos](../campaigns/01_pachacutec/documentation/img/acto_i/acto_i_03_encargos.png). 140 pruebas, `ARCO_OK` y arena; draw calls 265/270/334/272/283; FPS no concluyentes por carga 17–27. |
| Chaquitaclla del Agricultor | Se añade `pch_prop_chaquitaclla.glb` (430 triángulos, 1,48 m, estribo de 22 cm, madera y punta endurecida, sin metal), generado por `pch_models.py` y plantado en la primera terraza junto al Agricultor. Ficha PCH-037 (H/R, pendiente de firma). La llacta pasa de 248 a 249 draw calls. Se corrige la cámara de `capture_quaternius`, que tras los arquetipos volvía a la del jugador. 134 pruebas, captura nueva |
| HijoPuma sin base infantil | Se revisa el pack UBC Standard: solo incluye los cuerpos Superhero (hombre y mujer); Regular/Teen son de la versión Source de pago, no usada. No hay base infantil gratuita compatible con el rig Q y no se mezcla otro set. Se cierra la decisión con el Joven Q a 1,20 m y una prueba de altura. 135 pruebas |
| Mano articulada y manto con muelles | Los diez GLB Q pasan a 71 huesos: 65 de UBC más 6 de manto (`Cape_L/C/R_1/2`) con pesos en el paño. `NpcActor` y `CharacterModelVisual` montan `SpringBoneSimulator3D` con cápsulas en pelvis y cintura; la multitud no simula muelles. La mano en primera persona articula las falanges y cierra el puño al golpear. Capturas y medición nuevas: llacta 249 draw calls/222,3 MB y 101,7 FPS; Cusco 288/230,8 MB y 70,6 FPS. 136 pruebas |
| Mandíbula de habla | Se añade el hueso `Jaw` (72 huesos: 65 UBC + 6 de manto + 1 mandíbula) y se reparte el labio inferior, el mentón y la barba entre `Head` y `Jaw`. `CharacterFace` abre y cierra la boca mientras suena `talk`; la multitud no anima la cara. Es animación de habla, no fonemas ni parpadeo. 137 pruebas |
| Mano de maniquí en primera persona | Se sustituye la mano detallada de UBC por una mano de maniquí: antebrazo extraído del UAL1 (`tools/blender_mannequin_forearm.py`, 218 vértices, dos superficies) y palma, cuatro dedos separados y pulgar primitivos. Pose abierta para interactuar y puño cerrado para la honda y la porra; la pose se hornea al fusionar las piezas en dos mallas (piel y juntas), de ~30 draw calls a 2 por mano. Capturas en partida con honda y porra. 144 pruebas, arena y arco completos. Queda pendiente de revisión por el responsable. |
| Retirada del legado UBC | Se eliminan los diez GLB `pch_npc_*`, sus textiles y caras, la base/pelo UBC, `CharacterCatalog`, `CharacterFace`, `CapeSprings`, `QuaterniusMaterials`, `DressedMannequin`, el shader de tela y las herramientas de personajes UBC; `CharacterModelVisual` y `NpcActor` quedan solo con el maniquí. Sin cambio de draw calls ni memoria. 139 pruebas, arena y arco; la mano sigue en revisión. |
| Elenco de maniquíes integrado | La llacta, el Cusco, el paso y las chancas usan los diez looks sobre `OutfitMannequin`; `CharacterOutfit` fusiona las piezas por hueso con colores de vértice (tres mallas de ropa y dos del cuerpo) y `MannequinLooks.crowd_from` reduce la multitud. Los clips lógicos de UAL1/UAL2 conservan idle, walk, run, talk, work, weave, tired, attack, hit y death; el chanca lleva porra. Medición: llacta 257/145,2 MB, paso 270/121,1, Cusco 334/158,5, posguerra 259/145,3 y obra 275/140,2, bajo 350. 150 pruebas, arena y arco. El legado UBC ya no se carga y queda pendiente de retirada; la mano sigue en revisión. |
| Diez looks de maniquí | Se completan los diez papeles del elenco sobre el UAL1: Curaca, Sisa, Chanca, Anca, Puma, Madre, Hermano, Joven, Anciana y Mensajero, con alturas de la tabla de la llacta. Se corrige el Curaca (sin orejeras ni oro) y el Chanca (unku oscuro con acento teal); se añaden lliclla delantera con tupu, melena posterior o paño y el bulto/correa del mensajero. Capturas `maniquies_principales.png` y `maniquies_apoyo.png`. 144 pruebas; los looks aún no se usan en NPC. |
| Prototipo de maniquíes UAL1 | Se porta el sistema de la referencia: `CharacterLook`/`LookPart`/`CharacterOutfit` sobre el UAL1 de Quaternius, tres looks (Curaca, Sisa, Chanca), mano/antebrazo extraídos con `tools/blender_mannequin_forearm.py` y panel de objetivo arriba a la izquierda con fondo oscuro. Capturas en `documentation/img/prototipo/`. 144 pruebas; el elenco UBC sigue activo hasta aprobar el prototipo. |
| Pase visual: casas, llama y tarjetas | Las casas de la llacta pasan por `SurfaceMaterials` al cargar el modelo (piedra, paja y madera); la llama del fuego comunal es un shader billboard; la tarjeta del acto IV baja a 0,80 de opacidad; la del acto III se divide en párrafos; la porra de PNJ se oculta a menos de 1,4 m; la honda usa correa fina y bolsa; la mano de interacción baja a 0,68. 140 pruebas; llacta 220, paso 258, Cusco 297, posguerra 218 y obra 243 draw calls. |
| Revisión general: HUD y puño del arma | La pista superior baja a 72–114 px para no quedar bajo la banda de 64 px; la tarjeta de fin espera 0,35 s antes de mostrar el texto y lo desvanece con el fondo; la honda y la porra llevan un puño de bloqueo con manga. Se extrae `HudText.reading_seconds` para que `hud.gd` no crezca (612 líneas). 139 pruebas; draw calls llacta 248, Cusco 297. |
| Parpadeo y cejas | Los diez GLB Q pasan a 76 huesos (65 UBC + 6 de manto + 1 mandíbula + 4 de expresión). `Blink_L/R` baja el párpado superior y `Brow_L/R` alza la ceja; `CharacterFace` parpadea cada 2,8–6,2 s y alza las cejas al hablar, también en la multitud. Se corrige el uso de `set_bone_pose_position`, que es absoluto en el esqueleto y no un desplazamiento. Capturas nuevas `curaca_blink` y `curaca_brows`. 138 pruebas |

## 2026-11-17

| Cambio | Detalle |
|---|---|
| Rendimiento del Cusco | El desglose de `scene_audit.gd --breakdown` mostró que la multitud del Cusco pesaba 173 draw calls y el pase de sombra 266. La multitud oculta el tupu por material y conserva las cejas; solo cuerpo y ropa proyectan sombra, y ojos, cejas, tupu y pelo quedan fuera del pase. Llacta 248 draw calls/222,2 MB, paso 244/162,8 MB, Cusco 288/230,8 MB, posguerra 226/222,8 MB y obra 257/217,4 MB: los cinco actos bajo el presupuesto de 350. Tres pasadas por acto con carga 4,3–6,9: Cusco 62,6 FPS de mediana y p1 60,0 (peor p1 54,8). 133 pruebas, arena y arco completos |

## 2026-11-16

| Cambio | Detalle |
|---|---|
| Quaternius único | Se retira el elenco MakeHuman/Rocketbox, el híbrido Rocketbox y el injerto de cabeza MakeHuman. Todos los papeles usan los diez GLB Q: Tejedora = Anca, Agricultor = Joven, HijoPuma = Joven a 1,20 m, heridos y comitiva comparten Madre/Hermano/Joven. Se elimina `--visual-set`; el juego carga Q por defecto. LOD de multitud (cejas/tupu). Llacta 321 draw calls/222,2 MB; Cusco 413/230,8 MB, sobre el presupuesto de 350; 131 pruebas, arena y arco completos |
| Textiles andinos | Se integra el atlas textil de `pch_people.py` en los diez personajes Quaternius: franjas verticales, lliclla/manto con cenefas, faja con rombos, tupu de cobre con disco y alfiler, chuspa con correa y cuello alto con abertura estrecha. Se ensancha la nariz, se llenan los labios y se pinta el pliegue epicántico. Los GLB embeben el atlas textil (1,4–2,1 MB); cuerpo/cara siguen compartidos. Llacta 310 draw calls y 225 MB; Cusco 349 y 245 MB, a uno del presupuesto. 131 pruebas |
| Familia de la llacta | Se migran la madre (`Habitante1`), el hermano (`Habitante2`), Puma (`Principal2`) y Anca (`Anca`) a Quaternius con caras de 1024 y ropa propia: anacu/lliclla/tupu, unku/manto/chuspa y autoridad comunal sin t’oqapu. Puma y Anca comparten los rasgos andinos de los arquetipos. HijoPuma sigue legacy por falta de base infantil en UBC. Llacta 300 draw calls y 209 MB; Cusco 343 y 233 MB. 131 pruebas |
| Fusión de estática | `StaticMeshBatch` fusiona por material/tinte casas, props, mercado, mobiliario, puerta, remates de muro, terrazas, santuario y vegetación del Cusco y la llacta. El Cusco baja de 494 a 343 draw calls (328 legacy) y la llacta de 341 a 297; el presupuesto de 350 se cumple. La memoria sube ~8 MB por la copia de vértices; los originales quedan ocultos. 131 pruebas; capturas de santuario y mercado sin regresiones |
| Arquetipos andinos | Se añaden `pch_npc_anciana_q` (mujer mayor, canas, trenzas, anacu y lliclla) y `pch_npc_joven_q` (hombre joven, unku, faja y chuspa) con texturas de cara propias, cejas y edad. Ocupan dos de los diez puestos de la multitud del Cusco; el resto sigue con el elenco anterior. Se refuerzan los rasgos andinos —pómulos anchos, nariz recta, labios llenos, piel media/oscura— sin caricatura. Cusco 69,1 FPS, 494 draw calls y 219 MB; +14 draw calls frente al elenco anterior. 131 pruebas |
| Caras Quaternius | Se generan texturas de cara de 1024 por personaje desde la albedo 2048 de UBC con `tools/build_face_textures.py`: tono horneado, labios, ojeras, líneas de edad, grano y cejas más suaves (`pch.brow_*`). El Curaca suma mejillas hundidas y papada; Sisa, cejas finas y labios llenos. `QuaterniusMaterials` separa piel, pelo, cejas y ojos de `SurfaceMaterials`. 131 pruebas; llacta 111,0 y Cusco 71,7 FPS con carga 9,5; +2 MB de vídeo |
| UAL2 y texturas compartidas | Se extrae `UAL2_Prototype.glb` (11 clips, CC0) de UAL2 Standard con `pch_ual2_library.py`: `idle_b`, `work` y `hit` sustituyen sus equivalentes de UAL1. Los GLB de personaje dejan de embeber texturas y `SurfaceMaterials` comparte una sola vez las texturas de `base/`; bajan de ~10 MB a 4,5 MB en total y el Cusco baja ~9 MB de vídeo. 130 pruebas; llacta 114,8 y Cusco 73,1 FPS; +5/+8 draw calls |
| Prototipo Quaternius | Se añaden cuatro personajes sobre Universal Base Characters (CC0, estándar gratuito): Mensajero, Sisa, Curaca y Chanca. `pch_quaternius.py` conserva la cabeza UBC, añade ropa, trenzas, cintas, chuspa, tupu y sandalias, y exporta GLB sin animaciones; `QuaterniusClips` copia UAL1 (`idle`, `walk`, `run`, `talk`, `attack`, `hit`, `death`). `CharacterCatalog` activa el set con `-- --visual-set=quaternius`; el anterior sigue por defecto. 130 pruebas, arena y arco con el set nuevo; capturas en `documentation/img/personajes/`. Límites: cuerpos aún atléticos, caras con la misma topología base, sin expresiones faciales, mano propia sin articulación por dedo y multitud del Cusco sin migrar; el Cusco se mueve entre 65 y 72 FPS |
| Vídeo actual | Se regraba la pasada guionizada con el estado actual: 1:58, 1280×720, 30 fps y 16 MB en `build/partida_completa_actual.mp4`. El grabador incluye 4 s de combate en el paso y 3 s por oleada en el Cusco, recarga piedras, llama al ataque de la escena e inclina la cámara; la tarjeta de fin sube a 0,93 para leerse sobre la obra. Clips `build/combate_paso_actual.mp4` y `build/combate_cusco_actual.mp4`, hoja de contacto y fotograma final. `build/` ignorado por Git |
| Guardarraíles de entrega | Se añaden `export_presets.cfg` (Linux/Windows), CI de GitHub Actions (importar, pruebas, exportar y arrancar el build) y `tools/check_gdscript_limits.py`: los archivos nuevos no pasan de 400 líneas y los siete heredados quedan congelados. La exportación local de Linux (128 MB) arranca en headless |
| Guía visual y paletas 4.9 | Se escribe `guia_visual.md` con idea, escala, formas, luz, «qué evitar» y una paleta por acto; `PaletteTuning` aplica cielo, sol, ambiente, niebla y exposición desde `resources/palettes/`. `capture_palettes.tscn` genera las cinco capturas de referencia. El acto IV deja de llevar colores en código: la paleta manda |
| Sensación de combate 4.11 | `CombatLoadout` separa anticipación, ventana activa y recuperación; el impacto añade hitstop, golpe de cámara y destello; el escudo tiene parry de 0,15 s y bloqueo del 70 %; los chancas avisan el golpe y comparten fichas (máximo dos a la vez). La arena con bot resuelve tres enemigos con ≤ 2 atacantes. El bot descubrió que el cadáver seguía bloqueando el rayo; el cuerpo derribado ya desactiva colisión. 126 pruebas; `ARCO_OK` |
| Registro de tuning | Se añade `docs/combat-tuning-log.md` con los valores iniciales, las invariantes y lo que falta por verificar con una persona |

## 2026-11-15

| Cambio | Detalle |
|---|---|
| Medición final de Bajo | Tres pasadas del perfil Bajo con el arte nuevo y carga 1,6–3,8: llacta 102,4, paso 102,0, Cusco 74,2, posguerra 124,5 y obra 105,3 FPS de mediana. El mínimo es 73,8, muy por encima del objetivo de 30. Se actualizan `docs/05`, `docs/06` y `docs/08` |
| Vídeo final | Se regraba la pasada guionizada con el arte final (cordilleras con nieve, escala 0,68 y HUD actual): 1280×720, 30 fps, 1:45 y 14 MB en `build/partida_completa.mp4` (ignorado por Git). La hoja de contacto y el fotograma final acompañan al vídeo |
| Medición final 4.10 | Tres pasadas válidas con la escena final (cordilleras, shader aligerado y escala 0,68) y carga 1,8–2,7: llacta 89,4, paso 93,4, Cusco 63,6, posguerra 97,5 y obra 90,5 FPS de mediana. Los cinco actos superan los 60; el Cusco queda en 63,2 en la peor pasada. Con esto se cierra el rendimiento en Medio |
| Rendimiento con cordilleras | Tanda completa de tres pasadas con las montañas nuevas: llacta 87,3, paso 79,8, Cusco 59,4, posguerra 94,3 y obra 85,6 FPS de mediana. El Cusco queda por debajo de 60. Se aligera el shader (variación por vértice, nieve condicional) y la escala de Medio baja de 0,70 a 0,68; la medición final queda pendiente por carga externa |
| Alcance de arte 4.9 | Se corrige el alcance pendiente: el elenco ya tiene reposo, habla, trabajo, caminar, correr, mirada y manto simulado, y la biblia excluye retratos y voces. El arte que falta queda en texturas finas de roca, props de detalle y mezcla de audio escuchada |
| Niveles de audio 4.9 | Se añade `tools/audio_levels.py`, que decodifica cada audio a estéreo y mide duración, pico, RMS y clips. Los 19 archivos están sin clip (picos entre -3,2 y -13,9 dBFS) y sin efectos casi mudos; la escucha por acto sigue pendiente. El primer análisis daba un falso clip en `honda_impacto.wav` por bajar a mono y sumar canales |
| Roca y nieve 4.9 | Las cordilleras ganan estratos por ruido y nieve sobre una línea irregular en las cumbres medias y lejanas; la luz separa sombra fría y sol cálido. La nieve solo aparece en las bandas altas, con umbral y fuerza por material. 118 pruebas; `ARCO_OK` |
| Medición pendiente 4.10 | La herramienta de rendimiento ahora limpia `CampaignState` entre actos: las banderas de un acto cambiaban la puesta en escena del siguiente y los draw calls. La re-medición tras las cordilleras con volumen no se pudo completar: el equipo estuvo entre carga 30 y 40 por procesos externos y las pasadas contaminadas daban 53–59 FPS en el Cusco. Se obtuvieron dos pasadas válidas con el shader anterior (Cusco 61,1 y 59,6); falta la tercera. Después se aligeró el shader de cordilleras, sin re-medir |
| Cordilleras con volumen 4.9 | Las cordilleras de la llacta y las colinas del Cusco dejan de ser cortinas planas: `DistantRange` genera bandas polares con ladera de entrada, cresta y ladera de salida, altura por ruido de crestas y normales; `range_shade.gdshader` hornea la luz del sol y mezcla la bruma por distancia y altura. La llacta usa tres bandas superpuestas y el Cusco comparte el generador con su paleta. Capturas de los cinco actos revisadas; faltan texturas de roca y el pase de audio. 118 pruebas; `ARCO_OK` |
| Re-medición 4.10 | Tras el pase visual se repiten las tres pasadas de Medio con carga 2,6–2,8: llacta 87,2, paso 88,5, Cusco 62,4, posguerra 99,6 y obra 84,0 FPS de mediana. La obra marcó 420 draw calls en la primera pasada y un p1 de 26,6 en otra; la mediana no cambia, pero el acto V queda bajo observación |
| Pase visual 4.9 | Nubes: bordes suaves, menos opacidad y horizonte alto para que no se corten contra las crestas. Cordilleras de la llacta: tres capas más separadas, cresta sin serrucho y degradado de base a cima; el Cusco gana un anillo lejano más alto y oscuro que ya no deja una línea clara sobre las colinas. Terreno de llacta y paso a 96 de resolución, macro más marcado y más piedras. La junta del refugio del paso deja de leerse como una caja negra. Capturas de los cinco actos revisadas; faltan animaciones, retratos y mezcla de audio. 118 pruebas; `ARCO_OK` |
| Rendimiento 4.10 | Tres pasadas de Medio a 1080p con la herramienta de medición, que ahora calienta 60 fotogramas, muestrea 300, publica FPS medio y p1 y anota la carga del sistema. El Cusco era el único acto por debajo de 60 (55,6 FPS): el SSAO costaba 17 FPS y bajar solo la escala no bastaba. Se decide mantener el SSAO y bajar la escala 3D de Medio de 0,83 a 0,70; el Cusco queda en 62,2 FPS de mediana (rango 58,0–62,6) y el resto entre 86 y 91. Se actualizan `docs/04` y `docs/08` |
| Duración 4.8 | Los cinco mundos marcan su acto en el registro de sesión (`act llacta/paso/cusco/posguerra/obra`), de modo que una partida jugada con `--session` deja la duración por acto sin cronómetro externo. Se añade `tools/session_duration.py`, que resume inicio, fin, duración y total (y `--json`), y la prueba `test_session_acts`. El protocolo queda en `docs/06` §4; la partida humana sigue pendiente. 118 pruebas; `ARCO_OK` |
| Combate y HUD 4.7 | Honda, porra y escudo con cambio 1/2/3; la honda consume piedras y la porra alcanza 1,6 m; el escudo bloquea el 70 % y consume aliento. La salud se lee en una viñeta, la respiración sintetizada acompaña al aliento, la munición aparece junto a la mano y se retira la barra fija de estado. Se añaden `CombatLoadout`, `FirstPersonWeapon`, `BreathingAudio`, `respiracion.wav`, el shader de viñeta y las acciones `attack/block/weapon_*`. 117 pruebas; `ARCO_OK` |
| Cierre de escenas 4.6 | Se cierran las 7 escenas parciales del guion de escenas: la duda se acerca al fuego, la marcha nombra al inca que huyó, el campamento deja de duplicar «Descansar», el coste cae al empezar la última oleada, el curaca vecino interviene y Anca testifica en la asamblea, `maiz_repartido` paga en el cierre y la obra usa los verbos y habilidades del acto I. Se eliminan `distraccion_cuerda` y `marcha_silencio`, se añaden rótulos de nombre, campos sin cuidar y el cruce del paso activa la emboscada si se rodea el disparador. 115 pruebas; `ARCO_OK` |
| Guion de escena 4.5 | Se añade la plantilla `docs/10_plantilla_guion_de_escena.md` y el `guion_escenas.md` de la campaña 01: 22 fichas con lugar, momento, personajes presentes, bloqueo, cámara, textos, decisiones, banderas, consecuencias, aceptación y deudas. Se actualizan la biblia y el guion de campaña a v1.1, se enlazan desde `docs/09` y se documenta la matriz de banderas y finales. 113 pruebas; `ARCO_OK` |
| Alineación con la biblia 4.4 | La casa de Rumi vuelve al este (House04) y la familia se calcula desde su puerta; la cuenta del sur y la del este varían con el coste y el explorador perdonado; Puma tiene línea propia si se reconcilia tras perder a su hijo; Anca reduce el aliento máximo al cargarlo y consume agua y coca al dejarlo; IV.4 y V.2 tienen mensajero visible; la familia se reúne en el umbral del cierre; la asamblea de I y IV se puebla; el acto IV tiene luz fría y heridos; la obra del acto V marca el oficio; la trampa es obligatoria; `paso_cruzado`, `viracocha_muerto`, `casa_reconstruida` y `carga_anca` pagan donde el guion dice. 112 pruebas; `ARCO_OK` |
| Cierre narrativo 4.3 | El acto II cobra cargar a Anca (aliento y salud) o dejarlo (reputación y ánimo). El acto III solo asigna el costo del hijo de Puma si los jóvenes se unieron, hace caer al defensor en la plaza y conserva el nombre en el epílogo. La casa de Rumi se traslada al oeste, la familia vive junto a ella, la posguerra la cubre con un paño y la obra la repara con umbral y lumbre; el acto V añade la quinta obra y el cierre enfoca la casa. La asamblea de IV paga el maíz guardado y el apoyo al curaca, y varía el silencio. La introducción y el aviso del mensajero quedan cableados. 103 pruebas; `ARCO_OK`; vídeo guionizado I–V en `build/partida_completa.mp4` |
| Puesta en escena 4.2 | Cusi recibe el mensaje en la puerta y se traslada al santuario al terminar la conversación; la llegada tiene objetivo e interlocutor visibles. Las cuatro preparaciones tienen puesto de trabajo visible y el oficio elegido queda anotado en el diario. La trampa incorpora al curaca vecino y enfoca su diálogo. Las cuentas se hacen en las puertas de las casas reales, con un paño de ausencia, y el resaltado se limita al objetivo. Los puntos de preparación, recluta, trampa, víspera y Cusi se retiran durante la defensa. 100 pruebas; `ARCO_OK` |
| Cierre jugable P0 | El campamento reparte sus seis opciones en dos páginas de cuatro y ya no pierde «Compartir coca» ni «Otro día será». El resaltado se limita al objetivo y no ilumina la escena entera al enfocar un punto de conversación. El diario recibe foco, se navega con flechas y libera el puntero. Las tarjetas de fin se cierran con E, Intro o R, bloquean al jugador y el objetivo de la defensa pasa a «Sostén la plaza». Se corrigen los contadores de encargos y obras. 99 pruebas; `ARCO_OK` |
| Cierre del guion y de los sistemas de campaña | Se corrige la tarjeta de fin para mostrar el cuerpo narrativo (muerte de Viracocha, nombre de Pachacútec y variantes). Se añaden intro, duda, mensajero, recursos persistentes, oficio aplicado, Sisa, reputación, Palabra, diario en los cinco actos y puntos de control. El acto II gana marcha, llegada y preparación; el III, trampa, tres oleadas y costo con nombre; el IV, cuentas y asamblea con Palabra; el V, telar y tres finales. PCH-032 a PCH-036 verificadas. 97 pruebas; `ARCO_OK`; medición de rendimiento por acto. Pendiente: arte/audio, equilibrio y duración real |
| Arco completo I–V en gris | Se encadenan llacta (acto I), paso (acto II), Cusco (acto III), llacta de posguerra (acto IV) y llacta en obra (acto V): asambleas, costo de la batalla, muerte de Viracocha y nombre nuevo. La portada abre la campaña y cada acto entrega el testigo al siguiente. Vídeo de 58 s en `build/campana.mp4` (1080p30). 91 pruebas, 0 advertencias; `ARCO_OK`. Pendiente: pase de arte del paso y de la posguerra, guion escrito y puntos de control |
| Acto I jugable en gris | La portada abre la llacta: terreno con relieve, ocho viviendas, tres terrazas con surcos, dos corrales, fuego comunal, vegetación y siete personajes con «Hablar» (madre, hermano, Sisa, curaca, Puma, tejedora y agricultor). Cuatro encargos: los tres primeros dan agua, maíz y manta, fijan el oficio y cambian el objetivo. Se conecta el MCP de Blender al proyecto. 88 pruebas en verde |
| Inicio de la campaña El despertar del Sol | Se aprueba la biblia de la campaña en cinco actos y el expediente histórico que la sostiene. La campaña se construye desde cero sobre el motor y el núcleo RPG existentes: acto I (llacta, encargos con recursos, familia, duda, mensajero y asamblea), acto II (paso, emboscada, Cusco, reclutamiento y preparación), acto III (defensa y costo), acto IV (posguerra y asamblea) y acto V (reconstrucción y nombre nuevo). Se ordenan las fuentes: la biblia narrativa general manda en lo narrativo y el plan fija las fases. 86 pruebas del motor en verde |
