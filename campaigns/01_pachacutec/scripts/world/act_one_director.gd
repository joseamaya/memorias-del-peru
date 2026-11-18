class_name ActOneDirector
extends Node
## Dirige los objetivos del acto I: pasos, encargos, entrenamiento y diálogos.
##
## Vive como hijo de la llacta. No conoce la lógica interna del mundo: se
## engancha a sus puntos de interacción, a sus tareas y al diálogo, y traduce
## todo a [SliceStep]. El HUD muestra el objetivo en [QuestTracker]; el mundo
## recibe marcadores [QuestMarker].

signal step_started(step: SliceStep)
signal finished

const TASK_ORDER: Array[StringName] = [&"agua", &"maiz", &"telar", &"pirca"]
const TASK_PROMPT_KEYS: Dictionary[StringName, StringName] = {
	&"agua": &"PCH_TASK_AGUA",
	&"maiz": &"PCH_TASK_MAIZ",
	&"telar": &"PCH_TASK_TELAR",
	&"pirca": &"PCH_TASK_PIRCA",
}
@export var sequence: SliceSequence

var _world: Llacta = null
var _hud: PlayerHud = null
var _player: PlayerFPS = null
var _tracker: QuestTracker = null
var _dialogue: DialogueRunner = null
var _flow: SliceFlow = null
var _step: SliceStep = null
var _tasks: Array[TaskPoint] = []
var _task_markers: Dictionary[StringName, QuestMarker] = {}
var _markers: Dictionary[StringName, QuestMarker] = {}
var _active_marker: StringName = &""
var _drill: SlingDrill = null
var _progress: int = 0
var _finished: bool = false
var _bound: bool = false


func _ready() -> void:
	bind_now.call_deferred()


## La llacta termina de construir sus tareas en su propio _ready; este método
## permite enganchar el flujo en cuanto están listas, sin esperar un frame.
func bind_now() -> void:
	if _bound:
		return
	_bound = true
	_bind()


func current_step() -> SliceStep:
	return _step


func objective_count() -> int:
	return _progress


## Panel de objetivos, para las pruebas de aceptación.
func tracker() -> QuestTracker:
	return _tracker


## Entrenamiento de honda, para las pruebas de aceptación.
func training_drill() -> SlingDrill:
	return _drill


## Marcador del paso actual (`Mother`, `Training`…), o vacío si no tiene.
func current_marker() -> StringName:
	return _step.marker if _step != null else &""


## Indica si el marcador [param key] está visible ahora mismo.
func is_marker_visible(key: StringName) -> bool:
	var marker: QuestMarker = _markers.get(key)
	return marker != null and marker.visible


func is_finished() -> bool:
	return _finished


func _bind() -> void:
	_world = get_parent() as Llacta
	if _world == null or _world.act != 1:
		return
	_hud = _world.hud
	_player = _world.player
	_dialogue = _world.dialogue
	if _hud == null or _player == null or sequence == null:
		return
	_tracker = _hud.get_node_or_null("QuestTracker") as QuestTracker
	_tasks = []
	for node: Node in _world.find_children("Task*", "TaskPoint", true, false):
		var task: TaskPoint = node as TaskPoint
		if task != null:
			_tasks.append(task)
			task.completed.connect(_on_task_completed)
			_build_task_marker(task)
	_build_markers()
	_build_training()
	_connect_talks()
	_connect_dialogue()
	_flow = SliceFlow.new(sequence)
	_start(_flow.current())


func _connect_talks() -> void:
	var mother: NpcActor = _world.get_node_or_null("Llacta/NPCs/Habitante1") as NpcActor
	if mother != null:
		for node: Node in mother.find_children("*", "TalkPoint", true, false):
			var talk: TalkPoint = node as TalkPoint
			if talk != null:
				talk.spoke.connect(_on_mother_spoke)
				break
	var doubt: CampPoint = _world.get_node_or_null("DudaPoint") as CampPoint
	if doubt != null:
		doubt.requested.connect(_on_doubt_requested)


func _connect_dialogue() -> void:
	if _dialogue != null:
		_dialogue.finished.connect(_on_dialogue_finished)


func _start(step: SliceStep) -> void:
	if step == null:
		_finish()
		return
	_step = step
	_progress = 0
	var task_rows: Array[Dictionary] = _task_rows()
	if _tracker != null:
		_tracker.begin_step(step, task_rows,
			step.count if step.kind in [SliceStep.Kind.TASKS, SliceStep.Kind.DRILL] else 0)
	_set_training(step.kind == SliceStep.Kind.DRILL)
	_set_task_markers(step.kind == SliceStep.Kind.TASKS)
	if step.kind == SliceStep.Kind.DIALOGUE and step.marker == &"Messenger" \
			and not _world._messenger_spawned:
		_world._spawn_messenger()
		_make_messenger_marker()
	_show_marker(step.marker)
	if step.checkpoint != &"":
		CampaignProgress.save_checkpoint(_world, _player.global_position)
		SessionLog.mark(&"step", String(step.checkpoint))
	step_started.emit(step)


func _complete() -> void:
	if _step == null:
		return
	var notice: StringName = _step.notice
	_set_training(false)
	_set_task_markers(false)
	_show_marker(&"")
	var next: SliceStep = _flow.advance()
	if notice != &"" and _tracker != null:
		_tracker.show_banner(notice)
	_start(next)


func _finish() -> void:
	if _finished:
		return
	_finished = true
	_step = null
	_set_training(false)
	_set_task_markers(false)
	_show_marker(&"")
	if _tracker != null:
		_tracker.finish()
	finished.emit()


