extends RefCounted
## Comprueba cómo arranca el evento del mensajero (ADR-0007).

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"


func _spawn_world() -> Node:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return null
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	return world


func test_messenger_event_starts_on_arrival() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	if event == null or player == null:
		world.free()
		return false
	event.step(1.0)
	var idle_away: bool = event.phase == MessengerEvent.Phase.IDLE
	player.global_position = Vector3(0.0, 0.05, 2.0)
	event.step(0.1)
	var started: bool = event.phase == MessengerEvent.Phase.ARRIVAL
	world.free()
	return idle_away and started


func test_messenger_event_starts_on_timeout() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	if event == null:
		world.free()
		return false
	event.step(1.0)
	var idle: bool = event.phase == MessengerEvent.Phase.IDLE
	event.step(event.arrival_timeout + 1.0)
	var started: bool = event.phase == MessengerEvent.Phase.ARRIVAL
	world.free()
	return idle and started
