class_name ChasquiEvent
extends Node
## Evento de llegada del chasqui a la plaza.
##
## El pututu lo inicia: el chasqui corre hasta la plaza, los NPC lo miran y
## después regresa por el camino norte.

signal started
signal finished

@export var chasqui: Node3D
@export var weaver: Node3D
@export var farmer: Node3D
@export var plaza_point: Marker3D

var active: bool = false
var completed: bool = false

var _chasqui_start: Vector3 = Vector3.ZERO
var _tween: Tween = null


func _ready() -> void:
	if chasqui != null:
		_chasqui_start = chasqui.global_position


## Asigna los nodos del mundo y guarda la posición inicial del chasqui.
func bind(chasqui_node: Node3D, weaver_node: Node3D, farmer_node: Node3D, plaza: Marker3D) -> void:
	chasqui = chasqui_node
	weaver = weaver_node
	farmer = farmer_node
	plaza_point = plaza
	if chasqui != null:
		_chasqui_start = chasqui.global_position


## Inicia el evento. Es idempotente mientras está activo.
func start() -> void:
	if active or chasqui == null or plaza_point == null:
		return
	active = true
	completed = false
	started.emit()
	if weaver != null:
		weaver.look_at(Vector3(plaza_point.global_position.x, weaver.global_position.y, plaza_point.global_position.z), Vector3.UP)
	if farmer != null:
		farmer.look_at(Vector3(plaza_point.global_position.x, farmer.global_position.y, plaza_point.global_position.z), Vector3.UP)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(chasqui, "global_position", plaza_point.global_position, 2.0)
	_tween.tween_interval(2.0)
	_tween.tween_property(chasqui, "global_position", _chasqui_start, 2.0)
	_tween.tween_callback(_finish)


func _finish() -> void:
	active = false
	completed = true
	finished.emit()
