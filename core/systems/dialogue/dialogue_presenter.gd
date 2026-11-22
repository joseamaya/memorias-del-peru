class_name DialoguePresenter
extends Node
## Presenta una conversación de [DialogueRunner] en el HUD.
##
## No conoce campañas: la campaña registra sus grafos por identificador. Las
## banderas que fija el diálogo se escriben en [WorldState] y se emiten para que
## la misión reaccione; al empezar se siembran con las del mundo, para que las
## condiciones lean el estado real y sobrevivan al guardado.

signal started(dialogue_id: StringName)
signal finished
signal flag_changed(key: StringName, value: int)

var hud: PlayerHud = null
var player: PlayerFPS = null
var runner: DialogueRunner = null

var _graphs: Dictionary[StringName, DialogueGraph] = {}
var _dialogue_id: StringName = &""
var _speaker: String = ""
var _text: String = ""
var _choices: Array[String] = []


func _ready() -> void:
	add_to_group(&"dialogue_presenter")
	runner = DialogueRunner.new()
	runner.name = "Runner"
	add_child(runner)
	runner.started.connect(_on_started)
	runner.finished.connect(_on_finished)
	runner.line_shown.connect(_on_line)
	runner.choices_shown.connect(_on_choices)
	runner.flag_changed.connect(_on_flag)


## Ata el HUD y el jugador. Debe llamarse antes de empezar una conversación.
func setup(hud_node: PlayerHud, player_node: PlayerFPS) -> void:
	hud = hud_node
	player = player_node
	if hud == null:
		return
	hud.dialogue_advanced.connect(_on_advanced)
	hud.dialogue_choice.connect(_on_choice)


## Registra un grafo con su identificador estable.
func register(dialogue_id: StringName, graph: DialogueGraph) -> void:
	if dialogue_id != &"" and graph != null:
		_graphs[dialogue_id] = graph


## Registra todos los `.tres` de una carpeta, con el nombre del archivo como ID.
##
## Usa [method ResourceLoader.list_directory] y no [method DirAccess.get_files_at]:
## en una exportación los recursos de texto se guardan como `.tres.remap` y
## `DirAccess` devuelve ese nombre, que no termina en `.tres`. El listado del
## cargador de recursos resuelve el remapeo y devuelve la ruta lógica.
func register_directory(path: String) -> int:
	var count: int = 0
	for file_name: String in ResourceLoader.list_directory(path):
		if not file_name.ends_with(".tres"):
			continue
		var graph: DialogueGraph = load(path.path_join(file_name)) as DialogueGraph
		if graph == null:
			continue
		_graphs[StringName(file_name.get_basename())] = graph
		count += 1
	return count


func has_graph(dialogue_id: StringName) -> bool:
	return _graphs.has(dialogue_id)


func get_graph_count() -> int:
	return _graphs.size()


func is_active() -> bool:
	return runner != null and runner.is_active()


## Empieza la conversación [param dialogue_id] mirando a [param target].
func start(dialogue_id: StringName, target: Node3D = null) -> bool:
	if runner == null or runner.is_active() or not _graphs.has(dialogue_id):
		return false
	var graph: DialogueGraph = _graphs[dialogue_id]
	# Se valida antes de bloquear: un grafo sin nodo de entrada dejaría al
	# jugador sin controles y sin diálogo.
	if graph == null or graph.find_node(graph.entry_id) == null:
		return false
	var world_state: WorldStateService = WorldStateService.instance()
	if world_state != null:
		runner.seed_flags(world_state.get_flags())
	_dialogue_id = dialogue_id
	if player != null:
		player.begin_dialogue(target)
	var began: bool = runner.start(graph)
	if not began:
		_dialogue_id = &""
		if player != null:
			player.end_dialogue()
	return began


func _on_started() -> void:
	started.emit(_dialogue_id)


func _on_line(speaker_key: StringName, text_key: StringName) -> void:
	_speaker = tr(String(speaker_key))
	_text = tr(String(text_key))
	_choices.clear()
	_refresh()


func _on_choices(text_keys: Array[StringName]) -> void:
	_choices.clear()
	for key: StringName in text_keys:
		_choices.append(tr(String(key)))
	_refresh()


func _on_flag(key: StringName, value: int) -> void:
	var world_state: WorldStateService = WorldStateService.instance()
	if world_state != null:
		world_state.set_flag(key, value)
	flag_changed.emit(key, value)


func _on_finished() -> void:
	if hud != null:
		hud.hide_dialogue()
	if player != null:
		player.end_dialogue()
	_dialogue_id = &""
	finished.emit()


func _refresh() -> void:
	if hud == null:
		return
	if hud.is_dialogue_open():
		hud.update_dialogue(_speaker, _text, _choices)
	else:
		hud.show_dialogue(_speaker, _text, _choices)


func _on_advanced() -> void:
	if runner != null and runner.is_active():
		runner.advance()


func _on_choice(index: int) -> void:
	if runner != null and runner.is_active():
		runner.choose(index)
