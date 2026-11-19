extends Node
## Captura el tráiler de redes sociales fotograma a fotograma.
##
##   godot --path . --resolution 1080x1920 \
##       res://tests/scenes/trailer_capture.tscn -- --out=/tmp/opencode/trailer_frames_v
##
## El tamaño real lo fija el viewport del proyecto (1080×1920 o 1920×1080),
## no `--resolution`. El script no captura mientras carga un mundo: eso deja
## los cortes limpios y evita meter fotogramas de carga en el vídeo.

const OUT_DEFAULT: String = "user://trailer_frames"
const LLACTA: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"
const PASO: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"
const CIUDAD: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"
const ACT4: String = "res://campaigns/01_pachacutec/scenes/world/llacta_act4.tscn"
const ACT5: String = "res://campaigns/01_pachacutec/scenes/world/llacta_act5.tscn"

var _out: String = OUT_DEFAULT
var _only: String = ""
var _size: Vector2i = Vector2i(1080, 1920)
var _viewport: SubViewport = null
var _frame: int = 0
var _world: Node = null
var _player: PlayerFPS = null
var _camera: Camera3D = null
var _wide: bool = false
var _fov: float = 78.0


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		if arg.begins_with("--only="):
			_only = arg.trim_prefix("--only=")
		if arg.begins_with("--size="):
			var parts: PackedStringArray = arg.trim_prefix("--size=").split("x")
			if parts.size() == 2:
				_size = Vector2i(int(parts[0]), int(parts[1]))
	DirAccess.make_dir_recursive_absolute(_out)
	Engine.max_fps = 30
	_wide = _size.x > _size.y
	_fov = 78.0 if _wide else 82.0
	_viewport = SubViewport.new()
	_viewport.name = "TrailerViewport"
	_viewport.size = _size
	_viewport.own_world_3d = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	_camera = Camera3D.new()
	_camera.name = "TrailerCamera"
	_camera.fov = _fov
	_camera.near = 0.05
	_camera.far = 4000.0
	_viewport.add_child(_camera)
	if _only == "7":
		await _capture_messenger_only()
		print("TRAILER_CAPTURE_OK frames=", _frame)
		get_tree().quit(0)
		return
	if _only == "" or _only.contains("1"):
		await _capture_act_one()
	if _only == "" or _only.contains("2"):
		await _capture_act_two()
	if _only == "" or _only.contains("3"):
		await _capture_act_three()
	if _only == "" or _only.contains("4"):
		await _capture_act_four()
	if _only == "" or _only.contains("5"):
		await _capture_act_five()
	print("TRAILER_CAPTURE_OK frames=", _frame)
	get_tree().quit(0)


func _capture_act_one() -> void:
	await _open(LLACTA, {&"intro_vista": 1})
	# 1. El mirador, en diagonal: el banco, el parapeto y el valle.
	await _dolly(Vector3(5.5, 1.7, -65.0), Vector3(4.0, 1.7, -67.5),
		Vector3(-6.0, 0.6, -96.0), 120, true)
	# 2. La plaza, el borde de pirca y los caminos.
	await _dolly(Vector3(8.0, 2.3, 12.0), Vector3(5.5, 2.2, 9.5),
		Vector3(0.0, 1.3, 2.0), 90, true)
	# 3. La casa de Rumi, la madre y el hermano.
	await _dolly(Vector3(12.5, 2.2, 10.0), Vector3(13.5, 2.2, 10.5),
		Vector3(19.0, 1.2, 8.2), 75)
	# 4. La honda: blanco, piedra y tres tiros. Cámara del jugador, sin manos.
	await _capture_honda(105)
	# 5. Manantial y acequia al pie de la terraza.
	await _dolly(Vector3(26.0, 2.0, 8.0), Vector3(27.0, 2.0, 6.5),
		Vector3(29.0, 0.8, 4.0), 60, true)
	# 6. La duda, junto al fuego.
	await _dolly(Vector3(-2.0, 1.8, 5.5), Vector3(-3.0, 1.8, 4.8),
		Vector3(-8.0, 1.3, 0.5), 75, true)
	# 7. El mensajero.
	await _messenger_shot()
	# 8. La asamblea.
	_world.call("_stage_assembly_cast")
	_world.call("_place_npc", "Curaca", Vector3(0.0, 0.0, -2.0), Vector3(0.0, 0.0, 2.0))
	_hide_markers()
	await _dolly(Vector3(0.0, 2.6, 12.0), Vector3(0.0, 2.3, 9.0),
		Vector3(0.0, 1.2, 2.0), 75)
	_close_world()


func _messenger_shot() -> void:
	_world.call("_spawn_messenger")
	var messenger: NpcActor = _world.get_node_or_null(
		"Llacta/NPCs/Mensajero") as NpcActor
	if messenger != null:
		messenger.watch_target = null
		messenger.face(Vector3(-1.2, 0.0, 0.5), true)
	_hide_markers()
	await _dolly(Vector3(-1.2, 1.7, 0.5), Vector3(-2.0, 1.7, 1.2),
		Vector3(-4.8, 1.35, 3.8), 75, true)


func _capture_messenger_only() -> void:
	await _open(LLACTA, {&"intro_vista": 1})
	await _messenger_shot()
	_close_world()


func _capture_act_two() -> void:
	await _open(PASO, {})
	_player.global_position = Vector3(0.0, 0.05, 10.0)
	_world.call("_start_ambush")
	await _dolly(Vector3(0.0, 3.2, 14.0), Vector3(0.0, 2.8, 10.0),
		Vector3(0.0, 0.9, -6.0), 105, true)
	_close_world()


