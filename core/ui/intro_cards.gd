class_name IntroCards
extends Control
## Tarjetas de texto a pantalla completa antes de que empiece el juego.
##
## Muestra una lista de textos ya traducidos, uno tras otro, con fundidos. Cada
## tarjeta dura su tiempo de lectura (la misma regla que los subtítulos,
## ADR-0012) y la acción `interact` pasa a la siguiente. Al terminar la última,
## el fondo se funde y emite [signal finished]. No conoce ninguna campaña: los
## textos y la indicación llegan desde fuera (ADR-0023).
##
## Fondos por tarjeta (ADR-0025):
## - opaca y sin capa: fondo negro y texto centrado;
## - transparente: deja ver lo que hay detrás (por ejemplo, una toma del
##   mundo) y pone el texto en el tercio inferior sobre una franja oscura;
## - con capa ([method set_overlay]): muestra un Control propio (por ejemplo,
##   un mapa) entre el fondo y el texto, también con el texto abajo.
## [signal card_shown] avisa de cada tarjeta para que la escena mueva su cámara.

signal finished
signal card_shown(index: int, seconds: float)

## Fundido de entrada y de salida de cada texto, y del fondo entre tarjetas.
const TEXT_FADE: float = 0.6
## Fundido del fondo al terminar la última tarjeta.
const BACKGROUND_FADE: float = 1.2
## Tiempo mínimo a la vista antes de aceptar `interact`, para que una pulsación
## doble no se salte una tarjeta sin leerla.
const MIN_SKIP_SECONDS: float = 0.6
const TEXT_FONT_SIZE: int = 36
const HINT_FONT_SIZE: int = 20
const TEXT_MAX_WIDTH: float = 1100.0
## Franja oscura bajo el texto cuando se ve una imagen detrás.
const BAND_ALPHA: float = 0.6
const BAND_HEIGHT: float = 220.0
const BAND_BOTTOM_MARGIN: float = 120.0

var _background: ColorRect = null
var _overlay_root: Control = null
var _band: ColorRect = null
var _text_label: Label = null
var _hint_label: Label = null
var _texts: Array[String] = []
var _opaque: Array[bool] = []
var _overlays: Dictionary[int, Control] = {}
var _index: int = -1
var _card_seconds: float = 0.0
var _card_elapsed: float = 0.0
var _closing_elapsed: float = -1.0
var _background_target: float = 1.0
var _band_target: float = 0.0
var _closing_from_background: float = 0.0
var _closing_from_band: float = 0.0


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
	_overlay_root = Control.new()
	_overlay_root.name = "Overlays"
	_overlay_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay_root)
	_band = ColorRect.new()
	_band.name = "Band"
	_band.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_band.offset_top = -BAND_BOTTOM_MARGIN - BAND_HEIGHT
	_band.offset_bottom = -BAND_BOTTOM_MARGIN
	_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_band.color = Color(0.0, 0.0, 0.0, 0.0)
	add_child(_band)
	_text_label = Label.new()
	_text_label.name = "Text"
	_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.add_theme_font_size_override("font_size", TEXT_FONT_SIZE)
	_text_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	_text_label.add_theme_constant_override("outline_size", 6)
	_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_text_label)
	_place_text(true)
	_hint_label = Label.new()
	_hint_label.name = "Hint"
	_hint_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hint_label.offset_left = -400.0
	_hint_label.offset_right = 400.0
	_hint_label.offset_top = -90.0
	_hint_label.offset_bottom = -50.0
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.add_theme_font_size_override("font_size", HINT_FONT_SIZE)
	_hint_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	_hint_label.add_theme_constant_override("outline_size", 4)
	_hint_label.modulate = Color(1.0, 1.0, 1.0, 0.7)
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


## Pone [param control] como capa de la tarjeta [param index]: se muestra solo
## durante esa tarjeta, entre el fondo y el texto. Se llama antes de
## [method play].
func set_overlay(index: int, control: Control) -> void:
	if control == null:
		return
	if _overlays.has(index):
		_overlays[index].queue_free()
	_overlays[index] = control
	control.visible = false
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay_root.add_child(control)


