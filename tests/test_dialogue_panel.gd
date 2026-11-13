extends RefCounted
## Comprueba el panel de diálogo: línea, opciones, avance y cierre (ADR-0038).

const SCENE_PATH: String = "res://core/ui/dialogue_panel.tscn"


func _spawn() -> DialoguePanel:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		return null
	var panel: DialoguePanel = packed.instantiate() as DialoguePanel
	tree.root.add_child(panel)
	return panel


func test_dialogue_panel_open_and_choose() -> bool:
	var panel: DialoguePanel = _spawn()
	if panel == null:
		return false
	var chosen: Array[int] = []
	panel.choice_selected.connect(func(index: int) -> void: chosen.append(index))
	panel.open("Tejedora", "Hola", ["Una", "Dos"])
	var ok: bool = panel.is_open()
	ok = ok and panel.get_speaker() == "Tejedora"
	ok = ok and panel.get_text() == "Hola"
	ok = ok and panel.get_choice_count() == 2
	var second: Button = panel.get_node("Panel/Margin/VBox/Choices/Choice2") as Button
	ok = ok and second != null and second.visible and second.text.ends_with("Dos")
	if second != null:
		second.pressed.emit()
	ok = ok and chosen == [1]
	panel.close()
	ok = ok and not panel.is_open()
	panel.free()
	return ok


func test_dialogue_panel_advance() -> bool:
	var panel: DialoguePanel = _spawn()
	if panel == null:
		return false
	var advanced: Array[bool] = [false]
	panel.advanced.connect(func() -> void: advanced[0] = true)
	panel.open("Curaca", "Escucha.", [])
	var ok: bool = panel.get_choice_count() == 0
	var event: InputEventAction = InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	panel._unhandled_input(event)
	ok = ok and advanced[0]
	panel.set_line("Curaca", "Otra línea.", ["Sí", "No"])
	ok = ok and panel.get_text() == "Otra línea."
	ok = ok and panel.get_choice_count() == 2
	panel.free()
	return ok
