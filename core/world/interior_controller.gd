class_name InteriorController
extends Node3D
## Entra y sale de los interiores transitables sin cambiar de escena.
##
## La sala se instancia a la misma XZ de la puerta y 400 m por debajo del
## terreno: el streaming de sectores no cambia de celda y el mundo sigue vivo
## detrás. Al salir, el jugador vuelve exactamente donde estaba.

## Profundidad del bolsillo respecto de la puerta. La XZ se conserva.
const POCKET_DEPTH: float = 400.0
## Separación del jugador respecto del suelo de la sala al entrar.
const ENTRY_CLEARANCE: float = 0.2
## Distancia a la pared de entrada desde el centro de la sala.
const ENTRY_INSET: float = 1.4

var _player: PlayerFPS = null
var _room: InteriorRoom = null
var _return_position: Vector3 = Vector3.ZERO
var _return_yaw: float = 0.0


func _ready() -> void:
	add_to_group(&"interior_controller")


func set_player(player: PlayerFPS) -> void:
	_player = player


func is_inside() -> bool:
	return _room != null


func get_room() -> InteriorRoom:
	return _room


## Entra en la sala de la puerta indicada. Devuelve si se pudo.
func enter(door: InteriorDoor) -> bool:
	if _player == null or _room != null or door == null:
		return false
	_return_position = _player.global_position
	_return_yaw = _player.rotation.y
	var pocket: Vector3 = door.global_position + Vector3(0.0, -POCKET_DEPTH, 0.0)
	_room = InteriorRoom.new()
	_room.dressing = door.dressing
	_room.player_home = door.player_home
	_room.position = pocket
	add_child(_room)
	_player.global_position = (
		pocket + Vector3(0.0, ENTRY_CLEARANCE, InteriorRoom.DEPTH * 0.5 - ENTRY_INSET)
	)
	_player.rotation.y = 0.0
	return true


## Vuelve a la puerta de la que se entró. Devuelve si se pudo.
func exit() -> bool:
	if _player == null or _room == null:
		return false
	_room.queue_free()
	_room = null
	_player.global_position = _return_position
	_player.rotation.y = _return_yaw
	return true
