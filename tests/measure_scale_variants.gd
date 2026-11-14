extends SceneTree
## Compara la escala del búfer 3D y el upscaler en el paso.
##
## Uso: godot --path . --script res://tests/measure_scale_variants.gd
##
## Cada variante usa el resto de ajustes del perfil Medio (SSAO y sombras) y
## gira la vista 8 s tras 3 s de calentamiento, todo en un mismo proceso para
## que la comparación no dependa de la caché ni del arranque. No forma parte del
## juego: sirve para elegir la escala del perfil (docs/08 §4).

const WARMUP_MS: int = 3000
const MEASURE_MS: int = 8000
const TURN_RAD_PER_SECOND: float = 0.35

const VARIANTS: Array[Dictionary] = [
	{"label": "1.00 bilineal", "scale": 1.0, "mode": Viewport.SCALING_3D_MODE_BILINEAR},
	{"label": "0.95 bilineal", "scale": 0.95, "mode": Viewport.SCALING_3D_MODE_BILINEAR},
	{"label": "0.83 bilineal", "scale": 0.83, "mode": Viewport.SCALING_3D_MODE_BILINEAR},
	{"label": "0.83 FSR", "scale": 0.83, "mode": Viewport.SCALING_3D_MODE_FSR},
	{"label": "0.75 bilineal", "scale": 0.75, "mode": Viewport.SCALING_3D_MODE_BILINEAR},
	{"label": "0.75 FSR", "scale": 0.75, "mode": Viewport.SCALING_3D_MODE_FSR},
]

var _player: CharacterBody3D = null
var _settings: Node = null
var _index: int = 0
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
	_apply_variant()
	process_frame.connect(_on_frame)


func _apply_variant() -> void:
	var variant: Dictionary = VARIANTS[_index]
	var profile: GraphicsProfile = GraphicsProfile.new()
	profile.profile_name = variant["label"]
	profile.ssao_enabled = true
	profile.shadow_distance = 60.0
	profile.shadow_atlas_size = 2048
	profile.shadow_filter_quality = RenderingServer.SHADOW_QUALITY_SOFT_LOW
	profile.render_scale = variant["scale"]
	profile.scaling_3d_mode = variant["mode"]
	profile.msaa_3d = Viewport.MSAA_DISABLED
	profile.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	if _settings != null:
		_settings.call("set_profile", profile)


func _on_frame() -> void:
	var now: int = Time.get_ticks_msec()
	var delta_s: float = float(now - _last_ms) / 1000.0
	_last_ms = now
	if _player != null:
		_player.rotate_y(TURN_RAD_PER_SECOND * delta_s)
	var elapsed_ms: int = now - _phase_start_ms
	if _warmup:
		if elapsed_ms >= WARMUP_MS:
			_warmup = false
			_phase_start_ms = now
			_frame_times.clear()
		return
	_frame_times.append(delta_s)
	if elapsed_ms < WARMUP_MS + MEASURE_MS:
		return
	_report()
	_index += 1
	if _index >= VARIANTS.size():
		quit(0)
		return
	_warmup = true
	_phase_start_ms = now
	_apply_variant()


func _report() -> void:
	var total: float = 0.0
	for value: float in _frame_times:
		total += value
	var average: float = total / maxf(1.0, float(_frame_times.size()))
	var sorted: Array[float] = _frame_times.duplicate()
	sorted.sort()
	var p1_index: int = maxi(0, int(float(sorted.size()) * 0.01))
	print("VARIANTE %s FPS=%.1f P1=%.1f" % [
		VARIANTS[_index]["label"], 1.0 / maxf(0.0001, average), 1.0 / maxf(0.0001, sorted[p1_index])])
