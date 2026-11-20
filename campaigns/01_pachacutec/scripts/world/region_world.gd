class_name RegionWorld
extends Node3D
## Mundo regional de la campaña 01: terreno continuo y sectores transmitidos.
##
## El relieve siempre está cargado; los sectores aportan props, edificios y NPC.
## El objetivo se mueve por la región sin cambiar de escena ni mostrar pantallas
## de carga. `autowalk` es una ayuda de blockout para revisar el recorrido.

const SECTOR_DEFINITIONS: Array[String] = [
	"res://campaigns/01_pachacutec/data/sectors/s1_cusco.tres",
	"res://campaigns/01_pachacutec/data/sectors/s2_afueras.tres",
	"res://campaigns/01_pachacutec/data/sectors/s3_llacta.tres",
	"res://campaigns/01_pachacutec/data/sectors/s4_quebrada.tres",
	"res://campaigns/01_pachacutec/data/sectors/s5_paso.tres",
	"res://campaigns/01_pachacutec/data/sectors/s6_frontera.tres",
]

const REVIEW_LABEL_LIMIT: int = 1
const REVIEW_LABEL_PIXEL: float = 0.03

## Escena del jugador en primera persona; el mundo regional la instancia cuando
## `first_person` está activo.
const PLAYER_SCENE: String = "res://core/player/player_fps.tscn"
## Punto de aparición a pie: plaza del arrabal de Chocos-chacona (S1 Cusco),
## mirando hacia la plaza de la ciudad. La campaña empieza en la ciudad: el
## jugador vive en el arrabal que resiste la defensa.
const SPAWN_POINT: Vector3 = Vector3(1088.0, 0.0, 294.0)
const SPAWN_YAW_DEGREES: float = -133.4
## Altura sobre el terreno a la que se deja caer al jugador al aparecer.
const SPAWN_CLEARANCE: float = 1.5
## Caída máxima respecto al terreno antes de devolver al jugador al inicio.
const FALL_RESPAWN_DEPTH: float = 120.0
## Nodos cosméticos del jugador que el blockout no equipa.
const UNEQUIPPED_NODES: Array[String] = [
	"Head/Camera3D/FirstPersonHands",
	"Head/Camera3D/FirstPersonWeapon",
]

const ROUTE: Array[Vector3] = [
	Vector3(1200.0, 0.0, 400.0),
	Vector3(750.0, 0.0, 150.0),
	Vector3(300.0, 0.0, 0.0),
	Vector3(-700.0, 0.0, 350.0),
	Vector3(-1300.0, 0.0, 100.0),
	Vector3(-1650.0, 0.0, 0.0),
]

@export var autowalk: bool = false
@export var walk_speed: float = 80.0
@export var camera_offset: Vector3 = Vector3(38.0, 26.0, 48.0)
@export var top_down_size: float = 240.0
## Arranca con jugador en primera persona. Si se desactiva, la escena queda como
## cámara de revisión del blockout.
@export var first_person: bool = true

var _region: CampaignRegion = null
var _streamer: SectorStreamer = null
var _target: Node3D = null
var _camera: Camera3D = null
var _player: PlayerFPS = null
var _interiors: InteriorController = null
var _spawn_position: Vector3 = Vector3.ZERO
var _route_index: int = 0
var _labels_visible: bool = false
var _top_down: bool = false
var _hud: Label = null


func _ready() -> void:
	add_to_group(&"region_world")
	_region = get_node("Region") as CampaignRegion
	_streamer = get_node("SectorStreamer") as SectorStreamer
	_target = get_node("StreamTarget") as Node3D
	_camera = get_node("Camera") as Camera3D
	var region_camera: Camera3D = _region.get_camera()
	if region_camera != null:
		region_camera.current = false
	_camera.current = true
	var definitions: Array[SectorDefinition] = []
	for path: String in SECTOR_DEFINITIONS:
		var definition: SectorDefinition = load(path) as SectorDefinition
		if definition != null:
			definitions.append(definition)
	_streamer.sectors = definitions
	_streamer.sector_size = 512.0
	_streamer.load_radius = 2
	_streamer.unload_radius = 3
	_streamer.target = _target
	_streamer.rebuild_index()
	_streamer.refresh()
	var discovery: DiscoveryService = get_node("Discovery") as DiscoveryService
	if discovery != null:
		discovery.set_target(_target)
		discovery.load_catalog("res://campaigns/01_pachacutec/data/pois")
	if first_person:
		_build_player()
		_build_interiors()
	_build_review_hud()
	_update_camera()


func _process(delta: float) -> void:
	if autowalk:
		_advance_route(delta)
	_follow_player()
	_update_camera()
	_update_labels()


func _unhandled_input(event: InputEvent) -> void:
	# El blockout no tiene menú de pausa: si Esc llegara a GameManager, congelaría
	# el árbol sin ninguna interfaz que lo explique.
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		return
	if not (event is InputEventKey):
		return
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_H:
		toggle_labels()
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_T:
		toggle_top_down()
		get_viewport().set_input_as_handled()


## Muestra u oculta las etiquetas de POI más cercanas.
func toggle_labels() -> void:
	_labels_visible = not _labels_visible
	_update_labels()


func toggle_top_down() -> void:
	_top_down = not _top_down
	_update_camera()


func is_top_down() -> bool:
	return _top_down


func get_visible_label_count() -> int:
	var count: int = 0
	for id: StringName in _streamer.get_loaded_ids():
		var node: Node3D = _streamer.get_loaded_node(id)
		if node == null:
			continue
		for label: Node in node.find_children("*", "Label3D", true, false):
			if (label as Label3D).visible:
				count += 1
	return count


func set_target_position(target_position: Vector3) -> void:
	if _target != null:
		_target.global_position = target_position
		if _streamer != null:
			_streamer.refresh()


