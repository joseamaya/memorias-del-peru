extends RefCounted
## Comprueba que los dos NPC con presencia existen.


func test_npcs_present() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var weaver: Node3D = world.get_node_or_null("Llacta/NPCs/Tejedora") as Node3D
	var farmer: Node3D = world.get_node_or_null("Llacta/NPCs/Agricultor") as Node3D
	var ok: bool = weaver != null and farmer != null
	world.free()
	return ok
