extends RefCounted
## El panel de pausa debe ofrecer continuar, volver al título y salir.

const HUD_PATH: String = "res://core/ui/hud.tscn"


func test_pause_panel_has_menu() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load(HUD_PATH) as PackedScene
	if packed == null:
		return false
	var hud: PlayerHud = packed.instantiate() as PlayerHud
	if hud == null:
		return false
	tree.root.add_child(hud)
	var panel: Control = hud.pause_panel
	if panel == null:
		hud.free()
		return false
	var resume: Button = panel.get_node_or_null("PauseMenu/Resume") as Button
	var title: Button = panel.get_node_or_null("PauseMenu/Title") as Button
	var quit: Button = panel.get_node_or_null("PauseMenu/Quit") as Button
	var ok: bool = resume != null and title != null and quit != null
	ok = ok and not resume.text.begins_with("UI_")
	ok = ok and not title.text.begins_with("UI_")
	ok = ok and not quit.text.begins_with("UI_")
	hud.pause_panel.show_menu(true)
	ok = ok and panel.visible
	hud.pause_panel.show_menu(false)
	ok = ok and not panel.visible
	hud.free()
	return ok
