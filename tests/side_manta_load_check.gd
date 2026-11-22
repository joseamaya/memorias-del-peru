extends SceneTree
## Al cargar con la lana entregada pero la manta aún no aceptada, la tejedora
## debe volver a ofrecerla. Antes el encargo desaparecía y la batalla perdía la
## reducción de daño.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const CAMPAIGN: StringName = &"01_pachacutec"
const SETTLE_FRAMES: int = 600
const MANTA_QUEST: StringName = &"s01_manta_encargo"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveManagerService.set_save_root("user://test-saves")
	var manager: SaveManagerService = SaveManagerService.instance()
	var state: WorldStateService = WorldStateService.instance()
	var campaign: CampaignStateService = CampaignStateService.instance()
	var ok: bool = manager != null and state != null and campaign != null
	if not ok:
		printerr("MANTA_LOAD_FAIL sin servicios")
		quit(1)
		return
	_clear_campaign(manager)
	state.clear()
	campaign.clear()

	var world: RegionWorld = _spawn()
	ok = ok and await _wait_ready(world)
	var session: CampaignSession = world.get_session() if world != null else null
	var population: CityPopulation = world.get_population() if world != null else null
	var journal: Journal = world.get_journal() if world != null else null
	var side: SideActivities = session.get_side_activities() if session != null else null
	ok = ok and session != null and population != null and journal != null and side != null
	if not ok:
		printerr("MANTA_LOAD_FAIL sin mundo, población o diario")
		quit(1)
		return

	# Lana entregada: la tejedora ofrece la manta, pero no se acepta.
	state.set_flag(&"m01_lana", 1)
	await process_frame
	ok = ok and population.get_dialogue_id(&"npc_tejedora") == &"s01_manta"
	ok = ok and journal.has(MANTA_QUEST) and not journal.is_done(MANTA_QUEST)
	ok = ok and side.get_loom_spot() != null and not side.get_loom_spot().is_available()
	ok = ok and session.save_auto()

	world.queue_free()
	await process_frame
	state.clear()
	campaign.clear()
	ok = ok and manager.request_load(CAMPAIGN, SaveManagerService.AUTO_SLOT)

	var world2: RegionWorld = _spawn()
	ok = ok and await _wait_ready(world2)
	var session2: CampaignSession = world2.get_session() if world2 != null else null
	var population2: CityPopulation = world2.get_population() if world2 != null else null
	var journal2: Journal = world2.get_journal() if world2 != null else null
	var side2: SideActivities = session2.get_side_activities() if session2 != null else null
	ok = ok and population2 != null and journal2 != null and side2 != null
	if population2 != null:
		ok = ok and population2.get_dialogue_id(&"npc_tejedora") == &"s01_manta"
	if journal2 != null:
		ok = ok and journal2.has(MANTA_QUEST) and not journal2.is_done(MANTA_QUEST)
	if side2 != null:
		ok = ok and side2.get_loom_spot() != null and not side2.get_loom_spot().is_available()

	print(
		"MANTA_LOAD tejedora=",
		population2.get_dialogue_id(&"npc_tejedora") if population2 != null else &"",
		" encargo=",
		journal2.has(MANTA_QUEST) if journal2 != null else false
	)
	world2.queue_free()
	state.clear()
	campaign.clear()
	_clear_campaign(manager)
	await process_frame
	await process_frame
	if ok:
		print("MANTA_LOAD_OK")
	else:
		printerr("MANTA_LOAD_FAIL")
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
		if session == null or session.get_side_activities() == null:
			continue
		var side: SideActivities = session.get_side_activities()
		if side.get_loom_spot() == null:
			continue
		return true
	return false


func _clear_campaign(manager: SaveManagerService) -> void:
	for slot: String in manager.list_slots(CAMPAIGN):
		manager.delete_slot(CAMPAIGN, StringName(slot))
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.save_root().path_join(String(CAMPAIGN)))
	)
