class_name MundoBase
extends Node3D
## Mundo base de la campaña 01.
##
## Compone el entorno atmosférico, el terreno procedural, la llacta, el jugador
## y el HUD.

const TERRAIN_SIZE: float = 150.0
const TERRAIN_RESOLUTION: int = 64
const PLATEAU_RADIUS: float = 55.0
const BOUNDARY_RADIUS: float = 70.0
## Cresta del borde: el terreno sube entre RIDGE_START y RIDGE_FULL (distancia
## de Chebyshev al centro) hasta RIDGE_HEIGHT metros, con una pendiente que el
## jugador no puede subir. Los muros de BOUNDARY_RADIUS quedan como respaldo.
const RIDGE_START: float = 61.0
const RIDGE_FULL: float = 73.0
const RIDGE_HEIGHT: float = 11.0
## Paso abierto en la cresta norte, por donde llega el mensajero.
const PASS_HALF_WIDTH: float = 5.0
const PASS_EDGE: float = 12.0
## Lomas suaves fuera del núcleo de la llacta: empiezan a RELIEF_START m del
## centro y no tocan las terrazas ni los caminos, que siguen a cota 0.
const RELIEF_AMPLITUDE: float = 1.3
const RELIEF_START: float = 30.0
const RELIEF_FULL: float = 42.0
const TERRACE_ZONE: Rect2 = Rect2(26.0, -19.0, 32.0, 38.0)
const RELIEF_EDGE: float = 8.0
const PATH_CLEAR: float = 4.0
const PATH_BLEND: float = 9.0
const GRASS_COLOR: Color = Color(0.50, 0.49, 0.34, 1.0)
const ROCK_COLOR: Color = Color(0.46, 0.44, 0.42, 1.0)
## Tierra apisonada de la plaza y los caminos, que el terreno pinta con borde
## irregular (SurfaceMaterials).
const DIRT_COLOR: Color = Color(0.49, 0.43, 0.36, 1.0)
const ROCK_FROM_HEIGHT: float = 1.0
const ROCK_FULL_HEIGHT: float = 4.0
## Cúpula de nubes procedurales (shared_assets/materials/nubes.gdshader).
const CLOUD_SHADER_PATH: String = "res://shared_assets/materials/nubes.gdshader"

const CLOUD_DOME_RADIUS: float = 420.0
const CLOUD_DOME_SEGMENTS: int = 64
const CLOUD_DOME_RINGS: int = 32
## Cordillera lejana: dos anillos de siluetas fuera del límite jugable. No
## tienen colisión ni sombra; solo dan profundidad al horizonte.
const DISTANT_NEAR_RADIUS: float = 210.0
const DISTANT_MID_RADIUS: float = 270.0
const DISTANT_FAR_RADIUS: float = 330.0
const DISTANT_SEGMENTS: int = 160
const DISTANT_BOTTOM: float = -10.0
const DISTANT_NEAR_BASE: float = 28.0
const DISTANT_NEAR_AMPLITUDE: float = 34.0
const DISTANT_MID_BASE: float = 36.0
const DISTANT_MID_AMPLITUDE: float = 42.0
const DISTANT_FAR_BASE: float = 46.0
const DISTANT_FAR_AMPLITUDE: float = 48.0
const DISTANT_NEAR_COLOR: Color = Color(0.30, 0.34, 0.41, 1.0)
const DISTANT_MID_COLOR: Color = Color(0.36, 0.41, 0.48, 1.0)
const DISTANT_FAR_COLOR: Color = Color(0.43, 0.48, 0.55, 1.0)
const DEBUG_PROFILE_KEY: Key = KEY_F2
## Nombres de las fases del evento, en el orden del enum de [MessengerEvent];
## el registro de sesión los usa como marcas (§9.2).
const EVENT_PHASE_NAMES: Array[String] = [
	"idle", "arrival", "message", "call", "departure", "done"
]
const AMBIENCE_PATH: String = "res://shared_assets/audio/ambiente_viento_andes.ogg"
const FOOTSTEP_PATHS: Array[String] = [
	"res://shared_assets/audio/pasos_tierra_01.wav",
	"res://shared_assets/audio/pasos_tierra_02.wav",
	"res://shared_assets/audio/pasos_tierra_03.wav",
]
const STONE_FOOTSTEP_PATHS: Array[String] = [
	"res://shared_assets/audio/pasos_piedra_01.wav",
	"res://shared_assets/audio/pasos_piedra_02.wav",
	"res://shared_assets/audio/pasos_piedra_03.wav",
]
## Golpe del telar (sintético propio) y paso que hace de chaquitaclla al
## entrar en la tierra (punto 4 del plan de realismo, ADR-0015).
const LOOM_BEAT_PATH: String = "res://shared_assets/audio/telar_golpe.wav"
const LOOM_BEAT_VOLUME_DB: float = -9.0
const DIG_PATH: String = "res://shared_assets/audio/pasos_tierra_02.wav"
const DIG_VOLUME_DB: float = -4.0
const DIG_PITCH: float = 0.62
const WORK_SOUND_MAX_DISTANCE: float = 18.0
const MURMUR_PATH: String = "res://shared_assets/audio/murmullo_plaza.wav"
const MURMUR_VOLUME_DB: float = -8.0
const MURMUR_SILENT_DB: float = -40.0
const MURMUR_FADE_IN: float = 2.0
const MURMUR_FADE_OUT: float = 5.0
## Modelos definitivos (alcance §6.1 y §7). Cada bloqueo tiene un hueco que
## carga el primer archivo existente de su lista; sin archivo, sigue el bloqueo.
const MODEL_DIR: String = "res://campaigns/01_pachacutec/assets/models/"
const MODEL_HOUSES: Array[String] = ["pch_house_a.glb", "pch_house_b.glb", "pch_house_c.glb", "pch_house_d.glb", "pch_house_e.glb"]
## Elenco del acto I: modelos MakeHuman/Rocketbox ya versionados (CC0/MIT),
## con esqueleto, animaciones y ropa propios. UAL1 queda para los actos II y
## III y como respaldo.
const CHARACTER_MODELS: Dictionary[String, String] = {
	"Tejedora": "pch_npc_weaver.glb",
	"Agricultor": "pch_npc_farmer.glb",
	"Mensajero": "pch_npc_messenger.glb",
	"Curaca": "pch_npc_curaca.glb",
	"Principal1": "pch_npc_principal.glb",
	"Principal2": "pch_npc_principal.glb",
	"Habitante1": "pch_npc_villager.glb",
	"Habitante2": "pch_npc_villager_b.glb",
	"Habitante3": "pch_npc_villager_c.glb",
}
## Altura visible de cada papel, en metros. Los GLB venían de 1,34 a 1,68 y la
## diferencia se notaba junto al jugador (1,70). La tejedora va sentada: con 0
## solo se apoya en el suelo, sin escalar.
const CHARACTER_HEIGHTS: Dictionary[String, float] = {
	"Tejedora": 0.0,
	"Agricultor": 1.57,
	"Mensajero": 1.61,
	"Curaca": 1.65,
	"Principal1": 1.63,
	"Principal2": 1.63,
	"Habitante1": 1.53,
	"Habitante2": 1.56,
	"Habitante3": 1.50,
}
const MODEL_QUERO: String = "pch_quero.glb"
const MODEL_PUTUTU: String = "pch_pututu.glb"
const MODEL_OFFERING: String = "pch_offering_shrine.glb"
## Atado de coca y maíz que aparece al dejar la ofrenda (PCH-012).
const MODEL_OFFERING_GIFT: String = "pch_offering_gift.glb"
const MODEL_LOOM: String = "pch_loom.glb"
## Props junto a la puerta de las viviendas (PCH-019 y PCH-020).
const MODEL_PROP_JAR: String = "pch_prop_jar.glb"
const MODEL_PROP_FIREWOOD: String = "pch_prop_firewood.glb"
## Fondo de las viviendas A, B y C, para dejar los props delante del muro.
const HOUSE_DEPTHS: Array[float] = [5.0, 4.6, 4.0, 5.4, 3.8]
## Lado izquierdo de la puerta de cada variante, donde van la leña o un cántaro.
const HOUSE_LEFT_PROP_X: Array[float] = [-2.1, -2.4, -1.7, -2.5, -1.5]
## Giro de cada vivienda respecto a la plaza, en grados: sin él, todas la
## miran de frente y el trazado parece planificado (ADR-0021).
const HOUSE_YAW_JITTER: Array[float] = [7.0, -11.0, 4.0, -6.0, 10.0, -8.0, 5.0, -4.0]
## Corrales de pirca seca en las afueras (ADR-0021): centro, planta (x, z) y
## lado de la entrada. Lejos de los caminos y de los paseos de los vecinos.
const CORRALS: Array[Array] = [
	[Vector3(-31.0, 0.0, -12.0), Vector2(7.0, 5.5), Vector3.RIGHT],
	[Vector3(-24.0, 0.0, -27.0), Vector2(6.0, 5.0), Vector3.BACK],
]
const CORRAL_WALL_HEIGHT: float = 1.0
const CORRAL_WALL_THICKNESS: float = 0.5
const CORRAL_ENTRANCE: float = 1.4
## Lo que el muro se hunde en el suelo para no quedar en el aire en las lomas.
const CORRAL_SINK: float = 0.35
## Poyo de piedra bajo el quero y el pututu (ADR-0021).
const MODEL_PEDESTAL: String = "pch_pedestal.glb"
const PROP_WALL_GAP: float = 0.45
const MODEL_COMMONER: String = "pch_npc_commoner.glb"
const MODEL_AUTHORITY: String = "pch_npc_authority.glb"
## Base de cada malla de bloqueo de los objetos (su origen está en el centro).
const QUERO_BASE: Vector3 = Vector3(0.0, -0.11, 0.0)
const PUTUTU_BASE: Vector3 = Vector3(0.0, -0.2, 0.0)
const OFFERING_BASE: Vector3 = Vector3(0.0, -0.15, 0.0)
const LOOM_POSITION: Vector3 = Vector3(-10.0, 0.0, 6.2)
## Fuego comunal de la plaza: punto de reunión y foco de luz y sonido.
const FIRE_PIT_POSITION: Vector3 = Vector3(-6.0, 0.0, 7.0)
## Distancia entre la tejedora arrodillada y el extremo del telar.
const WEAVER_LOOM_GAP: float = 0.22
## Tapa del extremo alto de cada rampa: grosor y margen bajo la superficie.
const TERRACE_CAP_THICKNESS: float = 0.3
const TERRACE_CAP_INSET: float = 0.05
## Introducción antes de tomar el control (ADR-0023). Sustituye al rótulo de
## lugar y época de ADR-0012. La primera tarjeta es la nota histórica (ADR-0024).
const INTRO_KEYS: Array[StringName] = [&"PCH_INTRO_NOTE", &"PCH_INTRO_1", &"PCH_INTRO_2", &"PCH_INTRO_3"]
## Controles en pantalla al tomar el control (ADR-0024).
const CONTROLS_HINT_KEY: StringName = &"UI_CONTROLS_HINT"
const CONTROLS_HINT_SECONDS: float = 8.0
## Fondos de la introducción (ADR-0025), por tarjeta: la nota sobre negro, los
## Andes y la llacta con tomas del mundo, y el valle del Cusco con el mapa.
const INTRO_OPAQUE: Array[bool] = [true, false, false, false]
const INTRO_SHOT_ANDES: int = 1
const INTRO_MAP_CARD: int = 2
const INTRO_SHOT_LLACTA: int = 3
## Música de la introducción (ADR-0029, sustituye a ADR-0027 y ADR-0028):
## montaje de 40 s de «Over The Andes» (Pixabay) con su entrada, su clímax y
## su final; se funde al tomar el control y deja solo el viento.
const INTRO_MUSIC_PATH: String = "res://shared_assets/audio/musica_intro_over_the_andes.ogg"
const INTRO_MUSIC_VOLUME_DB: float = -6.0
const INTRO_MUSIC_FADE: float = 3.0
## Toma de los Andes: desde la cresta del suroeste, mirando al otro lado del
## valle, con un giro lento.
const ANDES_FROM: Vector3 = Vector3(-30.0, 26.0, 66.0)
const ANDES_FROM_LOOK: Vector3 = Vector3(-10.0, 4.0, -70.0)
const ANDES_TO: Vector3 = Vector3(-18.0, 24.0, 66.0)
const ANDES_TO_LOOK: Vector3 = Vector3(20.0, 4.0, -70.0)
## Toma de la llacta: baja desde lo alto del camino sur hasta los ojos del
## jugador, que empieza ahí.
const LLACTA_FROM: Vector3 = Vector3(9.0, 7.0, 64.0)
const LLACTA_FROM_LOOK: Vector3 = Vector3(0.0, 2.0, 4.0)
const INTRO_HINT_KEY: StringName = &"PCH_INTRO_HINT"
## «Hablar»: escena del cuerpo interactuable y pausa del vecino que habla.
const TALK_SCENE: String = "res://campaigns/01_pachacutec/scenes/npcs/npc_talk.tscn"
const TALK_HOLD_SECONDS: float = 7.0
## Vecino que recibe al jugador junto al camino sur (ADR-0013). Se queda a unos
## diez metros de la aparición: saluda antes de que el jugador pueda mirarle la
## cara de cerca.
const GREETER_POINT: Vector3 = Vector3(3.2, 0.0, 12.0)
## Tarjeta de fin (ADR-0026, sustituye el retraso de 50 s de ADR-0013): el
## evento ya termina unos 8 s después del último subtítulo, así que la tarjeta
## se funde casi enseguida, mientras la comitiva se aleja.
const END_CARD_DELAY: float = 0.5
const END_TITLE_KEY: StringName = &"PCH_END_TITLE"
const END_HINT_KEY: StringName = &"PCH_END_HINT"
const RESTART_KEY: Key = KEY_R
## Velocidad de paseo de los vecinos antes de la noticia.
const NEIGHBOR_WALK_SPEED: float = 1.4
## Tierra de cultivo sobre cada terraza: surcos paralelos al muro de
## contención (siguen la curva de nivel), separados SPACING metros.
const FIELD_SOIL_COLOR: Color = Color(0.42, 0.32, 0.23, 1.0)
const FIELD_RIDGE_COLOR: Color = Color(0.52, 0.4, 0.28, 1.0)
const FIELD_FURROW_SPACING: float = 0.55
const FIELD_RIDGE_HEIGHT: float = 0.09
const FIELD_LIFT: float = 0.02
const FIELD_MARGIN: float = 0.25
## Juntas entre las piedras de los muros de contención: es el color del bloque
## de colisión, que asoma entre las piedras de StoneWall. Oscuro, como las
## juntas de la piedra seca sin mortero que Cobo describe en los andenes del
## Cusco (PCH-008).
const TERRACE_MORTAR_COLOR: Color = Color(0.24, 0.22, 0.2, 1.0)
## Rampas de las terrazas: piedra clara de camino, para que se vea por dónde
## se sube.
const RAMP_COLOR: Color = Color(0.62, 0.56, 0.47, 1.0)
## Superficie de los muros y rampas de las terrazas.
const SURFACE_STONE: StringName = &"stone"

