extends RefCounted
## Comprueba que la reunión del evento no tapa el quero, el pututu ni la
## ofrenda: todos los personajes quedan en la mitad norte de la plaza y a
## distancia de los objetos.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const STEP_SECONDS: float = 0.25
const MAX_STEPS: int = 400
const MIN_CLEARANCE: float = 2.5
const ACTOR_NAMES: Array[String] = [
	"Mensajero", "Curaca", "Principal1", "Principal2", "Habitante1", "Habitante2", "Habitante3",
]
const OBJECT_NAMES: Array[String] = ["QueroChicha", "Pututu", "OfrendaPachamama"]


func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))


func test_meeting_keeps_objects_clear() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	var pututu: Pututu = world.get_node_or_null("Pututu") as Pututu
	var plaza: Marker3D = world.get_node_or_null("PlazaPoint") as Marker3D
	if event == null or pututu == null or plaza == null:
		world.free()
		return false
	pututu.audio_stream = null
	event.start()
	# En CALL la reunión ya se ha formado y los personajes han llegado.
	var steps: int = 0
	while event.phase != MessengerEvent.Phase.CALL and steps < MAX_STEPS:
		event.step(STEP_SECONDS)
		steps += 1
	for _extra: int in range(20):
		event.step(STEP_SECONDS)
	var ok: bool = event.phase == MessengerEvent.Phase.CALL
	for actor_name: String in ACTOR_NAMES:
		var actor: Node3D = world.get_node_or_null("Llacta/NPCs/" + actor_name) as Node3D
		if actor == null:
			ok = false
			continue
		ok = ok and actor.global_position.z <= plaza.global_position.z + 0.5
		for object_name: String in OBJECT_NAMES:
			var object_node: Node3D = world.get_node_or_null(object_name) as Node3D
			if object_node == null:
				ok = false
				continue
			ok = ok and _flat_distance(actor.global_position, object_node.global_position) >= MIN_CLEARANCE
	world.free()
	return ok
