class_name CameraKick
extends Node
## Golpe de cámara breve y acumulable: sube el encuadre al recibir o dar un
## golpe y vuelve a su sitio. Vive fuera de [PlayerFPS] para no mezclar el
## control del ratón con el feedback de combate.

@export var camera: Camera3D
## Grados máximos del golpe y tiempo de recuperación.
@export var max_pitch_degrees: float = 2.5
@export var max_yaw_degrees: float = 1.8
@export var recovery_seconds: float = 0.16

var _pitch: float = 0.0
var _yaw: float = 0.0
var _elapsed: float = 0.0
var _duration: float = 0.0
var _base_rotation: Vector3 = Vector3.ZERO


func _ready() -> void:
	if camera != null:
		_base_rotation = camera.rotation


func _process(delta: float) -> void:
	advance(delta)


## Aplica un golpe; si ya había uno, se suma y se reinicia la recuperación.
func kick(pitch_degrees: float, yaw_degrees: float, seconds: float = -1.0) -> void:
	if camera == null:
		return
	_pitch = clampf(_pitch + pitch_degrees, -max_pitch_degrees, max_pitch_degrees)
	_yaw = clampf(_yaw + yaw_degrees, -max_yaw_degrees, max_yaw_degrees)
	_duration = recovery_seconds if seconds < 0.0 else maxf(seconds, 0.01)
	_elapsed = 0.0
	_apply()


## Avanza la recuperación. Público para las pruebas.
func advance(delta: float) -> void:
	if camera == null or _duration <= 0.0:
		return
	_elapsed += delta
	var weight: float = clampf(1.0 - _elapsed / _duration, 0.0, 1.0)
	if weight <= 0.0:
		_pitch = 0.0
		_yaw = 0.0
		_duration = 0.0
		_apply()
		return
	_apply(weight)


func current_pitch() -> float:
	return _pitch


func current_yaw() -> float:
	return _yaw


func _apply(weight: float = 1.0) -> void:
	camera.rotation = _base_rotation + Vector3(
		deg_to_rad(_pitch * weight), deg_to_rad(_yaw * weight), 0.0)
