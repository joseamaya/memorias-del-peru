class_name NpcMover
extends RefCounted
## Sigue una ruta de navegación para un NPC.
##
## Solo mueve el nodo: quién decide el destino, cuándo recalcular la ruta y
## qué velocidad aplicar es responsabilidad del sistema que lo usa.

var speed: float = 1.6
## Altura del centro del cuerpo sobre el punto de la ruta.
var body_offset: float = 0.9
## Altura del suelo para un XZ. Si está definido, manda sobre la Y de la ruta:
## al caminar por una pendiente el cuerpo sigue el terreno y no la cuerda del
## navmesh. Debe devolver metros o NAN si no hay dato.
var ground_sampler: Callable = Callable()

var _path: PackedVector3Array = PackedVector3Array()
var _index: int = 0


func _init(sampler: Callable = Callable()) -> void:
	ground_sampler = sampler


func set_path(path: PackedVector3Array) -> void:
	_path = path
	_index = 0


func get_path() -> PackedVector3Array:
	return _path


func is_finished() -> bool:
	return _path.is_empty() or _index >= _path.size()


## Avanza el nodo a lo largo de la ruta durante `delta` segundos.
func advance(node: Node3D, delta: float) -> void:
	if node == null or delta <= 0.0 or _path.is_empty():
		return
	var remaining: float = speed * delta
	while _index < _path.size() and remaining > 0.0:
		var point: Vector3 = _path[_index]
		var start: Vector3 = node.position
		var goal: Vector3 = Vector3(point.x, start.y, point.z)
		var distance: float = start.distance_to(goal)
		if distance <= remaining:
			node.position = Vector3(point.x, _height_for(point.x, point.z, point.y), point.z)
			remaining -= distance
			_index += 1
		else:
			node.position = start.move_toward(goal, remaining)
			if not _apply_ground(node):
				_interpolate_height(node, start, point)
			remaining = 0.0
	if _index >= _path.size():
		var last: Vector3 = _path[_path.size() - 1]
		node.position = Vector3(last.x, _height_for(last.x, last.z, last.y), last.z)


## Pone la Y del nodo en el suelo muestreado. Devuelve `false` sin muestreador.
func _apply_ground(node: Node3D) -> bool:
	var ground: float = _sample_ground(node.position.x, node.position.z)
	if not is_finite(ground):
		return false
	node.position.y = ground + body_offset
	return true


## Altura del centro del cuerpo en un XZ, o la de la ruta si no hay suelo.
func _height_for(x: float, z: float, fallback: float) -> float:
	var ground: float = _sample_ground(x, z)
	return (ground + body_offset) if is_finite(ground) else fallback + body_offset


func _sample_ground(x: float, z: float) -> float:
	if not ground_sampler.is_valid():
		return NAN
	var value: Variant = ground_sampler.call(x, z)
	if value is float:
		var ground: float = value
		return ground
	if value is int:
		var whole: int = value
		return float(whole)
	return NAN


func _interpolate_height(node: Node3D, start: Vector3, point: Vector3) -> void:
	var total: float = Vector2(start.x - point.x, start.z - point.z).length()
	if total <= 0.001:
		return
	var moved: float = Vector2(start.x - node.position.x, start.z - node.position.z).length()
	var target_y: float = point.y + body_offset
	node.position.y = lerpf(start.y, target_y, clampf(moved / total, 0.0, 1.0))
