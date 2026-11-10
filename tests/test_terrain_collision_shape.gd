extends RefCounted
## Comprueba que el terreno tiene una forma de colisión trimesh.


func test_terrain_collision_shape() -> bool:
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
	var body: StaticBody3D = terrain.get_node_or_null("TerrainBody") as StaticBody3D
	if body == null:
		world.free()
		return false
	var collision: CollisionShape3D = body.get_node_or_null("TerrainCollision") as CollisionShape3D
	var ok: bool = collision != null and collision.shape is ConcavePolygonShape3D
	world.free()
	return ok
