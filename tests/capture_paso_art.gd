extends SceneTree

const OUT: String = "user://capturas_paso_art"
const SCENE: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var paso: Node3D = (load(SCENE) as PackedScene).instantiate() as Node3D
	root.add_child(paso)
	await process_frame
	var player: CharacterBody3D = paso.get_node("PlayerFPS") as CharacterBody3D
	player.process_mode = Node.PROCESS_MODE_DISABLED
	(paso.get_node("UILayer") as CanvasLayer).visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await _shot(player, "01_entrada", Vector3(0.0, 0.15, 28.0), Vector3(0.0, 1.2, -10.0))
	await _shot(player, "02_campamento", Vector3(-4.0, 0.15, 24.0), Vector3(-4.0, 1.0, 18.0))
	await _shot(player, "03_arroyo", Vector3(-8.0, 0.15, 10.0), Vector3(-14.0, 0.2, 4.0))
	await _shot(player, "04_refugio", Vector3(7.0, 0.15, 2.0), Vector3(14.0, 1.0, 0.0))
	await _shot(player, "05_emboscada", Vector3(0.0, 0.15, 12.0), Vector3(0.0, 1.0, -8.0))
	await _shot(player, "06_pared", Vector3(0.0, 0.15, 0.0), Vector3(18.0, 4.0, 0.0))
	await _shot(player, "07_enemigo", Vector3(3.0, 0.15, 2.0), Vector3(5.0, 1.0, -2.0))
	print("PASO_ART_OK")
	quit(0)


func _shot(player: CharacterBody3D, name: String, from: Vector3, target: Vector3) -> void:
	player.global_position = from
	var eye: Vector3 = from + Vector3(0.0, 1.6, 0.0)
	var to: Vector3 = target - eye
	player.rotation.y = atan2(-to.x, -to.z)
	var head: Node3D = player.get_node("Head") as Node3D
	head.rotation.x = atan2(to.y, Vector2(to.x, to.z).length())
	for _i: int in range(10):
		await process_frame
	root.get_texture().get_image().save_png(OUT + "/" + name + ".png")
