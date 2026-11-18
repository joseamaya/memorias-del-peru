extends RefCounted
## Comprueba el cierre del acto I: tras tres encargos, la asamblea pregunta y
## la elección deja su bandera y la tarjeta de fin.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"


func test_assembly() -> bool:
	CampaignState.clear()
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	if world == null:
		return false
	tree.root.add_child(world)
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var tasks: Array[TaskPoint] = []
	for task_name: String in ["TaskAgua", "TaskMaiz", "TaskTelar"]:
		var task: TaskPoint = world.get_node_or_null(task_name) as TaskPoint
		if task != null:
			tasks.append(task)
	if player == null or hud == null or tasks.size() < 3:
		world.free()
		return false
	for task: TaskPoint in tasks:
		task.interact(player)
	var doubt: CampPoint = world.get_node_or_null("DudaPoint") as CampPoint
	if doubt == null:
		world.free()
		CampaignState.clear()
		return false
	doubt.interact(player)
	hud.get_dialogue_panel().choice_selected.emit(0)
	world.call("_on_dialogue_advanced")
	var messenger: CampPoint = world.get_node_or_null("MessengerPoint") as CampPoint
	if messenger == null:
		world.free()
		CampaignState.clear()
		return false
	messenger.interact(player)
	hud.get_dialogue_panel().choice_selected.emit(2)
	world.call("_on_dialogue_advanced")
	player.global_position = Vector3(0.0, 0.05, 2.0)
	world.call("_process", 0.016)
	var ok: bool = hud.is_dialogue_open()
	ok = ok and hud.get_dialogue_panel().get_text() == tr("PCH_ASM_ASK")
	ok = ok and hud.get_dialogue_panel().get_choice_count() == 3
	hud.get_dialogue_panel().choice_selected.emit(0)
	ok = ok and world.get("_assembly_choice") == &"asm_go"
	world.call("_on_dialogue_advanced")
	ok = ok and world.get("_assembly_done") == true and hud.is_end_card_visible()
	ok = ok and CampaignState.get_flag(&"ofrecio") == 1
	hud.hide_dialogue()
	hud.clear_subtitle()
	world.free()
	CampaignState.clear()
	return ok
