extends RefCounted
## Comprueba el ritmo de ADR-0030: el mensajero sale antes si el jugador
## completa las tareas y está cerca de la plaza, y se le ve acercarse mientras
## espera.

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


func test_messenger_event_hastens_by_action() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	if event == null or player == null:
		world.free()
		return false
	player.global_position = Vector3(0.0, 0.05, 2.0)
	event.step(1.0)
	var early: bool = event.phase == MessengerEvent.Phase.IDLE
	event.request_arrival()
	var started: bool = event.phase == MessengerEvent.Phase.ARRIVAL
	world.free()
	return early and started


func test_messenger_event_request_waits_for_plaza() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	if event == null or player == null:
		world.free()
		return false
	player.global_position = Vector3(0.0, 0.05, 60.0)
	event.step(1.0)
	event.request_arrival()
	event.step(1.0)
	var waiting: bool = event.phase == MessengerEvent.Phase.IDLE
	player.global_position = Vector3(0.0, 0.05, 2.0)
	event.step(0.1)
	var started: bool = event.phase == MessengerEvent.Phase.ARRIVAL
	world.free()
	return waiting and started


func test_messenger_approaches_before_arrival() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	var messenger: NpcActor = world.get_node_or_null("Llacta/NPCs/Mensajero") as NpcActor
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	if event == null or messenger == null or player == null:
		world.free()
		return false
	player.global_position = Vector3(0.0, 0.05, 60.0)
	var start: Vector3 = messenger.global_position
	event.step(MessengerEvent.APPROACH_START_TIME + 4.0)
	var approached: bool = messenger.global_position.distance_to(start) > 1.0
	var still_idle: bool = event.phase == MessengerEvent.Phase.IDLE
	world.free()
	return approached and still_idle
