extends SceneTree
## Comprueba las actividades secundarias (F3.6): el turno del agua y la manta.
##
## Recorre las dos cadenas con sus banderas, comprueba que el telar no responde
## sin encargo, que el diario guarda la decisión y que todo sobrevive a la carga.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const CAMPAIGN: StringName = &"01_pachacutec"
const SETTLE_FRAMES: int = 600
const LOOM_FRAMES: int = 300
const AGUA_QUEST: StringName = &"s01_agua_encargo"
const MANTA_QUEST: StringName = &"s01_manta_encargo"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var manager: SaveManagerService = SaveManagerService.instance()
	var state: WorldStateService = WorldStateService.instance()
	var campaign_state: CampaignStateService = CampaignStateService.instance()
	var ok: bool = manager != null and state != null and campaign_state != null
	if not ok:
		printerr("SIDE_FAIL sin servicios")
		quit(1)
		return
	_clear_campaign(manager)
	state.clear()
	campaign_state.clear()

	var world: RegionWorld = _spawn()
	ok = ok and await _wait_ready(world)
	var session: CampaignSession = world.get_session()
	var side: SideActivities = session.get_side_activities() if session != null else null
	var journal: Journal = world.get_journal()
	var population: CityPopulation = world.get_population()
	var presenter: DialoguePresenter = world.get_dialogue()
	var hud: PlayerHud = world.get_player_hud()
	ok = ok and side != null and journal != null and population != null
	ok = ok and presenter != null and hud != null
	if not ok:
		printerr("SIDE_FAIL sin actividades, diario, población o diálogo")
		world.queue_free()
		await process_frame
		quit(1)
		return

	var loom: FlagInteractable = null
	for _i: int in LOOM_FRAMES:
		await process_frame
		loom = side.get_loom_spot()
		if loom != null:
			break
	ok = ok and loom != null
	ok = ok and population.get_dialogue_id(&"npc_molendera") == &"m01_molendera"
	ok = ok and not loom.is_available()

	# El agua: la molendera plantea el reparto cuando ya tiene la suya.
	state.set_flag(&"m01_agua", 1)
	await process_frame
	ok = ok and population.get_dialogue_id(&"npc_molendera") == &"s01_agua"
	ok = ok and journal.has(AGUA_QUEST) and not journal.is_done(AGUA_QUEST)
	ok = ok and presenter.start(&"s01_agua", null)
	await process_frame
	ok = ok and hud.get_dialogue_panel().get_choice_count() == 4
	# Tercera opción: repartir por turnos.
	hud.dialogue_choice.emit(2)
	await process_frame
	ok = ok and state.get_flag(&"s01_agua") == 1
	ok = ok and state.get_flag(&"s01_agua_turnos") == 1
	ok = ok and state.get_flag(&"rep_molendera") == 1
	ok = ok and state.get_flag(&"rep_chacra") == 1
	ok = ok and journal.is_done(AGUA_QUEST)
	ok = ok and journal.has(&"s01_agua_mem_turnos")
	ok = ok and population.get_dialogue_id(&"npc_molendera") == &"s01_agua_eco"
	ok = ok and population.get_dialogue_id(&"npc_agricultor") == &"s01_agua_eco_agricultor"
	hud.dialogue_advanced.emit()
	await process_frame
	ok = ok and not presenter.is_active()

	# La manta: la tejedora la ofrece cuando ya tiene la lana.
	state.set_flag(&"m01_lana", 1)
	await process_frame
	ok = ok and population.get_dialogue_id(&"npc_tejedora") == &"s01_manta"
	ok = ok and journal.has(MANTA_QUEST) and not journal.is_done(MANTA_QUEST)
	ok = ok and not loom.is_available()
	ok = ok and presenter.start(&"s01_manta", null)
	await process_frame
	ok = ok and hud.get_dialogue_panel().get_choice_count() == 2
	hud.dialogue_choice.emit(0)
	await process_frame
	ok = ok and state.has_flag(&"s01_manta_pedido")
	ok = ok and loom.is_available()
	hud.dialogue_advanced.emit()
	await process_frame

	# El telar teje la manta y se ve colgada.
	loom.interact(world.get_player())
	await process_frame
	ok = ok and state.has_flag(&"s01_manta")
	ok = ok and journal.is_done(MANTA_QUEST)
	ok = ok and population.get_dialogue_id(&"npc_tejedora") == &"s01_manta_lista"
	ok = ok and side.has_manta_visible()
	ok = ok and not loom.is_available()

	# Guardar y cargar en una instancia nueva.
	ok = ok and session.save_auto()
	world.queue_free()
	await process_frame
	state.clear()
	campaign_state.clear()
	ok = ok and manager.request_load(CAMPAIGN, SaveManagerService.AUTO_SLOT)

	var world2: RegionWorld = _spawn()
	ok = ok and await _wait_ready(world2)
	var session2: CampaignSession = world2.get_session()
	var side2: SideActivities = session2.get_side_activities() if session2 != null else null
	var journal2: Journal = world2.get_journal()
	var population2: CityPopulation = world2.get_population()
	ok = ok and side2 != null and journal2 != null and population2 != null
	ok = ok and journal2.is_done(AGUA_QUEST) and journal2.has(&"s01_agua_mem_turnos")
	ok = ok and journal2.is_done(MANTA_QUEST)
	ok = ok and population2.get_dialogue_id(&"npc_molendera") == &"s01_agua_eco"
	ok = ok and population2.get_dialogue_id(&"npc_agricultor") == &"s01_agua_eco_agricultor"
	ok = ok and population2.get_dialogue_id(&"npc_tejedora") == &"s01_manta_lista"
	ok = ok and side2.has_manta_visible()
	ok = ok and WorldStateService.instance().get_flag(&"s01_agua_turnos") == 1

	print(
		"SIDE agua=",
		WorldStateService.instance().get_flag(&"s01_agua"),
		" manta=",
		WorldStateService.instance().get_flag(&"s01_manta"),
		" diario=",
		journal2.count(),
		" telar=",
		side2.get_loom_spot() != null
	)
	world2.queue_free()
	WorldStateService.instance().clear()
	campaign_state.clear()
	_clear_campaign(manager)
	await process_frame
	await process_frame
	if ok:
		print("SIDE_OK")
	else:
		printerr("SIDE_FAIL")
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
		if session.get_side_activities() == null:
			continue
		return true
	return false


func _clear_campaign(manager: SaveManagerService) -> void:
	for slot: String in manager.list_slots(CAMPAIGN):
		manager.delete_slot(CAMPAIGN, StringName(slot))
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.SAVE_DIR.path_join(String(CAMPAIGN)))
	)
