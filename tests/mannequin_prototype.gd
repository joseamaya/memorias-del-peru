extends Node3D
## Captura de prototipo del nuevo estilo de personajes.
##
##   godot --path . res://tests/scenes/mannequin_prototype.tscn
##
## Coloca a Curaca, Sisa y Chanca como maniquíes UAL1 con atuendo de primitivas
## y guarda `user://mannequin_prototype.png`. No es una prueba: es la referencia
## visual para aprobar el estilo antes de extenderlo al elenco.

const LOOKS: Array[String] = ["Curaca", "Sisa", "Chanca"]


func _ready() -> void:
	_build_environment()
	_build_ground()
	var looks: Array[CharacterLook] = [
		MannequinLooks.curaca(), MannequinLooks.sisa(), MannequinLooks.chanca(),
	]
	var heights: Array[float] = [1.65, 1.55, 1.60]
	for index: int in range(3):
		var mannequin: OutfitMannequin = OutfitMannequin.new()
		mannequin.name = LOOKS[index]
		mannequin.look = looks[index]
		mannequin.target_height = heights[index]
		mannequin.position = Vector3(-1.15 + 1.15 * float(index), 0.0, 0.0)
		mannequin.clip = &"Idle"
		add_child(mannequin)
		_add_label(LOOKS[index], mannequin.position + Vector3(0.0, heights[index] + 0.18, 0.0))
	_capture.call_deferred()


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
	plane.size = Vector2(8.0, 8.0)
	ground.mesh = plane
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.56, 0.46, 0.33)
	material.roughness = 1.0
	ground.material_override = material
	add_child(ground)


func _add_label(text: String, at: Vector3) -> void:
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


func _capture() -> void:
	var camera: Camera3D = Camera3D.new()
	camera.fov = 42.0
	camera.position = Vector3(0.0, 1.35, 4.2)
	add_child(camera)
	camera.look_at(Vector3(0.0, 0.95, 0.0), Vector3.UP)
	camera.current = true
	for _i: int in range(12):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("user://mannequin_prototype.png")
	print("PROTOTIPO_OK")
	get_tree().quit()
