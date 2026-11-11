class_name Pututu
extends Interactable
## Pututu ceremonial que convoca a la comunidad.
##
## Solo responde cuando el evento lo arma, y solo puede usarse una vez por
## partida. `force_play()` permite al curaca tocarlo aunque ya esté gastado:
## el evento nunca puede quedarse esperando un pututu que no responde.

signal played

@export var mesh: MeshInstance3D
@export var audio_stream: AudioStream

var used: bool = false
var armed: bool = false

var _mesh_node: MeshInstance3D = null


func _ready() -> void:
	_mesh_node = mesh
	if _mesh_node == null:
		_mesh_node = get_node_or_null("MeshInstance3D") as MeshInstance3D


func get_interaction_text() -> String:
	return tr("PCH_PUTUTU_PLAY")


## Solo se puede enfocar y usar mientras el evento lo permita.
func is_available() -> bool:
	return armed and not used


## El evento arma el pututu al entrar en la fase de llamada.
func set_armed(value: bool) -> void:
	armed = value


func interact(_interactor: Node3D) -> void:
	if not is_available():
		return
	_play()


## Toca el pututu aunque ya esté gastado. Lo usa el curaca como respaldo del
## evento, para que la llamada nunca dependa de un objeto agotado.
func force_play() -> void:
	_play()


func _play() -> void:
	used = true
	armed = false
	if audio_stream != null:
		AudioManager.play_sfx(audio_stream)
	played.emit()
	if _mesh_node == null:
		return
	var tween: Tween = create_tween()
	tween.tween_property(_mesh_node, "rotation_degrees", Vector3(0.0, 0.0, 12.0), 0.15)
	tween.tween_property(_mesh_node, "rotation_degrees", Vector3.ZERO, 0.25)
