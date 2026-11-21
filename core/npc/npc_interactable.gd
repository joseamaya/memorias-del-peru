class_name NpcInteractable
extends Interactable
## Punto de conversación de un NPC con nombre.
##
## Lo crea [NpcSimActor] cuando la definición trae `dialogue_id`. El colisionador
## va en la capa `interactable` (la que mira el rayo del jugador) y no bloquea el
## paso. No conoce la campaña: pide el diálogo al presentador por grupo.

const CAPSULE_RADIUS: float = 0.45
const CAPSULE_HEIGHT: float = 1.8
const INTERACT_LAYER: int = 4
const PRESENTER_GROUP: StringName = &"dialogue_presenter"

var definition: NpcDefinition = null


func setup(npc_definition: NpcDefinition) -> void:
	definition = npc_definition
	add_to_group(&"npc_interactable")
	hand_action = &"none"
	highlight_parent_if_empty = false
	_build_collider()


## Solo se puede hablar si hay un grafo registrado para este NPC.
func is_available() -> bool:
	if definition == null or definition.dialogue_id == &"":
		return false
	var presenter: Node = _presenter()
	if presenter == null or not presenter.has_method(&"has_graph"):
		return false
	return presenter.call(&"has_graph", definition.dialogue_id) == true


func interact(_interactor: Node3D) -> void:
	var presenter: Node = _presenter()
	if presenter == null or definition == null:
		return
	var target: Node3D = get_parent() as Node3D
	presenter.call(&"start", definition.dialogue_id, target)


## Nombre del NPC con la acción: «Hablar · Chanan Cury Coca».
func get_interaction_text() -> String:
	if definition == null or definition.name_key == &"":
		return tr("INTERACT_TALK")
	return tr("INTERACT_TALK_NAMED") % tr(String(definition.name_key))


func _presenter() -> Node:
	if not is_inside_tree():
		return null
	return get_tree().get_first_node_in_group(PRESENTER_GROUP)


func _build_collider() -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "Body"
	body.collision_layer = INTERACT_LAYER
	body.collision_mask = 0
	var shape: CollisionShape3D = CollisionShape3D.new()
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = CAPSULE_RADIUS
	capsule.height = CAPSULE_HEIGHT
	shape.shape = capsule
	body.add_child(shape)
	add_child(body)
