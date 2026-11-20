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

var _region: CampaignRegion = null
var _streamer: SectorStreamer = null
var _target: Node3D = null
var _camera: Camera3D = null
var _route_index: int = 0
var _labels_visible: bool = false
var _top_down: bool = false
var _hud: Label = null


func _ready() -> void:
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
	_build_review_hud()
	_update_camera()


func _process(delta: float) -> void:
	if autowalk:
		_advance_route(delta)
	_update_camera()
	_update_labels()


func _unhandled_input(event: InputEvent) -> void:
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
		return
	_camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	_camera.fov = 55.0
	_camera.near = 0.1
	_camera.far = 12000.0
	_camera.position = Vector3(
		center.x + camera_offset.x, ground + camera_offset.y, center.z + camera_offset.z
	)
	_camera.look_at(Vector3(center.x, ground + 6.0, center.z), Vector3.UP)


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
	_hud.text = tr("PCH_REVIEW_CONTROLS")
	_hud.position = Vector2(16.0, 12.0)
	_hud.add_theme_font_size_override("font_size", 18)
	_hud.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.9))
	layer.add_child(_hud)
