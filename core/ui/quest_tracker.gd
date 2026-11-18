class_name QuestTracker
extends Control
## Panel de objetivos del acto: paso actual y lista de encargos.
##
## Vive dentro del HUD y lee el estado del [ActOneDirector]. No conoce la
## campaña: recibe pasos y tareas. El objetivo se escribe en el `ObjectiveLabel`
## del HUD; la lista de encargos es propia y se oculta en diálogo o diario.

const PANEL_TOP: float = 68.0
const PANEL_WIDTH: float = 560.0
const PANEL_HEIGHT: float = 238.0

var _hud: PlayerHud = null
var _objective_label: Label = null
var _journal_panel: JournalPanel = null
var _step: SliceStep = null
var _active: bool = false
var _show_tasks: bool = false
var _total: int = 0
var _progress: int = 0
var _tasks: Array[Dictionary] = []
var _task_panel: PanelContainer = null
var _task_title: Label = null
var _task_rows: Array[Label] = []
var _task_status: Array[Label] = []
var _banner: Label = null
var _banner_remaining: float = 0.0


func _ready() -> void:
	theme = UiTheme.build()
	_hud = get_parent() as PlayerHud
	if _hud != null:
		_objective_label = _hud.get_node_or_null("ObjectiveLabel") as Label
		_journal_panel = _hud.get_node_or_null("JournalPanel") as JournalPanel
	_build_panel()
	_build_banner()
	visible = true


## Empieza un paso. [param tasks] son las filas de encargo y [param total] el
## número que pide el paso.
func begin_step(step: SliceStep, tasks: Array[Dictionary], total: int) -> void:
	_step = step
	_active = true
	_show_tasks = step != null and step.kind == SliceStep.Kind.TASKS
	_tasks = tasks
	_total = total
	_progress = 0
	if _objective_label != null:
		_objective_label.text = _objective_text()
		_objective_label.visible = true
	_build_tasks()


## Actualiza el contador del paso.
func set_progress(count: int) -> void:
	_progress = clampi(count, 0, _total)
	if _objective_label != null:
		_objective_label.text = _objective_text()
	if _task_title != null:
		_task_title.text = _task_title_text()


## Anuncia el cierre de un paso en una banda sobre el mundo. [param key] es la
## clave de localización del aviso; no sustituye al objetivo ni a la pista.
func show_banner(key: StringName, seconds: float = 2.6) -> void:
	if _banner == null or key == &"":
		return
	_banner.text = tr(String(key))
	_banner.visible = true
	_banner.modulate.a = 1.0
	_banner_remaining = maxf(seconds, 0.1)


## Texto del aviso a la vista, para las pruebas.
func banner_text() -> String:
	return _banner.text if _banner != null else ""


## Indica si el aviso sigue a la vista.
func is_banner_visible() -> bool:
	return _banner != null and _banner.visible


## Sustituye las filas de encargo (por ejemplo, al completar una tarea).
func set_tasks(tasks: Array[Dictionary]) -> void:
	_tasks = tasks
	_build_tasks()


## Termina el paso y oculta el panel.
func finish() -> void:
	_step = null
	_active = false
	_show_tasks = false
	_tasks.clear()
	_progress = 0
	if _objective_label != null:
		_objective_label.text = ""
		_objective_label.visible = false
	if _task_panel != null:
		_task_panel.visible = false
	if _banner != null:
		_banner.visible = false
		_banner.text = ""
	_banner_remaining = 0.0


## Indica si el panel de pasos está dirigiendo el objetivo del HUD.
func is_active() -> bool:
	return _active


## Indica si la lista de encargos debe verse en el paso actual.
func tasks_visible() -> bool:
	return _active and _show_tasks and not _tasks.is_empty()


## Paso actual, para las pruebas.
func current_step() -> SliceStep:
	return _step


## Texto del objetivo a la vista, para las pruebas.
func objective_text() -> String:
	return _objective_label.text if _objective_label != null else ""


## Filas de encargo visibles, para las pruebas.
func task_rows() -> Array[Label]:
	return _task_rows


