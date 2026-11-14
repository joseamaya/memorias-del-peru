extends RefCounted
## Comprueba que los nueve textos del museo viven en el diario: encargos,
## conversaciones, quero, ofrenda y llegada del mensajero (Fase 6).

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


func _choose_first(world: Node, hud: PlayerHud, actor_path: String, player: PlayerFPS) -> bool:
	var talk: NpcTalk = world.get_node_or_null(actor_path) as NpcTalk
	if talk == null:
		return false
	talk.interact(player)
	if not hud.is_dialogue_open():
		return false
	hud.get_dialogue_panel().choice_selected.emit(0)
	world.call("_on_dialogue_advanced")
	return not hud.is_dialogue_open()


func test_world_memories() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var journal: Journal = world.get_node_or_null("PlayerFPS/Journal") as Journal
	if hud == null or player == null or journal == null:
		world.free()
		return false
	var ok: bool = _choose_first(world, hud, "Llacta/NPCs/Agricultor/Talk", player)
	ok = ok and journal.has(&"mem_terraza")
	ok = ok and _choose_first(world, hud, "Llacta/NPCs/Curaca/Talk", player)
	ok = ok and journal.has(&"mem_plaza")
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
	var tasks: Array[TaskPoint] = [
		world.get_node_or_null("TaskAgua") as TaskPoint,
		world.get_node_or_null("TaskMaiz") as TaskPoint,
		world.get_node_or_null("TaskTelar") as TaskPoint,
		world.get_node_or_null("TaskPirca") as TaskPoint,
	]
	for task: TaskPoint in tasks:
		if task == null:
			world.free()
			return false
	tasks[0].interact(player)
	ok = ok and journal.has(&"mem_vivienda")
	tasks[1].interact(player)
	ok = ok and journal.has(&"mem_chicha")
	tasks[2].interact(player)
	ok = ok and journal.has(&"mem_telar")
	ok = ok and journal.has(&"mem_mirador")
	tasks[3].interact(player)
	ok = ok and journal.has(&"mem_corral")
	ok = ok and journal.get_entries(JournalEntry.Kind.MEMORY).size() == 9
	world.free()
	return ok