## Objetivo visible del evento narrativo. Solo cubre las fases del mensajero.
enum Objective { LISTEN, PUTUTU, LEAVE, NONE }

const OBJECTIVE_KEYS: Array[StringName] = [
	&"PCH_OBJ_LISTEN",
	&"PCH_OBJ_PUTUTU",
	&"PCH_OBJ_LEAVE",
]

## Encargos del acto I. El tercero dispara la llegada del mensajero.
const TASK_SCENE: String = "res://campaigns/01_pachacutec/scenes/objects/task_point.tscn"
const TASK_IDS: Array[StringName] = [&"agua", &"maiz", &"telar", &"pirca"]
const TASK_PROMPTS: Array[StringName] = [
	&"PCH_TASK_AGUA", &"PCH_TASK_MAIZ", &"PCH_TASK_TELAR", &"PCH_TASK_PIRCA",
]
const TASK_DONE_KEYS: Array[StringName] = [
	&"PCH_TASK_AGUA_DONE", &"PCH_TASK_MAIZ_DONE", &"PCH_TASK_TELAR_DONE", &"PCH_TASK_PIRCA_DONE",
]
const TASK_POSITIONS: Array[Vector3] = [
	Vector3(14.0, 0.0, 8.0),
	Vector3(-16.0, 0.0, 8.0),
	Vector3(-12.0, 0.0, 9.0),
	Vector3(-27.5, 0.0, -12.0),
]
## Modelo visible de cada encargo; vacío si el objeto ya está en el mundo.
const TASK_MODELS: Array[String] = [MODEL_PROP_JAR, MODEL_PEDESTAL, "", ""]
## Encargos necesarios para que llegue el mensajero.
const TASKS_REQUIRED: int = 3

## Argumentos de desarrollo (después de `--`): `--skip-intro` entra directo al
## mundo y `--spawn=spawn|plaza|mirador` elige el punto de aparición.
const SKIP_INTRO_ARG: String = "--skip-intro"
const SPAWN_ARG: String = "--spawn="
const SPAWN_POINTS: Dictionary[String, String] = {
	"spawn": "PlayerSpawn",
	"plaza": "PlazaPoint",
	"mirador": "Mirador",
}

## Mancha de contacto bajo los personajes: sin ella, los pies parecen flotar y
## la escena pierde realismo aunque la iluminación sea correcta.

## Cuándo se muestra la introducción: AUTO, solo si el mundo es la escena
## principal (partida real y reinicio con R), para que las pruebas que cargan
## el mundo directamente no esperen a las tarjetas; ALWAYS y NEVER la fuerzan.
enum IntroMode { AUTO, ALWAYS, NEVER }

@export var intro_mode: IntroMode = IntroMode.AUTO

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var sun: DirectionalLight3D = $Inti
@onready var terrain: Node3D = $Terrain
@onready var player_spawn: Marker3D = $PlayerSpawn
@onready var player: PlayerFPS = $PlayerFPS
@onready var hud: PlayerHud = $UILayer/HUD
@onready var environment_controller: EnvironmentQualityController = $EnvironmentQualityController

var _intro: IntroCards = null
var _director: IntroDirector = null
var _intro_music: AudioStreamPlayer = null
var _music_fade_remaining: float = -1.0
var _end_card_remaining: float = -1.0
var _end_card_shown: bool = false
var _objective: int = -1
## Núcleo RPG de la partida. Vive en el jugador y no conoce la campaña.
var character: CharacterState = null
var inventory: Inventory = null
var journal: Journal = null
var dialogue: DialogueRunner = null

var _dialogue_speaker: StringName = &""
var _dialogue_text: StringName = &""
var _dialogue_choices: Array[StringName] = []

var _tasks_done: Dictionary[StringName, bool] = {}
## Grupo de autoridades que conversa por turnos antes de la noticia.
var _ambient_group: Array[NpcActor] = []
var _ambient_timer: float = 6.0
var _ambient_index: int = 0
var _oficio: StringName = &""


func _ready() -> void:
	if SessionLog.is_active():
		var session_profile: GraphicsProfile = GraphicsSettings.get_active_profile()
		if session_profile != null:
			SessionLog.mark(&"profile", session_profile.profile_name)
	var with_intro: bool = should_play_intro()
	var event: MessengerEvent = $EventController as MessengerEvent
	if event != null and with_intro:
		# El reloj del mensajero espera a que termine la introducción.
		event.start_on_bind = false
		event.set_process(false)
	_build_terrain()
	_build_ground_clutter()
	_build_llacta()
	_build_distant_ranges()
	_build_clouds()
	_build_dust()
	player.global_position = _debug_spawn_position()
	hud.bind(player, player.stamina)
	_setup_rpg()
	_setup_act_one()
	_setup_footsteps()
	environment_controller.bind(world_environment, sun)
	if with_intro:
		_start_intro()


## Punto de aparición: el de la escena, salvo que `--spawn=<punto>` pida otro.
func _debug_spawn_position() -> Vector3:
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with(SPAWN_ARG):
			continue
		var requested: String = arg.substr(SPAWN_ARG.length())
		var node_name: String = str(SPAWN_POINTS.get(requested, ""))
		if node_name.is_empty():
			continue
		var marker: Marker3D = get_node_or_null(node_name) as Marker3D
		if marker != null:
			return marker.global_position
	return player_spawn.global_position


## Indica si esta partida empieza con la introducción.
func should_play_intro() -> bool:
	match intro_mode:
		IntroMode.ALWAYS:
			return true
		IntroMode.NEVER:
			return false
	return is_inside_tree() and get_tree().current_scene == self and not _skips_intro()


## Indica si `--skip-intro` pidió entrar directamente al mundo.
static func _skips_intro() -> bool:
	return OS.get_cmdline_user_args().has(SKIP_INTRO_ARG)


## Objetivo a la vista, para las pruebas y la instrumentación.
func get_objective() -> int:
	return _objective


## Texto del objetivo a la vista, o cadena vacía.
func get_objective_text() -> String:
	return hud.get_objective_text() if hud != null else ""


## Cambia el objetivo si avanza. Nunca retrocede: las tareas son opcionales en
## cuanto el evento narrativo toma el mando.
func _advance_objective(step: int) -> void:
	if step <= _objective:
		return
	_show_objective(step)


func _show_objective(step: int) -> void:
	_objective = step
	if hud == null:
		return
	if step == Objective.NONE or step >= OBJECTIVE_KEYS.size():
		hud.clear_objective()
		return
	var key: StringName = OBJECTIVE_KEYS[step]
	hud.show_objective(tr(String(key)))
	SessionLog.mark(&"objective", String(key))


## Indica si la introducción está a la vista.
func is_intro_playing() -> bool:
	return _intro != null and _intro.is_playing()


## Tarjetas de la introducción, para las pruebas.
func get_intro() -> IntroCards:
	return _intro


func _start_intro() -> void:
	# El jugador no se mueve, no mira ni interactúa hasta que termina.
	player.process_mode = Node.PROCESS_MODE_DISABLED
	_intro = IntroCards.new()
	_intro.name = "IntroCards"
	hud.add_child(_intro)
	_intro.finished.connect(_on_intro_finished)
	_intro.set_overlay(INTRO_MAP_CARD, IntroMap.new())
	_director = IntroDirector.new()
	_director.name = "IntroDirector"
	add_child(_director)
	var player_camera: Camera3D = player.get_node("Head/Camera3D") as Camera3D
	_director.set_shot(INTRO_SHOT_ANDES, _shot(ANDES_FROM, ANDES_FROM_LOOK), _shot(ANDES_TO, ANDES_TO_LOOK))
	_director.set_shot_to_player(INTRO_SHOT_LLACTA, _shot(LLACTA_FROM, LLACTA_FROM_LOOK))
	_director.bind(_intro, player_camera)
	_start_intro_music()
	var texts: Array[String] = []
	for key: StringName in INTRO_KEYS:
		texts.append(tr(String(key)))
	_intro.play(texts, tr(String(INTRO_HINT_KEY)), INTRO_OPAQUE)


## Encuadre de cámara en [param at] (altura sobre el terreno) mirando a
## [param target].
func _shot(at: Vector3, target: Vector3) -> Transform3D:
	var position_world: Vector3 = Vector3(at.x, _height_at(at.x, at.z) + at.y, at.z)
	return Transform3D(Basis.looking_at(target - position_world, Vector3.UP), position_world)


## Director de las tomas de la introducción, para las pruebas.
func get_intro_director() -> IntroDirector:
	return _director


