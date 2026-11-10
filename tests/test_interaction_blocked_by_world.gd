extends RefCounted
## Comprueba que una pared de la capa world bloquea la interacción.


var _focused: int = 0


func _on_focused(_interactable: Interactable) -> void:
	_focused += 1


func test_interaction_blocked_by_world() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://core/player/player_fps.tscn") as PackedScene
	var player: PlayerFPS = packed.instantiate() as PlayerFPS
	var object: CountingInteractable = CountingInteractable.new()
	var object_body: StaticBody3D = StaticBody3D.new()
	var object_shape: CollisionShape3D = CollisionShape3D.new()
	var object_box: BoxShape3D = BoxShape3D.new()
	object_box.size = Vector3(0.4, 0.4, 0.4)
	object_shape.shape = object_box
	object_body.collision_layer = 4
	object_body.collision_mask = 0
	object_body.position = Vector3(0.0, 1.6, -1.6)
	object_body.add_child(object_shape)
	object.add_child(object_body)
	var wall: StaticBody3D = StaticBody3D.new()
	var wall_shape: CollisionShape3D = CollisionShape3D.new()
	var wall_box: BoxShape3D = BoxShape3D.new()
	wall_box.size = Vector3(0.8, 0.8, 0.2)
	wall_shape.shape = wall_box
	wall.collision_layer = 1
	wall.collision_mask = 0
	wall.position = Vector3(0.0, 1.6, -0.8)
	wall.add_child(wall_shape)
	tree.root.add_child(player)
	tree.root.add_child(object)
	tree.root.add_child(wall)
	player.interactable_focused.connect(_on_focused)
	player.interaction_ray.force_raycast_update()
	player.update_interaction()
	var ok: bool = _focused == 0
	player.interactable_focused.disconnect(_on_focused)
	player.free()
	object.free()
	wall.free()
	return ok
