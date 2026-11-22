extends SceneTree
## Comprueba que al cargar en la etapa 2 la curáca conserva la conversación de
## la partida y puede fijar `m01_queda`.
##
## La población se construye después de `MissionController._restore()`: el
## cambio de conversación debe reintentarse cuando la población termina.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const CAMPAIGN: StringName = &"01_pachacutec"
const SETTLE_FRAMES: int = 600


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveManagerService.set_save_root("user://test-saves")
	var manager: SaveManagerService = SaveManagerService.instance()
	var state: WorldStateService = WorldStateService.instance()
	var campaign: CampaignStateService = CampaignStateService.instance()
	var ok: bool = manager != null and state != null and campaign != null
	if not ok:
		printerr("STAGE2_FAIL sin servicios")
		quit(1)
		return
	_clear_campaign(manager)
	state.clear()
	campaign.clear()

	var world: RegionWorld = _spawn()
	ok = ok and await _wait_ready(world)
	var session: CampaignSession = world.get_session() if world != null else null
	var mission: MissionController = session.get_mission() if session != null else null
	var population: CityPopulation = world.get_population() if world != null else null
	ok = ok and mission != null and population != null
	if not ok:
		printerr("STAGE2_FAIL sin mundo, misión o población")
		quit(1)
		return

	# Etapa 1 con sus tres banderas; la misión entra en la etapa 2 en vivo.
	state.set_flag(&"m01_agua", 1)
	state.set_flag(&"m01_lana", 1)
	state.set_flag(&"m01_maiz", 1)
	await process_frame
	ok = ok and mission.get_stage() == 2
	ok = ok and population.get_dialogue_id(&"npc_curaca") == &"m01_curaca_partida"
	ok = ok and session.save_auto()

	# Cargar como si se hubiera cerrado el juego.
	world.queue_free()
	await process_frame
	state.clear()
	campaign.clear()
	ok = ok and manager.request_load(CAMPAIGN, SaveManagerService.AUTO_SLOT)

	var world2: RegionWorld = _spawn()
	ok = ok and await _wait_ready(world2)
	var session2: CampaignSession = world2.get_session() if world2 != null else null
	var mission2: MissionController = session2.get_mission() if session2 != null else null
	var population2: CityPopulation = world2.get_population() if world2 != null else null
	ok = ok and session2 != null and session2.is_restored()
	ok = ok and mission2 != null and mission2.get_stage() == 2
	# El fallo original: la curáca volvía a `m01_curaca` y `m01_queda` no podía
	# fijarse, bloqueando la misión.
	ok = ok and population2 != null
	if population2 != null:
		ok = ok and population2.get_dialogue_id(&"npc_curaca") == &"m01_curaca_partida"

	print(
		"STAGE2 etapa=",
		mission2.get_stage() if mission2 != null else -1,
		" curaca=",
		population2.get_dialogue_id(&"npc_curaca") if population2 != null else &""
	)
	world2.queue_free()
	state.clear()
	campaign.clear()
	_clear_campaign(manager)
	await process_frame
	await process_frame
	if ok:
		print("STAGE2_OK")
	else:
		printerr("STAGE2_FAIL")
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


func _wait_ready(world: RegionWorld) -> bool:
	if world == null:
		return false
	for _i: int in SETTLE_FRAMES:
		await process_frame
		var population: CityPopulation = world.get_population()
		if population == null or not population.is_built():
			continue
		var session: CampaignSession = world.get_session()
		if session == null or session.get_mission() == null:
			continue
		return true
	return false


func _clear_campaign(manager: SaveManagerService) -> void:
	for slot: String in manager.list_slots(CAMPAIGN):
		manager.delete_slot(CAMPAIGN, StringName(slot))
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.save_root().path_join(String(CAMPAIGN)))
	)
