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
const GRASS_COLOR: Color = Color(0.58, 0.55, 0.34, 1.0)
const ROCK_COLOR: Color = Color(0.5, 0.47, 0.42, 1.0)
## Tierra apisonada de la plaza y los caminos, que el terreno pinta con borde
## irregular (SurfaceMaterials).
const DIRT_COLOR: Color = Color(0.56, 0.46, 0.35, 1.0)
const ROCK_FROM_HEIGHT: float = 1.0
const ROCK_FULL_HEIGHT: float = 4.0
const DEBUG_PROFILE_KEY: Key = KEY_F2
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
const MODEL_HOUSES: Array[String] = ["pch_house_a.glb", "pch_house_b.glb", "pch_house_c.glb"]
const MODEL_QUERO: String = "pch_quero.glb"
const MODEL_PUTUTU: String = "pch_pututu.glb"
const MODEL_OFFERING: String = "pch_offering_shrine.glb"
const MODEL_LOOM: String = "pch_loom.glb"
## Props junto a la puerta de las viviendas (PCH-019 y PCH-020).
const MODEL_PROP_JAR: String = "pch_prop_jar.glb"
const MODEL_PROP_FIREWOOD: String = "pch_prop_firewood.glb"
## Fondo de las viviendas A, B y C, para dejar los props delante del muro.
const HOUSE_DEPTHS: Array[float] = [5.0, 4.6, 4.0]
## Lado izquierdo de la puerta de cada variante, donde van la leña o un cántaro.
const HOUSE_LEFT_PROP_X: Array[float] = [-2.1, -2.4, -1.7]
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
## Música de la introducción (ADR-0028, sustituye la pieza de quena de
## ADR-0027): los primeros 44 s de «Atlas • Bolivia» (Pixabay); se funde al
## tomar el control y deja solo el viento.
const INTRO_MUSIC_PATH: String = "res://shared_assets/audio/musica_intro_atlas_bolivia.ogg"
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
## Vecino que recibe al jugador junto al camino sur (ADR-0013).
const GREETER_POINT: Vector3 = Vector3(3.2, 0.0, 18.0)
## Tarjeta de fin (ADR-0026, sustituye el retraso de 50 s de ADR-0013): el
## evento ya termina unos 8 s después del último subtítulo, así que la tarjeta
## se funde casi enseguida, mientras la comitiva se aleja.
const END_CARD_DELAY: float = 0.5
const END_TITLE_KEY: StringName = &"PCH_END_TITLE"
const END_HINT_KEY: StringName = &"UI_END_HINT"
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


func _ready() -> void:
	var with_intro: bool = should_play_intro()
	var event: MessengerEvent = $EventController as MessengerEvent
	if event != null and with_intro:
		# El reloj del mensajero espera a que termine la introducción.
		event.start_on_bind = false
		event.set_process(false)
	_build_terrain()
	_build_llacta()
	player.global_position = player_spawn.global_position
	hud.bind(player, player.stamina)
	_setup_footsteps()
	environment_controller.bind(world_environment, sun)
	if with_intro:
		_start_intro()


