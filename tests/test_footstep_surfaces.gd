extends RefCounted
## Comprueba los pasos por superficie: el jugador elige el conjunto de la
## superficie que pisa, recurre al de por defecto si no hay conjunto, y las
## terrazas del mundo se declaran de piedra mientras el terreno no declara nada.

const PLAYER_PATH: String = "res://core/player/player_fps.tscn"
const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"


func _surface_selection_ok() -> bool:
	var ok: bool = true
	ok = ok and PlayerFPS.surface_of(null) == &""
	var plain: Node = Node.new()
	ok = ok and PlayerFPS.surface_of(plain) == &""
	plain.set_meta(PlayerFPS.FOOTSTEP_SURFACE_META, &"stone")
	ok = ok and PlayerFPS.surface_of(plain) == &"stone"
	plain.free()

	var player: PlayerFPS = (load(PLAYER_PATH) as PackedScene).instantiate() as PlayerFPS
	ok = ok and player.next_footstep_stream(&"stone") == null
	var dirt_a: AudioStream = AudioStreamGenerator.new()
	var dirt_b: AudioStream = AudioStreamGenerator.new()
	var stone_a: AudioStream = AudioStreamGenerator.new()
	var defaults: Array[AudioStream] = [dirt_a, dirt_b]
	player.footstep_streams = defaults
	var stone: FootstepSet = FootstepSet.new()
	stone.surface = &"stone"
	var stone_streams: Array[AudioStream] = [stone_a]
	stone.streams = stone_streams
	var sets: Array[FootstepSet] = [stone]
	player.footstep_sets = sets
	var first: AudioStream = player.next_footstep_stream(&"")
	var on_stone: AudioStream = player.next_footstep_stream(&"stone")
	var unknown: AudioStream = player.next_footstep_stream(&"mud")
	ok = ok and (first == dirt_a or first == dirt_b)
	ok = ok and on_stone == stone_a
	ok = ok and (unknown == dirt_a or unknown == dirt_b)
	# La alternancia cambia de variante entre pasos consecutivos.
	ok = ok and player.next_footstep_stream(&"") != player.next_footstep_stream(&"")
	player.free()
	return ok


func _world_marks_ok() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(WORLD_PATH) as PackedScene).instantiate()
	tree.root.add_child(world)
	var ok: bool = true
	# Rampas de piedra; encima de los bloques, tierra de cultivo con surcos.
	for level: String in ["Terrace01", "Terrace02", "Terrace03"]:
		var ramp: Node = world.get_node_or_null("Llacta/Terraces/%sRamp" % level)
		ok = ok and ramp != null and PlayerFPS.surface_of(ramp) == &"stone"
		for part: String in ["North", "South"]:
			var body: Node = world.get_node_or_null("Llacta/Terraces/%s%s" % [level, part])
			ok = ok and body != null and PlayerFPS.surface_of(body) == &""
			var field: MeshInstance3D = world.get_node_or_null("Llacta/Terraces/%sField%s" % [level, part]) as MeshInstance3D
			ok = ok and field != null and field.mesh != null and field.mesh.get_faces().size() > 6
	var terrain_body: Node = world.get_node_or_null("Terrain/TerrainBody")
	ok = ok and terrain_body != null and PlayerFPS.surface_of(terrain_body) == &""
	world.free()
	return ok


func test_footstep_surfaces() -> bool:
	return _surface_selection_ok() and _world_marks_ok()
