extends SceneTree
## Comprueba las obras de defensa (F3.8): fosos construibles y persistentes.
##
## Antes de decidir quedarse no se pueden construir; al construirlos, el foso
## abierto se cubre, el cambio queda en `WorldState.changes` y la carga lo
## conserva. La batalla de Carmenca leerá esos cambios.
## Cada paso lleva etiqueta para que un fallo diga qué se rompió.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const CAMPAIGN: StringName = &"01_pachacutec"
const SETTLE_FRAMES: int = 600
const PLACE_FRAMES: int = 300
const EXPECTED_WORKS: int = 4
const FIRST: StringName = &"defensa_1"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveManagerService.set_save_root("user://test-saves")
	var manager: SaveManagerService = SaveManagerService.instance()
	var state: WorldStateService = WorldStateService.instance()
	var campaign_state: CampaignStateService = CampaignStateService.instance()
	var steps: CheckSteps = CheckSteps.new()
	steps.check("servicios disponibles", manager != null and state != null)
	steps.check("estado de campaña", campaign_state != null)
	if not steps.is_ok():
		steps.report("DEFENSE")
		quit(1)
		return
	_clear_campaign(manager)
	state.clear()
	campaign_state.clear()

	var world: RegionWorld = _spawn()
	steps.check("mundo listo", await _wait_ready(world))
	var session: CampaignSession = world.get_session()
	var works: DefenseWorks = session.get_defense_works() if session != null else null
	steps.check("obras creadas", works != null)
	if not steps.is_ok():
		world.queue_free()
		await process_frame
		steps.report("DEFENSE")
		quit(1)
		return

	var spot: ChangeInteractable = null
	for _i: int in PLACE_FRAMES:
		await process_frame
		spot = works.get_spot(FIRST)
		if spot != null:
			break
	steps.check("foso en el mapa", spot != null)
	steps.check("cuatro obras", works.get_work_count() == EXPECTED_WORKS)
	# Antes de decidir quedarse, el foso existe pero no se puede construir.
	steps.check("no construible antes de quedarse", not spot.is_available())
	steps.check("sin cambio antes", not state.has_change(FIRST))
	steps.check("sin construir antes", not works.is_built(FIRST))

	state.set_flag(&"m01_queda", 1)
	await process_frame
	steps.check("construible tras quedarse", spot.is_available())
	steps.check("texto del foso", spot.get_interaction_text() == tr("PCH_S01_FOSO"))

	# Construir el primero: cambio persistente, geometría cubierta y punto cerrado.
	spot.interact(world.get_player())
	await process_frame
	steps.check("cambio persistente", state.has_change(FIRST))
	steps.check("obra construida", works.is_built(FIRST))
	steps.check("punto cerrado", not spot.is_available())
	steps.check("una obra construida", works.get_built_count() == 1)

	# Guardar y cargar: la obra sigue construida y el resto sigue disponible.
	steps.check("guardado", session.save_auto())
	world.queue_free()
	await process_frame
	state.clear()
	campaign_state.clear()
	steps.check("carga solicitada", manager.request_load(CAMPAIGN, SaveManagerService.AUTO_SLOT))

	var world2: RegionWorld = _spawn()
	steps.check("mundo recargado", await _wait_ready(world2))
	var session2: CampaignSession = world2.get_session()
	var works2: DefenseWorks = session2.get_defense_works() if session2 != null else null
	steps.check("obras recargadas", works2 != null)
	var spot2: ChangeInteractable = null
	for _i: int in PLACE_FRAMES:
		await process_frame
		spot2 = works2.get_spot(FIRST) if works2 != null else null
		if spot2 != null:
			break
	steps.check("foso recargado", spot2 != null)
	steps.check("cambio conservado", WorldStateService.instance().has_change(FIRST))
	steps.check("obra conservada al cargar", works2 != null and works2.is_built(FIRST))
	steps.check("conteo conservado", works2 != null and works2.get_built_count() == 1)
	steps.check("sigue cerrado", spot2 != null and not spot2.is_available())

	# Construir los tres restantes y contar.
	for work: Dictionary in DefenseWorks.WORKS:
		var id: StringName = work["id"]
		var next: ChangeInteractable = works2.get_spot(id) if works2 != null else null
		if next != null and next.is_available():
			next.interact(world2.get_player())
			await process_frame
	steps.check(
		"cuatro obras construidas", works2 != null and works2.get_built_count() == EXPECTED_WORKS
	)
	steps.check("defensa_4 construida", works2 != null and works2.is_built(&"defensa_4"))
	steps.check(
		"cuatro cambios",
		WorldStateService.instance().get_changes().size() == EXPECTED_WORKS
	)

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
	var ok: bool = steps.is_ok()
	steps.report("DEFENSE")
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
		ProjectSettings.globalize_path(SaveManagerService.save_root().path_join(String(CAMPAIGN)))
	)
