extends SceneTree
## Comprobación de recorrido de la llacta: entrada, plaza, casa, manantial,
## mirador y corral. No es parte de la suite unitaria porque necesita física y
## varios segundos de simulación.
##
##   godot --headless --path . --script res://tests/llacta_walk_check.gd

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"
const TIME_SCALE: float = 3.0
const WAYPOINTS: Array[Vector2] = [
	Vector2(0.0, 30.0), Vector2(0.0, 2.0), Vector2(13.5, 4.0), Vector2(27.0, 3.6),
	Vector2(13.5, 8.0), Vector2(19.5, 5.6), Vector2(15.0, 5.0), Vector2(13.5, 4.0),
	Vector2(0.0, -13.5), Vector2(0.0, -70.0), Vector2(0.0, -13.5),
	Vector2(-13.5, -8.0), Vector2(-20.0, -14.0), Vector2(-27.0, -12.0),
]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var state: Node = root.get_node_or_null("CampaignState")
	if state != null:
		state.call("clear")
		state.call("set_flag", &"intro_vista", 1)
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	var world: Node = packed.instantiate()
	root.add_child(world)
	await _frames(10)
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	if player == null:
		print("LLACTA_WALK_FAIL sin jugador")
		quit(1)
		return
	player.set("walk_speed", 4.2)
	Engine.time_scale = TIME_SCALE
	Input.action_press(&"move_forward")
	var ok: bool = true
	for index: int in range(WAYPOINTS.size()):
		var target: Vector2 = WAYPOINTS[index]
		var reached: bool = await _walk_to(player, target, 900)
		print("LLACTA_WALK ", index, " ", target, " ", "OK" if reached else "ATASCADO", " pos=", player.global_position)
		ok = ok and reached
		if not ok:
			break
	Input.action_release(&"move_forward")
	Engine.time_scale = 1.0
	if state != null:
		state.call("clear")
	world.queue_free()
	await _frames(5)
	print("LLACTA_WALK_OK" if ok else "LLACTA_WALK_FALLO")
	quit(0 if ok else 1)


func _walk_to(player: PlayerFPS, target: Vector2, max_frames: int) -> bool:
	for _index: int in range(max_frames):
		var to: Vector3 = Vector3(target.x, 0.0, target.y) - player.global_position
		to.y = 0.0
		if to.length() < 0.9:
			return true
		player.rotation.y = atan2(-to.x, -to.z)
		await physics_frame
	return false


func _frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame
