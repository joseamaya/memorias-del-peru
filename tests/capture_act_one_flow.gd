extends Node
## Captura la primera experiencia del acto I para revisión visual:
## la mañana, el entrenamiento de honda y la lista de encargos.
##
##   godot --path . --resolution 1280x720 res://tests/scenes/capture_act_one_flow.tscn

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"
const OUTPUT_DIR: String = "/tmp/opencode"


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	CampaignState.clear()
	CampaignState.set_flag(&"intro_vista", 1)
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		get_tree().quit(1)
		return
	var world: Node = packed.instantiate()
	add_child(world)
	await _frames(10)
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var director: ActOneDirector = world.get_node_or_null("ActOneDirector") as ActOneDirector
	var mother: NpcActor = world.get_node_or_null("Llacta/NPCs/Habitante1") as NpcActor
	if player == null or hud == null or director == null or mother == null:
		print("CAPTURA_ACTO_I_FALLO")
		get_tree().quit(1)
		return
	# I.1: desde la plaza hacia la madre, con la casa detrás.
	var to_plaza: Vector3 = Vector3(0.0, 0.0, 2.0) - mother.global_position
	to_plaza.y = 0.0
	to_plaza = to_plaza.normalized()
	var mother_flat: Vector3 = mother.global_position + to_plaza * 4.0
	mother_flat.y = 0.05
	player.global_position = mother_flat
	player.look_at(Vector3(mother.global_position.x, 0.05, mother.global_position.z), Vector3.UP)
	await _frames(20)
	_save("acto_i_01_manana.png")
	var talks: Array[Node] = mother.find_children("*", "TalkPoint", true, false)
	if talks.is_empty():
		print("CAPTURA_ACTO_I_SIN_HABLA")
		get_tree().quit(1)
		return
	var talk: TalkPoint = talks[0] as TalkPoint
	talk.interact(player)
	var drill: SlingDrill = director.training_drill()
	if drill == null:
		print("CAPTURA_ACTO_I_SIN_ENTRENAMIENTO")
		get_tree().quit(1)
		return
	# I.1b: el blanco de honda en la plaza; el primer tiro entra por la acción
	# real de ataque, no por el método de prueba.
	player.global_position = Vector3(-2.0, 0.05, 9.0)
	player.look_at(Vector3(-2.0, 0.05, 4.0), Vector3.UP)
	await _frames(20)
	var click: InputEventAction = InputEventAction.new()
	click.action = &"attack"
	click.pressed = true
	Input.parse_input_event(click)
	await _frames(4)
	print("CAPTURA_ACTO_I_CLIC ", drill.progress())
	_save("acto_i_02_honda.png")
	for shot: int in range(2):
		drill.throw_stone()
		await get_tree().create_timer(0.55).timeout
	await _frames(4)
	_save("acto_i_03_encargos.png")
	var agua: TaskPoint = world.get_node_or_null("TaskAgua") as TaskPoint
	if agua != null:
		agua.interact(player)
		await _frames(4)
		_save("acto_i_04_encargo_hecho.png")
	print("CAPTURA_ACTO_I_OK")
	world.queue_free()
	await _frames(10)
	await get_tree().create_timer(0.3).timeout
	CampaignState.clear()
	get_tree().quit(0)


func _frames(count: int) -> void:
	for _index: int in range(count):
		await get_tree().process_frame


func _save(file_name: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	if image == null:
		return
	image.save_png(OUTPUT_DIR + "/" + file_name)
	print("CAPTURA ", OUTPUT_DIR + "/" + file_name)
