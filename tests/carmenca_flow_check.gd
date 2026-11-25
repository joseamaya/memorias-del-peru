extends SceneTree
## Cierra la batalla de Carmenca sin que el jugador golpee: los aliados deben
## resolver las tres oleadas alrededor de las tiendas.
##
## `carmenca_check` mata a los chancas por código, así que no ve los atascos de
## movimiento. Este recorrido deja al jugador quieto y con salud alta, juega la
## batalla completa con dos obras (2, 4 y 6 chancas) y exige cerrar las tres
## oleadas en un tiempo acotado. También comprueba que los aliados ya no se apilan.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const CAMPAIGN: StringName = &"01_pachacutec"
const SETTLE_FRAMES: int = 600
const CAMP: Vector3 = Vector3(787.0, 0.0, 307.0)
const BUILT_WORKS: int = 2
const ALLIES: int = 6
const MAX_SECONDS: float = 90.0
const SETTLE_ALLIES_SECONDS: float = 10.0
const MIN_ALLY_GAP: float = 0.9
const WAVE_SIZES: Array[int] = [2, 4, 6]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveManagerService.set_save_root("user://test-saves")
	var manager: SaveManagerService = SaveManagerService.instance()
	var state: WorldStateService = WorldStateService.instance()
	var campaign: CampaignStateService = CampaignStateService.instance()
	var steps: CheckSteps = CheckSteps.new()
	steps.check("servicios disponibles", state != null and campaign != null and manager != null)
	if not steps.is_ok():
		steps.report("CARMENCA_FLOW")
		quit(1)
		return
	_clear_campaign(manager)
	state.clear()
	campaign.clear()
	var world: RegionWorld = _spawn()
	steps.check("mundo instanciado", world != null)
	if world == null:
		steps.report("CARMENCA_FLOW")
		quit(1)
		return
	steps.check("mundo listo", await _wait_ready(world))
	if not steps.is_ok():
		world.queue_free()
		await process_frame
		steps.report("CARMENCA_FLOW")
		quit(1)
		return
	var session: CampaignSession = world.get_session()
	var battle: CarmencaBattle = session.get_battle() if session != null else null
	var works: DefenseWorks = session.get_defense_works() if session != null else null
	var combat: PlayerCombat = world.get_player_combat()
	var player: PlayerFPS = world.get_player()
	var region: CampaignRegion = world.get_region()
	steps.check("batalla, obras, combate y jugador", battle != null and works != null)
	steps.check("combate y región", combat != null and player != null and region != null)
	if not steps.is_ok():
		world.queue_free()
		await process_frame
		steps.report("CARMENCA_FLOW")
		quit(1)
		return

	# Etapa 3 y dos obras: la oleada final queda en seis chancas.
	state.set_flag(&"m01_agua", 1)
	state.set_flag(&"m01_lana", 1)
	state.set_flag(&"m01_maiz", 1)
	await _wait_seconds(0.2)
	state.set_flag(&"m01_queda", 1)
	await _wait_seconds(0.2)
	steps.check("etapa 3", state.get_flag(&"m01_etapa") == 3)
	for id: StringName in [&"defensa_1", &"defensa_2"]:
		var spot: ChangeInteractable = works.get_spot(id)
		if spot != null and spot.is_available():
			spot.interact(player)
		await process_frame
	steps.check("dos obras construidas", works.get_built_count() == BUILT_WORKS)
	if not steps.is_ok():
		world.queue_free()
		await process_frame
		steps.report("CARMENCA_FLOW")
		quit(1)
		return

	# El jugador no ataca ni muere: la oleada debe caer por los aliados.
	if combat.character != null:
		combat.character.max_health = 100000.0
		combat.character.health = 100000.0
	# A 8 m del estandarte: dentro del radio de activación (30 m) pero fuera
	# del radio de victoria (3,5 m), para poder observar STANDARD sin cerrar.
	var point: Vector3 = CAMP + Vector3(8.0, 0.0, 0.0)
	player.global_position = Vector3(point.x, region.height_at(point.x, point.z) + 0.3, point.z)
	battle.force_start()
	steps.check("batalla activa", battle.is_active())
	steps.check("seis aliados", battle.get_ally_count() == ALLIES)
	if not steps.is_ok():
		world.queue_free()
		await process_frame
		steps.report("CARMENCA_FLOW")
		quit(1)
		return

	var started_ms: int = Time.get_ticks_msec()
	var seen: Array[int] = [0, 0, 0, 0]
	var cleared: bool = false
	var deadline: float = float(Time.get_ticks_msec()) + MAX_SECONDS * 1000.0
	while float(Time.get_ticks_msec()) < deadline:
		var wave: int = battle.get_wave()
		var alive: int = battle.get_enemy_count()
		if wave > 0 and wave < seen.size() and alive > seen[wave]:
			seen[wave] = alive
		if battle.get_state() == CarmencaBattle.State.STANDARD:
			cleared = true
			break
		await create_timer(0.1).timeout
	var elapsed: float = float(Time.get_ticks_msec() - started_ms) / 1000.0
	steps.check("tres oleadas cerradas", cleared)
	steps.check("oleada 1 con dos chancas", seen[1] == WAVE_SIZES[0])
	steps.check("oleada 2 con cuatro chancas", seen[2] == WAVE_SIZES[1])
	steps.check("oleada 3 con seis chancas", seen[3] == WAVE_SIZES[2])
	var spread_started_ms: int = Time.get_ticks_msec()
	var spread: bool = await _wait_until(_allies_spread, SETTLE_ALLIES_SECONDS)
	var settle_seconds: float = float(Time.get_ticks_msec() - spread_started_ms) / 1000.0
	steps.check("aliados sin apilarse", spread)
	print(
		"CARMENCA_FLOW cerrada=",
		cleared,
		" segundos=%.1f" % elapsed,
		" asentados=%.1f" % settle_seconds,
		" oleadas=",
		seen,
		" enemigos=",
		battle.get_enemy_count(),
		" aliados=",
		battle.get_ally_count()
	)
	world.queue_free()
	state.clear()
	campaign.clear()
	_clear_campaign(manager)
	await process_frame
	await process_frame
	var ok: bool = steps.is_ok()
	steps.report("CARMENCA_FLOW")
	quit(0 if ok else 1)


