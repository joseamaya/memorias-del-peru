class_name NpcMover
extends RefCounted
## Sigue una ruta de navegación para un NPC.
##
## Solo mueve el nodo: quién decide el destino, cuándo recalcular la ruta y
## qué velocidad aplicar es responsabilidad del sistema que lo usa.

var speed: float = 1.6
## Altura del centro del cuerpo sobre el punto de la ruta.
var body_offset: float = 0.9

var _path: PackedVector3Array = PackedVector3Array()
var _index: int = 0


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
			node.position = Vector3(point.x, point.y + body_offset, point.z)
			remaining -= distance
			_index += 1
		else:
			node.position = start.move_toward(goal, remaining)
			_interpolate_height(node, start, point)
			remaining = 0.0
	if _index >= _path.size():
		var last: Vector3 = _path[_path.size() - 1]
		node.position = Vector3(last.x, last.y + body_offset, last.z)


func _interpolate_height(node: Node3D, start: Vector3, point: Vector3) -> void:
	var total: float = Vector2(start.x - point.x, start.z - point.z).length()
	if total <= 0.001:
		return
	var moved: float = Vector2(start.x - node.position.x, start.z - node.position.z).length()
	var target_y: float = point.y + body_offset
	node.position.y = lerpf(start.y, target_y, clampf(moved / total, 0.0, 1.0))
