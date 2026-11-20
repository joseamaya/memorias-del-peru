extends SceneTree
## Comprueba los tres interiores transitables: entrar desde la puerta, sala
## instanciada fuera del terreno y vuelta exacta a la puerta.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const SETTLE_FRAMES: int = 240
const EXPECTED_DOORS: int = 3
const MIN_ROOM_MESHES: int = 8
const MAX_RETURN_DISTANCE: float = 2.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("INTERIORS_FAIL no scene")
		quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	root.add_child(world)
	var streamer: SectorStreamer = world.get_streamer()
	var blockout: CuscoBlockout = null
	for _i: int in SETTLE_FRAMES:
		await process_frame
		blockout = streamer.get_loaded_node(&"s1_cusco") as CuscoBlockout
		if blockout != null:
			break
	var controller: InteriorController = world.get_interiors()
	var player: PlayerFPS = world.get_player()
	var ok: bool = blockout != null and controller != null and player != null
	if not ok:
		printerr("INTERIORS_FAIL sin Cusco, controlador o jugador")
		world.queue_free()
		await process_frame
		quit(1)
		return
	var doors: Array[InteriorDoor] = blockout.get_interior_doors()
	ok = ok and doors.size() == EXPECTED_DOORS
	var visited: Array[StringName] = []
	var room_meshes: int = 0
	for door: InteriorDoor in doors:
		await physics_frame
		var before: Vector3 = door.global_position + Vector3(0.0, 1.0, 2.4)
		player.global_position = before
		ok = ok and controller.enter(door)
		var room: InteriorRoom = controller.get_room()
		ok = ok and controller.is_inside() and room != null
		ok = ok and room.get_mesh_count() >= MIN_ROOM_MESHES
		ok = ok and player.global_position.y < before.y - 100.0
		if room != null:
			visited.append(room.dressing)
			room_meshes = maxi(room_meshes, room.get_mesh_count())
		ok = ok and controller.exit()
		ok = ok and not controller.is_inside()
		ok = ok and player.global_position.distance_to(before) <= MAX_RETURN_DISTANCE
	ok = ok and visited.size() == EXPECTED_DOORS
	ok = ok and visited[0] == &"home" and visited[1] == &"authority"
	ok = ok and visited[2] == &"workshop"
	print("INTERIORS doors=", doors.size(), " visited=", visited, " room_meshes=", room_meshes)
	world.queue_free()
	await process_frame
	if ok:
		print("INTERIORS_OK")
	else:
		printerr("INTERIORS_FAIL")
	quit(0 if ok else 1)
