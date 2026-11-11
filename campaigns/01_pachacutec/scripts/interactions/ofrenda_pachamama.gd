class_name OfrendaPachamama
extends Interactable
## Adoratorio de ofrenda a la Pachamama.
##
## Solo puede usarse una vez por partida. No conoce la UI.

signal offered

@export var mesh: MeshInstance3D
@export var audio_stream: AudioStream

var used: bool = false
var _mesh_node: MeshInstance3D = null


func _ready() -> void:
	_mesh_node = mesh
	if _mesh_node == null:
		_mesh_node = get_node_or_null("MeshInstance3D") as MeshInstance3D


func get_interaction_text() -> String:
	return tr("PCH_OFFERING_INTERACT")


## Una vez dejada la ofrenda deja de enfocarse: el HUD no ofrece una acción
## que ya no responde (ADR-0008).
func is_available() -> bool:
	return not used


func interact(_interactor: Node3D) -> void:
	if used:
		return
	used = true
	if audio_stream != null:
		AudioManager.play_sfx(audio_stream)
	offered.emit()
	if _mesh_node == null:
		return
	var tween: Tween = create_tween()
	tween.tween_property(_mesh_node, "scale", Vector3(1.15, 0.85, 1.15), 0.15)
	tween.tween_property(_mesh_node, "scale", Vector3.ONE, 0.2)
