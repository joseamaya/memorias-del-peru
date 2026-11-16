extends RefCounted
## Comprueba que el campamento no pierde opciones: las seis caben en dos
## páginas de cuatro y «Compartir coca» y «Otro día será» son alcanzables.

const PASO: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"


func test_camp_dialogue_pages() -> bool:
	CampaignState.clear()
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(PASO) as PackedScene).instantiate()
	if world == null:
		return false
	tree.root.add_child(world)
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var inventory: Inventory = player.get_node_or_null("Inventory") as Inventory
	var runner: DialogueRunner = player.get_node_or_null("DialogueRunner") as DialogueRunner
	var camp: CampPoint = world.get_node_or_null("CampPoint") as CampPoint
	var ok: bool = player != null and hud != null and inventory != null \
		and runner != null and camp != null
	if not ok:
		world.free()
		CampaignState.clear()
		return false

	inventory.add(CampaignProgress.item_definition(&"agua"), 1)
	inventory.add(CampaignProgress.item_definition(&"manta"), 1)
	camp.interact(player)

	var panel: DialoguePanel = hud.get_dialogue_panel()
	ok = ok and panel.get_choice_count() == runner.get_visible_choices().size()
	ok = ok and panel.get_choice_count() == 3
	var first_keys: Array[StringName] = runner.get_visible_choice_text_keys()
	ok = ok and first_keys.has(&"PCH_CAMP_MORE")
	ok = ok and not first_keys.has(&"PCH_CAMP_REST")

	var more_index: int = first_keys.find(&"PCH_CAMP_MORE")
	panel.choice_selected.emit(more_index)
	ok = ok and runner.get_current_node() != null
	ok = ok and runner.get_current_node().id == &"more"
	ok = ok and panel.get_choice_count() == runner.get_visible_choices().size()
	var second_keys: Array[StringName] = runner.get_visible_choice_text_keys()
	ok = ok and second_keys.has(&"PCH_CAMP_COCA")
	ok = ok and second_keys.has(&"PCH_DLG_LEAVE")

	var leave_index: int = second_keys.find(&"PCH_DLG_LEAVE")
	panel.choice_selected.emit(leave_index)
	ok = ok and not runner.is_active()

	world.free()
	CampaignState.clear()
	return ok
