extends RefCounted
## Comprueba que el límite del mundo tiene colisión.


func test_world_bounds() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var boundary: Node3D = world.get_node_or_null("Boundary") as Node3D
	var walls: int = 0
	if boundary != null:
		for child: Node in boundary.get_children():
			if child is StaticBody3D:
				var body: StaticBody3D = child as StaticBody3D
				if body.collision_layer == 1:
					walls += 1
	var ok: bool = walls >= 4
	world.free()
	return ok
