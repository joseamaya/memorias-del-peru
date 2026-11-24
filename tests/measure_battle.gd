extends Node
## Mide la batalla de Carmenca dentro del mundo regional: el peor caso de F3.
##
##   godot --path . --disable-vsync --resolution 1920x1080 \
##       res://tests/scenes/measure_battle.tscn -- --profile=1
##
## Fuerza la oleada de ocho chancas con los seis aliados y el jugador en el
## campamento, y muestrea 300 fotogramas con el combate en marcha. El jugador se
## cura en cada fotograma para que la oleada no se reinicie a mitad de medición;
## curar no cambia la carga de dibujo. La línea informa de los chancas vivos al
## empezar y al terminar: los aliados matan alguno durante el muestreo.

const WORLD_SCENE: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const WARMUP_FRAMES: int = 60
const SAMPLE_FRAMES: int = 300
const SETTLE_FRAMES: int = 600
const CAMP: Vector3 = Vector3(787.0, 0.0, 307.0)
const FINAL_WAVE: int = 3

var _world: RegionWorld = null


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	Engine.max_fps = 0
	var packed: PackedScene = load(WORLD_SCENE) as PackedScene
	if packed == null:
		printerr("No se pudo cargar ", WORLD_SCENE)
		get_tree().quit(1)
		return
	_world = packed.instantiate() as RegionWorld
	# Primera persona: la partida necesita jugador, población y sesión de campaña.
	_world.first_person = true
	add_child(_world)
	_world.autowalk = false
	_world.set_target_position(CAMP)
	if not await _wait_session():
		printerr("BATTLE_PERF_FAIL sin sesión de campaña")
		get_tree().quit(1)
		return
	var battle: CarmencaBattle = _world.get_session().get_battle()
	var combat: PlayerCombat = _world.get_player_combat()
	var player: PlayerFPS = _world.get_player()
	if battle == null or combat == null or player == null:
		printerr("BATTLE_PERF_FAIL sin batalla, combate o jugador")
		get_tree().quit(1)
		return
	_place_player(player)
	battle.force_start()
	# La oleada de ocho es el peor caso; se arranca directa tras montar aliados.
	battle.call(&"_start_wave", FINAL_WAVE)
	var enemies_at_start: int = battle.get_enemy_count()
	for _i: int in range(WARMUP_FRAMES):
		combat.revive()
		await get_tree().process_frame
	var frame_ms: Array[float] = []
	frame_ms.resize(SAMPLE_FRAMES)
	for index: int in range(SAMPLE_FRAMES):
		combat.revive()
		await get_tree().process_frame
		frame_ms[index] = get_process_delta_time() * 1000.0
	var sorted_ms: Array[float] = frame_ms.duplicate()
	sorted_ms.sort()
	var total: float = 0.0
	var worst: float = 0.0
	for value: float in frame_ms:
		total += value
		worst = maxf(worst, value)
	var average_ms: float = total / float(SAMPLE_FRAMES)
	var p1_ms: float = sorted_ms[mini(int(float(SAMPLE_FRAMES) * 0.99), SAMPLE_FRAMES - 1)]
	var draws: int = int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	var primitives: int = int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
	var video_mb: float = (
		float(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)) / (1024.0 * 1024.0)
	)
	print(
		(
			(
				"BATTLE_PERF avg=%.1f p1=%.1f worst_ms=%.1f "
				+ "drawcalls=%d primitives=%d video_mb=%.1f "
				+ "enemies_end=%d enemies_start=%d allies=%d load=%s"
			)
			% [
				1000.0 / maxf(average_ms, 0.001),
				1000.0 / maxf(p1_ms, 0.001),
				worst,
				draws,
				primitives,
				video_mb,
				battle.get_enemy_count(),
				enemies_at_start,
				battle.get_ally_count(),
				_load_average(),
			]
		)
	)
	print("BATTLE_PERF_OK")
	battle.queue_free()
	_world.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _place_player(player: PlayerFPS) -> void:
	var point: Vector3 = CAMP + Vector3(3.0, 0.0, 0.0)
	var region: CampaignRegion = _world.get_region()
	player.global_position = Vector3(point.x, region.height_at(point.x, point.z) + 0.5, point.z)
	player.rotation_degrees.y = 90.0
	player.head.rotation.x = deg_to_rad(-4.0)


func _wait_session() -> bool:
	for _i: int in range(SETTLE_FRAMES):
		await get_tree().process_frame
		var population: CityPopulation = _world.get_population()
		if population == null or not population.is_built():
			continue
		var session: CampaignSession = _world.get_session()
		if session == null or session.get_battle() == null:
			continue
		return true
	return false


func _load_average() -> String:
	var file: FileAccess = FileAccess.open("/proc/loadavg", FileAccess.READ)
	if file == null:
		return "no disponible"
	var line: String = file.get_line().strip_edges()
	if line.is_empty():
		return "no disponible"
	return line.split(" ")[0]
