extends SceneTree
## Comprueba que al cargar en la etapa 2 la curáca conserva la conversación de
## la partida y que `m01_queda` se puede fijar de verdad.
##
## La población se construye después de `MissionController._restore()`: el
## cambio de conversación debe reintentarse cuando la población termina.
## Cada paso lleva etiqueta para que un fallo diga qué se rompió.

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
	var steps: CheckSteps = CheckSteps.new()
	steps.check("servicios de guardado y mundo", manager != null and state != null)
	steps.check("estado de campaña", campaign != null)
	if not steps.is_ok():
		steps.report("STAGE2")
		quit(1)
		return
	_clear_campaign(manager)
	state.clear()
	campaign.clear()

	var world: RegionWorld = _spawn()
	steps.check("mundo listo", await _wait_ready(world))
	var session: CampaignSession = world.get_session() if world != null else null
	var mission: MissionController = session.get_mission() if session != null else null
	var population: CityPopulation = world.get_population() if world != null else null
	steps.check("misión y población", mission != null and population != null)
	if not steps.is_ok():
		steps.report("STAGE2")
		quit(1)
		return

	# Etapa 1 con sus tres banderas; la misión entra en la etapa 2 en vivo.
	state.set_flag(&"m01_agua", 1)
	state.set_flag(&"m01_lana", 1)
	state.set_flag(&"m01_maiz", 1)
	await process_frame
	steps.check("etapa 2 en vivo", mission.get_stage() == 2)
	steps.check(
		"curáca ofrece la partida",
		await _wait_until(
			func() -> bool:
				return population.get_dialogue_id(&"npc_curaca") == &"m01_curaca_partida",
			2.0
		)
	)
	steps.check("guardado en la etapa 2", session.save_auto())

	# Cargar como si se hubiera cerrado el juego.
	world.queue_free()
	await process_frame
	state.clear()
	campaign.clear()
	steps.check("carga solicitada", manager.request_load(CAMPAIGN, SaveManagerService.AUTO_SLOT))

	var world2: RegionWorld = _spawn()
	steps.check("mundo recargado", await _wait_ready(world2))
	var session2: CampaignSession = world2.get_session() if world2 != null else null
	var mission2: MissionController = session2.get_mission() if session2 != null else null
	var population2: CityPopulation = world2.get_population() if world2 != null else null
	steps.check("sesión restaurada", session2 != null and session2.is_restored())
	steps.check("etapa 2 al cargar", mission2 != null and mission2.get_stage() == 2)
	# El fallo original: la curáca volvía a `m01_curaca` y `m01_queda` no podía
	# fijarse, bloqueando la misión.
	steps.check("población recargada", population2 != null)
	if population2 != null:
		steps.check(
			"curáca conserva la partida",
			await _wait_until(
				func() -> bool:
					return population2.get_dialogue_id(&"npc_curaca") == &"m01_curaca_partida",
				2.0
			)
		)

	# Se fija `m01_queda` de verdad: se recorre el grafo de la curáca y se elige
	# «quedarse». Antes solo se comprobaba el identificador del diálogo.
	var dialogue: DialoguePresenter = world2.get_dialogue() if world2 != null else null
	steps.check(
		"grafo de la partida registrado",
		dialogue != null and dialogue.has_graph(&"m01_curaca_partida")
	)
	if dialogue != null:
		steps.check("diálogo iniciado", dialogue.start(&"m01_curaca_partida"))
		steps.check("elección de quedarse", dialogue.runner.choose(0))
		await _wait_seconds(0.2)
		steps.check("bandera m01_queda", state.get_flag(&"m01_queda") == 1)
		steps.check(
			"etapa 3 tras quedarse",
			await _wait_until(func() -> bool: return mission2.get_stage() == 3, 2.0)
		)
		dialogue.runner.advance()

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
	var ok: bool = steps.is_ok()
	steps.report("STAGE2")
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
		# Los grafos se registran en el `setup` del presentador: la prueba los
		# necesita para recorrer la conversación de la curáca.
		var dialogue: DialoguePresenter = world.get_dialogue()
		if dialogue == null or not dialogue.has_graph(&"m01_curaca_partida"):
			continue
		return true
	return false


func _wait_until(condition: Callable, seconds: float) -> bool:
	var deadline: float = float(Time.get_ticks_msec()) + seconds * 1000.0
	while float(Time.get_ticks_msec()) < deadline:
		if condition.call():
			return true
		await process_frame
	return condition.call()


func _wait_seconds(seconds: float) -> void:
	await create_timer(seconds).timeout


func _clear_campaign(manager: SaveManagerService) -> void:
	for slot: String in manager.list_slots(CAMPAIGN):
		manager.delete_slot(CAMPAIGN, StringName(slot))
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.save_root().path_join(String(CAMPAIGN)))
	)
