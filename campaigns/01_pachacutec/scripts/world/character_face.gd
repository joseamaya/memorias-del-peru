class_name CharacterFace
extends RefCounted
## Cara de habla y expresión de los personajes Quaternius.
##
## La cara UBC no trae blendshapes ni hueso de mandíbula: el generador añade
## `Jaw` para el habla, `Blink_L/R` para los párpados y `Brow_L/R` para las
## cejas. Este helper abre la boca mientras suena `talk`, parpadea cada pocos
## segundos y alza las cejas al hablar. No es sincronía labial por fonemas: es
## animación de habla y gesto (R).

const JAW_BONE: String = "Jaw"
const BLINK_BONES: Array[String] = ["Blink_L", "Blink_R"]
const BROW_BONES: Array[String] = ["Brow_L", "Brow_R"]
## Frecuencia de la apertura, en ciclos por segundo.
const SPEECH_HZ: float = 4.5
## Apertura máxima de la mandíbula, en radianes (unos 5°).
const SPEECH_AMPLITUDE: float = 0.09
## Recorrido del párpado y de la ceja, en metros.
const BLINK_TRAVEL: float = 0.013
const BROW_LIFT: float = 0.0035
## Perfil del parpadeo: cierre rápido, pausa mínima y apertura algo más lenta.
const BLINK_CLOSE_SECONDS: float = 0.085
const BLINK_HOLD_SECONDS: float = 0.035
const BLINK_OPEN_SECONDS: float = 0.11
const BLINK_INTERVAL_MIN: float = 2.8
const BLINK_INTERVAL_MAX: float = 6.2
const DOUBLE_BLINK_CHANCE: float = 0.12
const DOUBLE_BLINK_DELAY: float = 0.18
## Velocidad de la ceja al subir o bajar, en unidades por segundo.
const BROW_EASE: float = 7.0
const BROW_SPEECH: float = 0.8

var _skeleton: Skeleton3D = null
var _jaw: int = -1
var _blink: Array[int] = []
var _blink_rest: Array[Transform3D] = []
var _brow: Array[int] = []
var _brow_rest: Array[Transform3D] = []
var _phase: float = 0.0
var _open: float = 0.0
var _blink_amount: float = 0.0
var _blink_applied: float = -1.0
var _blink_clock: float = 0.0
var _blink_interval: float = BLINK_INTERVAL_MIN
var _blink_elapsed: float = 0.0
var _blinking: bool = false
var _blink_count: int = 0
var _brow_lift: float = 0.0
var _brow_applied: float = -1.0
var _manual: bool = false
var _manual_blink: float = 0.0
var _manual_brow: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(model: Node) -> void:
	_rng.randomize()
	if model == null:
		return
	_skeleton = model.find_child("Skeleton3D", true, false) as Skeleton3D
	if _skeleton == null:
		return
	_jaw = _skeleton.find_bone(JAW_BONE)
	for bone: String in BLINK_BONES:
		var index: int = _skeleton.find_bone(bone)
		if index >= 0:
			_blink.append(index)
			_blink_rest.append(_skeleton.get_bone_rest(index))
	for bone: String in BROW_BONES:
		var index: int = _skeleton.find_bone(bone)
		if index >= 0:
			_brow.append(index)
			_brow_rest.append(_skeleton.get_bone_rest(index))
	_blink_interval = _rng.randf_range(BLINK_INTERVAL_MIN, BLINK_INTERVAL_MAX)


## Índice del hueso de mandíbula, o -1 si el modelo no lo trae.
func jaw_index() -> int:
	return _jaw


## Apertura actual de la boca, normalizada (0 cerrada, 1 abierta del todo).
func open_amount() -> float:
	return _open


## Cierre actual de los párpados, normalizado (0 abiertos, 1 cerrados).
func blink_amount() -> float:
	return _blink_amount


## Alzado actual de las cejas, normalizado (0 reposo, 1 alzadas).
func brow_amount() -> float:
	return _brow_lift


## Parpadeos completados desde que nació la cara. Lo usan las pruebas.
func blink_count() -> int:
	return _blink_count


## Indica si el modelo trae los cuatro huesos de expresión.
func has_expression_bones() -> bool:
	return _blink.size() == BLINK_BONES.size() and _brow.size() == BROW_BONES.size()


