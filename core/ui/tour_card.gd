class_name TourCard
extends Control
## Tarjeta de estación del museo explorable (ADR-0034).
##
## Muestra título, cuerpo, sello de clasificación y fuente. Mientras está
## abierta, la escena que la usa desactiva al jugador; se cierra con E o Esc y
## emite [signal closed]. No conoce la campaña.

signal closed

@onready var title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var badge_label: Label = $Panel/Margin/VBox/BadgeLabel
@onready var body_label: Label = $Panel/Margin/VBox/BodyLabel
@onready var source_label: Label = $Panel/Margin/VBox/SourceLabel

var _open: bool = false


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


## Abre la tarjeta con el contenido ya traducido.
func open(title: String, body: String, badge: String, source: String) -> void:
	title_label.text = title
	body_label.text = body
	badge_label.text = badge
	source_label.text = source
	_open = true
	visible = true


## Cierra la tarjeta y avisa a quien la abrió.
func close() -> void:
	if not _open:
		return
	_open = false
	visible = false
	closed.emit()


## Indica si la tarjeta está a la vista.
func is_open() -> bool:
	return _open


## Texto del título, para las pruebas.
func get_title_text() -> String:
	return title_label.text


## Texto del sello, para las pruebas.
func get_badge_text() -> String:
	return badge_label.text


func _unhandled_input(event: InputEvent) -> void:
	if not _open:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		close()
