class_name GameManagerService
extends Node
## Estado global mínimo del juego.
##
## Gestiona la pausa y expone el estado mediante [signal pause_changed].
## No conoce escenas de campaña concretas.

signal pause_changed(paused: bool)

var _paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		set_paused(not _paused)
		get_viewport().set_input_as_handled()


## Cambia el estado de pausa. No emite la señal si el valor no cambia.
func set_paused(paused: bool) -> void:
	if paused == _paused:
		return
	_paused = paused
	get_tree().paused = paused
	pause_changed.emit(paused)


## Devuelve el estado de pausa actual.
func is_paused() -> bool:
	return _paused
