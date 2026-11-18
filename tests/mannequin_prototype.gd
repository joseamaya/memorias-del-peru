extends Node3D
## Captura de contacto de los diez looks del elenco sobre maniquíes UAL1.
##
##   godot --path . res://tests/scenes/mannequin_prototype.tscn
##
## Guarda dos imágenes: los cinco papeles principales y los cinco de familia y
## apoyo. No es una prueba: es la referencia visual para aprobar los looks antes
## de integrarlos en NPC y multitud.

const PRINCIPALES: Array[String] = ["Curaca", "Sisa", "Chanca", "Puma", "Anca"]
const APOYO: Array[String] = ["Madre", "Hermano", "Joven", "Anciana", "Mensajero"]
const SPACING: float = 1.15
const CAMERA_POSITION: Vector3 = Vector3(0.0, 1.35, 4.6)
const LOOK_AT: Vector3 = Vector3(0.0, 0.95, 0.0)

var _camera: Camera3D = null
var _group: Array[Node] = []


func _ready() -> void:
	_build_environment()
	_build_ground()
	_camera = Camera3D.new()
	_camera.fov = 42.0
	_camera.position = CAMERA_POSITION
	add_child(_camera)
	_camera.look_at(LOOK_AT, Vector3.UP)
	_camera.current = true
	_capture.call_deferred()


func _capture() -> void:
	for _i: int in range(6):
		await get_tree().process_frame
	await _capture_group(PRINCIPALES, "maniquies_principales.png")
	await _capture_group(APOYO, "maniquies_apoyo.png")
	get_tree().quit()


func _capture_group(roles: Array[String], output: String) -> void:
	await _clear_group()
	for index: int in range(roles.size()):
		var x: float = (float(index) - float(roles.size() - 1) * 0.5) * SPACING
		_place(roles[index], Vector3(x, 0.0, 0.0))
	for _i: int in range(8):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("user://" + output)
	print("PROTOTIPO_OK ", output)


func _clear_group() -> void:
	for node: Node in _group:
		node.queue_free()
	_group.clear()
	await get_tree().process_frame


func _place(role: String, at: Vector3) -> void:
	var mannequin: OutfitMannequin = OutfitMannequin.new()
	mannequin.name = role
	mannequin.look = MannequinLooks.for_role(role)
	mannequin.target_height = _height_for(role)
	mannequin.position = at
	mannequin.rotation.y = atan2(CAMERA_POSITION.x - at.x, CAMERA_POSITION.z - at.z)
	mannequin.clip = &"Idle"
	add_child(mannequin)
	_group.append(mannequin)
	var label: Label3D = _add_label(role,
		at + Vector3(0.0, mannequin.target_height + 0.20, 0.0))
	_group.append(label)


func _height_for(role: String) -> float:
	var index: int = MannequinLooks.ROLE_NAMES.find(role)
	if index < 0:
		return 1.55
	return MannequinLooks.ROLE_HEIGHTS[index]


func _build_environment() -> void:
	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.48, 0.58, 0.68)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.75, 0.78, 0.82)
	environment.ambient_light_energy = 0.9
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -32.0, 0.0)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)


func _build_ground() -> void:
	var ground: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(12.0, 12.0)
	ground.mesh = plane
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.56, 0.46, 0.33)
	material.roughness = 1.0
	ground.material_override = material
	add_child(ground)


func _add_label(text: String, at: Vector3) -> Label3D:
	var label: Label3D = Label3D.new()
	label.text = text
	label.font_size = 44
	label.outline_size = 8
	label.modulate = Color(0.98, 0.92, 0.78)
	label.outline_modulate = Color(0.06, 0.05, 0.04)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = at
	label.pixel_size = 0.0025
	add_child(label)
	return label