## Fija una expresión estable para capturas y pruebas. Anula el parpadeo
## automático hasta que se llame a [method clear_expression].
func set_expression(blink: float, brow: float) -> void:
	_manual = true
	_manual_blink = clampf(blink, 0.0, 1.0)
	_manual_brow = clampf(brow, 0.0, 1.0)
	_apply_blink(_manual_blink)
	_apply_brow(_manual_brow)


## Devuelve la cara al parpadeo automático y al reposo.
func clear_expression() -> void:
	_manual = false
	_manual_blink = 0.0
	_manual_brow = 0.0
	_blinking = false
	_blink_elapsed = 0.0
	_blink_clock = 0.0
	_apply_blink(0.0)
	_apply_brow(0.0)
	_schedule_blink()


## Avanza mandíbula, párpados y cejas. Se llama desde el `_process` del actor
## o del visual; la multitud también parpadea, pero no habla.
func update(delta: float, talking: bool) -> void:
	if _skeleton == null:
		return
	if _manual:
		_apply_blink(_manual_blink)
		_apply_brow(_manual_brow)
		return
	_update_jaw(delta, talking)
	_update_blink(delta)
	_update_brow(delta, talking)


func _update_jaw(delta: float, talking: bool) -> void:
	if _jaw < 0:
		return
	if not talking:
		if _open > 0.0:
			_skeleton.set_bone_pose_rotation(_jaw, Quaternion.IDENTITY)
			_open = 0.0
		_phase = 0.0
		return
	_phase = fmod(_phase + delta * TAU * SPEECH_HZ, TAU)
	_open = 0.5 + 0.5 * sin(_phase)
	_skeleton.set_bone_pose_rotation(
		_jaw, Quaternion(Vector3.RIGHT, -SPEECH_AMPLITUDE * _open))


func _update_blink(delta: float) -> void:
	if _blink.is_empty():
		return
	if _blinking:
		_blink_elapsed += delta
		var close_end: float = BLINK_CLOSE_SECONDS
		var hold_end: float = close_end + BLINK_HOLD_SECONDS
		var open_end: float = hold_end + BLINK_OPEN_SECONDS
		if _blink_elapsed < close_end:
			_apply_blink(_blink_elapsed / close_end)
		elif _blink_elapsed < hold_end:
			_apply_blink(1.0)
		elif _blink_elapsed < open_end:
			_apply_blink(1.0 - (_blink_elapsed - hold_end) / BLINK_OPEN_SECONDS)
		else:
			_blinking = false
			_blink_elapsed = 0.0
			_apply_blink(0.0)
			_schedule_blink()
		return
	_blink_clock += delta
	if _blink_clock >= _blink_interval:
		_start_blink()


func _start_blink() -> void:
	_blinking = true
	_blink_elapsed = 0.0
	_blink_clock = 0.0
	_blink_count += 1


func _schedule_blink() -> void:
	if _rng.randf() < DOUBLE_BLINK_CHANCE:
		_blink_interval = DOUBLE_BLINK_DELAY
	else:
		_blink_interval = _rng.randf_range(BLINK_INTERVAL_MIN, BLINK_INTERVAL_MAX)


func _update_brow(delta: float, talking: bool) -> void:
	if _brow.is_empty():
		return
	var target: float = BROW_SPEECH if talking else 0.0
	_brow_lift = move_toward(_brow_lift, target, delta * BROW_EASE)
	_apply_brow(_brow_lift)


func _apply_blink(amount: float) -> void:
	var value: float = clampf(amount, 0.0, 1.0)
	_blink_amount = value
	if is_equal_approx(value, _blink_applied):
		return
	_blink_applied = value
	for index: int in range(_blink.size()):
		var rest: Transform3D = _blink_rest[index]
		_skeleton.set_bone_pose_position(
			_blink[index], rest.origin + rest.basis.y.normalized() * (BLINK_TRAVEL * value))


func _apply_brow(amount: float) -> void:
	var value: float = clampf(amount, 0.0, 1.0)
	_brow_lift = value
	if is_equal_approx(value, _brow_applied):
		return
	_brow_applied = value
	for index: int in range(_brow.size()):
		var rest: Transform3D = _brow_rest[index]
		_skeleton.set_bone_pose_position(
			_brow[index], rest.origin + rest.basis.y.normalized() * (BROW_LIFT * value))
