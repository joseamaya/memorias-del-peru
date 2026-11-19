extends Node
## Mide los blockouts de S4, S5 y S6 por separado.
##
##   godot --path . --disable-vsync --resolution 1920x1080 \
##       res://tests/scenes/measure_west.tscn

const WORLD_SCENE: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const TARGETS: Array[Vector3] = [
	Vector3(-700.0, 0.0, 350.0),
	Vector3(-1300.0, 0.0, 100.0),
	Vector3(-1650.0, 0.0, 0.0),
]
const LABELS: Array[String] = ["s4_quebrada", "s5_paso", "s6_frontera"]
const WARMUP_FRAMES: int = 40
const SAMPLE_FRAMES: int = 120


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	Engine.max_fps = 0
	var packed: PackedScene = load(WORLD_SCENE) as PackedScene
	if packed == null:
		printerr("No se pudo cargar ", WORLD_SCENE)
		get_tree().quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	add_child(world)
	world.autowalk = false
	for index: int in TARGETS.size():
		world.set_target_position(TARGETS[index])
		for _i: int in WARMUP_FRAMES:
			await get_tree().process_frame
		var frame_ms: Array[float] = []
		frame_ms.resize(SAMPLE_FRAMES)
		for sample: int in SAMPLE_FRAMES:
			await get_tree().process_frame
			frame_ms[sample] = get_process_delta_time() * 1000.0
		frame_ms.sort()
		var total: float = 0.0
		for value: float in frame_ms:
			total += value
		var average_ms: float = total / float(SAMPLE_FRAMES)
		var p1_ms: float = frame_ms[mini(int(float(SAMPLE_FRAMES) * 0.99), SAMPLE_FRAMES - 1)]
		var draws: int = int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		var video_mb: float = (
			float(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)) / (1024.0 * 1024.0)
		)
		var message: String = (
			"WEST_PERF sector=%s avg=%.1f p1=%.1f drawcalls=%d video_mb=%.1f load=%s"
			% [
				LABELS[index],
				1000.0 / maxf(average_ms, 0.001),
				1000.0 / maxf(p1_ms, 0.001),
				draws,
				video_mb,
				_load_average(),
			]
		)
		print(message)
	print("WEST_PERF_OK")
	world.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _load_average() -> String:
	var file: FileAccess = FileAccess.open("/proc/loadavg", FileAccess.READ)
	if file == null:
		return "no disponible"
	var line: String = file.get_line().strip_edges()
	if line.is_empty():
		return "no disponible"
	return line.split(" ")[0]
