extends RefCounted
## Prueba de jugador nuevo del acto I: el recorrido completo desde la mañana
## hasta la asamblea, sin saltarse pasos.
##
## Comprueba lo que ve el jugador: objetivo en pantalla, marcador del mundo,
## lista de encargos solo cuando toca y entrenamiento de honda con tres
## aciertos reales. También cubre el cuarto encargo después del cierre de
## tareas, que no debe devolver el flujo al paso anterior.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"


func test_act_one_flow() -> bool:
	CampaignState.clear()
	CampaignState.set_flag(&"intro_vista", 1)
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	if world == null:
		return false
	tree.root.add_child(world)
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var director: ActOneDirector = world.get_node_or_null("ActOneDirector") as ActOneDirector
	if player == null or hud == null or director == null:
		return _fail(world)
	var tracker: QuestTracker = director.tracker()
	var journal: Journal = player.get_node_or_null("Journal") as Journal
	var mother: NpcActor = world.get_node_or_null("Llacta/NPCs/Habitante1") as NpcActor
	var talk: TalkPoint = null
	if mother != null:
		for node: Node in mother.find_children("*", "TalkPoint", true, false):
			talk = node as TalkPoint
			if talk != null:
				break
	if tracker == null or journal == null or talk == null:
		return _fail(world)

	# I.1: la mañana empieza con un objetivo concreto y la madre señalada.
	var ok: bool = tracker.is_active()
	ok = ok and tracker.objective_text() == tr("PCH_OBJ_MORNING")
	ok = ok and director.is_marker_visible(&"Mother")
	ok = ok and not tracker.tasks_visible()
	ok = ok and not director.is_marker_visible(&"Training")
	ok = ok and journal.has(&"encargos") and not journal.is_done(&"encargos")
	var checkpoint: Dictionary = CampaignState.get_data(&"checkpoint", {})
	ok = ok and not checkpoint.is_empty()
	ok = ok and str(checkpoint.get("scene", "")) == WORLD_PATH

	# Hablar con la madre abre el entrenamiento, no los encargos.
	talk.interact(player)
	ok = ok and director.current_marker() == &"Training"
	ok = ok and tracker.objective_text() == tr("PCH_OBJ_TRAIN").format({"count": 0})
	ok = ok and director.is_marker_visible(&"Training")
	ok = ok and not director.is_marker_visible(&"Mother")
	ok = ok and not tracker.tasks_visible()
	ok = ok and tracker.banner_text() == tr("PCH_NOTICE_TRAINING")
	var drill: SlingDrill = director.training_drill()
	if drill == null or not drill.is_active():
		return _fail(world)

	# Tres tiros apuntados desde la plaza. El blanco está en (-2, 0, 4).
	player.global_position = Vector3(-2.0, 0.05, 9.0)
	player.rotation = Vector3.ZERO
	player.head.rotation = Vector3.ZERO
	for shot: int in range(2):
		ok = ok and drill.throw_stone()
		ok = ok and drill.progress() == shot + 1
		ok = ok and tracker.objective_text() == tr("PCH_OBJ_TRAIN").format({"count": shot + 1})
	# El tercer acierto cierra el paso y el panel cambia en el acto.
	ok = ok and drill.throw_stone()
	ok = ok and not drill.is_active()
	ok = ok and tracker.banner_text() == tr("PCH_NOTICE_TASKS")

	# I.2: los cuatro encargos aparecen en pantalla y bastan tres.
	ok = ok and director.current_step() != null
	ok = ok and director.current_step().kind == SliceStep.Kind.TASKS
	ok = ok and tracker.tasks_visible()
	ok = ok and tracker.task_rows().size() == 4
	ok = ok and tracker.task_rows()[0].text == tr("PCH_TASK_AGUA")
	ok = ok and tracker.task_rows()[3].text == tr("PCH_TASK_PIRCA")
	ok = ok and not director.is_marker_visible(&"Training")
	var agua: TaskPoint = world.get_node_or_null("TaskAgua") as TaskPoint
	if agua == null:
		return _fail(world)
	var agua_marker: QuestMarker = agua.get_node_or_null("TaskMarker") as QuestMarker
	ok = ok and agua_marker != null and agua_marker.visible
	agua.interact(player)
	ok = ok and not agua_marker.visible
	ok = ok and tracker.task_rows()[0].text == tr("PCH_TASK_AGUA")
	ok = ok and tracker.objective_text() == tr("PCH_OBJ_ENCARGOS").format({"count": 1})

	# Los otros dos encargos cierran el paso.
	for task_name: String in ["TaskMaiz", "TaskTelar"]:
		var task: TaskPoint = world.get_node_or_null(task_name) as TaskPoint
		ok = ok and task != null
		if task != null:
			task.interact(player)
	ok = ok and director.current_marker() == &"Doubt"
	ok = ok and tracker.objective_text() == tr("PCH_OBJ_DUDA")
	ok = ok and tracker.banner_text() == tr("PCH_NOTICE_DOUBT")
	ok = ok and journal.is_done(&"encargos")
	ok = ok and not tracker.tasks_visible()
	ok = ok and director.is_marker_visible(&"Doubt")

	# El cuarto encargo se puede hacer, pero no rebobina la duda.
	var pirca: TaskPoint = world.get_node_or_null("TaskPirca") as TaskPoint
	ok = ok and pirca != null and pirca.is_available()
	if pirca != null:
		pirca.interact(player)
	ok = ok and director.current_marker() == &"Doubt"

	# I.3: la duda se escucha y cierra al terminar la conversación.
	var doubt: CampPoint = world.get_node_or_null("DudaPoint") as CampPoint
	if doubt == null:
		return _fail(world)
	doubt.interact(player)
	ok = ok and hud.is_dialogue_open()
	hud.get_dialogue_panel().choice_selected.emit(0)
	world.call("_on_dialogue_advanced")
	ok = ok and director.current_marker() == &"Messenger"
	ok = ok and tracker.objective_text() == tr("PCH_OBJ_MESSENGER")
	ok = ok and tracker.banner_text() == tr("PCH_NOTICE_MESSENGER")
	ok = ok and director.is_marker_visible(&"Messenger")
	# El punto de la duda se retira y el mensajero queda dentro del rayo.
	ok = ok and not doubt.is_available()
	var messenger: CampPoint = world.get_node_or_null("MessengerPoint") as CampPoint
	if messenger == null:
		return _fail(world)
	var gap: Vector2 = Vector2(
		messenger.global_position.x - doubt.global_position.x,
		messenger.global_position.z - doubt.global_position.z)
	ok = ok and gap.length() <= 3.0
	ok = ok and messenger.is_available()

	# I.4: el mensajero aparece después de la duda, no al tercer encargo.
	messenger.interact(player)
	ok = ok and hud.is_dialogue_open()
	var panel: DialoguePanel = hud.get_dialogue_panel()
	var listen_button: Button = null
	for node: Node in panel.get_node("Panel/Margin/VBox/Choices").get_children():
		var button: Button = node as Button
		if button != null and button.visible and button.text.contains(tr("PCH_MSG_LISTEN")):
			listen_button = button
			break
	ok = ok and listen_button != null
	if listen_button != null:
		listen_button.pressed.emit()
	var advance: InputEventAction = InputEventAction.new()
	advance.action = &"interact"
	advance.pressed = true
	panel._unhandled_input(advance)
	ok = ok and CampaignState.has_flag(&"noticia_chanca")
	ok = ok and director.current_marker() == &"Plaza"
	ok = ok and tracker.objective_text() == tr("PCH_OBJ_ASAMBLEA")
	ok = ok and tracker.banner_text() == tr("PCH_NOTICE_ASSEMBLY")
	ok = ok and director.is_marker_visible(&"Plaza")

	# I.5: la asamblea cierra el acto y el panel se retira.
	player.global_position = Vector3(0.0, 0.05, 2.0)
	world.call("_process", 0.016)
	ok = ok and hud.is_dialogue_open()
	hud.get_dialogue_panel().choice_selected.emit(0)
	world.call("_on_dialogue_advanced")
	ok = ok and world.get("_assembly_done") == true
	ok = ok and director.is_finished()
	ok = ok and tracker.objective_text().is_empty()
	ok = ok and not tracker.is_banner_visible()
	world.free()
	CampaignState.clear()
	return ok


func _fail(world: Node) -> bool:
	world.free()
	CampaignState.clear()
	return false