func _on_mother_spoke(_actor: Node3D, _line_key: StringName) -> void:
	if _step != null and _step.kind == SliceStep.Kind.DIALOGUE and _step.marker == &"Mother":
		_complete()


func _on_doubt_requested() -> void:
	# La conversación la abre la llacta; aquí solo se marca el paso.
	if _step != null and _step.kind == SliceStep.Kind.DIALOGUE and _step.marker == &"Doubt":
		_show_marker(&"Doubt")


func _on_dialogue_finished() -> void:
	if _step == null or _step.kind != SliceStep.Kind.DIALOGUE:
		return
	if _step.marker == &"Doubt":
		_complete()
	elif _step.marker == &"Messenger":
		_complete()
	elif _step.marker == &"Plaza" and _world._assembly_done:
		_complete()


func _on_task_completed(task_id: StringName) -> void:
	if _step == null:
		return
	if _step.kind != SliceStep.Kind.TASKS:
		# Los encargos se pueden adelantar durante la mañana o el entrenamiento.
		# Después del paso de tareas el flujo no rebobina: el cuarto encargo
		# puede hacerse, pero no devuelve al jugador a un paso cerrado.
		if not _can_jump_to_tasks():
			return
		_jump_to_tasks()
		if _step == null or _step.kind != SliceStep.Kind.TASKS:
			return
	_progress += 1
	if _tracker != null:
		_tracker.set_tasks(_task_rows())
		_tracker.set_progress(_progress)
	var marker: QuestMarker = _task_markers.get(task_id)
	if marker != null:
		marker.set_marker_visible(false)
	if _progress >= _step.count:
		_complete()


func _can_jump_to_tasks() -> bool:
	if _step == null:
		return false
	if _step.kind == SliceStep.Kind.DRILL:
		return true
	return _step.kind == SliceStep.Kind.DIALOGUE and _step.marker == &"Mother"


func _jump_to_tasks() -> void:
	if _flow == null:
		return
	while _flow.current() != null and _flow.current().kind != SliceStep.Kind.TASKS:
		_flow.advance()
	_start(_flow.current())


func _on_training_hit(progress: int, _total: int) -> void:
	_progress = progress
	if _tracker != null:
		_tracker.set_progress(progress)


func _on_training_completed() -> void:
	_complete()


func _task_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for task_id: StringName in TASK_ORDER:
		var done: bool = false
		for task: TaskPoint in _tasks:
			if task.task_id == task_id:
				done = task.is_done()
				break
		rows.append({"key": TASK_PROMPT_KEYS[task_id], "done": done})
	return rows


func _set_task_markers(value: bool) -> void:
	for marker: QuestMarker in _task_markers.values():
		marker.set_marker_visible(value)


func _show_marker(marker: StringName) -> void:
	if _active_marker == marker:
		return
	if _markers.has(_active_marker):
		_markers[_active_marker].set_marker_visible(false)
	_active_marker = marker
	if _markers.has(marker):
		_markers[marker].set_marker_visible(true)


func _build_markers() -> void:
	var mother: NpcActor = _world.get_node_or_null("Llacta/NPCs/Habitante1") as NpcActor
	if mother != null:
		_markers[&"Mother"] = _add_marker(mother, &"PCH_MARK_MOTHER")
	var doubt: CampPoint = _world.get_node_or_null("DudaPoint") as CampPoint
	if doubt != null:
		_markers[&"Doubt"] = _add_marker(doubt as Node3D, &"PCH_MARK_DOUBT")
	var plaza: Vector3 = _world._plaza_center_flat()
	var plaza_marker: QuestMarker = QuestMarker.new()
	plaza_marker.name = "MarkerAssembly"
	plaza_marker.position = plaza
	_world.add_child(plaza_marker)
	plaza_marker.setup(&"PCH_MARK_ASSEMBLY")
	plaza_marker.set_marker_visible(false)
	_markers[&"Plaza"] = plaza_marker


func _make_messenger_marker() -> void:
	if _markers.has(&"Messenger"):
		return
	var point: CampPoint = _world.get_node_or_null("MessengerPoint") as CampPoint
	if point != null:
		_markers[&"Messenger"] = _add_marker(point as Node3D, &"PCH_MARK_MESSENGER")


func _add_marker(parent: Node3D, key: StringName) -> QuestMarker:
	var marker: QuestMarker = QuestMarker.new()
	marker.name = "QuestMarker"
	parent.add_child(marker)
	marker.setup(key)
	marker.set_marker_visible(false)
	return marker


func _build_task_marker(task: TaskPoint) -> void:
	var marker: QuestMarker = QuestMarker.new()
	marker.name = "TaskMarker"
	marker.position = Vector3(0.0, 0.9, 0.0)
	task.add_child(marker)
	marker.setup(task.prompt_key)
	marker.set_marker_visible(false)
	_task_markers[task.task_id] = marker


func _build_training() -> void:
	_drill = SlingDrill.new()
	_world.add_child(_drill)
	_drill.setup(_player, _hud)
	_drill.hit.connect(_on_training_hit)
	_drill.completed.connect(_on_training_completed)
	var marker: QuestMarker = _add_marker(_drill, &"PCH_MARK_TRAINING")
	marker.position = Vector3(0.0, 2.2, 0.0)
	_markers[&"Training"] = marker


func _set_training(value: bool) -> void:
	if _drill == null:
		return
	if value and _step != null:
		_drill.start(_step.count)
	else:
		_drill.stop()
	if _markers.has(&"Training"):
		_markers[&"Training"].set_marker_visible(value)
	_progress = 0
