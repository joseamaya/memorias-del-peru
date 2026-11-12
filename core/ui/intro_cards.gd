class_name IntroCards
extends Control
## Tarjetas de texto a pantalla completa antes de que empiece el juego.
##
## Muestra una lista de textos ya traducidos, uno tras otro, sobre fondo negro y
## con fundidos. Cada tarjeta dura su tiempo de lectura (la misma regla que los
## subtítulos, ADR-0012) y la acción `interact` pasa a la siguiente. Al terminar
## la última, el fondo se funde y emite [signal finished]. No conoce ninguna
## campaña: los textos y la indicación llegan desde fuera (ADR-0023).

signal finished

## Fundido de entrada y de salida de cada texto.
const TEXT_FADE: float = 0.6
## Fundido del fondo negro al terminar la última tarjeta.
const BACKGROUND_FADE: float = 1.2
## Tiempo mínimo a la vista antes de aceptar `interact`, para que una pulsación
## doble no se salte una tarjeta sin leerla.
const MIN_SKIP_SECONDS: float = 0.6
const TEXT_FONT_SIZE: int = 36
const HINT_FONT_SIZE: int = 20
const TEXT_MAX_WIDTH: float = 1100.0

var _background: ColorRect = null
var _text_label: Label = null
var _hint_label: Label = null
var _texts: Array[String] = []
var _index: int = -1
var _card_seconds: float = 0.0
var _card_elapsed: float = 0.0
var _closing_elapsed: float = -1.0


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_background = ColorRect.new()
	_background.name = "Background"
	_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.color = Color(0.0, 0.0, 0.0, 1.0)
	add_child(_background)
	_text_label = Label.new()
	_text_label.name = "Text"
	_text_label.set_anchors_preset(Control.PRESET_CENTER)
	_text_label.offset_left = -TEXT_MAX_WIDTH * 0.5
	_text_label.offset_right = TEXT_MAX_WIDTH * 0.5
	_text_label.offset_top = -160.0
	_text_label.offset_bottom = 160.0
	_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.add_theme_font_size_override("font_size", TEXT_FONT_SIZE)
	_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_text_label)
	_hint_label = Label.new()
	_hint_label.name = "Hint"
	_hint_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hint_label.offset_left = -400.0
	_hint_label.offset_right = 400.0
	_hint_label.offset_top = -90.0
	_hint_label.offset_bottom = -50.0
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.add_theme_font_size_override("font_size", HINT_FONT_SIZE)
	_hint_label.modulate = Color(1.0, 1.0, 1.0, 0.55)
	_hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hint_label)


func _ready() -> void:
	# Se detiene con la pausa aunque cuelgue de un HUD que no se detiene.
	process_mode = Node.PROCESS_MODE_PAUSABLE


func _process(delta: float) -> void:
	advance(delta)


func _unhandled_input(event: InputEvent) -> void:
	if not is_playing():
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		skip_card()


## Empieza a mostrar [param texts] (ya traducidos) con la indicación
## [param hint] al pie. Sin textos termina en el acto.
func play(texts: Array[String], hint: String) -> void:
	_texts = texts.duplicate()
	_hint_label.text = hint
	_closing_elapsed = -1.0
	if _texts.is_empty():
		_index = -1
		visible = false
		finished.emit()
		return
	visible = true
	_background.color.a = 1.0
	_show_card(0)


## Indica si hay una tarjeta a la vista o el fondo aún se está fundiendo.
func is_playing() -> bool:
	return visible and (_index >= 0 or _closing_elapsed >= 0.0)


## Índice de la tarjeta visible, o -1 si no hay ninguna.
func current_index() -> int:
	return _index


## Texto de la tarjeta visible.
func current_text() -> String:
	return _text_label.text if _index >= 0 else ""


## Segundos que dura una tarjeta con [param text].
static func card_seconds(text: String) -> float:
	return PlayerHud.reading_seconds(text)


## Pasa a la tarjeta siguiente si la visible lleva el tiempo mínimo a la vista.
## Devuelve si ha avanzado.
func skip_card() -> bool:
	if _index < 0 or _card_elapsed < MIN_SKIP_SECONDS:
		return false
	_next_card()
	return true


## Avanza el tiempo de la tarjeta visible y de los fundidos. Público para poder
## probarlo sin depender de los fotogramas.
func advance(delta: float) -> void:
	if not visible:
		return
	if _closing_elapsed >= 0.0:
		_closing_elapsed += delta
		_background.color.a = clampf(1.0 - _closing_elapsed / BACKGROUND_FADE, 0.0, 1.0)
		if _closing_elapsed >= BACKGROUND_FADE:
			_closing_elapsed = -1.0
			visible = false
			finished.emit()
		return
	if _index < 0:
		return
	_card_elapsed += delta
	if _card_elapsed >= _card_seconds:
		_next_card()
		return
	var fade_in: float = clampf(_card_elapsed / TEXT_FADE, 0.0, 1.0)
	var fade_out: float = clampf((_card_seconds - _card_elapsed) / TEXT_FADE, 0.0, 1.0)
	_text_label.modulate.a = minf(fade_in, fade_out)


func _show_card(index: int) -> void:
	_index = index
	_text_label.text = _texts[index]
	_text_label.modulate.a = 0.0
	_card_seconds = card_seconds(_texts[index])
	_card_elapsed = 0.0


func _next_card() -> void:
	if _index + 1 < _texts.size():
		_show_card(_index + 1)
		return
	_index = -1
	_text_label.text = ""
	_hint_label.text = ""
	_closing_elapsed = 0.0
