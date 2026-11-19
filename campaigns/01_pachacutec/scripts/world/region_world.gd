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

var _region: CampaignRegion = null
var _streamer: SectorStreamer = null
var _target: Node3D = null
var _camera: Camera3D = null
var _route_index: int = 0


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
	_update_camera()


func _process(delta: float) -> void:
	if autowalk:
		_advance_route(delta)
	_update_camera()


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
	var ground: float = _region.height_at(_target.global_position.x, _target.global_position.z)
	_camera.position = Vector3(
		_target.global_position.x + 120.0, ground + 130.0, _target.global_position.z + 160.0
	)
	_camera.look_at(
		Vector3(_target.global_position.x, ground + 20.0, _target.global_position.z), Vector3.UP
	)