func _on_intro_finished() -> void:
	SessionLog.mark(&"control_taken")
	player.process_mode = Node.PROCESS_MODE_INHERIT
	if _intro_music != null and _intro_music.playing:
		_music_fade_remaining = INTRO_MUSIC_FADE
	hud.show_hint(tr(String(CONTROLS_HINT_KEY)), CONTROLS_HINT_SECONDS)
	var event: MessengerEvent = $EventController as MessengerEvent
	if event != null:
		event.begin()


func _process(delta: float) -> void:
	advance_end_card(delta)
	advance_intro_music(delta)
	_advance_ambient(delta)


## Las autoridades intercambian un gesto de conversación por turnos mientras
## esperan la noticia. No mueve a nadie ni cambia el evento: solo evita que el
## grupo del curaca quede como estatuas hasta que llega el mensajero.
func _advance_ambient(delta: float) -> void:
	if _ambient_group.is_empty() or hud == null or hud.is_dialogue_open():
		return
	var event: MessengerEvent = $EventController as MessengerEvent
	if event != null and event.phase != MessengerEvent.Phase.IDLE:
		return
	if is_intro_playing():
		return
	_ambient_timer -= delta
	if _ambient_timer > 0.0:
		return
	var actor: NpcActor = _ambient_group[_ambient_index % _ambient_group.size()]
	_ambient_index += 1
	_ambient_timer = 7.0 + 1.5 * float(_ambient_index % 3)
	if actor == null or actor.moving:
		return
	actor.perform(&"talk", 2.4)


## Música de la introducción, para las pruebas.
func get_intro_music() -> AudioStreamPlayer:
	return _intro_music


## Funde la música de la introducción al tomar el control; pública para poder
## probarla sin depender de los fotogramas.
func advance_intro_music(delta: float) -> void:
	if _intro_music == null or _music_fade_remaining < 0.0:
		return
	_music_fade_remaining -= delta
	if _music_fade_remaining <= 0.0:
		_music_fade_remaining = -1.0
		_intro_music.stop()
		return
	var level: float = _music_fade_remaining / INTRO_MUSIC_FADE
	_intro_music.volume_db = INTRO_MUSIC_VOLUME_DB + linear_to_db(maxf(level, 0.001))


func _start_intro_music() -> void:
	var stream: AudioStream = load(INTRO_MUSIC_PATH) as AudioStream
	if stream == null:
		return
	_intro_music = AudioStreamPlayer.new()
	_intro_music.name = "IntroMusic"
	_intro_music.stream = stream
	_intro_music.volume_db = INTRO_MUSIC_VOLUME_DB
	add_child(_intro_music)
	_intro_music.play()


## Cuenta atrás de la tarjeta de fin; pública para poder probarla.
func advance_end_card(delta: float) -> void:
	if _end_card_shown or _end_card_remaining < 0.0:
		return
	_end_card_remaining -= delta
	if _end_card_remaining > 0.0:
		return
	_end_card_shown = true
	if hud != null:
		hud.show_end_card(tr(String(END_TITLE_KEY)), tr(String(END_HINT_KEY)))
	SessionLog.mark(&"end_card")


## Indica si la tarjeta de fin está a la vista.
func is_end_card_shown() -> bool:
	return _end_card_shown


func _on_event_finished() -> void:
	_end_card_remaining = END_CARD_DELAY


func _unhandled_input(event: InputEvent) -> void:
	if _end_card_shown:
		# Con la tarjeta de fin, R reinicia y Esc sale (no pausa).
		if event.is_action_pressed("pause"):
			get_viewport().set_input_as_handled()
			var manager: Node = get_node_or_null("/root/GameManager")
			if manager != null:
				manager.call("request_quit")
			return
		var restart: InputEventKey = event as InputEventKey
		if restart != null and restart.pressed and not restart.echo and restart.keycode == RESTART_KEY:
			get_viewport().set_input_as_handled()
			get_tree().change_scene_to_file("res://campaigns/01_pachacutec/scenes/world/paso.tscn")
			return
	if event.is_action_pressed("journal"):
		if hud == null or journal == null or _end_card_shown or is_intro_playing():
			return
		if hud.is_dialogue_open():
			return
		if hud.is_journal_open():
			hud.hide_journal()
			player.set_controls_locked(false)
		else:
			hud.show_journal(journal)
			player.set_controls_locked(true)
		get_viewport().set_input_as_handled()
		return
	if not OS.is_debug_build():
		return
	if SessionLog.is_active():
		# En una sesión de prueba el perfil gráfico no cambia (alcance §11).
		return
	if not (event is InputEventKey):
		return
	var key_event: InputEventKey = event as InputEventKey
	if key_event.pressed and not key_event.echo and key_event.keycode == DEBUG_PROFILE_KEY:
		GraphicsSettings.cycle_profile()
		get_viewport().set_input_as_handled()


## Piedras sueltas sobre la tierra: dan escala y rompen la alfombra de textura.
func _build_ground_clutter() -> void:
	var clutter: GroundClutter = GroundClutter.new()
	clutter.name = "GroundClutter"
	add_child(clutter)
	clutter.build(_height_at, Vector3.ZERO, 78.0, 8.0)


func _build_terrain() -> void:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var step: float = TERRAIN_SIZE / float(TERRAIN_RESOLUTION)
	var half: float = TERRAIN_SIZE * 0.5
	for zi: int in range(TERRAIN_RESOLUTION):
		for xi: int in range(TERRAIN_RESOLUTION):
			var x0: float = -half + step * float(xi)
			var z0: float = -half + step * float(zi)
			var x1: float = x0 + step
			var z1: float = z0 + step
			var p00: Vector3 = Vector3(x0, _height_at(x0, z0), z0)
			var p10: Vector3 = Vector3(x1, _height_at(x1, z0), z0)
			var p01: Vector3 = Vector3(x0, _height_at(x0, z1), z1)
			var p11: Vector3 = Vector3(x1, _height_at(x1, z1), z1)
			for vertex: Vector3 in [p00, p10, p11, p00, p11, p01]:
				surface.add_vertex(vertex)
	surface.generate_normals()
	var mesh: ArrayMesh = surface.commit()
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "TerrainMesh"
	mesh_instance.mesh = mesh
	var material: ShaderMaterial = SurfaceMaterials.terrain_material(GRASS_COLOR, ROCK_COLOR, DIRT_COLOR)
	material.set_shader_parameter("steep_height_range", Vector2(ROCK_FROM_HEIGHT, ROCK_FULL_HEIGHT))
	mesh_instance.material_override = material
	terrain.add_child(mesh_instance)
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "TerrainBody"
	body.collision_layer = 1
	body.collision_mask = 0
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.name = "TerrainCollision"
	collision.shape = mesh.create_trimesh_shape()
	body.add_child(collision)
	terrain.add_child(body)


func _height_at(x: float, z: float) -> float:
	var distance: float = Vector2(x, z).length()
	var blend: float = clampf((distance - PLATEAU_RADIUS) / 15.0, 0.0, 1.0)
	var height: float = 0.7 * sin(x * 0.06) * cos(z * 0.07) + 0.3 * sin((x + z) * 0.11)
	return height * blend + relief_height_at(x, z) + ridge_height_at(x, z)


## Cúpula de nubes procedurales. Es una esfera grande vista por dentro: el
## cielo físico sigue siendo el fondo y la cúpula solo añade las nubes altas.
func _build_clouds() -> void:
	if not ResourceLoader.exists(CLOUD_SHADER_PATH):
		return
	var shader: Shader = load(CLOUD_SHADER_PATH) as Shader
	if shader == null:
		return
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = CLOUD_DOME_RADIUS
	sphere.height = CLOUD_DOME_RADIUS * 2.0
	sphere.radial_segments = CLOUD_DOME_SEGMENTS
	sphere.rings = CLOUD_DOME_RINGS
	var dome: MeshInstance3D = MeshInstance3D.new()
	dome.name = "CloudDome"
	dome.mesh = sphere
	dome.material_override = material
	dome.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	dome.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(dome)


## Polvo en suspensión sobre la plaza: motas pequeñas y lentas que dan aire de
## lugar habitado y seco. Sin textura externa ni luz propia.
func _build_dust() -> void:
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.name = "Dust"
	particles.amount = 160
	particles.lifetime = 10.0
	particles.preprocess = 5.0
	particles.local_coords = false
	particles.visibility_aabb = AABB(Vector3(-34.0, -2.0, -34.0), Vector3(68.0, 18.0, 68.0))
	var process: ParticleProcessMaterial = ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(24.0, 3.0, 24.0)
	process.direction = Vector3(0.25, 0.05, -0.1)
	process.spread = 40.0
	process.initial_velocity_min = 0.03
	process.initial_velocity_max = 0.14
	process.gravity = Vector3(0.0, -0.01, 0.0)
	process.scale_min = 0.5
	process.scale_max = 1.2
	process.color = Color(1.0, 0.94, 0.82, 1.0)
	var gradient: Gradient = Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
	gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 32
	texture.height = 32
	var mesh: QuadMesh = QuadMesh.new()
	mesh.size = Vector2(0.06, 0.06)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.albedo_texture = texture
	material.albedo_color = Color(1.0, 0.96, 0.88, 0.16)
	material.disable_receive_shadows = true
	mesh.material = material
	particles.draw_pass_1 = mesh
	particles.process_material = process
	particles.position = Vector3(0.0, 4.0, 0.0)
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(particles)


## Dos anillos de montañas lejanas, uno delante del otro. Son solo siluetas:
## no tienen colisión ni sombra y quedan fuera del límite jugable.
func _build_distant_ranges() -> void:
	_build_range("DistantRangeNear", DISTANT_NEAR_RADIUS, DISTANT_NEAR_BASE,
		DISTANT_NEAR_AMPLITUDE, DISTANT_NEAR_COLOR)
	_build_range("DistantRangeMid", DISTANT_MID_RADIUS, DISTANT_MID_BASE,
		DISTANT_MID_AMPLITUDE, DISTANT_MID_COLOR)
	_build_range("DistantRangeFar", DISTANT_FAR_RADIUS, DISTANT_FAR_BASE,
		DISTANT_FAR_AMPLITUDE, DISTANT_FAR_COLOR)


func _build_range(node_name: String, radius: float, base_height: float, amplitude: float, color: Color) -> void:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Perspectiva aérea pintada a mano: la niebla automática convertía las tres
	# cordilleras en una banda plana. El pie se aclara hacia el horizonte y la
	# cumbre conserva el tono, así que la distancia se lee por capas.
	for index: int in range(DISTANT_SEGMENTS):
		var angle0: float = TAU * float(index) / float(DISTANT_SEGMENTS)
		var angle1: float = TAU * float(index + 1) / float(DISTANT_SEGMENTS)
		var height0: float = _distant_height(angle0, base_height, amplitude)
		var height1: float = _distant_height(angle1, base_height, amplitude)
		var bottom0: Vector3 = Vector3(cos(angle0) * radius, DISTANT_BOTTOM, sin(angle0) * radius)
		var bottom1: Vector3 = Vector3(cos(angle1) * radius, DISTANT_BOTTOM, sin(angle1) * radius)
		var top0: Vector3 = Vector3(cos(angle0) * radius, height0, sin(angle0) * radius)
		var top1: Vector3 = Vector3(cos(angle1) * radius, height1, sin(angle1) * radius)
		# El terreno tapa el pie de la silueta: no hace falta degradado alfa.
		surface.add_vertex(bottom0)
		surface.add_vertex(bottom1)
		surface.add_vertex(top1)
		surface.add_vertex(bottom0)
		surface.add_vertex(top1)
		surface.add_vertex(top0)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.disable_fog = true
	var range_node: MeshInstance3D = MeshInstance3D.new()
	range_node.name = node_name
	range_node.mesh = surface.commit()
	range_node.material_override = material
	range_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	range_node.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(range_node)


