extends RefCounted
## Comprueba quién se marcha y quién se queda al final del evento (alcance v2 §5)
## y el cierre corto de ADR-0026: el mensajero parte con la comitiva y el
## evento termina poco después del último subtítulo, sin esperar a que el grupo
## salga de la vista.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const MAX_STEPS: int = 500
const STEP_SECONDS: float = 2.0


func test_party_leaves_and_neighbors_stay() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	var pututu: Pututu = world.get_node_or_null("Pututu") as Pututu
	var curaca: NpcActor = world.get_node_or_null("Llacta/NPCs/Curaca") as NpcActor
	var messenger: NpcActor = world.get_node_or_null("Llacta/NPCs/Mensajero") as NpcActor
	var neighbor: NpcActor = world.get_node_or_null("Llacta/NPCs/Habitante1") as NpcActor
	if event == null or player == null or pututu == null or curaca == null or neighbor == null or messenger == null:
		world.free()
		return false
	pututu.audio_stream = null
	player.global_position = Vector3(0.0, 0.05, 2.0)
	var steps: int = 0
	var departure_seconds: float = 0.0
	while event.phase != MessengerEvent.Phase.DONE and steps < MAX_STEPS:
		event.step(STEP_SECONDS)
		if event.phase == MessengerEvent.Phase.DEPARTURE:
			departure_seconds += STEP_SECONDS
		steps += 1
	if event.phase != MessengerEvent.Phase.DONE:
		world.free()
		return false
	# El evento termina en el cierre corto, con la comitiva aún a la vista.
	var short_closing: bool = departure_seconds <= MessengerEvent.CLOSING_SECOND_DELAY + MessengerEvent.CLOSING_HOLD + STEP_SECONDS
	short_closing = short_closing and curaca.visible and messenger.visible
	# Después sigue caminando hasta salir por el camino norte, mensajero incluido.
	steps = 0
	while curaca.visible and steps < MAX_STEPS:
		event.step(STEP_SECONDS)
		steps += 1
	var exit_point: Vector3 = Vector3(0.0, 0.0, -50.0)
	var party_left: bool = (
		short_closing
		and not curaca.visible
		and curaca.flat_distance_to(exit_point) < 4.0
		and not messenger.visible
		and messenger.flat_distance_to(exit_point) < 6.0
	)
	var neighbor_stayed: bool = (
		neighbor.visible
		and neighbor.flat_distance_to(Vector3(0.0, 0.0, 2.0)) < 14.0
	)
	world.free()
	return party_left and neighbor_stayed
