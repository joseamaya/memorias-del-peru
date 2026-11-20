extends Node
## Captura el blockout de S1 — Cusco preimperial.
##
##   godot --path . --resolution 1280x720 \
##       res://tests/scenes/capture_cusco_blockout.tscn

const WORLD_SCENE: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const OUTPUT: String = "res://build/evidencia/cusco_blockout.png"
const WARMUP_FRAMES: int = 60


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(WORLD_SCENE) as PackedScene
	if packed == null:
		printerr("CUSCO_CAPTURE_FAIL scene")
		get_tree().quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	world.first_person = false
	add_child(world)
	world.autowalk = false
	world.set_target_position(Vector3(1200.0, 0.0, 400.0))
	for _i: int in WARMUP_FRAMES:
		await get_tree().process_frame
	var blockout: CuscoBlockout = world.get_streamer().get_loaded_node(&"s1_cusco") as CuscoBlockout
	if blockout != null:
		for label: Node in blockout.find_children("*", "Label3D", true, false):
			(label as Label3D).visible = false
	var camera: Camera3D = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 340.0
	camera.near = 100.0
	camera.far = 12000.0
	camera.position = Vector3(1200.0, 8000.0, 400.0)
	camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	camera.current = true
	add_child(camera)
	for _i: int in 10:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var absolute: String = ProjectSettings.globalize_path(OUTPUT)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var error: Error = image.save_png(absolute)
	if error == OK:
		print("CUSCO_CAPTURE_OK path=", absolute)
	else:
		printerr("CUSCO_CAPTURE_FAIL error=", error)
	get_tree().quit(0 if error == OK else 1)
