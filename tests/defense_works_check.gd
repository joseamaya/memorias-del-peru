extends SceneTree
## Comprueba las obras de defensa (F3.8): fosos construibles y persistentes.
##
## Antes de decidir quedarse no se pueden construir; al construirlos, el foso
## abierto se cubre, el cambio queda en `WorldState.changes` y la carga lo
## conserva. La batalla de Carmenca leerá esos cambios.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const CAMPAIGN: StringName = &"01_pachacutec"
const SETTLE_FRAMES: int = 600
const PLACE_FRAMES: int = 300
const EXPECTED_WORKS: int = 4
const FIRST: StringName = &"defensa_1"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var manager: SaveManagerService = SaveManagerService.instance()
	var state: WorldStateService = WorldStateService.instance()
	var campaign_state: CampaignStateService = CampaignStateService.instance()
	var ok: bool = manager != null and state != null and campaign_state != null
	if not ok:
		printerr("DEFENSE_FAIL sin servicios")
		quit(1)
		return
	_clear_campaign(manager)
	state.clear()
	campaign_state.clear()

	var world: RegionWorld = _spawn()
	ok = ok and await _wait_ready(world)
	var session: CampaignSession = world.get_session()
	var works: DefenseWorks = session.get_defense_works() if session != null else null
	ok = ok and works != null
	if not ok:
		printerr("DEFENSE_FAIL sin obras")
		world.queue_free()
		await process_frame
		quit(1)
		return

	var spot: ChangeInteractable = null
	for _i: int in PLACE_FRAMES:
		await process_frame
		spot = works.get_spot(FIRST)
		if spot != null:
			break
	ok = ok and spot != null
	ok = ok and works.get_work_count() == EXPECTED_WORKS
	# Antes de decidir quedarse, el foso existe pero no se puede construir.
	ok = ok and not spot.is_available()
	ok = ok and not state.has_change(FIRST)
	ok = ok and not works.is_built(FIRST)

	state.set_flag(&"m01_queda", 1)
	await process_frame
	ok = ok and spot.is_available()
	ok = ok and spot.get_interaction_text() == tr("PCH_S01_FOSO")

	# Construir el primero: cambio persistente, geometría cubierta y punto cerrado.
	spot.interact(world.get_player())
	await process_frame
	ok = ok and state.has_change(FIRST)
	ok = ok and works.is_built(FIRST)
	ok = ok and not spot.is_available()
	ok = ok and works.get_built_count() == 1

	# Guardar y cargar: la obra sigue construida y el resto sigue disponible.
	ok = ok and session.save_auto()
	world.queue_free()
	await process_frame
	state.clear()
	campaign_state.clear()
	ok = ok and manager.request_load(CAMPAIGN, SaveManagerService.AUTO_SLOT)

	var world2: RegionWorld = _spawn()
	ok = ok and await _wait_ready(world2)
	var session2: CampaignSession = world2.get_session()
	var works2: DefenseWorks = session2.get_defense_works() if session2 != null else null
	ok = ok and works2 != null
	var spot2: ChangeInteractable = null
	for _i: int in PLACE_FRAMES:
		await process_frame
		spot2 = works2.get_spot(FIRST) if works2 != null else null
		if spot2 != null:
			break
	ok = ok and spot2 != null
	ok = ok and WorldStateService.instance().has_change(FIRST)
	ok = ok and works2.is_built(FIRST)
	ok = ok and works2.get_built_count() == 1
	ok = ok and not spot2.is_available()

	# Construir los tres restantes y contar.
	for work: Dictionary in DefenseWorks.WORKS:
		var id: StringName = work["id"]
		var next: ChangeInteractable = works2.get_spot(id)
		if next != null and next.is_available():
			next.interact(world2.get_player())
			await process_frame
	ok = ok and works2.get_built_count() == EXPECTED_WORKS
	ok = ok and works2.is_built(&"defensa_4")
	ok = ok and WorldStateService.instance().get_changes().size() == EXPECTED_WORKS

	print(
		"DEFENSE obras=",
		works2.get_work_count(),
		" construidas=",
		works2.get_built_count(),
		" cambios=",
		WorldStateService.instance().get_changes().size()
	)
	world2.queue_free()
	WorldStateService.instance().clear()
	campaign_state.clear()
	_clear_campaign(manager)
	await process_frame
	await process_frame
	if ok:
		print("DEFENSE_OK")
	else:
		printerr("DEFENSE_FAIL")
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
		if session == null or session.get_defense_works() == null:
			continue
		return true
	return false


func _clear_campaign(manager: SaveManagerService) -> void:
	for slot: String in manager.list_slots(CAMPAIGN):
		manager.delete_slot(CAMPAIGN, StringName(slot))
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.SAVE_DIR.path_join(String(CAMPAIGN)))
	)
