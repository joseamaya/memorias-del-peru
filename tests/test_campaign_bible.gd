extends RefCounted
## Comprueba los puntos del guion que se corrigieron: casa al este, cuentas
## variables, línea de Puma con coste, oficio en la obra, coste de Anca y
## trampa obligatoria antes de la defensa.

const ACT_ONE: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"
const ACT_FOUR: String = "res://campaigns/01_pachacutec/scenes/world/llacta_act4.tscn"
const ACT_FIVE: String = "res://campaigns/01_pachacutec/scenes/world/llacta_act5.tscn"
const PASO: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"
const CIUDAD: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"


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


func _talk_line(world: Node, npc_name: String) -> StringName:
	var npc: Node = world.get_node_or_null("Llacta/NPCs/" + npc_name)
	if npc == null:
		return &""
	for child: Node in npc.get_children():
		if child is TalkPoint:
			return (child as TalkPoint).line_key
	return &""


func test_home_is_east_of_plaza() -> bool:
	CampaignState.clear()
	var world: Node = _spawn(ACT_ONE)
	if world == null:
		CampaignState.clear()
		return false
	var raw: Variant = world.call("_home_house")
	var house: Node3D = null
	if raw is Node3D:
		house = raw
	var ok: bool = house != null
	ok = ok and house.global_position.x > 0.0
	ok = ok and world.get_node_or_null("Llacta/Houses/House04") != null
	world.free()
	CampaignState.clear()
	return ok


func test_south_account_follows_cost() -> bool:
	CampaignState.clear()
	CampaignState.set_flag(&"costo_anca", 1)
	var world: Node = _spawn(ACT_FOUR)
	if world == null:
		CampaignState.clear()
		return false
	var anca: StringName = StringName(str(world.call("_account_text", 2)))
	world.free()
	CampaignState.clear()

	CampaignState.set_flag(&"costo_joven", 1)
	world = _spawn(ACT_FOUR)
	if world == null:
		CampaignState.clear()
		return false
	var joven: StringName = StringName(str(world.call("_account_text", 2)))
	world.free()
	CampaignState.clear()

	world = _spawn(ACT_FOUR)
	if world == null:
		CampaignState.clear()
		return false
	var nadie: StringName = StringName(str(world.call("_account_text", 2)))
	var ok: bool = anca == &"PCH_ACCOUNT_3_TEXT_ANCA"
	ok = ok and joven == &"PCH_ACCOUNT_3_TEXT"
	ok = ok and nadie == &"PCH_ACCOUNT_3_TEXT_NO_COST"
	ok = ok and anca != joven and joven != nadie
	world.free()
	CampaignState.clear()
	return ok


func test_anca_testifies_in_assembly() -> bool:
	CampaignState.clear()
	CampaignState.set_flag(&"herido_dejado", 1)
	var world: Node = _spawn(ACT_FOUR)
	if world == null:
		CampaignState.clear()
		return false
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	if player == null or hud == null:
		world.free()
		CampaignState.clear()
		return false
	for index: int in range(3):
		var account: CampPoint = world.get_node_or_null("Account%d" % index) as CampPoint
		if account != null:
			account.interact(player)
	player.global_position = Vector3(0.0, 0.05, 2.0)
	world.call("_process", 0.016)
	var panel: DialoguePanel = hud.get_dialogue_panel()
	var ok: bool = hud.is_dialogue_open()
	ok = ok and panel.get_text() == tr("PCH_ASM4_ANCA_TESTIMONY")
	world.call("_on_dialogue_advanced")
	ok = ok and panel.get_text() == tr("PCH_ASM4_ASK")
	world.free()
	CampaignState.clear()
	return ok


func test_vecino_intervenes_in_assembly() -> bool:
	CampaignState.clear()
	var world: Node = _spawn(ACT_FOUR)
	if world == null:
		CampaignState.clear()
		return false
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	if player == null or hud == null:
		world.free()
		CampaignState.clear()
		return false
	for index: int in range(3):
		var account: CampPoint = world.get_node_or_null("Account%d" % index) as CampPoint
		if account != null:
			account.interact(player)
	player.global_position = Vector3(0.0, 0.05, 2.0)
	world.call("_process", 0.016)
	var panel: DialoguePanel = hud.get_dialogue_panel()
	var ok: bool = hud.is_dialogue_open()
	var more_index: int = panel.get_choice_count() - 1
	panel.choice_selected.emit(more_index)
	ok = ok and panel.get_choice_count() == 2
	panel.choice_selected.emit(0)
	ok = ok and panel.get_text() == tr("PCH_ASM4_VECINO_ANSWER")
	world.free()
	CampaignState.clear()
	return ok


