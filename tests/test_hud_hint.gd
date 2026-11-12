extends RefCounted
## Comprueba la indicación breve del HUD (ADR-0024): aparece con fundido y se
## oculta al terminar su tiempo.


func test_hud_hint() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://core/ui/hud.tscn") as PackedScene
	if packed == null:
		return false
	var hud: PlayerHud = packed.instantiate() as PlayerHud
	if hud == null:
		return false
	tree.root.add_child(hud)
	var label: Label = hud.get_node_or_null("HintLabel") as Label
	var ok: bool = label != null and not hud.is_showing_hint()
	var text: String = tr("UI_CONTROLS_HINT")
	ok = ok and not text.begins_with("UI_") and text.contains("WASD") and text.contains("E ")
	hud.show_hint(text, 8.0)
	ok = ok and hud.is_showing_hint() and label.modulate.a < 0.01
	hud.advance_hint(4.0)
	ok = ok and hud.is_showing_hint() and label.modulate.a > 0.9
	hud.advance_hint(4.1)
	ok = ok and not hud.is_showing_hint()
	hud.free()
	return ok
