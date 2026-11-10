extends RefCounted
## Comprueba que el entorno usa un cielo físico.


func test_sky_material() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var world_environment: WorldEnvironment = world.get_node_or_null("WorldEnvironment") as WorldEnvironment
	var ok: bool = false
	if world_environment != null and world_environment.environment != null:
		var environment: Environment = world_environment.environment
		if environment.sky != null:
			ok = environment.sky.sky_material is PhysicalSkyMaterial
	world.free()
	return ok