func test_puma_reconciled_line_with_cost() -> bool:
	CampaignState.clear()
	CampaignState.set_flag(&"costo_joven", 1)
	CampaignState.set_flag(&"puma_reconciliado", 1)
	var world: Node = _spawn(ACT_FOUR)
	if world == null:
		CampaignState.clear()
		return false
	var ok: bool = _talk_line(world, "Principal2") == &"PCH_TALK_PUMA_4_RECONCILED_COST"
	world.free()
	CampaignState.clear()
	return ok


func test_puma_lines_without_cost() -> bool:
	CampaignState.clear()
	CampaignState.set_flag(&"puma_reconciliado", 1)
	var world: Node = _spawn(ACT_FOUR)
	if world == null:
		CampaignState.clear()
		return false
	var ok: bool = _talk_line(world, "Principal2") == &"PCH_TALK_PUMA_4_RECONCILED"
	world.free()
	world = _spawn(ACT_FIVE)
	if world == null:
		CampaignState.clear()
		return false
	ok = ok and _talk_line(world, "Principal2") == &"PCH_TALK_PUMA_5_RECONCILED"
	world.free()
	CampaignState.clear()
	return ok


func test_act_five_oficio_marks_work() -> bool:
	CampaignState.clear()
	CampaignProgress.set_oficio(&"pirca")
	var world: Node = _spawn(ACT_FIVE)
	if world == null:
		CampaignState.clear()
		return false
	var ok: bool = world.call("_is_oficio_work", &"pirca") == true
	ok = ok and world.call("_is_oficio_work", &"telar") == false
	world.call("_on_rebuild_completed", &"pirca")
	ok = ok and CampaignState.has_flag(&"obra_oficio")
	world.free()
	CampaignState.clear()
	return ok


func test_anca_carry_penalty() -> bool:
	CampaignState.clear()
	var world: Node = _spawn(PASO)
	if world == null:
		CampaignState.clear()
		return false
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var ok: bool = player != null and player.stamina != null
	world.call("_on_dialogue_flag", &"herido_salvado", 1)
	ok = ok and CampaignState.has_flag(&"carga_anca")
	ok = ok and player.stamina.get_maximum() == 75.0
	world.free()
	CampaignState.clear()
	return ok


func test_anca_leave_consumes_supplies() -> bool:
	CampaignState.clear()
	var world: Node = _spawn(PASO)
	if world == null:
		CampaignState.clear()
		return false
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var inventory: Inventory = world.get_node_or_null("PlayerFPS/Inventory") as Inventory
	var ok: bool = player != null and inventory != null
	var coca_before: int = inventory.count(&"coca")
	inventory.add(CampaignProgress.item_definition(&"agua"), 1)
	world.call("_on_dialogue_flag", &"herido_dejado", 1)
	ok = ok and not inventory.has(&"agua")
	ok = ok and inventory.count(&"coca") == coca_before - 1
	world.free()
	CampaignState.clear()
	return ok


func test_crossing_starts_ambush() -> bool:
	CampaignState.clear()
	var world: Node = _spawn(PASO)
	if world == null:
		CampaignState.clear()
		return false
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var ok: bool = player != null
	if player != null:
		player.global_position = Vector3(0.0, 0.0, -3.0)
	world.call("_physics_process", 0.1)
	ok = ok and world.call("is_ambush_active") == true
	world.free()
	CampaignState.clear()
	return ok


func test_trap_is_required_for_defense() -> bool:
	CampaignState.clear()
	var world: Node = _spawn(CIUDAD)
	if world == null:
		CampaignState.clear()
		return false
	var ok: bool = world.call("_can_start_defense") == false
	CampaignState.set_flag(&"trampa_resuelta", 1)
	ok = ok and world.call("_can_start_defense") == true
	world.free()
	CampaignState.clear()
	return ok


func test_final_card_reads_flags() -> bool:
	CampaignState.clear()
	CampaignState.set_flag(&"santuario_protegido", 1)
	CampaignState.set_flag(&"viracocha_muerto", 1)
	CampaignState.set_flag(&"maiz_repartido", 1)
	var world: Node = _spawn(ACT_FIVE)
	if world == null:
		CampaignState.clear()
		return false
	world.call("_finish_act_five")
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var body: Label = null
	if hud != null:
		body = hud.get_node_or_null("EndPanel/EndBody") as Label
	var ok: bool = body != null
	ok = ok and body.text.contains(tr("PCH_END5_NAME"))
	ok = ok and body.text.contains(tr("PCH_FINAL_CASA"))
	ok = ok and body.text.contains(tr("PCH_FINAL_SANTUARIO"))
	ok = ok and body.text.contains(tr("PCH_FINAL_MAIZ"))
	world.free()
	CampaignState.clear()
	return ok