## Altura de la silueta de la cordillera para un ángulo; suma de senos para
## que tenga picos y no un borde liso.
static func _distant_height(angle: float, base_height: float, amplitude: float) -> float:
	var ridge: float = 0.5 + 0.5 * sin(angle * 5.0 + 0.4) * sin(angle * 9.0 - 0.9)
	ridge = pow(maxf(ridge, 0.0), 0.65)
	var detail: float = 0.16 * sin(angle * 31.0 + 1.7) + 0.09 * sin(angle * 53.0 - 0.3) + 0.05 * sin(angle * 89.0 + 0.5)
	return base_height + amplitude * clampf(ridge + detail, 0.0, 1.0)


## Lomas suaves del campo, cero en la plaza, las casas, las terrazas y los
## caminos (alcance §3).
static func relief_height_at(x: float, z: float) -> float:
	var mask: float = smoothstep(RELIEF_START, RELIEF_FULL, Vector2(x, z).length())
	if mask <= 0.0:
		return 0.0
	var outside_x: float = maxf(maxf(TERRACE_ZONE.position.x - x, x - TERRACE_ZONE.end.x), 0.0)
	var outside_z: float = maxf(maxf(TERRACE_ZONE.position.y - z, z - TERRACE_ZONE.end.y), 0.0)
	mask *= smoothstep(0.0, RELIEF_EDGE, maxf(outside_x, outside_z))
	# Caminos norte y sur (todo el eje) y caminos este y oeste.
	mask *= smoothstep(PATH_CLEAR, PATH_BLEND, absf(x))
	mask *= maxf(smoothstep(PATH_CLEAR, PATH_BLEND, absf(z)), smoothstep(36.0, 42.0, absf(x)))
	if mask <= 0.0:
		return 0.0
	var wave: float = 0.6 * sin(x * 0.09 + 1.3) * cos(z * 0.08 - 0.4) + 0.4 * sin((x - z) * 0.15 + 0.7)
	return RELIEF_AMPLITUDE * mask * (wave + 0.35)


## Altura añadida por la cresta del borde en (x, z); cero en el interior y en
## el paso norte.
static func ridge_height_at(x: float, z: float) -> float:
	var edge_distance: float = maxf(absf(x), absf(z))
	var rise: float = smoothstep(RIDGE_START, RIDGE_FULL, edge_distance)
	if rise <= 0.0:
		return 0.0
	var roughness: float = 1.0 + 0.18 * sin(x * 0.21) * cos(z * 0.17)
	var opening: float = 1.0
	if z < 0.0:
		opening = smoothstep(PASS_HALF_WIDTH, PASS_EDGE, absf(x))
	return RIDGE_HEIGHT * rise * roughness * opening


func _build_llacta() -> void:
	var llacta: Node3D = $Llacta
	var boundary: Node3D = $Boundary
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, Color(0.56, 0.54, 0.50, 1.0))
	var thatch: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.THATCH, Color(0.50, 0.40, 0.22, 1.0))
	var dirt: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.DIRT, DIRT_COLOR)

	# La plaza y los caminos marcan las zonas de tierra apisonada. Las pinta el
	# terreno con borde irregular; las cajas quedan ocultas como referencia
	# (una losa de bordes rectos delata el bloqueo).
	var ground_areas: Array[MeshInstance3D] = [
		_add_visual_box(llacta, "Plaza", Vector3(0.0, 0.03, 0.0), Vector3(26.0, 0.06, 26.0), dirt),
		_add_visual_box(llacta, "PathSouth", Vector3(0.0, 0.035, 30.0), Vector3(4.0, 0.07, 30.0), dirt),
		_add_visual_box(llacta, "PathNorth", Vector3(0.0, 0.035, -35.0), Vector3(4.0, 0.07, 30.0), dirt),
		_add_visual_box(llacta, "PathEast", Vector3(24.0, 0.035, 0.0), Vector3(22.0, 0.07, 4.0), dirt),
		_add_visual_box(llacta, "PathWest", Vector3(-24.0, 0.035, 0.0), Vector3(22.0, 0.07, 4.0), dirt),
	]
	for area: MeshInstance3D in ground_areas:
		area.visible = false
	var terrain_mesh: MeshInstance3D = terrain.get_node_or_null("TerrainMesh") as MeshInstance3D
	if terrain_mesh != null and terrain_mesh.material_override is ShaderMaterial:
		SurfaceMaterials.set_overlay_areas(terrain_mesh.material_override as ShaderMaterial, ground_areas)

	var houses: Node3D = Node3D.new()
	houses.name = "Houses"
	llacta.add_child(houses)
	# Tres grupos que dejan libres los ejes de los caminos: viviendas oeste,
	# viviendas este y las dos casas del camino norte.
	var positions: Array[Vector3] = [
		Vector3(-18.0, 0.0, 11.0),
		Vector3(-27.0, 0.0, 6.0),
		Vector3(-20.0, 0.0, -9.0),
		Vector3(20.0, 0.0, 9.0),
		Vector3(24.0, 0.0, 14.0),
		Vector3(18.0, 0.0, -11.0),
		Vector3(-8.0, 0.0, -22.0),
		Vector3(10.0, 0.0, -20.0),
	]
	for index: int in range(positions.size()):
		_add_house(houses, index, positions[index], stone, thatch)

	# Ichu y queñua (PCH-013) fuera de la plaza, los caminos y las casas.
	var vegetation: LlactaVegetation = LlactaVegetation.new()
	vegetation.name = "Vegetation"
	llacta.add_child(vegetation)
	vegetation.build(_height_at, positions)
	# El viento mece el ichu y la queñua y modula el ambiente.
	var wind: LlactaWind = LlactaWind.new()
	wind.name = "Wind"
	wind.materials = vegetation.wind_materials
	add_child(wind)

	_add_community_fire(llacta)
	var corrals: Node3D = Node3D.new()
	corrals.name = "Corrals"
	llacta.add_child(corrals)
	for index: int in range(CORRALS.size()):
		var corral: Array = CORRALS[index]
		var corral_center: Vector3 = corral[0]
		var corral_size: Vector2 = corral[1]
		var corral_entrance: Vector3 = corral[2]
		_add_corral(corrals, "Corral%02d" % (index + 1), corral_center, corral_size, corral_entrance)

	var terraces: Node3D = Node3D.new()
	terraces.name = "Terraces"
	llacta.add_child(terraces)
	_add_terrace(terraces, "Terrace01", 34.0, 0.0, 0.8, stone)
	_add_terrace(terraces, "Terrace02", 42.0, 0.8, 1.6, stone)
	_add_terrace(terraces, "Terrace03", 50.0, 1.6, 2.4, stone, true)

	for pedestal: StaticBody3D in [
		_add_box_body(llacta, "PedestalQuero", Vector3(4.0, 0.4, 4.0), Vector3(0.6, 0.8, 0.6), stone, 1),
		_add_box_body(llacta, "PedestalPututu", Vector3(-4.0, 0.4, 4.0), Vector3(0.6, 0.8, 0.6), stone, 1),
	]:
		_attach_pedestal(pedestal)

	_add_box_body(boundary, "North", Vector3(0.0, 1.0, -BOUNDARY_RADIUS), Vector3(BOUNDARY_RADIUS * 2.0, 2.0, 1.0), stone, 1)
	_add_box_body(boundary, "South", Vector3(0.0, 1.0, BOUNDARY_RADIUS), Vector3(BOUNDARY_RADIUS * 2.0, 2.0, 1.0), stone, 1)
	_add_box_body(boundary, "East", Vector3(BOUNDARY_RADIUS, 1.0, 0.0), Vector3(1.0, 2.0, BOUNDARY_RADIUS * 2.0), stone, 1)
	_add_box_body(boundary, "West", Vector3(-BOUNDARY_RADIUS, 1.0, 0.0), Vector3(1.0, 2.0, BOUNDARY_RADIUS * 2.0), stone, 1)

	var npcs: Node3D = Node3D.new()
	npcs.name = "NPCs"
	llacta.add_child(npcs)
	# La tejedora se arrodilla en el extremo del telar de cintura (PCH-010,
	# ADR-0015), mirando a lo largo del telar hacia la plaza.
	var weaver: NpcActor = _add_npc(npcs, "Tejedora", weaver_position(), Color(0.62, 0.38, 0.3, 1.0))
	# Junto a la rampa de la primera terraza, al alcance para hablarle.
	var farmer: NpcActor = _add_npc(npcs, "Agricultor", Vector3(36.5, 0.8, -3.0), Color(0.45, 0.35, 0.25, 1.0))
	var messenger: NpcActor = _add_npc(npcs, "Mensajero", Vector3(0.0, 0.0, -60.0), Color(0.75, 0.65, 0.4, 1.0))
	messenger.walk_speed = MessengerEvent.MESSENGER_RUN_SPEED
	var curaca: NpcActor = _add_npc(npcs, "Curaca", Vector3(-7.0, 0.0, -3.0), Color(0.72, 0.55, 0.45, 1.0))
	var principal_one: NpcActor = _add_npc(npcs, "Principal1", Vector3(-8.5, 0.0, -1.0), Color(0.55, 0.42, 0.32, 1.0))
	var principal_two: NpcActor = _add_npc(npcs, "Principal2", Vector3(-8.6, 0.0, 0.7), Color(0.5, 0.4, 0.3, 1.0))
	# Dos hombres principales conversan de perfil junto al curaca: el ojo lee
	# una conversación en vez de examinar una cara de frente. El reposo
	# alternativo evita el gesto amplio de «talk», que a corta distancia
	# convierte la silueta en un espantapájaros.
	principal_one.face(principal_two.global_position, true)
	principal_two.face(principal_one.global_position, true)
	principal_two.set_idle_animation(&"idle_b")
	_ambient_group = [curaca, principal_one, principal_two]
	var neighbor_one: NpcActor = _add_npc(npcs, "Habitante1", Vector3(9.0, 0.0, 4.0), Color(0.48, 0.36, 0.28, 1.0))
	var neighbor_two: NpcActor = _add_npc(npcs, "Habitante2", Vector3(11.0, 0.0, -1.0), Color(0.42, 0.33, 0.26, 1.0))
	var neighbor_three: NpcActor = _add_npc(npcs, "Habitante3", Vector3(7.0, 0.0, 8.0), Color(0.52, 0.4, 0.3, 1.0))
	weaver.face(_plaza_center_flat(), true)
	weaver.turn_body_to_talk = false
	# La tejedora MakeHuman conserva su postura arrodillada de tejer; si en el
	# futuro se usa un modelo sin ese clip, vuelve al reposo de pie.
	var weaver_player: AnimationPlayer = weaver.animation_player()
	weaver.set_idle_animation(&"weave" if weaver_player != null and weaver_player.has_animation(&"weave") else &"idle")
	farmer.face(_plaza_center_flat(), true)
	farmer.set_idle_animation(&"work")
	for actor: Node in npcs.get_children():
		(actor as NpcActor).watch_target = player
	_setup_npc_sounds(npcs, weaver, farmer)
	_attach_object_models(llacta)
	var talks: Array[NpcTalk] = [
		_add_talk(weaver, &"PCH_TALK_WEAVER", _build_weaver_dialogue()),
		_add_talk(farmer, &"PCH_TALK_FARMER", _build_farmer_dialogue()),
		_add_talk(curaca, &"PCH_TALK_CURACA", _build_curaca_dialogue()),
		_add_talk(neighbor_one, &"PCH_TALK_VILLAGER_1"),
		_add_talk(neighbor_two, &"PCH_TALK_VILLAGER_2"),
		_add_talk(neighbor_three, &"PCH_TALK_VILLAGER_3"),
	]

	var event: MessengerEvent = $EventController as MessengerEvent
	var pututu: Pututu = $Pututu as Pututu
	var plaza_point: Marker3D = $PlazaPoint as Marker3D
	if event != null:
		var principals: Array[NpcActor] = [principal_one, principal_two]
		var neighbors: Array[NpcActor] = [neighbor_one, neighbor_two, neighbor_three]
		if not event.subtitle_requested.is_connected(_on_subtitle_requested):
			event.subtitle_requested.connect(_on_subtitle_requested)
		if not event.phase_changed.is_connected(_on_event_phase_changed):
			event.phase_changed.connect(_on_event_phase_changed)
		if not event.finished.is_connected(_on_event_finished):
			event.finished.connect(_on_event_finished)
		event.bind(player, plaza_point, messenger, curaca, principals, neighbors, pututu)
		for actor: NpcActor in neighbors:
			actor.walk_speed = NEIGHBOR_WALK_SPEED
		event.set_greeter(neighbor_three, GREETER_POINT)
		event.set_wander_routes(neighbor_routes(neighbor_one, neighbor_two, neighbor_three))
		for talk: NpcTalk in talks:
			if talk != null:
				talk.event = event
	_setup_ambience()


