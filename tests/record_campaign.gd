extends Node
## Herramienta de grabación: recorre los cinco actos y el título para revisar
## el arco completo en vídeo. No encadena con R: instancia cada escena como
## hija, la juega y la libera, para que el grabador sobreviva al cambio.
##
##   godot --path . --write-movie build/campana.avi --fixed-fps 30 \
##       --resolution 1280x720 res://tests/scenes/record_campaign.tscn

const TITLE: String = "res://core/ui/title_screen.tscn"
const ACT_ONE: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"
const ACT_TWO: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"
const ACT_THREE: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"
const ACT_FOUR: String = "res://campaigns/01_pachacutec/scenes/world/llacta_act4.tscn"
const ACT_FIVE: String = "res://campaigns/01_pachacutec/scenes/world/llacta_act5.tscn"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	print("REC_START")
	await _show_title(2.5)
	print("REC_TITLE")
	await _act_one()
	print("REC_A1")
	await _act_two()
	print("REC_A2")
	await _act_three()
	print("REC_A3")
	await _act_four()
	print("REC_A4")
	await _act_five()
	print("REC_A5")
	await _show_title(2.5)
	print("GRABACION_OK")
	get_tree().quit()


func _show_title(seconds: float) -> void:
	var scene: Node = await _open(TITLE)
	if scene != null:
		await _wait(seconds)
		scene.free()


func _act_one() -> void:
	var world: Node = await _open(ACT_ONE)
	if world == null:
		return
	await _wait(2.0)
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	var hud: Node = world.get_node_or_null("UILayer/HUD")
	if player == null or hud == null:
		world.free()
		return
	for task_name: String in ["TaskAgua", "TaskPirca", "TaskTelar"]:
		var task: Node = world.get_node_or_null(task_name)
		if task != null:
			task.call("interact", player)
			await _wait(0.9)
	var messenger: Node = world.get_node_or_null("MessengerPoint")
	if messenger != null:
		messenger.call("interact", player)
		await _wait(1.2)
		_choose_last(hud)
		await _wait(0.8)
		world.call("_on_dialogue_advanced")
		await _wait(1.2)
	for index: int in range(3):
		var account: Node = world.get_node_or_null("Account%d" % index)
		if account != null:
			account.call("interact", player)
			await _wait(0.7)
	player.global_position = Vector3(0.0, 0.05, 2.0)
	world.call("_process", 0.1)
	await _wait(1.5)
	_choose(hud, 1)
	await _wait(1.6)
	world.call("_on_dialogue_advanced")
	await _wait(2.2)
	world.free()


func _act_two() -> void:
	var paso: Node = await _open(ACT_TWO)
	if paso == null:
		return
	await _wait(2.0)
	var player: Node3D = paso.get_node_or_null("PlayerFPS") as Node3D
	var hud: Node = paso.get_node_or_null("UILayer/HUD")
	var camp: Node = paso.get_node_or_null("CampPoint")
	if player == null or hud == null or camp == null:
		paso.free()
		return
	var sisa: Node = paso.get_node_or_null("SisaPoint")
	if sisa != null:
		sisa.call("interact", player)
		await _wait(1.0)
		_choose(hud, 0)
		paso.call("_on_dialogue_advanced")
		await _wait(0.8)
	camp.call("interact", player)
	await _wait(1.2)
	_choose(hud, 2)
	paso.call("_on_dialogue_advanced")
	await _wait(1.0)
	paso.call("_on_sneak_requested")
	await _wait(0.8)
	paso.call("_start_ambush")
	await _wait(1.5)
	for index: int in range(1, 5):
		var enemy: Node = paso.get_node_or_null("Ambusher%d" % index)
		if enemy != null:
			enemy.call("take_hit", 200.0)
	paso.call("_physics_process", 0.1)
	await _wait(1.2)
	_choose(hud, 0)
	paso.call("_on_dialogue_advanced")
	await _wait(1.0)
	_choose(hud, 0)
	paso.call("_on_dialogue_advanced")
	await _wait(1.0)
	_choose(hud, 0)
	paso.call("_on_dialogue_advanced")
	await _wait(2.2)
	paso.free()


