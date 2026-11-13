extends RefCounted
## Comprueba que el grupo se acerca durante la llegada del mensajero y forma un
## anillo apretado a su alrededor, en vez de quedarse disperso por la plaza.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const GROUP: Array[String] = [
	"Curaca", "Principal1", "Principal2", "Habitante1", "Habitante2", "Habitante3",
]
const STEP_SECONDS: float = 0.25
const MAX_STEPS: int = 600
const SETTLE_STEPS: int = 20


func test_meeting_gathers_around_messenger() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(WORLD_PATH) as PackedScene).instantiate()
	tree.root.add_child(world)
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	var pututu: Pututu = world.get_node_or_null("Pututu") as Pututu
	var messenger: NpcActor = world.get_node_or_null("Llacta/NPCs/Mensajero") as NpcActor
	if event == null or player == null or pututu == null or messenger == null:
		world.free()
		return false
	pututu.audio_stream = null
	player.global_position = Vector3(0.0, 0.05, 2.0)
	var starts: Dictionary[String, Vector3] = {}
	var moving: int = 0
	event.start()
	for actor_name: String in GROUP:
		var actor: NpcActor = world.get_node_or_null("Llacta/NPCs/" + actor_name) as NpcActor
		if actor == null:
			world.free()
			return false
		starts[actor_name] = actor.global_position
		if actor.moving:
			moving += 1
	# Al empezar la llegada, el grupo ya sale hacia el anillo.
	var ok: bool = event.phase == MessengerEvent.Phase.ARRIVAL and moving == GROUP.size()
	for _step: int in range(8):
		event.step(STEP_SECONDS)
	var moved: int = 0
	for actor_name: String in GROUP:
		var actor: NpcActor = world.get_node_or_null("Llacta/NPCs/" + actor_name) as NpcActor
		if actor != null and actor.global_position.distance_to(starts[actor_name]) > 0.3:
			moved += 1
	ok = ok and moved >= 4
	# La reunión termina de formarse antes de la llamada.
	var steps: int = 0
	while event.phase != MessengerEvent.Phase.CALL and steps < MAX_STEPS:
		event.step(STEP_SECONDS)
		steps += 1
	for _step: int in range(SETTLE_STEPS):
		event.step(STEP_SECONDS)
	ok = ok and event.phase == MessengerEvent.Phase.CALL
	var max_radius: float = (
		MessengerEvent.MEETING_RADIUS
		+ MessengerEvent.MEETING_RADIUS_STAGGER
		+ 0.35
	)
	var south: int = 0
	var north: int = 0
	for actor_name: String in GROUP:
		var actor: NpcActor = world.get_node_or_null("Llacta/NPCs/" + actor_name) as NpcActor
		if actor == null:
			ok = false
			continue
		var distance: float = actor.flat_distance_to(messenger.global_position)
		ok = ok and not actor.moving
		ok = ok and distance >= 1.5 and distance <= max_radius
		if actor.global_position.z > messenger.global_position.z:
			south += 1
		else:
			north += 1
	# No es una fila detrás: hay gente también en los flancos sur.
	ok = ok and south >= 2 and north >= 2
	world.free()
	return ok
