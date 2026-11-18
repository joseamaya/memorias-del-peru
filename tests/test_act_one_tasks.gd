extends RefCounted
## Comprueba el bucle del acto I: tres encargos dan sus recursos, fijan el
## oficio y cambian el objetivo.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"


func test_act_one_tasks() -> bool:
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
	var inventory: Inventory = player.get_node_or_null("Inventory") as Inventory
	var journal: Journal = player.get_node_or_null("Journal") as Journal
	var agua: TaskPoint = world.get_node_or_null("TaskAgua") as TaskPoint
	var maiz: TaskPoint = world.get_node_or_null("TaskMaiz") as TaskPoint
	var telar: TaskPoint = world.get_node_or_null("TaskTelar") as TaskPoint
	var pirca: TaskPoint = world.get_node_or_null("TaskPirca") as TaskPoint
	var ok: bool = player != null and hud != null and inventory != null
	ok = ok and agua != null and maiz != null and telar != null and pirca != null
	if not ok:
		world.free()
		return false
	ok = ok and agua.task_id == &"agua" and pirca.task_id == &"pirca"
	agua.interact(player)
	maiz.interact(player)
	telar.interact(player)
	ok = ok and inventory.has(&"agua") and inventory.has(&"maiz") and inventory.has(&"manta")
	ok = ok and agua.is_done() and maiz.is_done() and telar.is_done()
	var oficio_entry: JournalEntry = null
	if journal != null:
		oficio_entry = journal.get_entry(&"oficio")
	ok = ok and oficio_entry != null
	ok = ok and oficio_entry != null and oficio_entry.body_key \
		== CampaignProgress.oficio_body_key(&"agua")
	ok = ok and hud.hint_label.text == tr("PCH_TASK_DONE") % 3
	ok = ok and hud.get_objective_text() == tr("PCH_OBJ_DUDA")
	# El cuarto encargo sigue disponible, pero ya no hace falta.
	ok = ok and pirca.is_available()
	var doubt: CampPoint = world.get_node_or_null("DudaPoint") as CampPoint
	ok = ok and doubt != null
	if doubt != null:
		doubt.interact(player)
		ok = ok and hud.is_dialogue_open()
		hud.get_dialogue_panel().choice_selected.emit(0)
		world.call("_on_dialogue_advanced")
		ok = ok and hud.get_objective_text() == tr("PCH_OBJ_MESSENGER")
	var messenger: CampPoint = world.get_node_or_null("MessengerPoint") as CampPoint
	ok = ok and messenger != null
	if messenger != null:
		messenger.interact(player)
		ok = ok and hud.is_dialogue_open()
		ok = ok and hud.get_dialogue_panel().get_choice_count() == 3
		hud.get_dialogue_panel().choice_selected.emit(0)
		world.call("_on_dialogue_advanced")
		ok = ok and CampaignState.has_flag(&"noticia_chanca")
		ok = ok and hud.get_objective_text() == tr("PCH_OBJ_ASAMBLEA")
	world.free()
	CampaignState.clear()
	return ok
