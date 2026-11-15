extends RefCounted
## Comprueba las tres oleadas de la defensa y el costo con nombre: si Anca fue
## salvado, cae él y el acto IV lo sabe.

const CIUDAD: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"


func test_three_waves_and_cost() -> bool:
	CampaignState.clear()
	CampaignState.set_flag(&"herido_salvado", 1)
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(CIUDAD) as PackedScene).instantiate()
	if world == null:
		return false
	tree.root.add_child(world)
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var ok: bool = hud != null
	world.call("_start_defense")
	ok = ok and world.call("is_ambush_active") == true
	for _wave: int in range(3):
		for child: Node in world.get_children():
			if child is AmbushEnemy and (child as AmbushEnemy).is_alive():
				child.call("take_hit", 200.0)
		world.call("_physics_process", 0.1)
	ok = ok and world.call("is_completed") == true
	ok = ok and CampaignState.has_flag(&"costo_anca")
	var body: Label = hud.get_node_or_null("EndPanel/EndBody") as Label
	ok = ok and body != null and body.text.contains(tr("PCH_CIUDAD_COST_ANCA"))
	world.free()
	CampaignState.clear()
	return ok
