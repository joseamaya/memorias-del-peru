extends RefCounted
## Comprueba que el jugador aparece en el camino sur, a la vista de la plaza:
## lo bastante cerca para saber qué hacer y lo bastante lejos para ver la llacta.


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
	var plaza: Marker3D = world.get_node_or_null("PlazaPoint") as Marker3D
	var ok: bool = (
		spawn != null
		and player != null
		and spawn.position.z > 10.0
		and spawn.position.z < 30.0
		and player.global_position.is_equal_approx(spawn.global_position)
	)
	# A menos de 25 m del centro de la plaza: la primera interacción queda a la
	# vista y no hay que adivinar hacia dónde caminar.
	if ok and plaza != null:
		ok = spawn.global_position.distance_to(plaza.global_position) < 25.0
	world.free()
	return ok
