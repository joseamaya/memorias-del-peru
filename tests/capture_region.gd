extends Node
## Captura el relieve regional de blockout y sus seis sectores.
##
##   godot --path . --resolution 1280x720 res://tests/scenes/capture_region.tscn

const REGION_SCENE: String = "res://campaigns/01_pachacutec/scenes/world/region.tscn"
const OUTPUT: String = "res://build/evidencia/region_overview.png"
const WARMUP_FRAMES: int = 30


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(REGION_SCENE) as PackedScene
	if packed == null:
		printerr("REGION_CAPTURE_FAIL scene")
		get_tree().quit(1)
		return
	var region: CampaignRegion = packed.instantiate() as CampaignRegion
	add_child(region)
	for _i: int in WARMUP_FRAMES:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var absolute: String = ProjectSettings.globalize_path(OUTPUT)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var error: Error = image.save_png(absolute)
	if error == OK:
		print("REGION_CAPTURE_OK path=", absolute)
	else:
		printerr("REGION_CAPTURE_FAIL error=", error)
	get_tree().quit(0 if error == OK else 1)
