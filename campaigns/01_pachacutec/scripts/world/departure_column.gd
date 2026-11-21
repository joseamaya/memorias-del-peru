class_name DepartureColumn
extends Node3D
## Columna authored de la partida: vecinos y orejones que abandonan la ciudad.
##
## No es un ejército simulado: siete cápsulas que caminan hacia el oeste y se
## liberan al cabo de medio minuto. La altura se toma del terreno para que no
## floten en la ladera.

const WALKERS: int = 7
const SPEED: float = 1.4
const DURATION: float = 30.0
const SPACING: float = 1.7
const BODY_RADIUS: float = 0.33
const BODY_HEIGHT: float = 1.7
const NOBLE_COLOR: Color = Color(0.78, 0.66, 0.38)
const COMMONER_COLOR: Color = Color(0.58, 0.45, 0.32)

var _walkers: Array[MeshInstance3D] = []
var _direction: Vector3 = Vector3.LEFT
var _elapsed: float = 0.0
var _region: CampaignRegion = null


## Coloca la columna en [param start] y la hace caminar en [param direction].
func setup(start: Vector3, direction: Vector3, region: CampaignRegion) -> void:
	_region = region
	_direction = direction.normalized()
	position = start
	for index: int in WALKERS:
		_build_walker(index)


func get_walker_count() -> int:
	return _walkers.size()


func _process(delta: float) -> void:
	if _walkers.is_empty():
		return
	_elapsed += delta
	position += _direction * SPEED * delta
	_ground_walkers()
	if _elapsed >= DURATION:
		queue_free()


func _build_walker(index: int) -> void:
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = BODY_RADIUS
	capsule.height = BODY_HEIGHT
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = NOBLE_COLOR if index < 3 else COMMONER_COLOR
	capsule.material = material
	var walker: MeshInstance3D = MeshInstance3D.new()
	walker.name = "Walker_%d" % index
	walker.mesh = capsule
	var back: float = float(index) * SPACING
	var side: float = 0.9 if index % 2 == 0 else -0.9
	var lateral: Vector3 = _direction.cross(Vector3.UP)
	walker.position = -_direction * back + lateral * side * float(index % 3) * 0.4
	add_child(walker)
	_walkers.append(walker)
	_ground_walkers()


## Ajusta cada caminante a la altura del terreno en su posición.
func _ground_walkers() -> void:
	if _region == null:
		return
	for walker: MeshInstance3D in _walkers:
		var point: Vector3 = walker.global_position
		walker.global_position = Vector3(
			point.x, _region.height_at(point.x, point.z) + BODY_HEIGHT * 0.5, point.z
		)
