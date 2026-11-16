extends RefCounted
## Comprueba que llegada, preparación, trampa y cuentas tengan un ancla visible,
## que Cusi reciba en la puerta y que las cuentas estén en casas reales.

const CIUDAD: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"
const ACT_FOUR: String = "res://campaigns/01_pachacutec/scenes/world/llacta_act4.tscn"


func test_city_staging_targets() -> bool:
	CampaignState.clear()
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var city: Node = (load(CIUDAD) as PackedScene).instantiate()
	if city == null:
		return false
	tree.root.add_child(city)
	var player: PlayerFPS = city.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = city.get_node_or_null("UILayer/HUD") as PlayerHud
	var arrival: CampPoint = city.get_node_or_null("ArrivalPoint") as CampPoint
	var cusi: CampPoint = city.get_node_or_null("CusiPoint") as CampPoint
	var trap: CampPoint = city.get_node_or_null("TrapPoint") as CampPoint
	var ok: bool = player != null and hud != null
	ok = ok and arrival != null and arrival.highlight_target != null
	ok = ok and cusi != null and cusi.highlight_target != null
	ok = ok and trap != null and trap.highlight_target != null
	ok = ok and arrival != null and arrival.is_available()
	ok = ok and cusi != null and not cusi.is_available()
	ok = ok and hud.get_objective_text() == tr("PCH_CIUDAD_TALK_MESSAGE")
	for index: int in range(4):
		var prep: CampPoint = city.get_node_or_null("Prep%d" % index) as CampPoint
		ok = ok and prep != null and prep.highlight_target != null

	# Cusi empieza en la puerta; al entregar el mensaje se traslada al santuario.
	arrival.interact(player)
	ok = ok and hud.is_dialogue_open()
	hud.get_dialogue_panel().choice_selected.emit(0)
	city.call("_on_dialogue_advanced")
	ok = ok and CampaignState.has_flag(&"mensaje_entregado")
	ok = ok and cusi.is_available()
	ok = ok and not arrival.is_available()
	ok = ok and hud.get_objective_text() == tr("PCH_OBJ_RECRUIT")
	var cusi_raw: Variant = city.get("_cusi_visual")
	var cusi_visual: Node3D = null
	if cusi_raw is Node3D:
		cusi_visual = cusi_raw
	ok = ok and cusi_visual != null
	if cusi_visual != null:
		ok = ok and cusi_visual.global_position.distance_to(Vector3(0.0, 0.0, -12.0)) < 0.5
	city.free()

	var act_four: Node = (load(ACT_FOUR) as PackedScene).instantiate()
	if act_four == null:
		CampaignState.clear()
		return false
	tree.root.add_child(act_four)
	for index: int in range(3):
		var account: CampPoint = act_four.get_node_or_null("Account%d" % index) as CampPoint
		ok = ok and account != null and account.highlight_target != null
	var south: CampPoint = act_four.get_node_or_null("Account2") as CampPoint
	ok = ok and south != null and south.highlight_target != null
	if south != null and south.highlight_target != null:
		# La casa del sur está en (10, −20); la cuenta ya no es una caja en (0, 16).
		ok = ok and south.highlight_target.global_position.distance_to(
			Vector3(10.0, 0.0, -20.0)) < 6.0
	act_four.free()
	CampaignState.clear()
	return ok