## Paseos de los tres vecinos antes de la noticia: cada uno vuelve a su punto
## de partida. Los tramos son rectos y esquivan las casas, el quero, el pututu,
## la ofrenda y el grupo del curaca.
static func neighbor_routes(one: NpcActor, two: NpcActor, three: NpcActor) -> Dictionary[NpcActor, PackedVector3Array]:
	var routes: Dictionary[NpcActor, PackedVector3Array] = {}
	if one != null:
		routes[one] = PackedVector3Array([one.position, Vector3(14.0, 0.0, 5.0), Vector3(14.0, 0.0, 13.0),
			Vector3(7.0, 0.0, 14.0), Vector3(5.0, 0.0, 8.0)])
	if two != null:
		routes[two] = PackedVector3Array([two.position, Vector3(14.0, 0.0, -8.0), Vector3(6.0, 0.0, -12.0),
			Vector3(-4.0, 0.0, -12.0), Vector3(-6.0, 0.0, -5.0), Vector3(2.0, 0.0, -3.0)])
	if three != null:
		routes[three] = PackedVector3Array([three.position, Vector3(10.0, 0.0, 15.0), Vector3(12.0, 0.0, 18.0),
			Vector3(4.0, 0.0, 19.0), Vector3(2.0, 0.0, 14.0)])
	return routes


## Añade «Hablar» a un personaje con su frase o su conversación.
func _add_talk(actor: NpcActor, line_key: StringName, graph: DialogueGraph = null) -> NpcTalk:
	if actor == null:
		return null
	var packed: PackedScene = load(TALK_SCENE) as PackedScene
	if packed == null:
		return null
	var talk: NpcTalk = packed.instantiate() as NpcTalk
	if talk == null:
		return null
	talk.line_key = line_key
	talk.dialogue = graph
	actor.add_child(talk)
	talk.spoke.connect(_on_npc_spoke)
	talk.dialogue_requested.connect(_on_npc_dialogue_requested)
	return talk


## Crea el estado, el inventario, el diario y el diálogo del jugador.
func _setup_rpg() -> void:
	character = CharacterState.new()
	character.name = "CharacterState"
	player.add_child(character)
	inventory = Inventory.new()
	inventory.name = "Inventory"
	player.add_child(inventory)
	journal = Journal.new()
	journal.name = "Journal"
	player.add_child(journal)
	dialogue = DialogueRunner.new()
	dialogue.name = "DialogueRunner"
	dialogue.character = character
	dialogue.inventory = inventory
	player.add_child(dialogue)
	dialogue.line_shown.connect(_on_dialogue_line)
	dialogue.choices_shown.connect(_on_dialogue_choices)
	dialogue.finished.connect(_on_dialogue_finished)
	dialogue.flag_changed.connect(_on_dialogue_flag)
	hud.dialogue_advanced.connect(_on_dialogue_advanced)
	hud.dialogue_choice.connect(_on_dialogue_choice)
	hud.journal_closed.connect(_on_journal_closed)
	var quero: QueroChicha = $QueroChicha as QueroChicha
	if quero != null and not quero.drank.is_connected(_on_quero_memory):
		quero.drank.connect(_on_quero_memory)
	var ofrenda: OfrendaPachamama = $OfrendaPachamama as OfrendaPachamama
	if ofrenda != null and not ofrenda.offered.is_connected(_on_offering_memory):
		ofrenda.offered.connect(_on_offering_memory)


## Crea los cuatro puntos de encargo y los apunta en el diario.
func _setup_act_one() -> void:
	if journal == null:
		return
	for index: int in range(TASK_IDS.size()):
		journal.add_quest(
			StringName("q_" + String(TASK_IDS[index])),
			StringName("PCH_Q_%s_TITLE" % String(TASK_IDS[index]).to_upper()),
			StringName("PCH_Q_%s_BODY" % String(TASK_IDS[index]).to_upper())
		)
	var packed: PackedScene = load(TASK_SCENE) as PackedScene
	if packed == null:
		return
	for index: int in range(TASK_IDS.size()):
		var instance: Node = packed.instantiate()
		var task: TaskPoint = instance as TaskPoint
		var body: Node3D = instance as Node3D
		if task == null or body == null:
			instance.free()
			continue
		task.name = "Task" + String(TASK_IDS[index]).capitalize()
		task.task_id = TASK_IDS[index]
		task.prompt_key = TASK_PROMPTS[index]
		var point: Vector3 = TASK_POSITIONS[index]
		body.position = Vector3(point.x, _height_at(point.x, point.z) + 0.9, point.z)
		if not TASK_MODELS[index].is_empty():
			var model_scene: PackedScene = load(MODEL_DIR + TASK_MODELS[index]) as PackedScene
			if model_scene != null:
				var model: Node3D = model_scene.instantiate() as Node3D
				if model != null:
					model.position = Vector3(0.0, -0.9, 0.0)
					SurfaceMaterials.apply_to_model(model)
					task.add_child(model)
		add_child(task)
		task.completed.connect(_on_task_completed)


## Registra un encargo cumplido. El primero fija el oficio; el tercero llama al
## mensajero (biblia de la campaña §4).
func _on_task_completed(task_id: StringName) -> void:
	if _tasks_done.has(task_id):
		return
	_tasks_done[task_id] = true
	if journal != null:
		journal.complete_quest(StringName("q_" + String(task_id)))
	_unlock_task_memory(task_id)
	if _oficio == &"":
		_oficio = task_id
		if character != null:
			character.register_skill_use(_skill_for_task(task_id), 3)
	if hud != null:
		hud.show_hint(tr("PCH_TASK_DONE") % _tasks_done.size(), 3.0)
		hud.show_subtitle(tr(String(_task_done_key(task_id))), 0.0)
	SessionLog.mark(&"task", String(task_id))
	if _tasks_done.size() < TASKS_REQUIRED:
		return
	var event: MessengerEvent = $EventController as MessengerEvent
	if event != null and event.phase == MessengerEvent.Phase.IDLE:
		event.start()


## Memoria que deja cada encargo al completarse.
func _unlock_task_memory(task_id: StringName) -> void:
	match task_id:
		&"agua":
			_unlock_memory(&"mem_vivienda", &"PCH_ST_VIVIENDA_TITLE", &"PCH_ST_VIVIENDA_BODY", &"A", &"PCH-007")
		&"maiz":
			_unlock_memory(&"mem_chicha", &"PCH_ST_CHICHA_TITLE", &"PCH_ST_CHICHA_BODY", &"H", &"PCH-005")
		&"telar":
			_unlock_memory(&"mem_telar", &"PCH_ST_TELAR_TITLE", &"PCH_ST_TELAR_BODY", &"A", &"PCH-010")
		&"pirca":
			_unlock_memory(&"mem_corral", &"PCH_ST_CORRAL_TITLE", &"PCH_ST_CORRAL_BODY", &"R", &"PCH-021")


## Habilidad que entrena cada encargo.
static func _skill_for_task(task_id: StringName) -> StringName:
	match task_id:
		&"agua":
			return &"monte"
		&"maiz":
			return &"oficio"
		&"telar":
			return &"palabra"
		&"pirca":
			return &"monte"
	return &"oficio"


static func _task_done_key(task_id: StringName) -> StringName:
	var index: int = TASK_IDS.find(task_id)
	return TASK_DONE_KEYS[index] if index >= 0 else &""


## Conversación de la tejedora: una pregunta y una entrada de Memoria.
func _build_weaver_dialogue() -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = &"PCH_NPC_WEAVER"
	start.text_key = &"PCH_TALK_WEAVER"
	start.next_id = &"end"
	var ask: DialogueChoice = DialogueChoice.new()
	ask.text_key = &"PCH_DLG_WEAVER_ASK"
	ask.next_id = &"dye"
	var leave: DialogueChoice = DialogueChoice.new()
	leave.text_key = &"PCH_DLG_WEAVER_LEAVE"
	leave.next_id = &"end"
	var start_choices: Array[DialogueChoice] = [ask, leave]
	start.choices = start_choices
	var dye: DialogueNode = DialogueNode.new()
	dye.id = &"dye"
	dye.speaker_key = &"PCH_NPC_WEAVER"
	dye.text_key = &"PCH_DLG_WEAVER_DYE"
	dye.next_id = &"end"
	var effect: DialogueEffect = DialogueEffect.new()
	effect.kind = DialogueEffect.Kind.SET_FLAG
	effect.key = &"sabio_telar"
	effect.amount = 1
	var effects: Array[DialogueEffect] = [effect]
	dye.effects = effects
	var nodes: Array[DialogueNode] = [start, dye]
	graph.nodes = nodes
	return graph


## Conversación de pregunta y respuesta con una entrada de Memoria.
func _build_question_dialogue(
	speaker_key: StringName,
	opening_key: StringName,
	ask_key: StringName,
	answer_key: StringName,
	flag_key: StringName
) -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	var start: DialogueNode = DialogueNode.new()
	start.id = &"start"
	start.speaker_key = speaker_key
	start.text_key = opening_key
	start.next_id = &"end"
	var ask: DialogueChoice = DialogueChoice.new()
	ask.text_key = ask_key
	ask.next_id = &"answer"
	var leave: DialogueChoice = DialogueChoice.new()
	leave.text_key = &"PCH_DLG_LEAVE"
	leave.next_id = &"end"
	var start_choices: Array[DialogueChoice] = [ask, leave]
	start.choices = start_choices
	var answer: DialogueNode = DialogueNode.new()
	answer.id = &"answer"
	answer.speaker_key = speaker_key
	answer.text_key = answer_key
	answer.next_id = &"end"
	var effect: DialogueEffect = DialogueEffect.new()
	effect.kind = DialogueEffect.Kind.SET_FLAG
	effect.key = flag_key
	effect.amount = 1
	var effects: Array[DialogueEffect] = [effect]
	answer.effects = effects
	var nodes: Array[DialogueNode] = [start, answer]
	graph.nodes = nodes
	return graph


func _build_farmer_dialogue() -> DialogueGraph:
	return _build_question_dialogue(
		&"PCH_NPC_FARMER", &"PCH_TALK_FARMER", &"PCH_DLG_FARMER_ASK",
		&"PCH_DLG_FARMER_TERRACE", &"sabio_terraza"
	)


func _build_curaca_dialogue() -> DialogueGraph:
	return _build_question_dialogue(
		&"PCH_NPC_CURACA", &"PCH_TALK_CURACA", &"PCH_DLG_CURACA_ASK",
		&"PCH_DLG_CURACA_PLAZA", &"sabio_plaza"
	)


func _on_npc_dialogue_requested(actor: Node3D, graph: DialogueGraph) -> void:
	if hud == null or dialogue == null or graph == null:
		return
	if hud.is_dialogue_open():
		return
	if not dialogue.start(graph):
		return
	var npc: NpcActor = actor as NpcActor
	if npc != null and npc.turn_body_to_talk:
		npc.face(player.global_position)
		npc.perform(&"talk" if npc.idle_animation == &"idle" else &"idle", TALK_HOLD_SECONDS)
	player.begin_dialogue(actor)


