extends RefCounted
## Comprueba la composición básica de la llacta.


func test_llacta_layout() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var llacta: Node3D = world.get_node_or_null("Llacta") as Node3D
	var plaza: Node = world.get_node_or_null("Llacta/Plaza")
	var houses: Node3D = world.get_node_or_null("Llacta/Houses") as Node3D
	var terraces: Node3D = world.get_node_or_null("Llacta/Terraces") as Node3D
	var path_south: Node = world.get_node_or_null("Llacta/PathSouth")
	var path_east: Node = world.get_node_or_null("Llacta/PathEast")
	var path_west: Node = world.get_node_or_null("Llacta/PathWest")
	var house_count: int = houses.get_child_count() if houses != null else 0
	var path_count: int = 0
	if path_south != null:
		path_count += 1
	if path_east != null:
		path_count += 1
	if path_west != null:
		path_count += 1
	var ok: bool = (
		llacta != null
		and plaza != null
		and houses != null
		and house_count >= 6
		and house_count <= 8
		and terraces != null
		and path_count >= 2
	)
	world.free()
	return ok
