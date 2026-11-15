class_name TalkPoint
extends Interactable
## «Hablar» con un personaje: una frase o una conversación con opciones.
##
## Cuelga del personaje y lo sigue cuando camina. No conoce la UI: emite la
## frase o la conversación y la campaña decide qué hacer.

signal spoke(actor: Node3D, line_key: StringName)
## Se emite cuando el personaje tiene una conversación con opciones.
signal dialogue_requested(actor: Node3D, graph: DialogueGraph)

@export var line_key: StringName = &""
## Conversación con opciones; si existe, sustituye a la frase suelta.
@export var dialogue: DialogueGraph = null
@export var prompt_key: StringName = &"PCH_TALK"


func is_available() -> bool:
	return dialogue != null or not line_key.is_empty()


func get_interaction_text() -> String:
	return tr(prompt_key)


func interact(_interactor: Node3D) -> void:
	if not is_available():
		return
	var actor: Node3D = get_parent() as Node3D
	if dialogue != null:
		dialogue_requested.emit(actor, dialogue)
		return
	spoke.emit(actor, line_key)
