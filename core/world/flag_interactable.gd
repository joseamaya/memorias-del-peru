class_name FlagInteractable
extends Interactable
## Punto del mundo que fija una bandera al usarlo.
##
## Lo coloca la campaña (agua, lana, maíz). No conoce la misión: solo escribe en
## [WorldState]. Puede exigir otra bandera para estar disponible, y desaparece
## como interactuable cuando ya se usó.

signal activated(flag: StringName)

const DEFAULT_SIZE: Vector3 = Vector3(1.0, 0.9, 1.0)
const INTERACT_LAYER: int = 4

## Bandera que fija y valor que le pone.
@export var flag: StringName = &""
@export var flag_value: int = 1
## Clave del texto que se muestra al enfocar.
@export var text_key: StringName = &"INTERACT_DEFAULT"
## Bandera que debe estar puesta para poder usarlo; vacía = siempre.
@export var requires_flag: StringName = &""
## Volumen del colisionador, para ajustarlo al prop.
@export var interact_size: Vector3 = DEFAULT_SIZE


func _ready() -> void:
	add_to_group(&"flag_interactable")
	highlight_parent_if_empty = false
	_build_collider()


## Está disponible si la campaña ya lo pidió y todavía no se ha usado.
func is_available() -> bool:
	var world_state: WorldStateService = WorldStateService.instance()
	if world_state == null or flag == &"":
		return false
	if requires_flag != &"" and not world_state.has_flag(requires_flag):
		return false
	return not world_state.has_flag(flag)


func interact(_interactor: Node3D) -> void:
	var world_state: WorldStateService = WorldStateService.instance()
	if world_state == null or flag == &"":
		return
	world_state.set_flag(flag, flag_value)
	activated.emit(flag)


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
