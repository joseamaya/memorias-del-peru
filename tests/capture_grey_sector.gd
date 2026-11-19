extends Node
## Captura el sector gris para revisión visual de F1.
##
##   godot --path . --resolution 1280x720 \
##       res://tests/scenes/capture_grey_sector.tscn

const SECTOR_SCENE: String = "res://tests/scenes/grey_sector.tscn"
const OUTPUT: String = "res://build/evidencia/grey_sector_nav.png"
const WARMUP_FRAMES: int = 60


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SECTOR_SCENE) as PackedScene
	if packed == null:
		printerr("GREY_CAPTURE_FAIL scene")
		get_tree().quit(1)
		return
	var sector: GreySector = packed.instantiate() as GreySector
	add_child(sector)
	sector.set_process(false)
	var camera: Camera3D = sector.find_child("GreySectorCamera", true, false) as Camera3D
	if camera != null:
		camera.position = Vector3(34.0, 22.0, 42.0)
		camera.look_at(Vector3(4.0, 0.0, -6.0), Vector3.UP)
	var block: CyclopsBlock = sector.get_cyclops_block()
	if block != null and block.mesh_instance != null:
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color(0.55, 0.43, 0.30)
		block.mesh_instance.material_override = material
	NavigationServer3D.set_debug_enabled(true)
	for _i: int in WARMUP_FRAMES:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var absolute: String = ProjectSettings.globalize_path(OUTPUT)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var error: Error = image.save_png(absolute)
	if error == OK:
		print("GREY_CAPTURE_OK path=", absolute)
	else:
		printerr("GREY_CAPTURE_FAIL error=", error)
	get_tree().quit(0 if error == OK else 1)
