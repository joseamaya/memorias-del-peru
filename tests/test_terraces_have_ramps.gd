extends RefCounted
## Comprueba que las terrazas se pueden recorrer por rampas inclinadas.


func test_terraces_have_ramps() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var terraces: Node3D = world.get_node_or_null("Llacta/Terraces") as Node3D
	if terraces == null:
		world.free()
		return false
	var ramps: int = 0
	for child: Node in terraces.get_children():
		var body: StaticBody3D = child as StaticBody3D
		if body == null or not String(body.name).ends_with("Ramp"):
			continue
		if not (absf(body.rotation.z) > 0.01):
			continue
		var has_shape: bool = false
		for grandchild: Node in body.get_children():
			if grandchild is CollisionShape3D:
				has_shape = true
		if has_shape:
			ramps += 1
	var ok: bool = ramps >= 3
	world.free()
	return ok
