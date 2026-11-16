extends Node
## Herramienta de grabación: recorre los cinco actos y el título para revisar
## el arco completo en vídeo. No encadena con R: instancia cada escena como
## hija, la juega y la libera, para que el grabador sobreviva al cambio.
##
##   godot --path . --write-movie build/partida_completa.avi --fixed-fps 10 \
##       --resolution 1280x720 res://tests/scenes/record_campaign.tscn
##
## El AVI se captura a 10 fps y se convierte a 30 fps con ffmpeg para que el
## archivo final pese poco. MovieWriter usa el viewport del proyecto, no
## `--resolution`: para 1280×720 hay que ajustar temporalmente
## display/window/size/viewport_* o grabar a 1920.

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
	await _wait_for_intro(world)
	await _show_home(world, player, 2.5)
	player.global_position = Vector3(0.0, 0.05, 12.0)
	player.rotation.y = 0.0
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
	# Muestra las tres armas y la munición antes de la emboscada.
	paso.call("_switch_weapon", 1)
	await _wait(0.8)
	paso.call("_switch_weapon", 2)
	await _wait(0.8)
	paso.call("_switch_weapon", 0)
	await _wait(0.6)
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
	await _wait(0.4)
	_choose(hud, 0)
	paso.call("_on_dialogue_advanced")
	await _wait(1.0)
	paso.call("_on_sneak_requested")
	await _wait(0.8)
	# El vídeo enseña el combate: aunque el sigilo esté disponible, la
	# emboscada se resuelve peleando.
	paso.set("_sneak", false)
	paso.call("_start_ambush")
	await _wait(0.5)
	player.global_position = Vector3(0.0, 0.05, 1.0)
	player.rotation.y = 0.0
	print("REC_COMBAT_A2_START frame=", Engine.get_frames_drawn())
	await _fight(paso, player, 4.0)
	print("REC_COMBAT_A2_END frame=", Engine.get_frames_drawn())
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
	# El vídeo se coloca en el centro de la plaza para que las oleadas se vean
	# de cerca; la lógica de la defensa no cambia.
	player.global_position = Vector3(0.0, 0.05, 0.0)
	player.rotation.y = 0.0
	for wave: int in range(3):
		await _wait(0.6)
		print("REC_COMBAT_A3_WAVE%d_START frame=" % wave, Engine.get_frames_drawn())
		await _fight(ciudad, player, 3.0)
		print("REC_COMBAT_A3_WAVE%d_END frame=" % wave, Engine.get_frames_drawn())
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
	await _show_home(world, player, 2.5)
	player.global_position = Vector3(0.0, 0.05, 2.0)
	player.rotation.y = 0.0
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
	await _show_home(world, player, 2.5)
	player.global_position = Vector3(0.0, 0.05, 12.0)
	player.rotation.y = 0.0
	for task_name: String in [
		"RebuildPirca", "RebuildTerraza", "RebuildAcequia", "RebuildTelar", "RebuildCasa",
	]:
		var task: Node = world.get_node_or_null(task_name)
		if task != null:
			task.call("interact", player)
			await _wait(1.0)
	await _wait(5.0)
	world.free()


func _wait_for_intro(world: Node) -> void:
	var cards: Node = world.get_node_or_null("UILayer/IntroCards")
	var guard: int = 0
	while cards != null and cards.call("is_playing") == true and guard < 20:
		await _wait(3.0)
		cards.call("skip_card")
		guard += 1
	await _wait(0.8)


func _show_home(world: Node, player: Node3D, seconds: float) -> void:
	var raw: Variant = world.call("_home_door_position")
	if not (raw is Vector3):
		return
	var home: Vector3 = raw
	var house: Node3D = world.get_node_or_null("Llacta/Houses/House04") as Node3D
	var outward: Vector3 = Vector3.FORWARD
	if house != null:
		outward = home - house.global_position
	outward.y = 0.0
	outward = outward.normalized()
	var at: Vector3 = home + outward * 3.0
	at.y = 0.05
	player.global_position = at
	player.look_at(Vector3(home.x, at.y, home.z), Vector3.UP)
	var head: Node3D = player.get_node_or_null("Head") as Node3D
	if head != null:
		head.rotation.x = 0.0
	await _wait(seconds)


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


## Combate real para el vídeo: encara al enemigo más cercano y ataca con el
## arma activa. No mata a nadie: deja que se vean anticipación, impacto,
## hitstop y fichas antes de que el guion resuelva la escena.
func _fight(world: Node, player: Node3D, seconds: float) -> void:
	var hud: Node = world.get_node_or_null("UILayer/HUD")
	if hud != null and hud.has_method("clear_subtitle"):
		hud.call("clear_subtitle")
	var loadout: CombatLoadout = player.get_node_or_null("CombatLoadout") as CombatLoadout
	if loadout == null:
		return
	# La partida guionizada no recoge piedras: sin munición el vídeo mostraría
	# un arma que no ataca.
	loadout.set_ammo(24)
	var character: CharacterState = player.get_node_or_null("CharacterState") as CharacterState
	if character != null:
		character.heal(100.0)
	var head: Node3D = player.get_node_or_null("Head") as Node3D
	if head != null:
		# El rayo sale del centro de la cámara; sin inclinarla, pasa por encima
		# del cuerpo del chanca y el golpe no conecta.
		head.rotation.x = -0.18
	var elapsed: float = 0.0
	while elapsed < seconds:
		var enemy: AmbushEnemy = _nearest_enemy(world, player)
		if enemy == null:
			break
		var to_enemy: Vector3 = enemy.global_position - player.global_position
		to_enemy.y = 0.0
		if to_enemy.length() > 0.05:
			player.rotation.y = atan2(-to_enemy.x, -to_enemy.z)
		# Se llama al ataque de la escena, no al loadout: la escena guarda el
		# daño pendiente y resuelve el rayo en la ventana activa.
		if world.has_method("_attack"):
			world.call("_attack")
		await _wait(0.25)
		elapsed += 0.25


func _nearest_enemy(world: Node, player: Node3D) -> AmbushEnemy:
	var best: AmbushEnemy = null
	var best_distance: float = INF
	for child: Node in world.get_children():
		var enemy: AmbushEnemy = child as AmbushEnemy
		if enemy == null or not enemy.is_alive():
			continue
		var distance: float = player.global_position.distance_to(enemy.global_position)
		if distance < best_distance:
			best_distance = distance
			best = enemy
	return best
