class_name CampPoint
extends Interactable
## Punto de conversación del campamento del acto II.
##
## No completa nada: avisa a la escena para que abra el diálogo del curaca.
## El jugador ve la acción en la indicación y pulsa E.

signal requested

@export var prompt_key: StringName = &"PCH_CAMP_TALK"


func is_available() -> bool:
	return true


func get_interaction_text() -> String:
	return tr(String(prompt_key))


func interact(_interactor: Node3D) -> void:
	requested.emit()
