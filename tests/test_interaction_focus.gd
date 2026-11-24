extends RefCounted
## Comprueba el enfoque y desenfoque de un interactuable.


var _focused: Array[Interactable] = []
var _unfocused: int = 0


func _on_focused(interactable: Interactable) -> void:
	_focused.append(interactable)


func _on_unfocused() -> void:
	_unfocused += 1


func test_interaction_focus() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://core/player/player_fps.tscn") as PackedScene
	var player: PlayerFPS = packed.instantiate() as PlayerFPS
	var object: CountingInteractable = CountingInteractable.new()
	var holder: Node3D = Node3D.new()
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(0.4, 0.4, 0.4)
	shape.shape = box
	body.collision_layer = 4
	body.collision_mask = 0
	body.position = Vector3(0.0, 1.6, -1.5)
	body.add_child(shape)
	holder.add_child(body)
	object.add_child(holder)
	tree.root.add_child(player)
	tree.root.add_child(object)
	player.interactable_focused.connect(_on_focused)
	player.interactable_unfocused.connect(_on_unfocused)
	player.interaction_ray.force_raycast_update()
	player.update_interaction()
	var focused_ok: bool = _focused.size() == 1 and _focused[0] == object
	player.interaction_ray.enabled = false
	player.update_interaction()
	player.interaction_ray.enabled = true
	var unfocused_ok: bool = _unfocused == 1
	player.interactable_focused.disconnect(_on_focused)
	player.interactable_unfocused.disconnect(_on_unfocused)
	player.free()
	object.free()
	return focused_ok and unfocused_ok


func test_interaction_focus_survives_freed_target() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://core/player/player_fps.tscn") as PackedScene
	var player: PlayerFPS = packed.instantiate() as PlayerFPS
	var object: CountingInteractable = CountingInteractable.new()
	var holder: Node3D = Node3D.new()
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(0.4, 0.4, 0.4)
	shape.shape = box
	body.collision_layer = 4
	body.collision_mask = 0
	body.position = Vector3(0.0, 1.6, -1.5)
	body.add_child(shape)
	holder.add_child(body)
	object.add_child(holder)
	tree.root.add_child(player)
	tree.root.add_child(object)
	player.interactable_unfocused.connect(_on_unfocused)
	player.interaction_ray.force_raycast_update()
	player.update_interaction()
	var focused: bool = player.get_focused_interactable() == object
	var before: int = _unfocused
	# El NPC se libera entre el último fotograma y la pulsación de E.
	object.free()
	player.try_interact()
	var ok: bool = focused and player.get_focused_interactable() == null
	ok = ok and _unfocused == before + 1
	player.interactable_unfocused.disconnect(_on_unfocused)
	player.free()
	return ok
