extends Node
## Captura la red de rutas y los navmeshes de sector desde arriba.
##
##   godot --path . --resolution 1280x720 res://tests/scenes/capture_routes.tscn

const WORLD_SCENE: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const OUTPUT: String = "res://build/evidencia/routes.png"
const WARMUP_FRAMES: int = 60


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(WORLD_SCENE) as PackedScene
	if packed == null:
		printerr("ROUTES_CAPTURE_FAIL scene")
		get_tree().quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	add_child(world)
	world.autowalk = false
	var camera: Camera3D = Camera3D.new()
	camera.fov = 55.0
	camera.near = 1.0
	camera.far = 12000.0
	camera.position = Vector3(620.0, 3900.0, 700.0)
	camera.current = true
	add_child(camera)
	camera.look_at(Vector3(250.0, 3600.0, 0.0), Vector3.UP)
	for _i: int in WARMUP_FRAMES:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var absolute: String = ProjectSettings.globalize_path(OUTPUT)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var error: Error = image.save_png(absolute)
	if error == OK:
		print("ROUTES_CAPTURE_OK path=", absolute)
	else:
		printerr("ROUTES_CAPTURE_FAIL error=", error)
	get_tree().quit(0 if error == OK else 1)
