extends RefCounted
## Comprueba la composición del territorio de la llacta: caminos visibles,
## borde de plaza, manantial, mirador, fondo de valle y colisiones de casa
## coherentes con cada variante.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"


func test_llacta_layout() -> bool:
	CampaignState.clear()
	CampaignState.set_flag(&"intro_vista", 1)
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	if world == null:
		return false
	tree.root.add_child(world)
	var paths: LlactaPaths = world.get_node_or_null("Llacta/Paths") as LlactaPaths
	var edges: LlactaPlazaEdges = world.get_node_or_null("Llacta/PlazaEdges") as LlactaPlazaEdges
	var spring: Node3D = world.get_node_or_null("Llacta/Spring") as Node3D
	var mirador: Node3D = world.get_node_or_null("Llacta/Mirador") as Node3D
	var backdrop: ValleyBackdrop = world.get_node_or_null("Llacta/Backdrop") as ValleyBackdrop
	var agua: Node3D = world.get_node_or_null("TaskAgua") as Node3D
	var houses: Node = world.get_node_or_null("Llacta/Houses")
	if paths == null or edges == null or spring == null or mirador == null \
			or backdrop == null or agua == null or houses == null:
		return _fail(world)
	var ok: bool = paths.paths.size() >= 8
	ok = ok and paths.get_node_or_null("PathSurface") != null
	var path_mesh: MeshInstance3D = paths.get_node_or_null("PathSurface") as MeshInstance3D
	ok = ok and path_mesh != null and path_mesh.mesh != null
	var edge_mesh: MultiMeshInstance3D = paths.get_node_or_null("PathEdge") as MultiMeshInstance3D
	ok = ok and edge_mesh != null and edge_mesh.multimesh.instance_count > 120
	ok = ok and edges.segments.size() == 9
	var edge_bodies: Node = edges.get_node_or_null("WallBodies")
	ok = ok and edge_bodies != null and edge_bodies.get_child_count() == 9
	ok = ok and spring.get_node_or_null("SpringWater") != null
	ok = ok and spring.get_node_or_null("Acequia") != null
	ok = ok and mirador.get_node_or_null("View") != null
	ok = ok and backdrop.get_node_or_null("ValleyFloor") != null
	ok = ok and backdrop.get_node_or_null("Town") != null
	# El camino llega al mirador y la tarea de agua nace en el manantial.
	ok = ok and paths.distance_to_paths(Vector2(0.0, -70.0)) < 0.2
	var to_spring: Vector2 = Vector2(agua.global_position.x, agua.global_position.z)
	var spring_xz: Vector2 = Vector2(spring.global_position.x, spring.global_position.z)
	ok = ok and to_spring.distance_to(spring_xz) <= 2.0
	# Las casas no quedan encima de un camino y su colisión coincide con HouseKit.
	for index: int in range(8):
		var house: Node3D = houses.get_node_or_null("House%02d" % (index + 1)) as Node3D
		if house == null:
			return _fail(world)
		var center: Vector2 = Vector2(house.global_position.x, house.global_position.z)
		ok = ok and paths.distance_to_paths(center) > 2.5
		var base: StaticBody3D = house.get_node_or_null("Base") as StaticBody3D
		if base == null:
			return _fail(world)
		var collision: CollisionShape3D = null
		for child: Node in base.get_children():
			collision = child as CollisionShape3D
			if collision != null:
				break
		ok = ok and collision != null
		if collision != null:
			var box: BoxShape3D = collision.shape as BoxShape3D
			ok = ok and box != null
			if box != null:
				ok = ok and box.size.is_equal_approx(HouseKit.wall_size(index))
	# El parapeto del norte es bajo para ver el valle desde el mirador.
	var north: StaticBody3D = world.get_node_or_null("Boundary/NorthWest") as StaticBody3D
	ok = ok and north != null
	if north != null:
		var shape: BoxShape3D = null
		for child: Node in north.get_children():
			var collision: CollisionShape3D = child as CollisionShape3D
			if collision != null:
				shape = collision.shape as BoxShape3D
		ok = ok and shape != null and shape.size.y <= 1.0
	world.free()
	CampaignState.clear()
	return ok


func _fail(world: Node) -> bool:
	world.free()
	CampaignState.clear()
	return false
