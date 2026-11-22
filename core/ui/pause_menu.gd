class_name PauseMenu
extends Control
## Menú de pausa del HUD.
##
## Vive en el nodo `PausePanel` y no conoce campañas: solo habla con
## [GameManagerService] para reanudar, volver al título o salir. El HUD lo
## muestra cuando `GameManager` emite `pause_changed`.

@onready var _label: Label = $PauseLabel
@onready var _resume: Button = $PauseMenu/Resume
@onready var _title: Button = $PauseMenu/Title
@onready var _quit: Button = $PauseMenu/Quit


func _ready() -> void:
	# Los textos del `.tscn` son claves; se traducen aquí para que el panel
	# funcione también en pruebas que instancian el HUD sin el editor.
	_label.text = tr("UI_PAUSED")
	_resume.text = tr("UI_RESUME")
	_title.text = tr("UI_TITLE")
	_quit.text = tr("UI_QUIT")
	_resume.pressed.connect(_on_resume)
	_title.pressed.connect(_on_title)
	_quit.pressed.connect(_on_quit)


## Muestra u oculta el menú y deja el foco en «Continuar».
func show_menu(paused: bool) -> void:
	visible = paused
	if paused:
		_resume.grab_focus()
	var parent: CanvasItem = get_parent() as CanvasItem
	if parent != null:
		parent.queue_redraw()


func _on_resume() -> void:
	var manager: GameManagerService = GameManagerService.instance()
	if manager != null:
		manager.set_paused(false)
	else:
		visible = false


func _on_title() -> void:
	var manager: GameManagerService = GameManagerService.instance()
	if manager != null:
		manager.return_to_title()
	else:
		get_tree().change_scene_to_file(GameManagerService.TITLE_SCENE)


func _on_quit() -> void:
	var manager: GameManagerService = GameManagerService.instance()
	if manager != null:
		manager.request_quit()
	else:
		get_tree().quit()