func _on_dialogue_line(speaker_key: StringName, text_key: StringName) -> void:
	_dialogue_speaker = speaker_key
	_dialogue_text = text_key
	_dialogue_choices.clear()
	if hud == null:
		return
	var empty: Array[String] = []
	hud.show_dialogue(tr(String(speaker_key)), tr(String(text_key)), empty)


func _on_dialogue_choices(text_keys: Array[StringName]) -> void:
	_dialogue_choices = text_keys
	if hud == null:
		return
	var texts: Array[String] = []
	for key: StringName in text_keys:
		texts.append(tr(String(key)))
	hud.update_dialogue(tr(String(_dialogue_speaker)), tr(String(_dialogue_text)), texts)


func _on_dialogue_advanced() -> void:
	if dialogue != null:
		dialogue.advance()


func _on_dialogue_choice(index: int) -> void:
	if dialogue != null:
		dialogue.choose(index)


func _on_dialogue_finished() -> void:
	if hud != null:
		hud.hide_dialogue()
	player.end_dialogue()


func _on_dialogue_flag(key: StringName, value: int) -> void:
	if value == 0:
		return
	match key:
		&"sabio_telar":
			_unlock_memory(&"mem_telar", &"PCH_ST_TELAR_TITLE", &"PCH_ST_TELAR_BODY", &"A", &"PCH-010")
		&"sabio_terraza":
			_unlock_memory(&"mem_terraza", &"PCH_ST_TERRAZA_TITLE", &"PCH_ST_TERRAZA_BODY", &"A", &"PCH-008")
		&"sabio_plaza":
			_unlock_memory(&"mem_plaza", &"PCH_ST_PLAZA_TITLE", &"PCH_ST_PLAZA_BODY", &"A", &"PCH-016")


func _on_journal_closed() -> void:
	player.set_controls_locked(false)


func _on_quero_memory() -> void:
	_unlock_memory(&"mem_quero", &"PCH_ST_QUERO_TITLE", &"PCH_ST_QUERO_BODY", &"A", &"PCH-004")


func _on_offering_memory() -> void:
	_unlock_memory(&"mem_ofrenda", &"PCH_ST_OFRENDA_TITLE", &"PCH_ST_OFRENDA_BODY", &"H", &"PCH-012")


func _unlock_memory(
	entry_id: StringName,
	title_key: StringName,
	body_key: StringName,
	badge: StringName,
	source_key: StringName
) -> void:
	if journal == null:
		return
	if journal.add_memory(entry_id, title_key, body_key, badge, source_key):
		if hud != null:
			hud.show_hint(tr("UI_JOURNAL_UPDATED"), 3.0)


func _on_npc_spoke(actor: Node3D, line_key: StringName) -> void:
	if hud != null:
		hud.show_subtitle(tr(String(line_key)), 0.0)
	var npc: NpcActor = actor as NpcActor
	if npc == null:
		return
	var event: MessengerEvent = $EventController as MessengerEvent
	if event != null:
		event.hold(npc, TALK_HOLD_SECONDS)
	# La tejedora sigue tejiendo y solo gira la cabeza. El agricultor deja la
	# chaquitaclla; los demás acompañan la frase con gestos (ADR-0015).
	if npc.turn_body_to_talk:
		npc.face(player.global_position)
		npc.perform(&"talk" if npc.idle_animation == &"idle" else &"idle", TALK_HOLD_SECONDS)


func _plaza_center_flat() -> Vector3:
	var plaza_point: Marker3D = $PlazaPoint as Marker3D
	if plaza_point == null:
		return Vector3.ZERO
	return plaza_point.global_position


func _on_subtitle_requested(text_key: StringName, seconds: float) -> void:
	SessionLog.mark(&"subtitle", String(text_key))
	if hud == null:
		return
	hud.show_subtitle(tr(String(text_key)), seconds)


## Indica si el murmullo de la plaza debe sonar en una fase del evento: desde
## la noticia hasta que suena el pututu.
static func murmur_plays_in(phase: int) -> bool:
	return phase == MessengerEvent.Phase.MESSAGE or phase == MessengerEvent.Phase.CALL


func _on_event_phase_changed(phase: int) -> void:
	if phase >= 0 and phase < EVENT_PHASE_NAMES.size():
		SessionLog.mark(&"phase", EVENT_PHASE_NAMES[phase])
	if phase == MessengerEvent.Phase.ARRIVAL:
		_unlock_memory(&"mem_mirador", &"PCH_ST_MIRADOR_TITLE", &"PCH_ST_MIRADOR_BODY", &"A", &"PCH-022")
	_sync_objective_with_phase(phase)
	if murmur_plays_in(phase):
		_start_murmur()
	else:
		_stop_murmur()


## El evento manda sobre las tareas: al llegar el mensajero, el objetivo pasa a
## escuchar y, en la llamada, a tocar el pututu.
func _sync_objective_with_phase(phase: int) -> void:
	match phase:
		MessengerEvent.Phase.ARRIVAL, MessengerEvent.Phase.MESSAGE:
			_advance_objective(Objective.LISTEN)
		MessengerEvent.Phase.CALL:
			_advance_objective(Objective.PUTUTU)
		MessengerEvent.Phase.DEPARTURE:
			_advance_objective(Objective.LEAVE)
		MessengerEvent.Phase.DONE:
			_show_objective(Objective.NONE)


func _start_murmur() -> void:
	var murmur: AudioStreamPlayer3D = $EnvironmentAudio.get_node_or_null("PlazaMurmur") as AudioStreamPlayer3D
	if murmur == null:
		murmur = _create_murmur()
	if murmur == null or murmur.playing:
		return
	murmur.volume_db = MURMUR_SILENT_DB
	murmur.play()
	var tween: Tween = murmur.create_tween()
	tween.tween_property(murmur, "volume_db", MURMUR_VOLUME_DB, MURMUR_FADE_IN)


func _stop_murmur() -> void:
	var murmur: AudioStreamPlayer3D = $EnvironmentAudio.get_node_or_null("PlazaMurmur") as AudioStreamPlayer3D
	if murmur == null or not murmur.playing:
		return
	var tween: Tween = murmur.create_tween()
	tween.tween_property(murmur, "volume_db", MURMUR_SILENT_DB, MURMUR_FADE_OUT)
	tween.tween_callback(murmur.stop)


func _create_murmur() -> AudioStreamPlayer3D:
	# Mismo motivo que el ambiente: el driver «Dummy» no libera reproducciones.
	if AudioServer.get_driver_name() == "Dummy":
		return null
	if not ResourceLoader.exists(MURMUR_PATH):
		return null
	var stream: AudioStreamWAV = load(MURMUR_PATH) as AudioStreamWAV
	if stream == null:
		return null
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = roundi(stream.get_length() * float(stream.mix_rate))
	var murmur: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	murmur.name = "PlazaMurmur"
	murmur.stream = stream
	murmur.unit_size = 12.0
	murmur.max_distance = 70.0
	$EnvironmentAudio.add_child(murmur)
	murmur.global_position = _plaza_center_flat() + Vector3(0.0, 1.5, -3.0)
	return murmur


func _setup_footsteps() -> void:
	# Con el driver «Dummy» de las pruebas sin pantalla las reproducciones no se
	# liberan; los pasos no son objeto de esas pruebas.
	if AudioServer.get_driver_name() == "Dummy":
		return
	player.footstep_streams = _load_streams(FOOTSTEP_PATHS)
	var stone: FootstepSet = FootstepSet.new()
	stone.surface = SURFACE_STONE
	stone.streams = _load_streams(STONE_FOOTSTEP_PATHS)
	var sets: Array[FootstepSet] = [stone]
	player.footstep_sets = sets


## Pasos de los personajes y sonidos de su trabajo, en 3D.
func _setup_npc_sounds(npcs: Node3D, weaver: NpcActor, farmer: NpcActor) -> void:
	if AudioServer.get_driver_name() == "Dummy":
		return
	var steps: Array[AudioStream] = _load_streams(FOOTSTEP_PATHS)
	for actor: Node in npcs.get_children():
		(actor as NpcActor).set_footsteps(steps)
	_add_beat_sound(weaver, "LoomSound", LOOM_BEAT_PATH, LOOM_BEAT_VOLUME_DB, 1.0, Vector3(0.0, 0.4, -0.4))
	_add_beat_sound(farmer, "DigSound", DIG_PATH, DIG_VOLUME_DB, DIG_PITCH, Vector3(0.3, 0.1, -0.3))


func _add_beat_sound(actor: NpcActor, sound_name: String, path: String, volume_db: float, pitch: float, offset: Vector3) -> void:
	if actor == null or not ResourceLoader.exists(path):
		return
	var sound: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	sound.name = sound_name
	sound.stream = load(path) as AudioStream
	sound.bus = &"SFX"
	sound.volume_db = volume_db
	sound.pitch_scale = pitch
	sound.max_distance = WORK_SOUND_MAX_DISTANCE
	sound.unit_size = 3.0
	sound.position = offset
	actor.add_child(sound)
	actor.beat.connect(func(_animation: StringName) -> void: sound.play())


func _load_streams(paths: Array[String]) -> Array[AudioStream]:
	var streams: Array[AudioStream] = []
	for path: String in paths:
		if not ResourceLoader.exists(path):
			continue
		var stream: AudioStream = load(path) as AudioStream
		if stream != null:
			streams.append(stream)
	return streams


func _setup_ambience() -> void:
	if AudioServer.get_driver_name() == "Dummy":
		return
	if not ResourceLoader.exists(AMBIENCE_PATH):
		return
	var stream: AudioStream = load(AMBIENCE_PATH) as AudioStream
	if stream == null:
		return
	if stream is AudioStreamWAV:
		var wav: AudioStreamWAV = stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_end = roundi(wav.get_length() * float(wav.mix_rate))
	elif stream is AudioStreamOggVorbis:
		var ogg: AudioStreamOggVorbis = stream as AudioStreamOggVorbis
		ogg.loop = true
	var player_audio: AudioStreamPlayer = AudioStreamPlayer.new()
	player_audio.name = "WindAmbience"
	player_audio.stream = stream
	player_audio.volume_db = -16.0
	player_audio.autoplay = true
	$EnvironmentAudio.add_child(player_audio)
	if AudioServer.get_bus_index(&"Ambience") >= 0:
		player_audio.bus = &"Ambience"
	var wind: LlactaWind = get_node_or_null("Wind") as LlactaWind
	if wind != null:
		wind.ambience = player_audio
		wind.ambience_base_db = player_audio.volume_db
	# Murmullo lejano de la comunidad, por debajo del viento. El evento sube su
	# propio murmullo cuando llega el mensajero.
	CampaignAudio.add_loop_3d(self, "VillageMurmur", CampaignAudio.MURMUR_PATH,
		_plaza_center_flat() + Vector3.UP * 1.3, -27.0, 12.0, 55.0)


