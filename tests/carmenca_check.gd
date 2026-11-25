extends SceneTree
## Comprueba la batalla de Carmenca (F3.9.b): oleadas, aliados, estandarte,
## derrota que reinicia la oleada y cierre de la misión.
##
## Cada comprobación lleva etiqueta: si falla, el resumen dice qué paso falló y
## no solo un `CARMENCA_FAIL`.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const CAMPAIGN: StringName = &"01_pachacutec"
const SETTLE_FRAMES: int = 600
const CAMP: Vector3 = Vector3(787.0, 0.0, 307.0)
## Fuera del radio de activación (30 m) y dentro, para probar el umbral.
const TRIGGER_OUTSIDE: float = 40.0
const TRIGGER_INSIDE: float = 25.0
## Distancia de reaparición y margen del anillo de aparición.
const DEFEAT_DISTANCE: float = 20.0
const MIN_ENEMY_DISTANCE: float = 6.0
const BUILT_WORKS: int = 2
const ALLIES: int = 6
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
		steps.report("CARMENCA")
		quit(1)
		return
	_clear_campaign(manager)
	state.clear()
	campaign.clear()
	var world: RegionWorld = _spawn()
	steps.check("mundo instanciado", world != null)
	if world == null:
		steps.report("CARMENCA")
		quit(1)
		return
	steps.check("mundo listo", await _wait_ready(world))
	if not steps.is_ok():
		world.queue_free()
		await process_frame
		steps.report("CARMENCA")
		quit(1)
		return
	var session: CampaignSession = world.get_session()
	var battle: CarmencaBattle = session.get_battle() if session != null else null
	var works: DefenseWorks = session.get_defense_works() if session != null else null
	var combat: PlayerCombat = world.get_player_combat()
	var player: PlayerFPS = world.get_player()
	var region: CampaignRegion = world.get_region()
	var journal: Journal = world.get_journal()
	steps.check("batalla, obras, combate y jugador", battle != null and works != null)
	steps.check("combate y diario", combat != null and region != null and journal != null)
	if not steps.is_ok():
		world.queue_free()
		await process_frame
		steps.report("CARMENCA")
		quit(1)
		return

	# Etapa 3 de la misión y dos obras construidas.
	state.set_flag(&"m01_agua", 1)
	state.set_flag(&"m01_lana", 1)
	state.set_flag(&"m01_maiz", 1)
	await _wait_seconds(0.2)
	state.set_flag(&"m01_queda", 1)
	await _wait_seconds(0.2)
	steps.check("etapa 3", state.get_flag(&"m01_etapa") == 3)
	steps.check("diario con Carmenca", journal.has(&"m01_carmenca"))
	for id: StringName in [&"defensa_1", &"defensa_2"]:
		var spot: ChangeInteractable = works.get_spot(id)
		if spot != null and spot.is_available():
			spot.interact(player)
		await process_frame
	steps.check("dos obras construidas", works.get_built_count() == BUILT_WORKS)
	state.set_flag(&"s01_manta", 1)
	await process_frame
	steps.check("sin batalla antes de entrar", not battle.is_active())

	# El radio manda: a 40 m del campamento todavía no hay batalla; al entrar,
	# sí. Antes la prueba saltaba a 15 m y nunca medía el umbral.
	var outside: Vector3 = Vector3(CAMP.x + TRIGGER_OUTSIDE, 0.0, CAMP.z)
	_place(player, region, outside)
	await _wait_seconds(1.0)
	steps.check("sin batalla a 40 m", not battle.is_active())
	var approach: Vector3 = Vector3(CAMP.x + TRIGGER_INSIDE, 0.0, CAMP.z)
	_place(player, region, approach)
	steps.check("batalla activa a 25 m", await _wait_until(battle.is_active.bind(), 5.0))
	steps.check("jugador armado", combat.is_armed())
	steps.check("manta reduce el daño", is_equal_approx(combat.get_damage_scale(), 0.85))
	# Empieza con la porra y avisa de las teclas.
	steps.check(
		"porra inicial", combat.loadout.current_index() == CarmencaBattle.START_WEAPON_INDEX
	)
	steps.check("arma cuerpo a cuerpo", not combat.loadout.is_ranged())
	var hud: PlayerHud = world.get_player_hud()
	steps.check("aviso visible", hud != null and hud.is_showing_hint())
	if hud != null:
		var hint: Label = hud.get_node_or_null("HintLabel") as Label
		steps.check("aviso de teclas", hint != null and hint.text == tr("PCH_BATALLA_ARMA"))
	steps.check("seis aliados", battle.get_ally_count() == ALLIES)
	steps.check("oleada 1", battle.get_wave() == 1)
	steps.check("enemigos de la oleada 1", battle.get_enemy_count() == WAVE_SIZES[0])
	# El estandarte y el radio cuelgan del campamento real, no de un punto suelto.
	var streamer: SectorStreamer = world.get_streamer()
	var sector: Node = null
	if streamer != null:
		steps.check("S2 cargado", await _wait_until(_sector_loaded.bind(streamer), 5.0))
		sector = streamer.get_loaded_node(&"s2_afueras")
	var overlook: CarmencaOverlook = null
	if sector != null:
		overlook = sector.get_node_or_null("CarmencaOverlook") as CarmencaOverlook
	steps.check("mirador en S2", overlook != null)
	if overlook != null:
		var center: Vector3 = overlook.camp_center()
		steps.check(
			"campamento coincide con las tiendas",
			Vector2(center.x - CAMP.x, center.z - CAMP.z).length() < 0.5
		)

	# Derrota: la oleada se reinicia, no la partida, y se vuelve al borde este
	# del campamento con los vecinos, fuera del anillo de aparición.
	combat.take_damage(9999.0)
	await _wait_seconds(0.2)
	steps.check("jugador vivo tras la derrota", not combat.is_dead())
	steps.check("reaparece a 20 m", absf(_distance_to_camp(player) - DEFEAT_DISTANCE) <= 2.0)
	steps.check("mira al campamento", _faces_camp(player))
	steps.check("oleada reiniciada", battle.is_active())
	steps.check("aliados junto al jugador", _allies_near(player, 10.0))
	steps.check("oleada 1 de nuevo", await _wait_until(_wave_started.bind(battle, 1), 8.0))
	steps.check("enemigos de la oleada reiniciada", battle.get_enemy_count() == WAVE_SIZES[0])
	steps.check(
		"sin chanca pegado al jugador", _nearest_enemy_distance(player) >= MIN_ENEMY_DISTANCE
	)

	# Tres oleadas; cada obra quita un enemigo de cada una (hasta dos).
	for wave: int in [1, 2, 3]:
		steps.check(
			"llega la oleada %d" % wave, await _wait_until(_wave_started.bind(battle, wave), 10.0)
		)
		steps.check(
			"enemigos de la oleada %d" % wave, battle.get_enemy_count() == WAVE_SIZES[wave - 1]
		)
		steps.check("tope de enemigos", battle.get_enemy_count() <= 25)
		if wave == 2:
			# El jugador está sobre un hueco del anillo: la aparición tuvo que
			# reflejarse. Medio metro de margen para el primer paso de la oleada.
			steps.check(
				"aparición reflejada dentro del campamento",
				_nearest_enemy_distance(player) >= MIN_ENEMY_DISTANCE - 0.5
			)
		if wave == 1:
			# Un chanca caído se libera solo a los 1,4 s; la lista no puede
			# quedarse con referencias muertas ni dejar de contar la oleada.
			var first: ChancaWarrior = get_first_node_in_group(&"chanca_warrior") as ChancaWarrior
			steps.check("chanca de la oleada 1", first != null)
			if first != null:
				first.take_damage(500.0)
				await _wait_seconds(2.0)
				steps.check(
					"el chanca caído se libera", battle.get_enemy_count() == WAVE_SIZES[0] - 1
				)
		_kill_enemies()
		await process_frame
		if wave == 1:
			# La oleada 2 debe medir el reflejo: se coloca al jugador sobre el
			# primer hueco del anillo antes de que aparezca.
			var slot: Vector3 = CarmencaSpawn.offset(CAMP, 0, WAVE_SIZES[1] - BUILT_WORKS, CAMP)
			_place(player, region, Vector3(slot.x, 0.0, slot.z))

	# El estandarte se activa al caer la tercera oleada.
	steps.check(
		"estandarte activo",
		await _wait_until(
			func() -> bool: return battle.get_state() == CarmencaBattle.State.STANDARD, 10.0
		)
	)
	var standard: Vector3 = battle.get_standard_position()
	player.global_position = Vector3(
		standard.x + 1.5, region.height_at(standard.x + 1.5, standard.z) + 0.3, standard.z
	)
	steps.check("victoria", await _wait_until(battle.is_finished.bind(), 5.0))
	steps.check("bandera de victoria", state.has_flag(&"m01_victoria"))
	steps.check("diario cerrado", journal.is_done(&"m01_carmenca"))
	steps.check("desarmado tras ganar", not combat.is_armed())
	var first_state: int = battle.get_state()
	var first_allies: int = battle.get_ally_count()
	var first_journal: int = journal.count()
	var first_victory: int = state.get_flag(&"m01_victoria")

	# Guardar después de ganar y cargar: la batalla no se repite y el diario
	# conserva la etapa cerrada.
	steps.check("guardado tras ganar", session.save_auto())
	world.queue_free()
	await process_frame
	state.clear()
	campaign.clear()
	steps.check("carga solicitada", manager.request_load(CAMPAIGN, SaveManagerService.AUTO_SLOT))
	var world2: RegionWorld = _spawn()
	steps.check("mundo recargado instanciado", world2 != null)
	if world2 == null:
		steps.report("CARMENCA")
		quit(1)
		return
	steps.check("mundo recargado", await _wait_ready(world2))
	if not steps.is_ok():
		world2.queue_free()
		await process_frame
		steps.report("CARMENCA")
		quit(1)
		return
	var state2: WorldStateService = WorldStateService.instance()
	var session2: CampaignSession = world2.get_session()
	var battle2: CarmencaBattle = session2.get_battle() if session2 != null else null
	var journal2: Journal = world2.get_journal()
	var player2: PlayerFPS = world2.get_player()
	steps.check("batalla, diario y jugador recargados", battle2 != null and journal2 != null)
	steps.check("jugador recargado", player2 != null)
	steps.check("victoria conservada", state2 != null and state2.has_flag(&"m01_victoria"))
	steps.check("batalla no se repite", battle2 != null and battle2.is_finished())
	steps.check("diario cerrado al cargar", journal2 != null and journal2.is_done(&"m01_carmenca"))
	if player2 != null:
		var region2: CampaignRegion = world2.get_region()
		player2.global_position = Vector3(
			CAMP.x + 15.0, region2.height_at(CAMP.x + 15.0, CAMP.z) + 0.3, CAMP.z
		)
		await _wait_seconds(0.5)
		steps.check(
			"no se reactiva al acercarse",
			battle2 != null and battle2.is_finished() and not battle2.is_active()
		)

	print(
		"CARMENCA estado=",
		first_state,
		" victoria=",
		first_victory,
		" aliados=",
		first_allies,
		" diario=",
		first_journal,
		" recargada=",
		battle2.is_finished() if battle2 != null else false
	)
	world2.queue_free()
	state.clear()
	campaign.clear()
	_clear_campaign(manager)
	await process_frame
	await process_frame
	var ok: bool = steps.is_ok()
	steps.report("CARMENCA")
	quit(0 if ok else 1)


