extends RefCounted
## Comprueba la línea de objetivo del HUD: aparece con texto traducido, se
## actualiza y se retira sin dejar rastro.


func test_hud_objective() -> bool:
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
	var label: Label = hud.get_node_or_null("ObjectiveLabel") as Label
	var ok: bool = (
		label != null
		and not hud.is_showing_objective()
		and hud.get_objective_text().is_empty()
	)
	var text: String = tr("PCH_OBJ_QUERO")
	ok = ok and not text.begins_with("PCH_") and not text.is_empty()
	hud.show_objective(text)
	ok = ok and hud.is_showing_objective() and label.visible
	ok = ok and hud.get_objective_text() == text
	hud.show_objective(tr("PCH_OBJ_OFFERING"))
	ok = ok and hud.get_objective_text() == tr("PCH_OBJ_OFFERING")
	hud.clear_objective()
	ok = ok and not hud.is_showing_objective()
	ok = ok and hud.get_objective_text().is_empty() and not label.visible
	hud.free()
	return ok
