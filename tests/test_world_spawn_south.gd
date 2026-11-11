extends RefCounted
## Comprueba que el jugador aparece en el camino sur.


func test_world_spawn_south() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var spawn: Marker3D = world.get_node_or_null("PlayerSpawn") as Marker3D
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var ok: bool = (
		spawn != null
		and player != null
		and spawn.position.z > 30.0
		and player.global_position.is_equal_approx(spawn.global_position)
	)
	world.free()
	return ok
