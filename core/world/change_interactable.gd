class_name ChangeInteractable
extends Interactable
## Punto del mundo que registra un cambio físico persistente al usarlo.
##
## Es el hermano de [FlagInteractable] para las obras: puertas, puentes,
## corrales y defensas viven en `WorldState.changes`, no en las banderas. Puede
## exigir una bandera para estar disponible y deja de responder una vez hecho.

signal built(change_id: StringName)

const DEFAULT_SIZE: Vector3 = Vector3(2.4, 0.6, 2.4)
const INTERACT_LAYER: int = 4

## Cambio que registra y valor que le pone.
@export var change_id: StringName = &""
@export var change_value: int = 1
## Clave del texto que se muestra al enfocar.
@export var text_key: StringName = &"INTERACT_DEFAULT"
## Bandera que debe estar puesta para poder construir; vacía = siempre.
@export var requires_flag: StringName = &""
## Volumen del colisionador, para ajustarlo a la obra.
@export var interact_size: Vector3 = DEFAULT_SIZE


func _ready() -> void:
	add_to_group(&"change_interactable")
	highlight_parent_if_empty = false
	_build_collider()


## Está disponible si se cumplen los requisitos y la obra no existe todavía.
func is_available() -> bool:
	var world_state: WorldStateService = WorldStateService.instance()
	if world_state == null or change_id == &"":
		return false
	if requires_flag != &"" and not world_state.has_flag(requires_flag):
		return false
	return not world_state.has_change(change_id)


func interact(_interactor: Node3D) -> void:
	var world_state: WorldStateService = WorldStateService.instance()
	if world_state == null or change_id == &"":
		return
	world_state.set_change(change_id, change_value)
	built.emit(change_id)


func get_interaction_text() -> String:
	return tr(String(text_key))


func _build_collider() -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "Body"
	body.collision_layer = INTERACT_LAYER
	body.collision_mask = 0
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = interact_size
	shape.shape = box
	body.add_child(shape)
	body.position = Vector3(0.0, interact_size.y * 0.5, 0.0)
	add_child(body)