func _distance_to_camp(player: PlayerFPS) -> float:
	return Vector2(player.global_position.x - CAMP.x, player.global_position.z - CAMP.z).length()


func _place(player: PlayerFPS, region: CampaignRegion, flat: Vector3) -> void:
	player.global_position = Vector3(flat.x, region.height_at(flat.x, flat.z) + 0.3, flat.z)


func _faces_camp(player: PlayerFPS) -> bool:
	var forward: Vector3 = -player.global_transform.basis.z
	var to_camp: Vector3 = CAMP - player.global_position
	to_camp.y = 0.0
	if to_camp.length_squared() < 0.001:
		return false
	return forward.normalized().dot(to_camp.normalized()) > 0.95


func _nearest_enemy_distance(player: PlayerFPS) -> float:
	var nearest: float = INF
	for node: Node in get_nodes_in_group(&"chanca_warrior"):
		var warrior: ChancaWarrior = node as ChancaWarrior
		if warrior == null or warrior.is_dead():
			continue
		nearest = minf(nearest, warrior.global_position.distance_to(player.global_position))
	return nearest


func _allies_near(player: PlayerFPS, radius: float) -> bool:
	var count: int = 0
	for node: Node in get_nodes_in_group(&"allied_warrior"):
		var ally: AlliedWarrior = node as AlliedWarrior
		if ally == null:
			continue
		if ally.global_position.distance_to(player.global_position) <= radius:
			count += 1
	return count == ALLIES


func _sector_loaded(streamer: SectorStreamer) -> bool:
	return streamer.get_loaded_node(&"s2_afueras") != null


func _clear_campaign(manager: SaveManagerService) -> void:
	for slot: String in manager.list_slots(CAMPAIGN):
		manager.delete_slot(CAMPAIGN, StringName(slot))
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.save_root().path_join(String(CAMPAIGN)))
	)


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
		if session == null or session.get_battle() == null:
			continue
		return true
	return false
