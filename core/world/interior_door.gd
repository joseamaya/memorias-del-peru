class_name InteriorDoor
extends Interactable
## Puerta de un interior transitable. Fuera lleva a la sala de bolsillo; dentro
## devuelve al jugador a la puerta del mundo.
##
## La campaña coloca estas puertas en las fachadas y les asigna su vestido.
## El controlador se busca por grupo: la puerta no conoce el mundo regional.

const WIDTH: float = 1.4
const HEIGHT: float = 2.1
const FRAME: float = 0.16

const FRAME_COLOR: Color = Color(0.36, 0.28, 0.20)
const PANEL_COLOR: Color = Color(0.20, 0.16, 0.12)

## Vestido de la sala a la que lleva: `home`, `authority` o `workshop`.
@export var dressing: StringName = &"home"
## Puerta interior que devuelve al mundo.
@export var is_exit: bool = false


func _ready() -> void:
	_build()


func interact(_interactor: Node3D) -> void:
	var controller: InteriorController = (
		get_tree().get_first_node_in_group(&"interior_controller") as InteriorController
	)
	if controller == null:
		return
	if is_exit:
		controller.exit()
	else:
		controller.enter(self)


func get_interaction_text() -> String:
	return tr("PCH_EXIT") if is_exit else tr("PCH_ENTER")


func _build() -> void:
	_add_mesh(Vector3(FRAME, HEIGHT, FRAME), Vector3(-WIDTH * 0.5, HEIGHT * 0.5, 0.0), FRAME_COLOR)
	_add_mesh(Vector3(FRAME, HEIGHT, FRAME), Vector3(WIDTH * 0.5, HEIGHT * 0.5, 0.0), FRAME_COLOR)
	_add_mesh(Vector3(WIDTH + FRAME, FRAME, FRAME), Vector3(0.0, HEIGHT, 0.0), FRAME_COLOR)
	_add_mesh(
		Vector3(WIDTH, HEIGHT - 0.1, 0.08), Vector3(0.0, (HEIGHT - 0.1) * 0.5, 0.0), PANEL_COLOR
	)
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(WIDTH, HEIGHT, 0.2)
	shape.shape = box
	body.add_child(shape)
	body.position = Vector3(0.0, HEIGHT * 0.5, 0.0)
	add_child(body)
	var label: Label3D = Label3D.new()
	label.text = get_interaction_text()
	label.font_size = 32
	label.pixel_size = 0.004
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.position = Vector3(0.0, HEIGHT + 0.45, 0.0)
	add_child(label)


func _add_mesh(size: Vector3, mesh_position: Vector3, color: Color) -> void:
	var instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.95
	instance.material_override = material
	instance.position = mesh_position
	add_child(instance)
