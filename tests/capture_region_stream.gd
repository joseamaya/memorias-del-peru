extends Node
## Captura el mundo regional con el sector de la llacta cargado.
##
##   godot --path . --resolution 1280x720 \
##       res://tests/scenes/capture_region_stream.tscn

const WORLD_SCENE: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const OUTPUT: String = "res://build/evidencia/region_streaming.png"
const WARMUP_FRAMES: int = 60


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(WORLD_SCENE) as PackedScene
	if packed == null:
		printerr("REGION_STREAM_CAPTURE_FAIL scene")
		get_tree().quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	add_child(world)
	world.autowalk = false
	world.set_target_position(Vector3(300.0, 0.0, 0.0))
	for _i: int in WARMUP_FRAMES:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var absolute: String = ProjectSettings.globalize_path(OUTPUT)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var error: Error = image.save_png(absolute)
	if error == OK:
		print("REGION_STREAM_CAPTURE_OK path=", absolute)
	else:
		printerr("REGION_STREAM_CAPTURE_FAIL error=", error)
	get_tree().quit(0 if error == OK else 1)
