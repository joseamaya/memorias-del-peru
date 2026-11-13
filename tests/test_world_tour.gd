extends RefCounted
## Comprueba la lectura en el mundo (ADR-0036): zonas invisibles, tarjetas al
## estar en el sitio o al hacer la acción, y cierre por el mirador.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"


func _spawn_world() -> Node:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return null
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	return world


func test_world_tour_starts() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var spots: int = 0
	for node: Node in world.get_children():
		if node is Area3D and str(node.name).begins_with("Spot"):
			spots += 1
	var ok: bool = hud != null and spots == 7 and not hud.is_showing_objective()
	world.free()
	return ok


func test_world_tour_zone_opens_card() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	if hud == null or player == null:
		world.free()
		return false
	world.call("visit_spot", &"plaza")
	var ok: bool = (
		hud.is_tour_card_open()
		and hud.get_tour_card().get_title_text() == tr("PCH_ST_PLAZA_TITLE")
		and player.process_mode == Node.PROCESS_MODE_DISABLED
	)
	hud.close_tour_card()
	ok = ok and not hud.is_tour_card_open()
	ok = ok and player.process_mode == Node.PROCESS_MODE_INHERIT
	world.call("visit_spot", &"plaza")
	ok = ok and not hud.is_tour_card_open()
	world.free()
	return ok


func test_world_tour_all_spots() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	if hud == null or player == null:
		world.free()
		return false
	# Cerca de la plaza: el mirador, al final, pide la llegada del mensajero.
	player.global_position = Vector3(0.0, 0.05, 2.0)
	var ids: Array[StringName] = [
		&"plaza", &"quero", &"chicha", &"ofrenda", &"telar",
		&"vivienda", &"terraza", &"corral", &"mirador",
	]
	var ok: bool = true
	for id: StringName in ids:
		world.call("visit_spot", id)
		if not hud.is_tour_card_open():
			ok = false
			break
		var expected: String = tr("PCH_ST_%s_TITLE" % String(id).to_upper())
		ok = hud.get_tour_card().get_title_text() == expected
		hud.close_tour_card()
		ok = ok and not hud.is_tour_card_open()
		if not ok:
			break
	# Ninguna tarjeta se reabre al volver.
	world.call("visit_spot", &"plaza")
	ok = ok and not hud.is_tour_card_open()
	world.free()
	return ok


func test_world_tour_action_opens_card() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var quero: QueroChicha = world.get_node_or_null("QueroChicha") as QueroChicha
	if hud == null or player == null or quero == null:
		world.free()
		return false
	quero.audio_stream = null
	quero.interact(player)
	var ok: bool = (
		hud.is_tour_card_open()
		and hud.get_tour_card().get_title_text() == tr("PCH_ST_QUERO_TITLE")
	)
	hud.close_tour_card()
	world.free()
	return ok


func test_world_tour_mirador_opens_event() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	if hud == null or player == null or event == null:
		world.free()
		return false
	# Cerca de la plaza: la petición del mirador arranca al volver.
	player.global_position = Vector3(0.0, 0.05, 2.0)
	world.call("visit_spot", &"mirador")
	hud.close_tour_card()
	var ok: bool = event.phase == MessengerEvent.Phase.ARRIVAL
	world.free()
	return ok


func test_world_tour_texts() -> bool:
	for id: StringName in [&"plaza", &"quero", &"chicha", &"ofrenda", &"telar", &"vivienda", &"terraza", &"corral", &"mirador"]:
		for part: String in ["TITLE", "BODY", "BADGE", "SOURCE"]:
			var key: String = "PCH_ST_%s_%s" % [String(id).to_upper(), part]
			var text: String = tr(key)
			if text == key or text.is_empty():
				return false
	return true
