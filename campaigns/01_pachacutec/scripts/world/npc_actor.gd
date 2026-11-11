class_name NpcActor
extends Node3D
## Personaje no jugable con desplazamiento simple.
##
## Se mueve hacia un punto a velocidad constante y se orienta hacia donde mira.
## El avance lo impulsa quien lo posee (el evento), no `_process`, para que las
## pruebas puedan avanzar la simulación sin esperar en tiempo real.

@export var body_color: Color = Color(0.6, 0.45, 0.35, 1.0)
@export var walk_speed: float = 3.2

## Balanceo de piernas al caminar (ADR-0013): sin rig, el modelo trae las
## piernas como nodos aparte y el personaje las gira sobre su eje X.
const LEG_SWING_DEGREES: float = 24.0
## Los brazos acompañan en sentido contrario a la pierna de su lado.
const ARM_SWING_RATIO: float = 0.7
## Metros recorridos en medio ciclo de paso.
const STRIDE_LENGTH: float = 0.75

@onready var body: MeshInstance3D = $Body
@onready var collision: StaticBody3D = $Collision

var target: Vector3 = Vector3.ZERO
var moving: bool = false
var _idle_tween: Tween = null
var _legs: Array[Node3D] = []
var _arms: Array[Node3D] = []
var _stride_phase: float = 0.0


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


## Asigna las piernas del modelo (pueden faltar: entonces no hay balanceo).
func set_legs(left: Node3D, right: Node3D) -> void:
	_legs.clear()
	if left != null and right != null:
		_legs.append(left)
		_legs.append(right)
	_apply_legs()


## Asigna los brazos del modelo, del mismo lado que [method set_legs].
func set_arms(left: Node3D, right: Node3D) -> void:
	_arms.clear()
	if left != null and right != null:
		_arms.append(left)
		_arms.append(right)
	_apply_legs()


## Ángulo actual del brazo izquierdo, en grados (para las pruebas).
func left_arm_angle() -> float:
	return rad_to_deg(_arms[0].rotation.x) if not _arms.is_empty() else 0.0


## Indica si el personaje tiene piernas que balancear.
func has_legs() -> bool:
	return not _legs.is_empty()


## Ángulo actual de la pierna izquierda, en grados (para las pruebas).
func left_leg_angle() -> float:
	return rad_to_deg(_legs[0].rotation.x) if has_legs() else 0.0


## Se detiene donde está.
func stop() -> void:
	moving = false
	_stride_phase = 0.0
	_apply_legs()
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
	_stride_phase += step / STRIDE_LENGTH * PI
	_apply_legs()
	return false


func _apply_legs() -> void:
	var angle: float = deg_to_rad(LEG_SWING_DEGREES) * sin(_stride_phase)
	if not _legs.is_empty():
		_legs[0].rotation.x = angle
		_legs[1].rotation.x = -angle
	if not _arms.is_empty():
		_arms[0].rotation.x = -angle * ARM_SWING_RATIO
		_arms[1].rotation.x = angle * ARM_SWING_RATIO


## Distancia horizontal al punto indicado.
func flat_distance_to(point: Vector3) -> float:
	return Vector2(global_position.x, global_position.z).distance_to(Vector2(point.x, point.z))


## Saca al personaje de la escena visible y de la colisión. Se usa cuando la
## comitiva se marcha: no debe quedar plantada contra el muro.
func hide_actor() -> void:
	visible = false
	collision.collision_layer = 0
