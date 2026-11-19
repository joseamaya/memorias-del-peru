extends SceneTree
## Comprueba que Terrain3D carga, crea una región y devuelve la altura importada.
## Es una comprobación de integración: la extensión necesita un frame para
## inicializar `data`.


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var stage: Node3D = Node3D.new()
	root.add_child(stage)
	var camera: Camera3D = Camera3D.new()
	camera.current = true
	stage.add_child(camera)
	var terrain: Terrain3D = Terrain3D.new()
	terrain.region_size = Terrain3D.SIZE_64
	terrain.vertex_spacing = 1.0
	terrain.free_editor_textures = false
	terrain.clipmap_target = camera
	terrain.set("collision_mode", 3)
	terrain.set("collision_target", camera)
	stage.add_child(terrain)
	await process_frame
	var ok: bool = terrain.data != null
	if ok:
		var image: Image = Image.create(64, 64, false, Image.FORMAT_RF)
		for y: int in 64:
			for x: int in 64:
				image.set_pixel(x, y, Color(float(x) * 0.1 + float(y) * 0.05, 0.0, 0.0, 1.0))
		var images: Array[Image] = [image, null, null]
		terrain.data.import_images(images, Vector3(-32.0, 0.0, -32.0), 0.0, 1.0)
		await process_frame
		ok = terrain.data.get_region_count() >= 1
		ok = ok and absf(terrain.data.get_height(Vector3(0.0, 0.0, 0.0)) - 4.8) < 0.5
		for _physics: int in 10:
			await physics_frame
		var space: PhysicsDirectSpaceState3D = stage.get_world_3d().direct_space_state
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
			Vector3(0.0, 20.0, 0.0), Vector3(0.0, -20.0, 0.0)
		)
		var hit: Dictionary = space.intersect_ray(query)
		ok = ok and hit.has("collider")
	if ok:
		print("TERRAIN3D_OK")
	else:
		printerr("TERRAIN3D_FAIL")
	stage.queue_free()
	await process_frame
	quit(0 if ok else 1)