## Empieza a mostrar [param texts] (ya traducidos) con la indicación
## [param hint] al pie. [param opaque] dice, por tarjeta, si el fondo es negro
## (`true`, el valor si falta) o deja ver lo que hay detrás. Sin textos termina
## en el acto.
func play(texts: Array[String], hint: String, opaque: Array[bool] = []) -> void:
	_texts = texts.duplicate()
	_opaque = opaque.duplicate()
	_hint_label.text = hint
	_closing_elapsed = -1.0
	if _texts.is_empty():
		_index = -1
		visible = false
		finished.emit()
		return
	visible = true
	_show_card(0)
	# La primera tarjeta aparece sin fundido de fondo.
	_background.color.a = _background_target
	_band.color.a = _band_target


## Indica si hay una tarjeta a la vista o el fondo aún se está fundiendo.
func is_playing() -> bool:
	return visible and (_index >= 0 or _closing_elapsed >= 0.0)


## Índice de la tarjeta visible, o -1 si no hay ninguna.
func current_index() -> int:
	return _index


## Texto de la tarjeta visible.
func current_text() -> String:
	return _text_label.text if _index >= 0 else ""


## Indica si la tarjeta [param index] tiene fondo negro.
func is_card_opaque(index: int) -> bool:
	return _opaque[index] if index >= 0 and index < _opaque.size() else true


## Opacidad actual del fondo negro (0 deja ver lo que hay detrás).
func background_alpha() -> float:
	return _background.color.a


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
		var t: float = clampf(1.0 - _closing_elapsed / BACKGROUND_FADE, 0.0, 1.0)
		_background.color.a = _closing_from_background * t
		_band.color.a = _closing_from_band * t
		if _closing_elapsed >= BACKGROUND_FADE:
			_closing_elapsed = -1.0
			visible = false
			finished.emit()
		return
	if _index < 0:
		return
	var step: float = delta / TEXT_FADE
	_background.color.a = move_toward(_background.color.a, _background_target, step)
	_band.color.a = move_toward(_band.color.a, _band_target, step * BAND_ALPHA)
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
	var has_overlay: bool = _overlays.has(index)
	var opaque: bool = is_card_opaque(index) and not has_overlay
	_background_target = 1.0 if opaque else 0.0
	_band_target = 0.0 if opaque else BAND_ALPHA
	_place_text(opaque)
	for key: int in _overlays:
		_overlays[key].visible = key == index
	card_shown.emit(index, _card_seconds)
	SessionLog.mark(&"intro_card", str(index + 1))


func _next_card() -> void:
	if _index + 1 < _texts.size():
		_show_card(_index + 1)
		return
	_index = -1
	_text_label.text = ""
	_hint_label.text = ""
	for key: int in _overlays:
		_overlays[key].visible = false
	_closing_from_background = _background.color.a
	_closing_from_band = _band.color.a
	_closing_elapsed = 0.0


## Texto centrado en pantalla (tarjeta negra) o en el tercio inferior, sobre la
## franja (tarjeta con imagen detrás).
func _place_text(centered: bool) -> void:
	if centered:
		_text_label.set_anchors_preset(Control.PRESET_CENTER)
		_text_label.offset_left = -TEXT_MAX_WIDTH * 0.5
		_text_label.offset_right = TEXT_MAX_WIDTH * 0.5
		_text_label.offset_top = -160.0
		_text_label.offset_bottom = 160.0
		return
	_text_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_text_label.offset_left = -TEXT_MAX_WIDTH * 0.5
	_text_label.offset_right = TEXT_MAX_WIDTH * 0.5
	_text_label.offset_top = -BAND_BOTTOM_MARGIN - BAND_HEIGHT
	_text_label.offset_bottom = -BAND_BOTTOM_MARGIN