## Fuego comunal: piedras, troncos, llama y una luz cálida. Es reconstrucción
## de ambiente (R): no documenta un fuego concreto, solo el uso del espacio.
func _add_community_fire(parent: Node3D) -> void:
	var root: Node3D = Node3D.new()
	root.name = "CommunityFire"
	root.position = FIRE_PIT_POSITION
	parent.add_child(root)
	var rock: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.ROCK, Color(0.50, 0.48, 0.45, 1.0))
	for index: int in range(8):
		var angle: float = TAU * float(index) / 8.0
		var stone_instance: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.15
		sphere.height = 0.26
		sphere.radial_segments = 6
		sphere.rings = 3
		stone_instance.mesh = sphere
		stone_instance.material_override = rock
		stone_instance.position = Vector3(cos(angle) * 0.72, 0.10, sin(angle) * 0.72)
		root.add_child(stone_instance)
	var wood: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.WOOD, Color(0.36, 0.26, 0.17, 1.0))
	for offset: Vector3 in [Vector3(-0.55, 0.0, 0.2), Vector3(0.5, 0.0, -0.25)]:
		var log_instance: MeshInstance3D = MeshInstance3D.new()
		var cylinder: CylinderMesh = CylinderMesh.new()
		cylinder.top_radius = 0.07
		cylinder.bottom_radius = 0.09
		cylinder.height = 0.9
		log_instance.mesh = cylinder
		log_instance.material_override = wood
		log_instance.position = Vector3(offset.x, 0.12, offset.z)
		log_instance.rotation_degrees = Vector3(0.0, 20.0, 90.0)
		root.add_child(log_instance)
	for size: Vector2 in [Vector2(0.20, 0.48), Vector2(0.12, 0.30)]:
		var flame: MeshInstance3D = MeshInstance3D.new()
		var cone: CylinderMesh = CylinderMesh.new()
		cone.top_radius = 0.0
		cone.bottom_radius = size.x
		cone.height = size.y
		flame.mesh = cone
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color(0.98, 0.52, 0.16, 1.0)
		material.emission_enabled = true
		material.emission = Color(1.0, 0.42, 0.1, 1.0)
		material.emission_energy_multiplier = 2.0
		flame.material_override = material
		flame.position = Vector3(0.0, 0.12 + size.y * 0.5, 0.0)
		root.add_child(flame)
	var light: OmniLight3D = OmniLight3D.new()
	light.name = "FireLight"
	light.position = Vector3(0.0, 0.9, 0.0)
	light.light_color = Color(1.0, 0.62, 0.32, 1.0)
	light.light_energy = 1.0
	light.omni_range = 5.5
	light.shadow_enabled = false
	root.add_child(light)
	if AudioServer.get_driver_name() != "Dummy":
		CampaignAudio.add_loop_3d(self, "VillageFire", CampaignAudio.FIRE_PATH,
			FIRE_PIT_POSITION + Vector3.UP * 0.35, -18.0, 4.0, 24.0)



func _add_visual_box(parent: Node3D, node_name: String, at: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = at
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)
	return mesh_instance


func _add_box_body(parent: Node3D, node_name: String, at: Vector3, size: Vector3, material: Material, layer: int) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name
	body.position = at
	body.collision_layer = layer
	body.collision_mask = 0
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var box_mesh: BoxMesh = BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = material
	body.add_child(mesh_instance)
	var collision: CollisionShape3D = CollisionShape3D.new()
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = size
	collision.shape = box_shape
	body.add_child(collision)
	parent.add_child(body)
	return body


## Nivel de terraza: dos bloques macizos desde el suelo hasta [param top_y] a
## ambos lados de una rampa central que sube desde [param bottom_y]. Bajo la
## rampa, un relleno llega hasta [param bottom_y] y una tapa cierra su extremo
## alto, para que no quede hueco por el que meterse bajo la rampa.
func _add_terrace(parent: Node3D, node_name: String, center_x: float, bottom_y: float, top_y: float, material: Material, back_exposed: bool = false) -> void:
	var bodies: Array[StaticBody3D] = []
	var mortar: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.ROCK, TERRACE_MORTAR_COLOR)
	var north: StaticBody3D = _add_box_body(parent, node_name + "North", Vector3(center_x, top_y * 0.5, -8.5), Vector3(8.0, top_y, 13.0), mortar, 1)
	var south: StaticBody3D = _add_box_body(parent, node_name + "South", Vector3(center_x, top_y * 0.5, 8.5), Vector3(8.0, top_y, 13.0), mortar, 1)
	bodies.append(north)
	bodies.append(south)
	var ramp_material: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, RAMP_COLOR)
	bodies.append(_add_ramp(parent, node_name + "Ramp", Vector3(center_x - 4.0, bottom_y, 0.0), 8.0, top_y - bottom_y, 4.0, ramp_material))
	if bottom_y > 0.0:
		bodies.append(_add_box_body(parent, node_name + "Fill", Vector3(center_x, bottom_y * 0.5, 0.0), Vector3(8.0, bottom_y, 4.0), material, 1))
	var cap_height: float = top_y - TERRACE_CAP_INSET
	bodies.append(_add_box_body(parent, node_name + "Cap", Vector3(center_x + 4.0 - TERRACE_CAP_THICKNESS * 0.5, cap_height * 0.5, 0.0), Vector3(TERRACE_CAP_THICKNESS, cap_height, 4.0), material, 1))
	for body: StaticBody3D in bodies:
		body.set_meta(PlayerFPS.FOOTSTEP_SURFACE_META, SURFACE_STONE)
	# Encima de los muros de piedra se camina sobre tierra de cultivo.
	for field_body: StaticBody3D in [north, south]:
		field_body.remove_meta(PlayerFPS.FOOTSTEP_SURFACE_META)
		parent.add_child(field_mesh(node_name + ("FieldNorth" if field_body == north else "FieldSouth"),
			Vector3(center_x, top_y, field_body.position.z), Vector2(8.0, 13.0)))
	parent.add_child(terrace_walls_mesh(node_name + "Walls", center_x, top_y, back_exposed))


## Piedras de los muros de contención de una terraza: caras hacia la plaza
## (oeste), hacia el pasillo de las rampas, hacia fuera (norte y sur) y, en la
## última terraza, hacia la cresta (este). Una malla por terraza.
static func terrace_walls_mesh(node_name: String, center_x: float, top_y: float, back_exposed: bool) -> MeshInstance3D:
	var x0: float = center_x - 4.0
	var x1: float = center_x + 4.0
	var faces: Array[StoneWall.Face] = [
		StoneWall.Face.new(Vector3(x0, 0.0, -15.0), Vector3.BACK, Vector3.LEFT, 13.0, top_y),
		StoneWall.Face.new(Vector3(x0, 0.0, 2.0), Vector3.BACK, Vector3.LEFT, 13.0, top_y),
		StoneWall.Face.new(Vector3(x0, 0.0, -2.0), Vector3.RIGHT, Vector3.BACK, 8.0, top_y),
		StoneWall.Face.new(Vector3(x0, 0.0, 2.0), Vector3.RIGHT, Vector3.FORWARD, 8.0, top_y),
		StoneWall.Face.new(Vector3(x0, 0.0, -15.0), Vector3.RIGHT, Vector3.FORWARD, 8.0, top_y),
		StoneWall.Face.new(Vector3(x0, 0.0, 15.0), Vector3.RIGHT, Vector3.BACK, 8.0, top_y),
	]
	if back_exposed:
		faces.append(StoneWall.Face.new(Vector3(x1, 0.0, -15.0), Vector3.BACK, Vector3.RIGHT, 13.0, top_y))
		faces.append(StoneWall.Face.new(Vector3(x1, 0.0, 2.0), Vector3.BACK, Vector3.RIGHT, 13.0, top_y))
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.mesh = StoneWall.build(faces, hash(node_name))
	mesh_instance.material_override = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, Color.WHITE, true)
	return mesh_instance


## Tierra de cultivo con surcos sobre la cara superior de un bloque de terraza
## centrado en [param top_center] y de planta [param size] (x, z). Los surcos
## corren a lo largo de z, paralelos al muro de contención. Es solo visual: la
## colisión es la del bloque.
static func field_mesh(node_name: String, top_center: Vector3, size: Vector2) -> MeshInstance3D:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half_x: float = size.x * 0.5 - FIELD_MARGIN
	var half_z: float = size.y * 0.5 - FIELD_MARGIN
	var y0: float = FIELD_LIFT
	var z0: float = -half_z
	var z1: float = half_z
	# Suelo entre surcos.
	surface.set_color(FIELD_SOIL_COLOR.srgb_to_linear())
	for vertex: Vector3 in [Vector3(-half_x, y0, z0), Vector3(half_x, y0, z0), Vector3(half_x, y0, z1),
			Vector3(-half_x, y0, z0), Vector3(half_x, y0, z1), Vector3(-half_x, y0, z1)]:
		surface.add_vertex(vertex)
	# Caballones: prismas triangulares a lo largo de z.
	var ridges: int = int(floorf((half_x * 2.0) / FIELD_FURROW_SPACING))
	var start_x: float = -half_x + (half_x * 2.0 - float(ridges - 1) * FIELD_FURROW_SPACING) * 0.5
	var half_width: float = FIELD_FURROW_SPACING * 0.3
	for index: int in range(ridges):
		var x: float = start_x + float(index) * FIELD_FURROW_SPACING
		var left: float = x - half_width
		var right: float = x + half_width
		var top: float = y0 + FIELD_RIDGE_HEIGHT
		surface.set_color(FIELD_RIDGE_COLOR.srgb_to_linear())
		for vertex: Vector3 in [Vector3(left, y0, z1), Vector3(x, top, z1), Vector3(x, top, z0),
				Vector3(left, y0, z1), Vector3(x, top, z0), Vector3(left, y0, z0),
				Vector3(x, top, z1), Vector3(right, y0, z1), Vector3(right, y0, z0),
				Vector3(x, top, z1), Vector3(right, y0, z0), Vector3(x, top, z0)]:
			surface.add_vertex(vertex)
	surface.generate_normals()
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.mesh = surface.commit()
	mesh_instance.material_override = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.SOIL, Color.WHITE, true)
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.position = top_center
	return mesh_instance


## Rampa transitable entre dos niveles de terraza. El cuerpo gira sobre Z y la
## cara superior pasa por el punto de arranque.
func _add_ramp(parent: Node3D, node_name: String, start: Vector3, run: float, rise: float, width: float, material: Material) -> StaticBody3D:
	var angle: float = atan2(rise, run)
	var length: float = sqrt(run * run + rise * rise)
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name
	body.position = start + Vector3(run * 0.5, rise * 0.5, 0.0)
	body.rotation = Vector3(0.0, 0.0, angle)
	body.collision_layer = 1
	body.collision_mask = 0
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var box_mesh: BoxMesh = BoxMesh.new()
	box_mesh.size = Vector3(length, 0.3, width)
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = material
	mesh_instance.position = Vector3(0.0, -0.15, 0.0)
	body.add_child(mesh_instance)
	var collision: CollisionShape3D = CollisionShape3D.new()
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = Vector3(length, 0.3, width)
	collision.shape = box_shape
	collision.position = Vector3(0.0, -0.15, 0.0)
	body.add_child(collision)
	parent.add_child(body)
	return body


func _add_house(parent: Node3D, index: int, at: Vector3, stone: Material, thatch: Material) -> void:
	var root: Node3D = Node3D.new()
	root.name = "House%02d" % (index + 1)
	root.position = at
	parent.add_child(root)
	root.look_at(Vector3(0.0, at.y, 0.0), Vector3.UP)
	root.rotate_y(deg_to_rad(HOUSE_YAW_JITTER[index % HOUSE_YAW_JITTER.size()]))
	var base: StaticBody3D = _add_box_body(root, "Base", Vector3(0.0, 1.25, 0.0), Vector3(6.0, 2.5, 5.0), stone, 1)
	var roof: MeshInstance3D = MeshInstance3D.new()
	roof.name = "Roof"
	roof.position = Vector3(0.0, 3.25, 0.0)
	var prism: PrismMesh = PrismMesh.new()
	prism.size = Vector3(6.6, 1.5, 5.6)
	roof.mesh = prism
	roof.material_override = thatch
	root.add_child(roof)
	root.add_to_group("houses")
	var blockout: Array[Node3D] = [roof]
	var collisions: Array[Node] = []
	for child: Node in base.get_children():
		if child is MeshInstance3D:
			blockout.append(child as MeshInstance3D)
		elif child is CollisionShape3D:
			collisions.append(child)
	var files: Array[String] = [MODEL_HOUSES[index % MODEL_HOUSES.size()]]
	_attach_model(root, "ModelSlot", Vector3.ZERO, files, blockout, collisions)
	_add_house_props(root, index)


