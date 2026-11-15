extends RefCounted
## Comprueba el diálogo y el diario dentro del mundo (Fase 6).

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


func _journal_event() -> InputEventAction:
	var event: InputEventAction = InputEventAction.new()
	event.action = &"journal"
	event.pressed = true
	return event


func test_world_dialogue_and_journal() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var talk: NpcTalk = world.get_node_or_null("Llacta/NPCs/Tejedora/Talk") as NpcTalk
	var runner: DialogueRunner = world.get_node_or_null("PlayerFPS/DialogueRunner") as DialogueRunner
	var journal: Journal = world.get_node_or_null("PlayerFPS/Journal") as Journal
	if hud == null or player == null or talk == null or runner == null or journal == null:
		world.free()
		return false
	talk.interact(player)
	var ok: bool = hud.is_dialogue_open()
	ok = ok and hud.get_dialogue_panel().get_text() == tr("PCH_TALK_WEAVER")
	ok = ok and hud.get_dialogue_panel().get_choice_count() == 2
	ok = ok and player.call("is_controls_locked") == true
	# Primera opción: la tejedora explica el teñido y deja una entrada de Memoria.
	hud.get_dialogue_panel().choice_selected.emit(0)
	ok = ok and runner.get_current_node() != null
	ok = ok and runner.get_current_node().id == &"dye"
	ok = ok and journal.has(&"mem_telar")
	ok = ok and journal.get_entry(&"mem_telar").badge == &"A"
	ok = ok and journal.get_entry(&"mem_telar").source_key == &"PCH-010"
	world.call("_on_dialogue_advanced")
	ok = ok and not hud.is_dialogue_open()
	player.call("_update_focus", 1.0)
	ok = ok and player.call("is_controls_locked") == false
	# J abre y cierra el diario.
	world.call("_unhandled_input", _journal_event())
	ok = ok and hud.is_journal_open()
	ok = ok and player.call("is_controls_locked") == true
	world.call("_unhandled_input", _journal_event())
	ok = ok and not hud.is_journal_open()
	ok = ok and player.call("is_controls_locked") == false
	world.free()
	return ok
