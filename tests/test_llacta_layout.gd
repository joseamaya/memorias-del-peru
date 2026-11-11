extends RefCounted
## Comprueba la composición básica de la llacta, sus caminos y el mirador.


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
	var path_north: Node = world.get_node_or_null("Llacta/PathNorth")
	var path_east: Node = world.get_node_or_null("Llacta/PathEast")
	var path_west: Node = world.get_node_or_null("Llacta/PathWest")
	var mirador: Marker3D = world.get_node_or_null("Mirador") as Marker3D
	var house_count: int = houses.get_child_count() if houses != null else 0
	var path_count: int = 0
	if path_south != null:
		path_count += 1
	if path_north != null:
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
		and path_count >= 4
		and mirador != null
	)
	world.free()
	return ok


## Comprueba que ninguna casa ocupa el eje de un camino.
func test_houses_clear_paths() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var houses: Node3D = world.get_node_or_null("Llacta/Houses") as Node3D
	if houses == null:
		world.free()
		return false
	var ok: bool = true
	for child: Node in houses.get_children():
		var at: Vector3 = (child as Node3D).position
		# Los caminos sur, norte, este y oeste ocupan una franja de 4 m
		# centrada en los ejes. Ninguna casa puede invadirla.
		if absf(at.x) < 4.5 or absf(at.z) < 4.5:
			ok = false
	world.free()
	return ok