func _capture_act_three() -> void:
	await _open(CIUDAD, {
		&"mensaje_entregado": 1, &"trampa_resuelta": 1,
		&"paso_cruzado": 1, &"confianza_sisa": 2,
	})
	_player.global_position = Vector3(0.0, 0.05, 10.0)
	_world.call("_start_defense")
	await _dolly(Vector3(0.0, 3.6, 26.0), Vector3(0.0, 3.0, 19.0),
		Vector3(0.0, 1.0, -6.0), 90, true)
	_close_world()


func _capture_act_four() -> void:
	await _open(ACT4, {})
	# La casa de Rumi en la posguerra: el paño oscuro en la puerta.
	_hide_cast()
	var frame: Dictionary = _home_frame()
	var from: Vector3 = frame["from"]
	var look: Vector3 = frame["look"]
	await _dolly(from, from - from.direction_to(look) * 0.6, look, 42, true)
	_close_world()


func _capture_act_five() -> void:
	await _open(ACT5, {})
	# La misma casa, reparada y con la lumbre encendida: el antes y el después.
	_hide_cast()
	_world.call("_repair_home")
	var frame: Dictionary = _home_frame()
	var from: Vector3 = frame["from"]
	var look: Vector3 = frame["look"]
	await _dolly(from, from - from.direction_to(look) * 0.9, look, 48, true)
	_close_world()


func _home_frame() -> Dictionary:
	var door: Vector3 = Vector3(16.7, 0.9, 7.8)
	var raw_door: Variant = _world.call("_home_door_position")
	if raw_door is Vector3:
		door = raw_door
	var house: Node3D = null
	var raw_house: Variant = _world.call("_home_house")
	if raw_house is Node3D:
		house = raw_house
	var outward: Vector3 = Vector3.FORWARD
	if house != null:
		outward = door - house.global_position
	outward.y = 0.0
	if outward.length_squared() < 0.01:
		outward = Vector3.FORWARD
	outward = outward.normalized()
	var from: Vector3 = door + outward * 8.2
	from.y = 1.9
	return {"from": from, "look": door + Vector3(0.0, 0.9, 0.0)}


func _open(path: String, flags: Dictionary) -> void:
	_close_world()
	CampaignState.clear()
	for key: StringName in flags:
		var raw: Variant = flags[key]
		var number: int = 0
		if raw is int:
			number = raw
		if number > 0:
			CampaignState.set_flag(key, number)
	var packed: PackedScene = load(path) as PackedScene
	_world = packed.instantiate()
	_viewport.add_child(_world)
	await _frames(8)
	var ui: CanvasLayer = _world.get_node_or_null("UILayer") as CanvasLayer
	if ui != null:
		ui.visible = false
	_player = _world.get_node_or_null("PlayerFPS") as PlayerFPS
	if _player != null:
		_player.camera.current = false
		_player.base_fov = _fov
		_player.set("_fov_target", _fov)
		_player.camera.fov = _fov
		for path_node: String in ["Head/Camera3D/FirstPersonHands", "Head/Camera3D/FirstPersonWeapon"]:
			var node: Node3D = _player.get_node_or_null(path_node) as Node3D
			if node != null:
				node.visible = false
	_hide_markers()
	_camera.current = true


func _close_world() -> void:
	if _world != null:
		_camera.current = false
		_world.queue_free()
		_world = null
		_player = null


func _capture_honda(frames: int) -> void:
	_player.global_position = Vector3(-2.0, 0.05, 9.0)
	_player.rotation = Vector3.ZERO
	_player.set("_pitch", -0.025)
	_player.head.rotation.x = -0.025
	_player.camera.current = true
	_camera.current = false
	_player.base_fov = _fov
	_player.set("_fov_target", _fov)
	_player.camera.fov = _fov
	var drill: SlingDrill = SlingDrill.new()
	_world.add_child(drill)
	drill.setup(_player, _world.get_node("UILayer/HUD") as PlayerHud)
	drill.start(99)
	_hide_markers()
	await _frames(3)
	for index: int in range(frames):
		_player.global_position = Vector3(-2.0, 0.05, lerpf(9.0, 7.0, float(index) / float(frames)))
		if index == 24 or index == 54 or index == 84:
			drill.throw_stone()
		await get_tree().process_frame
		_save()
	drill.stop()
	_player.camera.current = false
	_camera.current = true


func _dolly(from: Vector3, to: Vector3, look: Vector3, frames: int,
		tight: bool = false) -> void:
	_camera.current = true
	if _player != null:
		_player.camera.current = false
	_camera.fov = 68.0 if tight else _fov
	_camera.global_position = from
	_camera.look_at(look, Vector3.UP)
	await _frames(2)
	for index: int in range(frames):
		var t: float = float(index) / maxf(float(frames - 1), 1.0)
		_camera.global_position = from.lerp(to, t)
		_camera.look_at(look, Vector3.UP)
		await get_tree().process_frame
		_save()


func _hide_cast() -> void:
	if _world == null:
		return
	var cast: Node = _world.get_node_or_null("Llacta/NPCs")
	if cast == null:
		return
	for node: Node in cast.find_children("*", "NpcActor", true, false):
		node.set("visible", false)


func _hide_markers() -> void:
	if _world == null:
		return
	for node: Node in _world.find_children("*", "Node3D", true, false):
		if node is QuestMarker or node is TaskPoint:
			node.set("visible", false)


func _save() -> void:
	var image: Image = _viewport.get_texture().get_image()
	if image == null:
		return
	image.save_jpg("%s/%06d.jpg" % [_out, _frame], 0.92)
	_frame += 1


func _frames(count: int) -> void:
	for _index: int in range(count):
		await get_tree().process_frame
