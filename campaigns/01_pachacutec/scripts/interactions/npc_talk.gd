class_name NpcTalk
extends Interactable
## «Hablar» con un personaje antes de la noticia (ADR-0012).
##
## Va en la raíz de `npc_talk.tscn`, un cuerpo en la capa `interactable` que
## cuelga del personaje y lo sigue cuando camina. Cada personaje dice una sola
## frase, sin opciones (no hay diálogo ramificado). Solo responde mientras el
## evento no ha empezado: después, la noticia tiene la palabra.

signal spoke(actor: Node3D, line_key: StringName)
## Se emite cuando el personaje tiene una conversación con opciones.
signal dialogue_requested(actor: Node3D, graph: DialogueGraph)

@export var line_key: StringName = &""
## Conversación con opciones; si existe, sustituye a la frase suelta.
@export var dialogue: DialogueGraph = null
@export var prompt_key: StringName = &"PCH_TALK"

var event: MessengerEvent = null


func is_available() -> bool:
	if dialogue == null and line_key.is_empty():
		return false
	return event == null or event.phase == MessengerEvent.Phase.IDLE


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
