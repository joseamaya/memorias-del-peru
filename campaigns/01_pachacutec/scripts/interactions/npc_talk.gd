class_name NpcTalk
extends Interactable
## «Hablar» con un personaje antes de la noticia (ADR-0012).
##
## Va en la raíz de `npc_talk.tscn`, un cuerpo en la capa `interactable` que
## cuelga del personaje y lo sigue cuando camina. Cada personaje dice una sola
## frase, sin opciones (no hay diálogo ramificado). Solo responde mientras el
## evento no ha empezado: después, la noticia tiene la palabra.

signal spoke(actor: Node3D, line_key: StringName)

@export var line_key: StringName = &""
@export var prompt_key: StringName = &"PCH_TALK"

var event: MessengerEvent = null


func is_available() -> bool:
	if line_key.is_empty():
		return false
	return event == null or event.phase == MessengerEvent.Phase.IDLE


func get_interaction_text() -> String:
	return tr(prompt_key)


func interact(_interactor: Node3D) -> void:
	if not is_available():
		return
	spoke.emit(get_parent() as Node3D, line_key)
