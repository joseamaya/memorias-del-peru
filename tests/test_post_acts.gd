extends RefCounted
## Comprueba los actos IV y V: la asamblea de posguerra y la reconstrucción.

const ACT_FOUR: String = "res://campaigns/01_pachacutec/scenes/world/llacta_act4.tscn"
const ACT_FIVE: String = "res://campaigns/01_pachacutec/scenes/world/llacta_act5.tscn"


func _spawn(path: String) -> Node:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return null
	var world: Node = packed.instantiate()
	if world == null:
		return null
	tree.root.add_child(world)
	return world


func test_act_four_assembly() -> bool:
	CampaignState.clear()
	var world: Node = _spawn(ACT_FOUR)
	if world == null:
		return false
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var ok: bool = player != null and hud != null and world.get("act") == 4
	ok = ok and hud.get_objective_text() == tr("PCH_OBJ_POST")
	player.global_position = Vector3(0.0, 0.05, 2.0)
	world.call("_process", 0.016)
	ok = ok and hud.is_dialogue_open()
	ok = ok and hud.get_dialogue_panel().get_choice_count() == 2
	hud.get_dialogue_panel().choice_selected.emit(0)
	world.call("_on_dialogue_advanced")
	ok = ok and world.get("_act_four_done") == true and hud.is_end_card_visible()
	ok = ok and CampaignState.get_flag(&"hablo_en_asamblea") == 1
	world.free()
	CampaignState.clear()
	return ok


func test_act_five_rebuild() -> bool:
	CampaignState.clear()
	var world: Node = _spawn(ACT_FIVE)
	if world == null:
		return false
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var ok: bool = player != null and hud != null and world.get("act") == 5
	ok = ok and hud.get_objective_text() == tr("PCH_OBJ_REBUILD")
	var tasks: Array[TaskPoint] = []
	for task_name: String in ["RebuildPirca", "RebuildTerraza", "RebuildAcequia"]:
		var task: TaskPoint = world.get_node_or_null(task_name) as TaskPoint
		if task != null:
			tasks.append(task)
	ok = ok and tasks.size() == 3
	for task: TaskPoint in tasks:
		task.interact(player)
	ok = ok and world.get("_act_five_done") == true and hud.is_end_card_visible()
	ok = ok and CampaignState.get_flag(&"casa_reconstruida") == 1
	world.free()
	CampaignState.clear()
	return ok
