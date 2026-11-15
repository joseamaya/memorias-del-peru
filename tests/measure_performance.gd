extends Node
## Mide FPS medio, FPS mínimo y draw calls por acto con el protocolo de docs/08.
##
##   godot --path . --disable-vsync --resolution 1920x1080 \
##       res://tests/scenes/measure_performance.tscn -- --profile=1
##
## No forma parte de la suite: es una herramienta de medición. Cada acto se
## instancia, se deja estabilizar y se muestrea durante 120 fotogramas.

const ACTS: Array[String] = [
	"res://campaigns/01_pachacutec/scenes/world/llacta.tscn",
	"res://campaigns/01_pachacutec/scenes/world/paso.tscn",
	"res://campaigns/01_pachacutec/scenes/world/ciudad.tscn",
	"res://campaigns/01_pachacutec/scenes/world/llacta_act4.tscn",
	"res://campaigns/01_pachacutec/scenes/world/llacta_act5.tscn",
]
const WARMUP_FRAMES: int = 40
const SAMPLE_FRAMES: int = 120


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	Engine.max_fps = 0
	var only: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--act="):
			only = arg.substr("--act=".length())
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
		var total: float = 0.0
		var minimum: float = 9999.0
		for _i: int in range(SAMPLE_FRAMES):
			await get_tree().process_frame
			var fps: float = Engine.get_frames_per_second()
			total += fps
			minimum = minf(minimum, fps)
		var average: float = total / float(SAMPLE_FRAMES)
		var draws: int = int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		var video_mb: float = float(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)) / (1024.0 * 1024.0)
		print("PERF %s avg=%.1f min=%.1f drawcalls=%d video_mb=%.1f" % [
			path.get_file(), average, minimum, draws, video_mb])
		scene.free()
		await get_tree().process_frame
	print("PERF_OK")
	get_tree().quit()