func _process(delta: float) -> void:
	if not _active:
		return
	var blocked: bool = _hud == null or _hud.is_cinematic() or _hud.is_journal_open()
	if _objective_label != null:
		_objective_label.visible = _step != null and not blocked and not _objective_label.text.is_empty()
	if _task_panel != null:
		_task_panel.visible = tasks_visible() and not blocked
	if _banner != null:
		if _banner_remaining > 0.0:
			_banner_remaining = maxf(_banner_remaining - delta, 0.0)
			_banner.modulate.a = minf(1.0, _banner_remaining / 0.35)
			if _banner_remaining <= 0.0:
				_banner.text = ""
		_banner.visible = _banner_remaining > 0.0 and not blocked


func _objective_text() -> String:
	if _step == null:
		return ""
	return tr(String(_step.objective)).format({"count": _progress})


func _task_title_text() -> String:
	var done: int = 0
	for task: Dictionary in _tasks:
		var value: Variant = task.get("done", false)
		if value is bool and value:
			done += 1
	return "%s (%d/%d)" % [tr("PCH_TASKS_TITLE"), done, _total]


## Banda inferior para el aviso de paso; no compite con el objetivo ni con la
## pista de interacción.
func _build_banner() -> void:
	if _banner != null:
		return
	_banner = Label.new()
	_banner.name = "StepBanner"
	_banner.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_banner.offset_left = -500.0
	_banner.offset_right = 500.0
	_banner.offset_top = -320.0
	_banner.offset_bottom = -276.0
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_banner.add_theme_font_size_override(&"font_size", 28)
	_banner.add_theme_color_override(&"font_color", Color(0.98, 0.9, 0.7))
	_banner.add_theme_color_override(&"font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	_banner.add_theme_constant_override(&"outline_size", 8)
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.visible = false
	add_child(_banner)


func _build_panel() -> void:
	if _task_panel != null:
		return
	_task_panel = PanelContainer.new()
	_task_panel.name = "TaskPanel"
	_task_panel.offset_left = 40.0
	_task_panel.offset_top = PANEL_TOP
	_task_panel.offset_right = 40.0 + PANEL_WIDTH
	_task_panel.offset_bottom = PANEL_TOP + PANEL_HEIGHT
	_task_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.06, 0.05, 0.78)
	style.set_corner_radius_all(4)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	_task_panel.add_theme_stylebox_override(&"panel", style)
	add_child(_task_panel)
	var content: VBoxContainer = VBoxContainer.new()
	content.add_theme_constant_override(&"separation", 4)
	_task_panel.add_child(content)
	_task_title = Label.new()
	_task_title.add_theme_font_size_override(&"font_size", 24)
	_task_title.add_theme_color_override(&"font_color", Color(0.98, 0.9, 0.7))
	content.add_child(_task_title)
	for index: int in range(4):
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override(&"separation", 8)
		content.add_child(row)
		var status: Label = Label.new()
		status.custom_minimum_size = Vector2(24.0, 0.0)
		status.add_theme_font_size_override(&"font_size", 22)
		status.add_theme_color_override(&"font_color", Color(0.72, 0.64, 0.48))
		row.add_child(status)
		var label: Label = Label.new()
		label.add_theme_font_size_override(&"font_size", 21)
		label.add_theme_color_override(&"font_color", Color(0.9, 0.84, 0.7))
		row.add_child(label)
		_task_status.append(status)
		_task_rows.append(label)
	var hint: Label = Label.new()
	hint.text = tr("PCH_HINT_JOURNAL")
	hint.add_theme_font_size_override(&"font_size", 18)
	hint.add_theme_color_override(&"font_color", Color(0.68, 0.63, 0.52))
	content.add_child(hint)
	_task_panel.visible = false


func _build_tasks() -> void:
	if _task_panel == null:
		return
	_task_title.text = _task_title_text()
	for index: int in range(_task_rows.size()):
		if index >= _tasks.size():
			_task_rows[index].text = ""
			_task_status[index].text = ""
			continue
		var task: Dictionary = _tasks[index]
		var done_value: Variant = task.get("done", false)
		var done: bool = done_value if done_value is bool else false
		var key_value: Variant = task.get("key", &"")
		var key: StringName = &""
		if key_value is StringName:
			key = key_value
		elif key_value is String:
			key = StringName(str(key_value))
		_task_rows[index].text = tr(String(key))
		_task_status[index].text = "✓" if done else "○"
		_task_status[index].add_theme_color_override(&"font_color",
			Color(0.55, 0.82, 0.48) if done else Color(0.72, 0.64, 0.48))
		_task_rows[index].add_theme_color_override(&"font_color",
			Color(0.62, 0.74, 0.55) if done else Color(0.9, 0.84, 0.7))
