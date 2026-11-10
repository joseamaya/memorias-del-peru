extends RefCounted
## Comprueba que las normales del terreno apuntan hacia arriba.


func test_terrain_normals_up() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var terrain: Node3D = world.get_node_or_null("Terrain") as Node3D
	if terrain == null:
		world.free()
		return false
	var mesh_instance: MeshInstance3D = terrain.get_node_or_null("TerrainMesh") as MeshInstance3D
	if mesh_instance == null or mesh_instance.mesh == null:
		world.free()
		return false
	var arrays: Array = mesh_instance.mesh.surface_get_arrays(0)
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var count: int = normals.size()
	if count == 0:
		world.free()
		return false
	var total_y: float = 0.0
	for normal: Vector3 in normals:
		total_y += normal.y
	var average_y: float = total_y / float(count)
	world.free()
	return average_y > 0.9
