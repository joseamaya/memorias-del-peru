extends SceneTree

const OUT: String = "user://capturas_ciudad_vestida"
const SCENE: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var ciudad: Node3D = (load(SCENE) as PackedScene).instantiate() as Node3D
	root.add_child(ciudad)
	await process_frame
	var player: CharacterBody3D = ciudad.get_node("PlayerFPS") as CharacterBody3D
	player.process_mode = Node.PROCESS_MODE_DISABLED
	(ciudad.get_node("UILayer") as CanvasLayer).visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await _shot(player, "01_plaza", Vector3(0.0, 0.15, 20.0), Vector3(0.0, 1.2, -14.0))
	await _shot(player, "02_cusi", Vector3(0.0, 0.15, -7.0), Vector3(0.0, 1.0, -12.0))
	await _shot(player, "03_recluta", Vector3(0.0, 0.15, 16.0), Vector3(0.0, 1.0, 12.0))
	ciudad.call("_start_defense")
	await create_timer(2.5).timeout
	await _shot(player, "04_defensa", Vector3(0.0, 0.15, 6.0), Vector3(0.0, 1.0, -4.0))
	await _shot(player, "05_muralla", Vector3(0.0, 0.15, 40.0), Vector3(0.0, 1.2, 30.0))
	await _shot(player, "06_mercado", Vector3(-4.0, 0.15, 9.0), Vector3(-8.5, 1.1, 4.0))
	print("CIUDAD_VESTIDA_OK")
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
