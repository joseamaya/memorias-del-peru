extends SceneTree

const OUT: String = "user://capturas_dressed"
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
	var weaver: Node3D = world.get_node("Llacta/NPCs/Tejedora") as Node3D
	var npcs: Node = world.get_node("Llacta/NPCs")
	for child: Node in npcs.get_children():
		if child != weaver and child is Node3D:
			(child as Node3D).visible = false
	var front: Vector3 = -weaver.global_transform.basis.z.normalized()
	var side: Vector3 = weaver.global_transform.basis.x.normalized()
	var target: Vector3 = weaver.global_position + Vector3(0.0, 0.85, 0.0)
	await _shot(player, "01_frontal", target + front * 1.7 + Vector3(0.0, -0.95, 0.0), target)
	await _shot(player, "02_tres_cuartos", target + front * 1.5 + side * 1.0 + Vector3(0.0, -0.95, 0.0), target)
	await _shot(player, "03_lateral", target + side * 1.9 + Vector3(0.0, -0.95, 0.0), target)
	await _shot(player, "04_espalda", target - front * 1.7 + Vector3(0.0, -0.95, 0.0), target)
	var face: Vector3 = weaver.global_position + Vector3(0.0, 1.0, 0.0)
	await _shot(player, "05_rostro", face + front * 1.0 + Vector3(0.0, -1.6, 0.0), face)
	print("DRESSED_OK")
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
