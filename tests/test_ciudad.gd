extends RefCounted
## Comprueba el acto III en gris: reclutamiento según las banderas del acto II,
## Cusi Yupanqui, defensa y epílogo (Fase 7).

const CIUDAD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"


func _spawn() -> Node:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var packed: PackedScene = load(CIUDAD_PATH) as PackedScene
	if packed == null:
		return null
	var ciudad: Node = packed.instantiate()
	tree.root.add_child(ciudad)
	return ciudad


func _state() -> CampaignStateService:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("CampaignState") as CampaignStateService


func test_ciudad_scene_starts() -> bool:
	var ciudad: Node = _spawn()
	if ciudad == null:
		return false
	var hud: PlayerHud = ciudad.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = ciudad.get_node_or_null("PlayerFPS") as PlayerFPS
	var ok: bool = hud != null and player != null
	ok = ok and ciudad.get_node_or_null("Recruit0") != null
	ok = ok and ciudad.get_node_or_null("Recruit1") != null
	ok = ok and ciudad.get_node_or_null("Recruit2") != null
	ok = ok and ciudad.get_node_or_null("CusiPoint") != null
	ok = ok and ciudad.call("ally_count") == 0
	ciudad.free()
	return ok


func test_ciudad_recruits_and_defense() -> bool:
	var state: CampaignStateService = _state()
	if state == null:
		return false
	state.clear()
	state.set_flag(&"maiz_guardado", 1)
	state.set_flag(&"herido_salvado", 1)
	state.set_flag(&"coca_compartida", 1)
	var ciudad: Node = _spawn()
	if ciudad == null:
		state.clear()
		return false
	var hud: PlayerHud = ciudad.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = ciudad.get_node_or_null("PlayerFPS") as PlayerFPS
	if hud == null or player == null:
		ciudad.free()
		state.clear()
		return false
	var ok: bool = true
	for index: int in range(3):
		var point: CampPoint = ciudad.get_node_or_null("Recruit%d" % index) as CampPoint
		if point == null:
			ok = false
			break
		point.interact(player)
		ok = ok and hud.is_dialogue_open()
		hud.get_dialogue_panel().choice_selected.emit(0)
		ciudad.call("_on_dialogue_advanced")
		ok = ok and not hud.is_dialogue_open()
	ok = ok and ciudad.call("ally_count") == 3
	ok = ok and state.has_flag(&"aliado_0") and state.has_flag(&"aliado_2")
	var cusi: CampPoint = ciudad.get_node_or_null("CusiPoint") as CampPoint
	if cusi != null:
		cusi.interact(player)
		ok = ok and hud.is_dialogue_open()
		hud.get_dialogue_panel().choice_selected.emit(0)
		ciudad.call("_on_dialogue_advanced")
	ok = ok and ciudad.call("is_ambush_active") == true
	var enemy: AmbushEnemy = ciudad.get_node_or_null("Defender1") as AmbushEnemy
	if enemy != null:
		enemy.take_hit(200.0)
	ciudad.call("_physics_process", 0.1)
	ok = ok and ciudad.call("is_completed") == true
	ok = ok and hud.is_end_card_visible()
	ciudad.free()
	state.clear()
	return ok


func test_ciudad_vespera_is_belief() -> bool:
	var state: CampaignStateService = _state()
	if state == null:
		return false
	state.clear()
	var ciudad: Node = _spawn()
	if ciudad == null:
		return false
	var hud: PlayerHud = ciudad.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = ciudad.get_node_or_null("PlayerFPS") as PlayerFPS
	var point: CampPoint = ciudad.get_node_or_null("VesperaPoint") as CampPoint
	var journal: Journal = ciudad.get_node_or_null("PlayerFPS/Journal") as Journal
	if hud == null or player == null or point == null or journal == null:
		ciudad.free()
		return false
	# La leyenda no altera aliados ni enemigos: es relato, no mecánica.
	var allies_before: Variant = ciudad.call("ally_count")
	point.interact(player)
	var ok: bool = hud.is_dialogue_open()
	hud.get_dialogue_panel().choice_selected.emit(0)
	ciudad.call("_on_dialogue_advanced")
	ok = ok and state.has_flag(&"mem_pururaucas")
	ok = ok and journal.has(&"mem_pururaucas")
	var entry: JournalEntry = journal.get_entry(&"mem_pururaucas")
	ok = ok and entry != null and entry.badge == &"N" and entry.source_key == &"PCH-031"
	ciudad.call("_on_dialogue_advanced")
	ok = ok and not hud.is_dialogue_open()
	ok = ok and ciudad.call("ally_count") == allies_before
	ok = ok and ciudad.call("alive_enemies") == 0
	# La «Memoria» se abre con J y conserva la leyenda.
	var open_event: InputEventAction = InputEventAction.new()
	open_event.action = &"journal"
	open_event.pressed = true
	ciudad.call("_unhandled_input", open_event)
	ok = ok and hud.is_journal_open()
	ciudad.call("_unhandled_input", open_event)
	ok = ok and not hud.is_journal_open()
	# Escuchar de nuevo no duplica la entrada ni abre el diálogo.
	point.interact(player)
	ok = ok and not hud.is_dialogue_open()
	ok = ok and journal.count() == 1
	ciudad.free()
	state.clear()
	return ok
