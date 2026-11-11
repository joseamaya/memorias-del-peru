class_name NpcActor
extends Node3D
## Personaje no jugable con desplazamiento simple.
##
## Se mueve hacia un punto a velocidad constante y se orienta hacia donde mira.
## El avance lo impulsa quien lo posee (el evento), no `_process`, para que las
## pruebas puedan avanzar la simulación sin esperar en tiempo real.

@export var body_color: Color = Color(0.6, 0.45, 0.35, 1.0)
@export var walk_speed: float = 3.2

@onready var body: MeshInstance3D = $Body
@onready var collision: StaticBody3D = $Collision

var target: Vector3 = Vector3.ZERO
var moving: bool = false
var _idle_tween: Tween = null


func _ready() -> void:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = body_color
	material.roughness = 1.0
	body.material_override = material
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(body, "position:y", 0.03, 0.9).as_relative()
	_idle_tween.tween_property(body, "position:y", -0.03, 0.9).as_relative()


## Fija un destino. La orientación se actualiza al empezar a caminar.
func walk_to(point: Vector3) -> void:
	target = Vector3(point.x, global_position.y, point.z)
	moving = true
	face(target)
	if _idle_tween != null and _idle_tween.is_valid():
		_idle_tween.pause()


## Se detiene donde está.
func stop() -> void:
	moving = false
	if _idle_tween != null and _idle_tween.is_valid():
		_idle_tween.play()


## Gira el cuerpo hacia un punto, sin inclinarlo.
func face(point: Vector3) -> void:
	var flat: Vector3 = Vector3(point.x, global_position.y, point.z)
	if flat.is_equal_approx(global_position):
		return
	look_at(flat, Vector3.UP)


## Avanza hacia el destino. Devuelve `true` si acaba de llegar.
func advance(delta: float) -> bool:
	if not moving:
		return false
	var distance: float = global_position.distance_to(target)
	var step: float = walk_speed * delta
	if distance <= step:
		global_position = target
		stop()
		return true
	global_position = global_position.move_toward(target, step)
	return false


## Distancia horizontal al punto indicado.
func flat_distance_to(point: Vector3) -> float:
	return Vector2(global_position.x, global_position.z).distance_to(Vector2(point.x, point.z))
