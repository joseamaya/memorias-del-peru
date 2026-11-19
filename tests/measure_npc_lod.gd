extends Node
## Mide el sector gris con 60 NPC y presupuesto de animación (25).
##
##   godot --path . --disable-vsync --resolution 1920x1080 \
##       res://tests/scenes/measure_npc_lod.tscn

const SECTOR_SCENE: String = "res://tests/scenes/npc_lod.tscn"
const WARMUP_FRAMES: int = 60
const SAMPLE_FRAMES: int = 300


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	Engine.max_fps = 0
	var packed: PackedScene = load(SECTOR_SCENE) as PackedScene
	if packed == null:
		printerr("No se pudo cargar ", SECTOR_SCENE)
		get_tree().quit(1)
		return
	var sector: GreySector = packed.instantiate() as GreySector
	add_child(sector)
	for _i: int in range(WARMUP_FRAMES):
		await get_tree().process_frame
	var frame_ms: Array[float] = []
	frame_ms.resize(SAMPLE_FRAMES)
	for index: int in range(SAMPLE_FRAMES):
		await get_tree().process_frame
		frame_ms[index] = get_process_delta_time() * 1000.0
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
		"NPC_LOD_PERF avg=%.1f p1=%.1f frame_ms=%.2f drawcalls=%d "
		+ "video_mb=%.1f active=%d animated=%d load=%s"
	)
	print(
		(
			message
			% [
				1000.0 / maxf(average_ms, 0.001),
				1000.0 / maxf(p1_ms, 0.001),
				average_ms,
				draws,
				video_mb,
				sector.get_active_npc_count(),
				sector.get_animated_npc_count(),
				_load_average(),
			]
		)
	)
	print("NPC_LOD_PERF_OK")
	sector.queue_free()
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
