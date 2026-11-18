extends RefCounted
## Comprueba que la tarjeta de fin muestra el cuerpo narrativo: la noticia de
## Viracocha en el acto IV y el nombre nuevo en el V.

const ACT_FOUR: String = "res://campaigns/01_pachacutec/scenes/world/llacta_act4.tscn"
const ACT_FIVE: String = "res://campaigns/01_pachacutec/scenes/world/llacta_act5.tscn"


func _spawn(path: String) -> Node:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var world: Node = (load(path) as PackedScene).instantiate()
	if world == null:
		return null
	tree.root.add_child(world)
	return world


func test_end_card_text_waits_for_the_backdrop() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://core/ui/hud.tscn") as PackedScene
	if packed == null:
		return false
	var hud: PlayerHud = packed.instantiate() as PlayerHud
	if hud == null:
		return false
	tree.root.add_child(hud)
	var body: Label = hud.get_node_or_null("EndPanel/EndBody") as Label
	if body == null:
		hud.free()
		return false
	hud.show_end_card("Fin", "Seguir", "Texto")
	hud.advance_end_card(0.4)
	var early: bool = body.modulate.a == 0.0
	hud.advance_end_card(1.6)
	var late: bool = is_equal_approx(body.modulate.a, 1.0)
	hud.free()
	return early and late


func test_end_card_shows_news() -> bool:
	CampaignState.clear()
	var world: Node = _spawn(ACT_FOUR)
	if world == null:
		return false
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var ok: bool = player != null and hud != null
	for index: int in range(3):
		var account: CampPoint = world.get_node_or_null("Account%d" % index) as CampPoint
		if account != null:
			account.interact(player)
	player.global_position = Vector3(0.0, 0.05, 2.0)
	world.call("_process", 0.016)
	ok = ok and hud.is_dialogue_open()
	hud.get_dialogue_panel().choice_selected.emit(0)
	world.call("_on_dialogue_advanced")
	var body: Label = hud.get_node_or_null("EndPanel/EndBody") as Label
	ok = ok and body != null and body.visible
	ok = ok and body.text == tr("PCH_ASM4_NEWS")
	world.free()

	var five: Node = _spawn(ACT_FIVE)
	if five == null:
		CampaignState.clear()
		return false
	var five_player: PlayerFPS = five.get_node_or_null("PlayerFPS") as PlayerFPS
	var five_hud: PlayerHud = five.get_node_or_null("UILayer/HUD") as PlayerHud
	ok = ok and five_player != null and five_hud != null
	for task_name: String in ["RebuildPirca", "RebuildTerraza", "RebuildAcequia", "RebuildTelar", "RebuildCasa"]:
		var task: TaskPoint = five.get_node_or_null(task_name) as TaskPoint
		if task != null:
			task.interact(five_player)
	var five_body: Label = five_hud.get_node_or_null("EndPanel/EndBody") as Label
	ok = ok and five_body != null and five_body.visible
	ok = ok and five_body.text.contains(tr("PCH_END5_NAME"))
	ok = ok and (five_body.text.contains(tr("PCH_FINAL_LLENA"))
		or five_body.text.contains(tr("PCH_FINAL_EN_PIE"))
		or five_body.text.contains(tr("PCH_FINAL_VACIA")))
	five.free()
	CampaignState.clear()
	return ok