func get_streamer() -> SectorStreamer:
	return _streamer


func get_discovery() -> DiscoveryService:
	return get_node_or_null("Discovery") as DiscoveryService


func get_region() -> CampaignRegion:
	return _region


func get_route_point(index: int) -> Vector3:
	if index < 0 or index >= ROUTE.size():
		return Vector3.ZERO
	return ROUTE[index]


## Jugador en primera persona, o `null` si la escena está en modo revisión.
func get_player() -> PlayerFPS:
	return _player


func get_interiors() -> InteriorController:
	return _interiors


func _build_interiors() -> void:
	_interiors = InteriorController.new()
	_interiors.name = "Interiors"
	add_child(_interiors)
	_interiors.set_player(_player)


## Indica si el mundo arrancó con jugador a pie.
func is_first_person() -> bool:
	return _player != null


## Instancia el jugador en el camino de entrada a la llacta, sobre el terreno.
func _build_player() -> void:
	if autowalk:
		return
	var packed: PackedScene = load(PLAYER_SCENE) as PackedScene
	if packed == null:
		push_error("RegionWorld: no se encontró la escena del jugador.")
		return
	_player = packed.instantiate() as PlayerFPS
	if _player == null:
		push_error("RegionWorld: la escena del jugador no es PlayerFPS.")
		return
	_player.name = "Player"
	_spawn_position = _ground_position(SPAWN_POINT)
	_player.position = _spawn_position
	_player.rotation_degrees.y = SPAWN_YAW_DEGREES
	add_child(_player)
	_hide_unequipped()
	_target.global_position = _spawn_position
	if _streamer != null:
		_streamer.refresh()


## El blockout no reparte equipo: sin manos ni arma en pantalla.
func _hide_unequipped() -> void:
	for path: String in UNEQUIPPED_NODES:
		var node: Node3D = _player.get_node_or_null(path) as Node3D
		if node != null:
			node.hide()


## Mantiene el objetivo del streaming sobre el jugador y lo rescata si cae fuera
## del terreno.
func _follow_player() -> void:
	if _player == null or _target == null:
		return
	var player_position: Vector3 = _player.global_position
	_target.global_position = player_position
	if _player.is_on_floor():
		return
	var ground: float = _region.height_at(player_position.x, player_position.z)
	if player_position.y < ground - FALL_RESPAWN_DEPTH:
		_respawn_player()


func _respawn_player() -> void:
	_player.velocity = Vector3.ZERO
	_player.global_position = _spawn_position
	_target.global_position = _spawn_position


## Posición de aparición: el punto pedido, elevado sobre el terreno.
func _ground_position(point: Vector3) -> Vector3:
	return Vector3(point.x, _region.height_at(point.x, point.z) + SPAWN_CLEARANCE, point.z)


func _advance_route(delta: float) -> void:
	if _target == null:
		return
	var goal: Vector3 = ROUTE[_route_index]
	var next: Vector3 = _target.global_position.move_toward(goal, walk_speed * delta)
	_target.global_position = next
	if next.distance_to(goal) < 1.0:
		_route_index = (_route_index + 1) % ROUTE.size()


func _update_camera() -> void:
	if _camera == null or _target == null or _region == null:
		return
	var center: Vector3 = _target.global_position
	var ground: float = _region.height_at(center.x, center.z)
	if _top_down:
		_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		_camera.size = top_down_size
		_camera.near = 1.0
		_camera.far = 12000.0
		_camera.position = Vector3(center.x, ground + 3000.0, center.z)
		_camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		_activate_camera(_camera)
		return
	_camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	_camera.fov = 55.0
	_camera.near = 0.1
	_camera.far = 12000.0
	_camera.position = Vector3(
		center.x + camera_offset.x, ground + camera_offset.y, center.z + camera_offset.z
	)
	_camera.look_at(Vector3(center.x, ground + 6.0, center.z), Vector3.UP)
	if _player != null and _player.camera != null:
		_activate_camera(_player.camera)
	else:
		_activate_camera(_camera)


## Deja [param camera] como cámara activa sin reasignarla en cada fotograma.
func _activate_camera(camera: Camera3D) -> void:
	if camera != null and not camera.current:
		camera.current = true


func _update_labels() -> void:
	if _streamer == null or _target == null:
		return
	var candidates: Array[Dictionary] = []
	for id: StringName in _streamer.get_loaded_ids():
		var node: Node3D = _streamer.get_loaded_node(id)
		if node == null:
			continue
		for label: Node in node.find_children("*", "Label3D", true, false):
			var label_3d: Label3D = label as Label3D
			var distance: float = (
				Vector2(
					label_3d.global_position.x - _target.global_position.x,
					label_3d.global_position.z - _target.global_position.z
				)
				. length()
			)
			candidates.append({"label": label_3d, "distance": distance})
	candidates.sort_custom(_closer_label)
	for index: int in candidates.size():
		var label_3d: Label3D = candidates[index]["label"]
		label_3d.visible = _labels_visible and index < REVIEW_LABEL_LIMIT
		if label_3d.visible:
			label_3d.pixel_size = REVIEW_LABEL_PIXEL
			label_3d.outline_size = 8


func _closer_label(first: Dictionary, second: Dictionary) -> bool:
	return str(first["distance"]).to_float() < str(second["distance"]).to_float()


func _build_review_hud() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.name = "ReviewHud"
	add_child(layer)
	_hud = Label.new()
	_hud.text = tr("PCH_PLAY_CONTROLS") if _player != null else tr("PCH_REVIEW_CONTROLS")
	_hud.position = Vector2(16.0, 12.0)
	_hud.add_theme_font_size_override("font_size", 18)
	_hud.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.9))
	layer.add_child(_hud)
