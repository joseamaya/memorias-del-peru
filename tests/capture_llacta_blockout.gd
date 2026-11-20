extends Node
## Captura el blockout de S3 — Llacta del valle.
##
##   godot --path . --resolution 1280x720 \
##       res://tests/scenes/capture_llacta_blockout.tscn

const WORLD_SCENE: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const OUTPUT: String = "res://build/evidencia/llacta_blockout.png"
const WARMUP_FRAMES: int = 60


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(WORLD_SCENE) as PackedScene
	if packed == null:
		printerr("LLACTA_CAPTURE_FAIL scene")
		get_tree().quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	world.first_person = false
	add_child(world)
	world.autowalk = false
	world.set_target_position(Vector3(300.0, 0.0, 0.0))
	for _i: int in WARMUP_FRAMES:
		await get_tree().process_frame
	var blockout: LlactaBlockout = (
		world.get_streamer().get_loaded_node(&"s3_llacta") as LlactaBlockout
	)
	if blockout != null:
		for label: Node in blockout.find_children("*", "Label3D", true, false):
			(label as Label3D).visible = false
	var camera: Camera3D = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 170.0
	camera.near = 100.0
	camera.far = 12000.0
	camera.position = Vector3(300.0, 8000.0, 0.0)
	camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	camera.current = true
	add_child(camera)
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var absolute: String = ProjectSettings.globalize_path(OUTPUT)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var error: Error = image.save_png(absolute)
	if error == OK:
		print("LLACTA_CAPTURE_OK path=", absolute)
	else:
		printerr("LLACTA_CAPTURE_FAIL error=", error)
	get_tree().quit(0 if error == OK else 1)