func _allies_spread() -> bool:
	var positions: Array[Vector3] = []
	for node: Node in get_nodes_in_group(&"allied_warrior"):
		var ally: AlliedWarrior = node as AlliedWarrior
		if ally != null:
			positions.append(ally.global_position)
	if positions.size() != ALLIES:
		return false
	for first: int in positions.size():
		for second: int in range(first + 1, positions.size()):
			var gap: float = (
				Vector2(
					positions[first].x - positions[second].x,
					positions[first].z - positions[second].z
				)
				. length()
			)
			if gap < MIN_ALLY_GAP:
				return false
	return true


func _spawn() -> RegionWorld:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		return null
	var world: RegionWorld = packed.instantiate() as RegionWorld
	if world == null:
		return null
	root.add_child(world)
	return world


func _clear_campaign(manager: SaveManagerService) -> void:
	for slot: String in manager.list_slots(CAMPAIGN):
		manager.delete_slot(CAMPAIGN, StringName(slot))
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.save_root().path_join(String(CAMPAIGN)))
	)


func _wait_until(condition: Callable, seconds: float) -> bool:
	var deadline: float = float(Time.get_ticks_msec()) + seconds * 1000.0
	while float(Time.get_ticks_msec()) < deadline:
		if condition.call():
			return true
		await create_timer(0.1).timeout
	return condition.call()


func _wait_seconds(seconds: float) -> void:
	await create_timer(seconds).timeout


func _wait_ready(world: RegionWorld) -> bool:
	if world == null:
		return false
	for _i: int in SETTLE_FRAMES:
		await process_frame
		var population: CityPopulation = world.get_population()
		if population == null or not population.is_built():
			continue
		var session: CampaignSession = world.get_session()
		if session == null or session.get_battle() == null:
			continue
		return true
	return false
