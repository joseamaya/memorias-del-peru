extends RefCounted
## Comprueba que el pututu inicia el evento del chasqui.


func test_chasqui_event() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var pututu: Pututu = world.get_node_or_null("Pututu") as Pututu
	var event: ChasquiEvent = world.get_node_or_null("EventController") as ChasquiEvent
	if pututu == null or event == null:
		world.free()
		return false
	var interactor: Node3D = Node3D.new()
	pututu.interact(interactor)
	interactor.free()
	var ok: bool = event.active
	world.free()
	return ok
