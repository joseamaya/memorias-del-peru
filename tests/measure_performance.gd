extends Node
## Mide FPS medio, FPS p1, draw calls y memoria de vídeo por acto con el
## protocolo de docs/08.
##
##   godot --path . --disable-vsync --resolution 1920x1080 \
##       res://tests/scenes/measure_performance.tscn -- --profile=1
##
## No forma parte de la suite: es una herramienta de medición. Cada acto se
## instancia, se deja estabilizar y se muestrea durante [constant SAMPLE_FRAMES]
## fotogramas. El p1 es el percentil 99 del tiempo de fotograma: descarta los
## picos aislados de carga o de compilación de shaders.
##
## Al final imprime la carga media del sistema (`/proc/loadavg`) para detectar
## mediciones contaminadas por otros procesos.

const ACTS: Array[String] = [
	"res://campaigns/01_pachacutec/scenes/world/llacta.tscn",
	"res://campaigns/01_pachacutec/scenes/world/paso.tscn",
	"res://campaigns/01_pachacutec/scenes/world/ciudad.tscn",
	"res://campaigns/01_pachacutec/scenes/world/llacta_act4.tscn",
	"res://campaigns/01_pachacutec/scenes/world/llacta_act5.tscn",
]
const WARMUP_FRAMES: int = 60
const SAMPLE_FRAMES: int = 300


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	Engine.max_fps = 0
	var only: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--act="):
			only = arg.substr("--act=".length())
	print("PERF_LOAD ", _load_average())
	for path: String in ACTS:
		if not only.is_empty() and not path.contains(only):
			continue
		var packed: PackedScene = load(path) as PackedScene
		if packed == null:
			print("PERF_FALLO ", path)
			continue
		var scene: Node = packed.instantiate()
		add_child(scene)
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
		var video_mb: float = float(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)) / (1024.0 * 1024.0)
		print("PERF %s avg=%.1f p1=%.1f frame_ms=%.2f drawcalls=%d video_mb=%.1f" % [
			path.get_file(), 1000.0 / maxf(average_ms, 0.001), 1000.0 / maxf(p1_ms, 0.001),
			average_ms, draws, video_mb])
		scene.free()
		await get_tree().process_frame
	print("PERF_LOAD ", _load_average())
	print("PERF_OK")
	get_tree().quit()


## Carga media del sistema en el último minuto, si el SO la expone.
func _load_average() -> String:
	var file: FileAccess = FileAccess.open("/proc/loadavg", FileAccess.READ)
	if file == null:
		return "no disponible"
	# `/proc` informa tamaño 0: `get_as_text()` devolvería vacío.
	var line: String = file.get_line().strip_edges()
	if line.is_empty():
		return "no disponible"
	return line.split(" ")[0]
