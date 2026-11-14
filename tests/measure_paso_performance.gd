extends SceneTree
## Medición del acto II con el paisaje nuevo, perfiles Bajo y Medio.
##
## Uso: godot --path . --script res://tests/measure_paso_performance.gd
##
## Gira la vista sobre el paso durante 8 s por perfil, sin vsync y con
## `Engine.max_fps = 0`. No forma parte del juego: sirve para comparar el
## paisaje del acto II con las mediciones de la llacta (docs/08).

const WARMUP_MS: int = 3000
const MEASURE_MS: int = 8000
const TURN_RAD_PER_SECOND: float = 0.35
const PROFILE_LABELS: Array[String] = ["LOW", "MEDIUM"]

var _player: CharacterBody3D = null
var _settings: Node = null
var _profile_index: int = 0
var _warmup: bool = true
var _phase_start_ms: int = 0
var _last_ms: int = 0
var _frame_times: Array[float] = []


func _initialize() -> void:
	_start.call_deferred()


func _start() -> void:
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/paso.tscn") as PackedScene
	var paso: Node = packed.instantiate()
	root.add_child(paso)
	_player = paso.get_node_or_null("PlayerFPS") as CharacterBody3D
	_settings = root.get_node_or_null("GraphicsSettings")
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_set_profile(0)
	_phase_start_ms = Time.get_ticks_msec()
	_last_ms = _phase_start_ms
	process_frame.connect(_on_frame)


func _set_profile(index: int) -> void:
	if _settings != null:
		_settings.call("set_profile_by_index", index)


func _on_frame() -> void:
	var now: int = Time.get_ticks_msec()
	var delta_ms: int = now - _last_ms
	_last_ms = now
	var delta_s: float = float(delta_ms) / 1000.0
	if _player != null:
		_player.rotate_y(TURN_RAD_PER_SECOND * delta_s)
	var elapsed_ms: int = now - _phase_start_ms
	if _warmup:
		if elapsed_ms >= WARMUP_MS:
			_warmup = false
			_phase_start_ms = now
			_frame_times.clear()
		return
	if delta_ms > 0:
		_frame_times.append(float(delta_ms))
	if elapsed_ms >= MEASURE_MS:
		_print_result(PROFILE_LABELS[_profile_index])
		_profile_index += 1
		if _profile_index >= PROFILE_LABELS.size():
			_finish()
		else:
			_set_profile(1)
			_warmup = true
			_phase_start_ms = now
			_frame_times.clear()


func _print_result(label: String) -> void:
	var count: int = _frame_times.size()
	if count == 0:
		printerr("Sin muestras para ", label)
		return
	var total: float = 0.0
	for frame_ms: float in _frame_times:
		total += frame_ms
	var average_ms: float = total / float(count)
	var average_fps: float = 1000.0 / average_ms
	var sorted: Array[float] = []
	for frame_ms: float in _frame_times:
		sorted.append(frame_ms)
	sorted.sort()
	var p99_index: int = clampi(int(float(count - 1) * 0.99), 0, count - 1)
	var p99_ms: float = sorted[p99_index]
	var low_fps: float = 1000.0 / p99_ms
	var draw_calls: float = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var video_mem: float = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	print("PROFILE=", label)
	print(label, "_FRAMES=", count)
	print(label, "_FPS_MEDIO=", average_fps)
	print(label, "_FPS_P1=", low_fps)
	print(label, "_FRAME_MEDIO_MS=", average_ms)
	print(label, "_FRAME_P99_MS=", p99_ms)
	print(label, "_DRAW_CALLS=", draw_calls)
	print(label, "_VIDEO_MEM_MB=", video_mem / (1024.0 * 1024.0))


func _finish() -> void:
	if process_frame.is_connected(_on_frame):
		process_frame.disconnect(_on_frame)
	var audio: Node = root.get_node_or_null("AudioManager")
	if audio != null:
		audio.call("stop_all")
	quit(0)
