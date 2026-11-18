extends Node3D
## Captura de prototipo de la mano de maniquí en primera persona.
##
##   godot --path . res://tests/scenes/mannequin_hand_prototype.tscn
##
## Carga el GLB extraído del UAL1, le pone los colores de piel/juntas y lo
## coloca delante de la cámara. Guarda `user://mannequin_hand_prototype.png`.

const HAND: String = "res://shared_assets/characters/mannequin/mannequin_hand_open.glb"


func _ready() -> void:
	_build_world()
	var packed: PackedScene = load(HAND) as PackedScene
	var hand: Node3D = packed.instantiate() as Node3D
	hand.name = "MannequinHand"
	# Ejes: local -X (dedos) -> -Z (adelante); local +X (antebrazo) -> +Z
	# (hacia la cámara); local +Z (dorso) -> +Y (arriba).
	var hand_basis: Basis = Basis(Vector3(0.0, 0.0, 1.0), Vector3(1.0, 0.0, 0.0),
		Vector3(0.0, 1.0, 0.0)).scaled(Vector3.ONE * 0.90)
	hand.transform = Transform3D(hand_basis, Vector3(0.16, -0.16, -0.42))
	add_child(hand)
	_tint(hand)
	_capture.call_deferred()


func _build_world() -> void:
	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.46, 0.56, 0.66)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.78, 0.82, 0.86)
	environment.ambient_light_energy = 1.0
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40.0, -30.0, 0.0)
	sun.light_energy = 1.2
	add_child(sun)
	var camera: Camera3D = Camera3D.new()
	camera.fov = 70.0
	camera.current = true
	add_child(camera)


func _tint(hand: Node3D) -> void:
	var skin: StandardMaterial3D = StandardMaterial3D.new()
	skin.albedo_color = Color(0.55, 0.36, 0.24)
	skin.roughness = 0.9
	var joints: StandardMaterial3D = StandardMaterial3D.new()
	joints.albedo_color = Color(0.16, 0.10, 0.08)
	joints.roughness = 0.9
	var meshes: Array[Node] = hand.find_children("*", "MeshInstance3D", true, false)
	for node: Node in meshes:
		var mesh: MeshInstance3D = node as MeshInstance3D
		if mesh.mesh == null:
			continue
		mesh.set_surface_override_material(0, skin)
		if mesh.mesh.get_surface_count() > 1:
			mesh.set_surface_override_material(1, joints)


func _capture() -> void:
	for _i: int in range(8):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("user://mannequin_hand_prototype.png")
	print("MANO_PROTOTIPO_OK")
	get_tree().quit()
