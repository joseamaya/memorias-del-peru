extends RefCounted
## Comprueba que los tres interactuables de la llacta existen.


func test_llacta_interactables() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var quero: QueroChicha = world.get_node_or_null("QueroChicha") as QueroChicha
	var ofrenda: OfrendaPachamama = world.get_node_or_null("OfrendaPachamama") as OfrendaPachamama
	var pututu: Pututu = world.get_node_or_null("Pututu") as Pututu
	var ok: bool = quero != null and ofrenda != null and pututu != null
	world.free()
	return ok