## Cántaros y leña delante de la vivienda, a los lados de la puerta. El frente
## mira a −Z local; la puerta de la variante B está desplazada hacia −X.
func _add_house_props(root: Node3D, index: int) -> void:
	var variant: int = index % MODEL_HOUSES.size()
	var front: float = -HOUSE_DEPTHS[variant] * 0.5 - PROP_WALL_GAP
	var left_x: float = HOUSE_LEFT_PROP_X[variant]
	var props: Array[Array] = []
	match index % 3:
		0:
			props = [[MODEL_PROP_JAR, Vector3(1.8, 0.0, front)], [MODEL_PROP_JAR, Vector3(2.3, 0.0, front - 0.25)],
				[MODEL_PROP_FIREWOOD, Vector3(left_x, 0.0, front)]]
		1:
			props = [[MODEL_PROP_FIREWOOD, Vector3(2.0, 0.0, front)], [MODEL_PROP_JAR, Vector3(left_x - 0.2, 0.0, front)]]
		_:
			props = [[MODEL_PROP_JAR, Vector3(2.0, 0.0, front)]]
	var no_blockout: Array[Node3D] = []
	var no_collisions: Array[Node] = []
	for prop_index: int in range(props.size()):
		var entry: Array = props[prop_index]
		var file: String = entry[0]
		var at: Vector3 = entry[1]
		var prop_files: Array[String] = [file]
		var slot: ModelSlot = _attach_model(root, "Prop%d" % prop_index, at, prop_files, no_blockout, no_collisions)
		slot.rotation.y = 0.35 * float((index + prop_index) % 3 - 1)


## Archivos candidatos para un personaje: primero el de su papel
## (`pch_npc_<papel>.glb`), luego la variante común o de autoridad.
static func npc_model_files(_node_name: String) -> Array[String]:
	# Base del juego: maniquí UAL1 (CC0). La ropa y la cara se añaden como
	# capas encima (ADR-0042); los modelos MakeHuman/Rocketbox quedan solo como
	# referencia y no se cargan en escena.
	return ["res://shared_assets/characters/mannequin/ual1_standard.glb"]


## Conjunto de vestuario del maniquí para cada personaje del acto I.
static func dressed_role(node_name: String) -> StringName:
	match node_name:
		"Tejedora":
			return &"weaver"
		"Agricultor":
			return &"farmer"
		"Mensajero":
			return &"messenger"
		"Curaca":
			return &"curaca"
		"Principal1", "Principal2":
			return &"principal"
	return &"villager"


## Variante de color de los vecinos.
static func dressed_variant(node_name: String) -> int:
	match node_name:
		"Habitante2":
			return 1
		"Habitante3":
			return 2
	return 0


## Crea un hueco de modelo bajo [param parent]. Las listas se fijan antes de
## añadirlo al árbol para que cargue en su _ready().
## Corral de pirca seca baja: cuatro muros con una entrada en el lado
## [param entrance] (dirección hacia fuera). Cada tramo es un bloque con
## colisión que asoma entre las piedras como junta, como en las terrazas.
func _add_corral(parent: Node3D, node_name: String, center: Vector3, size: Vector2, entrance: Vector3) -> void:
	var root: Node3D = Node3D.new()
	root.name = node_name
	parent.add_child(root)
	var base_y: float = _height_at(center.x, center.z) - CORRAL_SINK
	var height: float = CORRAL_WALL_HEIGHT + CORRAL_SINK
	var half: Vector2 = size * 0.5
	var mortar: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.ROCK, TERRACE_MORTAR_COLOR)
	# Lados: esquina de partida, dirección, largo y normal hacia fuera.
	var sides: Array[Array] = [
		[Vector3(-half.x, 0.0, -half.y), Vector3.RIGHT, size.x, Vector3.FORWARD],
		[Vector3(half.x, 0.0, -half.y), Vector3.BACK, size.y, Vector3.RIGHT],
		[Vector3(half.x, 0.0, half.y), Vector3.LEFT, size.x, Vector3.BACK],
		[Vector3(-half.x, 0.0, half.y), Vector3.FORWARD, size.y, Vector3.LEFT],
	]
	var faces: Array[StoneWall.Face] = []
	var segment_index: int = 0
	for side: Array in sides:
		var start: Vector3 = side[0]
		var along: Vector3 = side[1]
		var length: float = side[2]
		var outward: Vector3 = side[3]
		var spans: Array[Vector2] = [Vector2(0.0, length)]
		if outward.is_equal_approx(entrance):
			var middle: float = length * 0.5
			spans = [Vector2(0.0, middle - CORRAL_ENTRANCE * 0.5), Vector2(middle + CORRAL_ENTRANCE * 0.5, length)]
		for span: Vector2 in spans:
			var span_length: float = span.y - span.x
			var a: Vector3 = center + start + along * span.x + Vector3(0.0, base_y, 0.0)
			var mid: Vector3 = a + along * (span_length * 0.5) + Vector3(0.0, height * 0.5, 0.0)
			var box_size: Vector3 = (along.abs() * span_length + outward.abs() * CORRAL_WALL_THICKNESS) + Vector3(0.0, height, 0.0)
			segment_index += 1
			_add_box_body(root, "Wall%d" % segment_index, mid, box_size, mortar, 1)
			var half_t: Vector3 = outward * (CORRAL_WALL_THICKNESS * 0.5)
			faces.append(StoneWall.Face.new(a + half_t, along, outward, span_length, height))
			faces.append(StoneWall.Face.new(a + along * span_length - half_t, -along, -outward, span_length, height))
			faces.append(StoneWall.Face.new(a - half_t, outward, -along, CORRAL_WALL_THICKNESS, height))
			faces.append(StoneWall.Face.new(a + along * span_length + half_t, -outward, along, CORRAL_WALL_THICKNESS, height))
	var stones: MeshInstance3D = MeshInstance3D.new()
	stones.name = "Stones"
	stones.mesh = StoneWall.build(faces, hash(node_name))
	stones.material_override = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, Color.WHITE, true)
	root.add_child(stones)


## Poyo de pirca en lugar de la caja del bloqueo; la caja conserva la colisión.
func _attach_pedestal(pedestal: StaticBody3D) -> void:
	var blockout: Array[Node3D] = []
	for child: Node in pedestal.get_children():
		if child is MeshInstance3D:
			blockout.append(child as MeshInstance3D)
	var files: Array[String] = [MODEL_PEDESTAL]
	var keep_collisions: Array[Node] = []
	_attach_model(pedestal, "ModelSlot", Vector3(0.0, -0.4, 0.0), files, blockout, keep_collisions)


func _attach_model(parent: Node3D, slot_name: String, at: Vector3, files: Array[String], blockout: Array[Node3D], collisions: Array[Node]) -> ModelSlot:
	var slot: ModelSlot = ModelSlot.new()
	slot.name = slot_name
	slot.position = at
	var paths: Array[String] = []
	for file: String in files:
		paths.append(file if file.begins_with("res://") else MODEL_DIR + file)
	slot.model_paths = paths
	slot.blockout_nodes = blockout
	slot.blockout_collisions = collisions
	parent.add_child(slot)
	SurfaceMaterials.apply_to_model(slot.model)
	return slot


func _attach_object_models(llacta: Node3D) -> void:
	var targets: Array[Array] = [
		[$QueroChicha, MODEL_QUERO, QUERO_BASE],
		[$Pututu, MODEL_PUTUTU, PUTUTU_BASE],
		[$OfrendaPachamama, MODEL_OFFERING, OFFERING_BASE],
	]
	for target: Array in targets:
		var object_root: Node = target[0]
		var mesh: MeshInstance3D = object_root.get_node_or_null("MeshInstance3D") as MeshInstance3D
		if mesh == null:
			continue
		var file: String = target[1]
		var base: Vector3 = target[2]
		# El hueco cuelga de la malla para heredar las animaciones de respuesta.
		var files: Array[String] = [file]
		var blockout: Array[Node3D] = [mesh]
		var no_collisions: Array[Node] = []
		_attach_model(mesh, "ModelSlot", base, files, blockout, no_collisions)
	# La ofrenda que deja el jugador va aparte del adoratorio: oculta hasta la
	# interacción, para que se vea el gesto (PCH-012).
	var offering_gift: Node3D = $OfrendaPachamama.get_node_or_null("Gift") as Node3D
	if offering_gift != null:
		var gift_files: Array[String] = [MODEL_OFFERING_GIFT]
		var gift_blockout: Array[Node3D] = []
		var gift_collisions: Array[Node] = []
		_attach_model(offering_gift, "ModelSlot", Vector3.ZERO, gift_files, gift_blockout, gift_collisions)
	var loom_files: Array[String] = [MODEL_LOOM]
	var nothing: Array[Node3D] = []
	var no_loom_collisions: Array[Node] = []
	var loom_slot: ModelSlot = _attach_model(llacta, "LoomSlot", LOOM_POSITION, loom_files, nothing, no_loom_collisions)
	loom_slot.transform = loom_transform()


func _add_npc(parent: Node3D, node_name: String, at: Vector3, color: Color) -> NpcActor:
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/npcs/npc_actor.tscn") as PackedScene
	if packed == null:
		return null
	var actor: NpcActor = packed.instantiate() as NpcActor
	if actor == null:
		return null
	actor.name = node_name
	actor.position = at
	actor.body_color = color
	if CHARACTER_HEIGHTS.has(node_name):
		actor.target_height = CHARACTER_HEIGHTS[node_name]
	parent.add_child(actor)
	actor.add_to_group("npcs")
	var body_mesh: MeshInstance3D = actor.get_node_or_null("Body") as MeshInstance3D
	var blockout: Array[Node3D] = []
	var slot_parent: Node3D = actor
	var slot_offset: Vector3 = Vector3.ZERO
	if body_mesh != null:
		blockout.append(body_mesh)
		# El hueco cuelga del cuerpo del bloqueo; se compensa la altura del
		# cuerpo para que los pies queden en el origen del personaje. Con un
		# modelo animado, el balanceo del bloqueo se detiene (ADR-0015).
		slot_parent = body_mesh
		slot_offset = -body_mesh.position
	# La cápsula de colisión del bloqueo se conserva (alcance §7).
	var no_collisions: Array[Node] = []
	var files: Array[String] = npc_model_files(node_name)
	var character_model: bool = CHARACTER_MODELS.has(node_name)
	if character_model:
		files = [CHARACTER_MODELS[node_name]]
	var slot: ModelSlot = _attach_model(slot_parent, "ModelSlot", slot_offset, files, blockout, no_collisions)
	slot.use_model_collision = false
	# Los modelos MakeHuman/Rocketbox traen sus materiales y animaciones; el
	# maniquí UAL1 sigue disponible para el resto de actos.
	actor.mannequin_skin = not character_model
	actor.preserve_materials = character_model
	actor.body_color = DressedMannequin.SKIN_COLOR
	if slot.model != null:
		actor.set_model(slot.model)
	if not character_model:
		var outfit: DressedMannequin = DressedMannequin.new()
		outfit.name = "Outfit"
		outfit.role = dressed_role(node_name)
		outfit.variant = dressed_variant(node_name)
		actor.add_child(outfit)
	return actor


## Telar orientado con su extremo de trabajo en [constant LOOM_POSITION] y
## el resto tendido hacia la plaza (el modelo se extiende hacia su +Z).
func loom_transform() -> Transform3D:
	var toward: Vector3 = _plaza_center_flat() - LOOM_POSITION
	toward.y = 0.0
	return Transform3D(Basis.looking_at(-toward.normalized(), Vector3.UP), LOOM_POSITION)


## Sitio de la tejedora: arrodillada justo detrás del extremo del telar.
func weaver_position() -> Vector3:
	var loom: Transform3D = loom_transform()
	return loom.origin - loom.basis.z * WEAVER_LOOM_GAP
