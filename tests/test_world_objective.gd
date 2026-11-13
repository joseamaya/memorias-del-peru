extends RefCounted
## Comprueba que el mundo arranca con un objetivo visible, que las tareas lo
## hacen avanzar y que el mirador anuncia la espera. Es la respuesta permanente
## a «¿qué hago?».

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"

var _wait_announced: bool = false


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


func _on_subtitle(text_key: StringName, _seconds: float) -> void:
	if text_key == &"PCH_NARR_WAIT":
		_wait_announced = true


func test_world_objective_starts_with_quero() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var ok: bool = (
		hud != null
		and world.call("get_objective") == MundoBase.Objective.QUERO
		and hud.is_showing_objective()
		and hud.get_objective_text() == tr("PCH_OBJ_QUERO")
	)
	world.free()
	return ok


func test_world_objective_advances_with_quero() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var quero: QueroChicha = world.get_node_or_null("QueroChicha") as QueroChicha
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var ok: bool = quero != null and player != null and hud != null
	if ok:
		# Sin audio en la prueba: el objeto debe avanzar el objetivo por señal.
		quero.audio_stream = null
		quero.interact(player)
		ok = world.call("get_objective") == MundoBase.Objective.OFFERING
		ok = ok and hud.get_objective_text() == tr("PCH_OBJ_OFFERING")
	world.free()
	return ok


func test_world_objective_reaches_mirador() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var quero: QueroChicha = world.get_node_or_null("QueroChicha") as QueroChicha
	var ofrenda: OfrendaPachamama = world.get_node_or_null("OfrendaPachamama") as OfrendaPachamama
	var talk: NpcTalk = world.get_node_or_null("Llacta/NPCs/Curaca/Talk") as NpcTalk
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	if player == null or quero == null or ofrenda == null or talk == null or event == null:
		world.free()
		return false
	event.subtitle_requested.connect(_on_subtitle)
	quero.audio_stream = null
	ofrenda.audio_stream = null
	quero.interact(player)
	ofrenda.interact(player)
	talk.interact(player)
	var reached_talk: bool = world.call("get_objective") == MundoBase.Objective.MIRADOR
	# El mirador está en la terraza este; se coloca al jugador en su vertical.
	player.global_position = Vector3(52.0, 2.45, 0.0)
	var arrived: bool = world.call("check_mirador")
	var ok: bool = (
		reached_talk
		and arrived
		and world.call("get_objective") == MundoBase.Objective.WAIT
		and _wait_announced
	)
	world.free()
	return ok
