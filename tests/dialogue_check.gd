extends SceneTree
## Comprueba la capa de conversación y diario en el mundo (F3.5.a).
##
## Habla con Chanan Cury Coca desde su interactable, recorre el grafo, comprueba
## que la bandera llega a WorldState y que el diario se abre y se cierra.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const SETTLE_FRAMES: int = 600
const MIN_GRAPHS: int = 6


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("DIALOGUE_FAIL no scene")
		quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	root.add_child(world)
	var population: CityPopulation = null
	for _i: int in SETTLE_FRAMES:
		await process_frame
		population = world.get_population()
		if population != null and population.is_built():
			break
	var presenter: DialoguePresenter = world.get_dialogue()
	var hud: PlayerHud = world.get_player_hud()
	var journal: Journal = world.get_journal()
	var player: PlayerFPS = world.get_player()
	var ok: bool = population != null and presenter != null and hud != null
	ok = ok and journal != null and player != null
	if not ok:
		printerr("DIALOGUE_FAIL sin poblacion, presentador, HUD o diario")
		world.queue_free()
		await process_frame
		quit(1)
		return
	ok = ok and presenter.get_graph_count() >= MIN_GRAPHS

	# La curáca tiene que estar viva y con su punto de conversación.
	var talk: NpcInteractable = null
	for _i: int in 120:
		await process_frame
		for node: Node in world.find_children("*", "NpcInteractable", true, false):
			var candidate: NpcInteractable = node as NpcInteractable
			if candidate.definition != null and candidate.definition.id == &"npc_curaca":
				talk = candidate
				break
		if talk != null:
			break
	ok = ok and talk != null
	if talk == null:
		printerr("DIALOGUE_FAIL sin interactable de la curaca")
		world.queue_free()
		await process_frame
		quit(1)
		return
	ok = ok and talk.is_available()
	ok = ok and talk.get_interaction_text().contains("Chanan")

	WorldStateService.instance().clear()
	var world_state: WorldStateService = WorldStateService.instance()
	talk.interact(player)
	await process_frame
	ok = ok and presenter.is_active()
	ok = ok and hud.is_dialogue_open()
	var panel: DialoguePanel = hud.get_dialogue_panel()
	ok = ok and not panel.get_text().begins_with("PCH_")
	ok = ok and not panel.get_speaker().begins_with("PCH_")
	ok = ok and panel.get_choice_count() == 2

	# «¿Qué hacemos?» lleva a los encargos y fija la bandera.
	hud.dialogue_choice.emit(0)
	await process_frame
	ok = ok and world_state.has_flag(&"m01_encargos")
	ok = ok and panel.get_text() != ""
	hud.dialogue_advanced.emit()
	await process_frame
	ok = ok and not presenter.is_active()
	ok = ok and not hud.is_dialogue_open()

	# Diario: se abre con J y se cierra con J, y no deja mover al jugador.
	ok = ok and journal.add_quest(&"m01_diario", &"PCH_M01_DIARIO_TITULO", &"PCH_M01_DIARIO_CUERPO")
	world.toggle_journal()
	await process_frame
	ok = ok and hud.is_journal_open()
	ok = ok and hud.get_journal_panel().get_entry_count() == 1
	ok = ok and player.is_controls_locked()
	world.toggle_journal()
	await process_frame
	ok = ok and not hud.is_journal_open()

	print("DIALOGUE graphs=", presenter.get_graph_count(), " talkers=", talk.get_interaction_text())
	world.queue_free()
	await process_frame
	await process_frame
	if ok:
		print("DIALOGUE_OK")
	else:
		printerr("DIALOGUE_FAIL")
	quit(0 if ok else 1)
