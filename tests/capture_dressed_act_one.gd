extends SceneTree

const OUT: String = "user://capturas_acto1_vestido"
const WORLD: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var world: Node3D = (load(WORLD) as PackedScene).instantiate() as Node3D
	root.add_child(world)
	await process_frame
	var player: CharacterBody3D = world.get_node("PlayerFPS") as CharacterBody3D
	player.process_mode = Node.PROCESS_MODE_DISABLED
	(world.get_node("UILayer") as CanvasLayer).visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await _shot(player, "01_plaza", Vector3(0.0, 0.05, 22.0), Vector3(0.0, 1.4, -8.0))
	await _shot_actor(player, world, "Tejedora", "02_tejedora", 0.9, 1.8)
	await _shot_actor(player, world, "Curaca", "03_curaca", 1.0, 2.2)
	await _shot_actor(player, world, "Agricultor", "04_agricultor", 1.0, 2.2)
	await _shot_actor(player, world, "Mensajero", "05_mensajero", 1.0, 2.2)
	await _shot_actor(player, world, "Habitante2", "06_vecina", 1.0, 2.2)
	await _shot_actor(player, world, "Principal1", "07_principal", 1.0, 2.2)
	print("ACTO1_VESTIDO_OK")
	quit(0)


func _shot_actor(player: CharacterBody3D, world: Node3D, actor_name: String, file_name: String, target_height: float, distance: float) -> void:
	var actor: Node3D = world.get_node("Llacta/NPCs/%s" % actor_name) as Node3D
	var front: Vector3 = -actor.global_transform.basis.z.normalized()
	var target: Vector3 = actor.global_position + Vector3(0.0, target_height, 0.0)
	var from: Vector3 = target + front * distance + Vector3(0.0, -0.9, 0.0)
	await _shot(player, file_name, from, target)


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