func _act_three() -> void:
	var ciudad: Node = await _open(ACT_THREE)
	if ciudad == null:
		return
	await _wait(2.0)
	var player: Node3D = ciudad.get_node_or_null("PlayerFPS") as Node3D
	var hud: Node = ciudad.get_node_or_null("UILayer/HUD")
	if player == null or hud == null:
		ciudad.free()
		return
	var arrival: Node = ciudad.get_node_or_null("ArrivalPoint")
	if arrival != null:
		arrival.call("interact", player)
		await _wait(1.0)
		_choose(hud, 0)
		ciudad.call("_on_dialogue_advanced")
		await _wait(1.0)
	for index: int in range(3):
		var point: Node = ciudad.get_node_or_null("Recruit%d" % index)
		if point != null:
			point.call("interact", player)
			await _wait(0.8)
			_choose(hud, 0)
			ciudad.call("_on_dialogue_advanced")
			await _wait(0.8)
	var prep: Node = ciudad.get_node_or_null("Prep2")
	if prep != null:
		prep.call("interact", player)
		await _wait(1.0)
	var trap: Node = ciudad.get_node_or_null("TrapPoint")
	if trap != null:
		trap.call("interact", player)
		await _wait(1.0)
		_choose(hud, 0)
		ciudad.call("_on_dialogue_advanced")
		await _wait(1.0)
	var cusi: Node = ciudad.get_node_or_null("CusiPoint")
	if cusi != null:
		cusi.call("interact", player)
		await _wait(1.0)
		_choose(hud, 0)
		ciudad.call("_on_dialogue_advanced")
	await _wait(1.5)
	for _wave: int in range(3):
		for child: Node in ciudad.get_children():
			if child is AmbushEnemy and (child as AmbushEnemy).is_alive():
				child.call("take_hit", 200.0)
		ciudad.call("_physics_process", 0.1)
		await _wait(1.0)
	await _wait(2.5)
	ciudad.free()


func _act_four() -> void:
	var world: Node = await _open(ACT_FOUR)
	if world == null:
		return
	await _wait(2.0)
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	var hud: Node = world.get_node_or_null("UILayer/HUD")
	if player == null or hud == null:
		world.free()
		return
	for index: int in range(3):
		var account: Node = world.get_node_or_null("Account%d" % index)
		if account != null:
			account.call("interact", player)
			await _wait(0.7)
	player.global_position = Vector3(0.0, 0.05, 2.0)
	world.call("_process", 0.1)
	await _wait(2.0)
	_choose(hud, 0)
	await _wait(2.0)
	world.call("_on_dialogue_advanced")
	await _wait(2.5)
	world.free()


func _act_five() -> void:
	var world: Node = await _open(ACT_FIVE)
	if world == null:
		return
	await _wait(2.0)
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	if player == null:
		world.free()
		return
	for task_name: String in ["RebuildPirca", "RebuildTerraza", "RebuildAcequia", "RebuildTelar"]:
		var task: Node = world.get_node_or_null(task_name)
		if task != null:
			task.call("interact", player)
			await _wait(1.0)
	await _wait(5.0)
	world.free()


func _open(path: String) -> Node:
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return null
	var scene: Node = packed.instantiate()
	if scene == null:
		return null
	add_child(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	return scene


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _choose(hud: Node, index: int) -> void:
	var panel: Node = hud.get_node_or_null("DialoguePanel")
	if panel != null:
		panel.emit_signal("choice_selected", index)


func _choose_last(hud: Node) -> void:
	var panel: DialoguePanel = hud.get_node_or_null("DialoguePanel") as DialoguePanel
	if panel != null:
		panel.emit_signal("choice_selected", panel.get_choice_count() - 1)
