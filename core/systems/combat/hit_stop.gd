class_name HitStop
extends Node
## Congelación breve del tiempo al impactar. No acumula: un golpe nuevo
## reinicia la cuenta y solo la última restaura `Engine.time_scale`.
##
## El temporizador corre en tiempo real (`ignore_time_scale`), así que la
## congelación no se alarga a sí misma.

@export var default_seconds: float = 0.06
@export var time_scale: float = 0.05

var _stop_id: int = 0


func _exit_tree() -> void:
	Engine.time_scale = 1.0


## Congela el juego durante [param seconds] (o el valor por defecto).
func trigger(seconds: float = -1.0) -> void:
	var duration: float = default_seconds if seconds < 0.0 else seconds
	if duration <= 0.0 or time_scale >= 1.0:
		return
	_stop_id += 1
	Engine.time_scale = clampf(time_scale, 0.01, 1.0)
	var timer: SceneTreeTimer = get_tree().create_timer(duration, true, false, true)
	timer.timeout.connect(_on_timeout.bind(_stop_id))


func is_stopped() -> bool:
	return Engine.time_scale < 1.0


func _on_timeout(id: int) -> void:
	if id == _stop_id:
		Engine.time_scale = 1.0
