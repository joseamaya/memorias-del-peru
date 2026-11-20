extends SceneTree
## Comprueba el modo de revisión del mundo regional: cámara cercana, teclas de
## etiquetas y vista cenital.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("REVIEW_FAIL no scene")
		quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	root.add_child(world)
	world.autowalk = false
	world.set_target_position(Vector3(300.0, 0.0, 0.0))
	for _i: int in 20:
		await process_frame
	var camera: Camera3D = world.get_node("Camera") as Camera3D
	var ok: bool = camera != null and camera.projection == Camera3D.PROJECTION_PERSPECTIVE
	ok = ok and world.get_visible_label_count() == 0
	var target_node: Node3D = world.get_node("StreamTarget") as Node3D
	var target: Vector3 = target_node.global_position
	var camera_offset: Vector2 = Vector2(camera.position.x - target.x, camera.position.z - target.z)
	ok = ok and camera_offset.length() < 120.0
	world.toggle_labels()
	for _i: int in 2:
		await process_frame
	var visible: int = world.get_visible_label_count()
	ok = ok and visible == 1
	world.toggle_top_down()
	ok = ok and world.is_top_down()
	ok = ok and camera.projection == Camera3D.PROJECTION_ORTHOGONAL
	world.toggle_top_down()
	ok = ok and not world.is_top_down()
	ok = ok and camera.projection == Camera3D.PROJECTION_PERSPECTIVE
	print("REVIEW labels=", visible, " top_down=", world.is_top_down())
	world.queue_free()
	await process_frame
	if ok:
		print("REVIEW_OK")
	else:
		printerr("REVIEW_FAIL")
	quit(0 if ok else 1)
