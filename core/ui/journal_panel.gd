class_name JournalPanel
extends Control
## Diario en pantalla: lista de encargos y «Memoria», con detalle y fuente.
##
## No conoce la campaña: recibe un [Journal] y lee sus entradas. Se abre y se
## cierra con la acción `journal` (J).

signal closed

@onready var title_label: Label = $Panel/Margin/VBox/Header/TitleLabel
@onready var hint_label: Label = $Panel/Margin/VBox/Header/HintLabel
@onready var entry_list: ItemList = $Panel/Margin/VBox/Content/EntryList
@onready var detail_title: Label = $Panel/Margin/VBox/Content/Detail/DetailTitle
@onready var detail_badge: Label = $Panel/Margin/VBox/Content/Detail/DetailBadge
@onready var detail_body: Label = $Panel/Margin/VBox/Content/Detail/DetailBody
@onready var detail_source: Label = $Panel/Margin/VBox/Content/Detail/DetailSource

var _open: bool = false
var _entries: Array[JournalEntry] = []


func _ready() -> void:
	theme = UiTheme.build()
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	title_label.text = tr("UI_JOURNAL_TITLE")
	hint_label.text = tr("UI_JOURNAL_HINT")
	entry_list.item_selected.connect(_on_entry_selected)


## Abre el diario con las entradas de [param journal].
func open(journal: Journal) -> void:
	if journal == null:
		return
	_refresh(journal)
	_open = true
	visible = true
	# El jugador abre el diario con el ratón capturado: sin foco, las flechas
	# no llegan a la lista y solo se podía leer la primera entrada.
	entry_list.grab_focus()


## Cierra el diario y avisa a quien lo abrió.
func close() -> void:
	if not _open:
		return
	_open = false
	visible = false
	closed.emit()


## Indica si el diario está abierto.
func is_open() -> bool:
	return _open


## Número de entradas a la vista.
func get_entry_count() -> int:
	return _entries.size()


## Selecciona una entrada por índice, como si el jugador la hubiera pulsado.
func select_entry(index: int) -> void:
	if index < 0 or index >= _entries.size():
		return
	entry_list.select(index)
	_show_entry(index)


## Texto del detalle, para las pruebas.
func get_detail_text() -> String:
	return detail_body.text


## Texto del título del detalle, para las pruebas.
func get_detail_title() -> String:
	return detail_title.text


func _refresh(journal: Journal) -> void:
	entry_list.clear()
	_entries = journal.get_entries()
	if _entries.is_empty():
		detail_title.text = ""
		detail_badge.text = ""
		detail_body.text = tr("UI_JOURNAL_EMPTY")
		detail_source.text = ""
		return
	for entry: JournalEntry in _entries:
		var label: String = tr(String(entry.title_key))
		if entry.kind == JournalEntry.Kind.MEMORY and entry.badge != &"":
			label += "  [" + String(entry.badge) + "]"
		entry_list.add_item(label)
	entry_list.select(0)
	_show_entry(0)


func _show_entry(index: int) -> void:
	if index < 0 or index >= _entries.size():
		return
	var entry: JournalEntry = _entries[index]
	detail_title.text = tr(String(entry.title_key))
	detail_badge.text = ""
	if entry.kind == JournalEntry.Kind.MEMORY and entry.badge != &"":
		detail_badge.text = "[" + String(entry.badge) + "]"
	detail_body.text = tr(String(entry.body_key))
	detail_source.text = ""
	if entry.kind == JournalEntry.Kind.MEMORY and entry.source_key != &"":
		detail_source.text = tr("UI_JOURNAL_SOURCE") % String(entry.source_key)


func _on_entry_selected(index: int) -> void:
	_show_entry(index)

