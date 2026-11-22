extends SceneTree
## Comprueba el ciclo descanso → guardar → cargar de la vertical slice (F3.7).
##
## Duerme en la casa del jugador, comprueba que se guarda la ranura automática
## y levanta una segunda instancia del mundo como si se hubiera cerrado el
## juego: hora, NPC, banderas de misión, inventario y obras deben volver.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const CAMPAIGN: StringName = &"01_pachacutec"
const SETTLE_FRAMES: int = 600
const POSITION_TOLERANCE: float = 1.5
const NAMED_NPCS: int = 8


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveManagerService.set_save_root("user://test-saves")
	var manager: SaveManagerService = SaveManagerService.instance()
	var clock: WorldClockService = WorldClockService.instance()
	var world_state: WorldStateService = WorldStateService.instance()
	var campaign_state: CampaignStateService = CampaignStateService.instance()
	var ok: bool = (
		manager != null and clock != null and world_state != null and campaign_state != null
	)
	if not ok:
		printerr("SAVE_FAIL sin gestor de guardado o reloj")
		quit(1)
		return
	_clear_campaign(manager)
	world_state.clear()
	campaign_state.clear()
	clock.set_paused(true)
	clock.set_time(3, 1200.0)

	var world: RegionWorld = _spawn()
	ok = ok and await _wait_population(world)
	var player: PlayerFPS = world.get_player() if world != null else null
	var session: CampaignSession = world.get_session() if world != null else null
	var blockout: CuscoBlockout = world.get_streamer().get_loaded_node(&"s1_cusco") as CuscoBlockout
	var door: InteriorDoor = _home_door(blockout)
	ok = ok and player != null and session != null and door != null
	if not ok:
		printerr("SAVE_FAIL sin jugador, sesion o puerta de casa")
		world.queue_free()
		await process_frame
		quit(1)
		return

	# Estado representativo de lo que la partida debe conservar.
	world_state.set_flag(&"mision_principal", 2)
	world_state.set_change(&"foso_arrabal", 1)
	campaign_state.set_flag(&"mision", 2)
	campaign_state.set_data(&"inventario", ["honda", "porra"])

	# Dormir desde dentro de la casa: se sale a la puerta y avanza el día.
	player.global_position = door.global_position + Vector3(0.0, 1.0, 2.4)
	await physics_frame
	ok = ok and world.get_interiors().enter(door)
	await physics_frame
	ok = ok and session.rest_until_morning()
	ok = ok and not world.get_interiors().is_inside()
	ok = ok and clock.get_day() == 4
	ok = ok and clock.get_minute_of_day() == RestCycle.wake_minute()
	ok = ok and session.get_last_save_ok()
	ok = ok and manager.has_slot(CAMPAIGN, SaveManagerService.AUTO_SLOT)
	var overlay: SleepOverlay = session.get_overlay()
	ok = ok and overlay != null and overlay.is_active()
	ok = ok and not overlay.get_title_text().begins_with("UI_")
	ok = (
		ok
		and overlay.get_detail_text().contains(SleepOverlay.format_minute(RestCycle.wake_minute()))
	)

	var saved_position: Vector3 = player.global_position
	var director: NpcDirector = world.get_population().get_director()
	var saved_anchor: StringName = director.get_anchor(&"npc_curaca")
	var data: Dictionary = manager.load_slot(CAMPAIGN, SaveManagerService.AUTO_SLOT)
	var player_data: Dictionary = _as_dict(data.get("player", {}))
	var snapshot: Dictionary = _as_dict(player_data.get("npcs", {}))
	var npcs_value: Variant = snapshot.get("npcs", {})
	var saved_npcs: int = _as_dict(npcs_value).size() if npcs_value is Dictionary else -1
	ok = ok and saved_npcs == NAMED_NPCS

	# Cierre del juego: el estado en memoria se pierde y el reloj vuelve al inicio.
	world.queue_free()
	await process_frame
	world_state.clear()
	campaign_state.clear()
	clock.set_time(1, 480.0)
	var requested: bool = manager.request_load(CAMPAIGN, SaveManagerService.AUTO_SLOT)
	ok = ok and requested

	var world2: RegionWorld = _spawn()
	ok = ok and await _wait_population(world2)
	var player2: PlayerFPS = world2.get_player() if world2 != null else null
	var session2: CampaignSession = world2.get_session() if world2 != null else null
	ok = ok and player2 != null and session2 != null
	ok = ok and session2.is_restored()
	ok = ok and clock.get_day() == 4
	ok = ok and clock.get_minute_of_day() == RestCycle.wake_minute()
	ok = ok and world_state.get_flag(&"mision_principal") == 2
	ok = ok and world_state.get_change(&"foso_arrabal") == 1
	ok = ok and campaign_state.get_flag(&"mision") == 2
	var inventory: Variant = campaign_state.get_data(&"inventario")
	ok = ok and inventory is Array
	if inventory is Array:
		ok = ok and _as_array(inventory).size() == 2
	ok = ok and player2.global_position.distance_to(saved_position) <= POSITION_TOLERANCE
	var director2: NpcDirector = world2.get_population().get_director()
	ok = ok and director2.get_anchor(&"npc_curaca") == saved_anchor

	print(
		"SAVE_ROUND_TRIP day=",
		clock.get_day(),
		" minute=",
		clock.get_minute_of_day(),
		" npcs=",
		saved_npcs,
		" position_gap=",
		snappedf(player2.global_position.distance_to(saved_position), 0.01),
		" restored=",
		session2.is_restored()
	)
	world2.queue_free()
	world_state.clear()
	campaign_state.clear()
	clock.set_paused(false)
	clock.set_time(1, 480.0)
	_clear_campaign(manager)
	await process_frame
	await process_frame
	if ok:
		print("SAVE_ROUND_TRIP_OK")
	else:
		printerr("SAVE_ROUND_TRIP_FAIL")
	quit(0 if ok else 1)


func _spawn() -> RegionWorld:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		return null
	var world: RegionWorld = packed.instantiate() as RegionWorld
	if world == null:
		return null
	root.add_child(world)
	return world


func _wait_population(world: RegionWorld) -> bool:
	if world == null:
		return false
	for _i: int in SETTLE_FRAMES:
		await process_frame
		var population: CityPopulation = world.get_population()
		if population != null and population.is_built():
			return true
	return false


func _home_door(blockout: CuscoBlockout) -> InteriorDoor:
	if blockout == null:
		return null
	for door: InteriorDoor in blockout.get_interior_doors():
		if door.player_home:
			return door
	return null


func _clear_campaign(manager: SaveManagerService) -> void:
	for slot: String in manager.list_slots(CAMPAIGN):
		manager.delete_slot(CAMPAIGN, StringName(slot))
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.save_root().path_join(String(CAMPAIGN)))
	)


# El payload viene de JSON; la comprobación `is` se hace antes de llamar.
static func _as_dict(value: Variant) -> Dictionary:
	@warning_ignore("unsafe_cast")
	return value as Dictionary


static func _as_array(value: Variant) -> Array:
	@warning_ignore("unsafe_cast")
	return value as Array
