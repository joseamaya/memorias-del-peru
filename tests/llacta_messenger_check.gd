extends SceneTree
## Comprobación de extremo a extremo del mensajero del acto I: desde el punto
## de la duda, el rayo real enfoca al mensajero, abre el diálogo, elige
## «Escuchar» y cierra el paso. No es parte de la suite unitaria porque
## necesita física y varios fotogramas.
##
##   godot --headless --path . --script res://tests/llacta_messenger_check.gd

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"


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
	await _frames(8)
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: Node = world.get_node_or_null("UILayer/HUD")
	var director: Node = world.get_node_or_null("ActOneDirector")
	var panel: DialoguePanel = hud.get_node_or_null("DialoguePanel") as DialoguePanel
	if player == null or hud == null or director == null or panel == null:
		print("MENSAJERO_CHECK_FAIL piezas")
		quit(1)
		return
	var mother: NpcActor = world.get_node_or_null("Llacta/NPCs/Habitante1") as NpcActor
	var talk: TalkPoint = null
	if mother != null:
		for node: Node in mother.find_children("*", "TalkPoint", true, false):
			talk = node as TalkPoint
			if talk != null:
				break
	var drill_value: Variant = director.call("training_drill")
	var drill: Node = null
	if drill_value is Node:
		drill = drill_value
	if talk == null or drill == null:
		print("MENSAJERO_CHECK_FAIL inicio")
		quit(1)
		return
	talk.interact(player)
	await _frames(2)
	player.global_position = Vector3(-2.0, 0.05, 9.0)
	player.rotation = Vector3.ZERO
	for _shot: int in range(3):
		drill.call("throw_stone")
		await _frames(2)
	for task_name: String in ["TaskAgua", "TaskMaiz", "TaskTelar"]:
		var task: TaskPoint = world.get_node_or_null(task_name) as TaskPoint
		if task != null:
			task.interact(player)
	await _frames(2)
	var doubt: CampPoint = world.get_node_or_null("DudaPoint") as CampPoint
	if doubt == null:
		print("MENSAJERO_CHECK_FAIL duda")
		quit(1)
		return
	doubt.interact(player)
	await _frames(2)
	panel.choice_selected.emit(0)
	world.call("_on_dialogue_advanced")
	await _frames(30)
	var messenger: CampPoint = world.get_node_or_null("MessengerPoint") as CampPoint
	if doubt.is_available() or messenger == null:
		print("MENSAJERO_CHECK_FAIL duda activa")
		quit(1)
		return
	# Colocarse donde quedó la duda y mirar al mensajero: el rayo debe enfocarlo.
	player.global_position = Vector3(-6.5, 0.05, 4.2)
	var to: Vector3 = messenger.global_position - player.global_position
	player.rotation.y = atan2(-to.x, -to.z)
	player.set("_pitch", 0.0)
	await _frames(3)
	player.update_interaction()
	await physics_frame
	player.try_interact()
	await _frames(2)
	if not panel.is_open():
		print("MENSAJERO_CHECK_FAIL rayo")
		quit(1)
		return
	var listen: Button = null
	for node: Node in panel.get_node("Panel/Margin/VBox/Choices").get_children():
		var button: Button = node as Button
		if button != null and button.visible and button.text.contains(tr("PCH_MSG_LISTEN")):
			listen = button
			break
	if listen == null:
		print("MENSAJERO_CHECK_FAIL opcion")
		quit(1)
		return
	listen.pressed.emit()
	var advance: InputEventAction = InputEventAction.new()
	advance.action = &"interact"
	advance.pressed = true
	panel._unhandled_input(advance)
	await _frames(2)
	var news: Variant = state.call("has_flag", &"noticia_chanca")
	var marker: Variant = director.call("current_marker")
	if not (news is bool and news) or not (marker is StringName and marker == &"Plaza"):
		print("MENSAJERO_CHECK_FAIL cierre")
		quit(1)
		return
	print("MENSAJERO_CHECK_OK")
	if state != null:
		state.call("clear")
	world.queue_free()
	await _frames(5)
	quit(0)


func _frames(count: int) -> void:
	for _index: int in range(count):
		await physics_frame
