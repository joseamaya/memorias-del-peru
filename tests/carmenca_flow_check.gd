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
const ALLIES: int = AlliedFormation.SLOT_COUNT
const MAX_SECONDS: float = 90.0
## Tras la última oleada se deja asentar el grupo y se muestrea un rato: una
## separación de un solo fotograma no vale.
const POST_BATTLE_SECONDS: float = 10.0
const STILL_SAMPLE_SECONDS: float = 3.0
const MAX_ALLY_DRIFT: float = 0.35
const MIN_ALLY_GAP: float = 0.9
const TENT_MARGIN: float = 0.1
## Gracia antes de exigir que la oleada haya roto la formación y avanzado.
const IDLE_GRACE_SECONDS: float = 1.5
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
	# A 4 m al oeste de la tienda 7 y mirando al campamento: la tienda queda a la
	# espalda y ocupa los seis huecos de formación. Es el caso que hacía temblar
	# a los aliados. Sigue fuera del radio de victoria (3,5 m).
	var tents: Array[CampLayout.Tent] = CampLayout.tents(CAMP)
	var tent: CampLayout.Tent = tents[7]
	var point: Vector3 = tent.center + Vector3(-4.0, 0.0, 0.0)
	player.global_position = Vector3(point.x, region.height_at(point.x, point.z) + 0.3, point.z)
	player.rotation.y = PI * 0.5
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
	var combat_gap: float = INF
	var combat_separated: bool = true
	var idle_found: bool = false
	var wave_since: Dictionary = {}
	var deadline: float = float(Time.get_ticks_msec()) + MAX_SECONDS * 1000.0
	while float(Time.get_ticks_msec()) < deadline:
		var wave: int = battle.get_wave()
		var alive: int = battle.get_enemy_count()
		if wave > 0 and wave < seen.size() and alive > seen[wave]:
			seen[wave] = alive
		if wave > 0 and not wave_since.has(wave):
			wave_since[wave] = Time.get_ticks_msec()
		elif wave > 0 and not idle_found:
			var since: int = wave_since[wave]
			var wave_elapsed: float = float(Time.get_ticks_msec() - since) / 1000.0
			if wave_elapsed >= IDLE_GRACE_SECONDS and _idle_enemy_count() > 0:
				idle_found = true
		combat_gap = minf(combat_gap, _min_ally_gap())
		if combat_gap < MIN_ALLY_GAP:
			combat_separated = false
		if battle.get_state() == CarmencaBattle.State.STANDARD:
			cleared = true
			break
		await create_timer(0.1).timeout
	var elapsed: float = float(Time.get_ticks_msec() - started_ms) / 1000.0
	steps.check("tres oleadas cerradas", cleared)
	steps.check("oleada 1 con dos chancas", seen[1] == WAVE_SIZES[0])
	steps.check("oleada 2 con cuatro chancas", seen[2] == WAVE_SIZES[1])
	steps.check("oleada 3 con seis chancas", seen[3] == WAVE_SIZES[2])
	steps.check("ningún chanca espera fuera de alcance", not idle_found)
	steps.check("aliados separados en combate", combat_separated)
	if cleared:
		await create_timer(POST_BATTLE_SECONDS).timeout
		var before: Array[Vector3] = _ally_positions()
		var settled: bool = true
		var separated: bool = true
		var outside: bool = true
		var drift: float = 0.0
		var sample_deadline: float = float(Time.get_ticks_msec()) + STILL_SAMPLE_SECONDS * 1000.0
		while float(Time.get_ticks_msec()) < sample_deadline:
			var positions: Array[Vector3] = _ally_positions()
			if positions.size() != ALLIES:
				settled = false
				break
			for index: int in positions.size():
				drift = maxf(drift, _flat_distance(before[index], positions[index]))
			if drift > MAX_ALLY_DRIFT:
				settled = false
			if _min_gap(positions) < MIN_ALLY_GAP:
				separated = false
			for position: Vector3 in positions:
				if not CampAvoidance.is_clear(position, tents, TENT_MARGIN):
					outside = false
			await create_timer(0.1).timeout
		steps.check("aliados quietos tras la batalla", settled)
		steps.check("aliados separados tras la batalla", separated)
		steps.check("aliados fuera de las tiendas", outside)
	print(
		"CARMENCA_FLOW cerrada=",
		cleared,
		" segundos=%.1f" % elapsed,
		" hueco_min=%.2f" % combat_gap,
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


func _ally_positions() -> Array[Vector3]:
	var positions: Array[Vector3] = []
	for node: Node in get_nodes_in_group(&"allied_warrior"):
		var ally: AlliedWarrior = node as AlliedWarrior
		if ally != null:
			positions.append(ally.global_position)
	return positions


func _min_ally_gap() -> float:
	return _min_gap(_ally_positions())


func _min_gap(positions: Array[Vector3]) -> float:
	var gap: float = INF
	for first: int in positions.size():
		for second: int in range(first + 1, positions.size()):
			gap = minf(gap, _flat_distance(positions[first], positions[second]))
	return gap


func _idle_enemy_count() -> int:
	var count: int = 0
	for node: Node in get_nodes_in_group(&"chanca_warrior"):
		var warrior: ChancaWarrior = node as ChancaWarrior
		if warrior == null or warrior.is_dead() or warrior.combatant == null:
			continue
		if warrior.combatant.intent == EnemyCombatant.Intent.IDLE:
			count += 1
	return count


func _flat_distance(first: Vector3, second: Vector3) -> float:
	return Vector2(first.x - second.x, first.z - second.z).length()


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
