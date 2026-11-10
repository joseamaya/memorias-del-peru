extends RefCounted
## Comprueba que la escena sandbox instancia y entra al árbol.


func test_sandbox_loads() -> bool:
	var packed: PackedScene = load("res://tests/scenes/player_sandbox.tscn") as PackedScene
	if packed == null:
		return false
	var sandbox: Node = packed.instantiate()
	if sandbox == null:
		return false
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		sandbox.free()
		return false
	tree.root.add_child(sandbox)
	var ok: bool = sandbox.is_inside_tree()
	sandbox.queue_free()
	return ok
