class_name Pututu
extends Interactable
## Pututu ceremonial que convoca a la comunidad.
##
## Solo puede usarse una vez por partida y avisa al evento mediante una señal.

signal played

@export var mesh: MeshInstance3D

var used: bool = false
var _mesh_node: MeshInstance3D = null


func _ready() -> void:
	_mesh_node = mesh
	if _mesh_node == null:
		_mesh_node = get_node_or_null("MeshInstance3D") as MeshInstance3D


func get_interaction_text() -> String:
	return tr("PCH_PUTUTU_PLAY")


func interact(_interactor: Node3D) -> void:
	if used:
		return
	used = true
	played.emit()
	if _mesh_node == null:
		return
	var tween: Tween = create_tween()
	tween.tween_property(_mesh_node, "rotation_degrees", Vector3(0.0, 0.0, 12.0), 0.15)
	tween.tween_property(_mesh_node, "rotation_degrees", Vector3.ZERO, 0.25)
