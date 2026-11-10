extends SceneTree
## Medición de rendimiento del mundo base.
##
## Uso: godot --path . --script res://tests/measure_performance.gd
##
## Carga el mundo, descarta un periodo de calentamiento y mide el FPS medio y el
## percentil 1 % a partir de los tiempos de frame. No forma parte del juego.

const WARMUP_MS: int = 3000
const MEASURE_MS: int = 8000

var _start_ms: int = 0
var _last_ms: int = 0
var _frame_times: Array[float] = []
var _load_ms: int = 0
var _player: CharacterBody3D = null


func _initialize() -> void:
	var load_start: int = Time.get_ticks_msec()
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	var world: Node = packed.instantiate()
	root.add_child(world)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	Engine.max_fps = 60
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_load_ms = Time.get_ticks_msec() - load_start
	_player = world.get_node_or_null("PlayerFPS") as CharacterBody3D
	_start_ms = Time.get_ticks_msec()
	_last_ms = _start_ms
	process_frame.connect(_on_frame)


func _on_frame() -> void:
	var now: int = Time.get_ticks_msec()
	var delta_ms: int = now - _last_ms
	_last_ms = now
	var elapsed_ms: int = now - _start_ms
	if elapsed_ms < WARMUP_MS:
		return
	if delta_ms > 0:
		_frame_times.append(float(delta_ms))
	if elapsed_ms >= WARMUP_MS + MEASURE_MS:
		_finish()


func _finish() -> void:
	var count: int = _frame_times.size()
	if count == 0:
		printerr("Sin muestras de rendimiento")
		quit(1)
		return
	var total_ms: float = 0.0
	for frame_ms: float in _frame_times:
		total_ms += frame_ms
	var average_ms: float = total_ms / float(count)
	var average_fps: float = 1000.0 / average_ms
	var sorted: Array[float] = _frame_times.duplicate()
	sorted.sort()
	var p99_index: int = clampi(int(float(count - 1) * 0.99), 0, count - 1)
	var p99_ms: float = sorted[p99_index]
	var low_fps: float = 1000.0 / p99_ms
	var draw_calls: float = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var video_mem: float = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	print("FRAMES=", count)
	print("FPS_MEDIO=", average_fps)
	print("FPS_P1=", low_fps)
	print("FRAME_MEDIO_MS=", average_ms)
	print("FRAME_P99_MS=", p99_ms)
	print("DRAW_CALLS=", draw_calls)
	print("VIDEO_MEM_MB=", video_mem / (1024.0 * 1024.0))
	print("LOAD_MS=", _load_ms)
	if _player != null:
		print("PLAYER_Y=", _player.global_position.y)
		print("PLAYER_ON_FLOOR=", _player.is_on_floor())
	quit(0)
