extends RefCounted
## Comprueba que el jugador aparece en PlayerSpawn.


func test_player_spawn() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var spawn: Marker3D = world.get_node_or_null("PlayerSpawn") as Marker3D
	var ok: bool = (
		player != null
		and spawn != null
		and player.global_position.is_equal_approx(spawn.global_position)
	)
	world.free()
	return ok
