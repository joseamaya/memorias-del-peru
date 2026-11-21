extends SceneTree
## Comprueba la batalla de Carmenca (F3.9.b): oleadas, aliados, estandarte,
## derrota que reinicia la oleada y cierre de la misión.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const SETTLE_FRAMES: int = 600
const CAMP: Vector3 = Vector3(765.0, 0.0, 295.0)
const BUILT_WORKS: int = 2
const ALLIES: int = 6
const WAVE_SIZES: Array[int] = [2, 4, 6]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var state: WorldStateService = WorldStateService.instance()
	var campaign: CampaignStateService = CampaignStateService.instance()
	var ok: bool = state != null and campaign != null
	if not ok:
		printerr("CARMENCA_FAIL sin servicios")
		quit(1)
		return
	state.clear()
	campaign.clear()
	var world: RegionWorld = (load(SCENE_PATH) as PackedScene).instantiate() as RegionWorld
	root.add_child(world)
	ok = ok and await _wait_ready(world)
	var session: CampaignSession = world.get_session()
	var battle: CarmencaBattle = session.get_battle() if session != null else null
	var works: DefenseWorks = session.get_defense_works() if session != null else null
	var combat: PlayerCombat = world.get_player_combat()
	var player: PlayerFPS = world.get_player()
	var region: CampaignRegion = world.get_region()
	var journal: Journal = world.get_journal()
	ok = ok and battle != null and works != null and combat != null
	ok = ok and player != null and region != null and journal != null
	if not ok:
		printerr("CARMENCA_FAIL sin batalla, obras, combate o diario")
		world.queue_free()
		await process_frame
		quit(1)
		return

	# Etapa 3 de la misión y dos obras construidas.
	state.set_flag(&"m01_agua", 1)
	state.set_flag(&"m01_lana", 1)
	state.set_flag(&"m01_maiz", 1)
	await _wait_seconds(0.2)
	state.set_flag(&"m01_queda", 1)
	await _wait_seconds(0.2)
	ok = ok and state.get_flag(&"m01_etapa") == 3
	ok = ok and journal.has(&"m01_carmenca")
	for id: StringName in [&"defensa_1", &"defensa_2"]:
		var spot: ChangeInteractable = works.get_spot(id)
		if spot != null and spot.is_available():
			spot.interact(player)
		await process_frame
	ok = ok and works.get_built_count() == BUILT_WORKS
	state.set_flag(&"s01_manta", 1)
	await process_frame
	ok = ok and not battle.is_active()

	# Acercarse al campamento dispara la batalla.
	var approach: Vector3 = Vector3(CAMP.x + 15.0, 0.0, CAMP.z)
	player.global_position = Vector3(
		approach.x, region.height_at(approach.x, approach.z) + 0.3, approach.z
	)
	var activated: bool = await _wait_until(battle.is_active.bind(), 5.0)
	ok = ok and activated
	ok = ok and combat.is_armed()
	ok = ok and is_equal_approx(combat.get_damage_scale(), 0.85)
	ok = ok and battle.get_ally_count() == ALLIES
	ok = ok and battle.get_wave() == 1
	ok = ok and battle.get_enemy_count() == WAVE_SIZES[0]

	# Derrota: la oleada se reinicia, no la partida.
	combat.take_damage(9999.0)
	await _wait_seconds(0.2)
	ok = ok and not combat.is_dead()
	ok = ok and battle.is_active()
	ok = ok and await _wait_until(battle.is_active.bind(), 5.0)
	ok = ok and await _wait_until(_wave_started.bind(battle, 1), 8.0)
	ok = ok and battle.get_enemy_count() == WAVE_SIZES[0]

	# Tres oleadas; cada obra quita un enemigo de cada una (hasta dos).
	for wave: int in [1, 2, 3]:
		ok = ok and await _wait_until(_wave_started.bind(battle, wave), 10.0)
		ok = ok and battle.get_enemy_count() == WAVE_SIZES[wave - 1]
		ok = ok and battle.get_enemy_count() <= 25
		if wave == 1:
			# Un chanca caído se libera solo a los 1,4 s; la lista no puede
			# quedarse con referencias muertas ni dejar de contar la oleada.
			var first: ChancaWarrior = get_first_node_in_group(&"chanca_warrior") as ChancaWarrior
			ok = ok and first != null
			if first != null:
				first.take_damage(500.0)
				await _wait_seconds(2.0)
				ok = ok and battle.get_enemy_count() == WAVE_SIZES[0] - 1
		_kill_enemies()
		await process_frame

	# El estandarte se activa al caer la tercera oleada.
	ok = (
		ok
		and await _wait_until(
			func() -> bool: return battle.get_state() == CarmencaBattle.State.STANDARD, 10.0
		)
	)
	var standard: Vector3 = battle.get_standard_position()
	player.global_position = Vector3(
		standard.x + 1.5, region.height_at(standard.x + 1.5, standard.z) + 0.3, standard.z
	)
	ok = ok and await _wait_until(battle.is_finished.bind(), 5.0)
	ok = ok and state.has_flag(&"m01_victoria")
	ok = ok and journal.is_done(&"m01_carmenca")
	ok = ok and not combat.is_armed()

	print(
		"CARMENCA estado=",
		battle.get_state(),
		" victoria=",
		state.get_flag(&"m01_victoria"),
		" aliados=",
		battle.get_ally_count(),
		" diario=",
		journal.count()
	)
	world.queue_free()
	state.clear()
	campaign.clear()
	await process_frame
	await process_frame
	if ok:
		print("CARMENCA_OK")
	else:
		printerr("CARMENCA_FAIL")
	quit(0 if ok else 1)


func _wave_started(battle: CarmencaBattle, wave: int) -> bool:
	return (
		battle.get_state() == CarmencaBattle.State.WAVE
		and battle.get_wave() == wave
		and battle.get_enemy_count() > 0
	)


func _kill_enemies() -> void:
	for node: Node in get_nodes_in_group(&"chanca_warrior"):
		var warrior: ChancaWarrior = node as ChancaWarrior
		if warrior != null and not warrior.is_dead():
			warrior.take_damage(500.0)


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
