class_name DiscoveryService
extends Node
## Descubre POI por proximidad, diálogo o evento y alimenta el diario.
##
## El catálogo de POI vive en la campaña. El servicio no conoce IDs concretos:
## carga los recursos de un directorio, consulta el estado del mundo y guarda
## los descubrimientos en `WorldState`. El diario y el mapa solo muestran lo
## descubierto.

signal poi_discovered(id: StringName)

@export var target: Node3D = null
@export var auto_discover: bool = true
@export var world_stage: int = 0

var _definitions: Dictionary[StringName, PoiDefinition] = {}
var _discovered: Dictionary[StringName, bool] = {}
var _catalog_path: String = ""


## Carga los POI del directorio y sincroniza los ya descubiertos.
func load_catalog(directory: String) -> int:
	_catalog_path = directory
	_definitions.clear()
	var files: PackedStringArray = DirAccess.get_files_at(directory)
	files.sort()
	for file_name: String in files:
		if not file_name.ends_with(".tres"):
			continue
		var definition: PoiDefinition = load(directory.path_join(file_name)) as PoiDefinition
		if definition != null and definition.is_valid():
			_definitions[definition.id] = definition
	_sync_discovered()
	return _definitions.size()


## Marca un POI como descubierto si existe y la fase lo permite.
func discover(id: StringName) -> bool:
	if not _definitions.has(id) or _discovered.has(id):
		return false
	var definition: PoiDefinition = _definitions[id]
	if not definition.is_available(world_stage):
		return false
	_discovered[id] = true
	var state: WorldStateService = _world_state()
	if state != null:
		state.discover(id)
	poi_discovered.emit(id)
	return true


func set_target(node: Node3D) -> void:
	target = node


func get_count() -> int:
	return _definitions.size()


func get_discovered_count() -> int:
	return _discovered.size()


func is_discovered(id: StringName) -> bool:
	return _discovered.has(id)


func get_definition(id: StringName) -> PoiDefinition:
	return _definitions.get(id, null)


## Entradas del diario, solo para POI descubiertos.
func get_journal() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for id: StringName in _definitions.keys():
		if not _discovered.has(id):
			continue
		var definition: PoiDefinition = _definitions[id]
		(
			entries
			. append(
				{
					"id": String(id),
					"name": definition.display_name,
					"description": definition.description,
					"sector": String(definition.sector),
					"classification": definition.classification,
				}
			)
		)
	return entries


## Puntos del mapa, solo para POI descubiertos.
func get_map_points() -> Array[Vector3]:
	var points: Array[Vector3] = []
	for id: StringName in _definitions.keys():
		if _discovered.has(id):
			points.append(_definitions[id].position)
	return points


func _process(_delta: float) -> void:
	if not auto_discover or target == null:
		return
	for id: StringName in _definitions.keys():
		if _discovered.has(id):
			continue
		var definition: PoiDefinition = _definitions[id]
		if definition.trigger != PoiDefinition.Trigger.PROXIMITY:
			continue
		if not definition.is_available(world_stage):
			continue
		if _distance_to(definition.position) <= definition.radius:
			discover(id)


func _sync_discovered() -> void:
	_discovered.clear()
	var state: WorldStateService = _world_state()
	for id: StringName in _definitions.keys():
		var definition: PoiDefinition = _definitions[id]
		var known: bool = state != null and state.is_discovered(id)
		if known or definition.trigger == PoiDefinition.Trigger.START:
			_discovered[id] = true
			if state != null and not known:
				state.discover(id)


func _distance_to(point: Vector3) -> float:
	if target == null:
		return INF
	var origin: Vector3 = target.global_position
	return Vector2(point.x - origin.x, point.z - origin.z).length()


func _world_state() -> WorldStateService:
	return get_node_or_null("/root/WorldState") as WorldStateService
