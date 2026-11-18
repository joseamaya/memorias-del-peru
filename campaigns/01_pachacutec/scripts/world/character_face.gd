class_name CharacterFace
extends RefCounted
## Mandíbula de habla para los personajes Quaternius.
##
## La cara UBC no trae blendshapes ni hueso de mandíbula: el generador añade
## `Jaw` y reparte el labio inferior, el mentón y la barba entre `Head` y `Jaw`.
## Este helper abre y cierra la boca mientras suena el clip `talk`. No es
## sincronía labial por fonemas: es una animación de habla (R).

const JAW_BONE: String = "Jaw"
## Frecuencia de la apertura, en ciclos por segundo.
const SPEECH_HZ: float = 4.5
## Apertura máxima, en radianes (unos 5°).
const SPEECH_AMPLITUDE: float = 0.09

var _skeleton: Skeleton3D = null
var _jaw: int = -1
var _phase: float = 0.0
var _open: float = 0.0


func _init(model: Node) -> void:
	if model == null:
		return
	_skeleton = model.find_child("Skeleton3D", true, false) as Skeleton3D
	if _skeleton != null:
		_jaw = _skeleton.find_bone(JAW_BONE)


## Índice del hueso de mandíbula, o -1 si el modelo no lo trae.
func jaw_index() -> int:
	return _jaw


## Apertura actual normalizada (0 cerrada, 1 abierta del todo).
func open_amount() -> float:
	return _open


## Avanza la mandíbula. Con [param talking] abre y cierra; sin hablar vuelve
## al reposo. Se llama desde el `_process` del actor o del visual.
func update(delta: float, talking: bool) -> void:
	if _skeleton == null or _jaw < 0:
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