## Indica si esta partida empieza con la introducción.
func should_play_intro() -> bool:
	match intro_mode:
		IntroMode.ALWAYS:
			return true
		IntroMode.NEVER:
			return false
	return is_inside_tree() and get_tree().current_scene == self


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
			get_tree().reload_current_scene()
			return
	if not OS.is_debug_build():
		return
	if not (event is InputEventKey):
		return
	var key_event: InputEventKey = event as InputEventKey
	if key_event.pressed and not key_event.echo and key_event.keycode == DEBUG_PROFILE_KEY:
		GraphicsSettings.cycle_profile()
		get_viewport().set_input_as_handled()


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
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.STONE, Color(0.55, 0.54, 0.51, 1.0))
	var thatch: ShaderMaterial = SurfaceMaterials.layer_material(SurfaceMaterials.Layer.THATCH, Color(0.55, 0.42, 0.2, 1.0))
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
		Vector3(-19.0, 0.0, 10.0),
		Vector3(-27.0, 0.0, 6.0),
		Vector3(-19.0, 0.0, -10.0),
		Vector3(19.0, 0.0, 10.0),
		Vector3(23.0, 0.0, 15.0),
		Vector3(19.0, 0.0, -10.0),
		Vector3(-9.0, 0.0, -21.0),
		Vector3(9.0, 0.0, -21.0),
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
	messenger.walk_speed = 5.2
	var curaca: NpcActor = _add_npc(npcs, "Curaca", Vector3(-7.0, 0.0, -3.0), Color(0.72, 0.55, 0.45, 1.0))
	var principal_one: NpcActor = _add_npc(npcs, "Principal1", Vector3(-8.5, 0.0, -1.0), Color(0.55, 0.42, 0.32, 1.0))
	var principal_two: NpcActor = _add_npc(npcs, "Principal2", Vector3(-9.0, 0.0, 2.0), Color(0.5, 0.4, 0.3, 1.0))
	var neighbor_one: NpcActor = _add_npc(npcs, "Habitante1", Vector3(9.0, 0.0, 4.0), Color(0.48, 0.36, 0.28, 1.0))
	var neighbor_two: NpcActor = _add_npc(npcs, "Habitante2", Vector3(11.0, 0.0, -1.0), Color(0.42, 0.33, 0.26, 1.0))
	var neighbor_three: NpcActor = _add_npc(npcs, "Habitante3", Vector3(7.0, 0.0, 8.0), Color(0.52, 0.4, 0.3, 1.0))
	weaver.face(_plaza_center_flat(), true)
	weaver.turn_body_to_talk = false
	weaver.set_idle_animation(&"weave")
	farmer.face(_plaza_center_flat(), true)
	farmer.set_idle_animation(&"work")
	for actor: Node in npcs.get_children():
		(actor as NpcActor).watch_target = player
	_setup_npc_sounds(npcs, weaver, farmer)
	_attach_object_models(llacta)
	var talks: Array[NpcTalk] = [
		_add_talk(weaver, &"PCH_TALK_WEAVER"),
		_add_talk(farmer, &"PCH_TALK_FARMER"),
		_add_talk(curaca, &"PCH_TALK_CURACA"),
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
		routes[one] = PackedVector3Array([one.position, Vector3(16.0, 0.0, 1.0), Vector3(16.0, 0.0, -5.0), Vector3(9.0, 0.0, -2.0)])
	if two != null:
		routes[two] = PackedVector3Array([two.position, Vector3(6.0, 0.0, -9.0), Vector3(-5.0, 0.0, -9.0), Vector3(2.0, 0.0, -3.0)])
	if three != null:
		routes[three] = PackedVector3Array([three.position, Vector3(12.0, 0.0, 12.0), Vector3(4.0, 0.0, 12.0)])
	return routes


## Añade «Hablar» a un personaje con su frase.
func _add_talk(actor: NpcActor, line_key: StringName) -> NpcTalk:
	if actor == null:
		return null
	var packed: PackedScene = load(TALK_SCENE) as PackedScene
	if packed == null:
		return null
	var talk: NpcTalk = packed.instantiate() as NpcTalk
	if talk == null:
		return null
	talk.line_key = line_key
	actor.add_child(talk)
	talk.spoke.connect(_on_npc_spoke)
	return talk


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
	if hud == null:
		return
	hud.show_subtitle(tr(String(text_key)), seconds)


## Indica si el murmullo de la plaza debe sonar en una fase del evento: desde
## la noticia hasta que suena el pututu.
static func murmur_plays_in(phase: int) -> bool:
	return phase == MessengerEvent.Phase.MESSAGE or phase == MessengerEvent.Phase.CALL


func _on_event_phase_changed(phase: int) -> void:
	if murmur_plays_in(phase):
		_start_murmur()
	else:
		_stop_murmur()


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
	var wind: LlactaWind = get_node_or_null("Wind") as LlactaWind
	if wind != null:
		wind.ambience = player_audio
		wind.ambience_base_db = player_audio.volume_db



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
static func npc_model_files(node_name: String) -> Array[String]:
	var role: String = "villager"
	var generic: String = MODEL_COMMONER
	match node_name:
		"Tejedora":
			role = "weaver"
		"Agricultor":
			role = "farmer"
		"Mensajero":
			role = "messenger"
		"Curaca":
			role = "curaca"
			generic = MODEL_AUTHORITY
		"Principal1", "Principal2":
			role = "principal"
			generic = MODEL_AUTHORITY
		# Tres vecinas distintas, no tres copias (ADR-0017).
		"Habitante2":
			role = "villager_b"
		"Habitante3":
			role = "villager_c"
	var files: Array[String] = ["pch_npc_%s.glb" % role, generic]
	return files


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
		paths.append(MODEL_DIR + file)
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
	var slot: ModelSlot = _attach_model(slot_parent, "ModelSlot", slot_offset, npc_model_files(node_name), blockout, no_collisions)
	slot.use_model_collision = false
	if slot.model != null:
		actor.set_model(slot.model)
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
