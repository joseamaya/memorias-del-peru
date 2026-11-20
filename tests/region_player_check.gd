extends SceneTree
## Comprueba que el mundo regional se recorre a pie: el jugador aparece sobre el
## terreno, camina con colisión, el streaming lo sigue y una caída lo devuelve.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const SETTLE_FRAMES: int = 90
const WALK_FRAMES: int = 180
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

	var target: Node3D = world.get_node("StreamTarget") as Node3D
	if target == null:
		ok = false
	else:
		var follow: Vector2 = Vector2(
			target.global_position.x - end.x, target.global_position.z - end.z
		)
		ok = ok and follow.length() < 2.0

	player.global_position = Vector3(end.x, end.y - 400.0, end.z)
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
		snappedf(end.y - end_ground, 0.01)
	)
	world.queue_free()
	await process_frame
	if ok:
		print("PLAYER_OK")
	else:
		printerr("PLAYER_FAIL")
	quit(0 if ok else 1)
