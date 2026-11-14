class_name TitleScreen
extends Control
## Pantalla de título (ADR-0024): nombre del juego, subtítulo de la campaña y
## dos botones, Comenzar y Salir. Es la escena principal del proyecto.
##
## No conoce ninguna campaña: lee la configurada en el proyecto mediante
## [CampaignInfo]. Comenzar tiene el foco, así que Intro también empieza.

const TITLE_KEY: StringName = &"UI_GAME_TITLE"
const START_KEY: StringName = &"UI_START"
const QUIT_KEY: StringName = &"UI_QUIT"
const BACKGROUND_COLOR: Color = Color(0.05, 0.04, 0.035, 1.0)
const TITLE_FONT_SIZE: int = 72
const SUBTITLE_FONT_SIZE: int = 30
const BUTTON_FONT_SIZE: int = 28
const BUTTON_WIDTH: float = 280.0

var _campaign: CampaignInfo = null
var _title_label: Label = null
var _subtitle_label: Label = null
var _start_button: Button = null
var _quit_button: Button = null


func _ready() -> void:
	# Debe responder aunque una pausa anterior hubiera quedado activa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_campaign = CampaignInfo.load_configured()
	_build()
	_start_button.disabled = _campaign == null or not _campaign.has_entry_scene()
	_start_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	# En el título, Esc no pausa: no hay partida que detener.
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()


## Campaña que empezará al pulsar Comenzar, o `null` si no hay ninguna válida.
func get_campaign() -> CampaignInfo:
	return _campaign


## Texto visible del título del juego.
func get_title_text() -> String:
	return _title_label.text


## Texto visible del subtítulo de la campaña.
func get_subtitle_text() -> String:
	return _subtitle_label.text


## Botón Comenzar, para las pruebas.
func get_start_button() -> Button:
	return _start_button


## Botón Salir, para las pruebas.
func get_quit_button() -> Button:
	return _quit_button


## Empieza la campaña configurada. Devuelve si se pudo pedir el cambio.
func start_campaign() -> bool:
	if _campaign == null or not _campaign.has_entry_scene():
		return false
	var manager: Node = get_node_or_null("/root/GameManager")
	if manager != null:
		manager.call("set_paused", false)
	CampaignState.clear()
	var changed: bool = get_tree().change_scene_to_file(_campaign.entry_scene) == OK
	if changed:
		SessionLog.mark(&"campaign_start")
	return changed


func _on_quit_pressed() -> void:
	var manager: Node = get_node_or_null("/root/GameManager")
	if manager != null:
		manager.call("request_quit")
	else:
		get_tree().quit()


func _on_start_pressed() -> void:
	start_campaign()


func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var background: ColorRect = ColorRect.new()
	background.name = "Background"
	background.color = BACKGROUND_COLOR
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var column: VBoxContainer = VBoxContainer.new()
	column.name = "Column"
	column.set_anchors_preset(Control.PRESET_CENTER)
	column.grow_horizontal = Control.GROW_DIRECTION_BOTH
	column.grow_vertical = Control.GROW_DIRECTION_BOTH
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 18)
	add_child(column)

	_title_label = _make_label("Title", tr(String(TITLE_KEY)), TITLE_FONT_SIZE)
	column.add_child(_title_label)
	var subtitle: String = ""
	if _campaign != null and not String(_campaign.subtitle_key).is_empty():
		subtitle = tr(String(_campaign.subtitle_key))
	_subtitle_label = _make_label("Subtitle", subtitle, SUBTITLE_FONT_SIZE)
	_subtitle_label.modulate = Color(1.0, 1.0, 1.0, 0.75)
	column.add_child(_subtitle_label)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0.0, 48.0)
	column.add_child(spacer)

	_start_button = _make_button("Start", tr(String(START_KEY)))
	_start_button.pressed.connect(_on_start_pressed)
	column.add_child(_start_button)
	_quit_button = _make_button("Quit", tr(String(QUIT_KEY)))
	_quit_button.pressed.connect(_on_quit_pressed)
	column.add_child(_quit_button)


func _make_label(node_name: String, text: String, font_size: int) -> Label:
	var label: Label = Label.new()
	label.name = node_name
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	return label


func _make_button(node_name: String, text: String) -> Button:
	var button: Button = Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = Vector2(BUTTON_WIDTH, 0.0)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE)
	return button
