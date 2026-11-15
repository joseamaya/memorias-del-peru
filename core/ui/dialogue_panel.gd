class_name DialoguePanel
extends Control
## Panel de diálogo en primera persona: hablante, línea y hasta cuatro opciones.
##
## No conoce el grafo ni la campaña. La escena que lo abre le pasa los textos ya
## traducidos y escucha [signal advanced] y [signal choice_selected].
##
## Controles: E avanza cuando no hay opciones; 1–4 eligen. El ratón también
## puede pulsar las opciones.

signal advanced
signal choice_selected(index: int)

const MAX_CHOICES: int = 4

@onready var speaker_label: Label = $Panel/Margin/VBox/SpeakerLabel
@onready var text_label: Label = $Panel/Margin/VBox/TextLabel
@onready var choices_box: VBoxContainer = $Panel/Margin/VBox/Choices
@onready var hint_label: Label = $Panel/Margin/VBox/HintLabel

var _open: bool = false
var _buttons: Array[Button] = []
var _choice_count: int = 0


func _ready() -> void:
	theme = UiTheme.build()
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	var index: int = 0
	for child: Node in choices_box.get_children():
		var button: Button = child as Button
		if button == null:
			continue
		button.pressed.connect(_on_choice_pressed.bind(index))
		_buttons.append(button)
		index += 1


## Abre el panel con una línea y sus opciones ya traducidas.
func open(speaker: String, text: String, choices: Array[String]) -> void:
	speaker_label.text = speaker
	text_label.text = text
	_show_choices(choices)
	_open = true
	visible = true


## Sustituye la línea y las opciones sin cerrar el panel.
func set_line(speaker: String, text: String, choices: Array[String]) -> void:
	if not _open:
		open(speaker, text, choices)
		return
	speaker_label.text = speaker
	text_label.text = text
	_show_choices(choices)


## Cierra el panel.
func close() -> void:
	if not _open:
		return
	_open = false
	visible = false
	_choice_count = 0


## Indica si el panel está abierto.
func is_open() -> bool:
	return _open


## Número de opciones visibles.
func get_choice_count() -> int:
	return _choice_count


## Texto de la línea, para las pruebas.
func get_text() -> String:
	return text_label.text


## Texto del hablante, para las pruebas.
func get_speaker() -> String:
	return speaker_label.text


func _show_choices(choices: Array[String]) -> void:
	_choice_count = mini(choices.size(), MAX_CHOICES)
	for index: int in range(_buttons.size()):
		var button: Button = _buttons[index]
		if index < _choice_count:
			button.text = "%d. %s" % [index + 1, choices[index]]
			button.visible = true
		else:
			button.text = ""
			button.visible = false
	hint_label.text = tr("UI_DIALOGUE_ADVANCE") if _choice_count == 0 else tr("UI_DIALOGUE_CHOOSE")


func _on_choice_pressed(index: int) -> void:
	if not _open or index < 0 or index >= _choice_count:
		return
	choice_selected.emit(index)


func _unhandled_input(event: InputEvent) -> void:
	if not _open:
		return
	if event is InputEventKey:
		var key: InputEventKey = event as InputEventKey
		if key.pressed and not key.echo:
			var index: int = _key_index(key.keycode)
			if index >= 0 and index < _choice_count:
				get_viewport().set_input_as_handled()
				choice_selected.emit(index)
				return
	if event.is_action_pressed("interact") and _choice_count == 0:
		get_viewport().set_input_as_handled()
		advanced.emit()


static func _key_index(keycode: Key) -> int:
	match keycode:
		KEY_1:
			return 0
		KEY_2:
			return 1
		KEY_3:
			return 2
		KEY_4:
			return 3
	return -1
