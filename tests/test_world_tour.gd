extends RefCounted
## Comprueba el tour de estaciones del museo explorable (ADR-0034).

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


func _station(world: Node, id: String) -> Station:
	var llacta: Node = world.get_node_or_null("Llacta")
	if llacta == null:
		return null
	for node: Node in llacta.get_children():
		var station: Station = node as Station
		if station != null and station.station_id == StringName(id):
			return station
	return null


func test_world_tour_starts() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var stations: int = 0
	for node: Node in world.get_node("Llacta").get_children():
		if node is Station:
			stations += 1
	var ok: bool = (
		hud != null
		and stations == 9
		and hud.get_tour_progress_text() == "0/9"
		and hud.is_showing_objective()
		and hud.get_objective_text() == tr("PCH_OBJ_TOUR_FREE")
		and not hud.is_tour_compass_visible()
	)
	world.free()
	return ok


func test_world_tour_station_opens_card() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var station: Station = _station(world, "plaza")
	if hud == null or player == null or station == null:
		world.free()
		return false
	station.interact(player)
	var ok: bool = (
		hud.is_tour_card_open()
		and hud.get_tour_progress_text() == "1/9"
		and hud.get_tour_card().get_title_text() == tr("PCH_ST_PLAZA_TITLE")
		and player.process_mode == Node.PROCESS_MODE_DISABLED
	)
	hud.close_tour_card()
	ok = ok and not hud.is_tour_card_open()
	ok = ok and player.process_mode == Node.PROCESS_MODE_INHERIT
	world.free()
	return ok


func test_world_tour_station_counts_once() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var station: Station = _station(world, "quero")
	if hud == null or player == null or station == null:
		world.free()
		return false
	station.interact(player)
	hud.close_tour_card()
	station.interact(player)
	hud.close_tour_card()
	var ok: bool = hud.get_tour_progress_text() == "1/9"
	world.free()
	return ok


func test_world_tour_mirador_opens_event() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	var mirador: Station = _station(world, "mirador")
	if hud == null or player == null or event == null or mirador == null:
		world.free()
		return false
	# Cerca de la plaza: la petición del mirador arranca al volver.
	player.global_position = Vector3(0.0, 0.05, 2.0)
	mirador.interact(player)
	hud.close_tour_card()
	var ok: bool = event.phase == MessengerEvent.Phase.ARRIVAL
	world.free()
	return ok


func test_world_tour_texts() -> bool:
	for id: StringName in MundoBase.STATION_IDS:
		for part: String in ["TITLE", "BODY", "BADGE", "SOURCE"]:
			var key: String = "PCH_ST_%s_%s" % [String(id).to_upper(), part]
			var text: String = tr(key)
			if text == key or text.is_empty():
				return false
	return true
