extends SceneTree
## Comprueba que el mundo regional se recorre a pie: el jugador aparece sobre el
## terreno, camina con colisión, el streaming lo sigue y una caída lo devuelve.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const SETTLE_FRAMES: int = 90
const WALK_FRAMES: int = 180
## La segunda marcha comprueba que el jugador sale del arrabal hacia la
## ciudad: en 600 fotogramas debe avanzar y acercarse a la plaza del Cusco.
const CITY_WALK_FRAMES: int = 600
const CUSCO_PLAZA: Vector3 = Vector3(1200.0, 0.0, 400.0)
const ARRABAL_SPAWN: Vector3 = Vector3(1088.0, 0.0, 294.0)
const MAX_SPAWN_DISTANCE: float = 25.0
const MIN_CITY_WALK: float = 20.0
const MIN_WALK_METERS: float = 5.0
const MAX_GROUND_GAP: float = 2.5
const RESPAWN_TOLERANCE: float = 3.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("PLAYER_FAIL no scene")
		quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	root.add_child(world)
	for _i: int in SETTLE_FRAMES:
		await physics_frame
	var player: PlayerFPS = world.get_player()
	if player == null:
		printerr("PLAYER_FAIL no player")
		world.queue_free()
		await process_frame
		quit(1)
		return
	var region: CampaignRegion = world.get_region()
	var review_camera: Camera3D = world.get_node("Camera") as Camera3D
	var start: Vector3 = player.global_position
	var start_ground: float = region.height_at(start.x, start.z)
	var ok: bool = player.is_on_floor()
	ok = ok and absf(start.y - start_ground) <= MAX_GROUND_GAP
	ok = ok and player.camera.current
	ok = ok and not review_camera.current
	ok = ok and world.is_first_person()
	var hands: Node3D = player.get_node("Head/Camera3D/FirstPersonHands") as Node3D
	ok = ok and hands != null and not hands.visible

	Input.action_press("move_forward")
	for _i: int in WALK_FRAMES:
		await physics_frame
	Input.action_release("move_forward")
	await physics_frame
	var end: Vector3 = player.global_position
	var walked: float = Vector2(end.x - start.x, end.z - start.z).length()
	var end_ground: float = region.height_at(end.x, end.z)
	ok = ok and walked >= MIN_WALK_METERS
	ok = ok and absf(end.y - end_ground) <= MAX_GROUND_GAP

	# El jugador aparece en el arrabal de Chocos-chacona y puede salir hacia la
	# ciudad: la marcha gana distancia a la plaza y no se queda clavada.
	var arrabal: Vector2 = Vector2(ARRABAL_SPAWN.x, ARRABAL_SPAWN.z)
	var spawn_distance: float = Vector2(start.x - arrabal.x, start.z - arrabal.y).length()
	ok = ok and spawn_distance <= MAX_SPAWN_DISTANCE

	Input.action_press("move_forward")
	for _i: int in CITY_WALK_FRAMES:
		await physics_frame
	Input.action_release("move_forward")
	await physics_frame
	var city_end: Vector3 = player.global_position
	var city_walk: float = Vector2(city_end.x - end.x, city_end.z - end.z).length()
	var plaza_before: float = Vector2(end.x - CUSCO_PLAZA.x, end.z - CUSCO_PLAZA.z).length()
	var plaza_after: float = (
		Vector2(city_end.x - CUSCO_PLAZA.x, city_end.z - CUSCO_PLAZA.z).length()
	)
	var city_ground: float = region.height_at(city_end.x, city_end.z)
	ok = ok and city_walk >= MIN_CITY_WALK
	ok = ok and plaza_after < plaza_before
	ok = ok and absf(city_end.y - city_ground) <= MAX_GROUND_GAP
	ok = ok and player.is_on_floor()

	var target: Node3D = world.get_node("StreamTarget") as Node3D
	if target == null:
		ok = false
	else:
		var follow: Vector2 = Vector2(
			target.global_position.x - city_end.x, target.global_position.z - city_end.z
		)
		ok = ok and follow.length() < 2.0

	# El marcador de S2 es una ayuda de revisión: en primera persona no debe
	# tapar el camino ni poder atravesarse como decorado.
	world.set_target_position(Vector3(750.0, 0.0, 150.0))
	var marker: CampaignSectorMarker = null
	for _i: int in 240:
		await process_frame
		marker = (world.get_streamer().get_loaded_node(&"s2_afueras") as CampaignSectorMarker)
		if marker != null:
			break
	ok = ok and marker != null and _marker_hidden(marker)

	player.global_position = Vector3(city_end.x, city_end.y - 400.0, city_end.z)
	for _i: int in 5:
		await physics_frame
	await process_frame
	var respawned: Vector3 = player.global_position
	ok = ok and respawned.distance_to(start) <= RESPAWN_TOLERANCE

	var pause_event: InputEventAction = InputEventAction.new()
	pause_event.action = &"pause"
	pause_event.pressed = true
	Input.parse_input_event(pause_event)
	await process_frame
	ok = ok and not paused

	print(
		"PLAYER walked_m=",
		snappedf(walked, 0.1),
		" ground_gap=",
		snappedf(end.y - end_ground, 0.01),
		" spawn_distance=",
		snappedf(spawn_distance, 0.1),
		" city_walk=",
		snappedf(city_walk, 0.1),
		" plaza_after=",
		snappedf(plaza_after, 0.1)
	)
	world.queue_free()
	await process_frame
	if ok:
		print("PLAYER_OK")
	else:
		printerr("PLAYER_FAIL")
	quit(0 if ok else 1)


## Solo el marcador de revisión debe ocultarse: el sector ya tiene contenido
## propio (el mirador) que debe seguir a la vista.
func _marker_hidden(marker: CampaignSectorMarker) -> bool:
	var mesh: MeshInstance3D = marker.get_node_or_null("SectorMarker") as MeshInstance3D
	if mesh == null or mesh.visible:
		return false
	for child: Node in marker.find_children("*", "Label3D", true, false):
		if (child as Label3D).visible:
			return false
	return true
