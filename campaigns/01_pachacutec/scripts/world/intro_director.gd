class_name IntroDirector
extends Node3D
## Tomas de cámara detrás de la introducción (ADR-0025).
##
## Tiene su propia Camera3D, que es la activa mientras duran las tarjetas. Cada
## tarjeta puede tener una toma: la cámara va de un encuadre a otro durante la
## tarjeta, con aceleración suave. La última toma termina en el encuadre de la
## cámara del jugador, así que al acabar la introducción se pasa al juego sin
## corte. La escena decide las tomas; el director solo las reproduce.

## Parte de la tarjeta en la que la toma llega a su encuadre final; el resto
## de la tarjeta la cámara queda quieta.
const SHOT_PORTION: float = 0.9

var _camera: Camera3D = null
var _player_camera: Camera3D = null
var _from: Dictionary[int, Transform3D] = {}
var _to: Dictionary[int, Transform3D] = {}
## Tomas que terminan en el encuadre de la cámara del jugador.
var _to_player: Dictionary[int, bool] = {}
var _shot_index: int = -1
var _shot_seconds: float = 0.0
var _shot_elapsed: float = 0.0


func _init() -> void:
	_camera = Camera3D.new()
	_camera.name = "IntroCamera"
	add_child(_camera)


## Cámara de la introducción.
func get_camera() -> Camera3D:
	return _camera


## Define la toma de la tarjeta [param index]: de [param from] a [param to].
func set_shot(index: int, from: Transform3D, to: Transform3D) -> void:
	_from[index] = from
	_to[index] = to
	_to_player.erase(index)


## Define una toma que termina en el encuadre de la cámara del jugador. Ese
## encuadre se lee al empezar la toma, cuando el jugador ya está en su sitio.
func set_shot_to_player(index: int, from: Transform3D) -> void:
	_from[index] = from
	_to[index] = from
	_to_player[index] = true


## Conecta el director con las tarjetas y con la cámara del jugador, y pone su
## cámara como activa.
func bind(cards: IntroCards, player_camera: Camera3D) -> void:
	_player_camera = player_camera
	if _player_camera != null:
		_camera.fov = _player_camera.fov
		_camera.near = _player_camera.near
		_camera.far = _player_camera.far
	cards.card_shown.connect(_on_card_shown)
	cards.finished.connect(_on_finished)
	_camera.make_current()


## Avanza la toma visible. Público para poder probarlo sin fotogramas.
func advance(delta: float) -> void:
	if _shot_index < 0:
		return
	_shot_elapsed += delta
	var t: float = 1.0
	if _shot_seconds > 0.0:
		t = clampf(_shot_elapsed / (_shot_seconds * SHOT_PORTION), 0.0, 1.0)
	var eased: float = smoothstep(0.0, 1.0, t)
	_camera.global_transform = _from[_shot_index].interpolate_with(_to[_shot_index], eased)


func _process(delta: float) -> void:
	advance(delta)


func _on_card_shown(index: int, seconds: float) -> void:
	if not _from.has(index):
		return
	_shot_index = index
	_shot_seconds = seconds
	_shot_elapsed = 0.0
	if _to_player.has(index) and _player_camera != null:
		_to[index] = _player_camera.global_transform
	_camera.global_transform = _from[index]


func _on_finished() -> void:
	# Si se saltó la última tarjeta, la toma no llegó a su final: se coloca la
	# cámara donde termina antes de devolver el control.
	if _shot_index >= 0:
		_camera.global_transform = _to[_shot_index]
	if _player_camera != null:
		_player_camera.make_current()
	_shot_index = -1
