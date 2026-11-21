extends SceneTree
## Comprueba la misión principal (F3.5.b): tres etapas, diario y persistencia.
##
## Recorre la etapa 1 con sus banderas, entra en la partida, elige quedarse y
## guarda a mitad de misión; la carga reconstruye etapa y diario.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const CAMPAIGN: StringName = &"01_pachacutec"
const SETTLE_FRAMES: int = 600
const EXPECTED_STAGES: int = 3
const EXPECTED_SPOTS: int = 3


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var manager: SaveManagerService = SaveManagerService.instance()
	var world_state: WorldStateService = WorldStateService.instance()
	var campaign_state: CampaignStateService = CampaignStateService.instance()
	var ok: bool = manager != null and world_state != null and campaign_state != null
	if not ok:
		printerr("MISSION_FAIL sin servicios")
		quit(1)
		return
	_clear_campaign(manager)
	world_state.clear()
	campaign_state.clear()

	var world: RegionWorld = _spawn()
	ok = ok and await _wait_ready(world)
	var mission: MissionController = world.get_session().get_mission()
	var journal: Journal = world.get_journal()
	ok = ok and mission != null and journal != null
	if not ok:
		printerr("MISSION_FAIL sin misión o diario")
		world.queue_free()
		await process_frame
		quit(1)
		return
	ok = ok and mission.get_stage() == 1
	ok = ok and mission.get_stage_count() == EXPECTED_STAGES
	ok = ok and journal.has(&"m01_arrabal") and not journal.is_done(&"m01_arrabal")
	ok = ok and mission.get_spots() != null
	ok = ok and mission.get_spots().get_child_count() == EXPECTED_SPOTS

	# Etapa 1: los tres encargos se completan en el mundo, no por código.
	# Sin el pedido del NPC, el punto no está disponible.
	var water: FlagInteractable = _find_spot(mission, &"m01_agua")
	var wool: FlagInteractable = _find_spot(mission, &"m01_lana")
	var maize: FlagInteractable = _find_spot(mission, &"m01_maiz")
	ok = ok and water != null and wool != null and maize != null
	ok = ok and not water.is_available() and not maize.is_available()
	world_state.set_flag(&"m01_agua_pedido", 1)
	world_state.set_flag(&"m01_lana_pedido", 1)
	ok = ok and water.is_available() and not maize.is_available()
	water.interact(world.get_player())
	wool.interact(world.get_player())
	await process_frame
	ok = ok and world_state.has_flag(&"m01_agua")
	ok = ok and mission.get_stage() == 1
	world_state.set_flag(&"m01_maiz_pedido", 1)
	maize.interact(world.get_player())
	await process_frame
	ok = ok and mission.get_stage() == 2
	ok = ok and journal.is_done(&"m01_arrabal") and journal.has(&"m01_partida")
	ok = ok and mission.has_departure()
	ok = ok and world.get_player_hud().is_showing_subtitle()
	var talk: NpcInteractable = _find_curaca(world)
	ok = ok and talk != null and talk.definition.dialogue_id == &"m01_curaca_partida"

	# Etapa 2: la curáca ofrece quedarse y el jugador acepta.
	var presenter: DialoguePresenter = world.get_dialogue()
	ok = ok and presenter.start(&"m01_curaca_partida", null)
	await process_frame
	ok = ok and presenter.is_active()
	world.get_player_hud().dialogue_choice.emit(0)
	await process_frame
	world.get_player_hud().dialogue_advanced.emit()
	await process_frame
	ok = ok and world_state.get_flag(&"m01_queda") == 1
	ok = ok and mission.get_stage() == 3
	ok = ok and world_state.get_phase() == &"guerra"
	ok = ok and journal.is_done(&"m01_partida") and journal.has(&"m01_carmenca")

	# Guardar a mitad de la etapa 3 y cargar en otra instancia del mundo.
	ok = ok and world.get_session().save_auto()
	world.queue_free()
	await process_frame
	world_state.clear()
	campaign_state.clear()
	var requested: bool = manager.request_load(CAMPAIGN, SaveManagerService.AUTO_SLOT)
	ok = ok and requested

	var world2: RegionWorld = _spawn()
	ok = ok and await _wait_ready(world2)
	var mission2: MissionController = world2.get_session().get_mission()
	var journal2: Journal = world2.get_journal()
	ok = ok and mission2 != null and journal2 != null
	ok = ok and mission2.get_stage() == 3
	ok = ok and journal2.is_done(&"m01_arrabal") and journal2.is_done(&"m01_partida")
	ok = ok and journal2.has(&"m01_carmenca") and not journal2.is_done(&"m01_carmenca")
	ok = ok and WorldStateService.instance().get_phase() == &"guerra"

	# La etapa 3 la cierra la batalla (3.9) con su bandera.
	WorldStateService.instance().set_flag(&"m01_victoria", 1)
	await process_frame
	ok = ok and journal2.is_done(&"m01_carmenca")

	print(
		"MISSION stage=",
		mission2.get_stage(),
		" stage_count=",
		mission2.get_stage_count(),
		" journal=",
		journal2.count(),
		" phase=",
		WorldStateService.instance().get_phase()
	)
	world2.queue_free()
	WorldStateService.instance().clear()
	campaign_state.clear()
	_clear_campaign(manager)
	await process_frame
	await process_frame
	if ok:
		print("MISSION_OK")
	else:
		printerr("MISSION_FAIL")
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


func _find_spot(mission: MissionController, flag: StringName) -> FlagInteractable:
	if mission.get_spots() == null:
		return null
	for node: Node in mission.get_spots().find_children("*", "FlagInteractable", true, false):
		var spot: FlagInteractable = node as FlagInteractable
		if spot.flag == flag:
			return spot
	return null


func _find_curaca(world: RegionWorld) -> NpcInteractable:
	for node: Node in world.find_children("*", "NpcInteractable", true, false):
		var talk: NpcInteractable = node as NpcInteractable
		if talk.definition != null and talk.definition.id == &"npc_curaca":
			return talk
	return null


func _clear_campaign(manager: SaveManagerService) -> void:
	for slot: String in manager.list_slots(CAMPAIGN):
		manager.delete_slot(CAMPAIGN, StringName(slot))
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.SAVE_DIR.path_join(String(CAMPAIGN)))
	)
