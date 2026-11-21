class_name SleepOverlay
extends CanvasLayer
## Aviso a pantalla completa al dormir o al cargar una partida.
##
## Tapa la escena con un fundido negro y dos líneas: el titular y el detalle
## (día, hora y si se guardó). Se desvanece solo; no bloquea la partida ni pausa
## el árbol. `advance()` permite moverlo con tiempo fijo en las pruebas.

const LAYER: int = 120
const MINUTES_PER_HOUR: int = 60
const HOLD_SECONDS: float = 1.1
const FADE_SECONDS: float = 1.4
const TITLE_SIZE: int = 34
const DETAIL_SIZE: int = 22
const BACKDROP_COLOR: Color = Color(0.02, 0.018, 0.015, 1.0)
const TITLE_COLOR: Color = Color(0.97, 0.93, 0.82, 1.0)
const DETAIL_COLOR: Color = Color(0.86, 0.80, 0.66, 1.0)

const REST_TITLE_KEY: StringName = &"UI_SLEPT_TITLE"
const LOADED_TITLE_KEY: StringName = &"UI_LOADED_TITLE"
const DETAIL_KEY: StringName = &"UI_SLEPT_DETAIL"
const SAVED_KEY: StringName = &"UI_SAVED"
const SAVE_FAILED_KEY: StringName = &"UI_SAVE_FAILED"

var _root: Control = null
var _title_label: Label = null
var _detail_label: Label = null
var _elapsed: float = 0.0
var _active: bool = false


func _ready() -> void:
	layer = LAYER
	_build()
	set_process(false)
	hide()


## Aviso de descanso: día y minuto nuevos, y si el guardado salió bien.
func show_rest(day: int, minute: int, saved: bool) -> void:
	var detail: String = tr(String(DETAIL_KEY)) % [day, format_minute(minute)]
	detail += "\n" + tr(String(SAVED_KEY if saved else SAVE_FAILED_KEY))
	_show(tr(String(REST_TITLE_KEY)), detail)


## Aviso de partida cargada.
func show_loaded(day: int, minute: int) -> void:
	_show(tr(String(LOADED_TITLE_KEY)), tr(String(DETAIL_KEY)) % [day, format_minute(minute)])


## Indica si el aviso sigue en pantalla.
func is_active() -> bool:
	return _active


func get_title_text() -> String:
	return _title_label.text if _title_label != null else ""


func get_detail_text() -> String:
	return _detail_label.text if _detail_label != null else ""


## Adelanta el fundido. En el juego lo llama `_process` con el delta real.
func advance(delta: float) -> void:
	if not _active or delta <= 0.0:
		return
	_elapsed += delta
	var fade: float = clampf((_elapsed - HOLD_SECONDS) / FADE_SECONDS, 0.0, 1.0)
	if _root != null:
		_root.modulate.a = 1.0 - fade
	if fade >= 1.0:
		_active = false
		set_process(false)
		hide()


## Hora `HH:MM` del minuto del día, para el detalle del aviso.
static func format_minute(minute: int) -> String:
	var safe: int = clampi(minute, 0, 1439)
	return "%02d:%02d" % [safe / MINUTES_PER_HOUR, safe % MINUTES_PER_HOUR]


func _process(delta: float) -> void:
	advance(delta)


func _show(title: String, detail: String) -> void:
	_title_label.text = title
	_detail_label.text = detail
	_elapsed = 0.0
	_active = true
	if _root != null:
		_root.modulate.a = 1.0
	set_process(true)
	show()


func _build() -> void:
	_root = Control.new()
	_root.name = "Fade"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var backdrop: ColorRect = ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.color = BACKDROP_COLOR
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(backdrop)
	var column: VBoxContainer = VBoxContainer.new()
	column.name = "Column"
	column.set_anchors_preset(Control.PRESET_CENTER)
	column.grow_horizontal = Control.GROW_DIRECTION_BOTH
	column.grow_vertical = Control.GROW_DIRECTION_BOTH
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 10)
	_root.add_child(column)
	_title_label = Label.new()
	_title_label.name = "Title"
	_title_label.text = ""
	_title_label.add_theme_font_size_override("font_size", TITLE_SIZE)
	_title_label.add_theme_color_override("font_color", TITLE_COLOR)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_title_label)
	_detail_label = Label.new()
	_detail_label.name = "Detail"
	_detail_label.text = ""
	_detail_label.add_theme_font_size_override("font_size", DETAIL_SIZE)
	_detail_label.add_theme_color_override("font_color", DETAIL_COLOR)
	_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_detail_label)
