extends Node
## Captura los blockouts de S4, S5 y S6, uno por sector.
##
##   godot --path . --resolution 1280x720 \
##       res://tests/scenes/capture_west.tscn

const WORLD_SCENE: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const WARMUP_FRAMES: int = 60
const SECTORS: Array[Dictionary] = [
	{
		"id": &"s4_quebrada",
		"center": Vector3(-700.0, 0.0, 350.0),
		"size": 260.0,
		"output": "res://build/evidencia/quebrada_blockout.png",
	},
	{
		"id": &"s5_paso",
		"center": Vector3(-1300.0, 0.0, 100.0),
		"size": 260.0,
		"output": "res://build/evidencia/paso_blockout.png",
	},
	{
		"id": &"s6_frontera",
		"center": Vector3(-1650.0, 0.0, 0.0),
		"size": 340.0,
		"output": "res://build/evidencia/frontera_blockout.png",
	},
]


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(WORLD_SCENE) as PackedScene
	if packed == null:
		printerr("WEST_CAPTURE_FAIL scene")
		get_tree().quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	add_child(world)
	world.autowalk = false
	var routes: Node3D = world.get_node("Routes") as Node3D
	if routes != null:
		routes.visible = false
	var camera: Camera3D = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 100.0
	camera.far = 12000.0
	camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	camera.current = true
	add_child(camera)
	for entry: Dictionary in SECTORS:
		var id: StringName = entry["id"]
		var center: Vector3 = entry["center"]
		world.set_target_position(center)
		if not await _wait_loaded(world.get_streamer(), id):
			printerr("WEST_CAPTURE_FAIL load ", id)
			get_tree().quit(1)
			return
		for _i: int in 6:
			await get_tree().process_frame
		_hide_labels(world.get_streamer().get_loaded_node(id))
		camera.size = str(entry["size"]).to_float()
		camera.position = Vector3(center.x, 8000.0, center.z)
		for _i: int in WARMUP_FRAMES:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image: Image = get_viewport().get_texture().get_image()
		var absolute: String = ProjectSettings.globalize_path(str(entry["output"]))
		DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
		var error: Error = image.save_png(absolute)
		if error == OK:
			print("WEST_CAPTURE_OK path=", absolute)
		else:
			printerr("WEST_CAPTURE_FAIL error=", error)
			get_tree().quit(1)
			return
	print("WEST_CAPTURE_DONE sectors=3")
	get_tree().quit(0)


func _hide_labels(node: Node3D) -> void:
	if node == null:
		return
	for label: Node in node.find_children("*", "Label3D", true, false):
		(label as Label3D).visible = false


func _wait_loaded(streamer: SectorStreamer, id: StringName) -> bool:
	var deadline: int = Time.get_ticks_msec() + 5000
	while Time.get_ticks_msec() < deadline:
		if streamer.is_loaded(id):
			return true
		await get_tree().process_frame
	return false
