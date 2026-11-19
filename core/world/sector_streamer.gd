class_name SectorStreamer
extends Node3D
## Carga y descarga sectores exteriores por cercanía.
##
## Es un sistema de Core: no conoce campañas. El mundo declara sectores con
## [SectorDefinition] y el streamer carga las escenas dentro de `load_radius`
## y descarga las que quedan fuera de `unload_radius`. La diferencia entre
## ambos radios evita cargas y descargas en el borde.
##
## La carga usa `ResourceLoader.load_threaded_request`; el terreno de la región
## puede permanecer cargado y los sectores aportan props, edificios y NPC.

signal sector_loaded(id: StringName, node: Node3D)
signal sector_unloaded(id: StringName)
signal sector_load_failed(id: StringName, error: int)

@export var sectors: Array[SectorDefinition] = []
@export var sector_size: float = 256.0
@export_range(0, 8, 1) var load_radius: int = 2
@export_range(0, 12, 1) var unload_radius: int = 3
@export var target: Node3D = null
@export var update_interval: float = 0.25

var _definitions: Dictionary[StringName, SectorDefinition] = {}
var _loaded: Dictionary[StringName, Node3D] = {}
var _pending: Dictionary[StringName, bool] = {}
var _pending_paths: Dictionary[StringName, String] = {}
var _elapsed: float = 0.0


func _ready() -> void:
	rebuild_index()
	if target != null:
		refresh()


func _process(delta: float) -> void:
	_poll_pending()
	if target == null:
		return
	_elapsed += delta
	if _elapsed < update_interval:
		return
	_elapsed = 0.0
	refresh()


## Reconstruye el índice de definiciones. Llamar después de cambiar `sectors`.
func rebuild_index() -> void:
	_definitions.clear()
	for definition: SectorDefinition in sectors:
		if definition != null and definition.id != &"":
			_definitions[definition.id] = definition


## Fija el nodo que marca la posición del jugador.
func set_target(value: Node3D) -> void:
	target = value
	if is_inside_tree() and target != null:
		refresh()


## Nodo de referencia actual, o `null`.
func get_target() -> Node3D:
	return target


## Celda de la región que contiene una posición mundial.
func get_cell_for_position(world_position: Vector3) -> Vector2i:
	var size: float = maxf(sector_size, 1.0)
	return Vector2i(floori(world_position.x / size), floori(world_position.z / size))


## Definiciones dentro del radio de carga, incluidas las siempre cargadas.
func get_needed_definitions(cell: Vector2i) -> Array[SectorDefinition]:
	var result: Array[SectorDefinition] = []
	for definition: SectorDefinition in _definitions.values():
		if definition.always_loaded:
			result.append(definition)
			continue
		var distance: int = _distance(definition.grid_position, cell)
		if distance <= load_radius:
			result.append(definition)
	return result


## Sectores cargados que ya quedaron fuera del radio de descarga.
func get_unload_ids(cell: Vector2i) -> Array[StringName]:
	var result: Array[StringName] = []
	for id: StringName in _loaded.keys():
		if not _definitions.has(id):
			continue
		var definition: SectorDefinition = _definitions[id]
		if definition.always_loaded:
			continue
		if _distance(definition.grid_position, cell) > unload_radius:
			result.append(id)
	return result


## Distancia de una celda de sector a otra, en celdas (Chebyshev).
func get_sector_distance(id: StringName, cell: Vector2i) -> int:
	if not _definitions.has(id):
		return 9999
	var definition: SectorDefinition = _definitions[id]
	return _distance(definition.grid_position, cell)


## Definición registrada por ID, o `null`.
func get_definition(id: StringName) -> SectorDefinition:
	if not _definitions.has(id):
		return null
	return _definitions[id]


## Registra una definición y la añade a `sectors`.
func register_definition(definition: SectorDefinition) -> void:
	if definition == null or definition.id == &"":
		return
	if not sectors.has(definition):
		sectors.append(definition)
	_definitions[definition.id] = definition


## Indica si un sector está cargado.
func is_loaded(id: StringName) -> bool:
	return _loaded.has(id)


## Nodo cargado, o `null`.
func get_loaded_node(id: StringName) -> Node3D:
	if not _loaded.has(id):
		return null
	return _loaded[id]


## IDs cargados.
func get_loaded_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for id: StringName in _loaded.keys():
		result.append(id)
	return result


## IDs con carga en curso.
func get_pending_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for id: StringName in _pending.keys():
		result.append(id)
	return result


## Recalcula qué sectores deben estar cargados.
func refresh() -> void:
	if target == null:
		return
	var cell: Vector2i = get_cell_for_position(target.global_position)
	for definition: SectorDefinition in get_needed_definitions(cell):
		_request(definition)
	for id: StringName in get_unload_ids(cell):
		unload_sector(id)


## Descarga un sector cargado.
func unload_sector(id: StringName) -> void:
	if not _loaded.has(id):
		return
	var node: Node3D = _loaded[id]
	_loaded.erase(id)
	node.queue_free()
	sector_unloaded.emit(id)


## Descarga todos los sectores.
func unload_all() -> void:
	var ids: Array[StringName] = get_loaded_ids()
	for id: StringName in ids:
		unload_sector(id)


func _request(definition: SectorDefinition) -> void:
	if _loaded.has(definition.id) or _pending.has(definition.id):
		return
	if not definition.is_valid():
		sector_load_failed.emit(definition.id, ERR_FILE_NOT_FOUND)
		return
	var error: Error = ResourceLoader.load_threaded_request(
		definition.scene_path, "PackedScene", true
	)
	if error != OK:
		sector_load_failed.emit(definition.id, error)
		return
	_pending[definition.id] = true
	_pending_paths[definition.id] = definition.scene_path


func _poll_pending() -> void:
	if _pending.is_empty():
		return
	var ids: Array[StringName] = get_pending_ids()
	for id: StringName in ids:
		var path: String = _pending_paths.get(id, "")
		if path.is_empty():
			_forget_pending(id)
			continue
		var status: int = ResourceLoader.load_threaded_get_status(path)
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				_finish_load(id, path)
			ResourceLoader.THREAD_LOAD_FAILED:
				_forget_pending(id)
				sector_load_failed.emit(id, ERR_FILE_CORRUPT)
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				_forget_pending(id)
				sector_load_failed.emit(id, ERR_INVALID_DATA)


func _finish_load(id: StringName, path: String) -> void:
	var resource: Resource = ResourceLoader.load_threaded_get(path)
	_forget_pending(id)
	var packed: PackedScene = _as_packed_scene(resource)
	if packed == null:
		sector_load_failed.emit(id, ERR_INVALID_DATA)
		return
	var instance: Node = packed.instantiate()
	if instance == null:
		sector_load_failed.emit(id, ERR_INVALID_DATA)
		return
	var world_node: Node3D = _as_node3d(instance)
	if world_node == null:
		instance.queue_free()
		sector_load_failed.emit(id, ERR_INVALID_DATA)
		return
	add_child(world_node)
	_loaded[id] = world_node
	sector_loaded.emit(id, world_node)


func _forget_pending(id: StringName) -> void:
	_pending.erase(id)
	_pending_paths.erase(id)


func _distance(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


# El recurso viene del cargador y se comprueba con `is`; se concentra aquí la
# única conversión necesaria.
static func _as_packed_scene(value: Resource) -> PackedScene:
	if not (value is PackedScene):
		return null
	@warning_ignore("unsafe_cast")
	return value as PackedScene


static func _as_node3d(value: Node) -> Node3D:
	if not (value is Node3D):
		return null
	@warning_ignore("unsafe_cast")
	return value as Node3D
