extends Node
## Prueba encuadres de la emboscada y de la defensa con la puesta en escena real.
##
##   godot --path . --resolution 1280x720 res://tests/scenes/trailer_probe_acts.tscn \
##       -- --world=ciudad --out=/tmp/opencode/probe_ciudad

const LLACTA: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"
const PASO: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"
const CIUDAD: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"


class Shot:
	var name: String
	var from: Vector3
	var look: Vector3
	var fov: float

	func _init(shot_name: String, at: Vector3, target: Vector3, angle: float) -> void:
		name = shot_name
		from = at
		look = target
		fov = angle


var _world_name: String = "ciudad"
var _out: String = "/tmp/opencode/trailer_probe_acts"
var _size: Vector2i = Vector2i(540, 960)


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--world="):
			_world_name = arg.trim_prefix("--world=")
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		if arg.begins_with("--size="):
			var parts: PackedStringArray = arg.trim_prefix("--size=").split("x")
			if parts.size() == 2:
				_size = Vector2i(int(parts[0]), int(parts[1]))
	DirAccess.make_dir_recursive_absolute(_out)
	var viewport: SubViewport = SubViewport.new()
	viewport.size = _size
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var camera: Camera3D = Camera3D.new()
	camera.near = 0.05
	camera.far = 4000.0
	viewport.add_child(camera)
	var shots: Array[Shot] = _build_shots()
	var world: Node = _open(viewport)
	await _frames(120 if _world_name == "ciudad" else 50)
	var ui: CanvasLayer = world.get_node_or_null("UILayer") as CanvasLayer
	if ui != null:
		ui.visible = false
	for node: Node in world.find_children("*", "Node3D", true, false):
		if node is QuestMarker or node is TaskPoint:
			node.set("visible", false)
	for shot: Shot in shots:
		camera.fov = shot.fov
		camera.global_position = shot.from
		camera.look_at(shot.look, Vector3.UP)
		camera.current = true
		await _frames(3)
		viewport.get_texture().get_image().save_png(
			"%s/%s.png" % [_out, shot.name])
		print("PROBE ", shot.name)
	print("PROBE_OK")
	get_tree().quit(0)


func _open(viewport: SubViewport) -> Node:
	CampaignState.clear()
	var path: String = CIUDAD
	if _world_name == "paso":
		path = PASO
	elif _world_name == "llacta":
		path = LLACTA
	if _world_name == "llacta":
		CampaignState.set_flag(&"intro_vista", 1)
	if _world_name == "ciudad":
		for key: StringName in [&"mensaje_entregado", &"trampa_resuelta",
				&"paso_cruzado", &"confianza_sisa"]:
			CampaignState.set_flag(key, 1 if key != &"confianza_sisa" else 2)
	var packed: PackedScene = load(path) as PackedScene
	var world: Node = packed.instantiate()
	viewport.add_child(world)
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	if player != null:
		player.global_position = Vector3(0.0, 0.05, 10.0)
		player.camera.current = false
	if _world_name == "ciudad":
		world.call("_start_defense")
	elif _world_name == "paso":
		world.call("_start_ambush")
	else:
		world.call("_spawn_messenger")
	return world


func _build_shots() -> Array[Shot]:
	if _world_name == "llacta":
		return [
			Shot.new("f_mensajero_frente", Vector3(-1.6, 1.7, 0.8),
				Vector3(-4.8, 1.35, 3.8), 68.0),
			Shot.new("g_mensajero_lado", Vector3(-2.6, 1.7, 6.8),
				Vector3(-4.8, 1.35, 3.8), 68.0),
			Shot.new("h_mensajero_cerca", Vector3(-2.4, 1.7, 1.6),
				Vector3(-4.8, 1.4, 3.8), 68.0),
		]
	if _world_name == "paso":
		return [
			Shot.new("a_alto_frente", Vector3(0.0, 3.2, 14.0),
				Vector3(0.0, 0.9, -6.0), 66.0),
			Shot.new("b_lado", Vector3(5.5, 2.6, 8.0),
				Vector3(0.0, 1.0, -8.0), 66.0),
			Shot.new("c_actual", Vector3(0.0, 2.2, 12.0),
				Vector3(0.0, 1.2, -4.0), 78.0),
			Shot.new("d_alto_lado", Vector3(-5.5, 3.4, 6.0),
				Vector3(0.0, 1.0, -10.0), 66.0),
		]
	return [
		Shot.new("a_alto_frente", Vector3(0.0, 3.6, 24.0),
			Vector3(0.0, 1.0, -6.0), 60.0),
		Shot.new("b_lado", Vector3(9.0, 3.2, 16.0),
			Vector3(0.0, 1.0, -4.0), 62.0),
		Shot.new("c_actual", Vector3(0.0, 2.8, 18.0),
			Vector3(0.0, 1.2, -4.0), 78.0),
		Shot.new("d_alto_atras", Vector3(0.0, 4.5, 30.0),
			Vector3(0.0, 1.0, -8.0), 58.0),
	]


func _frames(count: int) -> void:
	for _index: int in range(count):
		await get_tree().process_frame
