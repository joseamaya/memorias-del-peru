extends RefCounted
## Comprueba que la acción de interacción llama a interact().


func test_interaction_calls_interact() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://core/player/player_fps.tscn") as PackedScene
	var player: PlayerFPS = packed.instantiate() as PlayerFPS
	var object: CountingInteractable = CountingInteractable.new()
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(0.4, 0.4, 0.4)
	shape.shape = box
	body.collision_layer = 4
	body.collision_mask = 0
	body.position = Vector3(0.0, 1.6, -1.5)
	body.add_child(shape)
	object.add_child(body)
	tree.root.add_child(player)
	tree.root.add_child(object)
	player.interaction_ray.force_raycast_update()
	player.update_interaction()
	player.try_interact()
	var ok: bool = object.interactions == 1
	player.free()
	object.free()
	return ok
