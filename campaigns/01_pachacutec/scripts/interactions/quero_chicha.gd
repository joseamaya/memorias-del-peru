class_name QueroChicha
extends Interactable
## Quero de chicha de jora.
##
## Restaura estamina sin conocer al jugador ni a la UI: recibe el interactor,
## busca su componente de estamina y solicita la recuperación.

@export var restore_amount: float = 35.0
@export var interaction_text_key: StringName = &"PCH_QUERO_INTERACT"
@export var mesh: MeshInstance3D
@export var audio_stream: AudioStream

var _mesh_node: MeshInstance3D = null
var _tween: Tween = null


func _ready() -> void:
	_mesh_node = mesh
	if _mesh_node == null:
		_mesh_node = get_node_or_null("MeshInstance3D") as MeshInstance3D


func get_interaction_text() -> String:
	return tr(interaction_text_key)


func interact(interactor: Node3D) -> void:
	var stamina: StaminaComponent = StaminaComponent.find_in(interactor)
	if stamina != null:
		stamina.restore(restore_amount)
	if audio_stream != null:
		AudioManager.play_sfx(audio_stream)
	_play_response()


func _play_response() -> void:
	if _mesh_node == null:
		return
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_mesh_node, "rotation_degrees", Vector3(0.0, 0.0, 14.0), 0.12)
	_tween.tween_property(_mesh_node, "rotation_degrees", Vector3.ZERO, 0.2)
