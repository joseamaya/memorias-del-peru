extends Node
## Prueba encuadres fijos del tráiler sin grabar la secuencia completa.
##
##   godot --path . --resolution 1280x720 res://tests/scenes/trailer_probe.tscn \
##       -- --out=/tmp/opencode/trailer_probe --cast=1
##
## Guarda un PNG por encuadre a 1080×1920 (o el tamaño pedido con --size=).

const LLACTA: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"

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


var _shots: Array[Shot] = []


func _build_shots() -> void:
	_shots = [
		Shot.new("a_mirador_diagonal", Vector3(5.0, 1.7, -66.0),
			Vector3(-6.0, 0.6, -96.0), 68.0),
		Shot.new("b_plaza_cerca", Vector3(6.0, 2.0, 11.0),
			Vector3(0.0, 1.4, 0.0), 68.0),
		Shot.new("c_plaza_lado", Vector3(10.0, 2.2, 8.0),
			Vector3(0.0, 1.2, 2.0), 68.0),
		Shot.new("d_terrazas", Vector3(30.0, 2.2, 2.0),
			Vector3(45.0, 0.8, 0.0), 68.0),
		Shot.new("e_casa_frente", Vector3(16.7, 1.8, 12.5),
			Vector3(19.0, 1.2, 8.2), 68.0),
	]

var _out: String = "/tmp/opencode/trailer_probe"
var _size: Vector2i = Vector2i(1080, 1920)


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		if arg.begins_with("--size="):
			var parts: PackedStringArray = arg.trim_prefix("--size=").split("x")
			if parts.size() == 2:
				_size = Vector2i(int(parts[0]), int(parts[1]))
	DirAccess.make_dir_recursive_absolute(_out)
	_build_shots()
	CampaignState.clear()
	CampaignState.set_flag(&"intro_vista", 1)
	var viewport: SubViewport = SubViewport.new()
	viewport.size = _size
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var camera: Camera3D = Camera3D.new()
	camera.near = 0.05
	camera.far = 4000.0
	viewport.add_child(camera)
	var packed: PackedScene = load(LLACTA) as PackedScene
	var world: Node = packed.instantiate()
	viewport.add_child(world)
	await _frames(12)
	var ui: CanvasLayer = world.get_node_or_null("UILayer") as CanvasLayer
	if ui != null:
		ui.visible = false
	for node: Node in world.find_children("*", "Node3D", true, false):
		if node is QuestMarker or node is TaskPoint:
			node.set("visible", false)
	for shot: Shot in _shots:
		camera.fov = shot.fov
		camera.global_position = shot.from
		camera.look_at(shot.look, Vector3.UP)
		camera.current = true
		await _frames(3)
		var image: Image = viewport.get_texture().get_image()
		image.save_png("%s/%s.png" % [_out, shot.name])
		print("PROBE ", shot.name)
	print("PROBE_OK")
	get_tree().quit(0)


func _frames(count: int) -> void:
	for _index: int in range(count):
		await get_tree().process_frame
