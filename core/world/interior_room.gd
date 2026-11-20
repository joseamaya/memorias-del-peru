class_name InteriorRoom
extends Node3D
## Sala de bolsillo de los interiores transitables.
##
## Se instancia fuera del terreno, a la misma XZ que la puerta, para que el
## streaming de sectores no cambie de celda. La sala es cerrada y tiene luz
## propia: no depende del sol ni del ciclo día/noche.

const WIDTH: float = 8.0
const DEPTH: float = 6.0
const HEIGHT: float = 3.0
const WALL: float = 0.3
const DOOR_WIDTH: float = 1.4

const STONE: Color = Color(0.62, 0.58, 0.50)
const PLASTER: Color = Color(0.78, 0.72, 0.60)
const WOOD: Color = Color(0.36, 0.28, 0.20)
const FABRIC: Color = Color(0.55, 0.35, 0.28)
const SOIL: Color = Color(0.40, 0.32, 0.22)

## Vestido de la sala: `home`, `authority` o `workshop`.
@export var dressing: StringName = &"home"

var _materials: Dictionary[String, StandardMaterial3D] = {}


func _ready() -> void:
	_build_shell()
	_build_exit()
	_build_dressing()
	_build_light()


func get_mesh_count() -> int:
	return find_children("*", "MeshInstance3D", true, false).size()


func _build_shell() -> void:
	_box(Vector3(WIDTH, 0.2, DEPTH), Vector3(0.0, -0.1, 0.0), SOIL, true)
	_box(Vector3(WIDTH, HEIGHT, WALL), Vector3(0.0, HEIGHT * 0.5, -DEPTH * 0.5), STONE, true)
	_box(Vector3(WALL, HEIGHT, DEPTH), Vector3(-WIDTH * 0.5, HEIGHT * 0.5, 0.0), STONE, true)
	_box(Vector3(WALL, HEIGHT, DEPTH), Vector3(WIDTH * 0.5, HEIGHT * 0.5, 0.0), STONE, true)
	var side: float = (WIDTH - DOOR_WIDTH) * 0.5
	var offset: float = DOOR_WIDTH * 0.5 + side * 0.5
	_box(Vector3(side, HEIGHT, WALL), Vector3(-offset, HEIGHT * 0.5, DEPTH * 0.5), PLASTER, true)
	_box(Vector3(side, HEIGHT, WALL), Vector3(offset, HEIGHT * 0.5, DEPTH * 0.5), PLASTER, true)
	_box(
		Vector3(DOOR_WIDTH, HEIGHT - 2.1, WALL),
		Vector3(0.0, 2.1 + (HEIGHT - 2.1) * 0.5, DEPTH * 0.5),
		PLASTER,
		true
	)
	_box(Vector3(WIDTH + 0.4, 0.25, DEPTH + 0.4), Vector3(0.0, HEIGHT + 0.12, 0.0), WOOD, false)


func _build_exit() -> void:
	var door: InteriorDoor = InteriorDoor.new()
	door.is_exit = true
	door.position = Vector3(0.0, 0.0, DEPTH * 0.5 - 0.18)
	add_child(door)


func _build_light() -> void:
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0.0, HEIGHT - 0.5, 0.0)
	light.light_energy = 1.8
	light.omni_range = 9.0
	light.shadow_enabled = false
	add_child(light)


func _build_dressing() -> void:
	match dressing:
		&"authority":
			_bed(-2.6, 1.4, 2.2, 0.6)
			_loom(1.8, -1.4)
			_stack(-2.4, -2.0)
			_bench(0.0, 2.2)
		&"workshop":
			_loom(-2.2, -1.6)
			_loom(1.6, -1.6)
			_stack(2.6, 1.8)
			_bench(0.0, 2.2)
		_:
			_bed(-2.6, 1.4, 2.2, 0.6)
			_hearth(1.9, 1.6)
			_stack(-2.6, -1.9)
			_bench(0.2, 2.2)


func _bed(x: float, z: float, width: float, height: float) -> void:
	_box(Vector3(width, height, 2.0), Vector3(x, height * 0.5, z), WOOD, false)
	_box(Vector3(width - 0.2, 0.18, 1.8), Vector3(x, height + 0.09, z), FABRIC, false)


func _loom(x: float, z: float) -> void:
	_box(Vector3(0.16, 2.0, 0.16), Vector3(x - 0.7, 1.0, z), WOOD, false)
	_box(Vector3(0.16, 2.0, 0.16), Vector3(x + 0.7, 1.0, z), WOOD, false)
	_box(Vector3(1.6, 0.14, 0.14), Vector3(x, 1.9, z), WOOD, false)
	_box(Vector3(1.3, 0.9, 0.05), Vector3(x, 1.2, z), FABRIC, false)


func _stack(x: float, z: float) -> void:
	for index: int in 3:
		var offset: float = float(index) * 0.16
		_box(Vector3(0.7, 0.16, 0.7), Vector3(x, 0.08 + offset, z), FABRIC, false)


func _bench(x: float, z: float) -> void:
	_box(Vector3(1.8, 0.12, 0.5), Vector3(x, 0.45, z), WOOD, false)
	_box(Vector3(0.14, 0.45, 0.4), Vector3(x - 0.75, 0.22, z), WOOD, false)
	_box(Vector3(0.14, 0.45, 0.4), Vector3(x + 0.75, 0.22, z), WOOD, false)


func _hearth(x: float, z: float) -> void:
	_box(Vector3(1.1, 0.3, 1.1), Vector3(x, 0.15, z), STONE, true)
	var fire: OmniLight3D = OmniLight3D.new()
	fire.position = Vector3(x, 0.6, z)
	fire.light_color = Color(1.0, 0.62, 0.32)
	fire.light_energy = 1.4
	fire.omni_range = 4.0
	fire.shadow_enabled = false
	add_child(fire)


func _box(size: Vector3, box_position: Vector3, color: Color, collision: bool) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.material_override = _material(color)
	instance.position = box_position
	add_child(instance)
	if collision:
		var body: StaticBody3D = StaticBody3D.new()
		var shape: CollisionShape3D = CollisionShape3D.new()
		var box: BoxShape3D = BoxShape3D.new()
		box.size = size
		shape.shape = box
		body.add_child(shape)
		body.position = box_position
		add_child(body)
	return instance


func _material(color: Color) -> StandardMaterial3D:
	var key: String = color.to_html()
	if _materials.has(key):
		return _materials[key]
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.95
	_materials[key] = material
	return material
