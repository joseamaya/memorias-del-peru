extends SceneTree
## Comprueba la ciudad habitable de la slice: el jugador aparece en el arrabal
## de Chocos-chacona, el barrio tiene sus casas y la plaza del Cusco queda
## cerca y sin obstáculos entre ambos.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const SETTLE_FRAMES: int = 240
const MIN_ARRABAL_HOUSES: int = 10
const MAX_SPAWN_DISTANCE: float = 20.0
const MAX_PLAZA_DISTANCE: float = 200.0
const MAX_GROUND_GAP: float = 2.5


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("CITY_FAIL no scene")
		quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	root.add_child(world)
	var streamer: SectorStreamer = world.get_streamer()
	var loaded: bool = false
	for _i: int in SETTLE_FRAMES:
		await process_frame
		loaded = streamer.get_loaded_node(&"s1_cusco") != null
		if loaded:
			break
	var blockout: CuscoBlockout = streamer.get_loaded_node(&"s1_cusco") as CuscoBlockout
	var player: PlayerFPS = world.get_player()
	var ok: bool = loaded and blockout != null and player != null
	if not ok:
		printerr("CITY_FAIL sin sector S1 o sin jugador")
		world.queue_free()
		await process_frame
		quit(1)
		return
	for _i: int in 90:
		await physics_frame
	var local: Vector2 = blockout.get_arrabal_center()
	var arrabal: Vector3 = blockout.global_position + Vector3(local.x, 0.0, local.y)
	var spawn: Vector3 = player.global_position
	var spawn_distance: float = Vector2(spawn.x - arrabal.x, spawn.z - arrabal.z).length()
	var plaza: Vector3 = blockout.global_position
	var plaza_distance: float = Vector2(arrabal.x - plaza.x, arrabal.z - plaza.z).length()
	var ground: float = world.get_region().height_at(spawn.x, spawn.z)
	ok = ok and blockout.get_arrabal_house_count() >= MIN_ARRABAL_HOUSES
	ok = ok and arrabal.x < plaza.x - 60.0
	ok = ok and spawn_distance <= MAX_SPAWN_DISTANCE
	ok = ok and plaza_distance <= MAX_PLAZA_DISTANCE
	ok = ok and player.is_on_floor()
	ok = ok and absf(spawn.y - ground) <= MAX_GROUND_GAP
	print(
		"CITY arrabal_houses=",
		blockout.get_arrabal_house_count(),
		" spawn_distance=",
		snappedf(spawn_distance, 0.1),
		" plaza_distance=",
		snappedf(plaza_distance, 0.1),
		" houses=",
		blockout.get_house_count(),
		" grounded=",
		player.is_on_floor(),
		" ground_gap=",
		snappedf(spawn.y - ground, 0.01)
	)
	world.queue_free()
	await process_frame
	if ok:
		print("CITY_OK")
	else:
		printerr("CITY_FAIL")
	quit(0 if ok else 1)
