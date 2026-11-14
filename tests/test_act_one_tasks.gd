extends RefCounted
## Comprueba el acto I sin museo: cuatro encargos, oficio, diario y llegada del
## mensajero al tercero (biblia de la campaña §4).

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


func test_act_one_tasks() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var character: CharacterState = world.get_node_or_null("PlayerFPS/CharacterState") as CharacterState
	var journal: Journal = world.get_node_or_null("PlayerFPS/Journal") as Journal
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	var tasks: Array[TaskPoint] = [
		world.get_node_or_null("TaskAgua") as TaskPoint,
		world.get_node_or_null("TaskMaiz") as TaskPoint,
		world.get_node_or_null("TaskTelar") as TaskPoint,
		world.get_node_or_null("TaskPirca") as TaskPoint,
	]
	if hud == null or player == null or character == null or journal == null or event == null:
		world.free()
		return false
	var ok: bool = tasks.size() == 4
	for task: TaskPoint in tasks:
		ok = ok and task != null
	if not ok:
		world.free()
		return false
	# El museo ya no existe.
	ok = ok and hud.get_node_or_null("TourCard") == null
	ok = ok and world.get_node_or_null("SpotPlaza") == null
	# Cuatro encargos apuntados en el diario.
	ok = ok and journal.count() == 4
	ok = ok and journal.has(&"q_agua") and journal.has(&"q_pirca")
	ok = ok and tasks[0].get_interaction_text() == tr("PCH_TASK_AGUA")
	# Primer encargo: agua; fija el oficio y sube monte a rango 1.
	tasks[0].interact(player)
	ok = ok and tasks[0].is_done() and not tasks[0].is_available()
	ok = ok and journal.is_done(&"q_agua")
	ok = ok and character.get_skill(&"monte") == 1
	ok = ok and event.phase == MessengerEvent.Phase.IDLE
	# Segundo: maíz; todavía no llega el mensajero.
	tasks[1].interact(player)
	ok = ok and journal.is_done(&"q_maiz")
	ok = ok and event.phase == MessengerEvent.Phase.IDLE
	# Tercero: telar; el mensajero sale.
	tasks[2].interact(player)
	ok = ok and journal.is_done(&"q_telar")
	ok = ok and event.phase == MessengerEvent.Phase.ARRIVAL
	# Repetir no cambia nada.
	tasks[0].interact(player)
	ok = ok and character.get_skill(&"monte") == 1
	# Beber y ofrecer dejan su Memoria, sin tarjetas.
	var quero: QueroChicha = world.get_node_or_null("QueroChicha") as QueroChicha
	if quero != null:
		quero.audio_stream = null
		quero.interact(player)
	ok = ok and journal.has(&"mem_quero")
	var ofrenda: OfrendaPachamama = world.get_node_or_null("OfrendaPachamama") as OfrendaPachamama
	if ofrenda != null:
		ofrenda.audio_stream = null
		ofrenda.interact(player)
	ok = ok and journal.has(&"mem_ofrenda")
	world.free()
	return ok
